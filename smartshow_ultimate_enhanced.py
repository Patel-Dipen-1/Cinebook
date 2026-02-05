# SmartShow Ultimate - Complete Entertainment Booking System
# Movies, Comedy Shows, Concerts with PostgreSQL and Streamlit

import streamlit as st
import psycopg2
from psycopg2.extras import RealDictCursor
import psycopg2.errors
import random
import json
import time
from datetime import datetime, timedelta
import plotly.express as px
import plotly.graph_objects as go
import pandas as pd

# Page configuration
st.set_page_config(
    page_title="SmartShow Ultimate - Complete",
    page_icon="🎬",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Initialize session state
if 'logged_in_user' not in st.session_state:
    st.session_state.logged_in_user = None
if 'admin_logged_in' not in st.session_state:
    st.session_state.admin_logged_in = None
if 'db_password' not in st.session_state:
    st.session_state.db_password = None
if 'conn' not in st.session_state:
    st.session_state.conn = None
if 'cursor' not in st.session_state:
    st.session_state.cursor = None
if 'db_ready' not in st.session_state:
    st.session_state.db_ready = False

def reset_and_create_database():
    """Completely reset and create database with correct structure"""
    try:
        password = st.session_state.db_password
        
        # Connect to PostgreSQL server
        server_conn = psycopg2.connect(
            host='localhost',
            user='postgres',
            password=password,
            port=5432
        )
        server_conn.autocommit = True
        server_cursor = server_conn.cursor()
        
        # Force drop and recreate database
        server_cursor.execute("SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'cinebook'")
        server_cursor.execute("DROP DATABASE IF EXISTS cinebook")
        server_cursor.execute("CREATE DATABASE cinebook")
        
        server_cursor.close()
        server_conn.close()
        
        # Connect to new database
        conn = psycopg2.connect(
            host='localhost',
            user='postgres',
            password=password,
            database='cinebook',
            port=5432
        )
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        
        # Create all tables with correct structure
        create_all_tables(cursor, conn)
        insert_all_sample_data(cursor, conn)
        
        st.session_state.conn = conn
        st.session_state.cursor = cursor
        st.session_state.db_ready = True
        
        return True
    except Exception as e:
        st.error(f"❌ Database creation failed: {e}")
        return False

def connect_to_existing_database():
    """Connect to existing database and check/fix structure"""
    try:
        password = st.session_state.db_password
        
        # First check if database exists
        server_conn = psycopg2.connect(
            host='localhost',
            user='postgres',
            password=password,
            port=5432
        )
        server_conn.autocommit = True
        server_cursor = server_conn.cursor()
        
        # Check if database exists
        server_cursor.execute("SELECT 1 FROM pg_catalog.pg_database WHERE datname = 'cinebook'")
        db_exists = server_cursor.fetchone()
        
        if not db_exists:
            # Create database if it doesn't exist
            server_cursor.execute("CREATE DATABASE cinebook")
            st.info("📝 Database 'cinebook' created as it didn't exist")
        
        server_cursor.close()
        server_conn.close()
        
        # Connect to the database
        conn = psycopg2.connect(
            host='localhost',
            user='postgres',
            password=password,
            database='cinebook',
            port=5432
        )
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        
        # Check if theatre_rows table has show_time column
        try:
            cursor.execute("""
                SELECT column_name FROM information_schema.columns 
                WHERE table_name='theatre_rows' AND column_name='show_time'
            """)
            show_time_exists = cursor.fetchone()
            
            if not show_time_exists:
                st.warning("⚠️ Database structure needs updating. Fixing automatically...")
                # Force recreation of database structure
                cursor.close()
                conn.close()
                return reset_and_create_database()
        except:
            # If any error occurs, reset the database
            st.warning("⚠️ Database structure issues detected. Resetting database...")
            cursor.close()
            conn.close()
            return reset_and_create_database()
        
        # Check and fix database structure
        fix_database_structure(cursor, conn)
        
        st.session_state.conn = conn
        st.session_state.cursor = cursor
        st.session_state.db_ready = True
        
        return True
    except Exception as e:
        st.error(f"❌ Database connection failed: {e}")
        st.info("💡 Try using the 'Reset DB' button to create a fresh database.")
        return False
def fix_database_structure(cursor, conn):
    """Check and fix database structure issues"""
    try:
        # First ensure all basic tables exist
        ensure_all_tables_exist(cursor, conn)
        
        # Check if theatre_rows table exists and has show_time and show_date columns
        cursor.execute("""
            SELECT column_name FROM information_schema.columns 
            WHERE table_name='theatre_rows' AND column_name IN ('show_time', 'show_date')
        """)
        columns = cursor.fetchall()
        column_names = [col['column_name'] for col in columns]
        
        if 'show_time' not in column_names or 'show_date' not in column_names:
            st.info("🔧 Fixing theatre_rows table structure to include date-specific seats...")
            
            # Check if theatre_rows table exists at all
            cursor.execute("""
                SELECT EXISTS (
                    SELECT FROM information_schema.tables 
                    WHERE table_name = 'theatre_rows'
                )
            """)
            table_exists = cursor.fetchone()[0]
            
            if table_exists:
                # Drop the old table
                cursor.execute("DROP TABLE IF EXISTS theatre_rows CASCADE")
            
            # Create new table with show_time and show_date columns
            cursor.execute("""
                CREATE TABLE theatre_rows (
                    id SERIAL PRIMARY KEY,
                    theatre_id INTEGER NOT NULL,
                    row_name VARCHAR(5) NOT NULL,
                    show_date DATE NOT NULL,
                    show_time VARCHAR(20) NOT NULL,
                    total_seats INTEGER NOT NULL,
                    available_seats INTEGER NOT NULL,
                    price_multiplier DECIMAL(3,2) DEFAULT 1.0,
                    FOREIGN KEY (theatre_id) REFERENCES theatres(theater_id),
                    UNIQUE (theatre_id, row_name, show_date, show_time)
                )
            """)
            st.success("✅ Theatre rows table structure fixed with date-specific seats!")
            
            # Force recreation of theatre rows data
            recreate_theatre_rows_data(cursor, conn)
        
        # Add sample data if tables are empty
        cursor.execute("SELECT COUNT(*) as count FROM theatres")
        theatre_count = cursor.fetchone()['count']
        
        if theatre_count == 0:
            st.info("📝 Adding sample data to empty database...")
            insert_all_sample_data(cursor, conn)
            st.success("✅ Sample data added!")
        else:
            # Check if theatre_rows has data
            cursor.execute("SELECT COUNT(*) as count FROM theatre_rows")
            rows_count = cursor.fetchone()['count']
            if rows_count == 0:
                st.info("📝 Adding theatre rows data...")
                recreate_theatre_rows_data(cursor, conn)
                st.success("✅ Theatre rows data added!")
        
        conn.commit()
    except Exception as e:
        st.error(f"❌ Error fixing database structure: {e}")
        conn.rollback()

def recreate_theatre_rows_data(cursor, conn):
    """Recreate theatre rows data with date and movie-specific show times"""
    try:
        # Clear existing data
        cursor.execute("DELETE FROM theatre_rows")
        
        # Get all unique show times from all movies
        all_show_times = set()
        for movie_id in range(1, 21):  # Movies 1-20
            show_times = get_movie_show_times(movie_id)
            all_show_times.update(show_times)
        
        # Convert to sorted list
        all_show_times = sorted(list(all_show_times))
        
        # Get next 3 days for booking
        available_dates = get_next_few_days(3)
        
        st.info(f"Creating seat data for {len(all_show_times)} show times across {len(available_dates)} dates...")
        
        for theatre_id in [1, 2, 3, 4, 5]:
            if theatre_id == 1:  # 120 seats
                rows = [("A", 30, 1.5), ("B", 35, 1.2), ("C", 30, 1.0), ("D", 15, 0.8), ("E", 10, 0.7)]
            elif theatre_id == 2:  # 90 seats
                rows = [("A", 25, 1.5), ("B", 30, 1.2), ("C", 20, 1.0), ("D", 15, 0.8)]
            elif theatre_id == 3:  # 105 seats
                rows = [("A", 30, 1.5), ("B", 35, 1.2), ("C", 25, 1.0), ("D", 15, 0.8)]
            elif theatre_id == 4:  # 75 seats
                rows = [("A", 20, 1.5), ("B", 25, 1.2), ("C", 20, 1.0), ("D", 10, 0.8)]
            else:  # 60 seats
                rows = [("A", 20, 1.5), ("B", 25, 1.2), ("C", 15, 1.0)]
            
            # Create rows for each date and show time combination
            for date_info in available_dates:
                show_date = date_info['date']
                for show_time in all_show_times:
                    for row_name, seats_in_row, price_mult in rows:
                        cursor.execute("""
                            INSERT INTO theatre_rows 
                            (theatre_id, row_name, show_date, show_time, total_seats, available_seats, price_multiplier)
                            VALUES (%s, %s, %s, %s, %s, %s, %s)
                        """, (theatre_id, row_name, show_date, show_time, seats_in_row, seats_in_row, price_mult))
        
        conn.commit()
        st.success(f"✅ Created seat data for {len(all_show_times)} show times across {len(available_dates)} dates for all theatres!")
    except Exception as e:
        st.error(f"❌ Error recreating theatre rows data: {e}")
        conn.rollback()

def ensure_all_tables_exist(cursor, conn):
    """Ensure all required tables exist"""
    # Check and create missing tables
    required_tables = {
        'users': """
            CREATE TABLE IF NOT EXISTS users (
                id SERIAL PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                email VARCHAR(100) UNIQUE NOT NULL,
                password VARCHAR(10) NOT NULL,
                password_display VARCHAR(20) NOT NULL,
                area VARCHAR(100) NOT NULL,
                otp VARCHAR(10),
                otp_expiry TIMESTAMP,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """,
        'admin_users': """
            CREATE TABLE IF NOT EXISTS admin_users (
                admin_id SERIAL PRIMARY KEY,
                username VARCHAR(50) UNIQUE NOT NULL,
                password VARCHAR(100) NOT NULL,
                full_name VARCHAR(100) NOT NULL,
                email VARCHAR(100) NOT NULL,
                role VARCHAR(50) DEFAULT 'ADMIN',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                last_login TIMESTAMP
            )
        """,
        'theatres': """
            CREATE TABLE IF NOT EXISTS theatres (
                theater_id INTEGER PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                area VARCHAR(100),
                city VARCHAR(50) DEFAULT 'Ahmedabad',
                theater_type VARCHAR(50),
                total_screens INTEGER,
                base_price INTEGER DEFAULT 250,
                total_seats INTEGER DEFAULT 50,
                available_seats INTEGER DEFAULT 50,
                address TEXT
            )
        """,
        'movies': """
            CREATE TABLE IF NOT EXISTS movies (
                id INTEGER PRIMARY KEY,
                movie_name VARCHAR(100) NOT NULL,
                mood VARCHAR(50) NOT NULL,
                duration_minutes INTEGER DEFAULT 150,
                rating VARCHAR(10) DEFAULT 'U/A',
                language VARCHAR(50) DEFAULT 'Hindi'
            )
        """,
        'comedy_shows': """
            CREATE TABLE IF NOT EXISTS comedy_shows (
                show_id INTEGER PRIMARY KEY,
                comedian_name VARCHAR(100) NOT NULL,
                show_title VARCHAR(150) NOT NULL,
                show_type VARCHAR(50) DEFAULT 'Stand-up Comedy',
                duration_minutes INTEGER DEFAULT 90,
                language VARCHAR(50) DEFAULT 'Hindi',
                age_rating VARCHAR(10) DEFAULT '18+',
                description TEXT,
                ticket_price INTEGER DEFAULT 500
            )
        """,
        'concerts': """
            CREATE TABLE IF NOT EXISTS concerts (
                concert_id INTEGER PRIMARY KEY,
                artist_name VARCHAR(100) NOT NULL,
                concert_title VARCHAR(150) NOT NULL,
                genre VARCHAR(50) NOT NULL,
                duration_minutes INTEGER DEFAULT 120,
                language VARCHAR(50) DEFAULT 'Hindi',
                ticket_price INTEGER DEFAULT 1000,
                description TEXT,
                special_guests TEXT
            )
        """,
        'venues': """
            CREATE TABLE IF NOT EXISTS venues (
                venue_id INTEGER PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                area VARCHAR(100),
                city VARCHAR(50) DEFAULT 'Ahmedabad',
                venue_type VARCHAR(50),
                capacity INTEGER DEFAULT 200,
                available_capacity INTEGER DEFAULT 200,
                base_price INTEGER DEFAULT 500,
                address TEXT,
                facilities TEXT
            )
        """,
        'bookings': """
            CREATE TABLE IF NOT EXISTS bookings (
                booking_id SERIAL PRIMARY KEY,
                user_email VARCHAR(100) NOT NULL,
                event_type VARCHAR(20) NOT NULL,
                event_id INTEGER NOT NULL,
                event_name VARCHAR(150) NOT NULL,
                venue_id INTEGER NOT NULL,
                venue_name VARCHAR(100) NOT NULL,
                show_date DATE NOT NULL,
                show_time VARCHAR(20) NOT NULL,
                booked_seats INTEGER NOT NULL,
                total_amount INTEGER NOT NULL,
                booking_date TIMESTAMP NOT NULL,
                seat_numbers TEXT,
                row_details TEXT,
                payment_method VARCHAR(50),
                payment_status VARCHAR(20) DEFAULT 'COMPLETED',
                transaction_id VARCHAR(100)
            )
        """,
        'payment_transactions': """
            CREATE TABLE IF NOT EXISTS payment_transactions (
                transaction_id VARCHAR(100) PRIMARY KEY,
                booking_id INTEGER,
                user_email VARCHAR(100) NOT NULL,
                amount INTEGER NOT NULL,
                payment_method VARCHAR(50) NOT NULL,
                payment_status VARCHAR(20) NOT NULL,
                transaction_date TIMESTAMP NOT NULL,
                card_last_digits VARCHAR(4),
                upi_id VARCHAR(100),
                failure_reason TEXT,
                FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
            )
        """
    }
    
    for table_name, create_sql in required_tables.items():
        cursor.execute(create_sql)
    
    conn.commit()
def create_all_tables(cursor, conn):
    """Create all tables with correct structure"""
    # Drop all tables first
    drop_tables = [
        "DROP TABLE IF EXISTS payment_transactions CASCADE",
        "DROP TABLE IF EXISTS bookings CASCADE",
        "DROP TABLE IF EXISTS theatre_rows CASCADE",
        "DROP TABLE IF EXISTS venues CASCADE",
        "DROP TABLE IF EXISTS concerts CASCADE",
        "DROP TABLE IF EXISTS comedy_shows CASCADE",
        "DROP TABLE IF EXISTS movies CASCADE",
        "DROP TABLE IF EXISTS theatres CASCADE",
        "DROP TABLE IF EXISTS admin_users CASCADE",
        "DROP TABLE IF EXISTS users CASCADE"
    ]
    
    for drop_sql in drop_tables:
        cursor.execute(drop_sql)
    
    # Create tables in correct order
    tables = [
        # Users table
        """
        CREATE TABLE users (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            email VARCHAR(100) UNIQUE NOT NULL,
            password VARCHAR(10) NOT NULL,
            password_display VARCHAR(20) NOT NULL,
            area VARCHAR(100) NOT NULL,
            otp VARCHAR(10),
            otp_expiry TIMESTAMP,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        """,
        # Admin users table
        """
        CREATE TABLE admin_users (
            admin_id SERIAL PRIMARY KEY,
            username VARCHAR(50) UNIQUE NOT NULL,
            password VARCHAR(100) NOT NULL,
            full_name VARCHAR(100) NOT NULL,
            email VARCHAR(100) NOT NULL,
            role VARCHAR(50) DEFAULT 'ADMIN',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            last_login TIMESTAMP
        )
        """,
        # Theatres table
        """
        CREATE TABLE theatres (
            theater_id INTEGER PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            area VARCHAR(100),
            city VARCHAR(50) DEFAULT 'Ahmedabad',
            theater_type VARCHAR(50),
            total_screens INTEGER,
            base_price INTEGER DEFAULT 250,
            total_seats INTEGER DEFAULT 50,
            available_seats INTEGER DEFAULT 50,
            address TEXT
        )
        """,
        # Movies table
        """
        CREATE TABLE movies (
            id INTEGER PRIMARY KEY,
            movie_name VARCHAR(100) NOT NULL,
            mood VARCHAR(50) NOT NULL,
            duration_minutes INTEGER DEFAULT 150,
            rating VARCHAR(10) DEFAULT 'U/A',
            language VARCHAR(50) DEFAULT 'Hindi'
        )
        """,
        # Comedy shows table
        """
        CREATE TABLE comedy_shows (
            show_id INTEGER PRIMARY KEY,
            comedian_name VARCHAR(100) NOT NULL,
            show_title VARCHAR(150) NOT NULL,
            show_type VARCHAR(50) DEFAULT 'Stand-up Comedy',
            duration_minutes INTEGER DEFAULT 90,
            language VARCHAR(50) DEFAULT 'Hindi',
            age_rating VARCHAR(10) DEFAULT '18+',
            description TEXT,
            ticket_price INTEGER DEFAULT 500
        )
        """,
        # Concerts table
        """
        CREATE TABLE concerts (
            concert_id INTEGER PRIMARY KEY,
            artist_name VARCHAR(100) NOT NULL,
            concert_title VARCHAR(150) NOT NULL,
            genre VARCHAR(50) NOT NULL,
            duration_minutes INTEGER DEFAULT 120,
            language VARCHAR(50) DEFAULT 'Hindi',
            ticket_price INTEGER DEFAULT 1000,
            description TEXT,
            special_guests TEXT
        )
        """,
        # Venues table
        """
        CREATE TABLE venues (
            venue_id INTEGER PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            area VARCHAR(100),
            city VARCHAR(50) DEFAULT 'Ahmedabad',
            venue_type VARCHAR(50),
            capacity INTEGER DEFAULT 200,
            available_capacity INTEGER DEFAULT 200,
            base_price INTEGER DEFAULT 500,
            address TEXT,
            facilities TEXT
        )
        """,
        # Theatre rows table WITH show_time AND show_date columns
        """
        CREATE TABLE theatre_rows (
            id SERIAL PRIMARY KEY,
            theatre_id INTEGER NOT NULL,
            row_name VARCHAR(5) NOT NULL,
            show_date DATE NOT NULL,
            show_time VARCHAR(20) NOT NULL,
            total_seats INTEGER NOT NULL,
            available_seats INTEGER NOT NULL,
            price_multiplier DECIMAL(3,2) DEFAULT 1.0,
            FOREIGN KEY (theatre_id) REFERENCES theatres(theater_id),
            UNIQUE (theatre_id, row_name, show_date, show_time)
        )
        """,
        # Bookings table
        """
        CREATE TABLE bookings (
            booking_id SERIAL PRIMARY KEY,
            user_email VARCHAR(100) NOT NULL,
            event_type VARCHAR(20) NOT NULL,
            event_id INTEGER NOT NULL,
            event_name VARCHAR(150) NOT NULL,
            venue_id INTEGER NOT NULL,
            venue_name VARCHAR(100) NOT NULL,
            show_date DATE NOT NULL,
            show_time VARCHAR(20) NOT NULL,
            booked_seats INTEGER NOT NULL,
            total_amount INTEGER NOT NULL,
            booking_date TIMESTAMP NOT NULL,
            seat_numbers TEXT,
            row_details TEXT,
            payment_method VARCHAR(50),
            payment_status VARCHAR(20) DEFAULT 'COMPLETED',
            transaction_id VARCHAR(100)
        )
        """,
        # Payment transactions table
        """
        CREATE TABLE payment_transactions (
            transaction_id VARCHAR(100) PRIMARY KEY,
            booking_id INTEGER,
            user_email VARCHAR(100) NOT NULL,
            amount INTEGER NOT NULL,
            payment_method VARCHAR(50) NOT NULL,
            payment_status VARCHAR(20) NOT NULL,
            transaction_date TIMESTAMP NOT NULL,
            card_last_digits VARCHAR(4),
            upi_id VARCHAR(100),
            failure_reason TEXT,
            FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
        )
        """
    ]
    
    for table_sql in tables:
        cursor.execute(table_sql)
    
    conn.commit()

def insert_all_sample_data(cursor, conn):
    """Insert all sample data"""
    try:
        # Insert admin user
        cursor.execute("""
            INSERT INTO admin_users (username, password, full_name, email, role)
            VALUES ('admin', 'Admin@123', 'System Administrator', 'admin@smartshow.com', 'SUPER_ADMIN')
        """)
        
        # Insert theatres
        theatres_data = [
            (1, "PVR Acropolis Mall", "Thaltej", "Ahmedabad", "Premium", 8, 350, 120, 120, "Acropolis Mall, Thaltej, Ahmedabad"),
            (2, "INOX R City Mall", "Paldi", "Ahmedabad", "Premium", 6, 320, 90, 90, "R City Mall, Paldi, Ahmedabad"),
            (3, "Cinepolis Alpha One Mall", "Vastrapur", "Ahmedabad", "Multiplex", 7, 300, 105, 105, "Alpha One Mall, Vastrapur, Ahmedabad"),
            (4, "PVR Himalaya Mall", "Satellite", "Ahmedabad", "Premium", 5, 330, 75, 75, "Himalaya Mall, Satellite, Ahmedabad"),
            (5, "Fun Cinemas Ahmedabad One", "Vastrapur", "Ahmedabad", "Multiplex", 4, 280, 60, 60, "Ahmedabad One Mall, Vastrapur")
        ]
        
        for theatre in theatres_data:
            cursor.execute("""
                INSERT INTO theatres (theater_id, name, area, city, theater_type, total_screens, base_price, total_seats, available_seats, address)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, theatre)
        
        # Insert venues for comedy shows and concerts
        venues_data = [
            (1, "Comedy Club Ahmedabad", "Satellite", "Ahmedabad", "Comedy Club", 150, 150, 500, "Satellite Road, Ahmedabad", "AC, Sound System, Bar"),
            (2, "Laugh Factory", "Vastrapur", "Ahmedabad", "Comedy Venue", 200, 200, 450, "Vastrapur, Ahmedabad", "AC, Stage Lighting"),
            (3, "Stand-Up Central", "Paldi", "Ahmedabad", "Comedy Hall", 120, 120, 550, "Paldi, Ahmedabad", "Premium Sound, AC"),
            (4, "Concert Hall Ahmedabad", "Thaltej", "Ahmedabad", "Concert Venue", 500, 500, 1000, "Thaltej, Ahmedabad", "Premium Sound, Lighting, VIP Seating"),
            (5, "Music Arena", "Satellite", "Ahmedabad", "Music Venue", 300, 300, 1200, "Satellite, Ahmedabad", "Professional Sound, Stage")
        ]
        
        for venue in venues_data:
            cursor.execute("""
                INSERT INTO venues (venue_id, name, area, city, venue_type, capacity, available_capacity, base_price, address, facilities)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, venue)
        
        # Insert movies (4 moods, 5 movies each)
        movies_data = [
            # Romantic Movies
            (1, "Titanic", "Romantic", 195, "PG-13", "English"),
            (2, "The Notebook", "Romantic", 123, "PG-13", "English"),
            (3, "La La Land", "Romantic", 128, "PG-13", "English"),
            (4, "Dilwale Dulhania Le Jayenge", "Romantic", 189, "U", "Hindi"),
            (5, "Jab We Met", "Romantic", 138, "U", "Hindi"),
            # Action Movies
            (6, "Avengers: Endgame", "Action", 181, "PG-13", "English"),
            (7, "Fast & Furious 9", "Action", 143, "PG-13", "English"),
            (8, "Baahubali 2", "Action", 167, "U/A", "Hindi"),
            (9, "KGF Chapter 2", "Action", 168, "U/A", "Hindi"),
            (10, "Pathaan", "Action", 146, "U/A", "Hindi"),
            # Comedy Movies
            (11, "Hera Pheri", "Comedy", 156, "U", "Hindi"),
            (12, "Golmaal", "Comedy", 150, "U", "Hindi"),
            (13, "Andaz Apna Apna", "Comedy", 160, "U", "Hindi"),
            (14, "Welcome", "Comedy", 159, "U", "Hindi"),
            (15, "Housefull", "Comedy", 140, "U/A", "Hindi"),
            # Family Movies
            (16, "Taare Zameen Par", "Family", 165, "U", "Hindi"),
            (17, "3 Idiots", "Family", 170, "U", "Hindi"),
            (18, "Dangal", "Family", 161, "U", "Hindi"),
            (19, "Finding Nemo", "Family", 100, "G", "English"),
            (20, "The Lion King", "Family", 88, "G", "English")
        ]
        
        for movie in movies_data:
            cursor.execute("""
                INSERT INTO movies (id, movie_name, mood, duration_minutes, rating, language) 
                VALUES (%s, %s, %s, %s, %s, %s)
            """, movie)
        
        # Insert comedy shows
        comedy_data = [
            (1, "Kapil Sharma", "The Kapil Sharma Show Live", "Stand-up Comedy", 90, "Hindi", "18+", "Hilarious comedy show", 500),
            (2, "Zakir Khan", "Haq Se Single", "Stand-up Comedy", 85, "Hindi", "18+", "Comedy about being single", 600),
            (3, "Biswa Kalyan Rath", "Pretentious Movie Reviews", "Stand-up Comedy", 80, "English", "18+", "Movie review comedy", 550),
            (4, "Kenny Sebastian", "The Most Interesting Person", "Stand-up Comedy", 75, "English", "16+", "Observational comedy", 650),
            (5, "Abhishek Upmanyu", "Thoda Saaf Bol", "Stand-up Comedy", 85, "Hindi", "18+", "Clean comedy show", 500)
        ]
        
        for comedy in comedy_data:
            cursor.execute("""
                INSERT INTO comedy_shows (show_id, comedian_name, show_title, show_type, duration_minutes, language, age_rating, description, ticket_price)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, comedy)
        
        # Insert concerts
        concert_data = [
            (1, "Arijit Singh", "Arijit Singh Live", "Bollywood", 120, "Hindi", 1000, "Romantic Bollywood hits", "Shreya Ghoshal"),
            (2, "A.R. Rahman", "Rahman Live Concert", "Classical/Fusion", 150, "Multi", 1500, "Musical maestro live", "Hariharan"),
            (3, "Nucleya", "Electronic Dance Night", "Electronic", 90, "Instrumental", 800, "EDM night", "Divine"),
            (4, "Rahat Fateh Ali Khan", "Sufi Night", "Sufi", 100, "Urdu", 1200, "Spiritual music", "Kailash Kher"),
            (5, "Sunidhi Chauhan", "Bollywood Diva Live", "Bollywood", 110, "Hindi", 900, "Energetic performance", "Shaan")
        ]
        
        for concert in concert_data:
            cursor.execute("""
                INSERT INTO concerts (concert_id, artist_name, concert_title, genre, duration_minutes, language, ticket_price, description, special_guests)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, concert)
        
        # Insert theatre rows with date and movie-specific show times
        # Get all unique show times from all movies
        all_show_times = set()
        for movie_id in range(1, 21):  # Movies 1-20
            show_times = get_movie_show_times(movie_id)
            all_show_times.update(show_times)
        
        # Convert to sorted list
        all_show_times = sorted(list(all_show_times))
        
        # Get next 3 days for booking
        available_dates = get_next_few_days(3)
        
        for theatre_id in [1, 2, 3, 4, 5]:
            if theatre_id == 1:  # 120 seats
                rows = [("A", 30, 1.5), ("B", 35, 1.2), ("C", 30, 1.0), ("D", 15, 0.8), ("E", 10, 0.7)]
            elif theatre_id == 2:  # 90 seats
                rows = [("A", 25, 1.5), ("B", 30, 1.2), ("C", 20, 1.0), ("D", 15, 0.8)]
            elif theatre_id == 3:  # 105 seats
                rows = [("A", 30, 1.5), ("B", 35, 1.2), ("C", 25, 1.0), ("D", 15, 0.8)]
            elif theatre_id == 4:  # 75 seats
                rows = [("A", 20, 1.5), ("B", 25, 1.2), ("C", 20, 1.0), ("D", 10, 0.8)]
            else:  # 60 seats
                rows = [("A", 20, 1.5), ("B", 25, 1.2), ("C", 15, 1.0)]
            
            # Create rows for each date and show time combination
            for date_info in available_dates:
                show_date = date_info['date']
                for show_time in all_show_times:
                    for row_name, seats_in_row, price_mult in rows:
                        cursor.execute("""
                            INSERT INTO theatre_rows 
                            (theatre_id, row_name, show_date, show_time, total_seats, available_seats, price_multiplier)
                            VALUES (%s, %s, %s, %s, %s, %s, %s)
                        """, (theatre_id, row_name, show_date, show_time, seats_in_row, seats_in_row, price_mult))
        
        conn.commit()
    except psycopg2.Error as e:
        st.error(f"❌ Error inserting sample data: {e}")
        conn.rollback()

# Validation Functions
def valid_email(email):
    """Enhanced email validation - no spaces allowed"""
    if " " in email:
        return False
    return email.endswith("@gmail.com") and len(email) > 10

def valid_password(pw):
    """Password validation - max 10 chars with requirements"""
    if len(pw) > 10:
        return False
    return any(c.isupper() for c in pw) and any(c.islower() for c in pw) and any(c.isdigit() for c in pw) and "@" in pw

def generate_otp():
    return str(random.randint(100000, 999999))

def generate_transaction_id():
    """Generate unique transaction ID"""
    return f"TXN{int(time.time())}{random.randint(1000, 9999)}"

def validate_upi_id(upi_id):
    """Validate UPI ID format"""
    if not upi_id:
        return False
    # Basic UPI ID validation: should contain @ and end with valid UPI handles
    valid_handles = ['@paytm', '@phonepe', '@gpay', '@amazonpay', '@ybl', '@okaxis', '@okicici', '@okhdfcbank', '@oksbi', '@okbizaxis']
    return '@' in upi_id and any(upi_id.endswith(handle) for handle in valid_handles)

def validate_card_number(card_number):
    """Basic card number validation"""
    if not card_number:
        return False
    # Remove spaces and check if it's 16 digits
    card_clean = card_number.replace(' ', '').replace('-', '')
    return card_clean.isdigit() and len(card_clean) == 16

def validate_cvv(cvv):
    """Validate CVV"""
    return cvv and cvv.isdigit() and len(cvv) in [3, 4]

def validate_expiry(month, year):
    """Validate card expiry"""
    if not month or not year:
        return False
    try:
        exp_month = int(month)
        exp_year = int(year)
        current_year = datetime.now().year
        current_month = datetime.now().month
        
        if exp_year < current_year or (exp_year == current_year and exp_month < current_month):
            return False
        return 1 <= exp_month <= 12 and current_year <= exp_year <= current_year + 10
    except:
        return False

def process_payment_details(payment_method, payment_data):
    """Process and validate payment details"""
    if payment_method == "UPI":
        if not validate_upi_id(payment_data.get('upi_id')):
            return False, "Invalid UPI ID format"
        return True, f"UPI: {payment_data['upi_id']}"
    elif payment_method == "Credit/Debit Card":
        if not validate_card_number(payment_data.get('card_number')):
            return False, "Invalid card number"
        if not validate_cvv(payment_data.get('cvv')):
            return False, "Invalid CVV"
        if not validate_expiry(payment_data.get('exp_month'), payment_data.get('exp_year')):
            return False, "Invalid or expired card"
        card_last_4 = payment_data['card_number'].replace(' ', '').replace('-', '')[-4:]
        return True, f"Card ending in {card_last_4}"
    elif payment_method == "Net Banking":
        if not payment_data.get('bank_name'):
            return False, "Please select a bank"
        if not payment_data.get('account_number'):
            return False, "Account number is required"
        return True, f"Net Banking: {payment_data['bank_name']}"
    return False, "Invalid payment method"

def write_ticket_to_file(event_type, booking_details):
    """Write ticket details to appropriate text file"""
    try:
        # Determine filename based on event type
        if event_type == "movie":
            filename = "movies.txt"
        elif event_type == "comedy":
            filename = "comedy.txt"
        elif event_type == "concert":
            filename = "concerts.txt"
        else:
            filename = "other_bookings.txt"
        
        # Create ticket information string
        ticket_info = f"""
{'='*60}
SMARTSHOW ULTIMATE - TICKET CONFIRMATION
{'='*60}
Booking ID: {booking_details['booking_id']}
Transaction ID: {booking_details['transaction_id']}
Event Type: {booking_details['event_type'].upper()}
Event Name: {booking_details['event_name']}
Venue: {booking_details['venue_name']}
User Email: {booking_details['user_email']}
Show Date: {booking_details['show_date']}
Show Time: {booking_details['show_time']}
Tickets Booked: {booking_details['booked_seats']}
Seat Numbers: {booking_details['seat_numbers']}
Total Amount: ₹{booking_details['total_amount']}
Payment Method: {booking_details['payment_method']}
Payment Status: {booking_details['payment_status']}
Booking Date: {booking_details['booking_date']}
{'='*60}

"""
        
        # Write to file (append mode)
        with open(filename, 'a', encoding='utf-8') as file:
            file.write(ticket_info)
        
        return True
    except Exception as e:
        st.error(f"❌ Error writing to file: {e}")
        return False
# Enhanced Payment Processing Functions

def show_complete_payment_form(payment_method, total_amount, event_type, back_step):
    """Complete payment form with all payment methods for all event types"""
    payment_data = {}
    payment_valid = False
    
    if payment_method == "UPI":
        st.write("### 📱 UPI Payment")
        with st.form(f"{event_type}_upi_payment_form"):
            upi_id = st.text_input("Enter UPI ID:", placeholder="yourname@paytm", 
                                 help="Example: john@paytm, mary@phonepe, user@gpay")
            
            col1, col2 = st.column
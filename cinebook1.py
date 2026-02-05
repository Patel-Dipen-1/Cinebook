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

def get_next_few_days(num_days=3):
    """Get next few days for booking"""
    dates = []
    for i in range(num_days):
        date = datetime.now().date() + timedelta(days=i)
        dates.append({
            'date': date,
            'display': date.strftime('%a, %b %d')
        })
    return dates

def get_movie_specific_theatres(movie_id, user_area, cursor):
    """Get 3 specific theatres for each movie from the 7 available in user's area"""
    # Get all theatres in user's area
    cursor.execute("""
        SELECT theater_id, name, area, theater_type, base_price, total_seats, address
        FROM theatres 
        WHERE area = %s
        ORDER BY theater_id
    """, (user_area,))
    all_theatres = cursor.fetchall()
    
    if len(all_theatres) < 3:
        return all_theatres
    
    # Movie-specific theatre mapping (each movie gets 3 different theatres)
    movie_theatre_mapping = {}
    
    # Create mapping for all 40 movies
    for i in range(1, 41):
        # Use modulo to cycle through available theatres, ensuring each movie gets 3 different ones
        start_idx = ((i - 1) * 2) % len(all_theatres)  # Different starting point for each movie
        selected_indices = []
        
        # Select 3 theatres with some spacing
        for j in range(3):
            idx = (start_idx + j * 2) % len(all_theatres)
            selected_indices.append(idx)
        
        # Remove duplicates and ensure we have 3 different theatres
        selected_indices = list(set(selected_indices))
        while len(selected_indices) < 3 and len(selected_indices) < len(all_theatres):
            for k in range(len(all_theatres)):
                if k not in selected_indices:
                    selected_indices.append(k)
                    break
        
        movie_theatre_mapping[i] = selected_indices[:3]
    
    # Get the specific theatres for this movie
    theatre_indices = movie_theatre_mapping.get(movie_id, [0, 1, 2])
    selected_theatres = []
    
    for idx in theatre_indices:
        if idx < len(all_theatres):
            selected_theatres.append(all_theatres[idx])
    
    return selected_theatres

def get_movie_show_times(movie_id):
    """Get show times based on movie ID - each movie has unique show times"""
    # Different show times for different movies to ensure variety
    movie_show_times = {
        # Romantic Movies (1-10) - Evening focused
        1: ["2:00 PM", "5:30 PM", "8:45 PM"],
        2: ["1:45 PM", "5:15 PM", "8:30 PM"],
        3: ["2:15 PM", "5:45 PM", "9:00 PM"],
        4: ["1:30 PM", "5:00 PM", "8:15 PM"],
        5: ["2:30 PM", "6:00 PM", "9:15 PM"],
        6: ["2:45 PM", "6:15 PM", "9:30 PM"],
        7: ["1:15 PM", "4:45 PM", "8:00 PM"],
        8: ["3:00 PM", "6:30 PM", "9:45 PM"],
        9: ["1:00 PM", "4:30 PM", "7:45 PM"],
        10: ["2:20 PM", "5:50 PM", "9:20 PM"],
        
        # Action Movies (11-20) - Multiple shows including late night
        11: ["12:30 PM", "4:00 PM", "7:30 PM", "10:45 PM"],
        12: ["12:15 PM", "3:45 PM", "7:15 PM", "10:30 PM"],
        13: ["12:45 PM", "4:15 PM", "7:45 PM", "11:00 PM"],
        14: ["1:00 PM", "4:30 PM", "8:00 PM", "11:15 PM"],
        15: ["12:00 PM", "3:30 PM", "7:00 PM", "10:15 PM"],
        16: ["11:45 AM", "3:15 PM", "6:45 PM", "10:00 PM"],
        17: ["1:15 PM", "4:45 PM", "8:15 PM", "11:30 PM"],
        18: ["11:30 AM", "3:00 PM", "6:30 PM", "9:45 PM"],
        19: ["12:20 PM", "3:50 PM", "7:20 PM", "10:50 PM"],
        20: ["11:15 AM", "2:45 PM", "6:15 PM", "9:30 PM"],
        
        # Comedy Movies (21-30) - Afternoon and evening
        21: ["1:30 PM", "4:30 PM", "7:00 PM", "9:30 PM"],
        22: ["1:15 PM", "4:15 PM", "6:45 PM", "9:15 PM"],
        23: ["1:45 PM", "4:45 PM", "7:15 PM", "9:45 PM"],
        24: ["2:00 PM", "5:00 PM", "7:30 PM", "10:00 PM"],
        25: ["1:00 PM", "4:00 PM", "6:30 PM", "9:00 PM"],
        26: ["1:20 PM", "4:20 PM", "6:50 PM", "9:20 PM"],
        27: ["1:35 PM", "4:35 PM", "7:05 PM", "9:35 PM"],
        28: ["1:50 PM", "4:50 PM", "7:20 PM", "9:50 PM"],
        29: ["1:10 PM", "4:10 PM", "6:40 PM", "9:10 PM"],
        30: ["1:25 PM", "4:25 PM", "6:55 PM", "9:25 PM"],
        
        # Family Movies (31-40) - Day shows and early evening
        31: ["11:00 AM", "2:30 PM", "6:00 PM", "9:00 PM"],
        32: ["10:45 AM", "2:15 PM", "5:45 PM", "8:45 PM"],
        33: ["11:15 AM", "2:45 PM", "6:15 PM", "9:15 PM"],
        34: ["10:30 AM", "2:00 PM", "5:30 PM", "8:30 PM"],
        35: ["11:30 AM", "3:00 PM", "6:30 PM", "9:30 PM"],
        36: ["10:15 AM", "1:45 PM", "5:15 PM", "8:15 PM"],
        37: ["11:45 AM", "3:15 PM", "6:45 PM", "9:45 PM"],
        38: ["10:00 AM", "1:30 PM", "5:00 PM", "8:00 PM"],
        39: ["12:00 PM", "3:30 PM", "7:00 PM", "10:00 PM"],
        40: ["10:20 AM", "1:50 PM", "5:20 PM", "8:20 PM"]
    }
    
    return movie_show_times.get(movie_id, ["2:00 PM", "6:00 PM", "9:00 PM"])

def recreate_theatre_rows_data(cursor, conn):
    """Recreate theatre rows data with date and movie-specific show times"""
    try:
        # Clear existing data
        cursor.execute("DELETE FROM theatre_rows")
        
        # Get all unique show times from all movies with individual timings
        all_show_times = set()
        
        # Add all movie show times
        for movie_id in range(1, 41):  # Movies 1-40
            show_times = get_movie_show_times(movie_id)
            all_show_times.update(show_times)
        
        # Add comedy show times
        comedy_times = ["6:00 PM", "6:15 PM", "6:30 PM", "6:45 PM", "7:00 PM", "8:30 PM", "8:45 PM", "9:00 PM", "9:15 PM", "9:30 PM"]
        all_show_times.update(comedy_times)
        
        # Add concert times
        concert_times = ["6:30 PM", "6:45 PM", "7:00 PM", "7:15 PM", "8:00 PM", "9:00 PM", "9:15 PM", "9:30 PM", "9:45 PM", "10:30 PM"]
        all_show_times.update(concert_times)
        
        # Convert to sorted list
        all_show_times = sorted(list(all_show_times))
        
        # Get next 3 days for booking
        available_dates = get_next_few_days(3)
        
        st.info(f"Creating seat data for {len(all_show_times)} show times across {len(available_dates)} dates...")
        
        for theatre_id in range(1, 57):  # 56 theatres total
            if theatre_id <= 7:  # Theatres 1-7 (120 seats)
                rows = [("A", 30, 1.5), ("B", 35, 1.2), ("C", 30, 1.0), ("D", 15, 0.8), ("E", 10, 0.7)]
            elif theatre_id <= 14:  # Theatres 8-14 (90 seats)
                rows = [("A", 25, 1.5), ("B", 30, 1.2), ("C", 20, 1.0), ("D", 15, 0.8)]
            elif theatre_id <= 21:  # Theatres 15-21 (105 seats)
                rows = [("A", 30, 1.5), ("B", 35, 1.2), ("C", 25, 1.0), ("D", 15, 0.8)]
            elif theatre_id <= 28:  # Theatres 22-28 (75 seats)
                rows = [("A", 20, 1.5), ("B", 25, 1.2), ("C", 20, 1.0), ("D", 10, 0.8)]
            elif theatre_id <= 35:  # Theatres 29-35 (60 seats)
                rows = [("A", 20, 1.5), ("B", 25, 1.2), ("C", 15, 1.0)]
            elif theatre_id <= 42:  # Theatres 36-42 (85 seats)
                rows = [("A", 25, 1.5), ("B", 30, 1.2), ("C", 20, 1.0), ("D", 10, 0.8)]
            elif theatre_id <= 49:  # Theatres 43-49 (70 seats)
                rows = [("A", 20, 1.5), ("B", 25, 1.2), ("C", 15, 1.0), ("D", 10, 0.8)]
            else:  # Theatres 50-56 (70 seats)
                rows = [("A", 20, 1.5), ("B", 25, 1.2), ("C", 15, 1.0), ("D", 10, 0.8)]
            
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
                transaction_id VARCHAR(100),
                base_amount INTEGER DEFAULT 0,
                gst_amount INTEGER DEFAULT 0,
                platform_fee INTEGER DEFAULT 0,
                theatre_share INTEGER DEFAULT 0,
                profit_amount INTEGER DEFAULT 0
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
            transaction_id VARCHAR(100),
            base_amount INTEGER DEFAULT 0,
            gst_amount INTEGER DEFAULT 0,
            platform_fee INTEGER DEFAULT 0,
            theatre_share INTEGER DEFAULT 0,
            profit_amount INTEGER DEFAULT 0
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
        
        # Insert theatres (7 theatres per area, 8 areas = 56 total theatres)
        theatres_data = [
            # Satellite Area Theatres (1-7)
            (1, "PVR Satellite Plaza", "Satellite", "Ahmedabad", "Premium", 8, 350, 120, 120, "Satellite Plaza, Satellite, Ahmedabad"),
            (2, "INOX Satellite Mall", "Satellite", "Ahmedabad", "Premium", 6, 320, 90, 90, "Satellite Mall, Satellite, Ahmedabad"),
            (3, "Cinepolis Satellite Square", "Satellite", "Ahmedabad", "Multiplex", 7, 300, 105, 105, "Satellite Square, Satellite, Ahmedabad"),
            (4, "Fun Cinemas Satellite", "Satellite", "Ahmedabad", "Multiplex", 5, 280, 75, 75, "Satellite Road, Satellite, Ahmedabad"),
            (5, "Rajhans Satellite", "Satellite", "Ahmedabad", "Standard", 4, 250, 60, 60, "Satellite Circle, Satellite, Ahmedabad"),
            (6, "Carnival Satellite", "Satellite", "Ahmedabad", "Multiplex", 6, 290, 85, 85, "Satellite Cross Roads, Satellite, Ahmedabad"),
            (7, "Miraj Satellite", "Satellite", "Ahmedabad", "Standard", 5, 270, 70, 70, "Satellite Garden, Satellite, Ahmedabad"),
            
            # Vastrapur Area Theatres (8-14)
            (8, "PVR Vastrapur Lake", "Vastrapur", "Ahmedabad", "Premium", 8, 360, 120, 120, "Vastrapur Lake, Vastrapur, Ahmedabad"),
            (9, "INOX Vastrapur Mall", "Vastrapur", "Ahmedabad", "Premium", 6, 330, 90, 90, "Vastrapur Mall, Vastrapur, Ahmedabad"),
            (10, "Cinepolis Vastrapur", "Vastrapur", "Ahmedabad", "Multiplex", 7, 310, 105, 105, "Vastrapur Main Road, Vastrapur, Ahmedabad"),
            (11, "Fun Cinemas Vastrapur", "Vastrapur", "Ahmedabad", "Multiplex", 5, 290, 75, 75, "Vastrapur Circle, Vastrapur, Ahmedabad"),
            (12, "Rajhans Vastrapur", "Vastrapur", "Ahmedabad", "Standard", 4, 260, 60, 60, "Vastrapur Garden, Vastrapur, Ahmedabad"),
            (13, "Carnival Vastrapur", "Vastrapur", "Ahmedabad", "Multiplex", 6, 300, 85, 85, "Vastrapur Cross Roads, Vastrapur, Ahmedabad"),
            (14, "Miraj Vastrapur", "Vastrapur", "Ahmedabad", "Standard", 5, 280, 70, 70, "Vastrapur Square, Vastrapur, Ahmedabad"),
            
            # Paldi Area Theatres (15-21)
            (15, "PVR Paldi Central", "Paldi", "Ahmedabad", "Premium", 8, 340, 120, 120, "Paldi Central, Paldi, Ahmedabad"),
            (16, "INOX Paldi Plaza", "Paldi", "Ahmedabad", "Premium", 6, 310, 90, 90, "Paldi Plaza, Paldi, Ahmedabad"),
            (17, "Cinepolis Paldi", "Paldi", "Ahmedabad", "Multiplex", 7, 290, 105, 105, "Paldi Main Road, Paldi, Ahmedabad"),
            (18, "Fun Cinemas Paldi", "Paldi", "Ahmedabad", "Multiplex", 5, 270, 75, 75, "Paldi Circle, Paldi, Ahmedabad"),
            (19, "Rajhans Paldi", "Paldi", "Ahmedabad", "Standard", 4, 240, 60, 60, "Paldi Garden, Paldi, Ahmedabad"),
            (20, "Carnival Paldi", "Paldi", "Ahmedabad", "Multiplex", 6, 280, 85, 85, "Paldi Cross Roads, Paldi, Ahmedabad"),
            (21, "Miraj Paldi", "Paldi", "Ahmedabad", "Standard", 5, 260, 70, 70, "Paldi Square, Paldi, Ahmedabad"),
            
            # Thaltej Area Theatres (22-28)
            (22, "PVR Thaltej Mall", "Thaltej", "Ahmedabad", "Premium", 8, 370, 120, 120, "Thaltej Mall, Thaltej, Ahmedabad"),
            (23, "INOX Thaltej Plaza", "Thaltej", "Ahmedabad", "Premium", 6, 340, 90, 90, "Thaltej Plaza, Thaltej, Ahmedabad"),
            (24, "Cinepolis Thaltej", "Thaltej", "Ahmedabad", "Multiplex", 7, 320, 105, 105, "Thaltej Cross Roads, Thaltej, Ahmedabad"),
            (25, "Fun Cinemas Thaltej", "Thaltej", "Ahmedabad", "Multiplex", 5, 300, 75, 75, "Thaltej Circle, Thaltej, Ahmedabad"),
            (26, "Rajhans Thaltej", "Thaltej", "Ahmedabad", "Standard", 4, 270, 60, 60, "Thaltej Garden, Thaltej, Ahmedabad"),
            (27, "Carnival Thaltej", "Thaltej", "Ahmedabad", "Multiplex", 6, 310, 85, 85, "Thaltej Square, Thaltej, Ahmedabad"),
            (28, "Miraj Thaltej", "Thaltej", "Ahmedabad", "Standard", 5, 290, 70, 70, "Thaltej Park, Thaltej, Ahmedabad"),
            
            # Bopal Area Theatres (29-35)
            (29, "PVR Bopal Square", "Bopal", "Ahmedabad", "Premium", 8, 350, 120, 120, "Bopal Square, Bopal, Ahmedabad"),
            (30, "INOX Bopal Mall", "Bopal", "Ahmedabad", "Premium", 6, 320, 90, 90, "Bopal Mall, Bopal, Ahmedabad"),
            (31, "Cinepolis Bopal", "Bopal", "Ahmedabad", "Multiplex", 7, 300, 105, 105, "Bopal Main Road, Bopal, Ahmedabad"),
            (32, "Fun Cinemas Bopal", "Bopal", "Ahmedabad", "Multiplex", 5, 280, 75, 75, "Bopal Circle, Bopal, Ahmedabad"),
            (33, "Rajhans Bopal", "Bopal", "Ahmedabad", "Standard", 4, 250, 60, 60, "Bopal Garden, Bopal, Ahmedabad"),
            (34, "Carnival Bopal", "Bopal", "Ahmedabad", "Multiplex", 6, 290, 85, 85, "Bopal Cross Roads, Bopal, Ahmedabad"),
            (35, "Miraj Bopal", "Bopal", "Ahmedabad", "Standard", 5, 270, 70, 70, "Bopal Park, Bopal, Ahmedabad"),
            
            # Maninagar Area Theatres (36-42)
            (36, "PVR Maninagar Central", "Maninagar", "Ahmedabad", "Premium", 8, 340, 120, 120, "Maninagar Central, Maninagar, Ahmedabad"),
            (37, "INOX Maninagar Plaza", "Maninagar", "Ahmedabad", "Premium", 6, 310, 90, 90, "Maninagar Plaza, Maninagar, Ahmedabad"),
            (38, "Cinepolis Maninagar", "Maninagar", "Ahmedabad", "Multiplex", 7, 290, 105, 105, "Maninagar Main Road, Maninagar, Ahmedabad"),
            (39, "Fun Cinemas Maninagar", "Maninagar", "Ahmedabad", "Multiplex", 5, 270, 75, 75, "Maninagar Circle, Maninagar, Ahmedabad"),
            (40, "Rajhans Maninagar", "Maninagar", "Ahmedabad", "Standard", 4, 240, 60, 60, "Maninagar Garden, Maninagar, Ahmedabad"),
            (41, "Carnival Maninagar", "Maninagar", "Ahmedabad", "Multiplex", 6, 280, 85, 85, "Maninagar Cross Roads, Maninagar, Ahmedabad"),
            (42, "Miraj Maninagar", "Maninagar", "Ahmedabad", "Standard", 5, 260, 70, 70, "Maninagar Square, Maninagar, Ahmedabad"),
            
            # Naranpura Area Theatres (43-49)
            (43, "PVR Naranpura Mall", "Naranpura", "Ahmedabad", "Premium", 8, 360, 120, 120, "Naranpura Mall, Naranpura, Ahmedabad"),
            (44, "INOX Naranpura Plaza", "Naranpura", "Ahmedabad", "Premium", 6, 330, 90, 90, "Naranpura Plaza, Naranpura, Ahmedabad"),
            (45, "Cinepolis Naranpura", "Naranpura", "Ahmedabad", "Multiplex", 7, 310, 105, 105, "Naranpura Main Road, Naranpura, Ahmedabad"),
            (46, "Fun Cinemas Naranpura", "Naranpura", "Ahmedabad", "Multiplex", 5, 290, 75, 75, "Naranpura Circle, Naranpura, Ahmedabad"),
            (47, "Rajhans Naranpura", "Naranpura", "Ahmedabad", "Standard", 4, 260, 60, 60, "Naranpura Garden, Naranpura, Ahmedabad"),
            (48, "Carnival Naranpura", "Naranpura", "Ahmedabad", "Multiplex", 6, 300, 85, 85, "Naranpura Cross Roads, Naranpura, Ahmedabad"),
            (49, "Miraj Naranpura", "Naranpura", "Ahmedabad", "Standard", 5, 280, 70, 70, "Naranpura Square, Naranpura, Ahmedabad"),
            
            # Chandkheda Area Theatres (50-56)
            (50, "PVR Chandkheda Central", "Chandkheda", "Ahmedabad", "Premium", 8, 350, 120, 120, "Chandkheda Central, Chandkheda, Ahmedabad"),
            (51, "INOX Chandkheda Mall", "Chandkheda", "Ahmedabad", "Premium", 6, 320, 90, 90, "Chandkheda Mall, Chandkheda, Ahmedabad"),
            (52, "Cinepolis Chandkheda", "Chandkheda", "Ahmedabad", "Multiplex", 7, 300, 105, 105, "Chandkheda Main Road, Chandkheda, Ahmedabad"),
            (53, "Fun Cinemas Chandkheda", "Chandkheda", "Ahmedabad", "Multiplex", 5, 280, 75, 75, "Chandkheda Circle, Chandkheda, Ahmedabad"),
            (54, "Rajhans Chandkheda", "Chandkheda", "Ahmedabad", "Standard", 4, 250, 60, 60, "Chandkheda Garden, Chandkheda, Ahmedabad"),
            (55, "Carnival Chandkheda", "Chandkheda", "Ahmedabad", "Multiplex", 6, 290, 85, 85, "Chandkheda Cross Roads, Chandkheda, Ahmedabad"),
            (56, "Miraj Chandkheda", "Chandkheda", "Ahmedabad", "Standard", 5, 270, 70, 70, "Chandkheda Square, Chandkheda, Ahmedabad")
        ]
        
        for theatre in theatres_data:
            cursor.execute("""
                INSERT INTO theatres (theater_id, name, area, city, theater_type, total_screens, base_price, total_seats, available_seats, address)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, theatre)
        
        # Insert venues for comedy shows and concerts (distributed across areas)
        venues_data = [
            (1, "Comedy Club Satellite", "Satellite", "Ahmedabad", "Comedy Club", 150, 150, 500, "Satellite Road, Ahmedabad", "AC, Sound System, Bar"),
            (2, "Laugh Factory Vastrapur", "Vastrapur", "Ahmedabad", "Comedy Venue", 200, 200, 450, "Vastrapur, Ahmedabad", "AC, Stage Lighting"),
            (3, "Stand-Up Central Paldi", "Paldi", "Ahmedabad", "Comedy Hall", 120, 120, 550, "Paldi, Ahmedabad", "Premium Sound, AC"),
            (4, "Comedy Corner Thaltej", "Thaltej", "Ahmedabad", "Comedy Club", 180, 180, 480, "Thaltej, Ahmedabad", "AC, Sound System, Bar"),
            (5, "Humor Hub Bopal", "Bopal", "Ahmedabad", "Comedy Venue", 160, 160, 520, "Bopal, Ahmedabad", "AC, Stage Lighting"),
            (6, "Concert Hall Satellite", "Satellite", "Ahmedabad", "Concert Venue", 500, 500, 1000, "Satellite, Ahmedabad", "Premium Sound, Lighting, VIP Seating"),
            (7, "Music Arena Vastrapur", "Vastrapur", "Ahmedabad", "Music Venue", 300, 300, 1200, "Vastrapur, Ahmedabad", "Professional Sound, Stage"),
            (8, "Symphony Hall Paldi", "Paldi", "Ahmedabad", "Concert Venue", 400, 400, 1100, "Paldi, Ahmedabad", "Premium Sound, Lighting"),
            (9, "Melody Center Thaltej", "Thaltej", "Ahmedabad", "Music Venue", 350, 350, 1150, "Thaltej, Ahmedabad", "Professional Sound, Stage"),
            (10, "Rhythm Palace Bopal", "Bopal", "Ahmedabad", "Concert Venue", 450, 450, 1050, "Bopal, Ahmedabad", "Premium Sound, Lighting, VIP Seating")
        ]
        
        for venue in venues_data:
            cursor.execute("""
                INSERT INTO venues (venue_id, name, area, city, venue_type, capacity, available_capacity, base_price, address, facilities)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, venue)
        
        # Insert movies (4 moods, 10 movies each = 40 total movies)
        movies_data = [
            # Romantic Movies (1-10)
            (1, "Titanic", "Romantic", 195, "PG-13", "English"),
            (2, "The Notebook", "Romantic", 123, "PG-13", "English"),
            (3, "La La Land", "Romantic", 128, "PG-13", "English"),
            (4, "Dilwale Dulhania Le Jayenge", "Romantic", 189, "U", "Hindi"),
            (5, "Jab We Met", "Romantic", 138, "U", "Hindi"),
            (6, "Casablanca", "Romantic", 102, "PG", "English"),
            (7, "Yeh Jawaani Hai Deewani", "Romantic", 161, "U", "Hindi"),
            (8, "Before Sunrise", "Romantic", 101, "R", "English"),
            (9, "Zindagi Na Milegi Dobara", "Romantic", 155, "U/A", "Hindi"),
            (10, "The Princess Bride", "Romantic", 98, "PG", "English"),
            
            # Action Movies (11-20)
            (11, "Avengers: Endgame", "Action", 181, "PG-13", "English"),
            (12, "Fast & Furious 9", "Action", 143, "PG-13", "English"),
            (13, "Baahubali 2", "Action", 167, "U/A", "Hindi"),
            (14, "KGF Chapter 2", "Action", 168, "U/A", "Hindi"),
            (15, "Pathaan", "Action", 146, "U/A", "Hindi"),
            (16, "Mad Max: Fury Road", "Action", 120, "R", "English"),
            (17, "War", "Action", 156, "U/A", "Hindi"),
            (18, "John Wick", "Action", 101, "R", "English"),
            (19, "Pushpa", "Action", 179, "U/A", "Hindi"),
            (20, "Mission Impossible", "Action", 147, "PG-13", "English"),
            
            # Comedy Movies (21-30)
            (21, "Hera Pheri", "Comedy", 156, "U", "Hindi"),
            (22, "Golmaal", "Comedy", 150, "U", "Hindi"),
            (23, "Andaz Apna Apna", "Comedy", 160, "U", "Hindi"),
            (24, "Welcome", "Comedy", 159, "U", "Hindi"),
            (25, "Housefull", "Comedy", 140, "U/A", "Hindi"),
            (26, "The Hangover", "Comedy", 100, "R", "English"),
            (27, "Munna Bhai MBBS", "Comedy", 156, "U", "Hindi"),
            (28, "Superbad", "Comedy", 113, "R", "English"),
            (29, "Fukrey", "Comedy", 139, "U/A", "Hindi"),
            (30, "Dumb and Dumber", "Comedy", 107, "PG-13", "English"),
            
            # Family Movies (31-40)
            (31, "Taare Zameen Par", "Family", 165, "U", "Hindi"),
            (32, "3 Idiots", "Family", 170, "U", "Hindi"),
            (33, "Dangal", "Family", 161, "U", "Hindi"),
            (34, "Finding Nemo", "Family", 100, "G", "English"),
            (35, "The Lion King", "Family", 88, "G", "English"),
            (36, "Coco", "Family", 105, "PG", "English"),
            (37, "Queen", "Family", 146, "U/A", "Hindi"),
            (38, "Toy Story", "Family", 81, "G", "English"),
            (39, "Hindi Medium", "Family", 132, "U", "Hindi"),
            (40, "The Incredibles", "Family", 115, "PG", "English")
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
        # Get all unique show times from all movies with individual timings
        all_show_times = set()
        
        # Add all movie show times
        for movie_id in range(1, 41):  # Movies 1-40
            show_times = get_movie_show_times(movie_id)
            all_show_times.update(show_times)
        
        # Add comedy show times
        comedy_times = ["6:00 PM", "6:15 PM", "6:30 PM", "6:45 PM", "7:00 PM", "8:30 PM", "8:45 PM", "9:00 PM", "9:15 PM", "9:30 PM"]
        all_show_times.update(comedy_times)
        
        # Add concert times
        concert_times = ["6:30 PM", "6:45 PM", "7:00 PM", "7:15 PM", "8:00 PM", "9:00 PM", "9:15 PM", "9:30 PM", "9:45 PM", "10:30 PM"]
        all_show_times.update(concert_times)
        
        # Convert to sorted list
        all_show_times = sorted(list(all_show_times))
        
        # Get next 3 days for booking
        available_dates = get_next_few_days(3)
        
        for theatre_id in range(1, 57):  # 56 theatres total
            if theatre_id <= 7:  # Theatres 1-7 (120 seats)
                rows = [("A", 30, 1.5), ("B", 35, 1.2), ("C", 30, 1.0), ("D", 15, 0.8), ("E", 10, 0.7)]
            elif theatre_id <= 14:  # Theatres 8-14 (90 seats)
                rows = [("A", 25, 1.5), ("B", 30, 1.2), ("C", 20, 1.0), ("D", 15, 0.8)]
            elif theatre_id <= 21:  # Theatres 15-21 (105 seats)
                rows = [("A", 30, 1.5), ("B", 35, 1.2), ("C", 25, 1.0), ("D", 15, 0.8)]
            elif theatre_id <= 28:  # Theatres 22-28 (75 seats)
                rows = [("A", 20, 1.5), ("B", 25, 1.2), ("C", 20, 1.0), ("D", 10, 0.8)]
            elif theatre_id <= 35:  # Theatres 29-35 (60 seats)
                rows = [("A", 20, 1.5), ("B", 25, 1.2), ("C", 15, 1.0)]
            elif theatre_id <= 42:  # Theatres 36-42 (85 seats)
                rows = [("A", 25, 1.5), ("B", 30, 1.2), ("C", 20, 1.0), ("D", 10, 0.8)]
            elif theatre_id <= 49:  # Theatres 43-49 (70 seats)
                rows = [("A", 20, 1.5), ("B", 25, 1.2), ("C", 15, 1.0), ("D", 10, 0.8)]
            else:  # Theatres 50-56 (70 seats)
                rows = [("A", 20, 1.5), ("B", 25, 1.2), ("C", 15, 1.0), ("D", 10, 0.8)]
            
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
            
            col1, col2 = st.columns(2)
            with col1:
                submit_payment = st.form_submit_button("💳 Pay Now", type="primary")
            with col2:
                back_button = st.form_submit_button("← Back")
            
            if back_button:
                st.session_state.current_step = back_step
                st.rerun()
            
            if submit_payment:
                if validate_upi_id(upi_id):
                    payment_data = {'upi_id': upi_id}
                    payment_valid = True
                else:
                    st.error("❌ Please enter a valid UPI ID (e.g., yourname@paytm)")
    
    elif payment_method == "Credit/Debit Card":
        st.write("### 💳 Card Payment")
        with st.form(f"{event_type}_card_payment_form"):
            card_number = st.text_input("Card Number:", placeholder="1234 5678 9012 3456", max_chars=19)
            
            col1, col2 = st.columns(2)
            with col1:
                exp_month = st.selectbox("Expiry Month:", 
                                       options=[""] + [f"{i:02d}" for i in range(1, 13)],
                                       format_func=lambda x: "Month" if x == "" else x)
            with col2:
                current_year = datetime.now().year
                exp_year = st.selectbox("Expiry Year:", 
                                      options=[""] + [str(i) for i in range(current_year, current_year + 11)],
                                      format_func=lambda x: "Year" if x == "" else x)
            
            cvv = st.text_input("CVV:", placeholder="123", max_chars=4, type="password")
            cardholder_name = st.text_input("Cardholder Name:", placeholder="John Doe")
            
            col1, col2 = st.columns(2)
            with col1:
                submit_payment = st.form_submit_button("💳 Pay Now", type="primary")
            with col2:
                back_button = st.form_submit_button("← Back")
            
            if back_button:
                st.session_state.current_step = back_step
                st.rerun()
            
            if submit_payment:
                if validate_card_number(card_number) and validate_cvv(cvv) and validate_expiry(exp_month, exp_year) and cardholder_name:
                    payment_data = {
                        'card_number': card_number,
                        'exp_month': exp_month,
                        'exp_year': exp_year,
                        'cvv': cvv,
                        'cardholder_name': cardholder_name
                    }
                    payment_valid = True
                else:
                    st.error("❌ Please fill all card details correctly")
    
    elif payment_method == "Net Banking":
        st.write("### 🏦 Net Banking")
        with st.form(f"{event_type}_netbanking_payment_form"):
            bank_name = st.selectbox("Select Bank:", [
                "", "State Bank of India", "HDFC Bank", "ICICI Bank", "Axis Bank", 
                "Punjab National Bank", "Bank of Baroda", "Canara Bank", "Union Bank", "Kotak Mahindra Bank"
            ], format_func=lambda x: "Select Bank" if x == "" else x)
            
            account_number = st.text_input("Account Number:", placeholder="Enter your account number")
            
            col1, col2 = st.columns(2)
            with col1:
                submit_payment = st.form_submit_button("💳 Pay Now", type="primary")
            with col2:
                back_button = st.form_submit_button("← Back")
            
            if back_button:
                st.session_state.current_step = back_step
                st.rerun()
            
            if submit_payment:
                if bank_name and account_number:
                    payment_data = {
                        'bank_name': bank_name,
                        'account_number': account_number
                    }
                    payment_valid = True
                else:
                    st.error("❌ Please select bank and enter account number")
    
    return payment_valid, payment_data
def calculate_profit_breakdown(total_amount):
    """Calculate profit breakdown with GST, platform fee, theatre share, and profit"""
    # Base amount (before GST)
    base_amount = int(total_amount / 1.18)  # Remove 18% GST
    
    # GST (18%)
    gst_amount = total_amount - base_amount
    
    # Platform fee (10% of base amount)
    platform_fee = int(base_amount * 0.10)
    
    # Theatre share (60% of base amount)
    theatre_share = int(base_amount * 0.60)
    
    # Our profit (30% of base amount)
    profit_amount = base_amount - platform_fee - theatre_share
    
    return {
        'base_amount': base_amount,
        'gst_amount': gst_amount,
        'platform_fee': platform_fee,
        'theatre_share': theatre_share,
        'profit_amount': profit_amount
    }

def process_booking_payment(cursor, conn, user_email, event_type, event_id, event_name, venue_id, venue_name, 
                          show_date, show_time, booked_seats, total_amount, seat_numbers, row_details, 
                          payment_method, payment_data):
    """Process booking and payment transaction"""
    try:
        # Generate transaction ID
        transaction_id = generate_transaction_id()
        
        # Simulate payment processing (90% success rate)
        payment_success = random.random() > 0.1
        
        if payment_success:
            # Calculate profit breakdown
            profit_breakdown = calculate_profit_breakdown(total_amount)
            
            # Insert booking with profit details
            cursor.execute("""
                INSERT INTO bookings (user_email, event_type, event_id, event_name, venue_id, venue_name,
                                    show_date, show_time, booked_seats, total_amount, booking_date,
                                    seat_numbers, row_details, payment_method, payment_status, transaction_id,
                                    base_amount, gst_amount, platform_fee, theatre_share, profit_amount)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING booking_id
            """, (user_email, event_type, event_id, event_name, venue_id, venue_name,
                  show_date, show_time, booked_seats, total_amount, datetime.now(),
                  seat_numbers, row_details, payment_method, 'COMPLETED', transaction_id,
                  profit_breakdown['base_amount'], profit_breakdown['gst_amount'], 
                  profit_breakdown['platform_fee'], profit_breakdown['theatre_share'], 
                  profit_breakdown['profit_amount']))
            
            booking_id = cursor.fetchone()['booking_id']
            
            # Insert payment transaction
            payment_details = {}
            if payment_method == "UPI":
                payment_details['upi_id'] = payment_data.get('upi_id')
            elif payment_method == "Credit/Debit Card":
                payment_details['card_last_digits'] = payment_data.get('card_number', '')[-4:]
            
            cursor.execute("""
                INSERT INTO payment_transactions (transaction_id, booking_id, user_email, amount,
                                                payment_method, payment_status, transaction_date,
                                                card_last_digits, upi_id)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (transaction_id, booking_id, user_email, total_amount, payment_method,
                  'SUCCESS', datetime.now(), payment_details.get('card_last_digits'),
                  payment_details.get('upi_id')))
            
            # Update seat availability for movies
            if event_type == "movie":
                # Parse row details to update specific rows
                for row_info in row_details.split(', '):
                    if ' x ' in row_info:
                        row_name = row_info.split(' x ')[0].strip()
                        seats_booked = int(row_info.split(' x ')[1].split(' seats')[0])
                        
                        cursor.execute("""
                            UPDATE theatre_rows 
                            SET available_seats = available_seats - %s
                            WHERE theatre_id = %s AND row_name = %s AND show_date = %s AND show_time = %s
                        """, (seats_booked, venue_id, row_name, show_date, show_time))
            else:
                # Update venue capacity for comedy shows and concerts
                cursor.execute("""
                    UPDATE venues 
                    SET available_capacity = available_capacity - %s
                    WHERE venue_id = %s
                """, (booked_seats, venue_id))
            
            conn.commit()
            
            # Prepare booking details for file writing
            booking_details = {
                'booking_id': booking_id,
                'transaction_id': transaction_id,
                'event_type': event_type,
                'event_name': event_name,
                'venue_name': venue_name,
                'user_email': user_email,
                'show_date': show_date,
                'show_time': show_time,
                'booked_seats': booked_seats,
                'seat_numbers': seat_numbers,
                'total_amount': total_amount,
                'payment_method': payment_method,
                'payment_status': 'COMPLETED',
                'booking_date': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            }
            
            # Write to appropriate file
            write_ticket_to_file(event_type, booking_details)
            
            return True, booking_id, transaction_id
        else:
            # Payment failed
            cursor.execute("""
                INSERT INTO payment_transactions (transaction_id, booking_id, user_email, amount,
                                                payment_method, payment_status, transaction_date,
                                                failure_reason)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """, (transaction_id, None, user_email, total_amount, payment_method,
                  'FAILED', datetime.now(), 'Payment gateway error'))
            
            conn.commit()
            return False, None, transaction_id
    
    except Exception as e:
        conn.rollback()
        st.error(f"❌ Booking failed: {e}")
        return False, None, None
# Database Connection Functions
def database_setup():
    """Database setup and connection interface"""
    st.title("🎬 SmartShow Ultimate - Database Setup")
    
    if not st.session_state.db_ready:
        st.write("### 🔧 Database Configuration")
        
        # Password input
        password = st.text_input("Enter PostgreSQL Password:", type="password", 
                               help="Enter your PostgreSQL 'postgres' user password")
        
        if password:
            st.session_state.db_password = password
            
            col1, col2 = st.columns(2)
            
            with col1:
                if st.button("🔗 Connect to Existing DB", type="primary"):
                    with st.spinner("Connecting to database..."):
                        if connect_to_existing_database():
                            st.success("✅ Connected to database successfully!")
                            st.rerun()
                        else:
                            st.error("❌ Connection failed!")
            
            with col2:
                if st.button("🔄 Reset & Create Fresh DB", type="secondary"):
                    with st.spinner("Creating fresh database..."):
                        if reset_and_create_database():
                            st.success("✅ Fresh database created successfully!")
                            st.rerun()
                        else:
                            st.error("❌ Database creation failed!")
        
        st.info("💡 **First time?** Use 'Reset & Create Fresh DB' to set up everything automatically.")
        st.info("🔄 **Having issues?** Use 'Reset & Create Fresh DB' to fix any database problems.")
    
    else:
        st.success("✅ Database is ready!")
        if st.button("🔄 Reset Database", type="secondary"):
            if reset_and_create_database():
                st.success("✅ Database reset successfully!")
                st.rerun()

# User Authentication Functions
def register_user():
    """Enhanced user registration with better validation"""
    st.title("📝 Create New Account")
    
    with st.form("register_form"):
        name = st.text_input("Full Name:", placeholder="Enter your full name")
        email = st.text_input("Email Address:", placeholder="yourname@gmail.com")
        password = st.text_input("Password:", type="password", 
                                help="Max 10 chars, must include: uppercase, lowercase, number, and @")
        confirm_password = st.text_input("Confirm Password:", type="password")
        area = st.selectbox("Select Area:", [
            "", "Satellite", "Vastrapur", "Paldi", "Thaltej", "Bopal", 
            "Maninagar", "Naranpura", "Chandkheda"
        ], format_func=lambda x: "Select your area" if x == "" else x)
        
        submit = st.form_submit_button("Create Account", type="primary")
        
        if submit:
            # Validation
            if not all([name, email, password, confirm_password, area]):
                st.error("❌ Please fill all fields")
            elif not valid_email(email):
                st.error("❌ Email must be @gmail.com and have no spaces")
            elif not valid_password(password):
                st.error("❌ Password must be max 10 chars with uppercase, lowercase, number, and @")
            elif password != confirm_password:
                st.error("❌ Passwords don't match")
            else:
                try:
                    cursor = st.session_state.cursor
                    
                    # Check if email already exists
                    cursor.execute("SELECT email FROM users WHERE email = %s", (email,))
                    if cursor.fetchone():
                        st.error("❌ Email already registered. Please login instead.")
                    else:
                        # Generate OTP
                        otp = generate_otp()
                        otp_expiry = datetime.now() + timedelta(minutes=10)
                        
                        # Insert user
                        cursor.execute("""
                            INSERT INTO users (name, email, password, password_display, area, otp, otp_expiry)
                            VALUES (%s, %s, %s, %s, %s, %s, %s)
                        """, (name, email, password, password, area, otp, otp_expiry))
                        
                        st.session_state.conn.commit()
                        
                        st.success("✅ Account created successfully!")
                        
                        # Store OTP and email for verification
                        st.session_state.pending_email = email
                        st.session_state.generated_otp = otp
                        st.session_state.current_step = "verify_otp"
                        st.rerun()
                        
                except psycopg2.IntegrityError:
                    st.error("❌ Email already exists")
                    st.session_state.conn.rollback()
                except Exception as e:
                    st.error(f"❌ Registration failed: {e}")
                    st.session_state.conn.rollback()
    
    if st.button("← Back to Login"):
        st.session_state.current_step = "login"
        st.rerun()

def verify_otp():
    """OTP verification for new users"""
    st.title("📱 Verify OTP")
    st.write(f"Enter OTP sent to: **{st.session_state.pending_email}**")
    
    # Display the OTP in a prominent way
    if 'generated_otp' in st.session_state:
        st.info(f"🔐 **Your OTP is: {st.session_state.generated_otp}**")
        st.write("💡 In a real application, this OTP would be sent to your email/SMS")
    
    with st.form("otp_form"):
        entered_otp = st.text_input("Enter 6-digit OTP:", max_chars=6)
        submit = st.form_submit_button("Verify OTP", type="primary")
        
        if submit:
            if len(entered_otp) != 6 or not entered_otp.isdigit():
                st.error("❌ Please enter a valid 6-digit OTP")
            else:
                try:
                    cursor = st.session_state.cursor
                    cursor.execute("""
                        SELECT otp, otp_expiry FROM users 
                        WHERE email = %s
                    """, (st.session_state.pending_email,))
                    
                    result = cursor.fetchone()
                    if result:
                        stored_otp = result['otp']
                        otp_expiry = result['otp_expiry']
                        
                        if datetime.now() > otp_expiry:
                            st.error("❌ OTP expired. Please register again.")
                        elif entered_otp == stored_otp:
                            # Clear OTP and activate account
                            cursor.execute("""
                                UPDATE users SET otp = NULL, otp_expiry = NULL 
                                WHERE email = %s
                            """, (st.session_state.pending_email,))
                            st.session_state.conn.commit()
                            
                            st.success("✅ Account verified successfully!")
                            st.session_state.logged_in_user = st.session_state.pending_email
                            st.session_state.pending_email = None
                            # Clear the stored OTP
                            if 'generated_otp' in st.session_state:
                                del st.session_state.generated_otp
                            st.session_state.current_step = "main_menu"
                            st.rerun()
                        else:
                            st.error("❌ Invalid OTP")
                    else:
                        st.error("❌ User not found")
                        
                except Exception as e:
                    st.error(f"❌ Verification failed: {e}")
    
    if st.button("← Back to Registration"):
        # Clear the stored OTP when going back
        if 'generated_otp' in st.session_state:
            del st.session_state.generated_otp
        st.session_state.current_step = "register"
        st.rerun()
def login_user():
    """User login interface"""
    st.title("🔐 User Login")
    
    with st.form("login_form"):
        email = st.text_input("Email Address:", placeholder="yourname@gmail.com")
        password = st.text_input("Password:", type="password")
        submit = st.form_submit_button("Login", type="primary")
        
        if submit:
            if not email or not password:
                st.error("❌ Please enter both email and password")
            else:
                try:
                    cursor = st.session_state.cursor
                    cursor.execute("""
                        SELECT email, name, otp FROM users 
                        WHERE email = %s AND password = %s
                    """, (email, password))
                    
                    user = cursor.fetchone()
                    if user:
                        if user['otp']:  # Account not verified
                            st.error("❌ Account not verified. Please complete registration.")
                        else:
                            st.success(f"✅ Welcome back, {user['name']}!")
                            st.session_state.logged_in_user = email
                            st.session_state.current_step = "main_menu"
                            st.rerun()
                    else:
                        st.error("❌ Invalid email or password")
                        
                except Exception as e:
                    st.error(f"❌ Login failed: {e}")
    
    col1, col2 = st.columns(2)
    with col1:
        if st.button("📝 Create New Account"):
            st.session_state.current_step = "register"
            st.rerun()
    with col2:
        if st.button("👨‍💼 Admin Login"):
            st.session_state.current_step = "admin_login"
            st.rerun()

def admin_login():
    """Admin login interface"""
    st.title("👨‍💼 Admin Login")
    
    with st.form("admin_login_form"):
        username = st.text_input("Username:")
        password = st.text_input("Password:", type="password")
        submit = st.form_submit_button("Admin Login", type="primary")
        
        if submit:
            if not username or not password:
                st.error("❌ Please enter both username and password")
            else:
                try:
                    cursor = st.session_state.cursor
                    cursor.execute("""
                        SELECT admin_id, username, full_name FROM admin_users 
                        WHERE username = %s AND password = %s
                    """, (username, password))
                    
                    admin = cursor.fetchone()
                    if admin:
                        # Update last login
                        cursor.execute("""
                            UPDATE admin_users SET last_login = %s WHERE admin_id = %s
                        """, (datetime.now(), admin['admin_id']))
                        st.session_state.conn.commit()
                        
                        st.success(f"✅ Welcome, {admin['full_name']}!")
                        st.session_state.admin_logged_in = admin
                        st.session_state.current_step = "admin_dashboard"
                        st.rerun()
                    else:
                        st.error("❌ Invalid admin credentials")
                        
                except Exception as e:
                    st.error(f"❌ Admin login failed: {e}")
    
    if st.button("← Back to User Login"):
        st.session_state.current_step = "login"
        st.rerun()
    
    st.info("💡 Default admin credentials: **admin** / **Admin@123**")

# Main Menu Functions
def main_menu():
    """Main menu for logged-in users"""
    cursor = st.session_state.cursor
    
    # Get user info
    cursor.execute("SELECT name, area FROM users WHERE email = %s", (st.session_state.logged_in_user,))
    user_info = cursor.fetchone()
    
    st.title(f"🎬 Welcome, {user_info['name']}!")
    st.write(f"📍 Area: {user_info['area']}")
    
    # Main menu options
    col1, col2, col3 = st.columns(3)
    
    with col1:
        if st.button("🎬 Book Movies", use_container_width=True):
            st.session_state.current_step = "movie_booking"
            st.rerun()
    
    with col2:
        if st.button("😂 Comedy Shows", use_container_width=True):
            st.session_state.current_step = "comedy_booking"
            st.rerun()
    
    with col3:
        if st.button("🎵 Concerts", use_container_width=True):
            st.session_state.current_step = "concert_booking"
            st.rerun()
    
    st.write("---")
    
    col1, col2 = st.columns(2)
    with col1:
        if st.button("📋 My Bookings", use_container_width=True):
            st.session_state.current_step = "my_bookings"
            st.rerun()
    
    with col2:
        if st.button("🚪 Logout", use_container_width=True):
            st.session_state.logged_in_user = None
            st.session_state.current_step = "login"
            st.rerun()
# Movie Booking Functions
def movie_booking():
    """Movie booking interface with mood-based filtering"""
    st.title("🎬 Book Movie Tickets")
    
    cursor = st.session_state.cursor
    
    # Step 1: Select mood
    if 'movie_mood' not in st.session_state:
        st.session_state.movie_mood = None
    
    if not st.session_state.movie_mood:
        st.write("### 🎭 What's your mood today?")
        
        col1, col2 = st.columns(2)
        with col1:
            if st.button("💕 Romantic", use_container_width=True):
                st.session_state.movie_mood = "Romantic"
                st.rerun()
            if st.button("😂 Comedy", use_container_width=True):
                st.session_state.movie_mood = "Comedy"
                st.rerun()
        
        with col2:
            if st.button("💥 Action", use_container_width=True):
                st.session_state.movie_mood = "Action"
                st.rerun()
            if st.button("👨‍👩‍👧‍👦 Family", use_container_width=True):
                st.session_state.movie_mood = "Family"
                st.rerun()
        
        if st.button("← Back to Main Menu"):
            st.session_state.current_step = "main_menu"
            st.rerun()
        return
    
    # Step 2: Show movies based on mood
    st.write(f"### 🎬 {st.session_state.movie_mood} Movies")
    
    cursor.execute("""
        SELECT id, movie_name, duration_minutes, rating, language 
        FROM movies WHERE mood = %s
    """, (st.session_state.movie_mood,))
    movies = cursor.fetchall()
    
    for movie in movies:
        with st.expander(f"🎬 {movie['movie_name']} ({movie['language']})"):
            col1, col2 = st.columns([3, 1])
            with col1:
                st.write(f"**Duration:** {movie['duration_minutes']} minutes")
                st.write(f"**Rating:** {movie['rating']}")
                st.write(f"**Language:** {movie['language']}")
            with col2:
                if st.button(f"Book Now", key=f"book_movie_{movie['id']}"):
                    st.session_state.selected_movie = movie
                    st.session_state.current_step = "movie_theatre_selection"
                    st.rerun()
    
    col1, col2 = st.columns(2)
    with col1:
        if st.button("← Change Mood"):
            st.session_state.movie_mood = None
            st.rerun()
    with col2:
        if st.button("← Main Menu"):
            st.session_state.movie_mood = None
            st.session_state.current_step = "main_menu"
            st.rerun()

def movie_theatre_selection():
    """Theatre selection for movies - 3 specific theatres per movie from user's area"""
    st.title(f"🎬 {st.session_state.selected_movie['movie_name']}")
    st.write("### 🏢 Select Theatre")
    
    cursor = st.session_state.cursor
    
    # Get user's area
    cursor.execute("SELECT area FROM users WHERE email = %s", (st.session_state.logged_in_user,))
    user_area = cursor.fetchone()['area']
    
    st.info(f"📍 Showing selected theatres in your area: **{user_area}**")
    
    # Get movie-specific theatres (3 theatres for this movie)
    theatres = get_movie_specific_theatres(st.session_state.selected_movie['id'], user_area, cursor)
    
    if not theatres:
        st.error(f"❌ No theatres found in {user_area} area")
        if st.button("← Back to Movies"):
            st.session_state.current_step = "movie_booking"
            st.rerun()
        return
    
    st.write(f"🎯 **{len(theatres)} Premium Theatres** selected for this movie")
    
    for theatre in theatres:
        with st.expander(f"🏢 {theatre['name']} - {theatre['area']}"):
            col1, col2 = st.columns([3, 1])
            with col1:
                st.write(f"**Type:** {theatre['theater_type']}")
                st.write(f"**Base Price:** ₹{theatre['base_price']}")
                st.write(f"**Total Seats:** {theatre['total_seats']}")
                st.write(f"**Address:** {theatre['address']}")
            with col2:
                if st.button("Select", key=f"select_theatre_{theatre['theater_id']}"):
                    st.session_state.selected_theatre = theatre
                    st.session_state.current_step = "movie_date_time_selection"
                    st.rerun()
    
    if st.button("← Back to Movies"):
        st.session_state.current_step = "movie_booking"
        st.rerun()

def ensure_seat_data_exists(cursor, conn, theatre_id, show_date, show_time):
    """Ensure seat data exists for a specific theatre, date, and time"""
    try:
        # Check if seat data already exists
        cursor.execute("""
            SELECT COUNT(*) as count FROM theatre_rows 
            WHERE theatre_id = %s AND show_date = %s AND show_time = %s
        """, (theatre_id, show_date, show_time))
        
        existing_count = cursor.fetchone()['count']
        
        if existing_count == 0:
            # Create seat data for this specific show
            if theatre_id <= 7:  # Theatres 1-7 (120 seats)
                seat_rows = [("A", 30, 1.5), ("B", 35, 1.2), ("C", 30, 1.0), ("D", 15, 0.8), ("E", 10, 0.7)]
            elif theatre_id <= 14:  # Theatres 8-14 (90 seats)
                seat_rows = [("A", 25, 1.5), ("B", 30, 1.2), ("C", 20, 1.0), ("D", 15, 0.8)]
            elif theatre_id <= 21:  # Theatres 15-21 (105 seats)
                seat_rows = [("A", 30, 1.5), ("B", 35, 1.2), ("C", 25, 1.0), ("D", 15, 0.8)]
            elif theatre_id <= 28:  # Theatres 22-28 (75 seats)
                seat_rows = [("A", 20, 1.5), ("B", 25, 1.2), ("C", 20, 1.0), ("D", 10, 0.8)]
            elif theatre_id <= 35:  # Theatres 29-35 (60 seats)
                seat_rows = [("A", 20, 1.5), ("B", 25, 1.2), ("C", 15, 1.0)]
            elif theatre_id <= 42:  # Theatres 36-42 (85 seats)
                seat_rows = [("A", 25, 1.5), ("B", 30, 1.2), ("C", 20, 1.0), ("D", 10, 0.8)]
            elif theatre_id <= 49:  # Theatres 43-49 (70 seats)
                seat_rows = [("A", 20, 1.5), ("B", 25, 1.2), ("C", 15, 1.0), ("D", 10, 0.8)]
            else:  # Theatres 50-56 (70 seats)
                seat_rows = [("A", 20, 1.5), ("B", 25, 1.2), ("C", 15, 1.0), ("D", 10, 0.8)]
            
            # Insert seat data
            for row_name, seats_in_row, price_mult in seat_rows:
                cursor.execute("""
                    INSERT INTO theatre_rows 
                    (theatre_id, row_name, show_date, show_time, total_seats, available_seats, price_multiplier)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                """, (theatre_id, row_name, show_date, show_time, seats_in_row, seats_in_row, price_mult))
            
            conn.commit()
            return True
        
        return False
        
    except Exception as e:
        conn.rollback()
        return False

def movie_date_time_selection():
    """Date and time selection for movies"""
    st.title(f"🎬 {st.session_state.selected_movie['movie_name']}")
    st.write(f"🏢 {st.session_state.selected_theatre['name']}")
    st.write("### 📅 Select Date & Time")
    
    # Get available dates
    available_dates = get_next_few_days(3)
    
    # Date selection
    selected_date = st.selectbox(
        "Select Date:",
        options=[None] + available_dates,
        format_func=lambda x: "Choose date" if x is None else x['display']
    )
    
    if selected_date:
        # Get show times for this movie
        movie_show_times = get_movie_show_times(st.session_state.selected_movie['id'])
        
        st.write("### ⏰ Available Show Times")
        
        cols = st.columns(len(movie_show_times))
        for i, show_time in enumerate(movie_show_times):
            with cols[i]:
                if st.button(show_time, key=f"time_{show_time}", use_container_width=True):
                    # Ensure seat data exists for this theatre, date, and time
                    theatre_id = st.session_state.selected_theatre['theater_id']
                    show_date = selected_date['date']
                    
                    # Create seat data if it doesn't exist
                    ensure_seat_data_exists(st.session_state.cursor, st.session_state.conn, 
                                          theatre_id, show_date, show_time)
                    
                    st.session_state.selected_date = selected_date['date']
                    st.session_state.selected_time = show_time
                    st.session_state.current_step = "movie_seat_selection"
                    st.rerun()
    
    if st.button("← Back to Theatres"):
        st.session_state.current_step = "movie_theatre_selection"
        st.rerun()
def movie_seat_selection():
    """Seat selection for movies with row-wise pricing"""
    st.title(f"🎬 {st.session_state.selected_movie['movie_name']}")
    st.write(f"🏢 {st.session_state.selected_theatre['name']}")
    st.write(f"📅 {st.session_state.selected_date} at {st.session_state.selected_time}")
    st.write("### 💺 Select Seats")
    
    cursor = st.session_state.cursor
    
    # Get available seats for this theatre, date, and time
    cursor.execute("""
        SELECT row_name, total_seats, available_seats, price_multiplier
        FROM theatre_rows 
        WHERE theatre_id = %s AND show_date = %s AND show_time = %s
        ORDER BY row_name
    """, (st.session_state.selected_theatre['theater_id'], st.session_state.selected_date, st.session_state.selected_time))
    
    rows = cursor.fetchall()
    
    if not rows:
        st.warning("⚠️ Creating seat data for this show time...")
        
        # Create seat data for this specific theatre, date, and time
        theatre_id = st.session_state.selected_theatre['theater_id']
        show_date = st.session_state.selected_date
        show_time = st.session_state.selected_time
        
        # Determine seat configuration based on theatre ID
        if theatre_id <= 7:  # Theatres 1-7 (120 seats)
            seat_rows = [("A", 30, 1.5), ("B", 35, 1.2), ("C", 30, 1.0), ("D", 15, 0.8), ("E", 10, 0.7)]
        elif theatre_id <= 14:  # Theatres 8-14 (90 seats)
            seat_rows = [("A", 25, 1.5), ("B", 30, 1.2), ("C", 20, 1.0), ("D", 15, 0.8)]
        elif theatre_id <= 21:  # Theatres 15-21 (105 seats)
            seat_rows = [("A", 30, 1.5), ("B", 35, 1.2), ("C", 25, 1.0), ("D", 15, 0.8)]
        elif theatre_id <= 28:  # Theatres 22-28 (75 seats)
            seat_rows = [("A", 20, 1.5), ("B", 25, 1.2), ("C", 20, 1.0), ("D", 10, 0.8)]
        elif theatre_id <= 35:  # Theatres 29-35 (60 seats)
            seat_rows = [("A", 20, 1.5), ("B", 25, 1.2), ("C", 15, 1.0)]
        elif theatre_id <= 42:  # Theatres 36-42 (85 seats)
            seat_rows = [("A", 25, 1.5), ("B", 30, 1.2), ("C", 20, 1.0), ("D", 10, 0.8)]
        elif theatre_id <= 49:  # Theatres 43-49 (70 seats)
            seat_rows = [("A", 20, 1.5), ("B", 25, 1.2), ("C", 15, 1.0), ("D", 10, 0.8)]
        else:  # Theatres 50-56 (70 seats)
            seat_rows = [("A", 20, 1.5), ("B", 25, 1.2), ("C", 15, 1.0), ("D", 10, 0.8)]
        
        # Insert seat data for this specific show
        try:
            for row_name, seats_in_row, price_mult in seat_rows:
                cursor.execute("""
                    INSERT INTO theatre_rows 
                    (theatre_id, row_name, show_date, show_time, total_seats, available_seats, price_multiplier)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                    ON CONFLICT (theatre_id, row_name, show_date, show_time) DO NOTHING
                """, (theatre_id, row_name, show_date, show_time, seats_in_row, seats_in_row, price_mult))
            
            st.session_state.conn.commit()
            st.success("✅ Seat data created! Please refresh to see seats.")
            
            # Refresh the page to show the newly created seats
            if st.button("🔄 Refresh Seats"):
                st.rerun()
                
        except Exception as e:
            st.error(f"❌ Error creating seat data: {e}")
            st.session_state.conn.rollback()
        
        if st.button("← Back to Date/Time"):
            st.session_state.current_step = "movie_date_time_selection"
            st.rerun()
        return
    
    # Initialize seat selection
    if 'selected_seats' not in st.session_state:
        st.session_state.selected_seats = {}
    
    base_price = st.session_state.selected_theatre['base_price']
    total_amount = 0
    total_seats = 0
    
    st.write("#### 💰 Seat Pricing & Selection")
    
    for row in rows:
        row_name = row['row_name']
        available = row['available_seats']
        total = row['total_seats']
        price_mult = float(row['price_multiplier'])
        row_price = int(base_price * price_mult)
        
        col1, col2, col3 = st.columns([2, 2, 2])
        
        with col1:
            st.write(f"**Row {row_name}** - ₹{row_price} each")
            st.write(f"Available: {available}/{total}")
        
        with col2:
            if available > 0:
                max_seats = min(available, 10)  # Max 10 seats per row
                selected = st.number_input(
                    f"Seats in Row {row_name}:",
                    min_value=0,
                    max_value=max_seats,
                    value=st.session_state.selected_seats.get(row_name, 0),
                    key=f"seats_row_{row_name}"
                )
                st.session_state.selected_seats[row_name] = selected
            else:
                st.write("❌ **SOLD OUT**")
                st.session_state.selected_seats[row_name] = 0
        
        with col3:
            seats_in_row = st.session_state.selected_seats.get(row_name, 0)
            if seats_in_row > 0:
                row_total = seats_in_row * row_price
                st.write(f"**₹{row_total}**")
                total_amount += row_total
                total_seats += seats_in_row
    
    st.write("---")
    
    if total_seats > 0:
        col1, col2 = st.columns(2)
        with col1:
            st.write(f"### 🎫 Total Tickets: {total_seats}")
        with col2:
            st.write(f"### 💰 Total Amount: ₹{total_amount}")
        
        if st.button("🛒 Proceed to Payment", type="primary"):
            # Prepare booking details
            seat_numbers = []
            row_details = []
            seat_counter = 1
            
            for row_name, seats_count in st.session_state.selected_seats.items():
                if seats_count > 0:
                    row_seats = [f"{row_name}{i}" for i in range(seat_counter, seat_counter + seats_count)]
                    seat_numbers.extend(row_seats)
                    row_details.append(f"Row {row_name} x {seats_count} seats")
                    seat_counter += seats_count
            
            st.session_state.booking_details = {
                'event_type': 'movie',
                'event_id': st.session_state.selected_movie['id'],
                'event_name': st.session_state.selected_movie['movie_name'],
                'venue_id': st.session_state.selected_theatre['theater_id'],
                'venue_name': st.session_state.selected_theatre['name'],
                'show_date': st.session_state.selected_date,
                'show_time': st.session_state.selected_time,
                'booked_seats': total_seats,
                'total_amount': total_amount,
                'seat_numbers': ', '.join(seat_numbers),
                'row_details': ', '.join(row_details)
            }
            
            st.session_state.current_step = "payment_method_selection"
            st.rerun()
    else:
        st.info("👆 Select seats to proceed")
    
    if st.button("← Back to Date/Time"):
        st.session_state.selected_seats = {}
        st.session_state.current_step = "movie_date_time_selection"
        st.rerun()

# Comedy Show Booking Functions
def comedy_booking():
    """Comedy show booking interface"""
    st.title("😂 Book Comedy Show Tickets")
    
    cursor = st.session_state.cursor
    
    # Get comedy shows
    cursor.execute("""
        SELECT show_id, comedian_name, show_title, show_type, duration_minutes, 
               language, age_rating, description, ticket_price
        FROM comedy_shows ORDER BY comedian_name
    """)
    shows = cursor.fetchall()
    
    for show in shows:
        with st.expander(f"😂 {show['comedian_name']} - {show['show_title']}"):
            col1, col2 = st.columns([3, 1])
            with col1:
                st.write(f"**Type:** {show['show_type']}")
                st.write(f"**Duration:** {show['duration_minutes']} minutes")
                st.write(f"**Language:** {show['language']}")
                st.write(f"**Age Rating:** {show['age_rating']}")
                st.write(f"**Description:** {show['description']}")
                st.write(f"**Price:** ₹{show['ticket_price']} per ticket")
            with col2:
                if st.button("Book Now", key=f"book_comedy_{show['show_id']}"):
                    st.session_state.selected_comedy = show
                    st.session_state.current_step = "comedy_venue_selection"
                    st.rerun()
    
    if st.button("← Back to Main Menu"):
        st.session_state.current_step = "main_menu"
        st.rerun()

def comedy_venue_selection():
    """Venue selection for comedy shows - filtered by user's area"""
    st.title(f"😂 {st.session_state.selected_comedy['show_title']}")
    st.write(f"🎭 {st.session_state.selected_comedy['comedian_name']}")
    st.write("### 🏢 Select Venue")
    
    cursor = st.session_state.cursor
    
    # Get user's area
    cursor.execute("SELECT area FROM users WHERE email = %s", (st.session_state.logged_in_user,))
    user_area = cursor.fetchone()['area']
    
    st.info(f"📍 Showing venues in your area: **{user_area}**")
    
    # Get venues suitable for comedy shows in user's area
    cursor.execute("""
        SELECT venue_id, name, area, venue_type, capacity, available_capacity, base_price, address, facilities
        FROM venues 
        WHERE venue_type LIKE '%Comedy%' AND area = %s
        ORDER BY name
    """, (user_area,))
    venues = cursor.fetchall()
    
    if not venues:
        st.warning(f"⚠️ No comedy venues found in {user_area} area. Showing all available venues:")
        # Fallback to show all comedy venues if none in user's area
        cursor.execute("""
            SELECT venue_id, name, area, venue_type, capacity, available_capacity, base_price, address, facilities
            FROM venues WHERE venue_type LIKE '%Comedy%' ORDER BY name
        """)
        venues = cursor.fetchall()
    
    for venue in venues:
        with st.expander(f"🏢 {venue['name']} - {venue['area']}"):
            col1, col2 = st.columns([3, 1])
            with col1:
                st.write(f"**Type:** {venue['venue_type']}")
                st.write(f"**Capacity:** {venue['capacity']} seats")
                st.write(f"**Available:** {venue['available_capacity']} seats")
                st.write(f"**Address:** {venue['address']}")
                st.write(f"**Facilities:** {venue['facilities']}")
            with col2:
                if venue['available_capacity'] > 0:
                    if st.button("Select", key=f"select_comedy_venue_{venue['venue_id']}"):
                        st.session_state.selected_comedy_venue = venue
                        st.session_state.current_step = "comedy_date_time_selection"
                        st.rerun()
                else:
                    st.write("❌ **SOLD OUT**")
    
    if st.button("← Back to Comedy Shows"):
        st.session_state.current_step = "comedy_booking"
        st.rerun()

def comedy_date_time_selection():
    """Date and time selection for comedy shows"""
    st.title(f"😂 {st.session_state.selected_comedy['show_title']}")
    st.write(f"🏢 {st.session_state.selected_comedy_venue['name']}")
    st.write("### 📅 Select Date & Time")
    
    # Get available dates
    available_dates = get_next_few_days(3)
    
    # Date selection
    selected_date = st.selectbox(
        "Select Date:",
        options=[None] + available_dates,
        format_func=lambda x: "Choose date" if x is None else x['display']
    )
    
    if selected_date:
        # Different show times for different comedy shows
        comedy_show_times = {
            1: ["6:00 PM", "8:30 PM"],  # Kapil Sharma
            2: ["6:15 PM", "8:45 PM"],  # Zakir Khan
            3: ["6:30 PM", "9:00 PM"],  # Biswa
            4: ["6:45 PM", "9:15 PM"],  # Kenny Sebastian
            5: ["7:00 PM", "9:30 PM"]   # Abhishek Upmanyu
        }
        
        show_times = comedy_show_times.get(st.session_state.selected_comedy['show_id'], ["6:00 PM", "8:30 PM"])
        
        st.write("### ⏰ Available Show Times")
        
        cols = st.columns(len(show_times))
        for i, show_time in enumerate(show_times):
            with cols[i]:
                if st.button(show_time, key=f"comedy_time_{show_time}", use_container_width=True):
                    st.session_state.selected_comedy_date = selected_date['date']
                    st.session_state.selected_comedy_time = show_time
                    st.session_state.current_step = "comedy_ticket_selection"
                    st.rerun()
    
    if st.button("← Back to Venues"):
        st.session_state.current_step = "comedy_venue_selection"
        st.rerun()
def comedy_ticket_selection():
    """Ticket selection for comedy shows"""
    st.title(f"😂 {st.session_state.selected_comedy['show_title']}")
    st.write(f"🏢 {st.session_state.selected_comedy_venue['name']}")
    st.write(f"📅 {st.session_state.selected_comedy_date} at {st.session_state.selected_comedy_time}")
    st.write("### 🎫 Select Tickets")
    
    venue = st.session_state.selected_comedy_venue
    show = st.session_state.selected_comedy
    
    # Show pricing
    ticket_price = show['ticket_price']
    available_seats = venue['available_capacity']
    
    col1, col2 = st.columns(2)
    with col1:
        st.write(f"**Ticket Price:** ₹{ticket_price} each")
        st.write(f"**Available Seats:** {available_seats}")
    
    with col2:
        num_tickets = st.number_input(
            "Number of Tickets:",
            min_value=1,
            max_value=min(available_seats, 10),
            value=1
        )
    
    total_amount = num_tickets * ticket_price
    
    st.write("---")
    col1, col2 = st.columns(2)
    with col1:
        st.write(f"### 🎫 Total Tickets: {num_tickets}")
    with col2:
        st.write(f"### 💰 Total Amount: ₹{total_amount}")
    
    if st.button("🛒 Proceed to Payment", type="primary"):
        # Prepare booking details
        seat_numbers = [f"S{i+1}" for i in range(num_tickets)]
        
        st.session_state.booking_details = {
            'event_type': 'comedy',
            'event_id': show['show_id'],
            'event_name': show['show_title'],
            'venue_id': venue['venue_id'],
            'venue_name': venue['name'],
            'show_date': st.session_state.selected_comedy_date,
            'show_time': st.session_state.selected_comedy_time,
            'booked_seats': num_tickets,
            'total_amount': total_amount,
            'seat_numbers': ', '.join(seat_numbers),
            'row_details': f"General Seating x {num_tickets} tickets"
        }
        
        st.session_state.current_step = "payment_method_selection"
        st.rerun()
    
    if st.button("← Back to Date/Time"):
        st.session_state.current_step = "comedy_date_time_selection"
        st.rerun()

# Concert Booking Functions
def concert_booking():
    """Concert booking interface"""
    st.title("🎵 Book Concert Tickets")
    
    cursor = st.session_state.cursor
    
    # Get concerts
    cursor.execute("""
        SELECT concert_id, artist_name, concert_title, genre, duration_minutes, 
               language, ticket_price, description, special_guests
        FROM concerts ORDER BY artist_name
    """)
    concerts = cursor.fetchall()
    
    for concert in concerts:
        with st.expander(f"🎵 {concert['artist_name']} - {concert['concert_title']}"):
            col1, col2 = st.columns([3, 1])
            with col1:
                st.write(f"**Genre:** {concert['genre']}")
                st.write(f"**Duration:** {concert['duration_minutes']} minutes")
                st.write(f"**Language:** {concert['language']}")
                st.write(f"**Description:** {concert['description']}")
                if concert['special_guests']:
                    st.write(f"**Special Guests:** {concert['special_guests']}")
                st.write(f"**Price:** ₹{concert['ticket_price']} per ticket")
            with col2:
                if st.button("Book Now", key=f"book_concert_{concert['concert_id']}"):
                    st.session_state.selected_concert = concert
                    st.session_state.current_step = "concert_venue_selection"
                    st.rerun()
    
    if st.button("← Back to Main Menu"):
        st.session_state.current_step = "main_menu"
        st.rerun()

def concert_venue_selection():
    """Venue selection for concerts - filtered by user's area"""
    st.title(f"🎵 {st.session_state.selected_concert['concert_title']}")
    st.write(f"🎤 {st.session_state.selected_concert['artist_name']}")
    st.write("### 🏢 Select Venue")
    
    cursor = st.session_state.cursor
    
    # Get user's area
    cursor.execute("SELECT area FROM users WHERE email = %s", (st.session_state.logged_in_user,))
    user_area = cursor.fetchone()['area']
    
    st.info(f"📍 Showing venues in your area: **{user_area}**")
    
    # Get venues suitable for concerts in user's area
    cursor.execute("""
        SELECT venue_id, name, area, venue_type, capacity, available_capacity, base_price, address, facilities
        FROM venues 
        WHERE (venue_type LIKE '%Concert%' OR venue_type LIKE '%Music%') AND area = %s
        ORDER BY name
    """, (user_area,))
    venues = cursor.fetchall()
    
    if not venues:
        st.warning(f"⚠️ No concert venues found in {user_area} area. Showing all available venues:")
        # Fallback to show all concert venues if none in user's area
        cursor.execute("""
            SELECT venue_id, name, area, venue_type, capacity, available_capacity, base_price, address, facilities
            FROM venues WHERE venue_type LIKE '%Concert%' OR venue_type LIKE '%Music%' ORDER BY name
        """)
        venues = cursor.fetchall()
    
    for venue in venues:
        with st.expander(f"🏢 {venue['name']} - {venue['area']}"):
            col1, col2 = st.columns([3, 1])
            with col1:
                st.write(f"**Type:** {venue['venue_type']}")
                st.write(f"**Capacity:** {venue['capacity']} seats")
                st.write(f"**Available:** {venue['available_capacity']} seats")
                st.write(f"**Address:** {venue['address']}")
                st.write(f"**Facilities:** {venue['facilities']}")
            with col2:
                if venue['available_capacity'] > 0:
                    if st.button("Select", key=f"select_concert_venue_{venue['venue_id']}"):
                        st.session_state.selected_concert_venue = venue
                        st.session_state.current_step = "concert_date_time_selection"
                        st.rerun()
                else:
                    st.write("❌ **SOLD OUT**")
    
    if st.button("← Back to Concerts"):
        st.session_state.current_step = "concert_booking"
        st.rerun()

def concert_date_time_selection():
    """Date and time selection for concerts"""
    st.title(f"🎵 {st.session_state.selected_concert['concert_title']}")
    st.write(f"🏢 {st.session_state.selected_concert_venue['name']}")
    st.write("### 📅 Select Date & Time")
    
    # Get available dates
    available_dates = get_next_few_days(3)
    
    # Date selection
    selected_date = st.selectbox(
        "Select Date:",
        options=[None] + available_dates,
        format_func=lambda x: "Choose date" if x is None else x['display']
    )
    
    if selected_date:
        # Different show times for different concerts
        concert_show_times = {
            1: ["7:00 PM", "9:30 PM"],   # Arijit Singh
            2: ["6:30 PM", "9:00 PM"],   # A.R. Rahman
            3: ["8:00 PM", "10:30 PM"],  # Nucleya
            4: ["6:45 PM", "9:15 PM"],   # Rahat Fateh Ali Khan
            5: ["7:15 PM", "9:45 PM"]    # Sunidhi Chauhan
        }
        
        show_times = concert_show_times.get(st.session_state.selected_concert['concert_id'], ["7:00 PM", "9:30 PM"])
        
        st.write("### ⏰ Available Show Times")
        
        cols = st.columns(len(show_times))
        for i, show_time in enumerate(show_times):
            with cols[i]:
                if st.button(show_time, key=f"concert_time_{show_time}", use_container_width=True):
                    st.session_state.selected_concert_date = selected_date['date']
                    st.session_state.selected_concert_time = show_time
                    st.session_state.current_step = "concert_ticket_selection"
                    st.rerun()
    
    if st.button("← Back to Venues"):
        st.session_state.current_step = "concert_venue_selection"
        st.rerun()

def concert_ticket_selection():
    """Ticket selection for concerts"""
    st.title(f"🎵 {st.session_state.selected_concert['concert_title']}")
    st.write(f"🏢 {st.session_state.selected_concert_venue['name']}")
    st.write(f"📅 {st.session_state.selected_concert_date} at {st.session_state.selected_concert_time}")
    st.write("### 🎫 Select Tickets")
    
    venue = st.session_state.selected_concert_venue
    concert = st.session_state.selected_concert
    
    # Show pricing
    ticket_price = concert['ticket_price']
    available_seats = venue['available_capacity']
    
    col1, col2 = st.columns(2)
    with col1:
        st.write(f"**Ticket Price:** ₹{ticket_price} each")
        st.write(f"**Available Seats:** {available_seats}")
    
    with col2:
        num_tickets = st.number_input(
            "Number of Tickets:",
            min_value=1,
            max_value=min(available_seats, 10),
            value=1
        )
    
    total_amount = num_tickets * ticket_price
    
    st.write("---")
    col1, col2 = st.columns(2)
    with col1:
        st.write(f"### 🎫 Total Tickets: {num_tickets}")
    with col2:
        st.write(f"### 💰 Total Amount: ₹{total_amount}")
    
    if st.button("🛒 Proceed to Payment", type="primary"):
        # Prepare booking details
        seat_numbers = [f"C{i+1}" for i in range(num_tickets)]
        
        st.session_state.booking_details = {
            'event_type': 'concert',
            'event_id': concert['concert_id'],
            'event_name': concert['concert_title'],
            'venue_id': venue['venue_id'],
            'venue_name': venue['name'],
            'show_date': st.session_state.selected_concert_date,
            'show_time': st.session_state.selected_concert_time,
            'booked_seats': num_tickets,
            'total_amount': total_amount,
            'seat_numbers': ', '.join(seat_numbers),
            'row_details': f"General Seating x {num_tickets} tickets"
        }
        
        st.session_state.current_step = "payment_method_selection"
        st.rerun()
    
    if st.button("← Back to Date/Time"):
        st.session_state.current_step = "concert_date_time_selection"
        st.rerun()
# Payment Functions
def payment_method_selection():
    """Payment method selection"""
    booking = st.session_state.booking_details
    
    st.title("💳 Payment")
    st.write(f"### 🎫 {booking['event_name']}")
    st.write(f"🏢 {booking['venue_name']}")
    st.write(f"📅 {booking['show_date']} at {booking['show_time']}")
    st.write(f"🎫 {booking['booked_seats']} tickets")
    st.write(f"💰 **Total Amount: ₹{booking['total_amount']}**")
    
    st.write("---")
    st.write("### 💳 Select Payment Method")
    
    col1, col2, col3 = st.columns(3)
    
    with col1:
        if st.button("📱 UPI", use_container_width=True):
            st.session_state.selected_payment_method = "UPI"
            st.session_state.current_step = "payment_processing"
            st.rerun()
    
    with col2:
        if st.button("💳 Card", use_container_width=True):
            st.session_state.selected_payment_method = "Credit/Debit Card"
            st.session_state.current_step = "payment_processing"
            st.rerun()
    
    with col3:
        if st.button("🏦 Net Banking", use_container_width=True):
            st.session_state.selected_payment_method = "Net Banking"
            st.session_state.current_step = "payment_processing"
            st.rerun()
    
    # Determine back step based on event type
    if booking['event_type'] == 'movie':
        back_step = "movie_seat_selection"
    elif booking['event_type'] == 'comedy':
        back_step = "comedy_ticket_selection"
    else:
        back_step = "concert_ticket_selection"
    
    if st.button("← Back to Ticket Selection"):
        st.session_state.current_step = back_step
        st.rerun()

def payment_processing():
    """Payment processing interface"""
    booking = st.session_state.booking_details
    payment_method = st.session_state.selected_payment_method
    
    st.title(f"💳 {payment_method} Payment")
    st.write(f"### 🎫 {booking['event_name']}")
    st.write(f"💰 **Amount to Pay: ₹{booking['total_amount']}**")
    
    # Determine back step based on event type
    if booking['event_type'] == 'movie':
        back_step = "movie_seat_selection"
    elif booking['event_type'] == 'comedy':
        back_step = "comedy_ticket_selection"
    else:
        back_step = "concert_ticket_selection"
    
    # Show payment form
    payment_valid, payment_data = show_complete_payment_form(
        payment_method, booking['total_amount'], booking['event_type'], back_step
    )
    
    if payment_valid:
        # Process payment
        with st.spinner("Processing payment..."):
            time.sleep(2)  # Simulate payment processing
            
            success, booking_id, transaction_id = process_booking_payment(
                st.session_state.cursor, st.session_state.conn,
                st.session_state.logged_in_user,
                booking['event_type'], booking['event_id'], booking['event_name'],
                booking['venue_id'], booking['venue_name'],
                booking['show_date'], booking['show_time'],
                booking['booked_seats'], booking['total_amount'],
                booking['seat_numbers'], booking['row_details'],
                payment_method, payment_data
            )
            
            if success:
                st.success("✅ Payment Successful!")
                st.balloons()
                
                # Show booking confirmation
                st.write("### 🎉 Booking Confirmed!")
                st.write(f"**Booking ID:** {booking_id}")
                st.write(f"**Transaction ID:** {transaction_id}")
                st.write(f"**Event:** {booking['event_name']}")
                st.write(f"**Venue:** {booking['venue_name']}")
                st.write(f"**Date & Time:** {booking['show_date']} at {booking['show_time']}")
                st.write(f"**Tickets:** {booking['booked_seats']}")
                st.write(f"**Seats:** {booking['seat_numbers']}")
                st.write(f"**Total Paid:** ₹{booking['total_amount']}")
                
                st.info("🎫 Your ticket details have been saved to the appropriate file!")
                
                if st.button("🏠 Back to Main Menu", type="primary"):
                    # Clear booking session data
                    for key in ['booking_details', 'selected_payment_method', 'selected_seats',
                               'selected_movie', 'selected_theatre', 'selected_date', 'selected_time',
                               'selected_comedy', 'selected_comedy_venue', 'selected_comedy_date', 'selected_comedy_time',
                               'selected_concert', 'selected_concert_venue', 'selected_concert_date', 'selected_concert_time',
                               'movie_mood']:
                        if key in st.session_state:
                            del st.session_state[key]
                    
                    st.session_state.current_step = "main_menu"
                    st.rerun()
            else:
                st.error("❌ Payment Failed!")
                st.write("Please try again with a different payment method.")
                
                if st.button("🔄 Try Again"):
                    st.session_state.current_step = "payment_method_selection"
                    st.rerun()

# My Bookings Function
def my_bookings():
    """Show user's booking history"""
    st.title("📋 My Bookings")
    
    cursor = st.session_state.cursor
    
    # Get user's bookings with profit details
    cursor.execute("""
        SELECT booking_id, event_type, event_name, venue_name, show_date, show_time,
               booked_seats, total_amount, booking_date, payment_status, transaction_id,
               base_amount, gst_amount, platform_fee, theatre_share, profit_amount
        FROM bookings 
        WHERE user_email = %s 
        ORDER BY booking_date DESC
    """, (st.session_state.logged_in_user,))
    
    bookings = cursor.fetchall()
    
    if not bookings:
        st.info("📝 No bookings found. Book your first show!")
    else:
        for booking in bookings:
            with st.expander(f"🎫 {booking['event_name']} - {booking['show_date']}"):
                col1, col2 = st.columns(2)
                
                with col1:
                    st.write(f"**Booking ID:** {booking['booking_id']}")
                    st.write(f"**Event Type:** {booking['event_type'].title()}")
                    st.write(f"**Venue:** {booking['venue_name']}")
                    st.write(f"**Date & Time:** {booking['show_date']} at {booking['show_time']}")
                
                with col2:
                    st.write(f"**Tickets:** {booking['booked_seats']}")
                    st.write(f"**Total Amount:** ₹{booking['total_amount']}")
                    st.write(f"**Status:** {booking['payment_status']}")
                    st.write(f"**Booked On:** {booking['booking_date'].strftime('%Y-%m-%d %H:%M')}")
                
                # Show price breakdown if available
                if booking.get('base_amount'):
                    st.write("---")
                    st.write("**💰 Price Breakdown:**")
                    col1, col2, col3 = st.columns(3)
                    
                    with col1:
                        st.write(f"Base Amount: ₹{booking['base_amount']}")
                        st.write(f"GST (18%): ₹{booking['gst_amount']}")
                    
                    with col2:
                        st.write(f"Platform Fee: ₹{booking['platform_fee']}")
                        st.write(f"Theatre Share: ₹{booking['theatre_share']}")
                    
                    with col3:
                        st.write(f"**Total Paid: ₹{booking['total_amount']}**")
                        st.write(f"Our Profit: ₹{booking['profit_amount']}")
    
    if st.button("← Back to Main Menu"):
        st.session_state.current_step = "main_menu"
        st.rerun()
# Admin Dashboard Functions
def admin_dashboard():
    """Admin dashboard with analytics and management"""
    admin = st.session_state.admin_logged_in
    st.title(f"👨‍💼 Admin Dashboard - {admin['full_name']}")
    
    cursor = st.session_state.cursor
    
    # Admin menu
    tab1, tab2, tab3, tab4, tab5 = st.tabs(["📊 Analytics", "💰 Profit Analysis", "🎫 Bookings", "👥 Users", "⚙️ Settings"])
    
    with tab1:
        show_admin_analytics(cursor)
    
    with tab2:
        show_profit_analytics(cursor)
    
    with tab3:
        show_admin_bookings(cursor)
    
    with tab4:
        show_admin_users(cursor)
    
    with tab5:
        show_admin_settings(cursor)
    
    # Logout button
    if st.button("🚪 Admin Logout"):
        st.session_state.admin_logged_in = None
        st.session_state.current_step = "login"
        st.rerun()

def show_profit_analytics(cursor):
    """Show detailed profit analytics"""
    st.write("### 💰 Profit & Revenue Analysis")
    
    # Get profit statistics
    cursor.execute("""
        SELECT 
            SUM(total_amount) as total_revenue,
            SUM(base_amount) as total_base_amount,
            SUM(gst_amount) as total_gst,
            SUM(platform_fee) as total_platform_fee,
            SUM(theatre_share) as total_theatre_share,
            SUM(profit_amount) as total_profit,
            COUNT(*) as total_bookings
        FROM bookings 
        WHERE payment_status = 'COMPLETED'
    """)
    profit_stats = cursor.fetchone()
    
    if profit_stats and profit_stats['total_revenue']:
        # Main metrics
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            st.metric("Total Revenue", f"₹{profit_stats['total_revenue']:,}")
            st.metric("Base Amount", f"₹{profit_stats['total_base_amount']:,}")
        
        with col2:
            st.metric("Our Profit", f"₹{profit_stats['total_profit']:,}")
            profit_percentage = (profit_stats['total_profit'] / profit_stats['total_revenue']) * 100
            st.metric("Profit %", f"{profit_percentage:.1f}%")
        
        with col3:
            st.metric("GST Collected", f"₹{profit_stats['total_gst']:,}")
            st.metric("Platform Fees", f"₹{profit_stats['total_platform_fee']:,}")
        
        with col4:
            st.metric("Theatre Share", f"₹{profit_stats['total_theatre_share']:,}")
            st.metric("Total Bookings", f"{profit_stats['total_bookings']:,}")
        
        # Profit breakdown chart
        st.write("#### 📊 Revenue Breakdown")
        
        breakdown_data = {
            'Category': ['Our Profit', 'Theatre Share', 'Platform Fee', 'GST'],
            'Amount': [
                profit_stats['total_profit'],
                profit_stats['total_theatre_share'],
                profit_stats['total_platform_fee'],
                profit_stats['total_gst']
            ]
        }
        
        df_breakdown = pd.DataFrame(breakdown_data)
        fig = px.pie(df_breakdown, values='Amount', names='Category', 
                    title="Revenue Distribution Breakdown")
        st.plotly_chart(fig, use_container_width=True)
        
        # Daily profit trend
        cursor.execute("""
            SELECT 
                DATE(booking_date) as booking_date,
                SUM(total_amount) as daily_revenue,
                SUM(profit_amount) as daily_profit,
                COUNT(*) as daily_bookings
            FROM bookings 
            WHERE payment_status = 'COMPLETED'
            GROUP BY DATE(booking_date)
            ORDER BY booking_date DESC
            LIMIT 30
        """)
        daily_profits = cursor.fetchall()
        
        if daily_profits:
            st.write("#### 📈 Daily Profit Trend (Last 30 Days)")
            df_daily = pd.DataFrame(daily_profits)
            
            col1, col2 = st.columns(2)
            
            with col1:
                fig_revenue = px.line(df_daily, x='booking_date', y='daily_revenue', 
                                    title="Daily Revenue Trend")
                st.plotly_chart(fig_revenue, use_container_width=True)
            
            with col2:
                fig_profit = px.line(df_daily, x='booking_date', y='daily_profit', 
                                   title="Daily Profit Trend")
                st.plotly_chart(fig_profit, use_container_width=True)
        
        # Event type profit analysis
        cursor.execute("""
            SELECT 
                event_type,
                SUM(total_amount) as revenue,
                SUM(profit_amount) as profit,
                COUNT(*) as bookings,
                AVG(profit_amount) as avg_profit_per_booking
            FROM bookings 
            WHERE payment_status = 'COMPLETED'
            GROUP BY event_type
            ORDER BY profit DESC
        """)
        event_profits = cursor.fetchall()
        
        if event_profits:
            st.write("#### 🎭 Profit by Event Type")
            df_events = pd.DataFrame(event_profits)
            
            col1, col2 = st.columns(2)
            
            with col1:
                fig_event_profit = px.bar(df_events, x='event_type', y='profit', 
                                        title="Total Profit by Event Type")
                st.plotly_chart(fig_event_profit, use_container_width=True)
            
            with col2:
                fig_avg_profit = px.bar(df_events, x='event_type', y='avg_profit_per_booking', 
                                      title="Average Profit per Booking")
                st.plotly_chart(fig_avg_profit, use_container_width=True)
        
        # Detailed breakdown table
        st.write("#### 📋 Detailed Profit Breakdown")
        if event_profits:
            df_display = pd.DataFrame(event_profits)
            df_display['revenue'] = df_display['revenue'].apply(lambda x: f"₹{x:,}")
            df_display['profit'] = df_display['profit'].apply(lambda x: f"₹{x:,}")
            df_display['avg_profit_per_booking'] = df_display['avg_profit_per_booking'].apply(lambda x: f"₹{x:,.0f}")
            df_display.columns = ['Event Type', 'Total Revenue', 'Total Profit', 'Bookings', 'Avg Profit/Booking']
            st.dataframe(df_display, use_container_width=True)
    
    else:
        st.info("📝 No profit data available yet. Complete some bookings to see analytics.")

def show_admin_analytics(cursor):
    """Show admin analytics"""
    st.write("### 📊 Booking Analytics")
    
    # Get booking statistics
    cursor.execute("""
        SELECT 
            event_type,
            COUNT(*) as total_bookings,
            SUM(booked_seats) as total_tickets,
            SUM(total_amount) as total_revenue
        FROM bookings 
        GROUP BY event_type
    """)
    stats = cursor.fetchall()
    
    if stats:
        # Create metrics
        col1, col2, col3 = st.columns(3)
        
        total_bookings = sum(stat['total_bookings'] for stat in stats)
        total_tickets = sum(stat['total_tickets'] for stat in stats)
        total_revenue = sum(stat['total_revenue'] for stat in stats)
        
        with col1:
            st.metric("Total Bookings", total_bookings)
        with col2:
            st.metric("Total Tickets", total_tickets)
        with col3:
            st.metric("Total Revenue", f"₹{total_revenue:,}")
        
        # Event type breakdown
        st.write("#### 📈 Revenue by Event Type")
        
        df_stats = pd.DataFrame(stats)
        fig = px.pie(df_stats, values='total_revenue', names='event_type', 
                    title="Revenue Distribution by Event Type")
        st.plotly_chart(fig, use_container_width=True)
        
        # Bookings over time
        cursor.execute("""
            SELECT DATE(booking_date) as booking_date, COUNT(*) as bookings
            FROM bookings 
            GROUP BY DATE(booking_date)
            ORDER BY booking_date
        """)
        daily_bookings = cursor.fetchall()
        
        if daily_bookings:
            st.write("#### 📅 Daily Bookings Trend")
            df_daily = pd.DataFrame(daily_bookings)
            fig = px.line(df_daily, x='booking_date', y='bookings', 
                         title="Daily Bookings Trend")
            st.plotly_chart(fig, use_container_width=True)
    else:
        st.info("📝 No booking data available yet.")

def show_admin_bookings(cursor):
    """Show all bookings for admin"""
    st.write("### 🎫 All Bookings")
    
    # Get all bookings
    cursor.execute("""
        SELECT booking_id, user_email, event_type, event_name, venue_name, 
               show_date, show_time, booked_seats, total_amount, booking_date, payment_status
        FROM bookings 
        ORDER BY booking_date DESC
        LIMIT 50
    """)
    bookings = cursor.fetchall()
    
    if bookings:
        # Convert to DataFrame for better display
        df = pd.DataFrame(bookings)
        df['booking_date'] = pd.to_datetime(df['booking_date']).dt.strftime('%Y-%m-%d %H:%M')
        
        st.dataframe(df, use_container_width=True)
        
        # Summary stats
        col1, col2, col3, col4 = st.columns(4)
        with col1:
            st.metric("Total Bookings", len(bookings))
        with col2:
            st.metric("Total Tickets", df['booked_seats'].sum())
        with col3:
            st.metric("Total Revenue", f"₹{df['total_amount'].sum():,}")
        with col4:
            successful = df[df['payment_status'] == 'COMPLETED'].shape[0]
            st.metric("Success Rate", f"{(successful/len(bookings)*100):.1f}%")
    else:
        st.info("📝 No bookings found.")

def show_admin_users(cursor):
    """Show user management"""
    st.write("### 👥 User Management")
    
    # Get user statistics
    cursor.execute("""
        SELECT COUNT(*) as total_users FROM users WHERE otp IS NULL
    """)
    total_users = cursor.fetchone()['total_users']
    
    cursor.execute("""
        SELECT area, COUNT(*) as user_count 
        FROM users WHERE otp IS NULL
        GROUP BY area 
        ORDER BY user_count DESC
    """)
    area_stats = cursor.fetchall()
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.metric("Total Active Users", total_users)
        
        if area_stats:
            st.write("#### 📍 Users by Area")
            df_areas = pd.DataFrame(area_stats)
            fig = px.bar(df_areas, x='area', y='user_count', 
                        title="User Distribution by Area")
            st.plotly_chart(fig, use_container_width=True)
    
    with col2:
        # Recent registrations
        cursor.execute("""
            SELECT name, email, area, created_at 
            FROM users 
            WHERE otp IS NULL 
            ORDER BY created_at DESC 
            LIMIT 10
        """)
        recent_users = cursor.fetchall()
        
        if recent_users:
            st.write("#### 🆕 Recent Registrations")
            for user in recent_users:
                st.write(f"**{user['name']}** ({user['area']}) - {user['created_at'].strftime('%Y-%m-%d')}")

def show_admin_settings(cursor):
    """Show admin settings"""
    st.write("### ⚙️ System Settings")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.write("#### 🎬 Theatre Management")
        if st.button("🔄 Reset Theatre Seats"):
            try:
                # Reset all theatre seats to full capacity
                cursor.execute("""
                    UPDATE theatre_rows 
                    SET available_seats = total_seats
                """)
                st.session_state.conn.commit()
                st.success("✅ All theatre seats reset to full capacity!")
            except Exception as e:
                st.error(f"❌ Error resetting seats: {e}")
        
        if st.button("📊 Update Seat Data"):
            try:
                recreate_theatre_rows_data(cursor, st.session_state.conn)
                st.success("✅ Seat data updated!")
            except Exception as e:
                st.error(f"❌ Error updating seat data: {e}")
        
        if st.button("🎬 Create All Theatre Seats"):
            try:
                # Create seat data for all theatres, all dates, all show times
                available_dates = get_next_few_days(3)
                all_show_times = set()
                
                # Get all show times
                for movie_id in range(1, 41):
                    show_times = get_movie_show_times(movie_id)
                    all_show_times.update(show_times)
                
                all_show_times = sorted(list(all_show_times))
                
                total_created = 0
                for theatre_id in range(1, 57):  # All 56 theatres
                    for date_info in available_dates:
                        for show_time in all_show_times:
                            created = ensure_seat_data_exists(cursor, st.session_state.conn, 
                                                            theatre_id, date_info['date'], show_time)
                            if created:
                                total_created += 1
                
                st.success(f"✅ Created seat data for {total_created} new show combinations!")
            except Exception as e:
                st.error(f"❌ Error creating seat data: {e}")
    
    with col2:
        st.write("#### 🏢 Venue Management")
        if st.button("🔄 Reset Venue Capacity"):
            try:
                # Reset all venue capacities
                cursor.execute("""
                    UPDATE venues 
                    SET available_capacity = capacity
                """)
                st.session_state.conn.commit()
                st.success("✅ All venue capacities reset!")
            except Exception as e:
                st.error(f"❌ Error resetting capacity: {e}")
    
    st.write("---")
    st.write("#### 🗄️ Database Management")
    
    col1, col2 = st.columns(2)
    with col1:
        if st.button("🔄 Reset Entire Database", type="secondary"):
            if reset_and_create_database():
                st.success("✅ Database reset successfully!")
                st.rerun()
    
    with col2:
        # Database statistics
        cursor.execute("SELECT COUNT(*) as count FROM users WHERE otp IS NULL")
        user_count = cursor.fetchone()['count']
        cursor.execute("SELECT COUNT(*) as count FROM bookings")
        booking_count = cursor.fetchone()['count']
        cursor.execute("SELECT COUNT(*) as count FROM payment_transactions")
        transaction_count = cursor.fetchone()['count']
        
        st.write(f"**Users:** {user_count}")
        st.write(f"**Bookings:** {booking_count}")
        st.write(f"**Transactions:** {transaction_count}")

# Main Application Flow
def main():
    """Main application flow"""
    
    # Initialize current step
    if 'current_step' not in st.session_state:
        st.session_state.current_step = "database_setup"
    
    # Database setup first
    if not st.session_state.db_ready:
        database_setup()
        return
    
    # Route to appropriate function based on current step
    if st.session_state.current_step == "login":
        login_user()
    elif st.session_state.current_step == "register":
        register_user()
    elif st.session_state.current_step == "verify_otp":
        verify_otp()
    elif st.session_state.current_step == "admin_login":
        admin_login()
    elif st.session_state.current_step == "main_menu":
        main_menu()
    elif st.session_state.current_step == "movie_booking":
        movie_booking()
    elif st.session_state.current_step == "movie_theatre_selection":
        movie_theatre_selection()
    elif st.session_state.current_step == "movie_date_time_selection":
        movie_date_time_selection()
    elif st.session_state.current_step == "movie_seat_selection":
        movie_seat_selection()
    elif st.session_state.current_step == "comedy_booking":
        comedy_booking()
    elif st.session_state.current_step == "comedy_venue_selection":
        comedy_venue_selection()
    elif st.session_state.current_step == "comedy_date_time_selection":
        comedy_date_time_selection()
    elif st.session_state.current_step == "comedy_ticket_selection":
        comedy_ticket_selection()
    elif st.session_state.current_step == "concert_booking":
        concert_booking()
    elif st.session_state.current_step == "concert_venue_selection":
        concert_venue_selection()
    elif st.session_state.current_step == "concert_date_time_selection":
        concert_date_time_selection()
    elif st.session_state.current_step == "concert_ticket_selection":
        concert_ticket_selection()
    elif st.session_state.current_step == "payment_method_selection":
        payment_method_selection()
    elif st.session_state.current_step == "payment_processing":
        payment_processing()
    elif st.session_state.current_step == "my_bookings":
        my_bookings()
    elif st.session_state.current_step == "admin_dashboard":
        admin_dashboard()
    else:
        # Default to login if no valid step
        st.session_state.current_step = "login"
        login_user()

if __name__ == "__main__":
    main()
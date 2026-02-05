# SmartShow Ultimate - Enhanced with 15 Comedy Shows & 15 Concerts
# 🎯 Complete Entertainment Booking System with Attractive UI
# Movies, Comedy Shows, Concerts with PostgreSQL and Streamlit

import streamlit as st
import psycopg2
from psycopg2.extras import RealDictCursor
import psycopg2.errors
import random
import time
from datetime import datetime, timedelta
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import numpy as np

# Page configuration
st.set_page_config(
    page_title="SmartShow Ultimate - Enhanced Entertainment",
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

# Enhanced Movie Posters
MOVIE_POSTERS = {
    # Romantic Movies (1-10)
    1: "https://image.tmdb.org/t/p/w500/9xjZS2rlVxm8SFx8kPC3aIGCOYQ.jpg",  # Titanic
    2: "https://image.tmdb.org/t/p/w500/rNzQyW4f8B8cQeg7Dgj3n6eT5k9.jpg",  # The Notebook
    3: "https://image.tmdb.org/t/p/w500/uDO8zWDhfWwoFdKS4fzkUJt0Rf0.jpg",  # La La Land
    4: "https://image.tmdb.org/t/p/w500/2CAL2433ZeIihfX1Hb2139CX0pW.jpg",  # DDLJ
    5: "https://image.tmdb.org/t/p/w500/yrf1RBdJqANJGKlJkS8PJhyaJJl.jpg",  # Jab We Met
    6: "https://image.tmdb.org/t/p/w500/5K7cOHoay2mZusSLezBOY0Qxh8a.jpg",  # Casablanca
    7: "https://image.tmdb.org/t/p/w500/9FBwqcd9IRruEDUrTdcaafOMKUq.jpg",  # YJHD
    8: "https://image.tmdb.org/t/p/w500/5MKXWWfKjLjKTOe5VWqRnBeGjWn.jpg",  # Before Sunrise
    9: "https://image.tmdb.org/t/p/w500/77ZozI0yAhrY7TgWVz0DG0ZjNbp.jpg",  # ZNMD
    10: "https://image.tmdb.org/t/p/w500/dvjqlp2sAL5gGvuGWrwgaGb0j1r.jpg",  # Princess Bride
    
    # Action Movies (11-20)
    11: "https://image.tmdb.org/t/p/w500/or06FN3Dka5tukK1e9sl16pB3iy.jpg",  # Avengers Endgame
    12: "https://image.tmdb.org/t/p/w500/6DrHO1jr3qVrViUO6s6kFiAGM7.jpg",  # Fast & Furious 9
    13: "https://image.tmdb.org/t/p/w500/klkFYDZOetUBKqeKXDJ7XZGP8Jl.jpg",  # Baahubali 2
    14: "https://image.tmdb.org/t/p/w500/jLEW3qsuTOeUNPe2jagaUgosbbO.jpg",  # KGF 2
    15: "https://image.tmdb.org/t/p/w500/qBG0jlhHvnt3bOp5XWQNaWcjkI8.jpg",  # Pathaan
    16: "https://image.tmdb.org/t/p/w500/hA2ple9q4qnwxp3hKVNhroipsir.jpg",  # Mad Max
    17: "https://image.tmdb.org/t/p/w500/4gpqv1iOmAVEpgWv3xgmhQVQFjl.jpg",  # War
    18: "https://image.tmdb.org/t/p/w500/fZPSd91yGE9fCcCe6OoQr6E3Bev.jpg",  # John Wick
    19: "https://image.tmdb.org/t/p/w500/qemWNpkHk5jbUjCKSRZJWfhaQM0.jpg",  # Pushpa
    20: "https://image.tmdb.org/t/p/w500/4XddcRDtnNjYmLRMYpbrhFxsbuq.jpg",  # Mission Impossible
    
    # Comedy Movies (21-30)
    21: "https://image.tmdb.org/t/p/w500/yOjty6adS9qPwqhZ8H7wYmAo87P.jpg",  # Hera Pheri
    22: "https://image.tmdb.org/t/p/w500/6CoRTJTmijhBLJTUNoVSUNxZMEI.jpg",  # Golmaal
    23: "https://image.tmdb.org/t/p/w500/lnWkyG3LLgbbrsFqvBEyJGrUpVu.jpg",  # Andaz Apna Apna
    24: "https://image.tmdb.org/t/p/w500/8UlWHLMpgZm9bx6QYh0NFoq67TZ.jpg",  # Welcome
    25: "https://image.tmdb.org/t/p/w500/9VLoqf0jPul6R0AJiJOtYmDpyYJ.jpg",  # Housefull
    26: "https://image.tmdb.org/t/p/w500/cs668Bd7YGNdW8bWyKU5ZgHb6Yp.jpg",  # The Hangover
    27: "https://image.tmdb.org/t/p/w500/yOjty6adS9qPwqhZ8H7wYmAo87P.jpg",  # Munna Bhai MBBS
    28: "https://image.tmdb.org/t/p/w500/ek8e8txUyUwd2BNqj6lFEerJfbq.jpg",  # Superbad
    29: "https://image.tmdb.org/t/p/w500/6CoRTJTmijhBLJTUNoVSUNxZMEI.jpg",  # Fukrey
    30: "https://image.tmdb.org/t/p/w500/4LdpBXiCyGKkR8FGHgjKlphrfUc.jpg",  # Dumb and Dumber
    
    # Family Movies (31-40)
    31: "https://image.tmdb.org/t/p/w500/gNA6hzSHk5h1fJcqp7ridaJEEDc.jpg",  # Taare Zameen Par
    32: "https://image.tmdb.org/t/p/w500/66A9MqXOyVFCssoloscw79z8Tew.jpg",  # 3 Idiots
    33: "https://image.tmdb.org/t/p/w500/lWlsZEteLGNOHBpWsEBKRbq8kUl.jpg",  # Dangal
    34: "https://image.tmdb.org/t/p/w500/eHuGQ10FUzK1mdOY69wF5pGgEf5.jpg",  # Finding Nemo
    35: "https://image.tmdb.org/t/p/w500/sKCr78MXSLixwmZ8DyJLrpMsd15.jpg",  # Lion King
    36: "https://image.tmdb.org/t/p/w500/gGEsBPAijhVUFoiNpgZXqRVWJt2.jpg",  # Coco
    37: "https://image.tmdb.org/t/p/w500/qCnGjNrBMxhJPlNW2e2zWq4KJgX.jpg",  # Queen
    38: "https://image.tmdb.org/t/p/w500/uXDfjJbdP4ijW5hWSBrPrlKpxab.jpg",  # Toy Story
    39: "https://image.tmdb.org/t/p/w500/gYuW3LBfhKGQBVNNlpWHhqXdJlU.jpg",  # Hindi Medium
    40: "https://image.tmdb.org/t/p/w500/2LqaLgk4Z226KkgPJuiOQ58wvrm.jpg"   # The Incredibles
}

# 🎭 ENHANCED COMEDY POSTERS - 15 Shows
COMEDY_POSTERS = {
    1: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=450&fit=crop",  # Kapil Sharma
    2: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300&h=450&fit=crop",  # Zakir Khan
    3: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&h=450&fit=crop",  # Biswa
    4: "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=300&h=450&fit=crop",  # Kenny Sebastian
    5: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=300&h=450&fit=crop",  # Abhishek Upmanyu
    6: "https://images.unsplash.com/photo-1566492031773-4f4e44671d66?w=300&h=450&fit=crop",  # Vir Das
    7: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=450&fit=crop",  # Kanan Gill
    8: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300&h=450&fit=crop",  # Sapan Verma
    9: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&h=450&fit=crop",  # Anubhav Singh Bassi
    10: "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=300&h=450&fit=crop", # Rahul Subramanian
    11: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=300&h=450&fit=crop", # Kunal Kamra
    12: "https://images.unsplash.com/photo-1566492031773-4f4e44671d66?w=300&h=450&fit=crop", # Abish Mathew
    13: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=450&fit=crop", # Sumukhi Suresh
    14: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300&h=450&fit=crop", # Prashasti Singh
    15: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&h=450&fit=crop"  # Rohan Joshi
}

# 🎵 ENHANCED CONCERT POSTERS - 15 Concerts
CONCERT_POSTERS = {
    1: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=450&fit=crop",  # Arijit Singh
    2: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300&h=450&fit=crop",  # AR Rahman
    3: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=450&fit=crop",  # Nucleya
    4: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=450&fit=crop",  # Rahat Fateh Ali Khan
    5: "https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=300&h=450&fit=crop",  # Sunidhi Chauhan
    6: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300&h=450&fit=crop",  # Shreya Ghoshal
    7: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=450&fit=crop",  # Sonu Nigam
    8: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=450&fit=crop",  # Armaan Malik
    9: "https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=300&h=450&fit=crop",  # Neha Kakkar
    10: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300&h=450&fit=crop", # Badshah
    11: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=450&fit=crop", # Divine
    12: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=450&fit=crop", # Kailash Kher
    13: "https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=300&h=450&fit=crop", # Hariharan
    14: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300&h=450&fit=crop", # Shaan
    15: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=450&fit=crop"  # Mohit Chauhan
}

# Enhanced Areas List - 8 areas with 7 theaters each (56 total)
AREAS = [
    'Satellite', 'Vastrapur', 'Paldi', 'Thaltej', 
    'Bopal', 'Maninagar', 'Naranpura', 'Chandkheda'
]

# Movie-specific theater mapping - Each movie gets 3 specific theaters from user's area
MOVIE_THEATER_MAPPING = {
    # Romantic Movies (1-10) - Premium theaters
    1: [1, 2, 3], 2: [2, 3, 4], 3: [3, 4, 5], 4: [4, 5, 6], 5: [5, 6, 7],
    6: [6, 7, 1], 7: [7, 1, 2], 8: [1, 3, 5], 9: [2, 4, 6], 10: [3, 5, 7],
    
    # Action Movies (11-20) - Mix of premium and multiplex
    11: [1, 4, 7], 12: [2, 5, 1], 13: [3, 6, 2], 14: [4, 7, 3], 15: [5, 1, 4],
    16: [6, 2, 5], 17: [7, 3, 6], 18: [1, 5, 7], 19: [2, 6, 1], 20: [3, 7, 2],
    
    # Comedy Movies (21-30) - All theater types
    21: [2, 4, 6], 22: [3, 5, 7], 23: [4, 6, 1], 24: [5, 7, 2], 25: [6, 1, 3],
    26: [7, 2, 4], 27: [1, 3, 5], 28: [2, 4, 6], 29: [3, 5, 7], 30: [4, 6, 1],
    
    # Family Movies (31-40) - Family-friendly theaters
    31: [1, 2, 7], 32: [2, 3, 1], 33: [3, 4, 2], 34: [4, 5, 3], 35: [5, 6, 4],
    36: [6, 7, 5], 37: [7, 1, 6], 38: [1, 4, 7], 39: [2, 5, 1], 40: [3, 6, 2]
}

# Utility Functions
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

def get_movie_show_times(movie_id):
    """Get show times based on movie ID - FIXED VERSION"""
    movie_show_times = {
        # Romantic Movies (1-10)
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
        
        # Action Movies (11-20)
        11: ["12:30 PM", "4:00 PM", "7:30 PM"],
        12: ["12:15 PM", "3:45 PM", "7:15 PM"],
        13: ["12:45 PM", "4:15 PM", "7:45 PM"],
        14: ["1:00 PM", "4:30 PM", "8:00 PM"],
        15: ["12:00 PM", "3:30 PM", "7:00 PM"],
        16: ["11:45 AM", "3:15 PM", "6:45 PM"],
        17: ["1:15 PM", "4:45 PM", "8:15 PM"],
        18: ["11:30 AM", "3:00 PM", "6:30 PM"],
        19: ["12:20 PM", "3:50 PM", "7:20 PM"],
        20: ["11:15 AM", "2:45 PM", "6:15 PM"],
        
        # Comedy Movies (21-30)
        21: ["1:30 PM", "4:30 PM", "7:00 PM"],
        22: ["1:15 PM", "4:15 PM", "6:45 PM"],
        23: ["1:45 PM", "4:45 PM", "7:15 PM"],
        24: ["2:00 PM", "5:00 PM", "7:30 PM"],
        25: ["1:00 PM", "4:00 PM", "6:30 PM"],
        26: ["1:20 PM", "4:20 PM", "6:50 PM"],
        27: ["1:35 PM", "4:35 PM", "7:05 PM"],
        28: ["1:50 PM", "4:50 PM", "7:20 PM"],
        29: ["1:10 PM", "4:10 PM", "6:40 PM"],
        30: ["1:25 PM", "4:25 PM", "6:55 PM"],
        
        # Family Movies (31-40)
        31: ["11:00 AM", "2:30 PM", "6:00 PM"],
        32: ["10:45 AM", "2:15 PM", "5:45 PM"],
        33: ["11:15 AM", "2:45 PM", "6:15 PM"],
        34: ["10:30 AM", "2:00 PM", "5:30 PM"],
        35: ["11:30 AM", "3:00 PM", "6:30 PM"],
        36: ["10:15 AM", "1:45 PM", "5:15 PM"],
        37: ["11:45 AM", "3:15 PM", "6:45 PM"],
        38: ["10:00 AM", "1:30 PM", "5:00 PM"],
        39: ["12:00 PM", "3:30 PM", "7:00 PM"],
        40: ["10:20 AM", "1:50 PM", "5:20 PM"]
    }
    
    return movie_show_times.get(movie_id, ["2:00 PM", "6:00 PM", "9:00 PM"])

def get_movie_specific_theaters(movie_id, user_area, cursor):
    """Get 3 specific theaters for each movie from the 7 available in user's area"""
    # Get all theaters in user's area
    cursor.execute("""
        SELECT theater_id, name, area, theater_type, base_price, total_seats, available_seats, address
        FROM theatres WHERE area = %s
        ORDER BY theater_id
    """, (user_area,))
    all_theaters = cursor.fetchall()
    
    if len(all_theaters) < 3:
        return all_theaters
    
    # Get the specific theater indices for this movie
    theater_indices = MOVIE_THEATER_MAPPING.get(movie_id, [1, 2, 3])
    
    # Select the specific theaters
    selected_theaters = []
    for idx in theater_indices:
        # Convert to 0-based index and ensure it's within bounds
        array_idx = (idx - 1) % len(all_theaters)
        selected_theaters.append(all_theaters[array_idx])
    
    return selected_theaters

def valid_email(email):
    """Email validation"""
    if " " in email or len(email) < 10:
        return False
    return email.endswith("@gmail.com")

def valid_password(pw):
    """Password validation"""
    if len(pw) > 10 or len(pw) < 5:
        return False
    return any(c.isupper() for c in pw) and any(c.islower() for c in pw) and any(c.isdigit() for c in pw) and "@" in pw

def generate_otp():
    """Generate 6-digit OTP"""
    return str(random.randint(100000, 999999))

def generate_transaction_id():
    """Generate unique transaction ID"""
    return f"TXN{int(time.time())}{random.randint(1000, 9999)}"

def validate_upi_id(upi_id):
    """Validate UPI ID format"""
    if not upi_id:
        return False
    valid_handles = ['@paytm', '@phonepe', '@gpay', '@amazonpay', '@ybl', '@okaxis', '@okicici', '@okhdfcbank', '@oksbi', '@okbizaxis']
    return '@' in upi_id and any(upi_id.endswith(handle) for handle in valid_handles)

def validate_card_number(card_number):
    """Basic card number validation"""
    if not card_number:
        return False
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

def calculate_profit_breakdown(total_amount):
    """Calculate profit breakdown with GST, platform fee, theater share, and profit"""
    # Base amount (before GST)
    base_amount = int(total_amount / 1.18)  # Remove 18% GST
    
    # GST (18%)
    gst_amount = total_amount - base_amount
    
    # Platform fee (10% of base amount)
    platform_fee = int(base_amount * 0.10)
    
    # Theater share (60% of base amount)
    theater_share = int(base_amount * 0.60)
    
    # Our profit (30% of base amount)
    profit_amount = base_amount - platform_fee - theater_share
    
    return {
        'base_amount': base_amount,
        'gst_amount': gst_amount,
        'platform_fee': platform_fee,
        'theater_share': theater_share,
        'profit_amount': profit_amount
    }

def write_ticket_to_file(event_type, booking_details):
    """Write ticket details to appropriate text file"""
    try:
        if event_type == "movie":
            filename = "movies.txt"
        elif event_type == "comedy":
            filename = "comedy.txt"
        elif event_type == "concert":
            filename = "concerts.txt"
        else:
            filename = "other_bookings.txt"
        
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
        
        with open(filename, 'a', encoding='utf-8') as file:
            file.write(ticket_info)
        
        return True
    except Exception as e:
        st.error(f"❌ Error writing to file: {e}")
        return False

# Database Connection Functions
def reset_and_create_database():
    """Completely reset and create database with correct structure"""
    try:
        password = st.session_state.db_password
        
        # Connect to PostgreSQL server (not specific database)
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
        
        # Check if all required tables exist
        cursor.execute("""
            SELECT table_name FROM information_schema.tables 
            WHERE table_schema = 'public' AND table_name IN 
            ('users', 'admin_users', 'theatres', 'movies', 'comedy_shows', 'concerts', 'venues', 'bookings', 'payment_transactions')
        """)
        existing_tables = [row['table_name'] for row in cursor.fetchall()]
        
        required_tables = ['users', 'admin_users', 'theatres', 'movies', 'comedy_shows', 'concerts', 'venues', 'bookings', 'payment_transactions']
        
        if len(existing_tables) < len(required_tables):
            st.warning("⚠️ Database structure incomplete. Creating missing tables...")
            create_all_tables(cursor, conn)
            insert_all_sample_data(cursor, conn)
        
        st.session_state.conn = conn
        st.session_state.cursor = cursor
        st.session_state.db_ready = True
        return True
        
    except Exception as e:
        st.error(f"❌ Database connection failed: {e}")
        st.info("💡 Try using the 'Reset DB' button to create a fresh database.")
        return False

def create_all_tables(cursor, conn):
    """Create all tables with correct structure"""
    # Drop all tables first
    drop_tables = [
        "DROP TABLE IF EXISTS payment_transactions CASCADE",
        "DROP TABLE IF EXISTS bookings CASCADE", 
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
        """CREATE TABLE users (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            email VARCHAR(100) UNIQUE NOT NULL,
            password VARCHAR(10) NOT NULL,
            password_display VARCHAR(20) NOT NULL,
            area VARCHAR(100) NOT NULL,
            otp VARCHAR(10),
            otp_expiry TIMESTAMP,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )""",
        
        # Admin users table
        """CREATE TABLE admin_users (
            admin_id SERIAL PRIMARY KEY,
            username VARCHAR(50) UNIQUE NOT NULL,
            password VARCHAR(100) NOT NULL,
            full_name VARCHAR(100) NOT NULL,
            email VARCHAR(100) NOT NULL,
            role VARCHAR(50) DEFAULT 'ADMIN',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            last_login TIMESTAMP
        )""",
        
        # Theatres table
        """CREATE TABLE theatres (
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
        )""",
        
        # Movies table
        """CREATE TABLE movies (
            id INTEGER PRIMARY KEY,
            movie_name VARCHAR(100) NOT NULL,
            mood VARCHAR(50) NOT NULL,
            duration_minutes INTEGER DEFAULT 150,
            rating VARCHAR(10) DEFAULT 'U/A',
            language VARCHAR(50) DEFAULT 'Hindi'
        )""",
        
        # Comedy shows table
        """CREATE TABLE comedy_shows (
            show_id INTEGER PRIMARY KEY,
            comedian_name VARCHAR(100) NOT NULL,
            show_title VARCHAR(150) NOT NULL,
            show_type VARCHAR(50) DEFAULT 'Stand-up Comedy',
            duration_minutes INTEGER DEFAULT 90,
            language VARCHAR(50) DEFAULT 'Hindi',
            age_rating VARCHAR(10) DEFAULT '18+',
            description TEXT,
            ticket_price INTEGER DEFAULT 500
        )""",
        
        # Concerts table
        """CREATE TABLE concerts (
            concert_id INTEGER PRIMARY KEY,
            artist_name VARCHAR(100) NOT NULL,
            concert_title VARCHAR(150) NOT NULL,
            genre VARCHAR(50) NOT NULL,
            duration_minutes INTEGER DEFAULT 120,
            language VARCHAR(50) DEFAULT 'Hindi',
            ticket_price INTEGER DEFAULT 1000,
            description TEXT,
            special_guests TEXT
        )""",
        
        # Venues table
        """CREATE TABLE venues (
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
        )""",
        
        # Bookings table
        """CREATE TABLE bookings (
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
        )""",
        
        # Payment transactions table
        """CREATE TABLE payment_transactions (
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
        )"""
    ]
    
    for table_sql in tables:
        cursor.execute(table_sql)
    
    conn.commit()
def insert_all_sample_data(cursor, conn):
    """Insert all sample data with ENHANCED 15 Comedy Shows & 15 Concerts"""
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
        
        # Insert enhanced venues for comedy shows and concerts (distributed across areas)
        venues_data = [
            # Comedy Venues (1-16) - 2 per area
            (1, "Comedy Club Satellite", "Satellite", "Ahmedabad", "Comedy Club", 150, 150, 500, "Satellite Road, Ahmedabad", "AC, Sound System, Bar"),
            (2, "Laugh Factory Satellite", "Satellite", "Ahmedabad", "Comedy Venue", 120, 120, 450, "Satellite Plaza, Ahmedabad", "AC, Stage Lighting"),
            (3, "Stand-Up Central Vastrapur", "Vastrapur", "Ahmedabad", "Comedy Hall", 180, 180, 550, "Vastrapur Lake, Ahmedabad", "Premium Sound, AC"),
            (4, "Comedy Corner Vastrapur", "Vastrapur", "Ahmedabad", "Comedy Club", 140, 140, 480, "Vastrapur Mall, Ahmedabad", "AC, Sound System, Bar"),
            (5, "Humor Hub Paldi", "Paldi", "Ahmedabad", "Comedy Venue", 160, 160, 520, "Paldi Central, Ahmedabad", "AC, Stage Lighting"),
            (6, "Laugh Lounge Paldi", "Paldi", "Ahmedabad", "Comedy Club", 130, 130, 480, "Paldi Plaza, Ahmedabad", "AC, Sound System"),
            (7, "Comedy Central Thaltej", "Thaltej", "Ahmedabad", "Comedy Hall", 170, 170, 500, "Thaltej Mall, Ahmedabad", "Premium Sound, AC"),
            (8, "Stand-Up Stage Thaltej", "Thaltej", "Ahmedabad", "Comedy Venue", 145, 145, 460, "Thaltej Plaza, Ahmedabad", "AC, Stage Lighting"),
            (9, "Humor House Bopal", "Bopal", "Ahmedabad", "Comedy Club", 155, 155, 490, "Bopal Square, Ahmedabad", "AC, Sound System, Bar"),
            (10, "Comedy Corner Bopal", "Bopal", "Ahmedabad", "Comedy Venue", 135, 135, 470, "Bopal Mall, Ahmedabad", "AC, Stage Lighting"),
            (11, "Laugh Factory Maninagar", "Maninagar", "Ahmedabad", "Comedy Hall", 165, 165, 510, "Maninagar Central, Ahmedabad", "Premium Sound, AC"),
            (12, "Comedy Club Maninagar", "Maninagar", "Ahmedabad", "Comedy Club", 125, 125, 450, "Maninagar Plaza, Ahmedabad", "AC, Sound System"),
            (13, "Stand-Up Central Naranpura", "Naranpura", "Ahmedabad", "Comedy Venue", 175, 175, 530, "Naranpura Mall, Ahmedabad", "AC, Stage Lighting"),
            (14, "Humor Hub Naranpura", "Naranpura", "Ahmedabad", "Comedy Club", 150, 150, 500, "Naranpura Plaza, Ahmedabad", "AC, Sound System, Bar"),
            (15, "Comedy Corner Chandkheda", "Chandkheda", "Ahmedabad", "Comedy Hall", 140, 140, 480, "Chandkheda Central, Ahmedabad", "Premium Sound, AC"),
            (16, "Laugh Lounge Chandkheda", "Chandkheda", "Ahmedabad", "Comedy Venue", 160, 160, 520, "Chandkheda Mall, Ahmedabad", "AC, Stage Lighting"),
            
            # Concert Venues (17-32) - 2 per area
            (17, "Concert Hall Satellite", "Satellite", "Ahmedabad", "Concert Venue", 500, 500, 1000, "Satellite Plaza, Ahmedabad", "Premium Sound, Lighting, VIP Seating"),
            (18, "Music Arena Satellite", "Satellite", "Ahmedabad", "Music Venue", 400, 400, 1200, "Satellite Road, Ahmedabad", "Professional Sound, Stage"),
            (19, "Symphony Hall Vastrapur", "Vastrapur", "Ahmedabad", "Concert Venue", 600, 600, 1100, "Vastrapur Lake, Ahmedabad", "Premium Sound, Lighting"),
            (20, "Melody Center Vastrapur", "Vastrapur", "Ahmedabad", "Music Venue", 450, 450, 1150, "Vastrapur Mall, Ahmedabad", "Professional Sound, Stage"),
            (21, "Rhythm Palace Paldi", "Paldi", "Ahmedabad", "Concert Venue", 550, 550, 1050, "Paldi Central, Ahmedabad", "Premium Sound, Lighting, VIP Seating"),
            (22, "Music Hall Paldi", "Paldi", "Ahmedabad", "Concert Venue", 480, 480, 1080, "Paldi Plaza, Ahmedabad", "Professional Sound, Stage"),
            (23, "Concert Arena Thaltej", "Thaltej", "Ahmedabad", "Music Venue", 520, 520, 1120, "Thaltej Mall, Ahmedabad", "Premium Sound, Lighting"),
            (24, "Sound Stage Thaltej", "Thaltej", "Ahmedabad", "Concert Venue", 460, 460, 1000, "Thaltej Plaza, Ahmedabad", "Professional Sound, Stage"),
            (25, "Music Palace Bopal", "Bopal", "Ahmedabad", "Concert Venue", 580, 580, 1180, "Bopal Square, Ahmedabad", "Premium Sound, Lighting, VIP Seating"),
            (26, "Concert Hall Bopal", "Bopal", "Ahmedabad", "Music Venue", 420, 420, 1020, "Bopal Mall, Ahmedabad", "Professional Sound, Stage"),
            (27, "Symphony Center Maninagar", "Maninagar", "Ahmedabad", "Concert Venue", 540, 540, 1140, "Maninagar Central, Ahmedabad", "Premium Sound, Lighting"),
            (28, "Music Arena Maninagar", "Maninagar", "Ahmedabad", "Concert Venue", 380, 380, 980, "Maninagar Plaza, Ahmedabad", "Professional Sound, Stage"),
            (29, "Rhythm Hall Naranpura", "Naranpura", "Ahmedabad", "Music Venue", 620, 620, 1220, "Naranpura Mall, Ahmedabad", "Premium Sound, Lighting"),
            (30, "Concert Palace Naranpura", "Naranpura", "Ahmedabad", "Concert Venue", 500, 500, 1100, "Naranpura Plaza, Ahmedabad", "Professional Sound, Stage"),
            (31, "Music Hall Chandkheda", "Chandkheda", "Ahmedabad", "Concert Venue", 560, 560, 1160, "Chandkheda Central, Ahmedabad", "Premium Sound, Lighting, VIP Seating"),
            (32, "Sound Arena Chandkheda", "Chandkheda", "Ahmedabad", "Music Venue", 440, 440, 1040, "Chandkheda Mall, Ahmedabad", "Professional Sound, Stage")
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
        
        # 🎭 ENHANCED COMEDY SHOWS - 15 Shows
        comedy_data = [
            (1, "Kapil Sharma", "The Kapil Sharma Show Live", "Stand-up Comedy", 90, "Hindi", "18+", "Hilarious comedy show with celebrity guests", 500),
            (2, "Zakir Khan", "Haq Se Single", "Stand-up Comedy", 85, "Hindi", "18+", "Comedy about being single and relationships", 600),
            (3, "Biswa Kalyan Rath", "Pretentious Movie Reviews", "Stand-up Comedy", 80, "English", "18+", "Movie review comedy with witty observations", 550),
            (4, "Kenny Sebastian", "The Most Interesting Person", "Stand-up Comedy", 75, "English", "16+", "Observational comedy about everyday life", 650),
            (5, "Abhishek Upmanyu", "Thoda Saaf Bol", "Stand-up Comedy", 85, "Hindi", "18+", "Clean comedy show with relatable humor", 500),
            (6, "Vir Das", "Abroad Understanding", "Stand-up Comedy", 95, "English", "18+", "International comedy with cultural observations", 700),
            (7, "Kanan Gill", "Keep It Real", "Stand-up Comedy", 80, "English", "16+", "Honest comedy about modern life", 580),
            (8, "Sapan Verma", "Obsessive Compulsive Disorder", "Stand-up Comedy", 75, "English", "18+", "Comedy about quirks and habits", 520),
            (9, "Anubhav Singh Bassi", "Bas Kar Bassi", "Stand-up Comedy", 90, "Hindi", "18+", "Storytelling comedy with personal anecdotes", 620),
            (10, "Rahul Subramanian", "Kal Main Udega", "Stand-up Comedy", 85, "English", "16+", "Witty comedy about aspirations and failures", 560),
            (11, "Kunal Kamra", "Shut Up Ya Kunal", "Stand-up Comedy", 80, "Hindi", "18+", "Political satire and social commentary", 540),
            (12, "Abish Mathew", "Whoop!", "Stand-up Comedy", 75, "English", "16+", "Energetic comedy with crowd interaction", 580),
            (13, "Sumukhi Suresh", "Don't Tell Amma", "Stand-up Comedy", 85, "English", "18+", "Female perspective comedy with bold humor", 600),
            (14, "Prashasti Singh", "Sassy Singh", "Stand-up Comedy", 80, "Hindi", "18+", "Sassy comedy about relationships and society", 520),
            (15, "Rohan Joshi", "Wake N Bake", "Stand-up Comedy", 90, "English", "18+", "Comedy about millennial struggles", 640)
        ]
        
        for comedy in comedy_data:
            cursor.execute("""
                INSERT INTO comedy_shows (show_id, comedian_name, show_title, show_type, duration_minutes, language, age_rating, description, ticket_price)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, comedy)
        
        # 🎵 ENHANCED CONCERTS - 15 Concerts
        concert_data = [
            (1, "Arijit Singh", "Arijit Singh Live in Concert", "Bollywood", 120, "Hindi", 1000, "Romantic Bollywood hits by the king of melody", "Shreya Ghoshal"),
            (2, "A.R. Rahman", "Rahman Live - Musical Journey", "Classical/Fusion", 150, "Multi", 1500, "Musical maestro performing his greatest hits", "Hariharan, Kailash Kher"),
            (3, "Nucleya", "Electronic Dance Night", "Electronic", 90, "Instrumental", 800, "High-energy EDM night with bass drops", "Divine, KSHMR"),
            (4, "Rahat Fateh Ali Khan", "Sufi Night - Ishq Sufiana", "Sufi", 100, "Urdu", 1200, "Spiritual Sufi music for the soul", "Kailash Kher"),
            (5, "Sunidhi Chauhan", "Bollywood Diva Live", "Bollywood", 110, "Hindi", 900, "Energetic performance by Bollywood's powerhouse", "Shaan"),
            (6, "Shreya Ghoshal", "Melody Queen Live", "Classical/Bollywood", 130, "Hindi", 1100, "Classical and Bollywood melodies", "Ustad Rahat Fateh Ali Khan"),
            (7, "Sonu Nigam", "Voice of Bollywood", "Bollywood", 125, "Hindi", 1000, "Versatile singer performing across genres", "Alka Yagnik"),
            (8, "Armaan Malik", "Next Gen Bollywood", "Pop/Bollywood", 100, "Hindi", 850, "Young sensation with contemporary hits", "Asees Kaur"),
            (9, "Neha Kakkar", "Queen of Pop", "Pop/Bollywood", 105, "Hindi", 950, "Peppy numbers and dance tracks", "Tony Kakkar"),
            (10, "Badshah", "Rap King Live", "Hip-Hop/Rap", 95, "Hindi", 900, "High-energy rap and hip-hop performance", "Aastha Gill"),
            (11, "Divine", "Gully Gang Live", "Hip-Hop/Rap", 85, "Hindi", 750, "Underground rap and street music", "Naezy"),
            (12, "Kailash Kher", "Sufi Rock Fusion", "Sufi Rock", 115, "Hindi", 1050, "Unique blend of Sufi and rock music", "Papon"),
            (13, "Hariharan", "Ghazal Maestro", "Ghazal/Classical", 120, "Hindi/Urdu", 1200, "Soulful ghazals and classical music", "Chitra"),
            (14, "Shaan", "Bollywood Unplugged", "Acoustic/Bollywood", 110, "Hindi", 950, "Acoustic versions of popular Bollywood songs", "Raghav Sachar"),
            (15, "Mohit Chauhan", "Rockstar Live", "Rock/Bollywood", 115, "Hindi", 1000, "Rock ballads and Bollywood chartbusters", "Shilpa Rao")
        ]
        
        for concert in concert_data:
            cursor.execute("""
                INSERT INTO concerts (concert_id, artist_name, concert_title, genre, duration_minutes, language, ticket_price, description, special_guests)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, concert)
        
        conn.commit()
        
    except psycopg2.Error as e:
        st.error(f"❌ Error inserting sample data: {e}")
        conn.rollback()

# Database Setup Function
def database_setup():
    """Database setup and connection interface"""
    st.title("🎬 SmartShow Ultimate - Enhanced Database Setup")
    
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
                    with st.spinner("Creating fresh database with 15 comedy shows & 15 concerts..."):
                        if reset_and_create_database():
                            st.success("✅ Enhanced database created successfully!")
                            st.info("🎭 15 Comedy Shows & 🎵 15 Concerts added!")
                            st.rerun()
                        else:
                            st.error("❌ Database creation failed!")
            
            st.info("💡 **First time?** Use 'Reset & Create Fresh DB' to set up everything automatically.")
            st.info("🔄 **Having issues?** Use 'Reset & Create Fresh DB' to fix any database problems.")
            st.info("🎯 **Enhanced Version:** This includes 15 comedy shows and 15 concerts!")
    else:
        st.success("✅ Enhanced Database is ready!")
        st.info("🎭 15 Comedy Shows & 🎵 15 Concerts available!")
        if st.button("🔄 Reset Database", type="secondary"):
            if reset_and_create_database():
                st.success("✅ Database reset successfully!")
                st.rerun()
# User Authentication Functions
def register_user():
    """Enhanced user registration with area selection first"""
    st.title("📝 Create New Account")
    
    # Step 1: Area Selection First (as per user requirement)
    if 'selected_area' not in st.session_state:
        st.session_state.selected_area = None
    
    if not st.session_state.selected_area:
        st.write("### 📍 Step 1: Select Your Area")
        st.info("🎯 Choose your area to see theaters and venues near you!")
        
        # Display areas in a nice grid
        cols = st.columns(4)
        for i, area in enumerate(AREAS):
            with cols[i % 4]:
                if st.button(f"📍 {area}", key=f"area_{area}", use_container_width=True):
                    st.session_state.selected_area = area
                    st.rerun()
        return
    
    # Step 2: User Registration Form
    st.write(f"### 📍 Selected Area: **{st.session_state.selected_area}**")
    st.write("### 👤 Step 2: Create Your Account")
    
    with st.form("register_form"):
        name = st.text_input("Full Name:", placeholder="Enter your full name")
        email = st.text_input("Email Address:", placeholder="yourname@gmail.com")
        password = st.text_input("Password:", type="password", 
                                help="Max 10 chars, must include: uppercase, lowercase, number, and @")
        confirm_password = st.text_input("Confirm Password:", type="password")
        
        col1, col2 = st.columns(2)
        with col1:
            submit = st.form_submit_button("Create Account", type="primary")
        with col2:
            change_area = st.form_submit_button("← Change Area")
        
        if change_area:
            st.session_state.selected_area = None
            st.rerun()
        
        if submit:
            # Validation
            if not all([name, email, password, confirm_password]):
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
                        
                        # Insert user with selected area
                        cursor.execute("""
                            INSERT INTO users (name, email, password, password_display, area, otp, otp_expiry)
                            VALUES (%s, %s, %s, %s, %s, %s, %s)
                        """, (name, email, password, password, st.session_state.selected_area, otp, otp_expiry))
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
        st.session_state.selected_area = None
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
                        SELECT otp, otp_expiry FROM users WHERE email = %s
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
                                UPDATE users SET otp = NULL, otp_expiry = NULL WHERE email = %s
                            """, (st.session_state.pending_email,))
                            st.session_state.conn.commit()
                            
                            st.success("✅ Account verified successfully!")
                            st.session_state.logged_in_user = st.session_state.pending_email
                            st.session_state.pending_email = None
                            
                            # Clear the stored OTP and area selection
                            if 'generated_otp' in st.session_state:
                                del st.session_state.generated_otp
                            if 'selected_area' in st.session_state:
                                del st.session_state.selected_area
                            
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
        if 'selected_area' in st.session_state:
            del st.session_state.selected_area
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
                        SELECT email, name, otp FROM users WHERE email = %s AND password = %s
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
    """Enhanced main menu for logged-in users"""
    cursor = st.session_state.cursor
    
    # Get user info
    cursor.execute("SELECT name, area FROM users WHERE email = %s", (st.session_state.logged_in_user,))
    user_info = cursor.fetchone()
    
    st.title(f"🎬 Welcome, {user_info['name']}!")
    st.write(f"📍 Your Area: **{user_info['area']}** (7 theaters available)")
    
    # Enhanced main menu with attractive cards
    st.write("### 🎯 Choose Your Entertainment")
    
    col1, col2, col3 = st.columns(3)
    
    with col1:
        st.markdown("""
        <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 20px; border-radius: 10px; text-align: center; margin: 10px 0;">
            <h3 style="color: white; margin: 0;">🎬 MOVIES</h3>
            <p style="color: white; margin: 5px 0;">40 Movies • 4 Moods</p>
            <p style="color: white; margin: 5px 0;">3 Theaters per Movie</p>
        </div>
        """, unsafe_allow_html=True)
        if st.button("🎬 Book Movies", use_container_width=True, type="primary"):
            st.session_state.current_step = "movie_booking"
            st.rerun()
    
    with col2:
        st.markdown("""
        <div style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); padding: 20px; border-radius: 10px; text-align: center; margin: 10px 0;">
            <h3 style="color: white; margin: 0;">😂 COMEDY</h3>
            <p style="color: white; margin: 5px 0;">15 Stand-up Shows</p>
            <p style="color: white; margin: 5px 0;">Live Performances</p>
        </div>
        """, unsafe_allow_html=True)
        if st.button("😂 Comedy Shows", use_container_width=True, type="primary"):
            st.session_state.current_step = "comedy_booking"
            st.rerun()
    
    with col3:
        st.markdown("""
        <div style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); padding: 20px; border-radius: 10px; text-align: center; margin: 10px 0;">
            <h3 style="color: white; margin: 0;">🎵 CONCERTS</h3>
            <p style="color: white; margin: 5px 0;">15 Live Concerts</p>
            <p style="color: white; margin: 5px 0;">Top Artists</p>
        </div>
        """, unsafe_allow_html=True)
        if st.button("🎵 Concerts", use_container_width=True, type="primary"):
            st.session_state.current_step = "concert_booking"
            st.rerun()
    
    st.write("---")
    
    # Enhanced statistics display
    st.write("### 📊 Entertainment Statistics")
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        st.metric("🎬 Movies", "40", "4 Moods")
    with col2:
        st.metric("😂 Comedy Shows", "15", "Top Comedians")
    with col3:
        st.metric("🎵 Concerts", "15", "Live Artists")
    with col4:
        st.metric("🏢 Theaters", "56", "8 Areas")
    
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
    
    # Navigation based on current step
    if st.session_state.current_step == "database_setup":
        database_setup()
    elif st.session_state.current_step == "login":
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
    elif st.session_state.current_step == "comedy_booking":
        comedy_booking()
    elif st.session_state.current_step == "concert_booking":
        concert_booking()
    else:
        # Default to login if no valid step
        st.session_state.current_step = "login"
        st.rerun()

# Enhanced Movie Booking Functions (Placeholder - would need full implementation)
def movie_booking():
    """Enhanced movie booking interface with mood-based filtering"""
    st.title("🎬 MOVIES")
    cursor = st.session_state.cursor
    
    # Get user's area
    cursor.execute("SELECT area FROM users WHERE email = %s", (st.session_state.logged_in_user,))
    user_result = cursor.fetchone()
    user_area = user_result['area'] if user_result else 'Satellite'
    
    st.info(f"📍 Your Area: **{user_area}** | Each movie shows in 3 specific theaters")
    
    # Back button
    if st.button("← Back to Entertainment Selection"):
        if 'movie_mood' in st.session_state:
            del st.session_state.movie_mood
        st.session_state.current_step = "main_menu"
        st.rerun()
    
    # Step 1: Select mood
    if 'movie_mood' not in st.session_state:
        st.session_state.movie_mood = None
    
    if not st.session_state.movie_mood:
        st.write("### 🎭 Choose Your Mood")
        
        # Enhanced mood selection with attractive cards
        col1, col2 = st.columns(2)
        with col1:
            st.markdown("""
            <div style="background: linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%); padding: 15px; border-radius: 10px; text-align: center; margin: 5px;">
                <h4 style="color: #333; margin: 0;">💕 ROMANTIC</h4>
                <p style="color: #666; margin: 5px 0;">Love Stories & Romance</p>
            </div>
            """, unsafe_allow_html=True)
            if st.button("💕 Romantic", use_container_width=True):
                st.session_state.movie_mood = "Romantic"
                st.rerun()
            
            st.markdown("""
            <div style="background: linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%); padding: 15px; border-radius: 10px; text-align: center; margin: 5px;">
                <h4 style="color: #333; margin: 0;">😂 COMEDY</h4>
                <p style="color: #666; margin: 5px 0;">Laughter & Fun</p>
            </div>
            """, unsafe_allow_html=True)
            if st.button("😂 Comedy", use_container_width=True):
                st.session_state.movie_mood = "Comedy"
                st.rerun()
        
        with col2:
            st.markdown("""
            <div style="background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%); padding: 15px; border-radius: 10px; text-align: center; margin: 5px;">
                <h4 style="color: #333; margin: 0;">💥 ACTION</h4>
                <p style="color: #666; margin: 5px 0;">Thrill & Adventure</p>
            </div>
            """, unsafe_allow_html=True)
            if st.button("💥 Action", use_container_width=True):
                st.session_state.movie_mood = "Action"
                st.rerun()
            
            st.markdown("""
            <div style="background: linear-gradient(135deg, #d299c2 0%, #fef9d7 100%); padding: 15px; border-radius: 10px; text-align: center; margin: 5px;">
                <h4 style="color: #333; margin: 0;">👨‍👩‍👧‍👦 FAMILY</h4>
                <p style="color: #666; margin: 5px 0;">For Everyone</p>
            </div>
            """, unsafe_allow_html=True)
            if st.button("👨‍👩‍👧‍👦 Family", use_container_width=True):
                st.session_state.movie_mood = "Family"
                st.rerun()
        return
    
    # Step 2: Show movies based on mood with enhanced display
    st.write(f"## {st.session_state.movie_mood.upper()} MOVIES")
    cursor.execute("""
        SELECT id, movie_name, duration_minutes, rating, language 
        FROM movies WHERE mood = %s
    """, (st.session_state.movie_mood,))
    movies = cursor.fetchall()
    
    # Display movies in an enhanced grid with posters
    cols = st.columns(2)
    for i, movie in enumerate(movies):
        with cols[i % 2]:
            # Create an attractive movie card
            poster_url = MOVIE_POSTERS.get(movie['id'], "https://via.placeholder.com/300x450/333/fff?text=No+Image")
            
            with st.container():
                col_img, col_info = st.columns([1, 2])
                
                with col_img:
                    st.image(poster_url, width=150)
                
                with col_info:
                    st.write(f"### {movie['movie_name']}")
                    st.write(f"⏱️ Duration: {movie['duration_minutes']} min")
                    st.write(f"⭐ Rating: {movie['rating']}")
                    st.write(f"🗣️ Language: {movie['language']}")
                    
                    # Get specific theaters for this movie
                    specific_theaters = get_movie_specific_theaters(movie['id'], user_area, cursor)
                    st.write(f"🏢 Available in {len(specific_theaters)} theaters")
                    
                    if st.button("🎫 Book Now", key=f"book_movie_{movie['id']}", type="primary"):
                        st.info("🚧 Movie booking flow would continue here...")
                        st.write("Next steps would be:")
                        st.write("1. Theater selection")
                        st.write("2. Date & time selection")
                        st.write("3. Seat selection")
                        st.write("4. Payment")
            
            st.write("---")
    
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

# Enhanced Comedy Booking Functions
def comedy_booking():
    """Enhanced comedy show booking interface with 15 shows"""
    st.title("😂 COMEDY SHOWS - 15 AMAZING COMEDIANS")
    
    if st.button("← Back to Entertainment Selection"):
        st.session_state.current_step = "main_menu"
        st.rerun()
    
    cursor = st.session_state.cursor
    cursor.execute("""
        SELECT show_id, comedian_name, show_title, show_type, duration_minutes, 
               language, age_rating, description, ticket_price
        FROM comedy_shows ORDER BY comedian_name
    """)
    shows = cursor.fetchall()
    
    st.write("### 🎭 Live Stand-up Comedy Shows")
    st.info(f"🎪 Book tickets for hilarious live performances by {len(shows)} top comedians!")
    
    # Enhanced display with attractive cards
    for show in shows:
        with st.container():
            col1, col2, col3 = st.columns([1, 2, 1])
            
            with col1:
                # Comedy show poster
                poster_url = COMEDY_POSTERS.get(show['show_id'], "https://via.placeholder.com/300x450/333/fff?text=Comedy+Show")
                st.image(poster_url, width=150)
            
            with col2:
                st.write(f"### 🎤 {show['comedian_name']}")
                st.write(f"**Show:** {show['show_title']}")
                st.write(f"**Duration:** {show['duration_minutes']} minutes")
                st.write(f"**Language:** {show['language']}")
                st.write(f"**Age Rating:** {show['age_rating']}")
                st.write(f"**Description:** {show['description']}")
            
            with col3:
                st.markdown(f"""
                <div style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); padding: 15px; border-radius: 10px; text-align: center; color: white; margin: 10px 0;">
                    <h3 style="margin: 0;">₹{show['ticket_price']}</h3>
                    <p style="margin: 0;">per ticket</p>
                </div>
                """, unsafe_allow_html=True)
                
                if st.button("🎫 Book Now", key=f"book_comedy_{show['show_id']}", type="primary"):
                    st.info("🚧 Comedy booking flow would continue here...")
                    st.write("Next steps would be:")
                    st.write("1. Venue selection")
                    st.write("2. Date & time selection")
                    st.write("3. Ticket quantity selection")
                    st.write("4. Payment")
            
            st.write("---")

# Enhanced Concert Booking Functions
def concert_booking():
    """Enhanced concert booking interface with 15 concerts"""
    st.title("🎵 CONCERTS - 15 AMAZING ARTISTS")
    
    if st.button("← Back to Entertainment Selection"):
        st.session_state.current_step = "main_menu"
        st.rerun()
    
    cursor = st.session_state.cursor
    cursor.execute("""
        SELECT concert_id, artist_name, concert_title, genre, duration_minutes, 
               language, ticket_price, description, special_guests
        FROM concerts ORDER BY artist_name
    """)
    concerts = cursor.fetchall()
    
    st.write("### 🎤 Live Music Concerts")
    st.info(f"🎶 Book tickets for amazing live performances by {len(concerts)} top artists!")
    
    # Enhanced display with attractive cards
    for concert in concerts:
        with st.container():
            col1, col2, col3 = st.columns([1, 2, 1])
            
            with col1:
                # Concert poster
                poster_url = CONCERT_POSTERS.get(concert['concert_id'], "https://via.placeholder.com/300x450/333/fff?text=Concert")
                st.image(poster_url, width=150)
            
            with col2:
                st.write(f"### 🎤 {concert['artist_name']}")
                st.write(f"**Concert:** {concert['concert_title']}")
                st.write(f"**Genre:** {concert['genre']}")
                st.write(f"**Duration:** {concert['duration_minutes']} minutes")
                st.write(f"**Language:** {concert['language']}")
                if concert['special_guests']:
                    st.write(f"**Special Guests:** {concert['special_guests']}")
                st.write(f"**Description:** {concert['description']}")
            
            with col3:
                st.markdown(f"""
                <div style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); padding: 15px; border-radius: 10px; text-align: center; color: white; margin: 10px 0;">
                    <h3 style="margin: 0;">₹{concert['ticket_price']}</h3>
                    <p style="margin: 0;">per ticket</p>
                </div>
                """, unsafe_allow_html=True)
                
                if st.button("🎫 Book Now", key=f"book_concert_{concert['concert_id']}", type="primary"):
                    st.info("🚧 Concert booking flow would continue here...")
                    st.write("Next steps would be:")
                    st.write("1. Venue selection")
                    st.write("2. Date & time selection")
                    st.write("3. Ticket quantity selection")
                    st.write("4. Payment")
            
            st.write("---")

if __name__ == "__main__":
    main()
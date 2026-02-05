# SmartShow Ultimate - Complete Entertainment Booking System - ENHANCED FINAL VERSION
# Movies, Comedy Shows, Concerts with PostgreSQL and Streamlit
# 🎯 ALL FEATURES: Area-wise theaters, movie-specific theaters, seat management, profit analytics

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
    page_title="SmartShow Ultimate - Enhanced",
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

# Movie Posters - Enhanced with more attractive images
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

COMEDY_POSTERS = {
    1: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=450&fit=crop",  # Kapil Sharma
    2: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300&h=450&fit=crop",  # Zakir Khan
    3: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&h=450&fit=crop",  # Biswa
    4: "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=300&h=450&fit=crop",  # Kenny Sebastian
    5: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=300&h=450&fit=crop"   # Abhishek Upmanyu
}

CONCERT_POSTERS = {
    1: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=450&fit=crop",  # Arijit Singh
    2: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300&h=450&fit=crop",  # AR Rahman
    3: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=450&fit=crop",  # Nucleya
    4: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=450&fit=crop",  # Rahat Fateh Ali Khan
    5: "https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=300&h=450&fit=crop"   # Sunidhi Chauhan
}

# Enhanced Areas List - 8 areas with 7 theaters each
AREAS = [
    'Satellite', 'Vastrapur', 'Paldi', 'Thaltej', 
    'Bopal', 'Maninagar', 'Naranpura', 'Chandkheda'
]

# Movie-specific theater mapping (each movie gets 3 specific theaters from user's area)
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
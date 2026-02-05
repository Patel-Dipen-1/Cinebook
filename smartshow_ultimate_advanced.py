# SmartShow Ultimate - Advanced Entertainment Booking System
# Complete implementation using all Python concepts

import streamlit as st
import psycopg2
from psycopg2.extras import RealDictCursor
import psycopg2.errors
import random
import json
import time
import os
import pickle
import csv
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple, Union
from dataclasses import dataclass, field
from abc import ABC, abstractmethod
from enum import Enum
import numpy as np
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from pathlib import Path
import logging
from contextlib import contextmanager

# =====================================================
# 1. FUNCTIONS, SCOPING AND ABSTRACTION
# =====================================================

# Global configuration
CONFIG = {
    'DB_HOST': 'localhost',
    'DB_PORT': 5432,
    'DB_USER': 'postgres',
    'MAX_SEATS_PER_BOOKING': 10,
    'OTP_EXPIRY_MINUTES': 10,
    'PAYMENT_SUCCESS_RATE': 0.9
}

def setup_logging() -> logging.Logger:
    """Setup logging configuration"""
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler('smartshow.log'),
            logging.StreamHandler()
        ]
    )
    return logging.getLogger(__name__)

logger = setup_logging()

# Higher-order functions and closures
def create_validator(min_length: int, max_length: int):
    """Factory function that creates validators with specific constraints"""
    def validator(value: str) -> bool:
        return min_length <= len(value) <= max_length
    return validator

def memoize(func):
    """Decorator for memoization"""
    cache = {}
    def wrapper(*args, **kwargs):
        key = str(args) + str(sorted(kwargs.items()))
        if key not in cache:
            cache[key] = func(*args, **kwargs)
        return cache[key]
    return wrapper

# Validation functions with proper scoping
email_validator = create_validator(10, 100)
password_validator = create_validator(5, 10)

def validate_email(email: str) -> bool:
    """Enhanced email validation using closure"""
    if " " in email or not email_validator(email):
        return False
    return email.endswith("@gmail.com")

def validate_password(password: str) -> bool:
    """Password validation with multiple criteria"""
    if not password_validator(password):
        return False
    return (any(c.isupper() for c in password) and 
            any(c.islower() for c in password) and 
            any(c.isdigit() for c in password) and 
            "@" in password)

@memoize
def calculate_show_times(movie_id: int) -> List[str]:
    """Memoized function to calculate show times"""
    base_times = {
        'romantic': ["2:00 PM", "5:30 PM", "8:45 PM"],
        'action': ["12:30 PM", "4:00 PM", "7:30 PM", "10:45 PM"],
        'comedy': ["1:30 PM", "4:30 PM", "7:00 PM", "9:30 PM"],
        'family': ["11:00 AM", "2:30 PM", "6:00 PM", "9:00 PM"]
    }
    
    if 1 <= movie_id <= 10:
        category = 'romantic'
    elif 11 <= movie_id <= 20:
        category = 'action'
    elif 21 <= movie_id <= 30:
        category = 'comedy'
    else:
        category = 'family'
    
    # Add variation based on movie_id
    times = base_times[category].copy()
    offset = (movie_id - 1) % 4 * 15  # 15-minute offset
    
    adjusted_times = []
    for time_str in times:
        hour, minute_period = time_str.split(':')
        minute, period = minute_period.split(' ')
        
        total_minutes = int(hour) * 60 + int(minute) + offset
        if period == 'PM' and int(hour) != 12:
            total_minutes += 12 * 60
        elif period == 'AM' and int(hour) == 12:
            total_minutes -= 12 * 60
            
        new_hour = (total_minutes // 60) % 24
        new_minute = total_minutes % 60
        
        if new_hour == 0:
            display_hour, period = 12, 'AM'
        elif new_hour < 12:
            display_hour, period = new_hour, 'AM'
        elif new_hour == 12:
            display_hour, period = 12, 'PM'
        else:
            display_hour, period = new_hour - 12, 'PM'
            
        adjusted_times.append(f"{display_hour}:{new_minute:02d} {period}")
    
    return adjusted_times

# =====================================================
# 2. IMMUTABLE AND MUTABLE DATA STRUCTURES
# =====================================================

# Immutable data structures using tuples and frozensets
AREAS = frozenset(['Satellite', 'Vastrapur', 'Paldi', 'Thaltej', 'Bopal', 
                   'Maninagar', 'Naranpura', 'Chandkheda'])

MOVIE_MOODS = ('Romantic', 'Action', 'Comedy', 'Family')

PAYMENT_METHODS = frozenset(['UPI', 'Credit/Debit Card', 'Net Banking'])

# Mutable data structures for dynamic content
theatre_cache = {}
booking_history = []
user_sessions = {}

class ImmutableConfig:
    """Immutable configuration class"""
    def __init__(self, **kwargs):
        for key, value in kwargs.items():
            object.__setattr__(self, key, value)
        self._frozen = True
    
    def __setattr__(self, key, value):
        if hasattr(self, '_frozen') and self._frozen:
            raise AttributeError(f"Cannot modify immutable config: {key}")
        object.__setattr__(self, key, value)

# Theatre configuration (immutable)
THEATRE_CONFIG = ImmutableConfig(
    SEATS_PER_ROW={'A': 30, 'B': 35, 'C': 30, 'D': 15, 'E': 10},
    PRICE_MULTIPLIERS={'A': 1.5, 'B': 1.2, 'C': 1.0, 'D': 0.8, 'E': 0.7},
    BASE_PRICES=tuple(range(250, 400, 25))
)

# =====================================================
# 3. WORKING WITH FILES
# =====================================================

class FileManager:
    """File operations manager with context management"""
    
    def __init__(self, base_path: str = "."):
        self.base_path = Path(base_path)
        self.base_path.mkdir(exist_ok=True)
    
    @contextmanager
    def open_file(self, filename: str, mode: str = 'r'):
        """Context manager for file operations"""
        file_path = self.base_path / filename
        try:
            file_handle = open(file_path, mode, encoding='utf-8')
            yield file_handle
        finally:
            if 'file_handle' in locals():
                file_handle.close()
    
    def write_ticket(self, booking_data: Dict, event_type: str) -> bool:
        """Write ticket to appropriate file"""
        filename = f"{event_type}_tickets.txt"
        try:
            with self.open_file(filename, 'a') as f:
                f.write(self._format_ticket(booking_data))
            return True
        except Exception as e:
            logger.error(f"Error writing ticket: {e}")
            return False
    
    def _format_ticket(self, booking_data: Dict) -> str:
        """Format ticket information"""
        return f"""
{'='*60}
SMARTSHOW ULTIMATE - TICKET CONFIRMATION
{'='*60}
Booking ID: {booking_data.get('booking_id', 'N/A')}
Event: {booking_data.get('event_name', 'N/A')}
Venue: {booking_data.get('venue_name', 'N/A')}
Date: {booking_data.get('show_date', 'N/A')}
Time: {booking_data.get('show_time', 'N/A')}
Seats: {booking_data.get('booked_seats', 'N/A')}
Amount: ₹{booking_data.get('total_amount', 'N/A')}
{'='*60}

"""
    
    def save_user_data(self, user_data: Dict) -> None:
        """Save user data to pickle file"""
        with self.open_file('user_data.pkl', 'wb') as f:
            pickle.dump(user_data, f)
    
    def load_user_data(self) -> Dict:
        """Load user data from pickle file"""
        try:
            with self.open_file('user_data.pkl', 'rb') as f:
                return pickle.load(f)
        except FileNotFoundError:
            return {}
    
    def export_bookings_csv(self, bookings: List[Dict]) -> str:
        """Export bookings to CSV file"""
        filename = f"bookings_export_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
        try:
            with self.open_file(filename, 'w', newline='') as f:
                if bookings:
                    writer = csv.DictWriter(f, fieldnames=bookings[0].keys())
                    writer.writeheader()
                    writer.writerows(bookings)
            return str(self.base_path / filename)
        except Exception as e:
            logger.error(f"Error exporting CSV: {e}")
            return ""

# Global file manager instance
file_manager = FileManager()

# =====================================================
# 4. MODULES AND DIRECTORIES
# =====================================================

# Database module
class DatabaseModule:
    """Database operations module"""
    
    def __init__(self):
        self.connection = None
        self.cursor = None
    
    def connect(self, password: str) -> bool:
        """Connect to database"""
        try:
            self.connection = psycopg2.connect(
                host=CONFIG['DB_HOST'],
                user=CONFIG['DB_USER'],
                password=password,
                database='cinebook',
                port=CONFIG['DB_PORT']
            )
            self.cursor = self.connection.cursor(cursor_factory=RealDictCursor)
            return True
        except Exception as e:
            logger.error(f"Database connection failed: {e}")
            return False
    
    def execute_query(self, query: str, params: Tuple = ()) -> Optional[List]:
        """Execute database query safely"""
        try:
            self.cursor.execute(query, params)
            if query.strip().upper().startswith('SELECT'):
                return self.cursor.fetchall()
            else:
                self.connection.commit()
                return None
        except Exception as e:
            logger.error(f"Query execution failed: {e}")
            self.connection.rollback()
            return None

# Utility module
class UtilityModule:
    """Utility functions module"""
    
    @staticmethod
    def generate_otp() -> str:
        """Generate 6-digit OTP"""
        return str(random.randint(100000, 999999))
    
    @staticmethod
    def generate_transaction_id() -> str:
        """Generate unique transaction ID"""
        return f"TXN{int(time.time())}{random.randint(1000, 9999)}"
    
    @staticmethod
    def get_next_dates(days: int = 3) -> List[Dict]:
        """Get next few dates for booking"""
        dates = []
        for i in range(days):
            date = datetime.now().date() + timedelta(days=i)
            dates.append({
                'date': date,
                'display': date.strftime('%a, %b %d')
            })
        return dates
    
    @staticmethod
    def calculate_profit_breakdown(total_amount: int) -> Dict[str, int]:
        """Calculate profit breakdown"""
        base_amount = int(total_amount / 1.18)
        gst_amount = total_amount - base_amount
        platform_fee = int(base_amount * 0.10)
        theatre_share = int(base_amount * 0.60)
        profit_amount = base_amount - platform_fee - theatre_share
        
        return {
            'base_amount': base_amount,
            'gst_amount': gst_amount,
            'platform_fee': platform_fee,
            'theatre_share': theatre_share,
            'profit_amount': profit_amount
        }

# =====================================================
# 5. OOP CONCEPTS AND EXCEPTION HANDLING
# =====================================================

class SmartShowException(Exception):
    """Base exception for SmartShow application"""
    pass

class DatabaseConnectionError(SmartShowException):
    """Database connection related errors"""
    pass

class ValidationError(SmartShowException):
    """Data validation errors"""
    pass

class BookingError(SmartShowException):
    """Booking related errors"""
    pass

class PaymentError(SmartShowException):
    """Payment processing errors"""
    pass

@dataclass
class User:
    """User data class"""
    name: str
    email: str
    area: str
    password: str = field(repr=False)
    otp: Optional[str] = field(default=None, repr=False)
    created_at: datetime = field(default_factory=datetime.now)
    
    def __post_init__(self):
        if not validate_email(self.email):
            raise ValidationError(f"Invalid email format: {self.email}")
        if not validate_password(self.password):
            raise ValidationError("Password does not meet requirements")

@dataclass
class Theatre:
    """Theatre data class"""
    id: int
    name: str
    area: str
    theatre_type: str
    base_price: int
    total_seats: int
    address: str
    
    def calculate_row_price(self, row: str) -> int:
        """Calculate price for specific row"""
        multiplier = THEATRE_CONFIG.PRICE_MULTIPLIERS.get(row, 1.0)
        return int(self.base_price * multiplier)

@dataclass
class Movie:
    """Movie data class"""
    id: int
    name: str
    mood: str
    duration: int
    rating: str
    language: str
    
    def get_show_times(self) -> List[str]:
        """Get show times for this movie"""
        return calculate_show_times(self.id)

@dataclass
class Booking:
    """Booking data class"""
    user_email: str
    event_type: str
    event_id: int
    event_name: str
    venue_id: int
    venue_name: str
    show_date: datetime.date
    show_time: str
    booked_seats: int
    total_amount: int
    seat_numbers: str
    row_details: str
    payment_method: str
    booking_id: Optional[int] = None
    transaction_id: Optional[str] = None
    profit_breakdown: Optional[Dict] = None
    
    def __post_init__(self):
        if self.booked_seats <= 0:
            raise BookingError("Number of seats must be positive")
        if self.total_amount <= 0:
            raise BookingError("Total amount must be positive")

# =====================================================
# 6. ADVANCED OOP CONCEPTS AND NUMPY
# =====================================================

class EventBookingStrategy(ABC):
    """Abstract base class for booking strategies"""
    
    @abstractmethod
    def calculate_pricing(self, base_price: int, seats: int) -> int:
        pass
    
    @abstractmethod
    def get_available_times(self) -> List[str]:
        pass

class MovieBookingStrategy(EventBookingStrategy):
    """Movie booking strategy implementation"""
    
    def __init__(self, movie: Movie):
        self.movie = movie
    
    def calculate_pricing(self, base_price: int, seats: int) -> int:
        # Use numpy for pricing calculations
        price_array = np.array([base_price] * seats)
        # Apply weekend surcharge using numpy
        if datetime.now().weekday() >= 5:  # Weekend
            price_array = price_array * 1.2
        return int(np.sum(price_array))
    
    def get_available_times(self) -> List[str]:
        return self.movie.get_show_times()

class ComedyBookingStrategy(EventBookingStrategy):
    """Comedy show booking strategy"""
    
    def calculate_pricing(self, base_price: int, seats: int) -> int:
        # Flat pricing for comedy shows
        return base_price * seats
    
    def get_available_times(self) -> List[str]:
        return ["6:00 PM", "8:30 PM"]

class ConcertBookingStrategy(EventBookingStrategy):
    """Concert booking strategy"""
    
    def calculate_pricing(self, base_price: int, seats: int) -> int:
        # Premium pricing for concerts
        price_matrix = np.array([[base_price * 1.5] * seats])
        return int(np.sum(price_matrix))
    
    def get_available_times(self) -> List[str]:
        return ["7:00 PM", "9:30 PM"]

class BookingContext:
    """Context class for booking strategies"""
    
    def __init__(self, strategy: EventBookingStrategy):
        self._strategy = strategy
    
    def set_strategy(self, strategy: EventBookingStrategy):
        self._strategy = strategy
    
    def calculate_total_price(self, base_price: int, seats: int) -> int:
        return self._strategy.calculate_pricing(base_price, seats)
    
    def get_show_times(self) -> List[str]:
        return self._strategy.get_available_times()

class EventType(Enum):
    """Event type enumeration"""
    MOVIE = "movie"
    COMEDY = "comedy"
    CONCERT = "concert"

class BookingFactory:
    """Factory pattern for creating bookings"""
    
    @staticmethod
    def create_booking_strategy(event_type: EventType, event_data: Dict) -> EventBookingStrategy:
        """Factory method to create appropriate booking strategy"""
        if event_type == EventType.MOVIE:
            movie = Movie(**event_data)
            return MovieBookingStrategy(movie)
        elif event_type == EventType.COMEDY:
            return ComedyBookingStrategy()
        elif event_type == EventType.CONCERT:
            return ConcertBookingStrategy()
        else:
            raise ValueError(f"Unknown event type: {event_type}")

class BookingManager:
    """Singleton pattern for booking management"""
    
    _instance = None
    _initialized = False
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def __init__(self):
        if not self._initialized:
            self.bookings = []
            self.db = DatabaseModule()
            self.utils = UtilityModule()
            self._initialized = True
    
    def process_booking(self, booking_data: Dict, event_type: EventType) -> Tuple[bool, str]:
        """Process booking with error handling"""
        try:
            # Create booking strategy
            strategy = BookingFactory.create_booking_strategy(event_type, booking_data)
            context = BookingContext(strategy)
            
            # Calculate pricing using numpy
            base_price = booking_data.get('base_price', 300)
            seats = booking_data.get('seats', 1)
            total_price = context.calculate_total_price(base_price, seats)
            
            # Create booking object
            booking = Booking(
                user_email=booking_data['user_email'],
                event_type=event_type.value,
                event_id=booking_data['event_id'],
                event_name=booking_data['event_name'],
                venue_id=booking_data['venue_id'],
                venue_name=booking_data['venue_name'],
                show_date=booking_data['show_date'],
                show_time=booking_data['show_time'],
                booked_seats=seats,
                total_amount=total_price,
                seat_numbers=booking_data.get('seat_numbers', ''),
                row_details=booking_data.get('row_details', ''),
                payment_method=booking_data.get('payment_method', 'UPI'),
                transaction_id=self.utils.generate_transaction_id()
            )
            
            # Calculate profit breakdown
            booking.profit_breakdown = self.utils.calculate_profit_breakdown(total_price)
            
            # Save booking
            self.bookings.append(booking)
            
            # Write ticket to file
            file_manager.write_ticket(booking.__dict__, event_type.value)
            
            return True, booking.transaction_id
            
        except (ValidationError, BookingError) as e:
            logger.error(f"Booking validation error: {e}")
            return False, str(e)
        except Exception as e:
            logger.error(f"Unexpected booking error: {e}")
            return False, "Booking failed due to system error"

# =====================================================
# 7. VISUALIZATION AND STREAMLIT
# =====================================================

class DataVisualizer:
    """Data visualization class using plotly and numpy"""
    
    @staticmethod
    def create_revenue_chart(bookings_data: List[Dict]) -> go.Figure:
        """Create revenue visualization using numpy for calculations"""
        if not bookings_data:
            return go.Figure()
        
        # Convert to numpy arrays for efficient processing
        df = pd.DataFrame(bookings_data)
        
        # Group by event type and calculate totals
        revenue_by_type = df.groupby('event_type')['total_amount'].sum()
        
        # Create pie chart
        fig = px.pie(
            values=revenue_by_type.values,
            names=revenue_by_type.index,
            title="Revenue Distribution by Event Type"
        )
        
        return fig
    
    @staticmethod
    def create_profit_analysis(profit_data: Dict) -> go.Figure:
        """Create profit analysis chart"""
        categories = list(profit_data.keys())
        values = list(profit_data.values())
        
        # Use numpy for percentage calculations
        total = np.sum(values)
        percentages = np.round((np.array(values) / total) * 100, 1)
        
        fig = go.Figure(data=[
            go.Bar(
                x=categories,
                y=values,
                text=[f"₹{v:,} ({p}%)" for v, p in zip(values, percentages)],
                textposition='auto'
            )
        ])
        
        fig.update_layout(
            title="Profit Breakdown Analysis",
            xaxis_title="Categories",
            yaxis_title="Amount (₹)"
        )
        
        return fig
    
    @staticmethod
    def create_booking_trends(bookings_data: List[Dict]) -> go.Figure:
        """Create booking trends over time"""
        if not bookings_data:
            return go.Figure()
        
        df = pd.DataFrame(bookings_data)
        df['booking_date'] = pd.to_datetime(df['booking_date'])
        
        # Group by date and count bookings
        daily_bookings = df.groupby(df['booking_date'].dt.date).size()
        
        fig = px.line(
            x=daily_bookings.index,
            y=daily_bookings.values,
            title="Daily Booking Trends"
        )
        
        return fig

class StreamlitUI:
    """Streamlit UI management class"""
    
    def __init__(self):
        self.booking_manager = BookingManager()
        self.visualizer = DataVisualizer()
        self.setup_page_config()
        self.initialize_session_state()
    
    def setup_page_config(self):
        """Setup Streamlit page configuration"""
        st.set_page_config(
            page_title="SmartShow Ultimate - Advanced",
            page_icon="🎬",
            layout="wide",
            initial_sidebar_state="expanded"
        )
    
    def initialize_session_state(self):
        """Initialize session state variables"""
        default_states = {
            'logged_in_user': None,
            'admin_logged_in': None,
            'db_password': None,
            'current_step': 'database_setup',
            'db_ready': False,
            'selected_movie': None,
            'selected_theatre': None,
            'booking_details': None
        }
        
        for key, default_value in default_states.items():
            if key not in st.session_state:
                st.session_state[key] = default_value
    
    def show_main_dashboard(self):
        """Main dashboard with advanced visualizations"""
        st.title("🎬 SmartShow Ultimate - Advanced Analytics")
        
        # Sample data for demonstration (in real app, this would come from database)
        sample_bookings = [
            {'event_type': 'movie', 'total_amount': 1500, 'booking_date': datetime.now()},
            {'event_type': 'comedy', 'total_amount': 800, 'booking_date': datetime.now()},
            {'event_type': 'concert', 'total_amount': 2000, 'booking_date': datetime.now()}
        ]
        
        # Create visualizations
        col1, col2 = st.columns(2)
        
        with col1:
            revenue_chart = self.visualizer.create_revenue_chart(sample_bookings)
            st.plotly_chart(revenue_chart, use_container_width=True)
        
        with col2:
            profit_data = {
                'Our Profit': 500,
                'Theatre Share': 1200,
                'Platform Fee': 200,
                'GST': 300
            }
            profit_chart = self.visualizer.create_profit_analysis(profit_data)
            st.plotly_chart(profit_chart, use_container_width=True)
        
        # Booking trends
        trends_chart = self.visualizer.create_booking_trends(sample_bookings)
        st.plotly_chart(trends_chart, use_container_width=True)
        
        # Advanced metrics using numpy
        self.show_advanced_metrics()
    
    def show_advanced_metrics(self):
        """Show advanced metrics using numpy calculations"""
        st.subheader("📊 Advanced Analytics")
        
        # Generate sample data using numpy
        np.random.seed(42)
        revenue_data = np.random.normal(1000, 200, 30)  # 30 days of revenue data
        
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            avg_revenue = np.mean(revenue_data)
            st.metric("Average Daily Revenue", f"₹{avg_revenue:,.0f}")
        
        with col2:
            std_revenue = np.std(revenue_data)
            st.metric("Revenue Std Dev", f"₹{std_revenue:,.0f}")
        
        with col3:
            max_revenue = np.max(revenue_data)
            st.metric("Peak Revenue", f"₹{max_revenue:,.0f}")
        
        with col4:
            growth_rate = np.polyfit(range(len(revenue_data)), revenue_data, 1)[0]
            st.metric("Growth Rate", f"₹{growth_rate:,.0f}/day")
    
    def run(self):
        """Main application runner"""
        try:
            if st.session_state.current_step == 'database_setup':
                self.show_database_setup()
            elif st.session_state.current_step == 'main_dashboard':
                self.show_main_dashboard()
            else:
                self.show_main_dashboard()
        except Exception as e:
            st.error(f"Application error: {e}")
            logger.error(f"Application error: {e}")
    
    def show_database_setup(self):
        """Database setup interface"""
        st.title("🔧 Database Setup")
        
        password = st.text_input("PostgreSQL Password:", type="password")
        
        if password:
            col1, col2 = st.columns(2)
            
            with col1:
                if st.button("Connect to Database"):
                    try:
                        db = DatabaseModule()
                        if db.connect(password):
                            st.success("✅ Connected successfully!")
                            st.session_state.db_ready = True
                            st.session_state.current_step = 'main_dashboard'
                            st.rerun()
                        else:
                            st.error("❌ Connection failed!")
                    except DatabaseConnectionError as e:
                        st.error(f"Database error: {e}")
            
            with col2:
                if st.button("Skip to Demo"):
                    st.session_state.current_step = 'main_dashboard'
                    st.rerun()

# =====================================================
# MAIN APPLICATION
# =====================================================

def main():
    """Main application entry point"""
    try:
        # Initialize and run the Streamlit UI
        app = StreamlitUI()
        app.run()
        
    except Exception as e:
        st.error(f"Critical application error: {e}")
        logger.critical(f"Critical application error: {e}")

if __name__ == "__main__":
    main()
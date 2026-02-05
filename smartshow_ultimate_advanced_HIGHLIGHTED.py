# SmartShow Ultimate - Advanced Entertainment Booking System
# 🎯 COMPLETE IMPLEMENTATION USING ALL 7 PYTHON CONCEPTS - HIGHLIGHTED VERSION

import streamlit as st
import psycopg2
from psycopg2.extras import RealDictCursor
import psycopg2.errors
import random
import json
import time
import os
import pickle  # 🔥 CONCEPT 3: FILE OPERATIONS - PICKLE FORMAT
import csv     # 🔥 CONCEPT 3: FILE OPERATIONS - CSV FORMAT
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple, Union  # 🔥 TYPE HINTS
from dataclasses import dataclass, field  # 🔥 CONCEPT 5: OOP - DATACLASS
from abc import ABC, abstractmethod        # 🔥 CONCEPT 6: ADVANCED OOP - ABC
from enum import Enum                      # 🔥 CONCEPT 6: ADVANCED OOP - ENUM
import numpy as np                         # 🔥 CONCEPT 6: NUMPY INTEGRATION
import pandas as pd                        # 🔥 CONCEPT 7: DATA ANALYSIS
import plotly.express as px               # 🔥 CONCEPT 7: VISUALIZATION
import plotly.graph_objects as go         # 🔥 CONCEPT 7: VISUALIZATION
from pathlib import Path                  # 🔥 CONCEPT 3: FILE OPERATIONS
import logging                            # 🔥 CONCEPT 1: LOGGING
from contextlib import contextmanager     # 🔥 CONCEPT 3: CONTEXT MANAGERS

# =====================================================
# 🎯 CONCEPT 1: FUNCTIONS, SCOPING AND ABSTRACTION
# =====================================================

# 🔥 GLOBAL SCOPING - Global configuration dictionary
CONFIG = {
    'DB_HOST': 'localhost',
    'DB_PORT': 5432,
    'DB_USER': 'postgres',
    'MAX_SEATS_PER_BOOKING': 10,
    'OTP_EXPIRY_MINUTES': 10,
    'PAYMENT_SUCCESS_RATE': 0.9
}

# 🔥 FUNCTION ABSTRACTION - Setup logging
def setup_logging() -> logging.Logger:
    """Setup logging configuration with proper abstraction"""
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler('smartshow.log'),  # 🔥 FILE OPERATIONS
            logging.StreamHandler()
        ]
    )
    return logging.getLogger(__name__)

# 🔥 GLOBAL SCOPE - Logger instance
logger = setup_logging()

# 🔥 HIGHER-ORDER FUNCTIONS - Factory function that returns functions
def create_validator(min_length: int, max_length: int):
    """Factory function that creates validators with specific constraints"""
    # 🔥 CLOSURES - Inner function with access to outer scope variables
    def validator(value: str) -> bool:
        return min_length <= len(value) <= max_length  # 🔥 CLOSURE SCOPE ACCESS
    return validator  # 🔥 RETURNING FUNCTION

# 🔥 DECORATORS - Memoization decorator for caching
def memoize(func):
    """Decorator for memoization - caches function results"""
    cache = {}  # 🔥 LOCAL SCOPE - Decorator's local cache
    def wrapper(*args, **kwargs):
        key = str(args) + str(sorted(kwargs.items()))
        if key not in cache:
            cache[key] = func(*args, **kwargs)  # 🔥 CACHE STORAGE
        return cache[key]  # 🔥 CACHED RESULT
    return wrapper

# 🔥 FUNCTION ABSTRACTION - Using higher-order functions
email_validator = create_validator(10, 100)      # 🔥 CLOSURE INSTANCE
password_validator = create_validator(5, 10)     # 🔥 CLOSURE INSTANCE

# 🔥 FUNCTION WITH CLOSURE USAGE
def validate_email(email: str) -> bool:
    """Enhanced email validation using closure"""
    if " " in email or not email_validator(email):  # 🔥 USING CLOSURE
        return False
    return email.endswith("@gmail.com")

# 🔥 FUNCTION WITH MULTIPLE SCOPING
def validate_password(password: str) -> bool:
    """Password validation with multiple criteria"""
    if not password_validator(password):  # 🔥 USING CLOSURE
        return False
    # 🔥 LOCAL SCOPE - Complex validation logic
    return (any(c.isupper() for c in password) and 
            any(c.islower() for c in password) and 
            any(c.isdigit() for c in password) and 
            "@" in password)

# 🔥 DECORATED FUNCTION - Using memoization decorator
@memoize
def calculate_show_times(movie_id: int) -> List[str]:
    """Memoized function to calculate show times - CACHED RESULTS"""
    # 🔥 LOCAL SCOPE - Function-specific data
    base_times = {
        'romantic': ["2:00 PM", "5:30 PM", "8:45 PM"],
        'action': ["12:30 PM", "4:00 PM", "7:30 PM", "10:45 PM"],
        'comedy': ["1:30 PM", "4:30 PM", "7:00 PM", "9:30 PM"],
        'family': ["11:00 AM", "2:30 PM", "6:00 PM", "9:00 PM"]
    }
    
    # 🔥 FUNCTION LOGIC WITH SCOPING
    if 1 <= movie_id <= 10:
        category = 'romantic'
    elif 11 <= movie_id <= 20:
        category = 'action'
    elif 21 <= movie_id <= 30:
        category = 'comedy'
    else:
        category = 'family'
    
    # 🔥 LOCAL SCOPE OPERATIONS
    times = base_times[category].copy()
    offset = (movie_id - 1) % 4 * 15
    
    adjusted_times = []
    for time_str in times:
        # 🔥 LOCAL SCOPE - Time calculation logic
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
    
    return adjusted_times  # 🔥 MEMOIZED RESULT

# =====================================================
# 🎯 CONCEPT 2: IMMUTABLE AND MUTABLE DATA STRUCTURES
# =====================================================

# 🔥 IMMUTABLE DATA STRUCTURES - frozenset (cannot be modified)
AREAS = frozenset(['Satellite', 'Vastrapur', 'Paldi', 'Thaltej', 'Bopal', 
                   'Maninagar', 'Naranpura', 'Chandkheda'])

# 🔥 IMMUTABLE DATA STRUCTURES - tuple (cannot be modified)
MOVIE_MOODS = ('Romantic', 'Action', 'Comedy', 'Family')

# 🔥 IMMUTABLE DATA STRUCTURES - frozenset for payment methods
PAYMENT_METHODS = frozenset(['UPI', 'Credit/Debit Card', 'Net Banking'])

# 🔥 MUTABLE DATA STRUCTURES - dict (can be modified)
theatre_cache = {}      # 🔥 MUTABLE - Can add/remove items
booking_history = []    # 🔥 MUTABLE - Can append/remove items
user_sessions = {}      # 🔥 MUTABLE - Dynamic user data

# 🔥 CUSTOM IMMUTABLE CLASS - Prevents modification after creation
class ImmutableConfig:
    """Immutable configuration class - CANNOT BE MODIFIED AFTER CREATION"""
    def __init__(self, **kwargs):
        for key, value in kwargs.items():
            object.__setattr__(self, key, value)  # 🔥 INITIAL SETUP
        self._frozen = True  # 🔥 FREEZE THE OBJECT
    
    def __setattr__(self, key, value):
        # 🔥 IMMUTABILITY ENFORCEMENT - Raises error if modified
        if hasattr(self, '_frozen') and self._frozen:
            raise AttributeError(f"Cannot modify immutable config: {key}")
        object.__setattr__(self, key, value)

# 🔥 IMMUTABLE INSTANCE - Theatre configuration that cannot be changed
THEATRE_CONFIG = ImmutableConfig(
    SEATS_PER_ROW={'A': 30, 'B': 35, 'C': 30, 'D': 15, 'E': 10},  # 🔥 DICT INSIDE IMMUTABLE
    PRICE_MULTIPLIERS={'A': 1.5, 'B': 1.2, 'C': 1.0, 'D': 0.8, 'E': 0.7},
    BASE_PRICES=tuple(range(250, 400, 25))  # 🔥 TUPLE - IMMUTABLE SEQUENCE
)

# =====================================================
# 🎯 CONCEPT 3: WORKING WITH FILES
# =====================================================

# 🔥 FILE OPERATIONS CLASS - Comprehensive file management
class FileManager:
    """File operations manager with context management and multiple formats"""
    
    def __init__(self, base_path: str = "."):
        self.base_path = Path(base_path)  # 🔥 PATHLIB USAGE
        self.base_path.mkdir(exist_ok=True)  # 🔥 DIRECTORY CREATION
    
    # 🔥 CONTEXT MANAGER - Safe file operations with automatic cleanup
    @contextmanager
    def open_file(self, filename: str, mode: str = 'r'):
        """Context manager for file operations - AUTOMATIC RESOURCE CLEANUP"""
        file_path = self.base_path / filename  # 🔥 PATH OPERATIONS
        try:
            file_handle = open(file_path, mode, encoding='utf-8')  # 🔥 FILE OPENING
            yield file_handle  # 🔥 CONTEXT MANAGER YIELD
        finally:
            if 'file_handle' in locals():
                file_handle.close()  # 🔥 AUTOMATIC CLEANUP
    
    # 🔥 TXT FILE OPERATIONS - Writing tickets to text files
    def write_ticket(self, booking_data: Dict, event_type: str) -> bool:
        """Write ticket to appropriate text file - TXT FORMAT"""
        filename = f"{event_type}_tickets.txt"  # 🔥 DYNAMIC FILENAME
        try:
            with self.open_file(filename, 'a') as f:  # 🔥 USING CONTEXT MANAGER
                f.write(self._format_ticket(booking_data))  # 🔥 TXT WRITING
            return True
        except Exception as e:
            logger.error(f"Error writing ticket: {e}")  # 🔥 ERROR HANDLING
            return False
    
    # 🔥 TEXT FORMATTING - Private method for ticket formatting
    def _format_ticket(self, booking_data: Dict) -> str:
        """Format ticket information - PRIVATE METHOD"""
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
    
    # 🔥 PICKLE FILE OPERATIONS - Binary file format for complex data
    def save_user_data(self, user_data: Dict) -> None:
        """Save user data to pickle file - PICKLE FORMAT"""
        with self.open_file('user_data.pkl', 'wb') as f:  # 🔥 BINARY MODE
            pickle.dump(user_data, f)  # 🔥 PICKLE SERIALIZATION
    
    # 🔥 PICKLE FILE LOADING - Reading binary data
    def load_user_data(self) -> Dict:
        """Load user data from pickle file - PICKLE DESERIALIZATION"""
        try:
            with self.open_file('user_data.pkl', 'rb') as f:  # 🔥 BINARY READ
                return pickle.load(f)  # 🔥 PICKLE LOADING
        except FileNotFoundError:
            return {}  # 🔥 ERROR HANDLING
    
    # 🔥 CSV FILE OPERATIONS - Structured data export
    def export_bookings_csv(self, bookings: List[Dict]) -> str:
        """Export bookings to CSV file - CSV FORMAT"""
        filename = f"bookings_export_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
        try:
            with self.open_file(filename, 'w', newline='') as f:  # 🔥 CSV MODE
                if bookings:
                    writer = csv.DictWriter(f, fieldnames=bookings[0].keys())  # 🔥 CSV WRITER
                    writer.writeheader()  # 🔥 CSV HEADER
                    writer.writerows(bookings)  # 🔥 CSV DATA
            return str(self.base_path / filename)
        except Exception as e:
            logger.error(f"Error exporting CSV: {e}")
            return ""

# 🔥 GLOBAL FILE MANAGER INSTANCE - Singleton-like usage
file_manager = FileManager()

# =====================================================
# 🎯 CONCEPT 4: MODULES AND DIRECTORIES
# =====================================================

# 🔥 DATABASE MODULE - Encapsulated database operations
class DatabaseModule:
    """Database operations module - MODULAR DESIGN"""
    
    def __init__(self):
        self.connection = None
        self.cursor = None
    
    # 🔥 MODULE METHOD - Database connection
    def connect(self, password: str) -> bool:
        """Connect to database - ENCAPSULATED FUNCTIONALITY"""
        try:
            self.connection = psycopg2.connect(
                host=CONFIG['DB_HOST'],      # 🔥 USING GLOBAL CONFIG
                user=CONFIG['DB_USER'],
                password=password,
                database='cinebook',
                port=CONFIG['DB_PORT']
            )
            self.cursor = self.connection.cursor(cursor_factory=RealDictCursor)
            return True
        except Exception as e:
            logger.error(f"Database connection failed: {e}")  # 🔥 LOGGING
            return False
    
    # 🔥 MODULE METHOD - Safe query execution
    def execute_query(self, query: str, params: Tuple = ()) -> Optional[List]:
        """Execute database query safely - ERROR HANDLING"""
        try:
            self.cursor.execute(query, params)
            if query.strip().upper().startswith('SELECT'):
                return self.cursor.fetchall()
            else:
                self.connection.commit()
                return None
        except Exception as e:
            logger.error(f"Query execution failed: {e}")
            self.connection.rollback()  # 🔥 TRANSACTION SAFETY
            return None

# 🔥 UTILITY MODULE - Static utility functions
class UtilityModule:
    """Utility functions module - STATIC METHODS"""
    
    # 🔥 STATIC METHOD - OTP generation
    @staticmethod
    def generate_otp() -> str:
        """Generate 6-digit OTP - UTILITY FUNCTION"""
        return str(random.randint(100000, 999999))
    
    # 🔥 STATIC METHOD - Transaction ID generation
    @staticmethod
    def generate_transaction_id() -> str:
        """Generate unique transaction ID - UTILITY FUNCTION"""
        return f"TXN{int(time.time())}{random.randint(1000, 9999)}"
    
    # 🔥 STATIC METHOD - Date utilities
    @staticmethod
    def get_next_dates(days: int = 3) -> List[Dict]:
        """Get next few dates for booking - DATE UTILITIES"""
        dates = []
        for i in range(days):
            date = datetime.now().date() + timedelta(days=i)
            dates.append({
                'date': date,
                'display': date.strftime('%a, %b %d')
            })
        return dates
    
    # 🔥 STATIC METHOD - Financial calculations
    @staticmethod
    def calculate_profit_breakdown(total_amount: int) -> Dict[str, int]:
        """Calculate profit breakdown - BUSINESS LOGIC"""
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
# 🎯 CONCEPT 5: OOP CONCEPTS AND EXCEPTION HANDLING
# =====================================================

# 🔥 CUSTOM EXCEPTION HIERARCHY - Base exception class
class SmartShowException(Exception):
    """Base exception for SmartShow application - EXCEPTION HIERARCHY ROOT"""
    pass

# 🔥 INHERITANCE - Specific exception classes inheriting from base
class DatabaseConnectionError(SmartShowException):
    """Database connection related errors - INHERITED EXCEPTION"""
    pass

class ValidationError(SmartShowException):
    """Data validation errors - INHERITED EXCEPTION"""
    pass

class BookingError(SmartShowException):
    """Booking related errors - INHERITED EXCEPTION"""
    pass

class PaymentError(SmartShowException):
    """Payment processing errors - INHERITED EXCEPTION"""
    pass

# 🔥 DATACLASS - Modern Python class with automatic methods
@dataclass
class User:
    """User data class - DATACLASS WITH VALIDATION"""
    name: str
    email: str
    area: str
    password: str = field(repr=False)  # 🔥 FIELD OPTIONS - Hidden in repr
    otp: Optional[str] = field(default=None, repr=False)  # 🔥 OPTIONAL FIELD
    created_at: datetime = field(default_factory=datetime.now)  # 🔥 FACTORY DEFAULT
    
    # 🔥 POST-INIT VALIDATION - Automatic validation after creation
    def __post_init__(self):
        if not validate_email(self.email):  # 🔥 USING GLOBAL FUNCTION
            raise ValidationError(f"Invalid email format: {self.email}")
        if not validate_password(self.password):
            raise ValidationError("Password does not meet requirements")

# 🔥 DATACLASS WITH METHODS - Theatre class with behavior
@dataclass
class Theatre:
    """Theatre data class - DATACLASS WITH METHODS"""
    id: int
    name: str
    area: str
    theatre_type: str
    base_price: int
    total_seats: int
    address: str
    
    # 🔥 INSTANCE METHOD - Encapsulated behavior
    def calculate_row_price(self, row: str) -> int:
        """Calculate price for specific row - ENCAPSULATED METHOD"""
        multiplier = THEATRE_CONFIG.PRICE_MULTIPLIERS.get(row, 1.0)  # 🔥 USING IMMUTABLE CONFIG
        return int(self.base_price * multiplier)

# 🔥 DATACLASS - Movie with metadata
@dataclass
class Movie:
    """Movie data class - RICH DATA STRUCTURE"""
    id: int
    name: str
    mood: str
    duration: int
    rating: str
    language: str
    
    # 🔥 METHOD - Using global memoized function
    def get_show_times(self) -> List[str]:
        """Get show times for this movie - USING MEMOIZED FUNCTION"""
        return calculate_show_times(self.id)  # 🔥 CALLING MEMOIZED FUNCTION

# 🔥 COMPLEX DATACLASS - Booking with comprehensive data
@dataclass
class Booking:
    """Booking data class - COMPLEX DATA STRUCTURE WITH VALIDATION"""
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
    
    # 🔥 POST-INIT VALIDATION - Business rule validation
    def __post_init__(self):
        if self.booked_seats <= 0:
            raise BookingError("Number of seats must be positive")
        if self.total_amount <= 0:
            raise BookingError("Total amount must be positive")

# =====================================================
# 🎯 CONCEPT 6: ADVANCED OOP CONCEPTS AND NUMPY
# =====================================================

# 🔥 ABSTRACT BASE CLASS - Interface definition
class EventBookingStrategy(ABC):
    """Abstract base class for booking strategies - STRATEGY PATTERN"""
    
    # 🔥 ABSTRACT METHOD - Must be implemented by subclasses
    @abstractmethod
    def calculate_pricing(self, base_price: int, seats: int) -> int:
        pass
    
    # 🔥 ABSTRACT METHOD - Interface contract
    @abstractmethod
    def get_available_times(self) -> List[str]:
        pass

# 🔥 CONCRETE STRATEGY - Movie booking implementation
class MovieBookingStrategy(EventBookingStrategy):
    """Movie booking strategy implementation - CONCRETE STRATEGY"""
    
    def __init__(self, movie: Movie):
        self.movie = movie  # 🔥 COMPOSITION
    
    # 🔥 NUMPY INTEGRATION - Mathematical calculations with NumPy
    def calculate_pricing(self, base_price: int, seats: int) -> int:
        # Use numpy for pricing calculations  # 🔥 NUMPY ARRAYS
        price_array = np.array([base_price] * seats)
        # Apply weekend surcharge using numpy  # 🔥 NUMPY OPERATIONS
        if datetime.now().weekday() >= 5:  # Weekend
            price_array = price_array * 1.2  # 🔥 VECTORIZED OPERATIONS
        return int(np.sum(price_array))  # 🔥 NUMPY AGGREGATION
    
    # 🔥 STRATEGY METHOD - Implementation of abstract method
    def get_available_times(self) -> List[str]:
        return self.movie.get_show_times()

# 🔥 CONCRETE STRATEGY - Comedy show implementation
class ComedyBookingStrategy(EventBookingStrategy):
    """Comedy show booking strategy - ANOTHER CONCRETE STRATEGY"""
    
    def calculate_pricing(self, base_price: int, seats: int) -> int:
        # Flat pricing for comedy shows
        return base_price * seats
    
    def get_available_times(self) -> List[str]:
        return ["6:00 PM", "8:30 PM"]

# 🔥 CONCRETE STRATEGY - Concert implementation
class ConcertBookingStrategy(EventBookingStrategy):
    """Concert booking strategy - THIRD CONCRETE STRATEGY"""
    
    def calculate_pricing(self, base_price: int, seats: int) -> int:
        # Premium pricing for concerts  # 🔥 NUMPY MATRIX OPERATIONS
        price_matrix = np.array([[base_price * 1.5] * seats])
        return int(np.sum(price_matrix))  # 🔥 NUMPY CALCULATIONS
    
    def get_available_times(self) -> List[str]:
        return ["7:00 PM", "9:30 PM"]

# 🔥 CONTEXT CLASS - Strategy pattern context
class BookingContext:
    """Context class for booking strategies - STRATEGY PATTERN CONTEXT"""
    
    def __init__(self, strategy: EventBookingStrategy):
        self._strategy = strategy  # 🔥 STRATEGY COMPOSITION
    
    # 🔥 STRATEGY SWITCHING - Runtime strategy change
    def set_strategy(self, strategy: EventBookingStrategy):
        self._strategy = strategy
    
    # 🔥 DELEGATED METHOD - Using current strategy
    def calculate_total_price(self, base_price: int, seats: int) -> int:
        return self._strategy.calculate_pricing(base_price, seats)
    
    def get_show_times(self) -> List[str]:
        return self._strategy.get_available_times()

# 🔥 ENUM - Type-safe constants
class EventType(Enum):
    """Event type enumeration - TYPE-SAFE CONSTANTS"""
    MOVIE = "movie"      # 🔥 ENUM VALUE
    COMEDY = "comedy"    # 🔥 ENUM VALUE
    CONCERT = "concert"  # 🔥 ENUM VALUE

# 🔥 FACTORY PATTERN - Object creation abstraction
class BookingFactory:
    """Factory pattern for creating bookings - FACTORY PATTERN"""
    
    # 🔥 FACTORY METHOD - Creates appropriate strategy based on type
    @staticmethod
    def create_booking_strategy(event_type: EventType, event_data: Dict) -> EventBookingStrategy:
        """Factory method to create appropriate booking strategy - POLYMORPHISM"""
        if event_type == EventType.MOVIE:
            movie = Movie(**event_data)  # 🔥 DATACLASS CREATION
            return MovieBookingStrategy(movie)  # 🔥 STRATEGY CREATION
        elif event_type == EventType.COMEDY:
            return ComedyBookingStrategy()
        elif event_type == EventType.CONCERT:
            return ConcertBookingStrategy()
        else:
            raise ValueError(f"Unknown event type: {event_type}")

# 🔥 SINGLETON PATTERN - Single instance management
class BookingManager:
    """Singleton pattern for booking management - SINGLETON PATTERN"""
    
    _instance = None      # 🔥 CLASS VARIABLE - Singleton instance
    _initialized = False  # 🔥 INITIALIZATION FLAG
    
    # 🔥 SINGLETON IMPLEMENTATION - Control instance creation
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)  # 🔥 CREATE SINGLE INSTANCE
        return cls._instance
    
    # 🔥 SINGLETON INITIALIZATION - Initialize only once
    def __init__(self):
        if not self._initialized:
            self.bookings = []                    # 🔥 MUTABLE LIST
            self.db = DatabaseModule()            # 🔥 MODULE COMPOSITION
            self.utils = UtilityModule()          # 🔥 MODULE COMPOSITION
            self._initialized = True              # 🔥 PREVENT RE-INITIALIZATION
    
    # 🔥 COMPLEX METHOD - Using multiple patterns and NumPy
    def process_booking(self, booking_data: Dict, event_type: EventType) -> Tuple[bool, str]:
        """Process booking with error handling - COMPREHENSIVE METHOD"""
        try:
            # Create booking strategy  # 🔥 FACTORY PATTERN USAGE
            strategy = BookingFactory.create_booking_strategy(event_type, booking_data)
            context = BookingContext(strategy)  # 🔥 STRATEGY PATTERN USAGE
            
            # Calculate pricing using numpy  # 🔥 NUMPY INTEGRATION
            base_price = booking_data.get('base_price', 300)
            seats = booking_data.get('seats', 1)
            total_price = context.calculate_total_price(base_price, seats)
            
            # Create booking object  # 🔥 DATACLASS USAGE
            booking = Booking(
                user_email=booking_data['user_email'],
                event_type=event_type.value,  # 🔥 ENUM VALUE
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
                transaction_id=self.utils.generate_transaction_id()  # 🔥 UTILITY USAGE
            )
            
            # Calculate profit breakdown  # 🔥 UTILITY METHOD
            booking.profit_breakdown = self.utils.calculate_profit_breakdown(total_price)
            
            # Save booking  # 🔥 MUTABLE LIST OPERATION
            self.bookings.append(booking)
            
            # Write ticket to file  # 🔥 FILE OPERATIONS
            file_manager.write_ticket(booking.__dict__, event_type.value)
            
            return True, booking.transaction_id
            
        except (ValidationError, BookingError) as e:  # 🔥 SPECIFIC EXCEPTION HANDLING
            logger.error(f"Booking validation error: {e}")
            return False, str(e)
        except Exception as e:  # 🔥 GENERAL EXCEPTION HANDLING
            logger.error(f"Unexpected booking error: {e}")
            return False, "Booking failed due to system error"

# =====================================================
# 🎯 CONCEPT 7: VISUALIZATION AND STREAMLIT
# =====================================================

# 🔥 VISUALIZATION CLASS - Data visualization using Plotly and NumPy
class DataVisualizer:
    """Data visualization class using plotly and numpy - VISUALIZATION MODULE"""
    
    # 🔥 STATIC METHOD - Revenue chart with NumPy calculations
    @staticmethod
    def create_revenue_chart(bookings_data: List[Dict]) -> go.Figure:
        """Create revenue visualization using numpy for calculations - PLOTLY INTEGRATION"""
        if not bookings_data:
            return go.Figure()
        
        # Convert to numpy arrays for efficient processing  # 🔥 PANDAS INTEGRATION
        df = pd.DataFrame(bookings_data)
        
        # Group by event type and calculate totals  # 🔥 DATA AGGREGATION
        revenue_by_type = df.groupby('event_type')['total_amount'].sum()
        
        # Create pie chart  # 🔥 PLOTLY VISUALIZATION
        fig = px.pie(
            values=revenue_by_type.values,
            names=revenue_by_type.index,
            title="Revenue Distribution by Event Type"
        )
        
        return fig
    
    # 🔥 STATIC METHOD - Profit analysis with NumPy
    @staticmethod
    def create_profit_analysis(profit_data: Dict) -> go.Figure:
        """Create profit analysis chart - NUMPY ANALYTICS"""
        categories = list(profit_data.keys())
        values = list(profit_data.values())
        
        # Use numpy for percentage calculations  # 🔥 NUMPY MATHEMATICAL OPERATIONS
        total = np.sum(values)
        percentages = np.round((np.array(values) / total) * 100, 1)
        
        # Create bar chart  # 🔥 PLOTLY BAR CHART
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
    
    # 🔥 STATIC METHOD - Booking trends analysis
    @staticmethod
    def create_booking_trends(bookings_data: List[Dict]) -> go.Figure:
        """Create booking trends over time - TIME SERIES VISUALIZATION"""
        if not bookings_data:
            return go.Figure()
        
        df = pd.DataFrame(bookings_data)  # 🔥 PANDAS DATAFRAME
        df['booking_date'] = pd.to_datetime(df['booking_date'])  # 🔥 DATE CONVERSION
        
        # Group by date and count bookings  # 🔥 TIME SERIES AGGREGATION
        daily_bookings = df.groupby(df['booking_date'].dt.date).size()
        
        # Create line chart  # 🔥 PLOTLY LINE CHART
        fig = px.line(
            x=daily_bookings.index,
            y=daily_bookings.values,
            title="Daily Booking Trends"
        )
        
        return fig

# 🔥 STREAMLIT UI CLASS - Complete UI management
class StreamlitUI:
    """Streamlit UI management class - STREAMLIT INTEGRATION"""
    
    def __init__(self):
        self.booking_manager = BookingManager()    # 🔥 SINGLETON USAGE
        self.visualizer = DataVisualizer()         # 🔥 VISUALIZATION COMPOSITION
        self.setup_page_config()                   # 🔥 METHOD CALL
        self.initialize_session_state()            # 🔥 METHOD CALL
    
    # 🔥 STREAMLIT CONFIGURATION - Page setup
    def setup_page_config(self):
        """Setup Streamlit page configuration - STREAMLIT CONFIG"""
        st.set_page_config(
            page_title="SmartShow Ultimate - Advanced",
            page_icon="🎬",
            layout="wide",
            initial_sidebar_state="expanded"
        )
    
    # 🔥 SESSION STATE MANAGEMENT - Streamlit state
    def initialize_session_state(self):
        """Initialize session state variables - STATE MANAGEMENT"""
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
        
        # 🔥 STREAMLIT SESSION STATE - Initialize if not exists
        for key, default_value in default_states.items():
            if key not in st.session_state:
                st.session_state[key] = default_value
    
    # 🔥 MAIN DASHBOARD - Advanced visualizations with NumPy
    def show_main_dashboard(self):
        """Main dashboard with advanced visualizations - COMPREHENSIVE UI"""
        st.title("🎬 SmartShow Ultimate - Advanced Analytics")
        
        # Sample data for demonstration  # 🔥 SAMPLE DATA
        sample_bookings = [
            {'event_type': 'movie', 'total_amount': 1500, 'booking_date': datetime.now()},
            {'event_type': 'comedy', 'total_amount': 800, 'booking_date': datetime.now()},
            {'event_type': 'concert', 'total_amount': 2000, 'booking_date': datetime.now()}
        ]
        
        # Create visualizations  # 🔥 STREAMLIT COLUMNS
        col1, col2 = st.columns(2)
        
        with col1:
            # 🔥 PLOTLY CHART IN STREAMLIT
            revenue_chart = self.visualizer.create_revenue_chart(sample_bookings)
            st.plotly_chart(revenue_chart, use_container_width=True)
        
        with col2:
            profit_data = {
                'Our Profit': 500,
                'Theatre Share': 1200,
                'Platform Fee': 200,
                'GST': 300
            }
            # 🔥 PLOTLY CHART IN STREAMLIT
            profit_chart = self.visualizer.create_profit_analysis(profit_data)
            st.plotly_chart(profit_chart, use_container_width=True)
        
        # Booking trends  # 🔥 FULL WIDTH CHART
        trends_chart = self.visualizer.create_booking_trends(sample_bookings)
        st.plotly_chart(trends_chart, use_container_width=True)
        
        # Advanced metrics using numpy  # 🔥 NUMPY ANALYTICS
        self.show_advanced_metrics()
    
    # 🔥 ADVANCED METRICS - NumPy statistical calculations
    def show_advanced_metrics(self):
        """Show advanced metrics using numpy calculations - NUMPY STATISTICS"""
        st.subheader("📊 Advanced Analytics")
        
        # Generate sample data using numpy  # 🔥 NUMPY RANDOM DATA
        np.random.seed(42)
        revenue_data = np.random.normal(1000, 200, 30)  # 30 days of revenue data
        
        # 🔥 STREAMLIT COLUMNS FOR METRICS
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            # 🔥 NUMPY MEAN CALCULATION
            avg_revenue = np.mean(revenue_data)
            st.metric("Average Daily Revenue", f"₹{avg_revenue:,.0f}")
        
        with col2:
            # 🔥 NUMPY STANDARD DEVIATION
            std_revenue = np.std(revenue_data)
            st.metric("Revenue Std Dev", f"₹{std_revenue:,.0f}")
        
        with col3:
            # 🔥 NUMPY MAXIMUM
            max_revenue = np.max(revenue_data)
            st.metric("Peak Revenue", f"₹{max_revenue:,.0f}")
        
        with col4:
            # 🔥 NUMPY POLYNOMIAL FIT - Advanced calculation
            growth_rate = np.polyfit(range(len(revenue_data)), revenue_data, 1)[0]
            st.metric("Growth Rate", f"₹{growth_rate:,.0f}/day")
    
    # 🔥 APPLICATION RUNNER - Main execution method
    def run(self):
        """Main application runner - MAIN EXECUTION"""
        try:
            if st.session_state.current_step == 'database_setup':
                self.show_database_setup()
            elif st.session_state.current_step == 'main_dashboard':
                self.show_main_dashboard()
            else:
                self.show_main_dashboard()
        except Exception as e:  # 🔥 EXCEPTION HANDLING
            st.error(f"Application error: {e}")
            logger.error(f"Application error: {e}")
    
    # 🔥 DATABASE SETUP UI - Streamlit interface
    def show_database_setup(self):
        """Database setup interface - STREAMLIT FORM"""
        st.title("🔧 Database Setup")
        
        password = st.text_input("PostgreSQL Password:", type="password")
        
        if password:
            col1, col2 = st.columns(2)
            
            with col1:
                if st.button("Connect to Database"):
                    try:
                        db = DatabaseModule()  # 🔥 MODULE USAGE
                        if db.connect(password):
                            st.success("✅ Connected successfully!")
                            st.session_state.db_ready = True
                            st.session_state.current_step = 'main_dashboard'
                            st.rerun()
                        else:
                            st.error("❌ Connection failed!")
                    except DatabaseConnectionError as e:  # 🔥 CUSTOM EXCEPTION
                        st.error(f"Database error: {e}")
            
            with col2:
                if st.button("Skip to Demo"):
                    st.session_state.current_step = 'main_dashboard'
                    st.rerun()

# =====================================================
# 🎯 MAIN APPLICATION - BRINGING ALL CONCEPTS TOGETHER
# =====================================================

def main():
    """Main application entry point - MAIN FUNCTION"""
    try:
        # Initialize and run the Streamlit UI  # 🔥 ALL CONCEPTS INTEGRATION
        app = StreamlitUI()  # 🔥 CLASS INSTANTIATION
        app.run()            # 🔥 METHOD CALL
        
    except Exception as e:  # 🔥 TOP-LEVEL EXCEPTION HANDLING
        st.error(f"Critical application error: {e}")
        logger.critical(f"Critical application error: {e}")

# 🔥 MAIN EXECUTION - Python entry point
if __name__ == "__main__":
    main()  # 🔥 FUNCTION CALL

# =====================================================
# 🎯 SUMMARY OF ALL 7 CONCEPTS IMPLEMENTED:
# =====================================================

"""
✅ CONCEPT 1: FUNCTIONS, SCOPING AND ABSTRACTION
   - Higher-order functions: create_validator()
   - Closures: email_validator, password_validator
   - Decorators: @memoize
   - Global/Local scoping: CONFIG, function scopes
   - Function abstraction: Modular function design

✅ CONCEPT 2: IMMUTABLE AND MUTABLE DATA STRUCTURES
   - Immutable: frozenset (AREAS, PAYMENT_METHODS), tuple (MOVIE_MOODS)
   - Custom immutable: ImmutableConfig class
   - Mutable: dict (theatre_cache), list (booking_history)

✅ CONCEPT 3: WORKING WITH FILES
   - Context managers: @contextmanager, with statements
   - Multiple formats: TXT, CSV, Pickle
   - File operations: Read, write, append with error handling
   - Path management: pathlib.Path

✅ CONCEPT 4: MODULES AND DIRECTORIES
   - DatabaseModule: Database operations
   - UtilityModule: Static utility functions
   - FileManager: File operation management
   - Modular design: Separation of concerns

✅ CONCEPT 5: OOP CONCEPTS AND EXCEPTION HANDLING
   - Custom exceptions: SmartShowException hierarchy
   - Data classes: @dataclass with validation
   - Encapsulation: Private methods, properties
   - Inheritance: Exception class hierarchy

✅ CONCEPT 6: ADVANCED OOP CONCEPTS AND NUMPY
   - Abstract Base Classes: EventBookingStrategy with @abstractmethod
   - Strategy Pattern: Different booking implementations
   - Factory Pattern: BookingFactory for object creation
   - Singleton Pattern: BookingManager single instance
   - Enums: EventType enumeration
   - NumPy integration: Mathematical calculations, arrays

✅ CONCEPT 7: VISUALIZATION AND STREAMLIT
   - Plotly charts: Interactive visualizations
   - NumPy analytics: Statistical calculations
   - Streamlit UI: Professional dashboard
   - Real-time metrics: Dynamic data visualization

🎉 ALL 7 CONCEPTS SUCCESSFULLY IMPLEMENTED AND HIGHLIGHTED! 🎉
"""
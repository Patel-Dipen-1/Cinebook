-- SmartShow Ultimate Database Setup for pgAdmin
-- Database: cinebook
-- Run this script in pgAdmin to create the complete database structure

-- Create database (run this first if database doesn't exist)
-- CREATE DATABASE cinebook;

-- Connect to cinebook database and run the following:

-- Drop existing tables if they exist (in correct order due to foreign keys)
DROP TABLE IF EXISTS payment_transactions CASCADE;
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS theatre_rows CASCADE;
DROP TABLE IF EXISTS venues CASCADE;
DROP TABLE IF EXISTS concerts CASCADE;
DROP TABLE IF EXISTS comedy_shows CASCADE;
DROP TABLE IF EXISTS movies CASCADE;
DROP TABLE IF EXISTS theatres CASCADE;
DROP TABLE IF EXISTS admin_users CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Create Users table
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
);

-- Create Admin Users table
CREATE TABLE admin_users (
    admin_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    role VARCHAR(50) DEFAULT 'ADMIN',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- Create Theatres table
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
);

-- Create Movies table
CREATE TABLE movies (
    id INTEGER PRIMARY KEY,
    movie_name VARCHAR(100) NOT NULL,
    mood VARCHAR(50) NOT NULL,
    duration_minutes INTEGER DEFAULT 150,
    rating VARCHAR(10) DEFAULT 'U/A',
    language VARCHAR(50) DEFAULT 'Hindi'
);

-- Create Comedy Shows table
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
);

-- Create Concerts table
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
);

-- Create Venues table
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
);

-- Create Theatre Rows table (with date and time specific seats)
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
);

-- Create Bookings table
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
);

-- Create Payment Transactions table
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
);

-- Insert Admin User
INSERT INTO admin_users (username, password, full_name, email, role)
VALUES ('admin', 'Admin@123', 'System Administrator', 'admin@smartshow.com', 'SUPER_ADMIN');

-- Insert Sample Theatres
INSERT INTO theatres (theater_id, name, area, city, theater_type, total_screens, base_price, total_seats, available_seats, address) VALUES
(1, 'PVR Acropolis Mall', 'Thaltej', 'Ahmedabad', 'Premium', 8, 350, 120, 120, 'Acropolis Mall, Thaltej, Ahmedabad'),
(2, 'INOX R City Mall', 'Paldi', 'Ahmedabad', 'Premium', 6, 320, 90, 90, 'R City Mall, Paldi, Ahmedabad'),
(3, 'Cinepolis Alpha One Mall', 'Vastrapur', 'Ahmedabad', 'Multiplex', 7, 300, 105, 105, 'Alpha One Mall, Vastrapur, Ahmedabad'),
(4, 'PVR Himalaya Mall', 'Satellite', 'Ahmedabad', 'Premium', 5, 330, 75, 75, 'Himalaya Mall, Satellite, Ahmedabad'),
(5, 'Fun Cinemas Ahmedabad One', 'Vastrapur', 'Ahmedabad', 'Multiplex', 4, 280, 60, 60, 'Ahmedabad One Mall, Vastrapur');

-- Insert Sample Venues for Comedy Shows and Concerts
INSERT INTO venues (venue_id, name, area, city, venue_type, capacity, available_capacity, base_price, address, facilities) VALUES
(1, 'Comedy Club Ahmedabad', 'Satellite', 'Ahmedabad', 'Comedy Club', 150, 150, 500, 'Satellite Road, Ahmedabad', 'AC, Sound System, Bar'),
(2, 'Laugh Factory', 'Vastrapur', 'Ahmedabad', 'Comedy Venue', 200, 200, 450, 'Vastrapur, Ahmedabad', 'AC, Stage Lighting'),
(3, 'Stand-Up Central', 'Paldi', 'Ahmedabad', 'Comedy Hall', 120, 120, 550, 'Paldi, Ahmedabad', 'Premium Sound, AC'),
(4, 'Concert Hall Ahmedabad', 'Thaltej', 'Ahmedabad', 'Concert Venue', 500, 500, 1000, 'Thaltej, Ahmedabad', 'Premium Sound, Lighting, VIP Seating'),
(5, 'Music Arena', 'Satellite', 'Ahmedabad', 'Music Venue', 300, 300, 1200, 'Satellite, Ahmedabad', 'Professional Sound, Stage');

-- Insert Sample Movies (4 moods, 5 movies each)
INSERT INTO movies (id, movie_name, mood, duration_minutes, rating, language) VALUES
-- Romantic Movies
(1, 'Titanic', 'Romantic', 195, 'PG-13', 'English'),
(2, 'The Notebook', 'Romantic', 123, 'PG-13', 'English'),
(3, 'La La Land', 'Romantic', 128, 'PG-13', 'English'),
(4, 'Dilwale Dulhania Le Jayenge', 'Romantic', 189, 'U', 'Hindi'),
(5, 'Jab We Met', 'Romantic', 138, 'U', 'Hindi'),
-- Action Movies
(6, 'Avengers: Endgame', 'Action', 181, 'PG-13', 'English'),
(7, 'Fast & Furious 9', 'Action', 143, 'PG-13', 'English'),
(8, 'Baahubali 2', 'Action', 167, 'U/A', 'Hindi'),
(9, 'KGF Chapter 2', 'Action', 168, 'U/A', 'Hindi'),
(10, 'Pathaan', 'Action', 146, 'U/A', 'Hindi'),
-- Comedy Movies
(11, 'Hera Pheri', 'Comedy', 156, 'U', 'Hindi'),
(12, 'Golmaal', 'Comedy', 150, 'U', 'Hindi'),
(13, 'Andaz Apna Apna', 'Comedy', 160, 'U', 'Hindi'),
(14, 'Welcome', 'Comedy', 159, 'U', 'Hindi'),
(15, 'Housefull', 'Comedy', 140, 'U/A', 'Hindi'),
-- Family Movies
(16, 'Taare Zameen Par', 'Family', 165, 'U', 'Hindi'),
(17, '3 Idiots', 'Family', 170, 'U', 'Hindi'),
(18, 'Dangal', 'Family', 161, 'U', 'Hindi'),
(19, 'Finding Nemo', 'Family', 100, 'G', 'English'),
(20, 'The Lion King', 'Family', 88, 'G', 'English');

-- Insert Sample Comedy Shows
INSERT INTO comedy_shows (show_id, comedian_name, show_title, show_type, duration_minutes, language, age_rating, description, ticket_price) VALUES
(1, 'Kapil Sharma', 'The Kapil Sharma Show Live', 'Stand-up Comedy', 90, 'Hindi', '18+', 'Hilarious comedy show', 500),
(2, 'Zakir Khan', 'Haq Se Single', 'Stand-up Comedy', 85, 'Hindi', '18+', 'Comedy about being single', 600),
(3, 'Biswa Kalyan Rath', 'Pretentious Movie Reviews', 'Stand-up Comedy', 80, 'English', '18+', 'Movie review comedy', 550),
(4, 'Kenny Sebastian', 'The Most Interesting Person', 'Stand-up Comedy', 75, 'English', '16+', 'Observational comedy', 650),
(5, 'Abhishek Upmanyu', 'Thoda Saaf Bol', 'Stand-up Comedy', 85, 'Hindi', '18+', 'Clean comedy show', 500);

-- Insert Sample Concerts
INSERT INTO concerts (concert_id, artist_name, concert_title, genre, duration_minutes, language, ticket_price, description, special_guests) VALUES
(1, 'Arijit Singh', 'Arijit Singh Live', 'Bollywood', 120, 'Hindi', 1000, 'Romantic Bollywood hits', 'Shreya Ghoshal'),
(2, 'A.R. Rahman', 'Rahman Live Concert', 'Classical/Fusion', 150, 'Multi', 1500, 'Musical maestro live', 'Hariharan'),
(3, 'Nucleya', 'Electronic Dance Night', 'Electronic', 90, 'Instrumental', 800, 'EDM night', 'Divine'),
(4, 'Rahat Fateh Ali Khan', 'Sufi Night', 'Sufi', 100, 'Urdu', 1200, 'Spiritual music', 'Kailash Kher'),
(5, 'Sunidhi Chauhan', 'Bollywood Diva Live', 'Bollywood', 110, 'Hindi', 900, 'Energetic performance', 'Shaan');

-- Insert Theatre Rows Data (for next 3 days with all show times)
-- This will be populated by the application based on show times and dates

-- Create indexes for better performance
CREATE INDEX idx_bookings_user_email ON bookings(user_email);
CREATE INDEX idx_bookings_event_type ON bookings(event_type);
CREATE INDEX idx_bookings_show_date ON bookings(show_date);
CREATE INDEX idx_theatre_rows_theatre_date_time ON theatre_rows(theatre_id, show_date, show_time);
CREATE INDEX idx_payment_transactions_booking_id ON payment_transactions(booking_id);

-- Grant permissions (adjust as needed)
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO your_app_user;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO your_app_user;

-- Database setup complete!
-- You can now run the Streamlit application which will populate theatre_rows data automatically.
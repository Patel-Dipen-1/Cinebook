-- SmartShow Ultimate - Complete Database Setup
-- This file contains all SQL queries for the complete entertainment booking system

-- =====================================================
-- DATABASE CREATION
-- =====================================================

-- Create database (run this first if database doesn't exist)
-- CREATE DATABASE cinebook;

-- Connect to the database
-- \c cinebook;

-- =====================================================
-- DROP EXISTING TABLES (if they exist)
-- =====================================================

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

-- =====================================================
-- CREATE TABLES
-- =====================================================

-- Users table
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

-- Admin users table
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

-- Theatres table
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

-- Movies table
CREATE TABLE movies (
    id INTEGER PRIMARY KEY,
    movie_name VARCHAR(100) NOT NULL,
    mood VARCHAR(50) NOT NULL,
    duration_minutes INTEGER DEFAULT 150,
    rating VARCHAR(10) DEFAULT 'U/A',
    language VARCHAR(50) DEFAULT 'Hindi'
);

-- Comedy shows table
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

-- Concerts table
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

-- Venues table
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

-- Theatre rows table (with date and time specific seats)
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

-- Bookings table (with profit tracking)
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
);

-- Payment transactions table
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

-- =====================================================
-- INSERT SAMPLE DATA
-- =====================================================

-- Insert admin user
INSERT INTO admin_users (username, password, full_name, email, role)
VALUES ('admin', 'Admin@123', 'System Administrator', 'admin@smartshow.com', 'SUPER_ADMIN');

-- Insert theatres (7 theatres per area, 8 areas = 56 total theatres)
INSERT INTO theatres (theater_id, name, area, city, theater_type, total_screens, base_price, total_seats, available_seats, address) VALUES
-- Satellite Area Theatres (1-7)
(1, 'PVR Satellite Plaza', 'Satellite', 'Ahmedabad', 'Premium', 8, 350, 120, 120, 'Satellite Plaza, Satellite, Ahmedabad'),
(2, 'INOX Satellite Mall', 'Satellite', 'Ahmedabad', 'Premium', 6, 320, 90, 90, 'Satellite Mall, Satellite, Ahmedabad'),
(3, 'Cinepolis Satellite Square', 'Satellite', 'Ahmedabad', 'Multiplex', 7, 300, 105, 105, 'Satellite Square, Satellite, Ahmedabad'),
(4, 'Fun Cinemas Satellite', 'Satellite', 'Ahmedabad', 'Multiplex', 5, 280, 75, 75, 'Satellite Road, Satellite, Ahmedabad'),
(5, 'Rajhans Satellite', 'Satellite', 'Ahmedabad', 'Standard', 4, 250, 60, 60, 'Satellite Circle, Satellite, Ahmedabad'),
(6, 'Carnival Satellite', 'Satellite', 'Ahmedabad', 'Multiplex', 6, 290, 85, 85, 'Satellite Cross Roads, Satellite, Ahmedabad'),
(7, 'Miraj Satellite', 'Satellite', 'Ahmedabad', 'Standard', 5, 270, 70, 70, 'Satellite Garden, Satellite, Ahmedabad'),

-- Vastrapur Area Theatres (8-14)
(8, 'PVR Vastrapur Lake', 'Vastrapur', 'Ahmedabad', 'Premium', 8, 360, 120, 120, 'Vastrapur Lake, Vastrapur, Ahmedabad'),
(9, 'INOX Vastrapur Mall', 'Vastrapur', 'Ahmedabad', 'Premium', 6, 330, 90, 90, 'Vastrapur Mall, Vastrapur, Ahmedabad'),
(10, 'Cinepolis Vastrapur', 'Vastrapur', 'Ahmedabad', 'Multiplex', 7, 310, 105, 105, 'Vastrapur Main Road, Vastrapur, Ahmedabad'),
(11, 'Fun Cinemas Vastrapur', 'Vastrapur', 'Ahmedabad', 'Multiplex', 5, 290, 75, 75, 'Vastrapur Circle, Vastrapur, Ahmedabad'),
(12, 'Rajhans Vastrapur', 'Vastrapur', 'Ahmedabad', 'Standard', 4, 260, 60, 60, 'Vastrapur Garden, Vastrapur, Ahmedabad'),
(13, 'Carnival Vastrapur', 'Vastrapur', 'Ahmedabad', 'Multiplex', 6, 300, 85, 85, 'Vastrapur Cross Roads, Vastrapur, Ahmedabad'),
(14, 'Miraj Vastrapur', 'Vastrapur', 'Ahmedabad', 'Standard', 5, 280, 70, 70, 'Vastrapur Square, Vastrapur, Ahmedabad'),

-- Paldi Area Theatres (15-21)
(15, 'PVR Paldi Central', 'Paldi', 'Ahmedabad', 'Premium', 8, 340, 120, 120, 'Paldi Central, Paldi, Ahmedabad'),
(16, 'INOX Paldi Plaza', 'Paldi', 'Ahmedabad', 'Premium', 6, 310, 90, 90, 'Paldi Plaza, Paldi, Ahmedabad'),
(17, 'Cinepolis Paldi', 'Paldi', 'Ahmedabad', 'Multiplex', 7, 290, 105, 105, 'Paldi Main Road, Paldi, Ahmedabad'),
(18, 'Fun Cinemas Paldi', 'Paldi', 'Ahmedabad', 'Multiplex', 5, 270, 75, 75, 'Paldi Circle, Paldi, Ahmedabad'),
(19, 'Rajhans Paldi', 'Paldi', 'Ahmedabad', 'Standard', 4, 240, 60, 60, 'Paldi Garden, Paldi, Ahmedabad'),
(20, 'Carnival Paldi', 'Paldi', 'Ahmedabad', 'Multiplex', 6, 280, 85, 85, 'Paldi Cross Roads, Paldi, Ahmedabad'),
(21, 'Miraj Paldi', 'Paldi', 'Ahmedabad', 'Standard', 5, 260, 70, 70, 'Paldi Square, Paldi, Ahmedabad'),

-- Thaltej Area Theatres (22-28)
(22, 'PVR Thaltej Mall', 'Thaltej', 'Ahmedabad', 'Premium', 8, 370, 120, 120, 'Thaltej Mall, Thaltej, Ahmedabad'),
(23, 'INOX Thaltej Plaza', 'Thaltej', 'Ahmedabad', 'Premium', 6, 340, 90, 90, 'Thaltej Plaza, Thaltej, Ahmedabad'),
(24, 'Cinepolis Thaltej', 'Thaltej', 'Ahmedabad', 'Multiplex', 7, 320, 105, 105, 'Thaltej Cross Roads, Thaltej, Ahmedabad'),
(25, 'Fun Cinemas Thaltej', 'Thaltej', 'Ahmedabad', 'Multiplex', 5, 300, 75, 75, 'Thaltej Circle, Thaltej, Ahmedabad'),
(26, 'Rajhans Thaltej', 'Thaltej', 'Ahmedabad', 'Standard', 4, 270, 60, 60, 'Thaltej Garden, Thaltej, Ahmedabad'),
(27, 'Carnival Thaltej', 'Thaltej', 'Ahmedabad', 'Multiplex', 6, 310, 85, 85, 'Thaltej Square, Thaltej, Ahmedabad'),
(28, 'Miraj Thaltej', 'Thaltej', 'Ahmedabad', 'Standard', 5, 290, 70, 70, 'Thaltej Park, Thaltej, Ahmedabad'),

-- Bopal Area Theatres (29-35)
(29, 'PVR Bopal Square', 'Bopal', 'Ahmedabad', 'Premium', 8, 350, 120, 120, 'Bopal Square, Bopal, Ahmedabad'),
(30, 'INOX Bopal Mall', 'Bopal', 'Ahmedabad', 'Premium', 6, 320, 90, 90, 'Bopal Mall, Bopal, Ahmedabad'),
(31, 'Cinepolis Bopal', 'Bopal', 'Ahmedabad', 'Multiplex', 7, 300, 105, 105, 'Bopal Main Road, Bopal, Ahmedabad'),
(32, 'Fun Cinemas Bopal', 'Bopal', 'Ahmedabad', 'Multiplex', 5, 280, 75, 75, 'Bopal Circle, Bopal, Ahmedabad'),
(33, 'Rajhans Bopal', 'Bopal', 'Ahmedabad', 'Standard', 4, 250, 60, 60, 'Bopal Garden, Bopal, Ahmedabad'),
(34, 'Carnival Bopal', 'Bopal', 'Ahmedabad', 'Multiplex', 6, 290, 85, 85, 'Bopal Cross Roads, Bopal, Ahmedabad'),
(35, 'Miraj Bopal', 'Bopal', 'Ahmedabad', 'Standard', 5, 270, 70, 70, 'Bopal Park, Bopal, Ahmedabad'),

-- Maninagar Area Theatres (36-42)
(36, 'PVR Maninagar Central', 'Maninagar', 'Ahmedabad', 'Premium', 8, 340, 120, 120, 'Maninagar Central, Maninagar, Ahmedabad'),
(37, 'INOX Maninagar Plaza', 'Maninagar', 'Ahmedabad', 'Premium', 6, 310, 90, 90, 'Maninagar Plaza, Maninagar, Ahmedabad'),
(38, 'Cinepolis Maninagar', 'Maninagar', 'Ahmedabad', 'Multiplex', 7, 290, 105, 105, 'Maninagar Main Road, Maninagar, Ahmedabad'),
(39, 'Fun Cinemas Maninagar', 'Maninagar', 'Ahmedabad', 'Multiplex', 5, 270, 75, 75, 'Maninagar Circle, Maninagar, Ahmedabad'),
(40, 'Rajhans Maninagar', 'Maninagar', 'Ahmedabad', 'Standard', 4, 240, 60, 60, 'Maninagar Garden, Maninagar, Ahmedabad'),
(41, 'Carnival Maninagar', 'Maninagar', 'Ahmedabad', 'Multiplex', 6, 280, 85, 85, 'Maninagar Cross Roads, Maninagar, Ahmedabad'),
(42, 'Miraj Maninagar', 'Maninagar', 'Ahmedabad', 'Standard', 5, 260, 70, 70, 'Maninagar Square, Maninagar, Ahmedabad'),

-- Naranpura Area Theatres (43-49)
(43, 'PVR Naranpura Mall', 'Naranpura', 'Ahmedabad', 'Premium', 8, 360, 120, 120, 'Naranpura Mall, Naranpura, Ahmedabad'),
(44, 'INOX Naranpura Plaza', 'Naranpura', 'Ahmedabad', 'Premium', 6, 330, 90, 90, 'Naranpura Plaza, Naranpura, Ahmedabad'),
(45, 'Cinepolis Naranpura', 'Naranpura', 'Ahmedabad', 'Multiplex', 7, 310, 105, 105, 'Naranpura Main Road, Naranpura, Ahmedabad'),
(46, 'Fun Cinemas Naranpura', 'Naranpura', 'Ahmedabad', 'Multiplex', 5, 290, 75, 75, 'Naranpura Circle, Naranpura, Ahmedabad'),
(47, 'Rajhans Naranpura', 'Naranpura', 'Ahmedabad', 'Standard', 4, 260, 60, 60, 'Naranpura Garden, Naranpura, Ahmedabad'),
(48, 'Carnival Naranpura', 'Naranpura', 'Ahmedabad', 'Multiplex', 6, 300, 85, 85, 'Naranpura Cross Roads, Naranpura, Ahmedabad'),
(49, 'Miraj Naranpura', 'Naranpura', 'Ahmedabad', 'Standard', 5, 280, 70, 70, 'Naranpura Square, Naranpura, Ahmedabad'),

-- Chandkheda Area Theatres (50-56)
(50, 'PVR Chandkheda Central', 'Chandkheda', 'Ahmedabad', 'Premium', 8, 350, 120, 120, 'Chandkheda Central, Chandkheda, Ahmedabad'),
(51, 'INOX Chandkheda Mall', 'Chandkheda', 'Ahmedabad', 'Premium', 6, 320, 90, 90, 'Chandkheda Mall, Chandkheda, Ahmedabad'),
(52, 'Cinepolis Chandkheda', 'Chandkheda', 'Ahmedabad', 'Multiplex', 7, 300, 105, 105, 'Chandkheda Main Road, Chandkheda, Ahmedabad'),
(53, 'Fun Cinemas Chandkheda', 'Chandkheda', 'Ahmedabad', 'Multiplex', 5, 280, 75, 75, 'Chandkheda Circle, Chandkheda, Ahmedabad'),
(54, 'Rajhans Chandkheda', 'Chandkheda', 'Ahmedabad', 'Standard', 4, 250, 60, 60, 'Chandkheda Garden, Chandkheda, Ahmedabad'),
(55, 'Carnival Chandkheda', 'Chandkheda', 'Ahmedabad', 'Multiplex', 6, 290, 85, 85, 'Chandkheda Cross Roads, Chandkheda, Ahmedabad'),
(56, 'Miraj Chandkheda', 'Chandkheda', 'Ahmedabad', 'Standard', 5, 270, 70, 70, 'Chandkheda Square, Chandkheda, Ahmedabad');

-- Insert venues for comedy shows and concerts (distributed across areas)
INSERT INTO venues (venue_id, name, area, city, venue_type, capacity, available_capacity, base_price, address, facilities) VALUES
(1, 'Comedy Club Satellite', 'Satellite', 'Ahmedabad', 'Comedy Club', 150, 150, 500, 'Satellite Road, Ahmedabad', 'AC, Sound System, Bar'),
(2, 'Laugh Factory Vastrapur', 'Vastrapur', 'Ahmedabad', 'Comedy Venue', 200, 200, 450, 'Vastrapur, Ahmedabad', 'AC, Stage Lighting'),
(3, 'Stand-Up Central Paldi', 'Paldi', 'Ahmedabad', 'Comedy Hall', 120, 120, 550, 'Paldi, Ahmedabad', 'Premium Sound, AC'),
(4, 'Comedy Corner Thaltej', 'Thaltej', 'Ahmedabad', 'Comedy Club', 180, 180, 480, 'Thaltej, Ahmedabad', 'AC, Sound System, Bar'),
(5, 'Humor Hub Bopal', 'Bopal', 'Ahmedabad', 'Comedy Venue', 160, 160, 520, 'Bopal, Ahmedabad', 'AC, Stage Lighting'),
(6, 'Concert Hall Satellite', 'Satellite', 'Ahmedabad', 'Concert Venue', 500, 500, 1000, 'Satellite, Ahmedabad', 'Premium Sound, Lighting, VIP Seating'),
(7, 'Music Arena Vastrapur', 'Vastrapur', 'Ahmedabad', 'Music Venue', 300, 300, 1200, 'Vastrapur, Ahmedabad', 'Professional Sound, Stage'),
(8, 'Symphony Hall Paldi', 'Paldi', 'Ahmedabad', 'Concert Venue', 400, 400, 1100, 'Paldi, Ahmedabad', 'Premium Sound, Lighting'),
(9, 'Melody Center Thaltej', 'Thaltej', 'Ahmedabad', 'Music Venue', 350, 350, 1150, 'Thaltej, Ahmedabad', 'Professional Sound, Stage'),
(10, 'Rhythm Palace Bopal', 'Bopal', 'Ahmedabad', 'Concert Venue', 450, 450, 1050, 'Bopal, Ahmedabad', 'Premium Sound, Lighting, VIP Seating');

-- Insert movies (40 movies - 10 per mood category)
INSERT INTO movies (id, movie_name, mood, duration_minutes, rating, language) VALUES
-- Romantic Movies (1-10)
(1, 'Titanic', 'Romantic', 195, 'PG-13', 'English'),
(2, 'The Notebook', 'Romantic', 123, 'PG-13', 'English'),
(3, 'La La Land', 'Romantic', 128, 'PG-13', 'English'),
(4, 'Dilwale Dulhania Le Jayenge', 'Romantic', 189, 'U', 'Hindi'),
(5, 'Jab We Met', 'Romantic', 138, 'U', 'Hindi'),
(6, 'Casablanca', 'Romantic', 102, 'PG', 'English'),
(7, 'Yeh Jawaani Hai Deewani', 'Romantic', 161, 'U', 'Hindi'),
(8, 'Before Sunrise', 'Romantic', 101, 'R', 'English'),
(9, 'Zindagi Na Milegi Dobara', 'Romantic', 155, 'U/A', 'Hindi'),
(10, 'The Princess Bride', 'Romantic', 98, 'PG', 'English'),

-- Action Movies (11-20)
(11, 'Avengers: Endgame', 'Action', 181, 'PG-13', 'English'),
(12, 'Fast & Furious 9', 'Action', 143, 'PG-13', 'English'),
(13, 'Baahubali 2', 'Action', 167, 'U/A', 'Hindi'),
(14, 'KGF Chapter 2', 'Action', 168, 'U/A', 'Hindi'),
(15, 'Pathaan', 'Action', 146, 'U/A', 'Hindi'),
(16, 'Mad Max: Fury Road', 'Action', 120, 'R', 'English'),
(17, 'War', 'Action', 156, 'U/A', 'Hindi'),
(18, 'John Wick', 'Action', 101, 'R', 'English'),
(19, 'Pushpa', 'Action', 179, 'U/A', 'Hindi'),
(20, 'Mission Impossible', 'Action', 147, 'PG-13', 'English'),

-- Comedy Movies (21-30)
(21, 'Hera Pheri', 'Comedy', 156, 'U', 'Hindi'),
(22, 'Golmaal', 'Comedy', 150, 'U', 'Hindi'),
(23, 'Andaz Apna Apna', 'Comedy', 160, 'U', 'Hindi'),
(24, 'Welcome', 'Comedy', 159, 'U', 'Hindi'),
(25, 'Housefull', 'Comedy', 140, 'U/A', 'Hindi'),
(26, 'The Hangover', 'Comedy', 100, 'R', 'English'),
(27, 'Munna Bhai MBBS', 'Comedy', 156, 'U', 'Hindi'),
(28, 'Superbad', 'Comedy', 113, 'R', 'English'),
(29, 'Fukrey', 'Comedy', 139, 'U/A', 'Hindi'),
(30, 'Dumb and Dumber', 'Comedy', 107, 'PG-13', 'English'),

-- Family Movies (31-40)
(31, 'Taare Zameen Par', 'Family', 165, 'U', 'Hindi'),
(32, '3 Idiots', 'Family', 170, 'U', 'Hindi'),
(33, 'Dangal', 'Family', 161, 'U', 'Hindi'),
(34, 'Finding Nemo', 'Family', 100, 'G', 'English'),
(35, 'The Lion King', 'Family', 88, 'G', 'English'),
(36, 'Coco', 'Family', 105, 'PG', 'English'),
(37, 'Queen', 'Family', 146, 'U/A', 'Hindi'),
(38, 'Toy Story', 'Family', 81, 'G', 'English'),
(39, 'Hindi Medium', 'Family', 132, 'U', 'Hindi'),
(40, 'The Incredibles', 'Family', 115, 'PG', 'English');

-- Insert comedy shows
INSERT INTO comedy_shows (show_id, comedian_name, show_title, show_type, duration_minutes, language, age_rating, description, ticket_price) VALUES
(1, 'Kapil Sharma', 'The Kapil Sharma Show Live', 'Stand-up Comedy', 90, 'Hindi', '18+', 'Hilarious comedy show', 500),
(2, 'Zakir Khan', 'Haq Se Single', 'Stand-up Comedy', 85, 'Hindi', '18+', 'Comedy about being single', 600),
(3, 'Biswa Kalyan Rath', 'Pretentious Movie Reviews', 'Stand-up Comedy', 80, 'English', '18+', 'Movie review comedy', 550),
(4, 'Kenny Sebastian', 'The Most Interesting Person', 'Stand-up Comedy', 75, 'English', '16+', 'Observational comedy', 650),
(5, 'Abhishek Upmanyu', 'Thoda Saaf Bol', 'Stand-up Comedy', 85, 'Hindi', '18+', 'Clean comedy show', 500);

-- Insert concerts
INSERT INTO concerts (concert_id, artist_name, concert_title, genre, duration_minutes, language, ticket_price, description, special_guests) VALUES
(1, 'Arijit Singh', 'Arijit Singh Live', 'Bollywood', 120, 'Hindi', 1000, 'Romantic Bollywood hits', 'Shreya Ghoshal'),
(2, 'A.R. Rahman', 'Rahman Live Concert', 'Classical/Fusion', 150, 'Multi', 1500, 'Musical maestro live', 'Hariharan'),
(3, 'Nucleya', 'Electronic Dance Night', 'Electronic', 90, 'Instrumental', 800, 'EDM night', 'Divine'),
(4, 'Rahat Fateh Ali Khan', 'Sufi Night', 'Sufi', 100, 'Urdu', 1200, 'Spiritual music', 'Kailash Kher'),
(5, 'Sunidhi Chauhan', 'Bollywood Diva Live', 'Bollywood', 110, 'Hindi', 900, 'Energetic performance', 'Shaan');
-- =====================================================
-- INSERT THEATRE ROWS DATA (Date and Time Specific Seats)
-- =====================================================

-- Theatre 1 (PVR Acropolis Mall) - 120 seats total
-- Row A: 30 seats (Premium - 1.5x price)
-- Row B: 35 seats (Gold - 1.2x price)  
-- Row C: 30 seats (Silver - 1.0x price)
-- Row D: 15 seats (Bronze - 0.8x price)
-- Row E: 10 seats (Economy - 0.7x price)

-- Theatre 2 (INOX R City Mall) - 90 seats total
-- Row A: 25 seats (Premium - 1.5x price)
-- Row B: 30 seats (Gold - 1.2x price)
-- Row C: 20 seats (Silver - 1.0x price)
-- Row D: 15 seats (Bronze - 0.8x price)

-- Theatre 3 (Cinepolis Alpha One Mall) - 105 seats total
-- Row A: 30 seats (Premium - 1.5x price)
-- Row B: 35 seats (Gold - 1.2x price)
-- Row C: 25 seats (Silver - 1.0x price)
-- Row D: 15 seats (Bronze - 0.8x price)

-- Theatre 4 (PVR Himalaya Mall) - 75 seats total
-- Row A: 20 seats (Premium - 1.5x price)
-- Row B: 25 seats (Gold - 1.2x price)
-- Row C: 20 seats (Silver - 1.0x price)
-- Row D: 10 seats (Bronze - 0.8x price)

-- Theatre 5 (Fun Cinemas Ahmedabad One) - 60 seats total
-- Row A: 20 seats (Premium - 1.5x price)
-- Row B: 25 seats (Gold - 1.2x price)
-- Row C: 15 seats (Silver - 1.0x price)

-- Show times for different movie types:
-- Romantic movies: 2:00 PM, 5:30 PM, 8:45 PM
-- Action movies: 12:30 PM, 4:00 PM, 7:30 PM, 10:45 PM
-- Comedy movies: 1:30 PM, 4:30 PM, 7:00 PM, 9:30 PM
-- Family movies: 11:00 AM, 2:30 PM, 6:00 PM, 9:00 PM

-- Insert theatre rows for next 3 days with all show times
-- Note: Replace CURRENT_DATE with actual dates when running

-- Theatre 1 rows for all show times and dates
INSERT INTO theatre_rows (theatre_id, row_name, show_date, show_time, total_seats, available_seats, price_multiplier) VALUES
-- Day 1 (Today)
(1, 'A', CURRENT_DATE, '11:00 AM', 30, 30, 1.5),
(1, 'B', CURRENT_DATE, '11:00 AM', 35, 35, 1.2),
(1, 'C', CURRENT_DATE, '11:00 AM', 30, 30, 1.0),
(1, 'D', CURRENT_DATE, '11:00 AM', 15, 15, 0.8),
(1, 'E', CURRENT_DATE, '11:00 AM', 10, 10, 0.7),

(1, 'A', CURRENT_DATE, '12:30 PM', 30, 30, 1.5),
(1, 'B', CURRENT_DATE, '12:30 PM', 35, 35, 1.2),
(1, 'C', CURRENT_DATE, '12:30 PM', 30, 30, 1.0),
(1, 'D', CURRENT_DATE, '12:30 PM', 15, 15, 0.8),
(1, 'E', CURRENT_DATE, '12:30 PM', 10, 10, 0.7),

(1, 'A', CURRENT_DATE, '1:30 PM', 30, 30, 1.5),
(1, 'B', CURRENT_DATE, '1:30 PM', 35, 35, 1.2),
(1, 'C', CURRENT_DATE, '1:30 PM', 30, 30, 1.0),
(1, 'D', CURRENT_DATE, '1:30 PM', 15, 15, 0.8),
(1, 'E', CURRENT_DATE, '1:30 PM', 10, 10, 0.7),

(1, 'A', CURRENT_DATE, '2:00 PM', 30, 30, 1.5),
(1, 'B', CURRENT_DATE, '2:00 PM', 35, 35, 1.2),
(1, 'C', CURRENT_DATE, '2:00 PM', 30, 30, 1.0),
(1, 'D', CURRENT_DATE, '2:00 PM', 15, 15, 0.8),
(1, 'E', CURRENT_DATE, '2:00 PM', 10, 10, 0.7),

(1, 'A', CURRENT_DATE, '2:30 PM', 30, 30, 1.5),
(1, 'B', CURRENT_DATE, '2:30 PM', 35, 35, 1.2),
(1, 'C', CURRENT_DATE, '2:30 PM', 30, 30, 1.0),
(1, 'D', CURRENT_DATE, '2:30 PM', 15, 15, 0.8),
(1, 'E', CURRENT_DATE, '2:30 PM', 10, 10, 0.7),

(1, 'A', CURRENT_DATE, '4:00 PM', 30, 30, 1.5),
(1, 'B', CURRENT_DATE, '4:00 PM', 35, 35, 1.2),
(1, 'C', CURRENT_DATE, '4:00 PM', 30, 30, 1.0),
(1, 'D', CURRENT_DATE, '4:00 PM', 15, 15, 0.8),
(1, 'E', CURRENT_DATE, '4:00 PM', 10, 10, 0.7),

(1, 'A', CURRENT_DATE, '4:30 PM', 30, 30, 1.5),
(1, 'B', CURRENT_DATE, '4:30 PM', 35, 35, 1.2),
(1, 'C', CURRENT_DATE, '4:30 PM', 30, 30, 1.0),
(1, 'D', CURRENT_DATE, '4:30 PM', 15, 15, 0.8),
(1, 'E', CURRENT_DATE, '4:30 PM', 10, 10, 0.7),

(1, 'A', CURRENT_DATE, '5:30 PM', 30, 30, 1.5),
(1, 'B', CURRENT_DATE, '5:30 PM', 35, 35, 1.2),
(1, 'C', CURRENT_DATE, '5:30 PM', 30, 30, 1.0),
(1, 'D', CURRENT_DATE, '5:30 PM', 15, 15, 0.8),
(1, 'E', CURRENT_DATE, '5:30 PM', 10, 10, 0.7),

(1, 'A', CURRENT_DATE, '6:00 PM', 30, 30, 1.5),
(1, 'B', CURRENT_DATE, '6:00 PM', 35, 35, 1.2),
(1, 'C', CURRENT_DATE, '6:00 PM', 30, 30, 1.0),
(1, 'D', CURRENT_DATE, '6:00 PM', 15, 15, 0.8),
(1, 'E', CURRENT_DATE, '6:00 PM', 10, 10, 0.7),

(1, 'A', CURRENT_DATE, '7:00 PM', 30, 30, 1.5),
(1, 'B', CURRENT_DATE, '7:00 PM', 35, 35, 1.2),
(1, 'C', CURRENT_DATE, '7:00 PM', 30, 30, 1.0),
(1, 'D', CURRENT_DATE, '7:00 PM', 15, 15, 0.8),
(1, 'E', CURRENT_DATE, '7:00 PM', 10, 10, 0.7),

(1, 'A', CURRENT_DATE, '7:30 PM', 30, 30, 1.5),
(1, 'B', CURRENT_DATE, '7:30 PM', 35, 35, 1.2),
(1, 'C', CURRENT_DATE, '7:30 PM', 30, 30, 1.0),
(1, 'D', CURRENT_DATE, '7:30 PM', 15, 15, 0.8),
(1, 'E', CURRENT_DATE, '7:30 PM', 10, 10, 0.7),

(1, 'A', CURRENT_DATE, '8:45 PM', 30, 30, 1.5),
(1, 'B', CURRENT_DATE, '8:45 PM', 35, 35, 1.2),
(1, 'C', CURRENT_DATE, '8:45 PM', 30, 30, 1.0),
(1, 'D', CURRENT_DATE, '8:45 PM', 15, 15, 0.8),
(1, 'E', CURRENT_DATE, '8:45 PM', 10, 10, 0.7),

(1, 'A', CURRENT_DATE, '9:00 PM', 30, 30, 1.5),
(1, 'B', CURRENT_DATE, '9:00 PM', 35, 35, 1.2),
(1, 'C', CURRENT_DATE, '9:00 PM', 30, 30, 1.0),
(1, 'D', CURRENT_DATE, '9:00 PM', 15, 15, 0.8),
(1, 'E', CURRENT_DATE, '9:00 PM', 10, 10, 0.7),

(1, 'A', CURRENT_DATE, '9:30 PM', 30, 30, 1.5),
(1, 'B', CURRENT_DATE, '9:30 PM', 35, 35, 1.2),
(1, 'C', CURRENT_DATE, '9:30 PM', 30, 30, 1.0),
(1, 'D', CURRENT_DATE, '9:30 PM', 15, 15, 0.8),
(1, 'E', CURRENT_DATE, '9:30 PM', 10, 10, 0.7),

(1, 'A', CURRENT_DATE, '10:45 PM', 30, 30, 1.5),
(1, 'B', CURRENT_DATE, '10:45 PM', 35, 35, 1.2),
(1, 'C', CURRENT_DATE, '10:45 PM', 30, 30, 1.0),
(1, 'D', CURRENT_DATE, '10:45 PM', 15, 15, 0.8),
(1, 'E', CURRENT_DATE, '10:45 PM', 10, 10, 0.7);

-- =====================================================
-- USEFUL QUERIES FOR APPLICATION
-- =====================================================

-- 1. Get all movies by mood
-- SELECT * FROM movies WHERE mood = 'Romantic';
-- SELECT * FROM movies WHERE mood = 'Action';
-- SELECT * FROM movies WHERE mood = 'Comedy';
-- SELECT * FROM movies WHERE mood = 'Family';

-- 2. Get all theatres with details
-- SELECT * FROM theatres ORDER BY name;

-- 3. Get available seats for a specific theatre, date, and time
-- SELECT row_name, total_seats, available_seats, price_multiplier
-- FROM theatre_rows 
-- WHERE theatre_id = 1 AND show_date = CURRENT_DATE AND show_time = '7:30 PM'
-- ORDER BY row_name;

-- 4. Get all comedy shows
-- SELECT * FROM comedy_shows ORDER BY comedian_name;

-- 5. Get all concerts
-- SELECT * FROM concerts ORDER BY artist_name;

-- 6. Get comedy venues
-- SELECT * FROM venues WHERE venue_type LIKE '%Comedy%' ORDER BY name;

-- 7. Get concert venues
-- SELECT * FROM venues WHERE venue_type LIKE '%Concert%' OR venue_type LIKE '%Music%' ORDER BY name;

-- 8. User registration
-- INSERT INTO users (name, email, password, password_display, area, otp, otp_expiry)
-- VALUES ('John Doe', 'john@gmail.com', 'Pass@123', 'Pass@123', 'Satellite', '123456', NOW() + INTERVAL '10 minutes');

-- 9. User login verification
-- SELECT email, name, otp FROM users WHERE email = 'john@gmail.com' AND password = 'Pass@123';

-- 10. Admin login
-- SELECT admin_id, username, full_name FROM admin_users WHERE username = 'admin' AND password = 'Admin@123';

-- 11. Create a booking
-- INSERT INTO bookings (user_email, event_type, event_id, event_name, venue_id, venue_name,
--                      show_date, show_time, booked_seats, total_amount, booking_date,
--                      seat_numbers, row_details, payment_method, payment_status, transaction_id)
-- VALUES ('user@gmail.com', 'movie', 1, 'Titanic', 1, 'PVR Acropolis Mall',
--         CURRENT_DATE, '7:30 PM', 2, 700, NOW(),
--         'A1, A2', 'Row A x 2 seats', 'UPI', 'COMPLETED', 'TXN123456789');

-- 12. Update seat availability after booking
-- UPDATE theatre_rows 
-- SET available_seats = available_seats - 2
-- WHERE theatre_id = 1 AND row_name = 'A' AND show_date = CURRENT_DATE AND show_time = '7:30 PM';

-- 13. Update venue capacity after booking (for comedy/concerts)
-- UPDATE venues SET available_capacity = available_capacity - 2 WHERE venue_id = 1;

-- 14. Get user's booking history
-- SELECT booking_id, event_type, event_name, venue_name, show_date, show_time,
--        booked_seats, total_amount, booking_date, payment_status, transaction_id
-- FROM bookings 
-- WHERE user_email = 'user@gmail.com' 
-- ORDER BY booking_date DESC;

-- 15. Admin analytics - booking statistics
-- SELECT 
--     event_type,
--     COUNT(*) as total_bookings,
--     SUM(booked_seats) as total_tickets,
--     SUM(total_amount) as total_revenue
-- FROM bookings 
-- GROUP BY event_type;

-- 16. Daily bookings trend
-- SELECT DATE(booking_date) as booking_date, COUNT(*) as bookings
-- FROM bookings 
-- GROUP BY DATE(booking_date)
-- ORDER BY booking_date;

-- 17. User statistics by area
-- SELECT area, COUNT(*) as user_count 
-- FROM users WHERE otp IS NULL
-- GROUP BY area 
-- ORDER BY user_count DESC;

-- 18. Reset all theatre seats to full capacity
-- UPDATE theatre_rows SET available_seats = total_seats;

-- 19. Reset all venue capacities
-- UPDATE venues SET available_capacity = capacity;

-- 20. Get payment transaction details
-- SELECT * FROM payment_transactions WHERE booking_id = 1;

-- =====================================================
-- INDEXES FOR BETTER PERFORMANCE
-- =====================================================

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_bookings_user_email ON bookings(user_email);
CREATE INDEX idx_bookings_event_type ON bookings(event_type);
CREATE INDEX idx_bookings_show_date ON bookings(show_date);
CREATE INDEX idx_theatre_rows_theatre_date_time ON theatre_rows(theatre_id, show_date, show_time);
CREATE INDEX idx_payment_transactions_booking_id ON payment_transactions(booking_id);

-- =====================================================
-- SAMPLE TEST DATA (Optional)
-- =====================================================

-- Sample user for testing
INSERT INTO users (name, email, password, password_display, area) VALUES
('Test User', 'test@gmail.com', 'Test@123', 'Test@123', 'Satellite');

-- Sample booking for testing
INSERT INTO bookings (user_email, event_type, event_id, event_name, venue_id, venue_name,
                     show_date, show_time, booked_seats, total_amount, booking_date,
                     seat_numbers, row_details, payment_method, payment_status, transaction_id) VALUES
('test@gmail.com', 'movie', 1, 'Titanic', 1, 'PVR Acropolis Mall',
 CURRENT_DATE, '7:30 PM', 2, 700, NOW(),
 'A1, A2', 'Row A x 2 seats', 'UPI', 'COMPLETED', 'TXN1234567890');

-- Sample payment transaction
INSERT INTO payment_transactions (transaction_id, booking_id, user_email, amount,
                                payment_method, payment_status, transaction_date, upi_id) VALUES
('TXN1234567890', 1, 'test@gmail.com', 700, 'UPI', 'SUCCESS', NOW(), 'test@paytm');

-- =====================================================
-- END OF DATABASE SETUP
-- =====================================================base me koi changes hai?

-- =====================================================
-- SmartShow Ultimate - COMPLETE FULL DATABASE SETUP
-- All Tables with Complete Sample Data + Theatre Rows
-- =====================================================

-- Drop existing database if exists and create fresh
-- Note: Run this part separately if needed
-- DROP DATABASE IF EXISTS cinebook;
-- CREATE DATABASE cinebook;

-- Make sure you're connected to 'cinebook' database before running this script

-- =====================================================
-- DROP EXISTING TABLES IF THEY EXIST
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
-- TABLE CREATION
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

-- Venues table (for comedy shows and concerts)
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

-- Theatre rows table (for movie seat management)
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

-- Bookings table
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
-- ADMIN USER
-- =====================================================

INSERT INTO admin_users (username, password, full_name, email, role) VALUES 
('admin', 'Admin@123', 'System Administrator', 'admin@smartshow.com', 'SUPER_ADMIN');

-- =====================================================
-- ALL 56 THEATRES DATA
-- =====================================================

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

-- =====================================================
-- ALL 10 VENUES FOR COMEDY & CONCERTS
-- =====================================================

INSERT INTO venues (venue_id, name, area, city, venue_type, capacity, available_capacity, base_price, address, facilities) VALUES 
(1, 'Comedy Club Satellite', 'Satellite', 'Ahmedabad', 'Comedy Club', 150, 150, 500, 'Satellite Road, Ahmedabad', 'AC, Sound System, Bar'),
(2, 'Laugh Factory Vastrapur', 'Vastrapur', 'Ahmedabad', 'Comedy Venue', 200, 200, 450, 'Vastrapur, Ahmedabad', 'AC, Stage Lighting'),
(3, 'Stand-Up Central Paldi', 'Paldi', 'Ahmedabad', 'Comedy Hall', 120, 120, 550, 'Paldi, Ahmedabad', 'Premium Sound, AC'),
(4, 'Comedy Corner Thaltej', 'Thaltej', 'Ahmedabad', 'Comedy Club', 180, 180, 480, 'Thaltej, Ahmedabad', 'AC, Sound System, Bar'),
(5, 'Humor Hub Bopal', 'Bopal', 'Ahmedabad', 'Comedy Venue', 160, 160, 520, 'Bopal, Ahmedabad', 'AC, Stage Lighting'),
(6, 'Comedy Central Maninagar', 'Maninagar', 'Ahmedabad', 'Comedy Club', 140, 140, 480, 'Maninagar, Ahmedabad', 'AC, Sound System'),
(7, 'Laugh Lounge Naranpura', 'Naranpura', 'Ahmedabad', 'Comedy Venue', 170, 170, 500, 'Naranpura, Ahmedabad', 'Premium Sound, AC'),
(8, 'Comedy Corner Chandkheda', 'Chandkheda', 'Ahmedabad', 'Comedy Hall', 130, 130, 460, 'Chandkheda, Ahmedabad', 'AC, Stage Lighting'),
(9, 'Concert Hall Satellite', 'Satellite', 'Ahmedabad', 'Concert Venue', 500, 500, 1000, 'Satellite, Ahmedabad', 'Premium Sound, Lighting, VIP Seating'),
(10, 'Music Arena Vastrapur', 'Vastrapur', 'Ahmedabad', 'Music Venue', 300, 300, 1200, 'Vastrapur, Ahmedabad', 'Professional Sound, Stage'),
(11, 'Symphony Hall Paldi', 'Paldi', 'Ahmedabad', 'Concert Venue', 400, 400, 1100, 'Paldi, Ahmedabad', 'Premium Sound, Lighting'),
(12, 'Melody Center Thaltej', 'Thaltej', 'Ahmedabad', 'Music Venue', 350, 350, 1150, 'Thaltej, Ahmedabad', 'Professional Sound, Stage'),
(13, 'Rhythm Palace Bopal', 'Bopal', 'Ahmedabad', 'Concert Venue', 450, 450, 1050, 'Bopal, Ahmedabad', 'Premium Sound, Lighting, VIP Seating'),
(14, 'Music Hall Maninagar', 'Maninagar', 'Ahmedabad', 'Concert Venue', 380, 380, 1080, 'Maninagar, Ahmedabad', 'Professional Sound, Stage'),
(15, 'Concert Arena Naranpura', 'Naranpura', 'Ahmedabad', 'Music Venue', 420, 420, 1120, 'Naranpura, Ahmedabad', 'Premium Sound, Lighting'),
(16, 'Sound Stage Chandkheda', 'Chandkheda', 'Ahmedabad', 'Concert Venue', 360, 360, 1000, 'Chandkheda, Ahmedabad', 'Professional Sound, Stage');

-- =====================================================
-- ALL 40 MOVIES DATA
-- =====================================================

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

-- =====================================================
-- ALL 5 COMEDY SHOWS DATA
-- =====================================================

INSERT INTO comedy_shows (show_id, comedian_name, show_title, show_type, duration_minutes, language, age_rating, description, ticket_price) VALUES 
(1, 'Kapil Sharma', 'The Kapil Sharma Show Live', 'Stand-up Comedy', 90, 'Hindi', '18+', 'Hilarious comedy show with celebrity guests', 500),
(2, 'Zakir Khan', 'Haq Se Single', 'Stand-up Comedy', 85, 'Hindi', '18+', 'Comedy about being single and relationships', 600),
(3, 'Biswa Kalyan Rath', 'Pretentious Movie Reviews', 'Stand-up Comedy', 80, 'English', '18+', 'Funny movie review comedy show', 550),
(4, 'Kenny Sebastian', 'The Most Interesting Person', 'Stand-up Comedy', 75, 'English', '16+', 'Observational comedy about daily life', 650),
(5, 'Abhishek Upmanyu', 'Thoda Saaf Bol', 'Stand-up Comedy', 85, 'Hindi', '18+', 'Clean comedy show with hilarious stories', 500);

-- =====================================================
-- ALL 5 CONCERTS DATA
-- =====================================================

INSERT INTO concerts (concert_id, artist_name, concert_title, genre, duration_minutes, language, ticket_price, description, special_guests) VALUES 
(1, 'Arijit Singh', 'Arijit Singh Live in Concert', 'Bollywood', 120, 'Hindi', 1000, 'Romantic Bollywood hits live performance', 'Shreya Ghoshal'),
(2, 'A.R. Rahman', 'Rahman Live Concert Experience', 'Classical/Fusion', 150, 'Multi', 1500, 'Musical maestro live with orchestra', 'Hariharan, Kailash Kher'),
(3, 'Nucleya', 'Electronic Dance Night', 'Electronic', 90, 'Instrumental', 800, 'High energy EDM night with DJ sets', 'Divine, KSHMR'),
(4, 'Rahat Fateh Ali Khan', 'Sufi Night Live', 'Sufi', 100, 'Urdu', 1200, 'Spiritual Sufi music experience', 'Kailash Kher'),
(5, 'Sunidhi Chauhan', 'Bollywood Diva Live', 'Bollywood', 110, 'Hindi', 900, 'Energetic Bollywood performance', 'Shaan, Rahat Fateh Ali Khan');

-- =====================================================
-- COMPLETE THEATRE ROWS DATA FOR NEXT 7 DAYS
-- =====================================================

-- Generate theatre rows for all theatres, all show times, for next 7 days
-- This creates seat availability for all possible combinations

-- First, let's create a function to generate dates
DO $$
DECLARE
    theatre_rec RECORD;
    date_counter INTEGER;
    current_date_val DATE;
    show_times TEXT[] := ARRAY[
        '10:00 AM', '10:15 AM', '10:30 AM', '10:45 AM', '11:00 AM', '11:15 AM', '11:30 AM', '11:45 AM',
        '12:00 PM', '12:15 PM', '12:30 PM', '12:45 PM', '1:00 PM', '1:15 PM', '1:30 PM', '1:45 PM',
        '2:00 PM', '2:15 PM', '2:30 PM', '2:45 PM', '3:00 PM', '3:15 PM', '3:30 PM', '3:45 PM',
        '4:00 PM', '4:15 PM', '4:30 PM', '4:45 PM', '5:00 PM', '5:15 PM', '5:30 PM', '5:45 PM',
        '6:00 PM', '6:15 PM', '6:30 PM', '6:45 PM', '7:00 PM', '7:15 PM', '7:30 PM', '7:45 PM',
        '8:00 PM', '8:15 PM', '8:30 PM', '8:45 PM', '9:00 PM', '9:15 PM', '9:30 PM', '9:45 PM',
        '10:00 PM', '10:15 PM', '10:30 PM', '10:45 PM'
    ];
    show_time TEXT;
    row_config RECORD;
BEGIN
    -- Loop through next 7 days
    FOR date_counter IN 0..6 LOOP
        current_date_val := CURRENT_DATE + date_counter;
        
        -- Loop through all theatres
        FOR theatre_rec IN SELECT theater_id FROM theatres LOOP
            
            -- Loop through all show times
            FOREACH show_time IN ARRAY show_times LOOP
                
                -- Determine seat configuration based on theatre ID
                IF theatre_rec.theater_id <= 7 THEN
                    -- Theatres 1-7 (120 seats): A=30, B=35, C=30, D=15, E=10
                    INSERT INTO theatre_rows (theatre_id, row_name, show_date, show_time, total_seats, available_seats, price_multiplier)
                    VALUES 
                        (theatre_rec.theater_id, 'A', current_date_val, show_time, 30, 30, 1.5),
                        (theatre_rec.theater_id, 'B', current_date_val, show_time, 35, 35, 1.2),
                        (theatre_rec.theater_id, 'C', current_date_val, show_time, 30, 30, 1.0),
                        (theatre_rec.theater_id, 'D', current_date_val, show_time, 15, 15, 0.8),
                        (theatre_rec.theater_id, 'E', current_date_val, show_time, 10, 10, 0.7);
                        
                ELSIF theatre_rec.theater_id <= 14 THEN
                    -- Theatres 8-14 (90 seats): A=25, B=30, C=20, D=15
                    INSERT INTO theatre_rows (theatre_id, row_name, show_date, show_time, total_seats, available_seats, price_multiplier)
                    VALUES 
                        (theatre_rec.theater_id, 'A', current_date_val, show_time, 25, 25, 1.5),
                        (theatre_rec.theater_id, 'B', current_date_val, show_time, 30, 30, 1.2),
                        (theatre_rec.theater_id, 'C', current_date_val, show_time, 20, 20, 1.0),
                        (theatre_rec.theater_id, 'D', current_date_val, show_time, 15, 15, 0.8);
                        
                ELSIF theatre_rec.theater_id <= 21 THEN
                    -- Theatres 15-21 (105 seats): A=30, B=35, C=25, D=15
                    INSERT INTO theatre_rows (theatre_id, row_name, show_date, show_time, total_seats, available_seats, price_multiplier)
                    VALUES 
                        (theatre_rec.theater_id, 'A', current_date_val, show_time, 30, 30, 1.5),
                        (theatre_rec.theater_id, 'B', current_date_val, show_time, 35, 35, 1.2),
                        (theatre_rec.theater_id, 'C', current_date_val, show_time, 25, 25, 1.0),
                        (theatre_rec.theater_id, 'D', current_date_val, show_time, 15, 15, 0.8);
                        
                ELSIF theatre_rec.theater_id <= 28 THEN
                    -- Theatres 22-28 (75 seats): A=20, B=25, C=20, D=10
                    INSERT INTO theatre_rows (theatre_id, row_name, show_date, show_time, total_seats, available_seats, price_multiplier)
                    VALUES 
                        (theatre_rec.theater_id, 'A', current_date_val, show_time, 20, 20, 1.5),
                        (theatre_rec.theater_id, 'B', current_date_val, show_time, 25, 25, 1.2),
                        (theatre_rec.theater_id, 'C', current_date_val, show_time, 20, 20, 1.0),
                        (theatre_rec.theater_id, 'D', current_date_val, show_time, 10, 10, 0.8);
                        
                ELSIF theatre_rec.theater_id <= 35 THEN
                    -- Theatres 29-35 (60 seats): A=20, B=25, C=15
                    INSERT INTO theatre_rows (theatre_id, row_name, show_date, show_time, total_seats, available_seats, price_multiplier)
                    VALUES 
                        (theatre_rec.theater_id, 'A', current_date_val, show_time, 20, 20, 1.5),
                        (theatre_rec.theater_id, 'B', current_date_val, show_time, 25, 25, 1.2),
                        (theatre_rec.theater_id, 'C', current_date_val, show_time, 15, 15, 1.0);
                        
                ELSIF theatre_rec.theater_id <= 42 THEN
                    -- Theatres 36-42 (85 seats): A=25, B=30, C=20, D=10
                    INSERT INTO theatre_rows (theatre_id, row_name, show_date, show_time, total_seats, available_seats, price_multiplier)
                    VALUES 
                        (theatre_rec.theater_id, 'A', current_date_val, show_time, 25, 25, 1.5),
                        (theatre_rec.theater_id, 'B', current_date_val, show_time, 30, 30, 1.2),
                        (theatre_rec.theater_id, 'C', current_date_val, show_time, 20, 20, 1.0),
                        (theatre_rec.theater_id, 'D', current_date_val, show_time, 10, 10, 0.8);
                        
                ELSIF theatre_rec.theater_id <= 49 THEN
                    -- Theatres 43-49 (70 seats): A=20, B=25, C=15, D=10
                    INSERT INTO theatre_rows (theatre_id, row_name, show_date, show_time, total_seats, available_seats, price_multiplier)
                    VALUES 
                        (theatre_rec.theater_id, 'A', current_date_val, show_time, 20, 20, 1.5),
                        (theatre_rec.theater_id, 'B', current_date_val, show_time, 25, 25, 1.2),
                        (theatre_rec.theater_id, 'C', current_date_val, show_time, 15, 15, 1.0),
                        (theatre_rec.theater_id, 'D', current_date_val, show_time, 10, 10, 0.8);
                        
                ELSE
                    -- Theatres 50-56 (70 seats): A=20, B=25, C=15, D=10
                    INSERT INTO theatre_rows (theatre_id, row_name, show_date, show_time, total_seats, available_seats, price_multiplier)
                    VALUES 
                        (theatre_rec.theater_id, 'A', current_date_val, show_time, 20, 20, 1.5),
                        (theatre_rec.theater_id, 'B', current_date_val, show_time, 25, 25, 1.2),
                        (theatre_rec.theater_id, 'C', current_date_val, show_time, 15, 15, 1.0),
                        (theatre_rec.theater_id, 'D', current_date_val, show_time, 10, 10, 0.8);
                END IF;
                
            END LOOP;
        END LOOP;
    END LOOP;
END $$;

-- =====================================================
-- SAMPLE USERS FOR TESTING
-- =====================================================

INSERT INTO users (name, email, password, password_display, area) VALUES 
('Test User Satellite', 'test1@gmail.com', 'Test@123', 'Test@123', 'Satellite'),
('Test User Vastrapur', 'test2@gmail.com', 'Test@123', 'Test@123', 'Vastrapur'),
('Test User Paldi', 'test3@gmail.com', 'Test@123', 'Test@123', 'Paldi'),
('Test User Thaltej', 'test4@gmail.com', 'Test@123', 'Test@123', 'Thaltej'),
('Test User Bopal', 'test5@gmail.com', 'Test@123', 'Test@123', 'Bopal'),
('Test User Maninagar', 'test6@gmail.com', 'Test@123', 'Test@123', 'Maninagar'),
('Test User Naranpura', 'test7@gmail.com', 'Test@123', 'Test@123', 'Naranpura'),
('Test User Chandkheda', 'test8@gmail.com', 'Test@123', 'Test@123', 'Chandkheda'),
('Demo User', 'demo@gmail.com', 'Demo@123', 'Demo@123', 'Satellite'),
('Admin Test', 'admintest@gmail.com', 'Admin@123', 'Admin@123', 'Vastrapur');

-- =====================================================
-- SAMPLE BOOKINGS FOR TESTING
-- =====================================================

INSERT INTO bookings (user_email, event_type, event_id, event_name, venue_id, venue_name, show_date, show_time, booked_seats, total_amount, booking_date, seat_numbers, row_details, payment_method, payment_status, transaction_id, base_amount, gst_amount, platform_fee, theatre_share, profit_amount) VALUES 
('test1@gmail.com', 'movie', 1, 'Titanic', 1, 'PVR Satellite Plaza', CURRENT_DATE + 1, '7:00 PM', 2, 1050, CURRENT_TIMESTAMP, 'A1, A2', 'Row A x 2 seats', 'UPI', 'COMPLETED', 'TXN1234567890', 890, 160, 89, 534, 267),
('test2@gmail.com', 'comedy', 1, 'The Kapil Sharma Show Live', 1, 'Comedy Club Satellite', CURRENT_DATE + 2, '8:00 PM', 3, 1500, CURRENT_TIMESTAMP, 'S1, S2, S3', 'General Seating x 3 tickets', 'Credit/Debit Card', 'COMPLETED', 'TXN1234567891', 1271, 229, 127, 763, 381),
('test3@gmail.com', 'concert', 1, 'Arijit Singh Live in Concert', 9, 'Concert Hall Satellite', CURRENT_DATE + 3, '9:00 PM', 2, 2000, CURRENT_TIMESTAMP, 'C1, C2', 'General Seating x 2 tickets', 'Net Banking', 'COMPLETED', 'TXN1234567892', 1695, 305, 170, 1017, 508);

-- =====================================================
-- SAMPLE PAYMENT TRANSACTIONS
-- =====================================================

INSERT INTO payment_transactions (transaction_id, booking_id, user_email, amount, payment_method, payment_status, transaction_date, upi_id) VALUES 
('TXN1234567890', 1, 'test1@gmail.com', 1050, 'UPI', 'SUCCESS', CURRENT_TIMESTAMP, 'test1@paytm'),
('TXN1234567891', 2, 'test2@gmail.com', 1500, 'Credit/Debit Card', 'SUCCESS', CURRENT_TIMESTAMP, NULL),
('TXN1234567892', 3, 'test3@gmail.com', 2000, 'Net Banking', 'SUCCESS', CURRENT_TIMESTAMP, NULL);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_area ON users(area);
CREATE INDEX idx_bookings_user_email ON bookings(user_email);
CREATE INDEX idx_bookings_event_type ON bookings(event_type);
CREATE INDEX idx_bookings_show_date ON bookings(show_date);
CREATE INDEX idx_bookings_booking_date ON bookings(booking_date);
CREATE INDEX idx_theatre_rows_theatre_date_time ON theatre_rows(theatre_id, show_date, show_time);
CREATE INDEX idx_theatre_rows_show_date ON theatre_rows(show_date);
CREATE INDEX idx_theatres_area ON theatres(area);
CREATE INDEX idx_venues_area ON venues(area);
CREATE INDEX idx_venues_venue_type ON venues(venue_type);
CREATE INDEX idx_movies_mood ON movies(mood);
CREATE INDEX idx_payment_transactions_status ON payment_transactions(payment_status);

-- =====================================================
-- DATABASE STATISTICS AND SUMMARY
-- =====================================================

-- Display comprehensive database statistics
SELECT 
    'SmartShow Ultimate - COMPLETE DATABASE SETUP FINISHED!' as status,
    '✅ ALL DATA LOADED SUCCESSFULLY' as result;

SELECT 
    'TABLES CREATED' as category,
    COUNT(*) as count
FROM information_schema.tables 
WHERE table_schema = 'public';

SELECT 
    'Total Theatres' as item,
    COUNT(*) as count
FROM theatres
UNION ALL
SELECT 
    'Total Movies' as item,
    COUNT(*) as count
FROM movies
UNION ALL
SELECT 
    'Total Comedy Shows' as item,
    COUNT(*) as count
FROM comedy_shows
UNION ALL
SELECT 
    'Total Concerts' as item,
    COUNT(*) as count
FROM concerts
UNION ALL
SELECT 
    'Total Venues' as item,
    COUNT(*) as count
FROM venues
UNION ALL
SELECT 
    'Total Theatre Rows Created' as item,
    COUNT(*) as count
FROM theatre_rows
UNION ALL
SELECT 
    'Total Test Users' as item,
    COUNT(*) as count
FROM users
UNION ALL
SELECT 
    'Total Sample Bookings' as item,
    COUNT(*) as count
FROM bookings;

-- Show login credentials
SELECT 
    'LOGIN CREDENTIALS' as category,
    'admin / Admin@123' as admin_login,
    'test1@gmail.com / Test@123' as test_user_1,
    'demo@gmail.com / Demo@123' as demo_user;

-- Show areas covered
SELECT 
    'AREAS COVERED' as category,
    STRING_AGG(DISTINCT area, ', ') as all_areas
FROM theatres;

-- Show theatre rows statistics
SELECT 
    'THEATRE ROWS STATISTICS' as category,
    COUNT(DISTINCT theatre_id) as theatres_with_seats,
    COUNT(DISTINCT show_date) as days_covered,
    COUNT(DISTINCT show_time) as unique_show_times,
    COUNT(*) as total_seat_rows
FROM theatre_rows;

SELECT '🎉 DATABASE SETUP COMPLETE - READY TO USE! 🎉' as final_message;
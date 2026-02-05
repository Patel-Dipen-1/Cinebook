-- SmartShow Ultimate Enhanced Database - 15 Comedy Shows & 15 Concerts
-- Complete database setup with all tables and enhanced sample data

-- Drop existing database and recreate
DROP DATABASE IF EXISTS cinebook;
CREATE DATABASE cinebook;

-- Connect to cinebook database
\c cinebook;

-- Drop all tables if they exist
DROP TABLE IF EXISTS payment_transactions CASCADE;
DROP TABLE IF EXISTS bookings CASCADE; 
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

-- Create Admin users table
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

-- Create Comedy shows table
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
    transaction_id VARCHAR(100),
    base_amount INTEGER DEFAULT 0,
    gst_amount INTEGER DEFAULT 0,
    platform_fee INTEGER DEFAULT 0,
    theatre_share INTEGER DEFAULT 0,
    profit_amount INTEGER DEFAULT 0
);

-- Create Payment transactions table
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

-- Insert Admin user
INSERT INTO admin_users (username, password, full_name, email, role)
VALUES ('admin', 'Admin@123', 'System Administrator', 'admin@smartshow.com', 'SUPER_ADMIN');

-- Insert Theatres (7 theatres per area, 8 areas = 56 total theatres)
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

-- Insert Enhanced Venues (32 total - 16 comedy + 16 concert venues, 2 per area)
INSERT INTO venues (venue_id, name, area, city, venue_type, capacity, available_capacity, base_price, address, facilities) VALUES
-- Comedy Venues (1-16) - 2 per area
(1, 'Comedy Club Satellite', 'Satellite', 'Ahmedabad', 'Comedy Club', 150, 150, 500, 'Satellite Road, Ahmedabad', 'AC, Sound System, Bar'),
(2, 'Laugh Factory Satellite', 'Satellite', 'Ahmedabad', 'Comedy Venue', 120, 120, 450, 'Satellite Plaza, Ahmedabad', 'AC, Stage Lighting'),
(3, 'Stand-Up Central Vastrapur', 'Vastrapur', 'Ahmedabad', 'Comedy Hall', 180, 180, 550, 'Vastrapur Lake, Ahmedabad', 'Premium Sound, AC'),
(4, 'Comedy Corner Vastrapur', 'Vastrapur', 'Ahmedabad', 'Comedy Club', 140, 140, 480, 'Vastrapur Mall, Ahmedabad', 'AC, Sound System, Bar'),
(5, 'Humor Hub Paldi', 'Paldi', 'Ahmedabad', 'Comedy Venue', 160, 160, 520, 'Paldi Central, Ahmedabad', 'AC, Stage Lighting'),
(6, 'Laugh Lounge Paldi', 'Paldi', 'Ahmedabad', 'Comedy Club', 130, 130, 480, 'Paldi Plaza, Ahmedabad', 'AC, Sound System'),
(7, 'Comedy Central Thaltej', 'Thaltej', 'Ahmedabad', 'Comedy Hall', 170, 170, 500, 'Thaltej Mall, Ahmedabad', 'Premium Sound, AC'),
(8, 'Stand-Up Stage Thaltej', 'Thaltej', 'Ahmedabad', 'Comedy Venue', 145, 145, 460, 'Thaltej Plaza, Ahmedabad', 'AC, Stage Lighting'),
(9, 'Humor House Bopal', 'Bopal', 'Ahmedabad', 'Comedy Club', 155, 155, 490, 'Bopal Square, Ahmedabad', 'AC, Sound System, Bar'),
(10, 'Comedy Corner Bopal', 'Bopal', 'Ahmedabad', 'Comedy Venue', 135, 135, 470, 'Bopal Mall, Ahmedabad', 'AC, Stage Lighting'),
(11, 'Laugh Factory Maninagar', 'Maninagar', 'Ahmedabad', 'Comedy Hall', 165, 165, 510, 'Maninagar Central, Ahmedabad', 'Premium Sound, AC'),
(12, 'Comedy Club Maninagar', 'Maninagar', 'Ahmedabad', 'Comedy Club', 125, 125, 450, 'Maninagar Plaza, Ahmedabad', 'AC, Sound System'),
(13, 'Stand-Up Central Naranpura', 'Naranpura', 'Ahmedabad', 'Comedy Venue', 175, 175, 530, 'Naranpura Mall, Ahmedabad', 'AC, Stage Lighting'),
(14, 'Humor Hub Naranpura', 'Naranpura', 'Ahmedabad', 'Comedy Club', 150, 150, 500, 'Naranpura Plaza, Ahmedabad', 'AC, Sound System, Bar'),
(15, 'Comedy Corner Chandkheda', 'Chandkheda', 'Ahmedabad', 'Comedy Hall', 140, 140, 480, 'Chandkheda Central, Ahmedabad', 'Premium Sound, AC'),
(16, 'Laugh Lounge Chandkheda', 'Chandkheda', 'Ahmedabad', 'Comedy Venue', 160, 160, 520, 'Chandkheda Mall, Ahmedabad', 'AC, Stage Lighting'),

-- Concert Venues (17-32) - 2 per area
(17, 'Concert Hall Satellite', 'Satellite', 'Ahmedabad', 'Concert Venue', 500, 500, 1000, 'Satellite Plaza, Ahmedabad', 'Premium Sound, Lighting, VIP Seating'),
(18, 'Music Arena Satellite', 'Satellite', 'Ahmedabad', 'Music Venue', 400, 400, 1200, 'Satellite Road, Ahmedabad', 'Professional Sound, Stage'),
(19, 'Symphony Hall Vastrapur', 'Vastrapur', 'Ahmedabad', 'Concert Venue', 600, 600, 1100, 'Vastrapur Lake, Ahmedabad', 'Premium Sound, Lighting'),
(20, 'Melody Center Vastrapur', 'Vastrapur', 'Ahmedabad', 'Music Venue', 450, 450, 1150, 'Vastrapur Mall, Ahmedabad', 'Professional Sound, Stage'),
(21, 'Rhythm Palace Paldi', 'Paldi', 'Ahmedabad', 'Concert Venue', 550, 550, 1050, 'Paldi Central, Ahmedabad', 'Premium Sound, Lighting, VIP Seating'),
(22, 'Music Hall Paldi', 'Paldi', 'Ahmedabad', 'Concert Venue', 480, 480, 1080, 'Paldi Plaza, Ahmedabad', 'Professional Sound, Stage'),
(23, 'Concert Arena Thaltej', 'Thaltej', 'Ahmedabad', 'Music Venue', 520, 520, 1120, 'Thaltej Mall, Ahmedabad', 'Premium Sound, Lighting'),
(24, 'Sound Stage Thaltej', 'Thaltej', 'Ahmedabad', 'Concert Venue', 460, 460, 1000, 'Thaltej Plaza, Ahmedabad', 'Professional Sound, Stage'),
(25, 'Music Palace Bopal', 'Bopal', 'Ahmedabad', 'Concert Venue', 580, 580, 1180, 'Bopal Square, Ahmedabad', 'Premium Sound, Lighting, VIP Seating'),
(26, 'Concert Hall Bopal', 'Bopal', 'Ahmedabad', 'Music Venue', 420, 420, 1020, 'Bopal Mall, Ahmedabad', 'Professional Sound, Stage'),
(27, 'Symphony Center Maninagar', 'Maninagar', 'Ahmedabad', 'Concert Venue', 540, 540, 1140, 'Maninagar Central, Ahmedabad', 'Premium Sound, Lighting'),
(28, 'Music Arena Maninagar', 'Maninagar', 'Ahmedabad', 'Concert Venue', 380, 380, 980, 'Maninagar Plaza, Ahmedabad', 'Professional Sound, Stage'),
(29, 'Rhythm Hall Naranpura', 'Naranpura', 'Ahmedabad', 'Music Venue', 620, 620, 1220, 'Naranpura Mall, Ahmedabad', 'Premium Sound, Lighting'),
(30, 'Concert Palace Naranpura', 'Naranpura', 'Ahmedabad', 'Concert Venue', 500, 500, 1100, 'Naranpura Plaza, Ahmedabad', 'Professional Sound, Stage'),
(31, 'Music Hall Chandkheda', 'Chandkheda', 'Ahmedabad', 'Concert Venue', 560, 560, 1160, 'Chandkheda Central, Ahmedabad', 'Premium Sound, Lighting, VIP Seating'),
(32, 'Sound Arena Chandkheda', 'Chandkheda', 'Ahmedabad', 'Music Venue', 440, 440, 1040, 'Chandkheda Mall, Ahmedabad', 'Professional Sound, Stage');

-- Insert Movies (40 movies - 4 moods, 10 each)
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

-- 🎭 ENHANCED COMEDY SHOWS - 15 Shows
INSERT INTO comedy_shows (show_id, comedian_name, show_title, show_type, duration_minutes, language, age_rating, description, ticket_price) VALUES
(1, 'Kapil Sharma', 'The Kapil Sharma Show Live', 'Stand-up Comedy', 90, 'Hindi', '18+', 'Hilarious comedy show with celebrity guests', 500),
(2, 'Zakir Khan', 'Haq Se Single', 'Stand-up Comedy', 85, 'Hindi', '18+', 'Comedy about being single and relationships', 600),
(3, 'Biswa Kalyan Rath', 'Pretentious Movie Reviews', 'Stand-up Comedy', 80, 'English', '18+', 'Movie review comedy with witty observations', 550),
(4, 'Kenny Sebastian', 'The Most Interesting Person', 'Stand-up Comedy', 75, 'English', '16+', 'Observational comedy about everyday life', 650),
(5, 'Abhishek Upmanyu', 'Thoda Saaf Bol', 'Stand-up Comedy', 85, 'Hindi', '18+', 'Clean comedy show with relatable humor', 500),
(6, 'Vir Das', 'Abroad Understanding', 'Stand-up Comedy', 95, 'English', '18+', 'International comedy with cultural observations', 700),
(7, 'Kanan Gill', 'Keep It Real', 'Stand-up Comedy', 80, 'English', '16+', 'Honest comedy about modern life', 580),
(8, 'Sapan Verma', 'Obsessive Compulsive Disorder', 'Stand-up Comedy', 75, 'English', '18+', 'Comedy about quirks and habits', 520),
(9, 'Anubhav Singh Bassi', 'Bas Kar Bassi', 'Stand-up Comedy', 90, 'Hindi', '18+', 'Storytelling comedy with personal anecdotes', 620),
(10, 'Rahul Subramanian', 'Kal Main Udega', 'Stand-up Comedy', 85, 'English', '16+', 'Witty comedy about aspirations and failures', 560),
(11, 'Kunal Kamra', 'Shut Up Ya Kunal', 'Stand-up Comedy', 80, 'Hindi', '18+', 'Political satire and social commentary', 540),
(12, 'Abish Mathew', 'Whoop!', 'Stand-up Comedy', 75, 'English', '16+', 'Energetic comedy with crowd interaction', 580),
(13, 'Sumukhi Suresh', 'Don''t Tell Amma', 'Stand-up Comedy', 85, 'English', '18+', 'Female perspective comedy with bold humor', 600),
(14, 'Prashasti Singh', 'Sassy Singh', 'Stand-up Comedy', 80, 'Hindi', '18+', 'Sassy comedy about relationships and society', 520),
(15, 'Rohan Joshi', 'Wake N Bake', 'Stand-up Comedy', 90, 'English', '18+', 'Comedy about millennial struggles', 640);

-- 🎵 ENHANCED CONCERTS - 15 Concerts
INSERT INTO concerts (concert_id, artist_name, concert_title, genre, duration_minutes, language, ticket_price, description, special_guests) VALUES
(1, 'Arijit Singh', 'Arijit Singh Live in Concert', 'Bollywood', 120, 'Hindi', 1000, 'Romantic Bollywood hits by the king of melody', 'Shreya Ghoshal'),
(2, 'A.R. Rahman', 'Rahman Live - Musical Journey', 'Classical/Fusion', 150, 'Multi', 1500, 'Musical maestro performing his greatest hits', 'Hariharan, Kailash Kher'),
(3, 'Nucleya', 'Electronic Dance Night', 'Electronic', 90, 'Instrumental', 800, 'High-energy EDM night with bass drops', 'Divine, KSHMR'),
(4, 'Rahat Fateh Ali Khan', 'Sufi Night - Ishq Sufiana', 'Sufi', 100, 'Urdu', 1200, 'Spiritual Sufi music for the soul', 'Kailash Kher'),
(5, 'Sunidhi Chauhan', 'Bollywood Diva Live', 'Bollywood', 110, 'Hindi', 900, 'Energetic performance by Bollywood''s powerhouse', 'Shaan'),
(6, 'Shreya Ghoshal', 'Melody Queen Live', 'Classical/Bollywood', 130, 'Hindi', 1100, 'Classical and Bollywood melodies', 'Ustad Rahat Fateh Ali Khan'),
(7, 'Sonu Nigam', 'Voice of Bollywood', 'Bollywood', 125, 'Hindi', 1000, 'Versatile singer performing across genres', 'Alka Yagnik'),
(8, 'Armaan Malik', 'Next Gen Bollywood', 'Pop/Bollywood', 100, 'Hindi', 850, 'Young sensation with contemporary hits', 'Asees Kaur'),
(9, 'Neha Kakkar', 'Queen of Pop', 'Pop/Bollywood', 105, 'Hindi', 950, 'Peppy numbers and dance tracks', 'Tony Kakkar'),
(10, 'Badshah', 'Rap King Live', 'Hip-Hop/Rap', 95, 'Hindi', 900, 'High-energy rap and hip-hop performance', 'Aastha Gill'),
(11, 'Divine', 'Gully Gang Live', 'Hip-Hop/Rap', 85, 'Hindi', 750, 'Underground rap and street music', 'Naezy'),
(12, 'Kailash Kher', 'Sufi Rock Fusion', 'Sufi Rock', 115, 'Hindi', 1050, 'Unique blend of Sufi and rock music', 'Papon'),
(13, 'Hariharan', 'Ghazal Maestro', 'Ghazal/Classical', 120, 'Hindi/Urdu', 1200, 'Soulful ghazals and classical music', 'Chitra'),
(14, 'Shaan', 'Bollywood Unplugged', 'Acoustic/Bollywood', 110, 'Hindi', 950, 'Acoustic versions of popular Bollywood songs', 'Raghav Sachar'),
(15, 'Mohit Chauhan', 'Rockstar Live', 'Rock/Bollywood', 115, 'Hindi', 1000, 'Rock ballads and Bollywood chartbusters', 'Shilpa Rao');

-- Create indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_bookings_user_email ON bookings(user_email);
CREATE INDEX idx_bookings_event_type ON bookings(event_type);
CREATE INDEX idx_theatres_area ON theatres(area);
CREATE INDEX idx_venues_area ON venues(area);
CREATE INDEX idx_venues_type ON venues(venue_type);
CREATE INDEX idx_movies_mood ON movies(mood);

-- Display summary
SELECT 'Database Setup Complete!' as status;
SELECT 'Total Movies: ' || COUNT(*) as movies_count FROM movies;
SELECT 'Total Comedy Shows: ' || COUNT(*) as comedy_count FROM comedy_shows;
SELECT 'Total Concerts: ' || COUNT(*) as concerts_count FROM concerts;
SELECT 'Total Theatres: ' || COUNT(*) as theatres_count FROM theatres;
SELECT 'Total Venues: ' || COUNT(*) as venues_count FROM venues;
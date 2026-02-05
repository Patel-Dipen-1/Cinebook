-- =====================================================
-- SmartShow Ultimate - Database Setup (FIXED VERSION)
-- Step-by-step setup without connection commands
-- =====================================================

-- =====================================================
-- STEP 1: CREATE DATABASE (Run this first)
-- =====================================================
-- Run these commands separately in psql:
-- DROP DATABASE IF EXISTS cinebook;
-- CREATE DATABASE cinebook;
-- Then connect to cinebook database and run rest of the script

-- =====================================================
-- TABLE CREATION
-- =====================================================

-- Users table
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
);

-- Admin users table
CREATE TABLE IF NOT EXISTS admin_users (
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
);

-- Movies table
CREATE TABLE IF NOT EXISTS movies (
    id INTEGER PRIMARY KEY,
    movie_name VARCHAR(100) NOT NULL,
    mood VARCHAR(50) NOT NULL,
    duration_minutes INTEGER DEFAULT 150,
    rating VARCHAR(10) DEFAULT 'U/A',
    language VARCHAR(50) DEFAULT 'Hindi'
);

-- Comedy shows table
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
);

-- Concerts table
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
);

-- Venues table
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
);

-- Theatre rows table
CREATE TABLE IF NOT EXISTS theatre_rows (
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
);

-- Payment transactions table
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
);

-- =====================================================
-- INSERT ADMIN USER
-- =====================================================

INSERT INTO admin_users (username, password, full_name, email, role) 
VALUES ('admin', 'Admin@123', 'System Administrator', 'admin@smartshow.com', 'SUPER_ADMIN')
ON CONFLICT (username) DO NOTHING;

-- =====================================================
-- INSERT SAMPLE USERS
-- =====================================================

INSERT INTO users (name, email, password, password_display, area) VALUES 
('Test User Satellite', 'test1@gmail.com', 'Test@123', 'Test@123', 'Satellite'),
('Test User Vastrapur', 'test2@gmail.com', 'Test@123', 'Test@123', 'Vastrapur'),
('Test User Paldi', 'test3@gmail.com', 'Test@123', 'Test@123', 'Paldi'),
('Demo User', 'demo@gmail.com', 'Demo@123', 'Demo@123', 'Satellite')
ON CONFLICT (email) DO NOTHING;

-- =====================================================
-- INSERT ALL THEATRES (56 TOTAL)
-- =====================================================

INSERT INTO theatres (theater_id, name, area, city, theater_type, total_screens, base_price, total_seats, available_seats, address) VALUES 
-- Satellite Area (1-7)
(1, 'PVR Satellite Plaza', 'Satellite', 'Ahmedabad', 'Premium', 8, 350, 120, 120, 'Satellite Plaza, Satellite, Ahmedabad'),
(2, 'INOX Satellite Mall', 'Satellite', 'Ahmedabad', 'Premium', 6, 320, 90, 90, 'Satellite Mall, Satellite, Ahmedabad'),
(3, 'Cinepolis Satellite Square', 'Satellite', 'Ahmedabad', 'Multiplex', 7, 300, 105, 105, 'Satellite Square, Satellite, Ahmedabad'),
(4, 'Fun Cinemas Satellite', 'Satellite', 'Ahmedabad', 'Multiplex', 5, 280, 75, 75, 'Satellite Road, Satellite, Ahmedabad'),
(5, 'Rajhans Satellite', 'Satellite', 'Ahmedabad', 'Standard', 4, 250, 60, 60, 'Satellite Circle, Satellite, Ahmedabad'),
(6, 'Carnival Satellite', 'Satellite', 'Ahmedabad', 'Multiplex', 6, 290, 85, 85, 'Satellite Cross Roads, Satellite, Ahmedabad'),
(7, 'Miraj Satellite', 'Satellite', 'Ahmedabad', 'Standard', 5, 270, 70, 70, 'Satellite Garden, Satellite, Ahmedabad'),

-- Vastrapur Area (8-14)
(8, 'PVR Vastrapur Lake', 'Vastrapur', 'Ahmedabad', 'Premium', 8, 360, 120, 120, 'Vastrapur Lake, Vastrapur, Ahmedabad'),
(9, 'INOX Vastrapur Mall', 'Vastrapur', 'Ahmedabad', 'Premium', 6, 330, 90, 90, 'Vastrapur Mall, Vastrapur, Ahmedabad'),
(10, 'Cinepolis Vastrapur', 'Vastrapur', 'Ahmedabad', 'Multiplex', 7, 310, 105, 105, 'Vastrapur Main Road, Vastrapur, Ahmedabad'),
(11, 'Fun Cinemas Vastrapur', 'Vastrapur', 'Ahmedabad', 'Multiplex', 5, 290, 75, 75, 'Vastrapur Circle, Vastrapur, Ahmedabad'),
(12, 'Rajhans Vastrapur', 'Vastrapur', 'Ahmedabad', 'Standard', 4, 260, 60, 60, 'Vastrapur Garden, Vastrapur, Ahmedabad'),
(13, 'Carnival Vastrapur', 'Vastrapur', 'Ahmedabad', 'Multiplex', 6, 300, 85, 85, 'Vastrapur Cross Roads, Vastrapur, Ahmedabad'),
(14, 'Miraj Vastrapur', 'Vastrapur', 'Ahmedabad', 'Standard', 5, 280, 70, 70, 'Vastrapur Square, Vastrapur, Ahmedabad'),

-- Paldi Area (15-21)
(15, 'PVR Paldi Central', 'Paldi', 'Ahmedabad', 'Premium', 8, 340, 120, 120, 'Paldi Central, Paldi, Ahmedabad'),
(16, 'INOX Paldi Plaza', 'Paldi', 'Ahmedabad', 'Premium', 6, 310, 90, 90, 'Paldi Plaza, Paldi, Ahmedabad'),
(17, 'Cinepolis Paldi', 'Paldi', 'Ahmedabad', 'Multiplex', 7, 290, 105, 105, 'Paldi Main Road, Paldi, Ahmedabad'),
(18, 'Fun Cinemas Paldi', 'Paldi', 'Ahmedabad', 'Multiplex', 5, 270, 75, 75, 'Paldi Circle, Paldi, Ahmedabad'),
(19, 'Rajhans Paldi', 'Paldi', 'Ahmedabad', 'Standard', 4, 240, 60, 60, 'Paldi Garden, Paldi, Ahmedabad'),
(20, 'Carnival Paldi', 'Paldi', 'Ahmedabad', 'Multiplex', 6, 280, 85, 85, 'Paldi Cross Roads, Paldi, Ahmedabad'),
(21, 'Miraj Paldi', 'Paldi', 'Ahmedabad', 'Standard', 5, 260, 70, 70, 'Paldi Square, Paldi, Ahmedabad'),

-- Thaltej Area (22-28)
(22, 'PVR Thaltej Mall', 'Thaltej', 'Ahmedabad', 'Premium', 8, 370, 120, 120, 'Thaltej Mall, Thaltej, Ahmedabad'),
(23, 'INOX Thaltej Plaza', 'Thaltej', 'Ahmedabad', 'Premium', 6, 340, 90, 90, 'Thaltej Plaza, Thaltej, Ahmedabad'),
(24, 'Cinepolis Thaltej', 'Thaltej', 'Ahmedabad', 'Multiplex', 7, 320, 105, 105, 'Thaltej Cross Roads, Thaltej, Ahmedabad'),
(25, 'Fun Cinemas Thaltej', 'Thaltej', 'Ahmedabad', 'Multiplex', 5, 300, 75, 75, 'Thaltej Circle, Thaltej, Ahmedabad'),
(26, 'Rajhans Thaltej', 'Thaltej', 'Ahmedabad', 'Standard', 4, 270, 60, 60, 'Thaltej Garden, Thaltej, Ahmedabad'),
(27, 'Carnival Thaltej', 'Thaltej', 'Ahmedabad', 'Multiplex', 6, 310, 85, 85, 'Thaltej Square, Thaltej, Ahmedabad'),
(28, 'Miraj Thaltej', 'Thaltej', 'Ahmedabad', 'Standard', 5, 290, 70, 70, 'Thaltej Park, Thaltej, Ahmedabad'),

-- Bopal Area (29-35)
(29, 'PVR Bopal Square', 'Bopal', 'Ahmedabad', 'Premium', 8, 350, 120, 120, 'Bopal Square, Bopal, Ahmedabad'),
(30, 'INOX Bopal Mall', 'Bopal', 'Ahmedabad', 'Premium', 6, 320, 90, 90, 'Bopal Mall, Bopal, Ahmedabad'),
(31, 'Cinepolis Bopal', 'Bopal', 'Ahmedabad', 'Multiplex', 7, 300, 105, 105, 'Bopal Main Road, Bopal, Ahmedabad'),
(32, 'Fun Cinemas Bopal', 'Bopal', 'Ahmedabad', 'Multiplex', 5, 280, 75, 75, 'Bopal Circle, Bopal, Ahmedabad'),
(33, 'Rajhans Bopal', 'Bopal', 'Ahmedabad', 'Standard', 4, 250, 60, 60, 'Bopal Garden, Bopal, Ahmedabad'),
(34, 'Carnival Bopal', 'Bopal', 'Ahmedabad', 'Multiplex', 6, 290, 85, 85, 'Bopal Cross Roads, Bopal, Ahmedabad'),
(35, 'Miraj Bopal', 'Bopal', 'Ahmedabad', 'Standard', 5, 270, 70, 70, 'Bopal Park, Bopal, Ahmedabad'),

-- Maninagar Area (36-42)
(36, 'PVR Maninagar Central', 'Maninagar', 'Ahmedabad', 'Premium', 8, 340, 120, 120, 'Maninagar Central, Maninagar, Ahmedabad'),
(37, 'INOX Maninagar Plaza', 'Maninagar', 'Ahmedabad', 'Premium', 6, 310, 90, 90, 'Maninagar Plaza, Maninagar, Ahmedabad'),
(38, 'Cinepolis Maninagar', 'Maninagar', 'Ahmedabad', 'Multiplex', 7, 290, 105, 105, 'Maninagar Main Road, Maninagar, Ahmedabad'),
(39, 'Fun Cinemas Maninagar', 'Maninagar', 'Ahmedabad', 'Multiplex', 5, 270, 75, 75, 'Maninagar Circle, Maninagar, Ahmedabad'),
(40, 'Rajhans Maninagar', 'Maninagar', 'Ahmedabad', 'Standard', 4, 240, 60, 60, 'Maninagar Garden, Maninagar, Ahmedabad'),
(41, 'Carnival Maninagar', 'Maninagar', 'Ahmedabad', 'Multiplex', 6, 280, 85, 85, 'Maninagar Cross Roads, Maninagar, Ahmedabad'),
(42, 'Miraj Maninagar', 'Maninagar', 'Ahmedabad', 'Standard', 5, 260, 70, 70, 'Maninagar Square, Maninagar, Ahmedabad'),

-- Naranpura Area (43-49)
(43, 'PVR Naranpura Mall', 'Naranpura', 'Ahmedabad', 'Premium', 8, 360, 120, 120, 'Naranpura Mall, Naranpura, Ahmedabad'),
(44, 'INOX Naranpura Plaza', 'Naranpura', 'Ahmedabad', 'Premium', 6, 330, 90, 90, 'Naranpura Plaza, Naranpura, Ahmedabad'),
(45, 'Cinepolis Naranpura', 'Naranpura', 'Ahmedabad', 'Multiplex', 7, 310, 105, 105, 'Naranpura Main Road, Naranpura, Ahmedabad'),
(46, 'Fun Cinemas Naranpura', 'Naranpura', 'Ahmedabad', 'Multiplex', 5, 290, 75, 75, 'Naranpura Circle, Naranpura, Ahmedabad'),
(47, 'Rajhans Naranpura', 'Naranpura', 'Ahmedabad', 'Standard', 4, 260, 60, 60, 'Naranpura Garden, Naranpura, Ahmedabad'),
(48, 'Carnival Naranpura', 'Naranpura', 'Ahmedabad', 'Multiplex', 6, 300, 85, 85, 'Naranpura Cross Roads, Naranpura, Ahmedabad'),
(49, 'Miraj Naranpura', 'Naranpura', 'Ahmedabad', 'Standard', 5, 280, 70, 70, 'Naranpura Square, Naranpura, Ahmedabad'),

-- Chandkheda Area (50-56)
(50, 'PVR Chandkheda Central', 'Chandkheda', 'Ahmedabad', 'Premium', 8, 350, 120, 120, 'Chandkheda Central, Chandkheda, Ahmedabad'),
(51, 'INOX Chandkheda Mall', 'Chandkheda', 'Ahmedabad', 'Premium', 6, 320, 90, 90, 'Chandkheda Mall, Chandkheda, Ahmedabad'),
(52, 'Cinepolis Chandkheda', 'Chandkheda', 'Ahmedabad', 'Multiplex', 7, 300, 105, 105, 'Chandkheda Main Road, Chandkheda, Ahmedabad'),
(53, 'Fun Cinemas Chandkheda', 'Chandkheda', 'Ahmedabad', 'Multiplex', 5, 280, 75, 75, 'Chandkheda Circle, Chandkheda, Ahmedabad'),
(54, 'Rajhans Chandkheda', 'Chandkheda', 'Ahmedabad', 'Standard', 4, 250, 60, 60, 'Chandkheda Garden, Chandkheda, Ahmedabad'),
(55, 'Carnival Chandkheda', 'Chandkheda', 'Ahmedabad', 'Multiplex', 6, 290, 85, 85, 'Chandkheda Cross Roads, Chandkheda, Ahmedabad'),
(56, 'Miraj Chandkheda', 'Chandkheda', 'Ahmedabad', 'Standard', 5, 270, 70, 70, 'Chandkheda Square, Chandkheda, Ahmedabad')
ON CONFLICT (theater_id) DO NOTHING;

-- =====================================================
-- INSERT ALL VENUES (16 TOTAL)
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
(16, 'Sound Stage Chandkheda', 'Chandkheda', 'Ahmedabad', 'Concert Venue', 360, 360, 1000, 'Chandkheda, Ahmedabad', 'Professional Sound, Stage')
ON CONFLICT (venue_id) DO NOTHING;

-- =====================================================
-- INSERT ALL MOVIES (40 TOTAL)
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
(40, 'The Incredibles', 'Family', 115, 'PG', 'English')
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- INSERT COMEDY SHOWS (5 TOTAL)
-- =====================================================

INSERT INTO comedy_shows (show_id, comedian_name, show_title, show_type, duration_minutes, language, age_rating, description, ticket_price) VALUES 
(1, 'Kapil Sharma', 'The Kapil Sharma Show Live', 'Stand-up Comedy', 90, 'Hindi', '18+', 'Hilarious comedy show with celebrity guests', 500),
(2, 'Zakir Khan', 'Haq Se Single', 'Stand-up Comedy', 85, 'Hindi', '18+', 'Comedy about being single and relationships', 600),
(3, 'Biswa Kalyan Rath', 'Pretentious Movie Reviews', 'Stand-up Comedy', 80, 'English', '18+', 'Funny movie review comedy show', 550),
(4, 'Kenny Sebastian', 'The Most Interesting Person', 'Stand-up Comedy', 75, 'English', '16+', 'Observational comedy about daily life', 650),
(5, 'Abhishek Upmanyu', 'Thoda Saaf Bol', 'Stand-up Comedy', 85, 'Hindi', '18+', 'Clean comedy show with hilarious stories', 500)
ON CONFLICT (show_id) DO NOTHING;

-- =====================================================
-- INSERT CONCERTS (5 TOTAL)
-- =====================================================

INSERT INTO concerts (concert_id, artist_name, concert_title, genre, duration_minutes, language, ticket_price, description, special_guests) VALUES 
(1, 'Arijit Singh', 'Arijit Singh Live in Concert', 'Bollywood', 120, 'Hindi', 1000, 'Romantic Bollywood hits live performance', 'Shreya Ghoshal'),
(2, 'A.R. Rahman', 'Rahman Live Concert Experience', 'Classical/Fusion', 150, 'Multi', 1500, 'Musical maestro live with orchestra', 'Hariharan, Kailash Kher'),
(3, 'Nucleya', 'Electronic Dance Night', 'Electronic', 90, 'Instrumental', 800, 'High energy EDM night with DJ sets', 'Divine, KSHMR'),
(4, 'Rahat Fateh Ali Khan', 'Sufi Night Live', 'Sufi', 100, 'Urdu', 1200, 'Spiritual Sufi music experience', 'Kailash Kher'),
(5, 'Sunidhi Chauhan', 'Bollywood Diva Live', 'Bollywood', 110, 'Hindi', 900, 'Energetic Bollywood performance', 'Shaan, Rahat Fateh Ali Khan')
ON CONFLICT (concert_id) DO NOTHING;

-- =====================================================
-- CREATE INDEXES FOR PERFORMANCE
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_area ON users(area);
CREATE INDEX IF NOT EXISTS idx_bookings_user_email ON bookings(user_email);
CREATE INDEX IF NOT EXISTS idx_bookings_event_type ON bookings(event_type);
CREATE INDEX IF NOT EXISTS idx_bookings_show_date ON bookings(show_date);
CREATE INDEX IF NOT EXISTS idx_theatre_rows_theatre_date_time ON theatre_rows(theatre_id, show_date, show_time);
CREATE INDEX IF NOT EXISTS idx_theatres_area ON theatres(area);
CREATE INDEX IF NOT EXISTS idx_venues_area ON venues(area);
CREATE INDEX IF NOT EXISTS idx_movies_mood ON movies(mood);

-- =====================================================
-- DISPLAY SUCCESS MESSAGE
-- =====================================================

SELECT 
    '🎉 SmartShow Ultimate Database Setup Complete! 🎉' as status,
    'Ready to use with Streamlit app!' as message;

SELECT 
    'LOGIN CREDENTIALS' as info,
    'Admin: admin / Admin@123' as admin_login,
    'Test User: test1@gmail.com / Test@123' as test_user;

SELECT 
    'TOTAL DATA LOADED' as category,
    (SELECT COUNT(*) FROM theatres) as theatres,
    (SELECT COUNT(*) FROM movies) as movies,
    (SELECT COUNT(*) FROM comedy_shows) as comedy_shows,
    (SELECT COUNT(*) FROM concerts) as concerts,
    (SELECT COUNT(*) FROM venues) as venues,
    (SELECT COUNT(*) FROM users) as test_users;
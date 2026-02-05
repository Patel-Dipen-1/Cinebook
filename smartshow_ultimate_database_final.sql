-- SmartShow Ultimate - Final Database Setup (Fixed Version)
-- This database fixes all issues including the "out of tuple range" error

-- =====================================================
-- DATABASE CREATION AND SETUP
-- =====================================================

-- Create database (run this first if database doesn't exist)
-- CREATE DATABASE cinebook;

-- Connect to the database
-- \c cinebook;

-- =====================================================
-- DROP EXISTING TABLES (Clean Slate)
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
-- CREATE TABLES WITH ENHANCED STRUCTURE
-- =====================================================

-- Users table with enhanced fields
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(10) NOT NULL,
    password_display VARCHAR(20) NOT NULL,
    area VARCHAR(100) NOT NULL,
    otp VARCHAR(10),
    otp_expiry TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    booking_count INTEGER DEFAULT 0,
    total_spent INTEGER DEFAULT 0
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
    last_login TIMESTAMP,
    permissions TEXT DEFAULT 'read,write,delete'
);

-- Theatres table with enhanced structure
CREATE TABLE theatres (
    theater_id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    area VARCHAR(100) NOT NULL,
    city VARCHAR(50) DEFAULT 'Ahmedabad',
    theater_type VARCHAR(50) NOT NULL,
    total_screens INTEGER NOT NULL,
    base_price INTEGER DEFAULT 250,
    total_seats INTEGER DEFAULT 50,
    available_seats INTEGER DEFAULT 50,
    address TEXT NOT NULL,
    facilities TEXT,
    rating DECIMAL(3,1) DEFAULT 4.0,
    contact_number VARCHAR(15),
    email VARCHAR(100)
);

-- Movies table with comprehensive details
CREATE TABLE movies (
    id INTEGER PRIMARY KEY,
    movie_name VARCHAR(100) NOT NULL,
    mood VARCHAR(50) NOT NULL,
    duration_minutes INTEGER DEFAULT 150,
    rating VARCHAR(10) DEFAULT 'U/A',
    language VARCHAR(50) DEFAULT 'Hindi',
    genre VARCHAR(100),
    director VARCHAR(100),
    cast_members TEXT,
    description TEXT,
    poster_url VARCHAR(255),
    release_date DATE,
    imdb_rating DECIMAL(3,1),
    box_office_collection BIGINT
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
    ticket_price INTEGER DEFAULT 500,
    comedian_bio TEXT,
    social_media_handles TEXT,
    special_requirements TEXT
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
    special_guests TEXT,
    artist_bio TEXT,
    album_releases TEXT,
    awards TEXT,
    social_media_handles TEXT
);

-- Venues table with detailed information
CREATE TABLE venues (
    venue_id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    area VARCHAR(100) NOT NULL,
    city VARCHAR(50) DEFAULT 'Ahmedabad',
    venue_type VARCHAR(50) NOT NULL,
    capacity INTEGER DEFAULT 200,
    available_capacity INTEGER DEFAULT 200,
    base_price INTEGER DEFAULT 500,
    address TEXT NOT NULL,
    facilities TEXT,
    parking_capacity INTEGER DEFAULT 50,
    accessibility_features TEXT,
    contact_number VARCHAR(15),
    email VARCHAR(100),
    website VARCHAR(255)
);

-- Theatre rows table with advanced seat management
CREATE TABLE theatre_rows (
    id SERIAL PRIMARY KEY,
    theatre_id INTEGER NOT NULL,
    row_name VARCHAR(5) NOT NULL,
    show_date DATE NOT NULL,
    show_time VARCHAR(20) NOT NULL,
    total_seats INTEGER NOT NULL,
    available_seats INTEGER NOT NULL,
    price_multiplier DECIMAL(3,2) DEFAULT 1.0,
    seat_type VARCHAR(20) DEFAULT 'Regular',
    amenities TEXT,
    FOREIGN KEY (theatre_id) REFERENCES theatres(theater_id),
    UNIQUE (theatre_id, row_name, show_date, show_time)
);

-- Enhanced bookings table with comprehensive tracking
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
    profit_amount INTEGER DEFAULT 0,
    discount_applied INTEGER DEFAULT 0,
    coupon_code VARCHAR(50),
    booking_source VARCHAR(50) DEFAULT 'WEB',
    customer_rating INTEGER,
    feedback TEXT
);

-- Payment transactions table with detailed tracking
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
    bank_name VARCHAR(100),
    failure_reason TEXT,
    gateway_response TEXT,
    processing_fee INTEGER DEFAULT 0,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

-- =====================================================
-- INSERT COMPREHENSIVE SAMPLE DATA
-- =====================================================

-- Insert admin user
INSERT INTO admin_users (username, password, full_name, email, role, permissions)
VALUES ('admin', 'Admin@123', 'System Administrator', 'admin@smartshow.com', 'SUPER_ADMIN', 'read,write,delete,manage_users,view_analytics');

-- Insert comprehensive theatre data (56 theatres across 8 areas)
INSERT INTO theatres (theater_id, name, area, city, theater_type, total_screens, base_price, total_seats, available_seats, address, facilities, rating, contact_number, email) VALUES
-- Satellite Area Theatres (1-7)
(1, 'PVR Satellite Plaza', 'Satellite', 'Ahmedabad', 'Premium', 8, 350, 120, 120, 'Satellite Plaza, Satellite, Ahmedabad', 'IMAX, Dolby Atmos, Recliner Seats, Food Court', 4.5, '079-12345001', 'satellite@pvr.com'),
(2, 'INOX Satellite Mall', 'Satellite', 'Ahmedabad', 'Premium', 6, 320, 90, 90, 'Satellite Mall, Satellite, Ahmedabad', 'Dolby Digital, Premium Seating, Cafe', 4.3, '079-12345002', 'satellite@inox.com'),
(3, 'Cinepolis Satellite Square', 'Satellite', 'Ahmedabad', 'Multiplex', 7, 300, 105, 105, 'Satellite Square, Satellite, Ahmedabad', '4DX, VIP Lounge, Gaming Zone', 4.2, '079-12345003', 'satellite@cinepolis.com'),
(4, 'Fun Cinemas Satellite', 'Satellite', 'Ahmedabad', 'Multiplex', 5, 280, 75, 75, 'Satellite Road, Satellite, Ahmedabad', 'Digital Projection, Surround Sound', 4.0, '079-12345004', 'satellite@funcinemas.com'),
(5, 'Rajhans Satellite', 'Satellite', 'Ahmedabad', 'Standard', 4, 250, 60, 60, 'Satellite Circle, Satellite, Ahmedabad', 'AC, Digital Sound', 3.8, '079-12345005', 'satellite@rajhans.com'),
(6, 'Carnival Satellite', 'Satellite', 'Ahmedabad', 'Multiplex', 6, 290, 85, 85, 'Satellite Cross Roads, Satellite, Ahmedabad', 'Premium Sound, Comfortable Seating', 4.1, '079-12345006', 'satellite@carnival.com'),
(7, 'Miraj Satellite', 'Satellite', 'Ahmedabad', 'Standard', 5, 270, 70, 70, 'Satellite Garden, Satellite, Ahmedabad', 'Digital Projection, AC', 3.9, '079-12345007', 'satellite@miraj.com'),

-- Vastrapur Area Theatres (8-14)
(8, 'PVR Vastrapur Lake', 'Vastrapur', 'Ahmedabad', 'Premium', 8, 360, 120, 120, 'Vastrapur Lake, Vastrapur, Ahmedabad', 'IMAX, Dolby Atmos, Director Cut', 4.6, '079-12345008', 'vastrapur@pvr.com'),
(9, 'INOX Vastrapur Mall', 'Vastrapur', 'Ahmedabad', 'Premium', 6, 330, 90, 90, 'Vastrapur Mall, Vastrapur, Ahmedabad', 'Dolby Digital, Luxury Seating', 4.4, '079-12345009', 'vastrapur@inox.com'),
(10, 'Cinepolis Vastrapur', 'Vastrapur', 'Ahmedabad', 'Multiplex', 7, 310, 105, 105, 'Vastrapur Main Road, Vastrapur, Ahmedabad', '4DX, VIP Experience', 4.3, '079-12345010', 'vastrapur@cinepolis.com'),
(11, 'Fun Cinemas Vastrapur', 'Vastrapur', 'Ahmedabad', 'Multiplex', 5, 290, 75, 75, 'Vastrapur Circle, Vastrapur, Ahmedabad', 'Digital Projection, Snack Bar', 4.0, '079-12345011', 'vastrapur@funcinemas.com'),
(12, 'Rajhans Vastrapur', 'Vastrapur', 'Ahmedabad', 'Standard', 4, 260, 60, 60, 'Vastrapur Garden, Vastrapur, Ahmedabad', 'AC, Digital Sound', 3.8, '079-12345012', 'vastrapur@rajhans.com'),
(13, 'Carnival Vastrapur', 'Vastrapur', 'Ahmedabad', 'Multiplex', 6, 300, 85, 85, 'Vastrapur Cross Roads, Vastrapur, Ahmedabad', 'Premium Audio, Comfortable Seats', 4.1, '079-12345013', 'vastrapur@carnival.com'),
(14, 'Miraj Vastrapur', 'Vastrapur', 'Ahmedabad', 'Standard', 5, 280, 70, 70, 'Vastrapur Square, Vastrapur, Ahmedabad', 'Digital Projection, AC', 3.9, '079-12345014', 'vastrapur@miraj.com'),

-- Paldi Area Theatres (15-21)
(15, 'PVR Paldi Central', 'Paldi', 'Ahmedabad', 'Premium', 8, 340, 120, 120, 'Paldi Central, Paldi, Ahmedabad', 'IMAX, Premium Dining', 4.5, '079-12345015', 'paldi@pvr.com'),
(16, 'INOX Paldi Plaza', 'Paldi', 'Ahmedabad', 'Premium', 6, 310, 90, 90, 'Paldi Plaza, Paldi, Ahmedabad', 'Dolby Atmos, Luxury Seats', 4.3, '079-12345016', 'paldi@inox.com'),
(17, 'Cinepolis Paldi', 'Paldi', 'Ahmedabad', 'Multiplex', 7, 290, 105, 105, 'Paldi Main Road, Paldi, Ahmedabad', '4DX, Gaming Zone', 4.2, '079-12345017', 'paldi@cinepolis.com'),
(18, 'Fun Cinemas Paldi', 'Paldi', 'Ahmedabad', 'Multiplex', 5, 270, 75, 75, 'Paldi Circle, Paldi, Ahmedabad', 'Digital Sound, Cafe', 4.0, '079-12345018', 'paldi@funcinemas.com'),
(19, 'Rajhans Paldi', 'Paldi', 'Ahmedabad', 'Standard', 4, 240, 60, 60, 'Paldi Garden, Paldi, Ahmedabad', 'AC, Digital Projection', 3.8, '079-12345019', 'paldi@rajhans.com'),
(20, 'Carnival Paldi', 'Paldi', 'Ahmedabad', 'Multiplex', 6, 280, 85, 85, 'Paldi Cross Roads, Paldi, Ahmedabad', 'Premium Sound, Snack Bar', 4.1, '079-12345020', 'paldi@carnival.com'),
(21, 'Miraj Paldi', 'Paldi', 'Ahmedabad', 'Standard', 5, 260, 70, 70, 'Paldi Square, Paldi, Ahmedabad', 'Digital Projection, AC', 3.9, '079-12345021', 'paldi@miraj.com'),

-- Thaltej Area Theatres (22-28)
(22, 'PVR Thaltej Mall', 'Thaltej', 'Ahmedabad', 'Premium', 8, 370, 120, 120, 'Thaltej Mall, Thaltej, Ahmedabad', 'IMAX, Premium Dining', 4.6, '079-12345022', 'thaltej@pvr.com'),
(23, 'INOX Thaltej Plaza', 'Thaltej', 'Ahmedabad', 'Premium', 6, 340, 90, 90, 'Thaltej Plaza, Thaltej, Ahmedabad', 'Dolby Atmos, VIP Seating', 4.4, '079-12345023', 'thaltej@inox.com'),
(24, 'Cinepolis Thaltej', 'Thaltej', 'Ahmedabad', 'Multiplex', 7, 320, 105, 105, 'Thaltej Cross Roads, Thaltej, Ahmedabad', '4DX, Gaming Zone', 4.3, '079-12345024', 'thaltej@cinepolis.com'),
(25, 'Fun Cinemas Thaltej', 'Thaltej', 'Ahmedabad', 'Multiplex', 5, 300, 75, 75, 'Thaltej Circle, Thaltej, Ahmedabad', 'Digital Sound, Cafe', 4.1, '079-12345025', 'thaltej@funcinemas.com'),
(26, 'Rajhans Thaltej', 'Thaltej', 'Ahmedabad', 'Standard', 4, 270, 60, 60, 'Thaltej Garden, Thaltej, Ahmedabad', 'AC, Digital Projection', 3.9, '079-12345026', 'thaltej@rajhans.com'),
(27, 'Carnival Thaltej', 'Thaltej', 'Ahmedabad', 'Multiplex', 6, 310, 85, 85, 'Thaltej Square, Thaltej, Ahmedabad', 'Premium Audio, Snack Bar', 4.2, '079-12345027', 'thaltej@carnival.com'),
(28, 'Miraj Thaltej', 'Thaltej', 'Ahmedabad', 'Standard', 5, 290, 70, 70, 'Thaltej Park, Thaltej, Ahmedabad', 'Digital Projection, AC', 4.0, '079-12345028', 'thaltej@miraj.com'),

-- Bopal Area Theatres (29-35)
(29, 'PVR Bopal Square', 'Bopal', 'Ahmedabad', 'Premium', 8, 350, 120, 120, 'Bopal Square, Bopal, Ahmedabad', 'IMAX, Premium Seating', 4.5, '079-12345029', 'bopal@pvr.com'),
(30, 'INOX Bopal Mall', 'Bopal', 'Ahmedabad', 'Premium', 6, 320, 90, 90, 'Bopal Mall, Bopal, Ahmedabad', 'Dolby Digital, VIP Lounge', 4.3, '079-12345030', 'bopal@inox.com'),
(31, 'Cinepolis Bopal', 'Bopal', 'Ahmedabad', 'Multiplex', 7, 300, 105, 105, 'Bopal Main Road, Bopal, Ahmedabad', '4DX, Gaming Zone', 4.2, '079-12345031', 'bopal@cinepolis.com'),
(32, 'Fun Cinemas Bopal', 'Bopal', 'Ahmedabad', 'Multiplex', 5, 280, 75, 75, 'Bopal Circle, Bopal, Ahmedabad', 'Digital Sound, Cafe', 4.0, '079-12345032', 'bopal@funcinemas.com'),
(33, 'Rajhans Bopal', 'Bopal', 'Ahmedabad', 'Standard', 4, 250, 60, 60, 'Bopal Garden, Bopal, Ahmedabad', 'AC, Digital Projection', 3.8, '079-12345033', 'bopal@rajhans.com'),
(34, 'Carnival Bopal', 'Bopal', 'Ahmedabad', 'Multiplex', 6, 290, 85, 85, 'Bopal Cross Roads, Bopal, Ahmedabad', 'Premium Audio, Snack Bar', 4.1, '079-12345034', 'bopal@carnival.com'),
(35, 'Miraj Bopal', 'Bopal', 'Ahmedabad', 'Standard', 5, 270, 70, 70, 'Bopal Park, Bopal, Ahmedabad', 'Digital Projection, AC', 3.9, '079-12345035', 'bopal@miraj.com'),

-- Maninagar Area Theatres (36-42)
(36, 'PVR Maninagar Central', 'Maninagar', 'Ahmedabad', 'Premium', 8, 340, 120, 120, 'Maninagar Central, Maninagar, Ahmedabad', 'IMAX, Premium Dining', 4.4, '079-12345036', 'maninagar@pvr.com'),
(37, 'INOX Maninagar Plaza', 'Maninagar', 'Ahmedabad', 'Premium', 6, 310, 90, 90, 'Maninagar Plaza, Maninagar, Ahmedabad', 'Dolby Atmos, Luxury Seats', 4.2, '079-12345037', 'maninagar@inox.com'),
(38, 'Cinepolis Maninagar', 'Maninagar', 'Ahmedabad', 'Multiplex', 7, 290, 105, 105, 'Maninagar Main Road, Maninagar, Ahmedabad', '4DX, VIP Experience', 4.1, '079-12345038', 'maninagar@cinepolis.com'),
(39, 'Fun Cinemas Maninagar', 'Maninagar', 'Ahmedabad', 'Multiplex', 5, 270, 75, 75, 'Maninagar Circle, Maninagar, Ahmedabad', 'Digital Sound, Cafe', 3.9, '079-12345039', 'maninagar@funcinemas.com'),
(40, 'Rajhans Maninagar', 'Maninagar', 'Ahmedabad', 'Standard', 4, 240, 60, 60, 'Maninagar Garden, Maninagar, Ahmedabad', 'AC, Digital Projection', 3.7, '079-12345040', 'maninagar@rajhans.com'),
(41, 'Carnival Maninagar', 'Maninagar', 'Ahmedabad', 'Multiplex', 6, 280, 85, 85, 'Maninagar Cross Roads, Maninagar, Ahmedabad', 'Premium Audio, Snack Bar', 4.0, '079-12345041', 'maninagar@carnival.com'),
(42, 'Miraj Maninagar', 'Maninagar', 'Ahmedabad', 'Standard', 5, 260, 70, 70, 'Maninagar Square, Maninagar, Ahmedabad', 'Digital Projection, AC', 3.8, '079-12345042', 'maninagar@miraj.com'),

-- Naranpura Area Theatres (43-49)
(43, 'PVR Naranpura Mall', 'Naranpura', 'Ahmedabad', 'Premium', 8, 360, 120, 120, 'Naranpura Mall, Naranpura, Ahmedabad', 'IMAX, Premium Seating', 4.5, '079-12345043', 'naranpura@pvr.com'),
(44, 'INOX Naranpura Plaza', 'Naranpura', 'Ahmedabad', 'Premium', 6, 330, 90, 90, 'Naranpura Plaza, Naranpura, Ahmedabad', 'Dolby Digital, VIP Lounge', 4.3, '079-12345044', 'naranpura@inox.com'),
(45, 'Cinepolis Naranpura', 'Naranpura', 'Ahmedabad', 'Multiplex', 7, 310, 105, 105, 'Naranpura Main Road, Naranpura, Ahmedabad', '4DX, Gaming Zone', 4.2, '079-12345045', 'naranpura@cinepolis.com'),
(46, 'Fun Cinemas Naranpura', 'Naranpura', 'Ahmedabad', 'Multiplex', 5, 290, 75, 75, 'Naranpura Circle, Naranpura, Ahmedabad', 'Digital Sound, Cafe', 4.0, '079-12345046', 'naranpura@funcinemas.com'),
(47, 'Rajhans Naranpura', 'Naranpura', 'Ahmedabad', 'Standard', 4, 260, 60, 60, 'Naranpura Garden, Naranpura, Ahmedabad', 'AC, Digital Projection', 3.8, '079-12345047', 'naranpura@rajhans.com'),
(48, 'Carnival Naranpura', 'Naranpura', 'Ahmedabad', 'Multiplex', 6, 300, 85, 85, 'Naranpura Cross Roads, Naranpura, Ahmedabad', 'Premium Audio, Snack Bar', 4.1, '079-12345048', 'naranpura@carnival.com'),
(49, 'Miraj Naranpura', 'Naranpura', 'Ahmedabad', 'Standard', 5, 280, 70, 70, 'Naranpura Square, Naranpura, Ahmedabad', 'Digital Projection, AC', 3.9, '079-12345049', 'naranpura@miraj.com'),

-- Chandkheda Area Theatres (50-56)
(50, 'PVR Chandkheda Central', 'Chandkheda', 'Ahmedabad', 'Premium', 8, 350, 120, 120, 'Chandkheda Central, Chandkheda, Ahmedabad', 'IMAX, Premium Dining', 4.4, '079-12345050', 'chandkheda@pvr.com'),
(51, 'INOX Chandkheda Mall', 'Chandkheda', 'Ahmedabad', 'Premium', 6, 320, 90, 90, 'Chandkheda Mall, Chandkheda, Ahmedabad', 'Dolby Atmos, Luxury Seats', 4.2, '079-12345051', 'chandkheda@inox.com'),
(52, 'Cinepolis Chandkheda', 'Chandkheda', 'Ahmedabad', 'Multiplex', 7, 300, 105, 105, 'Chandkheda Main Road, Chandkheda, Ahmedabad', '4DX, VIP Experience', 4.1, '079-12345052', 'chandkheda@cinepolis.com'),
(53, 'Fun Cinemas Chandkheda', 'Chandkheda', 'Ahmedabad', 'Multiplex', 5, 280, 75, 75, 'Chandkheda Circle, Chandkheda, Ahmedabad', 'Digital Sound, Cafe', 3.9, '079-12345053', 'chandkheda@funcinemas.com'),
(54, 'Rajhans Chandkheda', 'Chandkheda', 'Ahmedabad', 'Standard', 4, 250, 60, 60, 'Chandkheda Garden, Chandkheda, Ahmedabad', 'AC, Digital Projection', 3.7, '079-12345054', 'chandkheda@rajhans.com'),
(55, 'Carnival Chandkheda', 'Chandkheda', 'Ahmedabad', 'Multiplex', 6, 290, 85, 85, 'Chandkheda Cross Roads, Chandkheda, Ahmedabad', 'Premium Audio, Snack Bar', 4.0, '079-12345055', 'chandkheda@carnival.com'),
(56, 'Miraj Chandkheda', 'Chandkheda', 'Ahmedabad', 'Standard', 5, 270, 70, 70, 'Chandkheda Square, Chandkheda, Ahmedabad', 'Digital Projection, AC', 3.8, '079-12345056', 'chandkheda@miraj.com');

-- Insert comprehensive movie data (40 movies with detailed information)
INSERT INTO movies (id, movie_name, mood, duration_minutes, rating, language, genre, director, cast_members, description, release_date, imdb_rating) VALUES
-- Romantic Movies (1-10)
(1, 'Titanic', 'Romantic', 195, 'PG-13', 'English', 'Romance/Drama', 'James Cameron', 'Leonardo DiCaprio, Kate Winslet', 'Epic romance aboard the ill-fated ship', '1997-12-19', 7.8),
(2, 'The Notebook', 'Romantic', 123, 'PG-13', 'English', 'Romance/Drama', 'Nick Cassavetes', 'Ryan Gosling, Rachel McAdams', 'A timeless love story', '2004-06-25', 7.8),
(3, 'La La Land', 'Romantic', 128, 'PG-13', 'English', 'Romance/Musical', 'Damien Chazelle', 'Ryan Gosling, Emma Stone', 'Modern musical romance', '2016-12-09', 8.0),
(4, 'Dilwale Dulhania Le Jayenge', 'Romantic', 189, 'U', 'Hindi', 'Romance/Drama', 'Aditya Chopra', 'Shah Rukh Khan, Kajol', 'Classic Bollywood romance', '1995-10-20', 8.1),
(5, 'Jab We Met', 'Romantic', 138, 'U', 'Hindi', 'Romance/Comedy', 'Imtiaz Ali', 'Shahid Kapoor, Kareena Kapoor', 'Journey of love and self-discovery', '2007-10-26', 7.9),
(6, 'Casablanca', 'Romantic', 102, 'PG', 'English', 'Romance/Drama', 'Michael Curtiz', 'Humphrey Bogart, Ingrid Bergman', 'Classic wartime romance', '1942-11-26', 8.5),
(7, 'Yeh Jawaani Hai Deewani', 'Romantic', 161, 'U', 'Hindi', 'Romance/Comedy', 'Ayan Mukerji', 'Ranbir Kapoor, Deepika Padukone', 'Coming-of-age romance', '2013-05-31', 7.2),
(8, 'Before Sunrise', 'Romantic', 101, 'R', 'English', 'Romance/Drama', 'Richard Linklater', 'Ethan Hawke, Julie Delpy', 'One night in Vienna', '1995-01-27', 8.1),
(9, 'Zindagi Na Milegi Dobara', 'Romantic', 155, 'U/A', 'Hindi', 'Romance/Adventure', 'Zoya Akhtar', 'Hrithik Roshan, Katrina Kaif', 'Life-changing Spanish adventure', '2011-07-15', 8.2),
(10, 'The Princess Bride', 'Romantic', 98, 'PG', 'English', 'Romance/Adventure', 'Rob Reiner', 'Cary Elwes, Robin Wright', 'Fairy tale romance', '1987-09-25', 8.0),

-- Action Movies (11-20)
(11, 'Avengers: Endgame', 'Action', 181, 'PG-13', 'English', 'Action/Sci-Fi', 'Russo Brothers', 'Robert Downey Jr., Chris Evans', 'Epic superhero finale', '2019-04-26', 8.4),
(12, 'Fast & Furious 9', 'Action', 143, 'PG-13', 'English', 'Action/Thriller', 'Justin Lin', 'Vin Diesel, Michelle Rodriguez', 'High-octane action', '2021-06-25', 5.2),
(13, 'Baahubali 2', 'Action', 167, 'U/A', 'Hindi', 'Action/Drama', 'S.S. Rajamouli', 'Prabhas, Rana Daggubati', 'Epic Indian action saga', '2017-04-28', 8.7),
(14, 'KGF Chapter 2', 'Action', 168, 'U/A', 'Hindi', 'Action/Drama', 'Prashanth Neel', 'Yash, Sanjay Dutt', 'Mass action entertainer', '2022-04-14', 8.4),
(15, 'Pathaan', 'Action', 146, 'U/A', 'Hindi', 'Action/Thriller', 'Siddharth Anand', 'Shah Rukh Khan, Deepika Padukone', 'Spy action thriller', '2023-01-25', 5.7),
(16, 'Mad Max: Fury Road', 'Action', 120, 'R', 'English', 'Action/Sci-Fi', 'George Miller', 'Tom Hardy, Charlize Theron', 'Post-apocalyptic action', '2015-05-15', 8.1),
(17, 'War', 'Action', 156, 'U/A', 'Hindi', 'Action/Thriller', 'Siddharth Anand', 'Hrithik Roshan, Tiger Shroff', 'High-tech action thriller', '2019-10-02', 6.5),
(18, 'John Wick', 'Action', 101, 'R', 'English', 'Action/Thriller', 'Chad Stahelski', 'Keanu Reeves, Michael Nyqvist', 'Stylized action revenge', '2014-10-24', 7.4),
(19, 'Pushpa', 'Action', 179, 'U/A', 'Hindi', 'Action/Drama', 'Sukumar', 'Allu Arjun, Rashmika Mandanna', 'Mass action drama', '2021-12-17', 7.6),
(20, 'Mission Impossible', 'Action', 147, 'PG-13', 'English', 'Action/Thriller', 'Christopher McQuarrie', 'Tom Cruise, Rebecca Ferguson', 'Impossible missions', '2018-07-27', 7.7),

-- Comedy Movies (21-30)
(21, 'Hera Pheri', 'Comedy', 156, 'U', 'Hindi', 'Comedy', 'Priyadarshan', 'Akshay Kumar, Suniel Shetty, Paresh Rawal', 'Classic Bollywood comedy', '2000-03-31', 8.2),
(22, 'Golmaal', 'Comedy', 150, 'U', 'Hindi', 'Comedy', 'Rohit Shetty', 'Ajay Devgn, Arshad Warsi', 'Fun-filled comedy', '2006-07-14', 7.4),
(23, 'Andaz Apna Apna', 'Comedy', 160, 'U', 'Hindi', 'Comedy', 'Rajkumar Santoshi', 'Aamir Khan, Salman Khan', 'Cult comedy classic', '1994-11-04', 8.2),
(24, 'Welcome', 'Comedy', 159, 'U', 'Hindi', 'Comedy', 'Anees Bazmee', 'Akshay Kumar, Katrina Kaif', 'Comedy of errors', '2007-12-21', 7.0),
(25, 'Housefull', 'Comedy', 140, 'U/A', 'Hindi', 'Comedy', 'Sajid Khan', 'Akshay Kumar, Deepika Padukone', 'Multi-starrer comedy', '2010-04-30', 5.5),
(26, 'The Hangover', 'Comedy', 100, 'R', 'English', 'Comedy', 'Todd Phillips', 'Bradley Cooper, Ed Helms', 'Vegas bachelor party gone wrong', '2009-06-05', 7.7),
(27, 'Munna Bhai MBBS', 'Comedy', 156, 'U', 'Hindi', 'Comedy/Drama', 'Rajkumar Hirani', 'Sanjay Dutt, Arshad Warsi', 'Heartwarming comedy', '2003-12-19', 8.1),
(28, 'Superbad', 'Comedy', 113, 'R', 'English', 'Comedy', 'Greg Mottola', 'Jonah Hill, Michael Cera', 'Teen comedy', '2007-08-17', 7.6),
(29, 'Fukrey', 'Comedy', 139, 'U/A', 'Hindi', 'Comedy', 'Mrighdeep Singh Lamba', 'Pulkit Samrat, Varun Sharma', 'Delhi boys comedy', '2013-06-14', 6.9),
(30, 'Dumb and Dumber', 'Comedy', 107, 'PG-13', 'English', 'Comedy', 'Peter Farrelly', 'Jim Carrey, Jeff Daniels', 'Slapstick comedy', '1994-12-16', 7.3),

-- Family Movies (31-40)
(31, 'Taare Zameen Par', 'Family', 165, 'U', 'Hindi', 'Family/Drama', 'Aamir Khan', 'Aamir Khan, Darsheel Safary', 'Special child story', '2007-12-21', 8.4),
(32, '3 Idiots', 'Family', 170, 'U', 'Hindi', 'Family/Comedy', 'Rajkumar Hirani', 'Aamir Khan, R. Madhavan', 'Engineering college story', '2009-12-25', 8.4),
(33, 'Dangal', 'Family', 161, 'U', 'Hindi', 'Family/Sports', 'Nitesh Tiwari', 'Aamir Khan, Fatima Sana Shaikh', 'Wrestling champions story', '2016-12-23', 8.4),
(34, 'Finding Nemo', 'Family', 100, 'G', 'English', 'Family/Animation', 'Andrew Stanton', 'Albert Brooks, Ellen DeGeneres', 'Father-son underwater adventure', '2003-05-30', 8.2),
(35, 'The Lion King', 'Family', 88, 'G', 'English', 'Family/Animation', 'Roger Allers', 'Matthew Broderick, Jeremy Irons', 'Coming-of-age lion story', '1994-06-24', 8.5),
(36, 'Coco', 'Family', 105, 'PG', 'English', 'Family/Animation', 'Lee Unkrich', 'Anthony Gonzalez, Gael García Bernal', 'Mexican Day of the Dead', '2017-11-22', 8.4),
(37, 'Queen', 'Family', 146, 'U/A', 'Hindi', 'Family/Comedy', 'Vikas Bahl', 'Kangana Ranaut, Rajkummar Rao', 'Solo honeymoon journey', '2013-03-07', 8.2),
(38, 'Toy Story', 'Family', 81, 'G', 'English', 'Family/Animation', 'John Lasseter', 'Tom Hanks, Tim Allen', 'Toys come to life', '1995-11-22', 8.3),
(39, 'Hindi Medium', 'Family', 132, 'U', 'Hindi', 'Family/Comedy', 'Saket Chaudhary', 'Irrfan Khan, Saba Qamar', 'Education system satire', '2017-05-19', 7.9),
(40, 'The Incredibles', 'Family', 115, 'PG', 'English', 'Family/Animation', 'Brad Bird', 'Craig T. Nelson, Holly Hunter', 'Superhero family', '2004-11-05', 8.0);

-- Insert comedy shows with detailed information
INSERT INTO comedy_shows (show_id, comedian_name, show_title, show_type, duration_minutes, language, age_rating, description, ticket_price, comedian_bio, social_media_handles) VALUES
(1, 'Kapil Sharma', 'The Kapil Sharma Show Live', 'Stand-up Comedy', 90, 'Hindi', '18+', 'Hilarious comedy show with celebrity guests', 500, 'Popular Indian comedian and TV host', '@KapilSharmaK9'),
(2, 'Zakir Khan', 'Haq Se Single', 'Stand-up Comedy', 85, 'Hindi', '18+', 'Comedy about being single in India', 600, 'Stand-up comedian and writer', '@zakirkhan_208'),
(3, 'Biswa Kalyan Rath', 'Pretentious Movie Reviews', 'Stand-up Comedy', 80, 'English', '18+', 'Witty movie review comedy', 550, 'Engineer turned comedian', '@biswastweets'),
(4, 'Kenny Sebastian', 'The Most Interesting Person', 'Stand-up Comedy', 75, 'English', '16+', 'Observational comedy about life', 650, 'Musician and comedian', '@kennethseb'),
(5, 'Abhishek Upmanyu', 'Thoda Saaf Bol', 'Stand-up Comedy', 85, 'Hindi', '18+', 'Clean comedy with sharp wit', 500, 'IIT graduate comedian', '@AbhishekUpmanyu');

-- Insert concerts with comprehensive details
INSERT INTO concerts (concert_id, artist_name, concert_title, genre, duration_minutes, language, ticket_price, description, special_guests, artist_bio, awards) VALUES
(1, 'Arijit Singh', 'Arijit Singh Live', 'Bollywood', 120, 'Hindi', 1000, 'Romantic Bollywood hits live', 'Shreya Ghoshal', 'Playback singer with 100+ hit songs', 'Filmfare Awards, National Film Awards'),
(2, 'A.R. Rahman', 'Rahman Live Concert', 'Classical/Fusion', 150, 'Multi', 1500, 'Musical maestro live performance', 'Hariharan', 'Oscar-winning composer', 'Academy Awards, Grammy Awards'),
(3, 'Nucleya', 'Electronic Dance Night', 'Electronic', 90, 'Instrumental', 800, 'High-energy EDM night', 'Divine', 'Pioneer of Indian electronic music', 'MTV EMA nominations'),
(4, 'Rahat Fateh Ali Khan', 'Sufi Night', 'Sufi', 100, 'Urdu', 1200, 'Spiritual Sufi music experience', 'Kailash Kher', 'Renowned Qawwali singer', 'Padma Shri, UNESCO Artist for Peace'),
(5, 'Sunidhi Chauhan', 'Bollywood Diva Live', 'Bollywood', 110, 'Hindi', 900, 'Energetic Bollywood performance', 'Shaan', 'Versatile playback singer', 'Filmfare Awards, National Film Awards');

-- Insert venues with comprehensive information
INSERT INTO venues (venue_id, name, area, city, venue_type, capacity, available_capacity, base_price, address, facilities, parking_capacity, contact_number, email) VALUES
(1, 'Comedy Club Satellite', 'Satellite', 'Ahmedabad', 'Comedy Club', 150, 150, 500, 'Satellite Road, Ahmedabad', 'AC, Professional Sound System, Full Bar, Stage Lighting', 50, '079-22345001', 'satellite@comedyclub.com'),
(2, 'Laugh Factory Vastrapur', 'Vastrapur', 'Ahmedabad', 'Comedy Venue', 200, 200, 450, 'Vastrapur Lake Front, Ahmedabad', 'AC, Stage Lighting, Cafe, VIP Seating', 75, '079-22345002', 'vastrapur@laughfactory.com'),
(3, 'Stand-Up Central Paldi', 'Paldi', 'Ahmedabad', 'Comedy Hall', 120, 120, 550, 'Paldi Cross Roads, Ahmedabad', 'Premium Sound, AC, Intimate Setting', 40, '079-22345003', 'paldi@standupcentral.com'),
(4, 'Comedy Corner Thaltej', 'Thaltej', 'Ahmedabad', 'Comedy Club', 180, 180, 480, 'Thaltej Circle, Ahmedabad', 'AC, Sound System, Full Bar, Open Mic Nights', 60, '079-22345004', 'thaltej@comedycorner.com'),
(5, 'Humor Hub Bopal', 'Bopal', 'Ahmedabad', 'Comedy Venue', 160, 160, 520, 'Bopal Square, Ahmedabad', 'AC, Stage Lighting, Snack Bar', 55, '079-22345005', 'bopal@humorhub.com'),
(6, 'Concert Hall Satellite', 'Satellite', 'Ahmedabad', 'Concert Venue', 500, 500, 1000, 'Satellite Plaza, Ahmedabad', 'Premium Sound, Professional Lighting, VIP Boxes, Full Bar', 200, '079-22345006', 'satellite@concerthall.com'),
(7, 'Music Arena Vastrapur', 'Vastrapur', 'Ahmedabad', 'Music Venue', 300, 300, 1200, 'Vastrapur Lake, Ahmedabad', 'Professional Sound, Stage, Artist Green Room', 120, '079-22345007', 'vastrapur@musicarena.com'),
(8, 'Symphony Hall Paldi', 'Paldi', 'Ahmedabad', 'Concert Venue', 400, 400, 1100, 'Paldi Central, Ahmedabad', 'Acoustic Design, Premium Sound, Orchestra Pit', 150, '079-22345008', 'paldi@symphonyhall.com'),
(9, 'Melody Center Thaltej', 'Thaltej', 'Ahmedabad', 'Music Venue', 350, 350, 1150, 'Thaltej Cross Roads, Ahmedabad', 'Professional Sound, Stage, Recording Facility', 140, '079-22345009', 'thaltej@melodycenter.com'),
(10, 'Rhythm Palace Bopal', 'Bopal', 'Ahmedabad', 'Concert Venue', 450, 450, 1050, 'Bopal Main Road, Ahmedabad', 'Premium Sound, Lighting, VIP Seating, Dance Floor', 180, '079-22345010', 'bopal@rhythmpalace.com');

-- =====================================================
-- CREATE INDEXES FOR PERFORMANCE
-- =====================================================

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_area ON users(area);
CREATE INDEX idx_bookings_user_email ON bookings(user_email);
CREATE INDEX idx_bookings_event_type ON bookings(event_type);
CREATE INDEX idx_bookings_show_date ON bookings(show_date);
CREATE INDEX idx_bookings_booking_date ON bookings(booking_date);
CREATE INDEX idx_theatre_rows_theatre_date_time ON theatre_rows(theatre_id, show_date, show_time);
CREATE INDEX idx_payment_transactions_booking_id ON payment_transactions(booking_id);
CREATE INDEX idx_theatres_area ON theatres(area);
CREATE INDEX idx_venues_area ON venues(area);
CREATE INDEX idx_movies_mood ON movies(mood);

-- =====================================================
-- SAMPLE TEST DATA
-- =====================================================

-- Sample user for testing
INSERT INTO users (name, email, password, password_display, area, booking_count, total_spent) VALUES
('Test User', 'test@gmail.com', 'Test@123', 'Test@123', 'Satellite', 0, 0),
('Demo User', 'demo@gmail.com', 'Demo@123', 'Demo@123', 'Vastrapur', 0, 0);

-- Sample bookings for analytics
INSERT INTO bookings (user_email, event_type, event_id, event_name, venue_id, venue_name, show_date, show_time, booked_seats, total_amount, booking_date, seat_numbers, row_details, payment_method, payment_status, transaction_id, base_amount, gst_amount, platform_fee, theatre_share, profit_amount) VALUES
('test@gmail.com', 'movie', 1, 'Titanic', 1, 'PVR Satellite Plaza', CURRENT_DATE, '7:30 PM', 2, 700, NOW(), 'A1, A2', 'Row A x 2 seats', 'UPI', 'COMPLETED', 'TXN1234567890', 593, 107, 59, 356, 178),
('demo@gmail.com', 'comedy', 1, 'The Kapil Sharma Show Live', 1, 'Comedy Club Satellite', CURRENT_DATE + 1, '8:00 PM', 3, 1500, NOW(), 'S1, S2, S3', 'General Seating x 3 tickets', 'Card', 'COMPLETED', 'TXN1234567891', 1271, 229, 127, 763, 381);

-- =====================================================
-- END OF DATABASE SETUP
-- =====================================================

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;

-- Final message
SELECT 'SmartShow Ultimate Database Setup Complete - Fixed Version!' as status;
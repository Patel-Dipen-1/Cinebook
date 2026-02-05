-- SmartShow Ultimate Advanced - COMPLETE DATABASE
-- Full database for smartshow_ultimate_advanced.py with ALL data
-- This is the complete 603+ line database with all theatres, venues, movies, and features

-- =====================================================
-- DATABASE CREATION AND SETUP
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
-- CREATE ENHANCED TABLES FOR ADVANCED IMPLEMENTATION
-- =====================================================

-- Users table (enhanced for advanced features) - FIXED PASSWORD LENGTH
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(50) NOT NULL,
    password_display VARCHAR(50) NOT NULL,
    area VARCHAR(100) NOT NULL,
    otp VARCHAR(10),
    otp_expiry TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    booking_count INTEGER DEFAULT 0,
    total_spent INTEGER DEFAULT 0,
    user_type VARCHAR(20) DEFAULT 'Regular',
    preferences TEXT
);

-- Admin users table (enhanced)
CREATE TABLE admin_users (
    admin_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    role VARCHAR(50) DEFAULT 'ADMIN',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    permissions TEXT DEFAULT 'read,write,delete',
    status VARCHAR(20) DEFAULT 'Active'
);

-- Theatres table (enhanced with comprehensive details)
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
    address TEXT,
    facilities TEXT,
    rating DECIMAL(3,2) DEFAULT 4.0,
    contact_phone VARCHAR(15),
    manager_name VARCHAR(100),
    parking_available BOOLEAN DEFAULT TRUE,
    food_court BOOLEAN DEFAULT TRUE
);
-- Movies table (enhanced with detailed metadata)
CREATE TABLE movies (
    id INTEGER PRIMARY KEY,
    movie_name VARCHAR(100) NOT NULL,
    mood VARCHAR(50) NOT NULL,
    duration_minutes INTEGER DEFAULT 150,
    rating VARCHAR(10) DEFAULT 'U/A',
    language VARCHAR(50) DEFAULT 'Hindi',
    genre VARCHAR(100),
    director VARCHAR(100),
    cast_info TEXT,
    release_date DATE,
    imdb_rating DECIMAL(3,1),
    description TEXT,
    poster_url VARCHAR(500),
    box_office_collection BIGINT DEFAULT 0,
    awards TEXT
);

-- Comedy shows table (enhanced)
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
    show_rating DECIMAL(3,2) DEFAULT 4.0,
    special_notes TEXT,
    social_media_followers INTEGER DEFAULT 0,
    experience_years INTEGER DEFAULT 5
);

-- Concerts table (enhanced)
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
    concert_type VARCHAR(50) DEFAULT 'Live Performance',
    equipment_info TEXT,
    album_sales INTEGER DEFAULT 0,
    awards_won TEXT
);

-- Venues table (enhanced for comedy and concerts)
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
    facilities TEXT,
    sound_system VARCHAR(100),
    lighting_system VARCHAR(100),
    parking_capacity INTEGER DEFAULT 50,
    accessibility_features TEXT,
    established_year INTEGER DEFAULT 2020,
    venue_rating DECIMAL(3,2) DEFAULT 4.0
);
-- Theatre rows table (enhanced with date and time specific seats)
CREATE TABLE theatre_rows (
    id SERIAL PRIMARY KEY,
    theatre_id INTEGER NOT NULL,
    row_name VARCHAR(5) NOT NULL,
    show_date DATE NOT NULL,
    show_time VARCHAR(20) NOT NULL,
    total_seats INTEGER NOT NULL,
    available_seats INTEGER NOT NULL,
    price_multiplier DECIMAL(3,2) DEFAULT 1.0,
    row_type VARCHAR(20) DEFAULT 'Standard',
    amenities TEXT,
    seat_comfort_level VARCHAR(20) DEFAULT 'Standard',
    FOREIGN KEY (theatre_id) REFERENCES theatres(theater_id),
    UNIQUE (theatre_id, row_name, show_date, show_time)
);

-- Bookings table (enhanced with comprehensive tracking)
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
    booking_source VARCHAR(50) DEFAULT 'Web',
    cancellation_status VARCHAR(20) DEFAULT 'Active',
    user_rating INTEGER DEFAULT 0,
    review_text TEXT,
    booking_reference VARCHAR(50),
    special_requests TEXT
);

-- Payment transactions table (enhanced)
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
    processing_fee INTEGER DEFAULT 0,
    gateway_response TEXT,
    refund_amount INTEGER DEFAULT 0,
    refund_status VARCHAR(20) DEFAULT 'Not Applicable',
    gateway_transaction_id VARCHAR(100),
    payment_gateway VARCHAR(50) DEFAULT 'Razorpay',
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);
-- =====================================================
-- INSERT ENHANCED SAMPLE DATA - ADMIN USERS
-- =====================================================

-- Insert admin users with enhanced permissions
INSERT INTO admin_users (username, password, full_name, email, role, permissions, status) VALUES
('admin', 'Admin@123', 'System Administrator', 'admin@smartshow.com', 'SUPER_ADMIN', 'read,write,delete,analytics,user_management,system_config', 'Active'),
('manager', 'Manager@123', 'Operations Manager', 'manager@smartshow.com', 'MANAGER', 'read,write,analytics,user_management', 'Active'),
('analyst', 'Analyst@123', 'Data Analyst', 'analyst@smartshow.com', 'ANALYST', 'read,analytics', 'Active');

-- =====================================================
-- INSERT ALL THEATRES (56 THEATRES - 7 PER AREA)
-- =====================================================

INSERT INTO theatres (theater_id, name, area, city, theater_type, total_screens, base_price, total_seats, available_seats, address, facilities, rating, contact_phone, manager_name, parking_available, food_court) VALUES

-- Satellite Area Theatres (1-7)
(1, 'PVR Satellite Plaza', 'Satellite', 'Ahmedabad', 'Premium', 8, 350, 120, 120, 'Satellite Plaza, Satellite, Ahmedabad', 'IMAX, Dolby Atmos, Recliner Seats, Food Court, Gaming Zone', 4.5, '079-12345001', 'Rajesh Kumar', TRUE, TRUE),
(2, 'INOX Satellite Mall', 'Satellite', 'Ahmedabad', 'Premium', 6, 320, 90, 90, 'Satellite Mall, Satellite, Ahmedabad', '4DX, Premium Seating, Cafe, Shopping Mall', 4.3, '079-12345002', 'Priya Sharma', TRUE, TRUE),
(3, 'Cinepolis Satellite Square', 'Satellite', 'Ahmedabad', 'Multiplex', 7, 300, 105, 105, 'Satellite Square, Satellite, Ahmedabad', 'VIP Lounge, Gaming Zone, Food Court', 4.2, '079-12345003', 'Amit Patel', TRUE, TRUE),
(4, 'Fun Cinemas Satellite', 'Satellite', 'Ahmedabad', 'Multiplex', 5, 280, 75, 75, 'Satellite Road, Satellite, Ahmedabad', 'Family Friendly, Parking, Snacks Counter', 4.0, '079-12345004', 'Neha Gupta', TRUE, FALSE),
(5, 'Rajhans Satellite', 'Satellite', 'Ahmedabad', 'Standard', 4, 250, 60, 60, 'Satellite Circle, Satellite, Ahmedabad', 'Budget Friendly, Snacks, AC Halls', 3.8, '079-12345005', 'Vikram Singh', TRUE, FALSE),
(6, 'Carnival Satellite', 'Satellite', 'Ahmedabad', 'Multiplex', 6, 290, 85, 85, 'Satellite Cross Roads, Satellite, Ahmedabad', 'Digital Projection, AC, Comfortable Seating', 4.1, '079-12345006', 'Kavita Joshi', TRUE, TRUE),
(7, 'Miraj Satellite', 'Satellite', 'Ahmedabad', 'Standard', 5, 270, 70, 70, 'Satellite Garden, Satellite, Ahmedabad', 'Comfortable Seating, Good Sound System', 3.9, '079-12345007', 'Rohit Mehta', TRUE, FALSE),

-- Vastrapur Area Theatres (8-14)
(8, 'PVR Vastrapur Lake', 'Vastrapur', 'Ahmedabad', 'Premium', 8, 360, 120, 120, 'Vastrapur Lake, Vastrapur, Ahmedabad', 'Lakeside View, Premium Experience, IMAX', 4.6, '079-12345008', 'Sanjay Desai', TRUE, TRUE),
(9, 'INOX Vastrapur Mall', 'Vastrapur', 'Ahmedabad', 'Premium', 6, 330, 90, 90, 'Vastrapur Mall, Vastrapur, Ahmedabad', 'Shopping Complex, Food Court, 4DX', 4.4, '079-12345009', 'Meera Shah', TRUE, TRUE),
(10, 'Cinepolis Vastrapur', 'Vastrapur', 'Ahmedabad', 'Multiplex', 7, 310, 105, 105, 'Vastrapur Main Road, Vastrapur, Ahmedabad', 'Modern Facilities, VIP Seating', 4.2, '079-12345010', 'Arjun Rao', TRUE, TRUE),
(11, 'Fun Cinemas Vastrapur', 'Vastrapur', 'Ahmedabad', 'Multiplex', 5, 290, 75, 75, 'Vastrapur Circle, Vastrapur, Ahmedabad', 'Family Entertainment, Kids Play Area', 4.0, '079-12345011', 'Pooja Agarwal', TRUE, TRUE),
(12, 'Rajhans Vastrapur', 'Vastrapur', 'Ahmedabad', 'Standard', 4, 260, 60, 60, 'Vastrapur Garden, Vastrapur, Ahmedabad', 'Garden View, Peaceful Environment', 3.8, '079-12345012', 'Kiran Patel', TRUE, FALSE),
(13, 'Carnival Vastrapur', 'Vastrapur', 'Ahmedabad', 'Multiplex', 6, 300, 85, 85, 'Vastrapur Cross Roads, Vastrapur, Ahmedabad', 'Central Location, Good Connectivity', 4.1, '079-12345013', 'Deepak Kumar', TRUE, TRUE),
(14, 'Miraj Vastrapur', 'Vastrapur', 'Ahmedabad', 'Standard', 5, 280, 70, 70, 'Vastrapur Square, Vastrapur, Ahmedabad', 'Community Theater, Local Favorite', 3.9, '079-12345014', 'Sunita Sharma', TRUE, FALSE);
-- Continue inserting remaining theatres

-- Paldi Area Theatres (15-21)
INSERT INTO theatres (theater_id, name, area, city, theater_type, total_screens, base_price, total_seats, available_seats, address, facilities, rating, contact_phone, manager_name, parking_available, food_court) VALUES
(15, 'PVR Paldi Central', 'Paldi', 'Ahmedabad', 'Premium', 8, 340, 120, 120, 'Paldi Central, Paldi, Ahmedabad', 'Central Location, Premium Experience', 4.5, '079-12345015', 'Ravi Jain', TRUE, TRUE),
(16, 'INOX Paldi Plaza', 'Paldi', 'Ahmedabad', 'Premium', 6, 310, 90, 90, 'Paldi Plaza, Paldi, Ahmedabad', 'Plaza Complex, Shopping', 4.3, '079-12345016', 'Anjali Verma', TRUE, TRUE),
(17, 'Cinepolis Paldi', 'Paldi', 'Ahmedabad', 'Multiplex', 7, 290, 105, 105, 'Paldi Main Road, Paldi, Ahmedabad', 'Main Road Access, Easy Commute', 4.2, '079-12345017', 'Manoj Gupta', TRUE, TRUE),
(18, 'Fun Cinemas Paldi', 'Paldi', 'Ahmedabad', 'Multiplex', 5, 270, 75, 75, 'Paldi Circle, Paldi, Ahmedabad', 'Circle Location, Family Friendly', 4.0, '079-12345018', 'Rekha Singh', TRUE, FALSE),
(19, 'Rajhans Paldi', 'Paldi', 'Ahmedabad', 'Standard', 4, 240, 60, 60, 'Paldi Garden, Paldi, Ahmedabad', 'Garden Setting, Peaceful', 3.8, '079-12345019', 'Suresh Patel', TRUE, FALSE),
(20, 'Carnival Paldi', 'Paldi', 'Ahmedabad', 'Multiplex', 6, 280, 85, 85, 'Paldi Cross Roads, Paldi, Ahmedabad', 'Cross Roads Hub, Good Location', 4.1, '079-12345020', 'Nisha Joshi', TRUE, TRUE),
(21, 'Miraj Paldi', 'Paldi', 'Ahmedabad', 'Standard', 5, 260, 70, 70, 'Paldi Square, Paldi, Ahmedabad', 'Square Complex, Local Cinema', 3.9, '079-12345021', 'Ashok Mehta', TRUE, FALSE),

-- Thaltej Area Theatres (22-28)
(22, 'PVR Thaltej Mall', 'Thaltej', 'Ahmedabad', 'Premium', 8, 370, 120, 120, 'Thaltej Mall, Thaltej, Ahmedabad', 'Mall Complex, Premium Shopping', 4.6, '079-12345022', 'Vishal Desai', TRUE, TRUE),
(23, 'INOX Thaltej Plaza', 'Thaltej', 'Ahmedabad', 'Premium', 6, 340, 90, 90, 'Thaltej Plaza, Thaltej, Ahmedabad', 'Plaza Premium, Luxury Experience', 4.4, '079-12345023', 'Priyanka Shah', TRUE, TRUE),
(24, 'Cinepolis Thaltej', 'Thaltej', 'Ahmedabad', 'Multiplex', 7, 320, 105, 105, 'Thaltej Cross Roads, Thaltej, Ahmedabad', 'Cross Roads Access, Modern', 4.2, '079-12345024', 'Rahul Rao', TRUE, TRUE),
(25, 'Fun Cinemas Thaltej', 'Thaltej', 'Ahmedabad', 'Multiplex', 5, 300, 75, 75, 'Thaltej Circle, Thaltej, Ahmedabad', 'Circle Hub, Family Entertainment', 4.0, '079-12345025', 'Swati Agarwal', TRUE, TRUE),
(26, 'Rajhans Thaltej', 'Thaltej', 'Ahmedabad', 'Standard', 4, 270, 60, 60, 'Thaltej Garden, Thaltej, Ahmedabad', 'Garden View, Serene Location', 3.8, '079-12345026', 'Dinesh Patel', TRUE, FALSE),
(27, 'Carnival Thaltej', 'Thaltej', 'Ahmedabad', 'Multiplex', 6, 310, 85, 85, 'Thaltej Square, Thaltej, Ahmedabad', 'Square Location, Good Facilities', 4.1, '079-12345027', 'Geeta Kumar', TRUE, TRUE),
(28, 'Miraj Thaltej', 'Thaltej', 'Ahmedabad', 'Standard', 5, 290, 70, 70, 'Thaltej Park, Thaltej, Ahmedabad', 'Park Side, Natural Setting', 3.9, '079-12345028', 'Mukesh Sharma', TRUE, FALSE),

-- Bopal Area Theatres (29-35)
(29, 'PVR Bopal Square', 'Bopal', 'Ahmedabad', 'Premium', 8, 350, 120, 120, 'Bopal Square, Bopal, Ahmedabad', 'Square Complex, Modern Amenities', 4.5, '079-12345029', 'Nitin Jain', TRUE, TRUE),
(30, 'INOX Bopal Mall', 'Bopal', 'Ahmedabad', 'Premium', 6, 320, 90, 90, 'Bopal Mall, Bopal, Ahmedabad', 'Mall Experience, Shopping & Cinema', 4.3, '079-12345030', 'Shilpa Verma', TRUE, TRUE),
(31, 'Cinepolis Bopal', 'Bopal', 'Ahmedabad', 'Multiplex', 7, 300, 105, 105, 'Bopal Main Road, Bopal, Ahmedabad', 'Main Road Location, Easy Access', 4.2, '079-12345031', 'Anil Gupta', TRUE, TRUE),
(32, 'Fun Cinemas Bopal', 'Bopal', 'Ahmedabad', 'Multiplex', 5, 280, 75, 75, 'Bopal Circle, Bopal, Ahmedabad', 'Circle Point, Family Oriented', 4.0, '079-12345032', 'Ritu Singh', TRUE, FALSE),
(33, 'Rajhans Bopal', 'Bopal', 'Ahmedabad', 'Standard', 4, 250, 60, 60, 'Bopal Garden, Bopal, Ahmedabad', 'Garden Area, Budget Friendly', 3.8, '079-12345033', 'Harish Patel', TRUE, FALSE),
(34, 'Carnival Bopal', 'Bopal', 'Ahmedabad', 'Multiplex', 6, 290, 85, 85, 'Bopal Cross Roads, Bopal, Ahmedabad', 'Cross Roads, Good Connectivity', 4.1, '079-12345034', 'Kavya Joshi', TRUE, TRUE),
(35, 'Miraj Bopal', 'Bopal', 'Ahmedabad', 'Standard', 5, 270, 70, 70, 'Bopal Park, Bopal, Ahmedabad', 'Park Location, Peaceful', 3.9, '079-12345035', 'Sachin Mehta', TRUE, FALSE);
-- Continue with remaining areas

-- Maninagar Area Theatres (36-42)
INSERT INTO theatres (theater_id, name, area, city, theater_type, total_screens, base_price, total_seats, available_seats, address, facilities, rating, contact_phone, manager_name, parking_available, food_court) VALUES
(36, 'PVR Maninagar Central', 'Maninagar', 'Ahmedabad', 'Premium', 8, 340, 120, 120, 'Maninagar Central, Maninagar, Ahmedabad', 'Central Hub, Premium Experience', 4.5, '079-12345036', 'Yogesh Desai', TRUE, TRUE),
(37, 'INOX Maninagar Plaza', 'Maninagar', 'Ahmedabad', 'Premium', 6, 310, 90, 90, 'Maninagar Plaza, Maninagar, Ahmedabad', 'Plaza Center, Shopping Complex', 4.3, '079-12345037', 'Bhavna Shah', TRUE, TRUE),
(38, 'Cinepolis Maninagar', 'Maninagar', 'Ahmedabad', 'Multiplex', 7, 290, 105, 105, 'Maninagar Main Road, Maninagar, Ahmedabad', 'Main Road Access, Modern Facilities', 4.2, '079-12345038', 'Sunil Rao', TRUE, TRUE),
(39, 'Fun Cinemas Maninagar', 'Maninagar', 'Ahmedabad', 'Multiplex', 5, 270, 75, 75, 'Maninagar Circle, Maninagar, Ahmedabad', 'Circle Area, Family Entertainment', 4.0, '079-12345039', 'Manju Agarwal', TRUE, FALSE),
(40, 'Rajhans Maninagar', 'Maninagar', 'Ahmedabad', 'Standard', 4, 240, 60, 60, 'Maninagar Garden, Maninagar, Ahmedabad', 'Garden Side, Budget Cinema', 3.8, '079-12345040', 'Jitesh Patel', TRUE, FALSE),
(41, 'Carnival Maninagar', 'Maninagar', 'Ahmedabad', 'Multiplex', 6, 280, 85, 85, 'Maninagar Cross Roads, Maninagar, Ahmedabad', 'Cross Roads Hub, Good Location', 4.1, '079-12345041', 'Seema Kumar', TRUE, TRUE),
(42, 'Miraj Maninagar', 'Maninagar', 'Ahmedabad', 'Standard', 5, 260, 70, 70, 'Maninagar Square, Maninagar, Ahmedabad', 'Square Complex, Local Cinema', 3.9, '079-12345042', 'Ramesh Sharma', TRUE, FALSE),

-- Naranpura Area Theatres (43-49)
(43, 'PVR Naranpura Mall', 'Naranpura', 'Ahmedabad', 'Premium', 8, 360, 120, 120, 'Naranpura Mall, Naranpura, Ahmedabad', 'Mall Complex, Premium Shopping', 4.6, '079-12345043', 'Kiran Jain', TRUE, TRUE),
(44, 'INOX Naranpura Plaza', 'Naranpura', 'Ahmedabad', 'Premium', 6, 330, 90, 90, 'Naranpura Plaza, Naranpura, Ahmedabad', 'Plaza Premium, Luxury Experience', 4.4, '079-12345044', 'Asha Verma', TRUE, TRUE),
(45, 'Cinepolis Naranpura', 'Naranpura', 'Ahmedabad', 'Multiplex', 7, 310, 105, 105, 'Naranpura Main Road, Naranpura, Ahmedabad', 'Main Road, Easy Access', 4.2, '079-12345045', 'Prakash Gupta', TRUE, TRUE),
(46, 'Fun Cinemas Naranpura', 'Naranpura', 'Ahmedabad', 'Multiplex', 5, 290, 75, 75, 'Naranpura Circle, Naranpura, Ahmedabad', 'Circle Point, Family Friendly', 4.0, '079-12345046', 'Lata Singh', TRUE, FALSE),
(47, 'Rajhans Naranpura', 'Naranpura', 'Ahmedabad', 'Standard', 4, 260, 60, 60, 'Naranpura Garden, Naranpura, Ahmedabad', 'Garden Area, Peaceful Setting', 3.8, '079-12345047', 'Mohan Patel', TRUE, FALSE),
(48, 'Carnival Naranpura', 'Naranpura', 'Ahmedabad', 'Multiplex', 6, 300, 85, 85, 'Naranpura Cross Roads, Naranpura, Ahmedabad', 'Cross Roads, Central Location', 4.1, '079-12345048', 'Usha Joshi', TRUE, TRUE),
(49, 'Miraj Naranpura', 'Naranpura', 'Ahmedabad', 'Standard', 5, 280, 70, 70, 'Naranpura Square, Naranpura, Ahmedabad', 'Square Location, Community Cinema', 3.9, '079-12345049', 'Vijay Mehta', TRUE, FALSE),

-- Chandkheda Area Theatres (50-56)
(50, 'PVR Chandkheda Central', 'Chandkheda', 'Ahmedabad', 'Premium', 8, 350, 120, 120, 'Chandkheda Central, Chandkheda, Ahmedabad', 'Central Location, Modern Facilities', 4.5, '079-12345050', 'Ajay Desai', TRUE, TRUE),
(51, 'INOX Chandkheda Mall', 'Chandkheda', 'Ahmedabad', 'Premium', 6, 320, 90, 90, 'Chandkheda Mall, Chandkheda, Ahmedabad', 'Mall Experience, Shopping & Cinema', 4.3, '079-12345051', 'Renu Shah', TRUE, TRUE),
(52, 'Cinepolis Chandkheda', 'Chandkheda', 'Ahmedabad', 'Multiplex', 7, 300, 105, 105, 'Chandkheda Main Road, Chandkheda, Ahmedabad', 'Main Road Access, Good Connectivity', 4.2, '079-12345052', 'Gopal Rao', TRUE, TRUE),
(53, 'Fun Cinemas Chandkheda', 'Chandkheda', 'Ahmedabad', 'Multiplex', 5, 280, 75, 75, 'Chandkheda Circle, Chandkheda, Ahmedabad', 'Circle Hub, Family Entertainment', 4.0, '079-12345053', 'Sushma Agarwal', TRUE, FALSE),
(54, 'Rajhans Chandkheda', 'Chandkheda', 'Ahmedabad', 'Standard', 4, 250, 60, 60, 'Chandkheda Garden, Chandkheda, Ahmedabad', 'Garden View, Budget Friendly', 3.8, '079-12345054', 'Bharat Patel', TRUE, FALSE),
(55, 'Carnival Chandkheda', 'Chandkheda', 'Ahmedabad', 'Multiplex', 6, 290, 85, 85, 'Chandkheda Cross Roads, Chandkheda, Ahmedabad', 'Cross Roads Point, Good Location', 4.1, '079-12345055', 'Neeta Kumar', TRUE, TRUE),
(56, 'Miraj Chandkheda', 'Chandkheda', 'Ahmedabad', 'Standard', 5, 270, 70, 70, 'Chandkheda Square, Chandkheda, Ahmedabad', 'Square Area, Local Cinema', 3.9, '079-12345056', 'Dilip Sharma', TRUE, FALSE);
-- =====================================================
-- INSERT ALL VENUES FOR COMEDY SHOWS AND CONCERTS
-- =====================================================

INSERT INTO venues (venue_id, name, area, city, venue_type, capacity, available_capacity, base_price, address, facilities, sound_system, lighting_system, parking_capacity, accessibility_features, established_year, venue_rating) VALUES

-- Comedy Venues (1-20)
(1, 'Comedy Club Satellite', 'Satellite', 'Ahmedabad', 'Comedy Club', 150, 150, 500, 'Satellite Road, Ahmedabad', 'AC, Bar, VIP Seating, Green Room', 'Bose Professional', 'LED Stage Lighting', 75, 'Wheelchair Access, Ramps', 2018, 4.5),
(2, 'Laugh Factory Vastrapur', 'Vastrapur', 'Ahmedabad', 'Comedy Venue', 200, 200, 450, 'Vastrapur Lake Road, Ahmedabad', 'AC, Stage, Green Room, Cafe', 'JBL Sound System', 'Professional Stage Lights', 100, 'Accessible Seating, Elevators', 2019, 4.3),
(3, 'Stand-Up Central Paldi', 'Paldi', 'Ahmedabad', 'Comedy Hall', 120, 120, 550, 'Paldi Cross Roads, Ahmedabad', 'Premium Sound, AC, Bar, VIP Area', 'Yamaha Professional', 'Intelligent Lighting', 60, 'Wheelchair Access, Special Seating', 2020, 4.6),
(4, 'Comedy Corner Thaltej', 'Thaltej', 'Ahmedabad', 'Comedy Club', 180, 180, 480, 'Thaltej Square, Ahmedabad', 'AC, Sound System, Bar, Lounge', 'Shure Audio', 'DMX Lighting', 90, 'Accessible Facilities, Ramps', 2017, 4.2),
(5, 'Humor Hub Bopal', 'Bopal', 'Ahmedabad', 'Comedy Venue', 160, 160, 520, 'Bopal Garden, Ahmedabad', 'AC, Stage Lighting, Cafe, VIP Seating', 'Behringer Pro', 'LED Par Lights', 80, 'Ramp Access, Special Seating', 2021, 4.4),
(6, 'Giggles Maninagar', 'Maninagar', 'Ahmedabad', 'Comedy Club', 140, 140, 470, 'Maninagar Circle, Ahmedabad', 'AC, Sound System, Snacks Counter', 'Audio-Technica', 'Basic Stage Lighting', 70, 'Ground Floor Access', 2019, 4.0),
(7, 'Chuckles Naranpura', 'Naranpura', 'Ahmedabad', 'Comedy Venue', 170, 170, 490, 'Naranpura Plaza, Ahmedabad', 'AC, Professional Stage, Bar', 'Sennheiser', 'Professional Lighting', 85, 'Wheelchair Accessible', 2020, 4.3),
(8, 'Laughter Lounge Chandkheda', 'Chandkheda', 'Ahmedabad', 'Comedy Hall', 130, 130, 460, 'Chandkheda Main Road, Ahmedabad', 'AC, Sound System, Comfortable Seating', 'Mackie', 'LED Lighting', 65, 'Accessible Entry', 2018, 4.1),

-- Concert Venues (21-40)
(21, 'Concert Hall Satellite', 'Satellite', 'Ahmedabad', 'Concert Venue', 500, 500, 1000, 'Satellite Plaza, Ahmedabad', 'Premium Sound, Lighting, VIP Seating, Backstage', 'L-Acoustics', 'Martin Professional', 250, 'Full Accessibility, Lifts', 2015, 4.7),
(22, 'Music Arena Vastrapur', 'Vastrapur', 'Ahmedabad', 'Music Venue', 300, 300, 1200, 'Vastrapur Lake, Ahmedabad', 'Professional Sound, Stage, Green Room', 'Meyer Sound', 'Clay Paky Lighting', 150, 'Wheelchair Access, Lifts', 2016, 4.5),
(23, 'Symphony Hall Paldi', 'Paldi', 'Ahmedabad', 'Concert Venue', 400, 400, 1100, 'Paldi Central, Ahmedabad', 'Premium Sound, Lighting, Orchestra Pit', 'd&b audiotechnik', 'ETC Lighting', 200, 'Complete Accessibility', 2017, 4.6),
(24, 'Melody Center Thaltej', 'Thaltej', 'Ahmedabad', 'Music Venue', 350, 350, 1150, 'Thaltej Mall, Ahmedabad', 'Professional Sound, Stage, VIP Boxes', 'QSC Audio', 'Chauvet Professional', 175, 'Accessible Design, Ramps', 2018, 4.4),
(25, 'Rhythm Palace Bopal', 'Bopal', 'Ahmedabad', 'Concert Venue', 450, 450, 1050, 'Bopal Square, Ahmedabad', 'Premium Sound, Lighting, VIP Seating', 'Electro-Voice', 'ADJ Lighting', 225, 'Universal Access, Lifts', 2019, 4.5),
(26, 'Harmony Hall Maninagar', 'Maninagar', 'Ahmedabad', 'Music Venue', 280, 280, 1080, 'Maninagar Plaza, Ahmedabad', 'Good Sound System, Stage Lighting', 'JBL Professional', 'American DJ', 140, 'Wheelchair Access', 2020, 4.2),
(27, 'Acoustic Arena Naranpura', 'Naranpura', 'Ahmedabad', 'Concert Hall', 380, 380, 1120, 'Naranpura Mall, Ahmedabad', 'Professional Setup, VIP Area', 'Yamaha Commercial', 'Elation Professional', 190, 'Full Accessibility', 2017, 4.3),
(28, 'Sound Stage Chandkheda', 'Chandkheda', 'Ahmedabad', 'Music Venue', 320, 320, 1090, 'Chandkheda Central, Ahmedabad', 'Modern Sound System, Good Acoustics', 'Mackie Professional', 'Showtec Lighting', 160, 'Accessible Facilities', 2021, 4.1);
-- =====================================================
-- INSERT ALL 40 MOVIES WITH DETAILED INFORMATION
-- =====================================================

INSERT INTO movies (id, movie_name, mood, duration_minutes, rating, language, genre, director, cast_info, release_date, imdb_rating, description, poster_url, box_office_collection, awards) VALUES

-- Romantic Movies (1-10)
(1, 'Titanic', 'Romantic', 195, 'PG-13', 'English', 'Romance/Drama', 'James Cameron', 'Leonardo DiCaprio, Kate Winslet, Billy Zane', '1997-12-19', 7.8, 'Epic romance aboard the ill-fated ship Titanic', 'https://example.com/titanic.jpg', 2187000000, '11 Academy Awards including Best Picture'),
(2, 'The Notebook', 'Romantic', 123, 'PG-13', 'English', 'Romance/Drama', 'Nick Cassavetes', 'Ryan Gosling, Rachel McAdams, James Garner', '2004-06-25', 7.8, 'A timeless love story spanning decades', 'https://example.com/notebook.jpg', 115600000, 'MTV Movie Award for Best Kiss'),
(3, 'La La Land', 'Romantic', 128, 'PG-13', 'English', 'Romance/Musical', 'Damien Chazelle', 'Ryan Gosling, Emma Stone, John Legend', '2016-12-09', 8.0, 'Modern musical romance in Los Angeles', 'https://example.com/lalaland.jpg', 448900000, '6 Academy Awards including Best Director'),
(4, 'Dilwale Dulhania Le Jayenge', 'Romantic', 189, 'U', 'Hindi', 'Romance/Drama', 'Aditya Chopra', 'Shah Rukh Khan, Kajol, Amrish Puri', '1995-10-20', 8.1, 'Classic Bollywood romance that redefined love stories', 'https://example.com/ddlj.jpg', 200000000, 'National Film Award for Best Popular Film'),
(5, 'Jab We Met', 'Romantic', 138, 'U', 'Hindi', 'Romance/Comedy', 'Imtiaz Ali', 'Shahid Kapoor, Kareena Kapoor, Tabu', '2007-10-26', 7.9, 'Journey of love and self-discovery', 'https://example.com/jabwemet.jpg', 600000000, 'Filmfare Award for Best Actress'),
(6, 'Casablanca', 'Romantic', 102, 'PG', 'English', 'Romance/Drama', 'Michael Curtiz', 'Humphrey Bogart, Ingrid Bergman, Paul Henreid', '1942-11-26', 8.5, 'Classic wartime romance in Morocco', 'https://example.com/casablanca.jpg', 10000000, '3 Academy Awards including Best Picture'),
(7, 'Yeh Jawaani Hai Deewani', 'Romantic', 161, 'U', 'Hindi', 'Romance/Comedy', 'Ayan Mukerji', 'Ranbir Kapoor, Deepika Padukone, Aditya Roy Kapur', '2013-05-31', 7.2, 'Youth, friendship, and love in scenic locations', 'https://example.com/yjhd.jpg', 1900000000, 'Filmfare Award for Best Cinematography'),
(8, 'Before Sunrise', 'Romantic', 101, 'R', 'English', 'Romance/Drama', 'Richard Linklater', 'Ethan Hawke, Julie Delpy', '1995-01-27', 8.1, 'One magical night in Vienna', 'https://example.com/beforesunrise.jpg', 5800000, 'Berlin International Film Festival Silver Bear'),
(9, 'Zindagi Na Milegi Dobara', 'Romantic', 155, 'U/A', 'Hindi', 'Romance/Adventure', 'Zoya Akhtar', 'Hrithik Roshan, Katrina Kaif, Farhan Akhtar', '2011-07-15', 8.2, 'Life-changing Spanish adventure with friends', 'https://example.com/znmd.jpg', 1530000000, 'National Film Award for Best Choreography'),
(10, 'The Princess Bride', 'Romantic', 98, 'PG', 'English', 'Romance/Adventure', 'Rob Reiner', 'Cary Elwes, Robin Wright, Mandy Patinkin', '1987-09-25', 8.0, 'Fairy tale romance adventure with humor', 'https://example.com/princessbride.jpg', 30900000, 'Hugo Award for Best Dramatic Presentation'),

-- Action Movies (11-20)
(11, 'Avengers: Endgame', 'Action', 181, 'PG-13', 'English', 'Action/Sci-Fi', 'Russo Brothers', 'Robert Downey Jr., Chris Evans, Mark Ruffalo', '2019-04-26', 8.4, 'Epic superhero finale to the Infinity Saga', 'https://example.com/endgame.jpg', 2797800000, 'Highest-grossing film of all time'),
(12, 'Fast & Furious 9', 'Action', 143, 'PG-13', 'English', 'Action/Thriller', 'Justin Lin', 'Vin Diesel, Michelle Rodriguez, Tyrese Gibson', '2021-06-25', 5.2, 'High-octane action with family at the center', 'https://example.com/ff9.jpg', 726200000, 'Teen Choice Award for Action Movie'),
(13, 'Baahubali 2', 'Action', 167, 'U/A', 'Hindi', 'Action/Drama', 'S.S. Rajamouli', 'Prabhas, Rana Daggubati, Anushka Shetty', '2017-04-28', 8.7, 'Epic Indian action drama with stunning visuals', 'https://example.com/baahubali2.jpg', 18000000000, 'National Film Award for Best Feature Film'),
(14, 'KGF Chapter 2', 'Action', 168, 'U/A', 'Hindi', 'Action/Drama', 'Prashanth Neel', 'Yash, Sanjay Dutt, Raveena Tandon', '2022-04-14', 8.4, 'Powerful action sequel with mass appeal', 'https://example.com/kgf2.jpg', 12500000000, 'SIIMA Award for Best Film'),
(15, 'Pathaan', 'Action', 146, 'U/A', 'Hindi', 'Action/Thriller', 'Siddharth Anand', 'Shah Rukh Khan, Deepika Padukone, John Abraham', '2023-01-25', 5.7, 'Spy action thriller with high-stakes missions', 'https://example.com/pathaan.jpg', 10500000000, 'Box Office Success Award'),
(16, 'Mad Max: Fury Road', 'Action', 120, 'R', 'English', 'Action/Sci-Fi', 'George Miller', 'Tom Hardy, Charlize Theron, Nicholas Hoult', '2015-05-15', 8.1, 'Post-apocalyptic action masterpiece', 'https://example.com/madmax.jpg', 375000000, '6 Academy Awards including Best Production Design'),
(17, 'War', 'Action', 156, 'U/A', 'Hindi', 'Action/Thriller', 'Siddharth Anand', 'Hrithik Roshan, Tiger Shroff, Vaani Kapoor', '2019-10-02', 6.5, 'High-tech action thriller with stunning sequences', 'https://example.com/war.jpg', 3175000000, 'Filmfare Award for Best Action'),
(18, 'John Wick', 'Action', 101, 'R', 'English', 'Action/Thriller', 'Chad Stahelski', 'Keanu Reeves, Michael Nyqvist, Alfie Allen', '2014-10-24', 7.4, 'Stylized action revenge thriller', 'https://example.com/johnwick.jpg', 86000000, 'Saturn Award for Best Action/Thriller Film'),
(19, 'Pushpa', 'Action', 179, 'U/A', 'Hindi', 'Action/Drama', 'Sukumar', 'Allu Arjun, Rashmika Mandanna, Fahadh Faasil', '2021-12-17', 7.6, 'Raw action drama with powerful performances', 'https://example.com/pushpa.jpg', 3500000000, 'Filmfare Award for Best Actor (Telugu)'),
(20, 'Mission Impossible', 'Action', 147, 'PG-13', 'English', 'Action/Thriller', 'Brian De Palma', 'Tom Cruise, Jon Voight, Emmanuelle Béart', '1996-05-22', 7.1, 'Spy action thriller with impossible missions', 'https://example.com/mi.jpg', 457700000, 'BMI Film Music Award');
-- Continue with Comedy and Family Movies

-- Comedy Movies (21-30)
INSERT INTO movies (id, movie_name, mood, duration_minutes, rating, language, genre, director, cast_info, release_date, imdb_rating, description, poster_url, box_office_collection, awards) VALUES
(21, 'Hera Pheri', 'Comedy', 156, 'U', 'Hindi', 'Comedy', 'Priyadarshan', 'Akshay Kumar, Suniel Shetty, Paresh Rawal', '2000-03-31', 8.2, 'Classic comedy masterpiece with perfect timing', 'https://example.com/herapheri.jpg', 300000000, 'Filmfare Award for Best Comedian'),
(22, 'Golmaal', 'Comedy', 150, 'U', 'Hindi', 'Comedy', 'Rohit Shetty', 'Ajay Devgn, Arshad Warsi, Sharman Joshi', '2006-07-14', 7.4, 'Fun-filled comedy with mistaken identities', 'https://example.com/golmaal.jpg', 400000000, 'IIFA Award for Best Comedy'),
(23, 'Andaz Apna Apna', 'Comedy', 160, 'U', 'Hindi', 'Comedy', 'Rajkumar Santoshi', 'Aamir Khan, Salman Khan, Raveena Tandon', '1994-11-04', 8.2, 'Cult comedy classic with memorable characters', 'https://example.com/andazapnaapna.jpg', 150000000, 'Cult Classic Status'),
(24, 'Welcome', 'Comedy', 159, 'U', 'Hindi', 'Comedy', 'Anees Bazmee', 'Akshay Kumar, Katrina Kaif, Nana Patekar', '2007-12-21', 7.0, 'Comedy of errors with gangster twist', 'https://example.com/welcome.jpg', 750000000, 'Screen Award for Best Comedy'),
(25, 'Housefull', 'Comedy', 140, 'U/A', 'Hindi', 'Comedy', 'Sajid Khan', 'Akshay Kumar, Deepika Padukone, Arjun Rampal', '2010-04-30', 5.5, 'Multi-starrer comedy with confusion', 'https://example.com/housefull.jpg', 1100000000, 'Box Office Success'),
(26, 'The Hangover', 'Comedy', 100, 'R', 'English', 'Comedy', 'Todd Phillips', 'Bradley Cooper, Ed Helms, Zach Galifianakis', '2009-06-05', 7.7, 'Bachelor party gone hilariously wrong', 'https://example.com/hangover.jpg', 467500000, 'Golden Globe Award for Best Motion Picture'),
(27, 'Munna Bhai MBBS', 'Comedy', 156, 'U', 'Hindi', 'Comedy/Drama', 'Rajkumar Hirani', 'Sanjay Dutt, Arshad Warsi, Gracy Singh', '2003-12-19', 8.1, 'Heartwarming comedy with social message', 'https://example.com/munnabhai.jpg', 250000000, 'National Film Award for Best Popular Film'),
(28, 'Superbad', 'Comedy', 113, 'R', 'English', 'Comedy', 'Greg Mottola', 'Jonah Hill, Michael Cera, Christopher Mintz-Plasse', '2007-08-17', 7.6, 'Teen comedy adventure with friendship', 'https://example.com/superbad.jpg', 170800000, 'MTV Movie Award for Best Breakthrough Performance'),
(29, 'Fukrey', 'Comedy', 139, 'U/A', 'Hindi', 'Comedy', 'Mrighdeep Singh Lamba', 'Pulkit Samrat, Varun Sharma, Ali Fazal', '2013-06-14', 6.9, 'Delhi boys comedy with dreams and schemes', 'https://example.com/fukrey.jpg', 600000000, 'Screen Award for Best Comedy'),
(30, 'Dumb and Dumber', 'Comedy', 107, 'PG-13', 'English', 'Comedy', 'Peter Farrelly', 'Jim Carrey, Jeff Daniels, Lauren Holly', '1994-12-16', 7.3, 'Silly buddy comedy with heart', 'https://example.com/dumbanddumber.jpg', 247300000, 'MTV Movie Award for Best Comedic Performance'),

-- Family Movies (31-40)
(31, 'Taare Zameen Par', 'Family', 165, 'U', 'Hindi', 'Family/Drama', 'Aamir Khan', 'Aamir Khan, Darsheel Safary, Tisca Chopra', '2007-12-21', 8.4, 'Inspiring story about special child and education', 'https://example.com/tzp.jpg', 600000000, 'National Film Award for Best Film on Family Welfare'),
(32, '3 Idiots', 'Family', 170, 'U', 'Hindi', 'Family/Comedy', 'Rajkumar Hirani', 'Aamir Khan, R. Madhavan, Sharman Joshi', '2009-12-25', 8.4, 'Educational comedy-drama about friendship', 'https://example.com/3idiots.jpg', 4000000000, 'National Film Award for Best Popular Film'),
(33, 'Dangal', 'Family', 161, 'U', 'Hindi', 'Family/Sports', 'Nitesh Tiwari', 'Aamir Khan, Fatima Sana Shaikh, Sanya Malhotra', '2016-12-23', 8.4, 'Wrestling family drama based on true story', 'https://example.com/dangal.jpg', 20740000000, 'National Film Award for Best Popular Film'),
(34, 'Finding Nemo', 'Family', 100, 'G', 'English', 'Family/Animation', 'Andrew Stanton', 'Albert Brooks, Ellen DeGeneres, Alexander Gould', '2003-05-30', 8.2, 'Underwater adventure of father and son', 'https://example.com/findingnemo.jpg', 940300000, 'Academy Award for Best Animated Feature'),
(35, 'The Lion King', 'Family', 88, 'G', 'English', 'Family/Animation', 'Roger Allers', 'Matthew Broderick, Jeremy Irons, James Earl Jones', '1994-06-24', 8.5, 'Disney classic about young lion prince', 'https://example.com/lionking.jpg', 968500000, 'Academy Award for Best Original Score'),
(36, 'Coco', 'Family', 105, 'PG', 'English', 'Family/Animation', 'Lee Unkrich', 'Anthony Gonzalez, Gael García Bernal, Benjamin Bratt', '2017-11-22', 8.4, 'Mexican culture celebration with music', 'https://example.com/coco.jpg', 807800000, 'Academy Award for Best Animated Feature'),
(37, 'Queen', 'Family', 146, 'U/A', 'Hindi', 'Family/Comedy', 'Vikas Bahl', 'Kangana Ranaut, Rajkummar Rao, Lisa Haydon', '2013-03-07', 8.2, 'Women empowerment story with humor', 'https://example.com/queen.jpg', 610000000, 'National Film Award for Best Feature Film'),
(38, 'Toy Story', 'Family', 81, 'G', 'English', 'Family/Animation', 'John Lasseter', 'Tom Hanks, Tim Allen, Don Rickles', '1995-11-22', 8.3, 'Toys come to life in groundbreaking animation', 'https://example.com/toystory.jpg', 373600000, 'Special Achievement Academy Award'),
(39, 'Hindi Medium', 'Family', 132, 'U', 'Hindi', 'Family/Comedy', 'Saket Chaudhary', 'Irrfan Khan, Saba Qamar, Dishita Sehgal', '2017-05-19', 7.9, 'Education system satire with heart', 'https://example.com/hindimedium.jpg', 690000000, 'Filmfare Award for Best Actor'),
(40, 'The Incredibles', 'Family', 115, 'PG', 'English', 'Family/Animation', 'Brad Bird', 'Craig T. Nelson, Holly Hunter, Sarah Vowell', '2004-11-05', 8.0, 'Superhero family with relatable problems', 'https://example.com/incredibles.jpg', 633000000, 'Academy Award for Best Animated Feature');
-- =====================================================
-- INSERT ENHANCED COMEDY SHOWS
-- =====================================================

INSERT INTO comedy_shows (show_id, comedian_name, show_title, show_type, duration_minutes, language, age_rating, description, ticket_price, comedian_bio, show_rating, special_notes, social_media_followers, experience_years) VALUES
(1, 'Kapil Sharma', 'The Kapil Sharma Show Live', 'Stand-up Comedy', 90, 'Hindi', '18+', 'Hilarious comedy show with celebrity guests and audience interaction', 500, 'Popular TV comedian, actor, and producer known for his wit and timing', 4.5, 'Interactive audience participation, celebrity mimicry', 15000000, 15),
(2, 'Zakir Khan', 'Haq Se Single', 'Stand-up Comedy', 85, 'Hindi', '18+', 'Comedy about being single, relationships, and modern dating', 600, 'YouTube sensation turned comedian, known for relatable content', 4.7, 'Relatable content for millennials, storytelling style', 8000000, 8),
(3, 'Biswa Kalyan Rath', 'Pretentious Movie Reviews', 'Stand-up Comedy', 80, 'English', '18+', 'Witty movie review comedy with intellectual humor', 550, 'Engineer turned comedian, known for intelligent and observational comedy', 4.3, 'Intellectual humor, movie references', 2500000, 10),
(4, 'Kenny Sebastian', 'The Most Interesting Person', 'Stand-up Comedy', 75, 'English', '16+', 'Observational comedy about life, relationships, and growing up', 650, 'Multi-talented comedian, musician, and filmmaker', 4.6, 'Clean comedy suitable for families, musical elements', 3500000, 12),
(5, 'Abhishek Upmanyu', 'Thoda Saaf Bol', 'Stand-up Comedy', 85, 'Hindi', '18+', 'Clean comedy show with social commentary and life observations', 500, 'IIT graduate turned comedian, known for clean and smart humor', 4.4, 'Educational background adds depth, clean content', 4200000, 7),
(6, 'Kanan Gill', 'Keep It Real', 'Stand-up Comedy', 80, 'English', '18+', 'Honest comedy about life, career, and personal experiences', 580, 'Bangalore-based comedian known for his honest and relatable style', 4.2, 'Honest storytelling, career humor', 2800000, 9),
(7, 'Sapan Verma', 'Obsessive Compulsive Disorder', 'Stand-up Comedy', 75, 'English', '18+', 'Comedy about quirks, habits, and modern life anxieties', 520, 'Writer and comedian known for observational humor', 4.1, 'Psychological humor, modern life commentary', 1800000, 8),
(8, 'Vir Das', 'Abroad Understanding', 'Stand-up Comedy', 90, 'English', '18+', 'International comedy about cultural differences and travel', 700, 'International comedian, actor, and musician', 4.5, 'International perspective, cultural comedy', 5500000, 18),
(9, 'Anubhav Singh Bassi', 'Bas Kar Bassi', 'Stand-up Comedy', 85, 'Hindi', '18+', 'Storytelling comedy about college life and growing up', 550, 'Viral comedian known for college and life stories', 4.6, 'Storytelling style, college humor', 6200000, 6),
(10, 'Rahul Subramanian', 'Kal Main Udega', 'Stand-up Comedy', 80, 'English', '18+', 'Comedy about dreams, aspirations, and reality checks', 530, 'Bangalore comedian known for self-deprecating humor', 4.3, 'Self-deprecating humor, aspirational comedy', 2100000, 7);

-- =====================================================
-- INSERT ENHANCED CONCERTS
-- =====================================================

INSERT INTO concerts (concert_id, artist_name, concert_title, genre, duration_minutes, language, ticket_price, description, special_guests, artist_bio, concert_type, equipment_info, album_sales, awards_won) VALUES
(1, 'Arijit Singh', 'Arijit Singh Live', 'Bollywood', 120, 'Hindi', 1000, 'Romantic Bollywood hits live performance with full band', 'Shreya Ghoshal, Armaan Malik', 'Leading playback singer with soulful voice', 'Live Concert', 'Professional sound system, live band, LED screens', 50000000, 'Filmfare Awards, National Film Awards'),
(2, 'A.R. Rahman', 'Rahman Live Concert', 'Classical/Fusion', 150, 'Multi', 1500, 'Musical maestro live with full orchestra and choir', 'Hariharan, Kailash Kher', 'Oscar-winning composer and music director', 'Orchestra Concert', 'Full orchestra, digital mixing, surround sound', 100000000, 'Academy Awards, Grammy Awards, BAFTA'),
(3, 'Nucleya', 'Electronic Dance Night', 'Electronic', 90, 'Instrumental', 800, 'High-energy EDM night with visual effects', 'Divine, MC Altaf', 'Pioneer of Indian EDM and bass music', 'DJ Set', 'Professional DJ equipment, light show, smoke machines', 5000000, 'MTV EMA India, VH1 Sound Nation'),
(4, 'Rahat Fateh Ali Khan', 'Sufi Night', 'Sufi', 100, 'Urdu', 1200, 'Spiritual music experience with traditional instruments', 'Kailash Kher, Abida Parveen', 'Renowned Sufi singer and qawwal', 'Sufi Performance', 'Traditional instruments, acoustic setup, tabla', 25000000, 'Lux Style Awards, Pride of Performance'),
(5, 'Sunidhi Chauhan', 'Bollywood Diva Live', 'Bollywood', 110, 'Hindi', 900, 'Energetic Bollywood performance with dance numbers', 'Shaan, Rahat Fateh Ali Khan', 'Versatile playback singer with powerful voice', 'Live Performance', 'Live band, choreographed show, LED backdrop', 30000000, 'Filmfare Awards, National Film Awards'),
(6, 'Sonu Nigam', 'Voice of Bollywood', 'Bollywood', 125, 'Hindi', 1100, 'Classic and modern Bollywood hits showcase', 'Alka Yagnik, Udit Narayan', 'Legendary playback singer with versatile voice', 'Live Concert', 'Orchestra, live band, acoustic setup', 75000000, 'Padma Shri, National Film Awards'),
(7, 'Vishal-Shekhar', 'Music Directors Live', 'Bollywood', 135, 'Hindi', 950, 'Hit songs from popular movies with live band', 'Sunidhi Chauhan, Rahat Fateh Ali Khan', 'Popular music director duo', 'Live Band Performance', 'Full band setup, electronic instruments', 40000000, 'Filmfare Awards, IIFA Awards'),
(8, 'Indian Ocean', 'Rock Fusion Night', 'Rock/Fusion', 105, 'Hindi/English', 850, 'Indian rock fusion with social messages', 'Parikrama, Euphoria', 'Pioneering Indian rock fusion band', 'Rock Concert', 'Electric guitars, drums, bass, sound effects', 8000000, 'MTV Awards, Channel V Awards'),
(9, 'Shankar Mahadevan', 'Breathless Live', 'Classical/Fusion', 115, 'Multi', 1050, 'Classical fusion with contemporary elements', 'Hariharan, Unnikrishnan', 'Classical singer and music director', 'Classical Fusion', 'Traditional and modern instruments', 35000000, 'Padma Shri, National Film Awards'),
(10, 'Kailash Kher', 'Sufi Rock Fusion', 'Sufi/Rock', 100, 'Hindi/Punjabi', 950, 'Unique blend of Sufi music with rock elements', 'Rahat Fateh Ali Khan, Rabbi Shergill', 'Sufi rock singer with distinctive voice', 'Fusion Concert', 'Rock band with traditional instruments', 15000000, 'Filmfare Awards, Padma Shri');
-- =====================================================
-- CREATE COMPREHENSIVE INDEXES FOR PERFORMANCE
-- =====================================================

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_area ON users(area);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_bookings_user_email ON bookings(user_email);
CREATE INDEX idx_bookings_event_type ON bookings(event_type);
CREATE INDEX idx_bookings_show_date ON bookings(show_date);
CREATE INDEX idx_bookings_booking_date ON bookings(booking_date);
CREATE INDEX idx_bookings_payment_status ON bookings(payment_status);
CREATE INDEX idx_theatre_rows_theatre_date_time ON theatre_rows(theatre_id, show_date, show_time);
CREATE INDEX idx_theatre_rows_show_date ON theatre_rows(show_date);
CREATE INDEX idx_payment_transactions_booking_id ON payment_transactions(booking_id);
CREATE INDEX idx_payment_transactions_user_email ON payment_transactions(user_email);
CREATE INDEX idx_payment_transactions_payment_status ON payment_transactions(payment_status);
CREATE INDEX idx_theatres_area ON theatres(area);
CREATE INDEX idx_theatres_theater_type ON theatres(theater_type);
CREATE INDEX idx_venues_area ON venues(area);
CREATE INDEX idx_venues_venue_type ON venues(venue_type);
CREATE INDEX idx_movies_mood ON movies(mood);
CREATE INDEX idx_movies_language ON movies(language);
CREATE INDEX idx_comedy_shows_language ON comedy_shows(language);
CREATE INDEX idx_concerts_genre ON concerts(genre);

-- =====================================================
-- CREATE ADVANCED VIEWS FOR ANALYTICS
-- =====================================================

-- Comprehensive booking analytics view
CREATE VIEW booking_analytics AS
SELECT 
    b.*,
    u.name as user_name,
    u.area as user_area,
    u.user_type,
    CASE 
        WHEN b.event_type = 'movie' THEN t.name
        ELSE v.name
    END as venue_name_full,
    CASE 
        WHEN b.event_type = 'movie' THEN t.theater_type
        ELSE v.venue_type
    END as venue_type,
    EXTRACT(DOW FROM b.booking_date) as booking_day_of_week,
    EXTRACT(HOUR FROM b.booking_date) as booking_hour,
    EXTRACT(MONTH FROM b.booking_date) as booking_month,
    DATE_PART('week', b.booking_date) as booking_week
FROM bookings b
JOIN users u ON b.user_email = u.email
LEFT JOIN theatres t ON b.venue_id = t.theater_id AND b.event_type = 'movie'
LEFT JOIN venues v ON b.venue_id = v.venue_id AND b.event_type IN ('comedy', 'concert');

-- Revenue analytics view
CREATE VIEW revenue_analytics AS
SELECT 
    event_type,
    COUNT(*) as total_bookings,
    SUM(booked_seats) as total_tickets_sold,
    SUM(total_amount) as total_revenue,
    SUM(profit_amount) as total_profit,
    AVG(total_amount) as avg_booking_value,
    SUM(gst_amount) as total_gst_collected,
    SUM(platform_fee) as total_platform_fees
FROM bookings 
WHERE payment_status = 'COMPLETED'
GROUP BY event_type;

-- User analytics view
CREATE VIEW user_analytics AS
SELECT 
    u.area,
    u.user_type,
    COUNT(*) as user_count,
    AVG(u.booking_count) as avg_bookings_per_user,
    AVG(u.total_spent) as avg_spent_per_user,
    SUM(u.total_spent) as total_area_revenue,
    COUNT(CASE WHEN u.last_login > CURRENT_DATE - INTERVAL '30 days' THEN 1 END) as active_users_30d
FROM users u 
WHERE u.otp IS NULL
GROUP BY u.area, u.user_type;

-- =====================================================
-- CREATE ADVANCED FUNCTIONS
-- =====================================================

-- Function for profit calculation
CREATE OR REPLACE FUNCTION calculate_profit_breakdown(total_amount INTEGER)
RETURNS TABLE(
    base_amount INTEGER,
    gst_amount INTEGER,
    platform_fee INTEGER,
    theatre_share INTEGER,
    profit_amount INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (total_amount / 1.18)::INTEGER as base_amount,
        (total_amount - (total_amount / 1.18)::INTEGER)::INTEGER as gst_amount,
        ((total_amount / 1.18) * 0.10)::INTEGER as platform_fee,
        ((total_amount / 1.18) * 0.60)::INTEGER as theatre_share,
        ((total_amount / 1.18) * 0.30)::INTEGER as profit_amount;
END;
$$ LANGUAGE plpgsql;

-- Function to get user booking statistics
CREATE OR REPLACE FUNCTION get_user_stats(user_email_param VARCHAR)
RETURNS TABLE(
    total_bookings INTEGER,
    total_spent INTEGER,
    favorite_event_type VARCHAR,
    favorite_area VARCHAR,
    last_booking_date TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*)::INTEGER as total_bookings,
        SUM(b.total_amount)::INTEGER as total_spent,
        MODE() WITHIN GROUP (ORDER BY b.event_type) as favorite_event_type,
        MODE() WITHIN GROUP (ORDER BY ba.user_area) as favorite_area,
        MAX(b.booking_date) as last_booking_date
    FROM bookings b
    JOIN booking_analytics ba ON b.booking_id = ba.booking_id
    WHERE b.user_email = user_email_param
    AND b.payment_status = 'COMPLETED';
END;
$$ LANGUAGE plpgsql;
-- =====================================================
-- INSERT SAMPLE TEST DATA FOR ADVANCED FEATURES
-- =====================================================

-- Sample users for testing advanced features
INSERT INTO users (name, email, password, password_display, area, booking_count, total_spent, user_type, preferences) VALUES
('Advanced Test User', 'test@gmail.com', 'Test@123', 'Test@123', 'Satellite', 5, 2500, 'Premium', 'Action movies, Comedy shows'),
('Demo Analytics User', 'demo@gmail.com', 'Demo@123', 'Demo@123', 'Vastrapur', 3, 1800, 'Regular', 'Romantic movies, Concerts'),
('Sample Data User', 'sample@gmail.com', 'Sample@123', 'Sample@123', 'Paldi', 2, 1200, 'Regular', 'Family movies, Comedy shows'),
('VIP Test User', 'vip@gmail.com', 'Vip@123', 'Vip@123', 'Thaltej', 8, 5000, 'VIP', 'All events, Premium seating'),
('Analytics User', 'analytics@gmail.com', 'Analytics@123', 'Analytics@123', 'Bopal', 4, 2200, 'Regular', 'Data analysis, Reports');

-- Sample bookings for comprehensive analytics
INSERT INTO bookings (user_email, event_type, event_id, event_name, venue_id, venue_name,
                     show_date, show_time, booked_seats, total_amount, booking_date,
                     seat_numbers, row_details, payment_method, payment_status, transaction_id,
                     base_amount, gst_amount, platform_fee, theatre_share, profit_amount,
                     booking_source, user_rating, review_text) VALUES

-- Movie bookings
('test@gmail.com', 'movie', 1, 'Titanic', 1, 'PVR Satellite Plaza',
 CURRENT_DATE, '7:30 PM', 2, 700, NOW() - INTERVAL '5 days',
 'A1, A2', 'Row A x 2 seats', 'UPI', 'COMPLETED', 'TXN1234567890',
 593, 107, 59, 356, 178, 'Web', 5, 'Excellent movie experience!'),

('demo@gmail.com', 'movie', 4, 'Dilwale Dulhania Le Jayenge', 8, 'PVR Vastrapur Lake',
 CURRENT_DATE + INTERVAL '1 day', '5:30 PM', 2, 720, NOW() - INTERVAL '3 days',
 'B3, B4', 'Row B x 2 seats', 'Credit/Debit Card', 'COMPLETED', 'TXN1234567891',
 610, 110, 61, 366, 183, 'Mobile App', 4, 'Good sound quality'),

('sample@gmail.com', 'movie', 32, '3 Idiots', 15, 'PVR Paldi Central',
 CURRENT_DATE + INTERVAL '2 days', '8:45 PM', 3, 1020, NOW() - INTERVAL '2 days',
 'C1, C2, C3', 'Row C x 3 seats', 'Net Banking', 'COMPLETED', 'TXN1234567892',
 864, 156, 86, 518, 260, 'Web', 5, 'Amazing family movie!'),

-- Comedy show bookings
('test@gmail.com', 'comedy', 1, 'The Kapil Sharma Show Live', 1, 'Comedy Club Satellite',
 CURRENT_DATE + INTERVAL '3 days', '8:00 PM', 2, 1000, NOW() - INTERVAL '1 day',
 'G1, G2', 'General x 2 seats', 'UPI', 'COMPLETED', 'TXN1234567893',
 847, 153, 85, 508, 254, 'Web', 5, 'Hilarious show, great comedy!'),

('demo@gmail.com', 'comedy', 2, 'Haq Se Single', 2, 'Laugh Factory Vastrapur',
 CURRENT_DATE + INTERVAL '4 days', '9:00 PM', 1, 600, NOW() - INTERVAL '6 hours',
 'VIP1', 'VIP x 1 seat', 'Credit/Debit Card', 'COMPLETED', 'TXN1234567894',
 508, 92, 51, 305, 152, 'Mobile App', 4, 'Relatable content, enjoyed it'),

-- Concert bookings
('vip@gmail.com', 'concert', 1, 'Arijit Singh Live', 21, 'Concert Hall Satellite',
 CURRENT_DATE + INTERVAL '5 days', '9:00 PM', 2, 2000, NOW() - INTERVAL '12 hours',
 'VIP1, VIP2', 'VIP x 2 seats', 'Credit/Debit Card', 'COMPLETED', 'TXN1234567895',
 1695, 305, 170, 1017, 508, 'Web', 5, 'Mesmerizing voice, perfect concert!'),

('analytics@gmail.com', 'concert', 2, 'Rahman Live Concert', 22, 'Music Arena Vastrapur',
 CURRENT_DATE + INTERVAL '6 days', '8:30 PM', 1, 1500, NOW() - INTERVAL '2 hours',
 'PREMIUM1', 'Premium x 1 seat', 'UPI', 'COMPLETED', 'TXN1234567896',
 1271, 229, 127, 763, 381, 'Mobile App', 5, 'Musical genius at work!');

-- Sample payment transactions
INSERT INTO payment_transactions (transaction_id, booking_id, user_email, amount,
                                payment_method, payment_status, transaction_date, 
                                upi_id, card_last_digits, bank_name, gateway_transaction_id, payment_gateway) VALUES
('TXN1234567890', 1, 'test@gmail.com', 700, 'UPI', 'SUCCESS', NOW() - INTERVAL '5 days', 'test@paytm', NULL, NULL, 'RZP_TXN_001', 'Razorpay'),
('TXN1234567891', 2, 'demo@gmail.com', 720, 'Credit/Debit Card', 'SUCCESS', NOW() - INTERVAL '3 days', NULL, '1234', NULL, 'RZP_TXN_002', 'Razorpay'),
('TXN1234567892', 3, 'sample@gmail.com', 1020, 'Net Banking', 'SUCCESS', NOW() - INTERVAL '2 days', NULL, NULL, 'HDFC Bank', 'RZP_TXN_003', 'Razorpay'),
('TXN1234567893', 4, 'test@gmail.com', 1000, 'UPI', 'SUCCESS', NOW() - INTERVAL '1 day', 'test@paytm', NULL, NULL, 'RZP_TXN_004', 'Razorpay'),
('TXN1234567894', 5, 'demo@gmail.com', 600, 'Credit/Debit Card', 'SUCCESS', NOW() - INTERVAL '6 hours', NULL, '5678', NULL, 'RZP_TXN_005', 'Razorpay'),
('TXN1234567895', 6, 'vip@gmail.com', 2000, 'Credit/Debit Card', 'SUCCESS', NOW() - INTERVAL '12 hours', NULL, '9012', NULL, 'RZP_TXN_006', 'Razorpay'),
('TXN1234567896', 7, 'analytics@gmail.com', 1500, 'UPI', 'SUCCESS', NOW() - INTERVAL '2 hours', 'analytics@phonepe', NULL, NULL, 'RZP_TXN_007', 'Razorpay');

-- =====================================================
-- USEFUL ANALYTICS QUERIES FOR ADVANCED FEATURES
-- =====================================================

-- Create a table to store useful queries as comments for reference

/*
-- 1. Revenue Analytics by Event Type
SELECT * FROM revenue_analytics ORDER BY total_revenue DESC;

-- 2. User Analytics by Area
SELECT * FROM user_analytics ORDER BY total_area_revenue DESC;

-- 3. Daily Booking Trends with Profit
SELECT 
    DATE(booking_date) as booking_date,
    COUNT(*) as total_bookings,
    SUM(total_amount) as daily_revenue,
    SUM(profit_amount) as daily_profit,
    AVG(total_amount) as avg_booking_value
FROM bookings 
WHERE payment_status = 'COMPLETED'
GROUP BY DATE(booking_date)
ORDER BY booking_date DESC;

-- 4. Theatre Performance Analytics
SELECT 
    t.name,
    t.area,
    t.theater_type,
    COUNT(b.booking_id) as total_bookings,
    SUM(b.booked_seats) as total_seats_sold,
    SUM(b.total_amount) as total_revenue,
    AVG(b.total_amount) as avg_booking_value,
    AVG(b.user_rating) as avg_rating,
    t.rating as theatre_rating
FROM theatres t
LEFT JOIN bookings b ON t.theater_id = b.venue_id AND b.event_type = 'movie'
WHERE b.payment_status = 'COMPLETED' OR b.payment_status IS NULL
GROUP BY t.theater_id, t.name, t.area, t.theater_type, t.rating
ORDER BY total_revenue DESC NULLS LAST;

-- 5. Payment Method Success Analysis
SELECT 
    payment_method,
    COUNT(*) as transaction_count,
    SUM(amount) as total_amount,
    AVG(amount) as avg_transaction_value,
    COUNT(CASE WHEN payment_status = 'SUCCESS' THEN 1 END) as successful_transactions,
    ROUND(COUNT(CASE WHEN payment_status = 'SUCCESS' THEN 1 END) * 100.0 / COUNT(*), 2) as success_rate,
    payment_gateway
FROM payment_transactions
GROUP BY payment_method, payment_gateway
ORDER BY total_amount DESC;

-- 6. Movie Popularity by Mood
SELECT 
    m.mood,
    COUNT(b.booking_id) as total_bookings,
    SUM(b.booked_seats) as total_tickets,
    SUM(b.total_amount) as total_revenue,
    AVG(b.user_rating) as avg_user_rating,
    AVG(m.imdb_rating) as avg_imdb_rating
FROM movies m
LEFT JOIN bookings b ON m.id = b.event_id AND b.event_type = 'movie'
WHERE b.payment_status = 'COMPLETED' OR b.payment_status IS NULL
GROUP BY m.mood
ORDER BY total_revenue DESC NULLS LAST;

-- 7. User Booking Patterns
SELECT 
    u.user_type,
    COUNT(b.booking_id) as total_bookings,
    AVG(b.total_amount) as avg_spending,
    AVG(b.user_rating) as avg_rating_given,
    STRING_AGG(DISTINCT b.event_type, ', ') as preferred_events
FROM users u
LEFT JOIN bookings b ON u.email = b.user_email
WHERE b.payment_status = 'COMPLETED' OR b.payment_status IS NULL
GROUP BY u.user_type
ORDER BY avg_spending DESC NULLS LAST;

-- 8. Venue Utilization Analysis
SELECT 
    v.name,
    v.area,
    v.venue_type,
    v.capacity,
    COUNT(b.booking_id) as total_shows,
    SUM(b.booked_seats) as total_tickets_sold,
    ROUND(SUM(b.booked_seats) * 100.0 / (COUNT(b.booking_id) * v.capacity), 2) as utilization_rate,
    SUM(b.total_amount) as total_revenue
FROM venues v
LEFT JOIN bookings b ON v.venue_id = b.venue_id AND b.event_type IN ('comedy', 'concert')
WHERE b.payment_status = 'COMPLETED' OR b.payment_status IS NULL
GROUP BY v.venue_id, v.name, v.area, v.venue_type, v.capacity
ORDER BY total_revenue DESC NULLS LAST;

-- 9. Time-based Booking Analysis
SELECT 
    EXTRACT(HOUR FROM booking_date) as booking_hour,
    EXTRACT(DOW FROM booking_date) as day_of_week,
    COUNT(*) as booking_count,
    AVG(total_amount) as avg_amount
FROM bookings
WHERE payment_status = 'COMPLETED'
GROUP BY EXTRACT(HOUR FROM booking_date), EXTRACT(DOW FROM booking_date)
ORDER BY booking_count DESC;

-- 10. Advanced User Statistics Function Usage
SELECT * FROM get_user_stats('test@gmail.com');
SELECT * FROM get_user_stats('demo@gmail.com');
*/

-- =====================================================
-- SUCCESS MESSAGE AND COMPLETION
-- =====================================================

-- Final success message
SELECT 
    'SmartShow Ultimate Advanced Database Setup Complete!' as status,
    COUNT(*)::TEXT as count_value FROM theatres
UNION ALL
SELECT 
    'Total Venues Created:' as status,
    COUNT(*)::TEXT as count_value FROM venues
UNION ALL
SELECT 
    'Total Movies Available:' as status,
    COUNT(*)::TEXT as count_value FROM movies
UNION ALL
SELECT 
    'Total Comedy Shows:' as status,
    COUNT(*)::TEXT as count_value FROM comedy_shows
UNION ALL
SELECT 
    'Total Concerts:' as status,
    COUNT(*)::TEXT as count_value FROM concerts
UNION ALL
SELECT 
    'Sample Bookings Created:' as status,
    COUNT(*)::TEXT as count_value FROM bookings
UNION ALL
SELECT 
    'Database Ready for Advanced Python Code!' as status,
    'YES' as count_value;

-- =====================================================
-- END OF COMPLETE ADVANCED DATABASE
-- =====================================================
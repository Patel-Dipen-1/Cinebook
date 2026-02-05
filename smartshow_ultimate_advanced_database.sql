-- SmartShow Ultimate Advanced - Database Setup
-- Complete database for the advanced Python implementation with all concepts
-- This database supports the advanced features in smartshow_ultimate_advanced.py

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
-- CREATE TABLES FOR ADVANCED IMPLEMENTATION
-- =====================================================

-- Users table (enhanced for advanced features)
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
    permissions TEXT DEFAULT 'READ,write,delete'
);

-- Theatres table (enhanced with more details)
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
    manager_name VARCHAR(100)
);

-- Movies table (enhanced with more metadata)
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
    poster_url VARCHAR(500)
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
    special_notes TEXT
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
    equipment_info TEXT
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
    accessibility_features TEXT
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
    FOREIGN KEY (theatre_id) REFERENCES theatres(theater_id),
    UNIQUE (theatre_id, row_name, show_date, show_time)
);

-- Bookings table (enhanced with comprehensive profit tracking)
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
    review_text TEXT
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
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

-- =====================================================
-- INSERT ENHANCED SAMPLE DATA
-- =====================================================

-- Insert admin user with enhanced permissions
INSERT INTO admin_users (username, password, full_name, email, role, permissions)
VALUES ('admin', 'Admin@123', 'System Administrator', 'admin@smartshow.com', 'SUPER_ADMIN', 'read,write,delete,analytics,user_management');

-- Insert enhanced theatres (7 theatres per area, 8 areas = 56 total theatres)
INSERT INTO theatres (theater_id, name, area, city, theater_type, total_screens, base_price, total_seats, available_seats, address, facilities, rating, contact_phone, manager_name) VALUES
-- Satellite Area Theatres (1-7) - Enhanced with more details
(1, 'PVR Satellite Plaza', 'Satellite', 'Ahmedabad', 'Premium', 8, 350, 120, 120, 'Satellite Plaza, Satellite, Ahmedabad', 'IMAX, Dolby Atmos, Recliner Seats, Food Court', 4.5, '079-12345001', 'Rajesh Kumar'),
(2, 'INOX Satellite Mall', 'Satellite', 'Ahmedabad', 'Premium', 6, 320, 90, 90, 'Satellite Mall, Satellite, Ahmedabad', '4DX, Premium Seating, Cafe', 4.3, '079-12345002', 'Priya Sharma'),
(3, 'Cinepolis Satellite Square', 'Satellite', 'Ahmedabad', 'Multiplex', 7, 300, 105, 105, 'Satellite Square, Satellite, Ahmedabad', 'VIP Lounge, Gaming Zone', 4.2, '079-12345003', 'Amit Patel'),
(4, 'Fun Cinemas Satellite', 'Satellite', 'Ahmedabad', 'Multiplex', 5, 280, 75, 75, 'Satellite Road, Satellite, Ahmedabad', 'Family Friendly, Parking', 4.0, '079-12345004', 'Neha Gupta'),
(5, 'Rajhans Satellite', 'Satellite', 'Ahmedabad', 'Standard', 4, 250, 60, 60, 'Satellite Circle, Satellite, Ahmedabad', 'Budget Friendly, Snacks', 3.8, '079-12345005', 'Vikram Singh'),
(6, 'Carnival Satellite', 'Satellite', 'Ahmedabad', 'Multiplex', 6,Show Ultimate Advanced Database Setup Complete!' as status;,
    EXTRACT(DOW FROM b.booking_date) as booking_day_of_week,
    EXTRACT(HOUR FROM b.booking_date) as booking_hour
FROM bookings b
JOIN users u ON b.user_email = u.email
LEFT JOIN theatres t ON b.venue_id = t.theater_id AND b.event_type = 'movie'
LEFT JOIN venues v ON b.venue_id = v.venue_id AND b.event_type IN ('comedy', 'concert');

-- =====================================================
-- END OF ADVANCED DATABASE SETUP
-- =====================================================

-- Success message
SELECT 'Smart_amount / 1.18)::INTEGER)::INTEGER as gst_amount,
        ((total_amount / 1.18) * 0.10)::INTEGER as platform_fee,
        ((total_amount / 1.18) * 0.60)::INTEGER as theatre_share,
        ((total_amount / 1.18) * 0.30)::INTEGER as profit_amount;
END;
$$ LANGUAGE plpgsql;

-- Create view for advanced analytics
CREATE VIEW booking_analytics AS
SELECT 
    b.*,
    u.name as user_name,
    u.area as user_area,
    CASE 
        WHEN b.event_type = 'movie' THEN t.name
        ELSE v.name
    END as venue_name_full
-- ADVANCED FEATURES SUPPORT
-- =====================================================

-- Create function for profit calculation (supports advanced Python features)
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
        (total_amount - (totalY booking_date DESC;

-- 5. Payment method analytics
-- SELECT 
--     payment_method,
--     COUNT(*) as transaction_count,
--     SUM(amount) as total_amount,
--     AVG(amount) as avg_transaction_value,
--     COUNT(CASE WHEN payment_status = 'SUCCESS' THEN 1 END) as successful_transactions,
--     ROUND(COUNT(CASE WHEN payment_status = 'SUCCESS' THEN 1 END) * 100.0 / COUNT(*), 2) as success_rate
-- FROM payment_transactions
-- GROUP BY payment_method;

-- =====================================================revenue,
--     AVG(b.total_amount) as avg_booking_value,
--     t.rating
-- FROM theatres t
-- LEFT JOIN bookings b ON t.theater_id = b.venue_id AND b.event_type = 'movie'
-- GROUP BY t.theater_id, t.name, t.area, t.rating
-- ORDER BY total_revenue DESC;

-- 4. Daily booking trends
-- SELECT 
--     DATE(booking_date) as booking_date,
--     COUNT(*) as total_bookings,
--     SUM(total_amount) as daily_revenue,
--     SUM(profit_amount) as daily_profit
-- FROM bookings 
-- GROUP BY DATE(booking_date)
-- ORDER B- SELECT 
--     u.area,
--     COUNT(*) as user_count,
--     AVG(u.booking_count) as avg_bookings_per_user,
--     AVG(u.total_spent) as avg_spent_per_user,
--     SUM(u.total_spent) as total_area_revenue
-- FROM users u 
-- WHERE u.otp IS NULL
-- GROUP BY u.area 
-- ORDER BY total_area_revenue DESC;

-- 3. Theatre performance analytics
-- SELECT 
--     t.name,
--     t.area,
--     COUNT(b.booking_id) as total_bookings,
--     SUM(b.booked_seats) as total_seats_sold,
--     SUM(b.total_amount) as total_), NULL);

-- =====================================================
-- USEFUL QUERIES FOR ADVANCED ANALYTICS
-- =====================================================

-- 1. Revenue analytics by event type
-- SELECT 
--     event_type,
--     COUNT(*) as total_bookings,
--     SUM(booked_seats) as total_tickets,
--     SUM(total_amount) as total_revenue,
--     SUM(profit_amount) as total_profit,
--     AVG(total_amount) as avg_booking_value
-- FROM bookings 
-- GROUP BY event_type;

-- 2. User analytics by area
-LETED', 'TXN1234567892',
 847, 153, 85, 508, 254);

-- Sample payment transactions
INSERT INTO payment_transactions (transaction_id, booking_id, user_email, amount,
                                payment_method, payment_status, transaction_date, upi_id) VALUES
('TXN1234567890', 1, 'test@gmail.com', 700, 'UPI', 'SUCCESS', NOW(), 'test@paytm'),
('TXN1234567891', 2, 'demo@gmail.com', 1000, 'Credit/Debit Card', 'SUCCESS', NOW(), NULL),
('TXN1234567892', 3, 'sample@gmail.com', 1000, 'Net Banking', 'SUCCESS', NOW(PI', 'COMPLETED', 'TXN1234567890',
 593, 107, 59, 356, 178),
('demo@gmail.com', 'comedy', 1, 'The Kapil Sharma Show Live', 1, 'Comedy Club Satellite',
 CURRENT_DATE + INTERVAL '1 day', '8:00 PM', 2, 1000, NOW(),
 'G1, G2', 'General x 2 seats', 'Credit/Debit Card', 'COMPLETED', 'TXN1234567891',
 847, 153, 85, 508, 254),
('sample@gmail.com', 'concert', 1, 'Arijit Singh Live', 6, 'Concert Hall Satellite',
 CURRENT_DATE + INTERVAL '2 days', '9:00 PM', 1, 1000, NOW(),
 'VIP1', 'VIP x 1 seat', 'Net Banking', 'COMPnalytics
INSERT INTO bookings (user_email, event_type, event_id, event_name, venue_id, venue_name,
                     show_date, show_time, booked_seats, total_amount, booking_date,
                     seat_numbers, row_details, payment_method, payment_status, transaction_id,
                     base_amount, gst_amount, platform_fee, theatre_share, profit_amount) VALUES
('test@gmail.com', 'movie', 1, 'Titanic', 1, 'PVR Satellite Plaza',
 CURRENT_DATE, '7:30 PM', 2, 700, NOW(),
 'A1, A2', 'Row A x 2 seats', 'U TEST DATA FOR ADVANCED FEATURES
-- =====================================================

-- Sample users for testing advanced features
INSERT INTO users (name, email, password, password_display, area, booking_count, total_spent) VALUES
('Test User Advanced', 'test@gmail.com', 'Test@123', 'Test@123', 'Satellite', 5, 2500),
('Demo User', 'demo@gmail.com', 'Demo@123', 'Demo@123', 'Vastrapur', 3, 1800),
('Sample User', 'sample@gmail.com', 'Sample@123', 'Sample@123', 'Paldi', 2, 1200);

-- Sample bookings for adate ON bookings(booking_date);
CREATE INDEX idx_theatre_rows_theatre_date_time ON theatre_rows(theatre_id, show_date, show_time);
CREATE INDEX idx_payment_transactions_booking_id ON payment_transactions(booking_id);
CREATE INDEX idx_payment_transactions_user_email ON payment_transactions(user_email);
CREATE INDEX idx_theatres_area ON theatres(area);
CREATE INDEX idx_venues_area ON venues(area);
CREATE INDEX idx_movies_mood ON movies(mood);

-- =====================================================
-- SAMPLEe Performance', 'Live band, choreographed show');

-- =====================================================
-- CREATE INDEXES FOR BETTER PERFORMANCE
-- =====================================================

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_area ON users(area);
CREATE INDEX idx_bookings_user_email ON bookings(user_email);
CREATE INDEX idx_bookings_event_type ON bookings(event_type);
CREATE INDEX idx_bookings_show_date ON bookings(show_date);
CREATE INDEX idx_bookings_booking_Night', 'Electronic', 90, 'Instrumental', 800, 'High-energy EDM night', 'Divine', 'Pioneer of Indian EDM', 'DJ Set', 'Professional DJ equipment, light show'),
(4, 'Rahat Fateh Ali Khan', 'Sufi Night', 'Sufi', 100, 'Urdu', 1200, 'Spiritual music experience', 'Kailash Kher', 'Renowned Sufi singer', 'Sufi Performance', 'Traditional instruments, acoustic setup'),
(5, 'Sunidhi Chauhan', 'Bollywood Diva Live', 'Bollywood', 110, 'Hindi', 900, 'Energetic Bollywood performance', 'Shaan', 'Versatile playback singer', 'Liv_bio, concert_type, equipment_info) VALUES
(1, 'Arijit Singh', 'Arijit Singh Live', 'Bollywood', 120, 'Hindi', 1000, 'Romantic Bollywood hits live performance', 'Shreya Ghoshal', 'Leading playback singer', 'Live Concert', 'Professional sound system, live band'),
(2, 'A.R. Rahman', 'Rahman Live Concert', 'Classical/Fusion', 150, 'Multi', 1500, 'Musical maestro live with orchestra', 'Hariharan', 'Oscar-winning composer', 'Orchestra Concert', 'Full orchestra, digital mixing'),
(3, 'Nucleya', 'Electronic Dance 5, 'English', '16+', 'Observational comedy about life', 650, 'Multi-talented comedian and musician', 4.6, 'Clean comedy suitable for families'),
(5, 'Abhishek Upmanyu', 'Thoda Saaf Bol', 'Stand-up Comedy', 85, 'Hindi', '18+', 'Clean comedy show with social commentary', 500, 'IIT graduate comedian', 4.4, 'Educational background adds depth');

-- Insert enhanced concerts
INSERT INTO concerts (concert_id, artist_name, concert_title, genre, duration_minutes, language, ticket_price, description, special_guests, artisttor', 4.5, 'Interactive audience participation'),
(2, 'Zakir Khan', 'Haq Se Single', 'Stand-up Comedy', 85, 'Hindi', '18+', 'Comedy about being single and relationships', 600, 'YouTube sensation turned comedian', 4.7, 'Relatable content for millennials'),
(3, 'Biswa Kalyan Rath', 'Pretentious Movie Reviews', 'Stand-up Comedy', 80, 'English', '18+', 'Witty movie review comedy', 550, 'Engineer turned comedian', 4.3, 'Intellectual humor'),
(4, 'Kenny Sebastian', 'The Most Interesting Person', 'Stand-up Comedy', 7ion', 'Brad Bird', 'Craig T. Nelson, Holly Hunter', '2004-11-05', 8.0, 'Superhero family', 'https://example.com/incredibles.jpg');

-- Insert enhanced comedy shows
INSERT INTO comedy_shows (show_id, comedian_name, show_title, show_type, duration_minutes, language, age_rating, description, ticket_price, comedian_bio, show_rating, special_notes) VALUES
(1, 'Kapil Sharma', 'The Kapil Sharma Show Live', 'Stand-up Comedy', 90, 'Hindi', '18+', 'Hilarious comedy show with celebrity guests', 500, 'Popular TV comedian and ac'Women empowerment story', 'https://example.com/queen.jpg'),
(38, 'Toy Story', 'Family', 81, 'G', 'English', 'Family/Animation', 'John Lasseter', 'Tom Hanks, Tim Allen', '1995-11-22', 8.3, 'Toys come to life', 'https://example.com/toystory.jpg'),
(39, 'Hindi Medium', 'Family', 132, 'U', 'Hindi', 'Family/Comedy', 'Saket Chaudhary', 'Irrfan Khan, Saba Qamar', '2017-05-19', 7.9, 'Education system satire', 'https://example.com/hindimedium.jpg'),
(40, 'The Incredibles', 'Family', 115, 'PG', 'English', 'Family/Animatn King', 'Family', 88, 'G', 'English', 'Family/Animation', 'Roger Allers', 'Matthew Broderick, Jeremy Irons', '1994-06-24', 8.5, 'Disney classic', 'https://example.com/lionking.jpg'),
(36, 'Coco', 'Family', 105, 'PG', 'English', 'Family/Animation', 'Lee Unkrich', 'Anthony Gonzalez, Gael García Bernal', '2017-11-22', 8.4, 'Mexican culture celebration', 'https://example.com/coco.jpg'),
(37, 'Queen', 'Family', 146, 'U/A', 'Hindi', 'Family/Comedy', 'Vikas Bahl', 'Kangana Ranaut, Rajkummar Rao', '2013-03-07', 8.2, n, R. Madhavan', '2009-12-25', 8.4, 'Educational comedy-drama', 'https://example.com/3idiots.jpg'),
(33, 'Dangal', 'Family', 161, 'U', 'Hindi', 'Family/Sports', 'Nitesh Tiwari', 'Aamir Khan, Fatima Sana Shaikh', '2016-12-23', 8.4, 'Wrestling family drama', 'https://example.com/dangal.jpg'),
(34, 'Finding Nemo', 'Family', 100, 'G', 'English', 'Family/Animation', 'Andrew Stanton', 'Albert Brooks, Ellen DeGeneres', '2003-05-30', 8.2, 'Underwater adventure', 'https://example.com/findingnemo.jpg'),
(35, 'The Lio30, 'Dumb and Dumber', 'Comedy', 107, 'PG-13', 'English', 'Comedy', 'Peter Farrelly', 'Jim Carrey, Jeff Daniels', '1994-12-16', 7.3, 'Silly buddy comedy', 'https://example.com/dumbanddumber.jpg'),

-- Family Movies (31-40)
(31, 'Taare Zameen Par', 'Family', 165, 'U', 'Hindi', 'Family/Drama', 'Aamir Khan', 'Aamir Khan, Darsheel Safary', '2007-12-21', 8.4, 'Inspiring story about special child', 'https://example.com/tzp.jpg'),
(32, '3 Idiots', 'Family', 170, 'U', 'Hindi', 'Family/Comedy', 'Rajkumar Hirani', 'Aamir Khaomedy/Drama', 'Rajkumar Hirani', 'Sanjay Dutt, Arshad Warsi', '2003-12-19', 8.1, 'Heartwarming comedy', 'https://example.com/munnabhai.jpg'),
(28, 'Superbad', 'Comedy', 113, 'R', 'English', 'Comedy', 'Greg Mottola', 'Jonah Hill, Michael Cera', '2007-08-17', 7.6, 'Teen comedy adventure', 'https://example.com/superbad.jpg'),
(29, 'Fukrey', 'Comedy', 139, 'U/A', 'Hindi', 'Comedy', 'Mrighdeep Singh Lamba', 'Pulkit Samrat, Varun Sharma', '2013-06-14', 6.9, 'Delhi boys comedy', 'https://example.com/fukrey.jpg'),
(f', '2007-12-21', 7.0, 'Comedy of errors', 'https://example.com/welcome.jpg'),
(25, 'Housefull', 'Comedy', 140, 'U/A', 'Hindi', 'Comedy', 'Sajid Khan', 'Akshay Kumar, Deepika Padukone', '2010-04-30', 5.5, 'Multi-starrer comedy', 'https://example.com/housefull.jpg'),
(26, 'The Hangover', 'Comedy', 100, 'R', 'English', 'Comedy', 'Todd Phillips', 'Bradley Cooper, Ed Helms', '2009-06-05', 7.7, 'Bachelor party gone wrong', 'https://example.com/hangover.jpg'),
(27, 'Munna Bhai MBBS', 'Comedy', 156, 'U', 'Hindi', 'Casterpiece', 'https://example.com/herapheri.jpg'),
(22, 'Golmaal', 'Comedy', 150, 'U', 'Hindi', 'Comedy', 'Rohit Shetty', 'Ajay Devgn, Arshad Warsi', '2006-07-14', 7.4, 'Fun-filled comedy', 'https://example.com/golmaal.jpg'),
(23, 'Andaz Apna Apna', 'Comedy', 160, 'U', 'Hindi', 'Comedy', 'Rajkumar Santoshi', 'Aamir Khan, Salman Khan', '1994-11-04', 8.2, 'Cult comedy classic', 'https://example.com/andazapnaapna.jpg'),
(24, 'Welcome', 'Comedy', 159, 'U', 'Hindi', 'Comedy', 'Anees Bazmee', 'Akshay Kumar, Katrina Kai 'Action/Drama', 'Sukumar', 'Allu Arjun, Rashmika Mandanna', '2021-12-17', 7.6, 'Raw action drama', 'https://example.com/pushpa.jpg'),
(20, 'Mission Impossible', 'Action', 147, 'PG-13', 'English', 'Action/Thriller', 'Brian De Palma', 'Tom Cruise, Jon Voight', '1996-05-22', 7.1, 'Spy action thriller', 'https://example.com/mi.jpg'),

-- Comedy Movies (21-30)
(21, 'Hera Pheri', 'Comedy', 156, 'U', 'Hindi', 'Comedy', 'Priyadarshan', 'Akshay Kumar, Suniel Shetty, Paresh Rawal', '2000-03-31', 8.2, 'Classic comedy m '2015-05-15', 8.1, 'Post-apocalyptic action', 'https://example.com/madmax.jpg'),
(17, 'War', 'Action', 156, 'U/A', 'Hindi', 'Action/Thriller', 'Siddharth Anand', 'Hrithik Roshan, Tiger Shroff', '2019-10-02', 6.5, 'High-tech action thriller', 'https://example.com/war.jpg'),
(18, 'John Wick', 'Action', 101, 'R', 'English', 'Action/Thriller', 'Chad Stahelski', 'Keanu Reeves, Michael Nyqvist', '2014-10-24', 7.4, 'Stylized action revenge', 'https://example.com/johnwick.jpg'),
(19, 'Pushpa', 'Action', 179, 'U/A', 'Hindi',li2.jpg'),
(14, 'KGF Chapter 2', 'Action', 168, 'U/A', 'Hindi', 'Action/Drama', 'Prashanth Neel', 'Yash, Sanjay Dutt', '2022-04-14', 8.4, 'Powerful action sequel', 'https://example.com/kgf2.jpg'),
(15, 'Pathaan', 'Action', 146, 'U/A', 'Hindi', 'Action/Thriller', 'Siddharth Anand', 'Shah Rukh Khan, Deepika Padukone', '2023-01-25', 5.7, 'Spy action thriller', 'https://example.com/pathaan.jpg'),
(16, 'Mad Max: Fury Road', 'Action', 120, 'R', 'English', 'Action/Sci-Fi', 'George Miller', 'Tom Hardy, Charlize Theron', 'Robert Downey Jr., Chris Evans', '2019-04-26', 8.4, 'Epic superhero finale', 'https://example.com/endgame.jpg'),
(12, 'Fast & Furious 9', 'Action', 143, 'PG-13', 'English', 'Action/Thriller', 'Justin Lin', 'Vin Diesel, Michelle Rodriguez', '2021-06-25', 5.2, 'High-octane action adventure', 'https://example.com/ff9.jpg'),
(13, 'Baahubali 2', 'Action', 167, 'U/A', 'Hindi', 'Action/Drama', 'S.S. Rajamouli', 'Prabhas, Rana Daggubati', '2017-04-28', 8.7, 'Epic Indian action drama', 'https://example.com/baahuba, 155, 'U/A', 'Hindi', 'Romance/Adventure', 'Zoya Akhtar', 'Hrithik Roshan, Katrina Kaif', '2011-07-15', 8.2, 'Life-changing Spanish adventure', 'https://example.com/znmd.jpg'),
(10, 'The Princess Bride', 'Romantic', 98, 'PG', 'English', 'Romance/Adventure', 'Rob Reiner', 'Cary Elwes, Robin Wright', '1987-09-25', 8.0, 'Fairy tale romance adventure', 'https://example.com/princessbride.jpg'),

-- Action Movies (11-20)
(11, 'Avengers: Endgame', 'Action', 181, 'PG-13', 'English', 'Action/Sci-Fi', 'Russo Brothers',artime romance', 'https://example.com/casablanca.jpg'),
(7, 'Yeh Jawaani Hai Deewani', 'Romantic', 161, 'U', 'Hindi', 'Romance/Comedy', 'Ayan Mukerji', 'Ranbir Kapoor, Deepika Padukone', '2013-05-31', 7.2, 'Youth, friendship, and love', 'https://example.com/yjhd.jpg'),
(8, 'Before Sunrise', 'Romantic', 101, 'R', 'English', 'Romance/Drama', 'Richard Linklater', 'Ethan Hawke, Julie Delpy', '1995-01-27', 8.1, 'One night in Vienna', 'https://example.com/beforesunrise.jpg'),
(9, 'Zindagi Na Milegi Dobara', 'Romantic'9, 'U', 'Hindi', 'Romance/Drama', 'Aditya Chopra', 'Shah Rukh Khan, Kajol', '1995-10-20', 8.1, 'Classic Bollywood romance', 'https://example.com/ddlj.jpg'),
(5, 'Jab We Met', 'Romantic', 138, 'U', 'Hindi', 'Romance/Comedy', 'Imtiaz Ali', 'Shahid Kapoor, Kareena Kapoor', '2007-10-26', 7.9, 'Journey of love and self-discovery', 'https://example.com/jabwemet.jpg'),
(6, 'Casablanca', 'Romantic', 102, 'PG', 'English', 'Romance/Drama', 'Michael Curtiz', 'Humphrey Bogart, Ingrid Bergman', '1942-11-26', 8.5, 'Classic w ill-fated ship', 'https://example.com/titanic.jpg'),
(2, 'The Notebook', 'Romantic', 123, 'PG-13', 'English', 'Romance/Drama', 'Nick Cassavetes', 'Ryan Gosling, Rachel McAdams', '2004-06-25', 7.8, 'A timeless love story', 'https://example.com/notebook.jpg'),
(3, 'La La Land', 'Romantic', 128, 'PG-13', 'English', 'Romance/Musical', 'Damien Chazelle', 'Ryan Gosling, Emma Stone', '2016-12-09', 8.0, 'Modern musical romance', 'https://example.com/lalaland.jpg'),
(4, 'Dilwale Dulhania Le Jayenge', 'Romantic', 18', 'Premium Sound, Lighting, VIP', 'Electro-Voice', 'ADJ Lighting', 225, 'Universal Access');

-- Insert enhanced movies (40 movies with detailed information)
INSERT INTO movies (id, movie_name, mood, duration_minutes, rating, language, genre, director, cast_info, release_date, imdb_rating, description, poster_url) VALUES
-- Romantic Movies (1-10)
(1, 'Titanic', 'Romantic', 195, 'PG-13', 'English', 'Romance/Drama', 'James Cameron', 'Leonardo DiCaprio, Kate Winslet', '1997-12-19', 7.8, 'Epic romance aboard ther Access, Lifts'),
(8, 'Symphony Hall Paldi', 'Paldi', 'Ahmedabad', 'Concert Venue', 400, 400, 1100, 'Paldi, Ahmedabad', 'Premium Sound, Lighting', 'd&b audiotechnik', 'ETC Lighting', 200, 'Complete Accessibility'),
(9, 'Melody Center Thaltej', 'Thaltej', 'Ahmedabad', 'Music Venue', 350, 350, 1150, 'Thaltej, Ahmedabad', 'Professional Sound, Stage', 'QSC Audio', 'Chauvet Professional', 175, 'Accessible Design'),
(10, 'Rhythm Palace Bopal', 'Bopal', 'Ahmedabad', 'Concert Venue', 450, 450, 1050, 'Bopal, Ahmedabadpal, Ahmedabad', 'AC, Stage Lighting, Cafe', 'Behringer Pro', 'LED Par Lights', 80, 'Ramp Access, Special Seating'),
(6, 'Concert Hall Satellite', 'Satellite', 'Ahmedabad', 'Concert Venue', 500, 500, 1000, 'Satellite, Ahmedabad', 'Premium Sound, Lighting, VIP', 'L-Acoustics', 'Martin Professional', 250, 'Full Accessibility'),
(7, 'Music Arena Vastrapur', 'Vastrapur', 'Ahmedabad', 'Music Venue', 300, 300, 1200, 'Vastrapur, Ahmedabad', 'Professional Sound, Stage', 'Meyer Sound', 'Clay Paky Lighting', 150, 'Wheelchaiights', 100, 'Accessible Seating, Elevators'),
(3, 'Stand-Up Central Paldi', 'Paldi', 'Ahmedabad', 'Comedy Hall', 120, 120, 550, 'Paldi, Ahmedabad', 'Premium Sound, AC, Bar', 'Yamaha Professional', 'Intelligent Lighting', 60, 'Wheelchair Access'),
(4, 'Comedy Corner Thaltej', 'Thaltej', 'Ahmedabad', 'Comedy Club', 180, 180, 480, 'Thaltej, Ahmedabad', 'AC, Sound System, Bar', 'Shure Audio', 'DMX Lighting', 90, 'Accessible Facilities'),
(5, 'Humor Hub Bopal', 'Bopal', 'Ahmedabad', 'Comedy Venue', 160, 160, 520, 'Boacity, base_price, address, facilities, sound_system, lighting_system, parking_capacity, accessibility_features) VALUES
(1, 'Comedy Club Satellite', 'Satellite', 'Ahmedabad', 'Comedy Club', 150, 150, 500, 'Satellite Road, Ahmedabad', 'AC, Bar, VIP Seating', 'Bose Professional', 'LED Stage Lighting', 75, 'Wheelchair Access, Ramps'),
(2, 'Laugh Factory Vastrapur', 'Vastrapur', 'Ahmedabad', 'Comedy Venue', 200, 200, 450, 'Vastrapur, Ahmedabad', 'AC, Stage, Green Room', 'JBL Sound System', 'Professional Stage L'),
(55, 'Carnival Chandkheda', 'Chandkheda', 'Ahmedabad', 'Multiplex', 6, 290, 85, 85, 'Chandkheda Cross Roads, Chandkheda, Ahmedabad', 'Cross Roads Point', 4.1, '079-12345055', 'Neeta Kumar'),
(56, 'Miraj Chandkheda', 'Chandkheda', 'Ahmedabad', 'Standard', 5, 270, 70, 70, 'Chandkheda Square, Chandkheda, Ahmedabad', 'Square Area', 3.9, '079-12345056', 'Dilip Sharma');

-- Insert enhanced venues for comedy shows and concerts
INSERT INTO venues (venue_id, name, area, city, venue_type, capacity, available_capndkheda', 'Ahmedabad', 'Multiplex', 7, 300, 105, 105, 'Chandkheda Main Road, Chandkheda, Ahmedabad', 'Main Road Access', 4.2, '079-12345052', 'Gopal Rao'),
(53, 'Fun Cinemas Chandkheda', 'Chandkheda', 'Ahmedabad', 'Multiplex', 5, 280, 75, 75, 'Chandkheda Circle, Chandkheda, Ahmedabad', 'Circle Hub', 4.0, '079-12345053', 'Sushma Agarwal'),
(54, 'Rajhans Chandkheda', 'Chandkheda', 'Ahmedabad', 'Standard', 4, 250, 60, 60, 'Chandkheda Garden, Chandkheda, Ahmedabad', 'Garden View', 3.8, '079-12345054', 'Bharat PatelNaranpura, Ahmedabad', 'Square Location', 3.9, '079-12345049', 'Vijay Mehta'),

-- Chandkheda Area Theatres (50-56)
(50, 'PVR Chandkheda Central', 'Chandkheda', 'Ahmedabad', 'Premium', 8, 350, 120, 120, 'Chandkheda Central, Chandkheda, Ahmedabad', 'Central Location', 4.5, '079-12345050', 'Ajay Desai'),
(51, 'INOX Chandkheda Mall', 'Chandkheda', 'Ahmedabad', 'Premium', 6, 320, 90, 90, 'Chandkheda Mall, Chandkheda, Ahmedabad', 'Mall Experience', 4.3, '079-12345051', 'Renu Shah'),
(52, 'Cinepolis Chandkheda', 'Chaa, Ahmedabad', 'Circle Point', 4.0, '079-12345046', 'Lata Singh'),
(47, 'Rajhans Naranpura', 'Naranpura', 'Ahmedabad', 'Standard', 4, 260, 60, 60, 'Naranpura Garden, Naranpura, Ahmedabad', 'Garden Area', 3.8, '079-12345047', 'Mohan Patel'),
(48, 'Carnival Naranpura', 'Naranpura', 'Ahmedabad', 'Multiplex', 6, 300, 85, 85, 'Naranpura Cross Roads, Naranpura, Ahmedabad', 'Cross Roads', 4.1, '079-12345048', 'Usha Joshi'),
(49, 'Miraj Naranpura', 'Naranpura', 'Ahmedabad', 'Standard', 5, 280, 70, 70, 'Naranpura Square, ll Complex', 4.6, '079-12345043', 'Kiran Jain'),
(44, 'INOX Naranpura Plaza', 'Naranpura', 'Ahmedabad', 'Premium', 6, 330, 90, 90, 'Naranpura Plaza, Naranpura, Ahmedabad', 'Plaza Premium', 4.4, '079-12345044', 'Asha Verma'),
(45, 'Cinepolis Naranpura', 'Naranpura', 'Ahmedabad', 'Multiplex', 7, 310, 105, 105, 'Naranpura Main Road, Naranpura, Ahmedabad', 'Main Road', 4.2, '079-12345045', 'Prakash Gupta'),
(46, 'Fun Cinemas Naranpura', 'Naranpura', 'Ahmedabad', 'Multiplex', 5, 290, 75, 75, 'Naranpura Circle, Naranpur, 'Carnival Maninagar', 'Maninagar', 'Ahmedabad', 'Multiplex', 6, 280, 85, 85, 'Maninagar Cross Roads, Maninagar, Ahmedabad', 'Cross Roads Hub', 4.1, '079-12345041', 'Seema Kumar'),
(42, 'Miraj Maninagar', 'Maninagar', 'Ahmedabad', 'Standard', 5, 260, 70, 70, 'Maninagar Square, Maninagar, Ahmedabad', 'Square Complex', 3.9, '079-12345042', 'Ramesh Sharma'),

-- Naranpura Area Theatres (43-49)
(43, 'PVR Naranpura Mall', 'Naranpura', 'Ahmedabad', 'Premium', 8, 360, 120, 120, 'Naranpura Mall, Naranpura, Ahmedabad', 'MaManinagar', 'Ahmedabad', 'Multiplex', 7, 290, 105, 105, 'Maninagar Main Road, Maninagar, Ahmedabad', 'Main Road Access', 4.2, '079-12345038', 'Sunil Rao'),
(39, 'Fun Cinemas Maninagar', 'Maninagar', 'Ahmedabad', 'Multiplex', 5, 270, 75, 75, 'Maninagar Circle, Maninagar, Ahmedabad', 'Circle Area', 4.0, '079-12345039', 'Manju Agarwal'),
(40, 'Rajhans Maninagar', 'Maninagar', 'Ahmedabad', 'Standard', 4, 240, 60, 60, 'Maninagar Garden, Maninagar, Ahmedabad', 'Garden Side', 3.8, '079-12345040', 'Jitesh Patel'),
(410, 'Bopal Park, Bopal, Ahmedabad', 'Park Location', 3.9, '079-12345035', 'Sachin Mehta'),

-- Maninagar Area Theatres (36-42)
(36, 'PVR Maninagar Central', 'Maninagar', 'Ahmedabad', 'Premium', 8, 340, 120, 120, 'Maninagar Central, Maninagar, Ahmedabad', 'Central Hub', 4.5, '079-12345036', 'Yogesh Desai'),
(37, 'INOX Maninagar Plaza', 'Maninagar', 'Ahmedabad', 'Premium', 6, 310, 90, 90, 'Maninagar Plaza, Maninagar, Ahmedabad', 'Plaza Center', 4.3, '079-12345037', 'Bhavna Shah'),
(38, 'Cinepolis Maninagar', 'bad', 'Multiplex', 5, 280, 75, 75, 'Bopal Circle, Bopal, Ahmedabad', 'Circle Point', 4.0, '079-12345032', 'Ritu Singh'),
(33, 'Rajhans Bopal', 'Bopal', 'Ahmedabad', 'Standard', 4, 250, 60, 60, 'Bopal Garden, Bopal, Ahmedabad', 'Garden Area', 3.8, '079-12345033', 'Harish Patel'),
(34, 'Carnival Bopal', 'Bopal', 'Ahmedabad', 'Multiplex', 6, 290, 85, 85, 'Bopal Cross Roads, Bopal, Ahmedabad', 'Cross Roads', 4.1, '079-12345034', 'Kavya Joshi'),
(35, 'Miraj Bopal', 'Bopal', 'Ahmedabad', 'Standard', 5, 270, 70, 7pal Square', 'Bopal', 'Ahmedabad', 'Premium', 8, 350, 120, 120, 'Bopal Square, Bopal, Ahmedabad', 'Square Complex', 4.5, '079-12345029', 'Nitin Jain'),
(30, 'INOX Bopal Mall', 'Bopal', 'Ahmedabad', 'Premium', 6, 320, 90, 90, 'Bopal Mall, Bopal, Ahmedabad', 'Mall Experience', 4.3, '079-12345030', 'Shilpa Verma'),
(31, 'Cinepolis Bopal', 'Bopal', 'Ahmedabad', 'Multiplex', 7, 300, 105, 105, 'Bopal Main Road, Bopal, Ahmedabad', 'Main Road', 4.2, '079-12345031', 'Anil Gupta'),
(32, 'Fun Cinemas Bopal', 'Bopal', 'Ahmedaaltej', 'Ahmedabad', 'Standard', 4, 270, 60, 60, 'Thaltej Garden, Thaltej, Ahmedabad', 'Garden View', 3.8, '079-12345026', 'Dinesh Patel'),
(27, 'Carnival Thaltej', 'Thaltej', 'Ahmedabad', 'Multiplex', 6, 310, 85, 85, 'Thaltej Square, Thaltej, Ahmedabad', 'Square Location', 4.1, '079-12345027', 'Geeta Kumar'),
(28, 'Miraj Thaltej', 'Thaltej', 'Ahmedabad', 'Standard', 5, 290, 70, 70, 'Thaltej Park, Thaltej, Ahmedabad', 'Park Side', 3.9, '079-12345028', 'Mukesh Sharma'),

-- Bopal Area Theatres (29-35)
(29, 'PVR Bo, 'Ahmedabad', 'Premium', 6, 340, 90, 90, 'Thaltej Plaza, Thaltej, Ahmedabad', 'Plaza Premium', 4.4, '079-12345023', 'Priyanka Shah'),
(24, 'Cinepolis Thaltej', 'Thaltej', 'Ahmedabad', 'Multiplex', 7, 320, 105, 105, 'Thaltej Cross Roads, Thaltej, Ahmedabad', 'Cross Roads Access', 4.2, '079-12345024', 'Rahul Rao'),
(25, 'Fun Cinemas Thaltej', 'Thaltej', 'Ahmedabad', 'Multiplex', 5, 300, 75, 75, 'Thaltej Circle, Thaltej, Ahmedabad', 'Circle Hub', 4.0, '079-12345025', 'Swati Agarwal'),
(26, 'Rajhans Thaltej', 'Th 280, 85, 85, 'Paldi Cross Roads, Paldi, Ahmedabad', 'Cross Roads Hub', 4.1, '079-12345020', 'Nisha Joshi'),
(21, 'Miraj Paldi', 'Paldi', 'Ahmedabad', 'Standard', 5, 260, 70, 70, 'Paldi Square, Paldi, Ahmedabad', 'Square Complex', 3.9, '079-12345021', 'Ashok Mehta'),

-- Thaltej Area Theatres (22-28)
(22, 'PVR Thaltej Mall', 'Thaltej', 'Ahmedabad', 'Premium', 8, 370, 120, 120, 'Thaltej Mall, Thaltej, Ahmedabad', 'Mall Complex, Premium', 4.6, '079-12345022', 'Vishal Desai'),
(23, 'INOX Thaltej Plaza', 'Thaltej'ad', 'Multiplex', 7, 290, 105, 105, 'Paldi Main Road, Paldi, Ahmedabad', 'Main Road Access', 4.2, '079-12345017', 'Manoj Gupta'),
(18, 'Fun Cinemas Paldi', 'Paldi', 'Ahmedabad', 'Multiplex', 5, 270, 75, 75, 'Paldi Circle, Paldi, Ahmedabad', 'Circle Location', 4.0, '079-12345018', 'Rekha Singh'),
(19, 'Rajhans Paldi', 'Paldi', 'Ahmedabad', 'Standard', 4, 240, 60, 60, 'Paldi Garden, Paldi, Ahmedabad', 'Garden Setting', 3.8, '079-12345019', 'Suresh Patel'),
(20, 'Carnival Paldi', 'Paldi', 'Ahmedabad', 'Multiplex', 6,'Vastrapur Square, Vastrapur, Ahmedabad', 'Community Theater', 3.9, '079-12345014', 'Sunita Sharma'),

-- Paldi Area Theatres (15-21)
(15, 'PVR Paldi Central', 'Paldi', 'Ahmedabad', 'Premium', 8, 340, 120, 120, 'Paldi Central, Paldi, Ahmedabad', 'Central Location, Premium', 4.5, '079-12345015', 'Ravi Jain'),
(16, 'INOX Paldi Plaza', 'Paldi', 'Ahmedabad', 'Premium', 6, 310, 90, 90, 'Paldi Plaza, Paldi, Ahmedabad', 'Plaza Complex', 4.3, '079-12345016', 'Anjali Verma'),
(17, 'Cinepolis Paldi', 'Paldi', 'Ahmedabd', 'Family Entertainment', 4.0, '079-12345011', 'Pooja Agarwal'),
(12, 'Rajhans Vastrapur', 'Vastrapur', 'Ahmedabad', 'Standard', 4, 260, 60, 60, 'Vastrapur Garden, Vastrapur, Ahmedabad', 'Garden View, Peaceful', 3.8, '079-12345012', 'Kiran Patel'),
(13, 'Carnival Vastrapur', 'Vastrapur', 'Ahmedabad', 'Multiplex', 6, 300, 85, 85, 'Vastrapur Cross Roads, Vastrapur, Ahmedabad', 'Central Location', 4.1, '079-12345013', 'Deepak Kumar'),
(14, 'Miraj Vastrapur', 'Vastrapur', 'Ahmedabad', 'Standard', 5, 280, 70, 70, anjay Desai'),
(9, 'INOX Vastrapur Mall', 'Vastrapur', 'Ahmedabad', 'Premium', 6, 330, 90, 90, 'Vastrapur Mall, Vastrapur, Ahmedabad', 'Shopping Complex, Food Court', 4.4, '079-12345009', 'Meera Shah'),
(10, 'Cinepolis Vastrapur', 'Vastrapur', 'Ahmedabad', 'Multiplex', 7, 310, 105, 105, 'Vastrapur Main Road, Vastrapur, Ahmedabad', 'Modern Facilities', 4.2, '079-12345010', 'Arjun Rao'),
(11, 'Fun Cinemas Vastrapur', 'Vastrapur', 'Ahmedabad', 'Multiplex', 5, 290, 75, 75, 'Vastrapur Circle, Vastrapur, Ahmedaba 290, 85, 85, 'Satellite Cross Roads, Satellite, Ahmedabad', 'Digital Projection, AC', 4.1, '079-12345006', 'Kavita Joshi'),
(7, 'Miraj Satellite', 'Satellite', 'Ahmedabad', 'Standard', 5, 270, 70, 70, 'Satellite Garden, Satellite, Ahmedabad', 'Comfortable Seating', 3.9, '079-12345007', 'Rohit Mehta'),

-- Vastrapur Area Theatres (8-14)
(8, 'PVR Vastrapur Lake', 'Vastrapur', 'Ahmedabad', 'Premium', 8, 360, 120, 120, 'Vastrapur Lake, Vastrapur, Ahmedabad', 'Lakeside View, Premium Experience', 4.6, '079-12345008', 'S
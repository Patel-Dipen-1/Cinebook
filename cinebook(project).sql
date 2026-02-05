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
    transaction_id VARCHAR(100)
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

-- Insert theatres
INSERT INTO theatres (theater_id, name, area, city, theater_type, total_screens, base_price, total_seats, available_seats, address) VALUES
(1, 'PVR Acropolis Mall', 'Thaltej', 'Ahmedabad', 'Premium', 8, 350, 120, 120, 'Acropolis Mall, Thaltej, Ahmedabad'),
(2, 'INOX R City Mall', 'Paldi', 'Ahmedabad', 'Premium', 6, 320, 90, 90, 'R City Mall, Paldi, Ahmedabad'),
(3, 'Cinepolis Alpha One Mall', 'Vastrapur', 'Ahmedabad', 'Multiplex', 7, 300, 105, 105, 'Alpha One Mall, Vastrapur, Ahmedabad'),
(4, 'PVR Himalaya Mall', 'Satellite', 'Ahmedabad', 'Premium', 5, 330, 75, 75, 'Himalaya Mall, Satellite, Ahmedabad'),
(5, 'Fun Cinemas Ahmedabad One', 'Vastrapur', 'Ahmedabad', 'Multiplex', 4, 280, 60, 60, 'Ahmedabad One Mall, Vastrapur');

-- Insert venues for comedy shows and concerts
INSERT INTO venues (venue_id, name, area, city, venue_type, capacity, available_capacity, base_price, address, facilities) VALUES
(1, 'Comedy Club Ahmedabad', 'Satellite', 'Ahmedabad', 'Comedy Club', 150, 150, 500, 'Satellite Road, Ahmedabad', 'AC, Sound System, Bar'),
(2, 'Laugh Factory', 'Vastrapur', 'Ahmedabad', 'Comedy Venue', 200, 200, 450, 'Vastrapur, Ahmedabad', 'AC, Stage Lighting'),
(3, 'Stand-Up Central', 'Paldi', 'Ahmedabad', 'Comedy Hall', 120, 120, 550, 'Paldi, Ahmedabad', 'Premium Sound, AC'),
(4, 'Concert Hall Ahmedabad', 'Thaltej', 'Ahmedabad', 'Concert Venue', 500, 500, 1000, 'Thaltej, Ahmedabad', 'Premium Sound, Lighting, VIP Seating'),
(5, 'Music Arena', 'Satellite', 'Ahmedabad', 'Music Venue', 300, 300, 1200, 'Satellite, Ahmedabad', 'Professional Sound, Stage');

-- Insert movies (4 moods, 5 movies each)
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
-- =====================================================
select*from users
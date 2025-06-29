-- =====================================================
-- Airbnb Clone Database Schema
-- =====================================================
-- This script creates the complete database schema for the Airbnb Clone project
-- including all tables, constraints, indexes, and relationships.
-- 
-- Database: MySQL/PostgreSQL Compatible
-- Version: 1.0
-- Created: 2025
-- =====================================================

-- Set SQL mode and character set (MySQL specific)
-- SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
-- SET AUTOCOMMIT = 0;
-- START TRANSACTION;
-- SET time_zone = "+00:00";

-- Enable UUID extension (PostgreSQL specific)
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- TABLE: User
-- Purpose: Stores user account information for guests, hosts, and admins
-- =====================================================

CREATE TABLE User (
    user_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    role ENUM('guest', 'host', 'admin') NOT NULL DEFAULT 'guest',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_user_email_format CHECK (email LIKE '%@%.%'),
    CONSTRAINT chk_user_name_length CHECK (CHAR_LENGTH(first_name) >= 2 AND CHAR_LENGTH(last_name) >= 2)
);

-- =====================================================
-- TABLE: Property
-- Purpose: Stores property listing information
-- =====================================================

CREATE TABLE Property (
    property_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    host_id CHAR(36) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    location VARCHAR(500) NOT NULL,
    pricepernight DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_property_price CHECK (pricepernight > 0),
    CONSTRAINT chk_property_name_length CHECK (CHAR_LENGTH(name) >= 3),
    CONSTRAINT chk_property_description_length CHECK (CHAR_LENGTH(description) >= 10),
    
    -- Foreign Key
    FOREIGN KEY (host_id) REFERENCES User(user_id) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- =====================================================
-- TABLE: Booking
-- Purpose: Manages property reservations
-- =====================================================

CREATE TABLE Booking (
    booking_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_booking_dates CHECK (end_date > start_date),
    CONSTRAINT chk_booking_total_price CHECK (total_price > 0),
    CONSTRAINT chk_booking_future_start CHECK (start_date >= CURDATE()),
    
    -- Foreign Keys
    FOREIGN KEY (property_id) REFERENCES Property(property_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (user_id) REFERENCES User(user_id) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- =====================================================
-- TABLE: Payment
-- Purpose: Tracks payment transactions for bookings
-- =====================================================

CREATE TABLE Payment (
    payment_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    booking_id CHAR(36) NOT NULL UNIQUE,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('credit_card', 'paypal', 'stripe') NOT NULL,
    
    -- Constraints
    CONSTRAINT chk_payment_amount CHECK (amount > 0),
    
    -- Foreign Key
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- =====================================================
-- TABLE: Review
-- Purpose: Stores guest reviews and ratings for properties
-- =====================================================

CREATE TABLE Review (
    review_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    rating INTEGER NOT NULL,
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_review_rating CHECK (rating >= 1 AND rating <= 5),
    CONSTRAINT chk_review_comment_length CHECK (CHAR_LENGTH(comment) >= 10),
    
    -- Prevent duplicate reviews from same user for same property
    UNIQUE KEY unique_user_property_review (user_id, property_id),
    
    -- Foreign Keys
    FOREIGN KEY (property_id) REFERENCES Property(property_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (user_id) REFERENCES User(user_id) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- =====================================================
-- TABLE: Message
-- Purpose: Enables communication between users
-- =====================================================

CREATE TABLE Message (
    message_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    sender_id CHAR(36) NOT NULL,
    recipient_id CHAR(36) NOT NULL,
    message_body TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_message_body_length CHECK (CHAR_LENGTH(message_body) >= 1),
    CONSTRAINT chk_message_different_users CHECK (sender_id != recipient_id),
    
    -- Foreign Keys
    FOREIGN KEY (sender_id) REFERENCES User(user_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (recipient_id) REFERENCES User(user_id) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- =====================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- =====================================================

-- User table indexes
CREATE INDEX idx_user_email ON User(email);
CREATE INDEX idx_user_role ON User(role);
CREATE INDEX idx_user_created_at ON User(created_at);

-- Property table indexes
CREATE INDEX idx_property_host_id ON Property(host_id);
CREATE INDEX idx_property_location ON Property(location(100));
CREATE INDEX idx_property_price ON Property(pricepernight);
CREATE INDEX idx_property_created_at ON Property(created_at);

-- Booking table indexes
CREATE INDEX idx_booking_property_id ON Booking(property_id);
CREATE INDEX idx_booking_user_id ON Booking(user_id);
CREATE INDEX idx_booking_status ON Booking(status);
CREATE INDEX idx_booking_dates ON Booking(start_date, end_date);
CREATE INDEX idx_booking_created_at ON Booking(created_at);

-- Payment table indexes
CREATE INDEX idx_payment_booking_id ON Payment(booking_id);
CREATE INDEX idx_payment_method ON Payment(payment_method);
CREATE INDEX idx_payment_date ON Payment(payment_date);

-- Review table indexes
CREATE INDEX idx_review_property_id ON Review(property_id);
CREATE INDEX idx_review_user_id ON Review(user_id);
CREATE INDEX idx_review_rating ON Review(rating);
CREATE INDEX idx_review_created_at ON Review(created_at);

-- Message table indexes
CREATE INDEX idx_message_sender_id ON Message(sender_id);
CREATE INDEX idx_message_recipient_id ON Message(recipient_id);
CREATE INDEX idx_message_sent_at ON Message(sent_at);

-- Composite indexes for common query patterns
CREATE INDEX idx_booking_property_dates ON Booking(property_id, start_date, end_date);
CREATE INDEX idx_property_host_price ON Property(host_id, pricepernight);
CREATE INDEX idx_review_property_rating ON Review(property_id, rating);

-- =====================================================
-- ADDITIONAL CONSTRAINTS AND TRIGGERS (Optional)
-- =====================================================

-- Trigger to update Property.updated_at (MySQL example)
-- DELIMITER $$
-- CREATE TRIGGER tr_property_updated_at 
--     BEFORE UPDATE ON Property
--     FOR EACH ROW 
-- BEGIN
--     SET NEW.updated_at = CURRENT_TIMESTAMP;
-- END$$
-- DELIMITER ;

-- =====================================================
-- DATABASE SCHEMA VALIDATION
-- =====================================================

-- Verify all tables were created successfully
-- SELECT TABLE_NAME, TABLE_ROWS, CREATE_TIME 
-- FROM information_schema.TABLES 
-- WHERE TABLE_SCHEMA = DATABASE()
-- ORDER BY TABLE_NAME;

-- Check foreign key constraints
-- SELECT TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
-- FROM information_schema.KEY_COLUMN_USAGE 
-- WHERE REFERENCED_TABLE_SCHEMA = DATABASE()
-- ORDER BY TABLE_NAME;

-- COMMIT;
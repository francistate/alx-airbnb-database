-- =====================================================
-- AIRBNB CLONE - DATABASE INDEXING FOR OPTIMIZATION
-- =====================================================
-- This file contains CREATE INDEX commands for optimizing query performance
-- Based on analysis of high-usage columns in WHERE, JOIN, and ORDER BY clauses
-- =====================================================

-- =====================================================
-- USER TABLE INDEXES
-- =====================================================

-- Index for user authentication and lookups
CREATE INDEX IF NOT EXISTS idx_user_email ON User(email);

-- Index for filtering by user role
CREATE INDEX IF NOT EXISTS idx_user_role ON User(role);

-- Index for user creation date queries (analytics)
CREATE INDEX IF NOT EXISTS idx_user_created_at ON User(created_at);

-- Composite index for user role and creation date
CREATE INDEX IF NOT EXISTS idx_user_role_created ON User(role, created_at);

-- =====================================================
-- PROPERTY TABLE INDEXES
-- =====================================================

-- Index for host-property relationship (foreign key)
CREATE INDEX IF NOT EXISTS idx_property_host_id ON Property(host_id);

-- Index for location-based searches
CREATE INDEX IF NOT EXISTS idx_property_location ON Property(location);

-- Index for price filtering and sorting
CREATE INDEX IF NOT EXISTS idx_property_price ON Property(pricepernight);

-- Index for property creation date
CREATE INDEX IF NOT EXISTS idx_property_created_at ON Property(created_at);

-- Index for property updates
CREATE INDEX IF NOT EXISTS idx_property_updated_at ON Property(updated_at);

-- Composite index for location and price searches
CREATE INDEX IF NOT EXISTS idx_property_location_price ON Property(location, pricepernight);

-- Composite index for host properties with price
CREATE INDEX IF NOT EXISTS idx_property_host_price ON Property(host_id, pricepernight);

-- =====================================================
-- BOOKING TABLE INDEXES
-- =====================================================

-- Index for property-booking relationship (foreign key)
CREATE INDEX IF NOT EXISTS idx_booking_property_id ON Booking(property_id);

-- Index for user-booking relationship (foreign key)
CREATE INDEX IF NOT EXISTS idx_booking_user_id ON Booking(user_id);

-- Index for booking status filtering
CREATE INDEX IF NOT EXISTS idx_booking_status ON Booking(status);

-- Index for booking creation date
CREATE INDEX IF NOT EXISTS idx_booking_created_at ON Booking(created_at);

-- Index for start date filtering and sorting
CREATE INDEX IF NOT EXISTS idx_booking_start_date ON Booking(start_date);

-- Index for end date filtering
CREATE INDEX IF NOT EXISTS idx_booking_end_date ON Booking(end_date);

-- Composite index for date range searches
CREATE INDEX IF NOT EXISTS idx_booking_dates ON Booking(start_date, end_date);

-- Composite index for property availability queries
CREATE INDEX IF NOT EXISTS idx_booking_property_dates ON Booking(property_id, start_date, end_date);

-- Composite index for user booking history
CREATE INDEX IF NOT EXISTS idx_booking_user_status ON Booking(user_id, status);

-- Composite index for property booking analysis
CREATE INDEX IF NOT EXISTS idx_booking_property_status ON Booking(property_id, status, created_at);

-- =====================================================
-- PAYMENT TABLE INDEXES
-- =====================================================

-- Index for booking-payment relationship (foreign key)
CREATE INDEX IF NOT EXISTS idx_payment_booking_id ON Payment(booking_id);

-- Index for payment method analytics
CREATE INDEX IF NOT EXISTS idx_payment_method ON Payment(payment_method);

-- Index for payment date filtering and sorting
CREATE INDEX IF NOT EXISTS idx_payment_date ON Payment(payment_date);

-- Composite index for payment analysis
CREATE INDEX IF NOT EXISTS idx_payment_method_date ON Payment(payment_method, payment_date);

-- =====================================================
-- REVIEW TABLE INDEXES
-- =====================================================

-- Index for property-review relationship (foreign key)
CREATE INDEX IF NOT EXISTS idx_review_property_id ON Review(property_id);

-- Index for user-review relationship (foreign key)
CREATE INDEX IF NOT EXISTS idx_review_user_id ON Review(user_id);

-- Index for rating filtering and sorting
CREATE INDEX IF NOT EXISTS idx_review_rating ON Review(rating);

-- Index for review creation date
CREATE INDEX IF NOT EXISTS idx_review_created_at ON Review(created_at);

-- Composite index for property rating analysis
CREATE INDEX IF NOT EXISTS idx_review_property_rating ON Review(property_id, rating);

-- Composite index for user review history
CREATE INDEX IF NOT EXISTS idx_review_user_rating ON Review(user_id, rating, created_at);

-- =====================================================
-- MESSAGE TABLE INDEXES
-- =====================================================

-- Index for sender queries
CREATE INDEX IF NOT EXISTS idx_message_sender_id ON Message(sender_id);

-- Index for recipient queries
CREATE INDEX IF NOT EXISTS idx_message_recipient_id ON Message(recipient_id);

-- Index for message timing
CREATE INDEX IF NOT EXISTS idx_message_sent_at ON Message(sent_at);

-- Composite index for conversation queries
CREATE INDEX IF NOT EXISTS idx_message_conversation ON Message(sender_id, recipient_id, sent_at);

-- Composite index for user message history
CREATE INDEX IF NOT EXISTS idx_message_user_timeline ON Message(recipient_id, sent_at);

-- =====================================================
-- ADVANCED COMPOSITE INDEXES FOR COMMON QUERIES
-- =====================================================

-- Index for property search with filters (location, price range, availability)
CREATE INDEX IF NOT EXISTS idx_property_search ON Property(location, pricepernight, created_at);

-- Index for booking analytics (property performance over time)
CREATE INDEX IF NOT EXISTS idx_booking_analytics ON Booking(property_id, status, start_date, total_price);

-- Index for user activity analysis
CREATE INDEX IF NOT EXISTS idx_user_activity ON Booking(user_id, created_at, status);

-- Index for revenue analysis
CREATE INDEX IF NOT EXISTS idx_revenue_analysis ON Booking(property_id, status, total_price, start_date);

-- Index for review analytics
CREATE INDEX IF NOT EXISTS idx_review_analytics ON Review(property_id, rating, created_at);

-- =====================================================
-- PARTIAL INDEXES FOR SPECIFIC CONDITIONS
-- =====================================================

-- Index only for confirmed bookings (most common status)
CREATE INDEX IF NOT EXISTS idx_booking_confirmed ON Booking(property_id, start_date, end_date) 
WHERE status = 'confirmed';

-- Index only for active properties (with recent bookings)
CREATE INDEX IF NOT EXISTS idx_property_active ON Property(location, pricepernight) 
WHERE updated_at > CURRENT_DATE - INTERVAL '6 months';

-- Index for high-rated properties
CREATE INDEX IF NOT EXISTS idx_property_high_rated ON Review(property_id, created_at) 
WHERE rating >= 4;

-- Index for recent messages
CREATE INDEX IF NOT EXISTS idx_message_recent ON Message(sender_id, recipient_id) 
WHERE sent_at > CURRENT_DATE - INTERVAL '30 days';

-- =====================================================
-- FUNCTIONAL INDEXES
-- =====================================================

-- Index for case-insensitive email searches
CREATE INDEX IF NOT EXISTS idx_user_email_lower ON User(LOWER(email));

-- Index for extracting location city (assuming format "City, State, Country")
CREATE INDEX IF NOT EXISTS idx_property_city ON Property(SPLIT_PART(location, ',', 1));

-- Index for year-based date queries
CREATE INDEX IF NOT EXISTS idx_booking_year ON Booking(EXTRACT(YEAR FROM start_date));

-- Index for month-based analytics
CREATE INDEX IF NOT EXISTS idx_booking_month ON Booking(DATE_TRUNC('month', created_at));

-- =====================================================
-- TEXT SEARCH INDEXES
-- =====================================================

-- Full-text search index for property names and descriptions
CREATE INDEX IF NOT EXISTS idx_property_fulltext ON Property 
USING gin(to_tsvector('english', name || ' ' || description));

-- Full-text search index for review comments
CREATE INDEX IF NOT EXISTS idx_review_fulltext ON Review 
USING gin(to_tsvector('english', comment));

-- =====================================================
-- BTREE INDEXES FOR RANGE QUERIES
-- =====================================================

-- B-tree index for price range queries
CREATE INDEX IF NOT EXISTS idx_property_price_btree ON Property USING btree(pricepernight);

-- B-tree index for date range queries
CREATE INDEX IF NOT EXISTS idx_booking_date_range ON Booking USING btree(start_date, end_date);

-- =====================================================
-- HASH INDEXES FOR EQUALITY QUERIES
-- =====================================================

-- Hash index for exact status matches (PostgreSQL 10+)
CREATE INDEX IF NOT EXISTS idx_booking_status_hash ON Booking USING hash(status);

-- Hash index for payment method lookups
CREATE INDEX IF NOT EXISTS idx_payment_method_hash ON Payment USING hash(payment_method);

-- =====================================================
-- COVERING INDEXES (Include additional columns)
-- =====================================================

-- Covering index for user lookup with basic info
CREATE INDEX IF NOT EXISTS idx_user_lookup_covering ON User(email) 
INCLUDE (user_id, first_name, last_name, role);

-- Covering index for property search results
CREATE INDEX IF NOT EXISTS idx_property_search_covering ON Property(location, pricepernight) 
INCLUDE (property_id, name, description);

-- Covering index for booking summaries
CREATE INDEX IF NOT EXISTS idx_booking_summary_covering ON Booking(user_id, status) 
INCLUDE (booking_id, property_id, total_price, start_date, end_date);

-- =====================================================
<<<<<<< HEAD
-- PERFORMANCE TESTING QUERIES
-- =====================================================

-- Test Query 1: User Authentication (BEFORE creating idx_user_email)
-- Run this BEFORE creating the index
EXPLAIN ANALYZE 
SELECT user_id, first_name, last_name, role 
FROM User 
WHERE email = 'james.wilson@email.com';

-- Test Query 2: Property Location Search (BEFORE creating idx_property_location_price)
-- Run this BEFORE creating the index
EXPLAIN ANALYZE 
SELECT property_id, name, location, pricepernight 
FROM Property 
WHERE location LIKE 'Seattle%' 
ORDER BY pricepernight;

-- Test Query 3: User Bookings (BEFORE creating idx_booking_user_id)
-- Run this BEFORE creating the index
EXPLAIN ANALYZE 
SELECT b.booking_id, b.start_date, b.end_date, b.total_price, p.name 
FROM Booking b 
JOIN Property p ON b.property_id = p.property_id 
WHERE b.user_id = '550e8400-e29b-41d4-a716-446655440006' 
ORDER BY b.created_at DESC;

-- Test Query 4: Property Reviews Analysis (BEFORE creating idx_review_property_rating)
-- Run this BEFORE creating the index
EXPLAIN ANALYZE 
SELECT p.property_id, p.name, COUNT(r.review_id) as review_count, AVG(r.rating) as avg_rating
FROM Property p 
LEFT JOIN Review r ON p.property_id = r.property_id 
GROUP BY p.property_id, p.name 
HAVING AVG(r.rating) > 4.0 
ORDER BY avg_rating DESC;

-- =====================================================
-- AFTER INDEX CREATION - RE-RUN THE SAME QUERIES
-- =====================================================

-- Test Query 1: User Authentication (AFTER creating idx_user_email)
-- Run this AFTER creating the index to compare performance
EXPLAIN ANALYZE 
SELECT user_id, first_name, last_name, role 
FROM User 
WHERE email = 'james.wilson@email.com';

-- Test Query 2: Property Location Search (AFTER creating idx_property_location_price)
-- Run this AFTER creating the index to compare performance
EXPLAIN ANALYZE 
SELECT property_id, name, location, pricepernight 
FROM Property 
WHERE location LIKE 'Seattle%' 
ORDER BY pricepernight;

-- Test Query 3: User Bookings (AFTER creating idx_booking_user_id and idx_booking_property_id)
-- Run this AFTER creating the indexes to compare performance
EXPLAIN ANALYZE 
SELECT b.booking_id, b.start_date, b.end_date, b.total_price, p.name 
FROM Booking b 
JOIN Property p ON b.property_id = p.property_id 
WHERE b.user_id = '550e8400-e29b-41d4-a716-446655440006' 
ORDER BY b.created_at DESC;

-- Test Query 4: Property Reviews Analysis (AFTER creating idx_review_property_rating)
-- Run this AFTER creating the indexes to compare performance
EXPLAIN ANALYZE 
SELECT p.property_id, p.name, COUNT(r.review_id) as review_count, AVG(r.rating) as avg_rating
FROM Property p 
LEFT JOIN Review r ON p.property_id = r.property_id 
GROUP BY p.property_id, p.name 
HAVING AVG(r.rating) > 4.0 
ORDER BY avg_rating DESC;

-- =====================================================
-- ADDITIONAL PERFORMANCE TESTING QUERIES
-- =====================================================

-- Test Query 5: Booking Date Range Search
EXPLAIN ANALYZE 
SELECT b.booking_id, b.property_id, b.start_date, b.end_date 
FROM Booking b 
WHERE b.start_date >= '2024-06-01' 
AND b.end_date <= '2024-08-31' 
AND b.status = 'confirmed';

-- Test Query 6: Property Availability Check
EXPLAIN ANALYZE 
SELECT p.property_id, p.name 
FROM Property p 
WHERE p.property_id NOT IN (
    SELECT b.property_id 
    FROM Booking b 
    WHERE b.start_date <= '2024-07-15' 
    AND b.end_date >= '2024-07-10' 
    AND b.status IN ('confirmed', 'pending')
);

-- Test Query 7: Full-text Search (if you have text data)
EXPLAIN ANALYZE 
SELECT property_id, name, description 
FROM Property 
WHERE to_tsvector('english', name || ' ' || description) @@ to_tsquery('english', 'downtown & loft');

-- =====================================================
-- INDEX MAINTENANCE AND MONITORING
-- =====================================================

-- Analyze tables to update statistics (run after creating indexes)
=======
-- INDEX MAINTENANCE COMMANDS
-- =====================================================

-- Analyze tables to update statistics (should be run after creating indexes)
/*
>>>>>>> 40f9cf799471ed0b44621334795d9a3840b4f8ad
ANALYZE User;
ANALYZE Property;
ANALYZE Booking;
ANALYZE Payment;
ANALYZE Review;
ANALYZE Message;
<<<<<<< HEAD

-- Check index usage statistics
=======
*/

-- Check index usage statistics
/*
>>>>>>> 40f9cf799471ed0b44621334795d9a3840b4f8ad
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan as index_scans,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes 
<<<<<<< HEAD
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;

-- Find unused indexes
=======
ORDER BY idx_scan DESC;
*/

-- Find unused indexes
/*
>>>>>>> 40f9cf799471ed0b44621334795d9a3840b4f8ad
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan
FROM pg_stat_user_indexes 
<<<<<<< HEAD
WHERE idx_scan = 0 
AND schemaname = 'public'
ORDER BY tablename, indexname;

-- Check table sizes and index sizes
SELECT 
    tablename,
    pg_size_pretty(pg_total_relation_size(tablename::regclass)) AS total_size,
    pg_size_pretty(pg_relation_size(tablename::regclass)) AS table_size,
    pg_size_pretty(pg_total_relation_size(tablename::regclass) - pg_relation_size(tablename::regclass)) AS index_size
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(tablename::regclass) DESC;
=======
WHERE idx_scan = 0
ORDER BY tablename, indexname;
*/
>>>>>>> 40f9cf799471ed0b44621334795d9a3840b4f8ad

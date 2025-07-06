-- =====================================================
-- AIRBNB CLONE - COMPLEX QUERY OPTIMIZATION
-- =====================================================
-- This file contains an initial complex query that retrieves comprehensive
-- booking information along with optimized versions for performance comparison
-- =====================================================

-- =====================================================
-- INITIAL COMPLEX QUERY (UNOPTIMIZED)
-- Retrieves all bookings with user details, property details, and payment details
-- =====================================================

-- This query demonstrates common performance issues:
-- 1. Multiple unnecessary JOINs
-- 2. No filtering to reduce dataset size
-- 3. SELECT * instead of specific columns
-- 4. No proper indexing considerations
-- 5. Suboptimal JOIN order

SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at AS booking_created,
    
    -- User details
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.role,
    u.created_at AS user_created,
    
    -- Property details
    p.property_id,
    p.name AS property_name,
    p.description,
    p.location,
    p.pricepernight,
    p.created_at AS property_created,
    p.updated_at AS property_updated,
    
    -- Host details
    h.user_id AS host_id,
    h.first_name AS host_first_name,
    h.last_name AS host_last_name,
    h.email AS host_email,
    h.phone_number AS host_phone,
    h.created_at AS host_created,
    
    -- Payment details
    pay.payment_id,
    pay.amount AS payment_amount,
    pay.payment_date,
    pay.payment_method,
    
    -- Review details (if any)
    r.review_id,
    r.rating,
    r.comment,
    r.created_at AS review_created

FROM Booking b
    LEFT JOIN User u ON b.user_id = u.user_id
    LEFT JOIN Property p ON b.property_id = p.property_id
    LEFT JOIN User h ON p.host_id = h.user_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
    LEFT JOIN Review r ON p.property_id = r.property_id AND r.user_id = u.user_id
    LEFT JOIN Message m ON (m.sender_id = u.user_id OR m.recipient_id = u.user_id)

-- No WHERE clause limits - fetches all data
ORDER BY b.created_at DESC, p.name;

-- =====================================================
-- ANALYZE THE UNOPTIMIZED QUERY
-- =====================================================

-- Run this to see the performance characteristics of the unoptimized query
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) 
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at AS booking_created,
    
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.role,
    u.created_at AS user_created,
    
    p.property_id,
    p.name AS property_name,
    p.description,
    p.location,
    p.pricepernight,
    p.created_at AS property_created,
    p.updated_at AS property_updated,
    
    h.user_id AS host_id,
    h.first_name AS host_first_name,
    h.last_name AS host_last_name,
    h.email AS host_email,
    h.phone_number AS host_phone,
    h.created_at AS host_created,
    
    pay.payment_id,
    pay.amount AS payment_amount,
    pay.payment_date,
    pay.payment_method,
    
    r.review_id,
    r.rating,
    r.comment,
    r.created_at AS review_created

FROM Booking b
    LEFT JOIN User u ON b.user_id = u.user_id
    LEFT JOIN Property p ON b.property_id = p.property_id
    LEFT JOIN User h ON p.host_id = h.user_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
    LEFT JOIN Review r ON p.property_id = r.property_id AND r.user_id = u.user_id

ORDER BY b.created_at DESC, p.name;

-- =====================================================
-- OPTIMIZED QUERY VERSION 1: BASIC OPTIMIZATION
-- =====================================================

-- Optimizations applied:
-- 1. Added WHERE clause to limit dataset
-- 2. Removed unnecessary columns
-- 3. Removed unnecessary JOINs (Message table)
-- 4. Limited results with reasonable pagination

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    
    -- Essential user info only
    u.first_name,
    u.last_name,
    u.email,
    
    -- Essential property info only
    p.name AS property_name,
    p.location,
    p.pricepernight,
    
    -- Host name only
    h.first_name AS host_first_name,
    h.last_name AS host_last_name,
    
    -- Payment info
    pay.amount AS payment_amount,
    pay.payment_method

FROM Booking b
    INNER JOIN User u ON b.user_id = u.user_id
    INNER JOIN Property p ON b.property_id = p.property_id
    INNER JOIN User h ON p.host_id = h.user_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id

WHERE 
    b.status = 'confirmed'
    AND b.start_date >= CURRENT_DATE - INTERVAL '1 year'
    AND b.start_date <= CURRENT_DATE + INTERVAL '6 months'

ORDER BY b.created_at DESC
LIMIT 100;

-- =====================================================
-- OPTIMIZED QUERY VERSION 2: ADVANCED OPTIMIZATION
-- =====================================================

-- Additional optimizations:
-- 1. Use indexes more effectively with proper JOIN order
-- 2. Use INNER JOINs where possible to reduce result set
-- 3. Aggregate data where appropriate
-- 4. Use covering indexes considerations

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
WITH recent_bookings AS (
    -- Filter bookings first to reduce JOIN dataset
    SELECT 
        booking_id,
        property_id,
        user_id,
        start_date,
        end_date,
        total_price,
        status,
        created_at
    FROM Booking 
    WHERE 
        status IN ('confirmed', 'pending')
        AND created_at >= CURRENT_DATE - INTERVAL '6 months'
),
booking_details AS (
    -- Join with essential tables only
    SELECT 
        rb.booking_id,
        rb.start_date,
        rb.end_date,
        rb.total_price,
        rb.status,
        rb.created_at,
        
        u.first_name,
        u.last_name,
        u.email,
        
        p.name AS property_name,
        p.location,
        p.pricepernight,
        
        h.first_name AS host_first_name,
        h.last_name AS host_last_name
        
    FROM recent_bookings rb
        INNER JOIN Property p ON rb.property_id = p.property_id
        INNER JOIN User u ON rb.user_id = u.user_id
        INNER JOIN User h ON p.host_id = h.user_id
)
SELECT 
    bd.*,
    pay.amount AS payment_amount,
    pay.payment_method,
    pay.payment_date
FROM booking_details bd
    LEFT JOIN Payment pay ON bd.booking_id = pay.booking_id
ORDER BY bd.created_at DESC
LIMIT 50;

-- =====================================================
-- OPTIMIZED QUERY VERSION 3: SPECIALIZED USE CASE
-- =====================================================

-- Optimization for specific use case: Recent confirmed bookings with payment info
-- Uses the most efficient indexes and minimal data transfer

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    
    u.first_name || ' ' || u.last_name AS guest_name,
    u.email AS guest_email,
    
    p.name AS property_name,
    p.location,
    
    h.first_name || ' ' || h.last_name AS host_name,
    
    pay.amount AS payment_amount,
    pay.payment_method

FROM Booking b
    INNER JOIN Payment pay ON b.booking_id = pay.booking_id  -- Only bookings with payments
    INNER JOIN User u ON b.user_id = u.user_id
    INNER JOIN Property p ON b.property_id = p.property_id
    INNER JOIN User h ON p.host_id = h.user_id

WHERE 
    b.status = 'confirmed'
    AND pay.payment_date >= CURRENT_DATE - INTERVAL '3 months'

ORDER BY pay.payment_date DESC
LIMIT 25;

-- =====================================================
-- QUERY OPTIMIZATION FOR ANALYTICS
-- =====================================================

-- Optimized query for reporting/analytics purposes
-- Focus on aggregated data rather than individual records

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT 
    DATE_TRUNC('month', b.created_at) AS booking_month,
    p.location,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_price) AS total_revenue,
    AVG(b.total_price) AS avg_booking_value,
    COUNT(DISTINCT b.user_id) AS unique_guests,
    COUNT(DISTINCT p.property_id) AS properties_booked,
    
    -- Payment method breakdown
    COUNT(CASE WHEN pay.payment_method = 'credit_card' THEN 1 END) AS credit_card_payments,
    COUNT(CASE WHEN pay.payment_method = 'paypal' THEN 1 END) AS paypal_payments,
    COUNT(CASE WHEN pay.payment_method = 'stripe' THEN 1 END) AS stripe_payments

FROM Booking b
    INNER JOIN Property p ON b.property_id = p.property_id
    INNER JOIN Payment pay ON b.booking_id = pay.booking_id

WHERE 
    b.status = 'confirmed'
    AND b.created_at >= CURRENT_DATE - INTERVAL '1 year'

GROUP BY 
    DATE_TRUNC('month', b.created_at),
    p.location

HAVING 
    COUNT(b.booking_id) >= 5  -- Only locations with significant activity

ORDER BY 
    booking_month DESC,
    total_revenue DESC

LIMIT 100;

-- =====================================================
-- PERFORMANCE COMPARISON QUERIES
-- =====================================================

-- Simple query to test basic index usage
EXPLAIN (ANALYZE, BUFFERS)
SELECT b.booking_id, b.total_price, u.first_name, u.last_name
FROM Booking b
INNER JOIN User u ON b.user_id = u.user_id
WHERE b.status = 'confirmed'
AND b.start_date >= '2024-01-01'
ORDER BY b.created_at DESC
LIMIT 10;

-- Query with multiple filters to test composite index usage
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    p.name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) as booking_count
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id 
    AND b.status = 'confirmed'
    AND b.start_date >= CURRENT_DATE - INTERVAL '6 months'
WHERE p.location LIKE 'Seattle%'
AND p.pricepernight BETWEEN 100 AND 300
GROUP BY p.property_id, p.name, p.location, p.pricepernight
ORDER BY booking_count DESC, p.pricepernight
LIMIT 20;

-- Subquery optimization test
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    recent_bookings.booking_count,
    recent_bookings.total_spent
FROM User u
INNER JOIN (
    SELECT 
        user_id,
        COUNT(*) as booking_count,
        SUM(total_price) as total_spent
    FROM Booking 
    WHERE status = 'confirmed'
    AND created_at >= CURRENT_DATE - INTERVAL '6 months'
    GROUP BY user_id
    HAVING COUNT(*) >= 2
) recent_bookings ON u.user_id = recent_bookings.user_id
ORDER BY recent_bookings.total_spent DESC
LIMIT 15;
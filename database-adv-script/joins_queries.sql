-- =====================================================
-- AIRBNB CLONE - COMPLEX QUERIES WITH JOINS
-- =====================================================
-- This file contains 3 types of JOIN queries:
-- 1. INNER JOIN - bookings with users
-- 2. LEFT JOIN - properties with reviews (including properties with no reviews)
-- 3. FULL OUTER JOIN - users and bookings (all combinations)
-- =====================================================

-- =====================================================
-- 1. INNER JOIN Query
-- Retrieve all bookings and the respective users who made those bookings
-- =====================================================

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
    u.phone_number
FROM Booking b
INNER JOIN User u ON b.user_id = u.user_id
ORDER BY b.created_at DESC;

-- =====================================================
-- 2. LEFT JOIN Query
-- Retrieve all properties and their reviews, including properties that have no reviews
-- =====================================================

SELECT 
    p.property_id,
    p.name AS property_name,
    p.description,
    p.location,
    p.pricepernight,
    p.created_at AS property_created,
    r.review_id,
    r.rating,
    r.comment,
    r.created_at AS review_created,
    u.first_name AS reviewer_first_name,
    u.last_name AS reviewer_last_name
FROM Property p
LEFT JOIN Review r ON p.property_id = r.property_id
LEFT JOIN User u ON r.user_id = u.user_id
ORDER BY p.name, r.created_at DESC;

-- =====================================================
-- 3. FULL OUTER JOIN Query
-- Retrieve all users and all bookings, even if the user has no booking 
-- or a booking is not linked to a user
-- =====================================================


SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at AS booking_created
FROM User u
FULL OUTER JOIN Booking b ON u.user_id = b.user_id
ORDER BY u.user_id, b.created_at DESC;


-- =====================================================
-- Additional Complex Join Examples
-- =====================================================

-- Example: Get booking details with user info, property info, and payment info
SELECT 
    b.booking_id,
    u.first_name || ' ' || u.last_name AS guest_name,
    p.name AS property_name,
    p.location,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    pay.amount AS payment_amount,
    pay.payment_method,
    pay.payment_date
FROM Booking b
INNER JOIN User u ON b.user_id = u.user_id
INNER JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.status = 'confirmed'
ORDER BY b.start_date DESC;

-- Example: Properties with host details and average ratings
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    host.first_name || ' ' || host.last_name AS host_name,
    host.email AS host_email,
    COUNT(r.review_id) AS total_reviews,
    ROUND(AVG(r.rating), 2) AS average_rating
FROM Property p
INNER JOIN User host ON p.host_id = host.user_id
LEFT JOIN Review r ON p.property_id = r.property_id
GROUP BY p.property_id, p.name, p.location, p.pricepernight, host.first_name, host.last_name, host.email
ORDER BY average_rating DESC NULLS LAST;
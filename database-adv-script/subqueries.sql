-- =====================================================
-- AIRBNB CLONE - SUBQUERIES (CORRELATED AND NON-CORRELATED)
-- =====================================================
-- This file contains both correlated and non-correlated subqueries:
-- 1. Non-correlated subquery - properties with average rating > 4.0
-- 2. Correlated subquery - users who have made more than 3 bookings
-- =====================================================

-- =====================================================
-- 1. NON-CORRELATED SUBQUERY
-- Find all properties where the average rating is greater than 4.0
-- =====================================================

SELECT 
    p.property_id,
    p.name AS property_name,
    p.description,
    p.location,
    p.pricepernight,
    p.created_at,
    h.first_name || ' ' || h.last_name AS host_name
FROM Property p
INNER JOIN User h ON p.host_id = h.user_id
WHERE p.property_id IN (
    SELECT r.property_id
    FROM Review r
    GROUP BY r.property_id
    HAVING AVG(r.rating) > 4.0
)
ORDER BY p.pricepernight DESC;

-- =====================================================
-- Alternative approach using JOIN (for comparison)
-- =====================================================

/*
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    ROUND(AVG(r.rating), 2) AS average_rating
FROM Property p
INNER JOIN Review r ON p.property_id = r.property_id
GROUP BY p.property_id, p.name, p.location, p.pricepernight
HAVING AVG(r.rating) > 4.0
ORDER BY average_rating DESC;
*/

-- =====================================================
-- 2. CORRELATED SUBQUERY
-- Find users who have made more than 3 bookings
-- =====================================================

SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.created_at,
    (SELECT COUNT(*) 
     FROM Booking b 
     WHERE b.user_id = u.user_id) AS total_bookings
FROM User u
WHERE (
    SELECT COUNT(*) 
    FROM Booking b 
    WHERE b.user_id = u.user_id
) > 3
ORDER BY total_bookings DESC, u.first_name;



-- =====================================================
-- Additional Subquery Examples
-- =====================================================

-- Example 1: Properties with above-average price per night
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    ROUND(p.pricepernight - (SELECT AVG(pricepernight) FROM Property), 2) AS price_difference
FROM Property p
WHERE p.pricepernight > (
    SELECT AVG(pricepernight) 
    FROM Property
)
ORDER BY p.pricepernight DESC;

-- Example 2: Users who have never made a booking (non-correlated)
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role
FROM User u
WHERE u.user_id NOT IN (
    SELECT DISTINCT b.user_id 
    FROM Booking b 
    WHERE b.user_id IS NOT NULL
)
ORDER BY u.created_at;

-- Example 3: Properties with the highest number of bookings (correlated)
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    (SELECT COUNT(*) 
     FROM Booking b 
     WHERE b.property_id = p.property_id) AS total_bookings
FROM Property p
WHERE (
    SELECT COUNT(*) 
    FROM Booking b 
    WHERE b.property_id = p.property_id
) = (
    SELECT MAX(booking_count) 
    FROM (
        SELECT COUNT(*) AS booking_count
        FROM Booking b2
        GROUP BY b2.property_id
    ) AS booking_counts
);

-- Example 4: Users who have made bookings in the last 6 months (correlated)
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email
FROM User u
WHERE EXISTS (
    SELECT 1 
    FROM Booking b 
    WHERE b.user_id = u.user_id 
    AND b.created_at >= CURRENT_DATE - INTERVAL '6 months'
)
ORDER BY u.last_name;

-- Example 5: Properties that have never been booked (non-correlated with NOT EXISTS)
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    p.created_at
FROM Property p
WHERE NOT EXISTS (
    SELECT 1 
    FROM Booking b 
    WHERE b.property_id = p.property_id
)
ORDER BY p.created_at DESC;

-- Example 6: Users with bookings above average total price (correlated)
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    (SELECT AVG(b.total_price) 
     FROM Booking b 
     WHERE b.user_id = u.user_id) AS avg_booking_price
FROM User u
WHERE (
    SELECT AVG(b.total_price) 
    FROM Booking b 
    WHERE b.user_id = u.user_id
) > (
    SELECT AVG(total_price) 
    FROM Booking
)
ORDER BY avg_booking_price DESC;

-- Example 7: Properties in locations with multiple properties (non-correlated)
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight
FROM Property p
WHERE p.location IN (
    SELECT location 
    FROM Property 
    GROUP BY location 
    HAVING COUNT(*) > 1
)
ORDER BY p.location, p.name;

-- Example 8: Most recent booking for each user (correlated)
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    (SELECT b.booking_id 
     FROM Booking b 
     WHERE b.user_id = u.user_id 
     ORDER BY b.created_at DESC 
     LIMIT 1) AS latest_booking_id,
    (SELECT b.created_at 
     FROM Booking b 
     WHERE b.user_id = u.user_id 
     ORDER BY b.created_at DESC 
     LIMIT 1) AS latest_booking_date
FROM User u
WHERE EXISTS (
    SELECT 1 
    FROM Booking b 
    WHERE b.user_id = u.user_id
)
ORDER BY latest_booking_date DESC;
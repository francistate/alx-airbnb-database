-- =====================================================
-- AIRBNB CLONE - AGGREGATIONS AND WINDOW FUNCTIONS
-- =====================================================
-- This file contains aggregation queries and window functions:
-- 1. Total number of bookings made by each user (COUNT + GROUP BY)
-- 2. Ranking properties by total number of bookings (Window Functions)
-- =====================================================

-- =====================================================
-- 1. AGGREGATION QUERY
-- Find the total number of bookings made by each user using COUNT and GROUP BY
-- =====================================================

SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    COUNT(b.booking_id) AS total_bookings,
    COALESCE(SUM(b.total_price), 0) AS total_spent,
    COALESCE(AVG(b.total_price), 0) AS average_booking_value,
    MIN(b.created_at) AS first_booking_date,
    MAX(b.created_at) AS latest_booking_date
FROM User u
LEFT JOIN Booking b ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name, u.email, u.role
ORDER BY total_bookings DESC, total_spent DESC;

-- =====================================================
-- Alternative: Only users who have made bookings
-- =====================================================

SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_price) AS total_spent,
    ROUND(AVG(b.total_price), 2) AS average_booking_value,
    COUNT(CASE WHEN b.status = 'confirmed' THEN 1 END) AS confirmed_bookings,
    COUNT(CASE WHEN b.status = 'pending' THEN 1 END) AS pending_bookings,
    COUNT(CASE WHEN b.status = 'canceled' THEN 1 END) AS canceled_bookings
FROM User u
INNER JOIN Booking b ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name, u.email
HAVING COUNT(b.booking_id) > 0
ORDER BY total_bookings DESC;



-- =====================================================
-- 2. WINDOW FUNCTIONS
-- Rank properties based on the total number of bookings they have received
-- =====================================================

SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    h.first_name || ' ' || h.last_name AS host_name,
    COUNT(b.booking_id) AS total_bookings,
    
    -- ROW_NUMBER: Assigns unique sequential numbers
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC) AS row_number,
    
    -- RANK: Same values get same rank, with gaps
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS rank_by_bookings,
    
    -- DENSE_RANK: Same values get same rank, no gaps
    DENSE_RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS dense_rank_by_bookings,
    
    -- Percentage of total bookings
    ROUND(
        COUNT(b.booking_id) * 100.0 / SUM(COUNT(b.booking_id)) OVER(), 
        2
    ) AS percentage_of_total_bookings
    
FROM Property p
INNER JOIN User h ON p.host_id = h.user_id
LEFT JOIN Booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name, p.location, p.pricepernight, h.first_name, h.last_name
ORDER BY total_bookings DESC, p.name;

-- =====================================================
-- Additional Window Function Examples
-- =====================================================

-- Example 1: Ranking properties by price within each location
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    ROW_NUMBER() OVER (PARTITION BY p.location ORDER BY p.pricepernight DESC) AS price_rank_in_location,
    RANK() OVER (PARTITION BY p.location ORDER BY p.pricepernight DESC) AS price_rank_with_ties,
    AVG(p.pricepernight) OVER (PARTITION BY p.location) AS avg_price_in_location,
    p.pricepernight - AVG(p.pricepernight) OVER (PARTITION BY p.location) AS price_difference_from_avg
FROM Property p
ORDER BY p.location, price_rank_in_location;

-- Example 2: Running totals and moving averages for bookings by date
SELECT 
    b.booking_id,
    b.property_id,
    b.total_price,
    b.created_at::DATE AS booking_date,
    
    -- Running total of booking values
    SUM(b.total_price) OVER (ORDER BY b.created_at) AS running_total,
    
    -- Moving average of last 3 bookings
    AVG(b.total_price) OVER (
        ORDER BY b.created_at 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3_bookings,
    
    -- Cumulative count of bookings
    ROW_NUMBER() OVER (ORDER BY b.created_at) AS booking_sequence,
    
    -- Lag and Lead functions
    LAG(b.total_price) OVER (ORDER BY b.created_at) AS previous_booking_price,
    LEAD(b.total_price) OVER (ORDER BY b.created_at) AS next_booking_price,
    
    -- First and Last values
    FIRST_VALUE(b.total_price) OVER (ORDER BY b.created_at) AS first_booking_price,
    LAST_VALUE(b.total_price) OVER (
        ORDER BY b.created_at 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_booking_price
    
FROM Booking b
WHERE b.status = 'confirmed'
ORDER BY b.created_at;

-- Example 3: User booking patterns with window functions
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    b.booking_id,
    b.start_date,
    b.total_price,
    
    -- Booking number for this user
    ROW_NUMBER() OVER (PARTITION BY u.user_id ORDER BY b.created_at) AS user_booking_number,
    
    -- Days between this and previous booking
    b.created_at - LAG(b.created_at) OVER (PARTITION BY u.user_id ORDER BY b.created_at) AS days_since_last_booking,
    
    -- Total spent by user up to this booking
    SUM(b.total_price) OVER (PARTITION BY u.user_id ORDER BY b.created_at) AS cumulative_spent,
    
    -- Average booking value for this user
    AVG(b.total_price) OVER (PARTITION BY u.user_id) AS user_avg_booking_value,
    
    -- Percentage of user's total bookings
    ROUND(
        ROW_NUMBER() OVER (PARTITION BY u.user_id ORDER BY b.created_at) * 100.0 / 
        COUNT(*) OVER (PARTITION BY u.user_id), 
        1
    ) AS booking_progress_percentage

FROM User u
INNER JOIN Booking b ON u.user_id = b.user_id
WHERE b.status IN ('confirmed', 'pending')
ORDER BY u.user_id, b.created_at;

-- Example 4: Property performance analytics
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    COUNT(b.booking_id) AS total_bookings,
    COALESCE(AVG(r.rating), 0) AS average_rating,
    COUNT(r.review_id) AS total_reviews,
    COALESCE(SUM(b.total_price), 0) AS total_revenue,
    
    -- Ranking across all properties
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank,
    RANK() OVER (ORDER BY COALESCE(AVG(r.rating), 0) DESC) AS rating_rank,
    RANK() OVER (ORDER BY COALESCE(SUM(b.total_price), 0) DESC) AS revenue_rank,
    
    -- Ranking within location
    RANK() OVER (PARTITION BY p.location ORDER BY COUNT(b.booking_id) DESC) AS booking_rank_in_location,
    
    -- Percentiles
    PERCENT_RANK() OVER (ORDER BY COUNT(b.booking_id)) AS booking_percentile,
    PERCENT_RANK() OVER (ORDER BY COALESCE(AVG(r.rating), 0)) AS rating_percentile,
    
    -- NTILE for quartiles
    NTILE(4) OVER (ORDER BY COUNT(b.booking_id)) AS booking_quartile,
    NTILE(4) OVER (ORDER BY COALESCE(SUM(b.total_price), 0)) AS revenue_quartile

FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id AND b.status = 'confirmed'
LEFT JOIN Review r ON p.property_id = r.property_id
GROUP BY p.property_id, p.name, p.location
ORDER BY booking_rank;

-- Example 5: Monthly booking trends with window functions
SELECT 
    DATE_TRUNC('month', b.created_at) AS booking_month,
    COUNT(b.booking_id) AS monthly_bookings,
    SUM(b.total_price) AS monthly_revenue,
    
    -- Year-over-year comparison
    LAG(COUNT(b.booking_id), 12) OVER (ORDER BY DATE_TRUNC('month', b.created_at)) AS bookings_same_month_last_year,
    
    -- Month-over-month growth
    COUNT(b.booking_id) - LAG(COUNT(b.booking_id)) OVER (ORDER BY DATE_TRUNC('month', b.created_at)) AS mom_booking_change,
    
    -- Running 3-month average
    AVG(COUNT(b.booking_id)) OVER (
        ORDER BY DATE_TRUNC('month', b.created_at) 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS three_month_avg_bookings,
    
    -- Cumulative bookings for the year
    SUM(COUNT(b.booking_id)) OVER (
        PARTITION BY EXTRACT(YEAR FROM b.created_at) 
        ORDER BY DATE_TRUNC('month', b.created_at)
    ) AS ytd_bookings

FROM Booking b
WHERE b.status = 'confirmed'
GROUP BY DATE_TRUNC('month', b.created_at)
ORDER BY booking_month;
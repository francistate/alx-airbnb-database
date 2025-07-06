-- =====================================================
-- AIRBNB CLONE - TABLE PARTITIONING IMPLEMENTATION
-- =====================================================
-- This file implements partitioning on the Booking table based on start_date
-- to optimize queries on large datasets and improve performance for date range queries
-- =====================================================

-- =====================================================
-- STEP 1: BACKUP EXISTING BOOKING TABLE
-- =====================================================

-- Create backup of existing data before partitioning
CREATE TABLE booking_backup AS SELECT * FROM Booking;

-- Verify backup
SELECT COUNT(*) as backup_count FROM booking_backup;

-- =====================================================
-- STEP 2: CREATE PARTITIONED BOOKING TABLE
-- =====================================================

-- Drop existing table (after backup)
-- Note: In production, you would migrate data instead of dropping
DROP TABLE IF EXISTS Booking CASCADE;

-- Create new partitioned table
CREATE TABLE Booking (
    booking_id CHAR(36) PRIMARY KEY DEFAULT (gen_random_uuid()::text),
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_booking_dates CHECK (end_date > start_date),
    CONSTRAINT chk_booking_total_price CHECK (total_price > 0),
    CONSTRAINT chk_booking_status CHECK (status IN ('pending', 'confirmed', 'canceled'))
    
) PARTITION BY RANGE (start_date);

-- =====================================================
-- STEP 3: CREATE PARTITIONS BY DATE RANGE
-- =====================================================

-- Create partitions for different date ranges
-- Historical data (2023)
CREATE TABLE booking_2023 PARTITION OF Booking
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

-- 2024 partitions (quarterly)
CREATE TABLE booking_2024_q1 PARTITION OF Booking
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');

CREATE TABLE booking_2024_q2 PARTITION OF Booking
    FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');

CREATE TABLE booking_2024_q3 PARTITION OF Booking
    FOR VALUES FROM ('2024-07-01') TO ('2024-10-01');

CREATE TABLE booking_2024_q4 PARTITION OF Booking
    FOR VALUES FROM ('2024-10-01') TO ('2025-01-01');

-- 2025 partitions (monthly for current year)
CREATE TABLE booking_2025_01 PARTITION OF Booking
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE booking_2025_02 PARTITION OF Booking
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

CREATE TABLE booking_2025_03 PARTITION OF Booking
    FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');

CREATE TABLE booking_2025_04 PARTITION OF Booking
    FOR VALUES FROM ('2025-04-01') TO ('2025-05-01');

CREATE TABLE booking_2025_05 PARTITION OF Booking
    FOR VALUES FROM ('2025-05-01') TO ('2025-06-01');

CREATE TABLE booking_2025_06 PARTITION OF Booking
    FOR VALUES FROM ('2025-06-01') TO ('2025-07-01');

CREATE TABLE booking_2025_07 PARTITION OF Booking
    FOR VALUES FROM ('2025-07-01') TO ('2025-08-01');

CREATE TABLE booking_2025_08 PARTITION OF Booking
    FOR VALUES FROM ('2025-08-01') TO ('2025-09-01');

CREATE TABLE booking_2025_09 PARTITION OF Booking
    FOR VALUES FROM ('2025-09-01') TO ('2025-10-01');

CREATE TABLE booking_2025_10 PARTITION OF Booking
    FOR VALUES FROM ('2025-10-01') TO ('2025-11-01');

CREATE TABLE booking_2025_11 PARTITION OF Booking
    FOR VALUES FROM ('2025-11-01') TO ('2025-12-01');

CREATE TABLE booking_2025_12 PARTITION OF Booking
    FOR VALUES FROM ('2025-12-01') TO ('2026-01-01');

-- Future partition (catch-all for dates beyond 2025)
CREATE TABLE booking_future PARTITION OF Booking
    FOR VALUES FROM ('2026-01-01') TO ('2030-01-01');

-- =====================================================
-- STEP 4: CREATE INDEXES ON PARTITIONED TABLE
-- =====================================================

-- Create indexes on the main partitioned table
-- PostgreSQL will automatically create corresponding indexes on all partitions

-- Primary key index (automatically created)
-- CREATE UNIQUE INDEX booking_pkey ON Booking (booking_id);

-- Partition key index for range queries
CREATE INDEX idx_booking_start_date ON Booking (start_date);

-- Additional indexes for common queries
CREATE INDEX idx_booking_property_id ON Booking (property_id);
CREATE INDEX idx_booking_user_id ON Booking (user_id);
CREATE INDEX idx_booking_status ON Booking (status);
CREATE INDEX idx_booking_created_at ON Booking (created_at);

-- Composite indexes for common query patterns
CREATE INDEX idx_booking_property_dates ON Booking (property_id, start_date, end_date);
CREATE INDEX idx_booking_user_status ON Booking (user_id, status);
CREATE INDEX idx_booking_status_dates ON Booking (status, start_date, end_date);

-- Partial index for confirmed bookings (most common queries)
CREATE INDEX idx_booking_confirmed_dates ON Booking (start_date, end_date, property_id) 
WHERE status = 'confirmed';

-- =====================================================
-- STEP 5: RESTORE DATA TO PARTITIONED TABLE
-- =====================================================

-- Insert data back from backup into partitioned table
INSERT INTO Booking (
    booking_id, property_id, user_id, start_date, end_date, 
    total_price, status, created_at
)
SELECT 
    booking_id, property_id, user_id, start_date, end_date, 
    total_price, status, created_at
FROM booking_backup;

-- Verify data restoration
SELECT 
    COUNT(*) as total_records,
    MIN(start_date) as earliest_booking,
    MAX(start_date) as latest_booking
FROM Booking;

-- Check partition distribution
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE tablename LIKE 'booking_%'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- =====================================================
-- STEP 6: RECREATE FOREIGN KEY CONSTRAINTS
-- =====================================================

-- Add foreign key constraints (these were lost during table recreation)
ALTER TABLE Booking 
ADD CONSTRAINT fk_booking_property 
FOREIGN KEY (property_id) REFERENCES Property(property_id);

ALTER TABLE Booking 
ADD CONSTRAINT fk_booking_user 
FOREIGN KEY (user_id) REFERENCES User(user_id);

-- =====================================================
-- STEP 7: PERFORMANCE TESTING QUERIES
-- =====================================================

-- Enable timing for performance measurement
\timing on

-- Test 1: Date range query (should use partition pruning)
EXPLAIN (ANALYZE, BUFFERS) 
SELECT COUNT(*) 
FROM Booking 
WHERE start_date BETWEEN '2025-06-01' AND '2025-08-31';

-- Test 2: Single month query (should access only one partition)
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    booking_id, 
    property_id, 
    start_date, 
    end_date, 
    total_price
FROM Booking 
WHERE start_date >= '2025-07-01' 
AND start_date < '2025-08-01'
AND status = 'confirmed'
ORDER BY start_date;

-- Test 3: Property availability check for specific date range
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    p.property_id,
    p.name,
    COUNT(b.booking_id) as booking_count
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id 
    AND b.start_date <= '2025-07-15'
    AND b.end_date >= '2025-07-10'
    AND b.status IN ('confirmed', 'pending')
GROUP BY p.property_id, p.name
HAVING COUNT(b.booking_id) = 0
ORDER BY p.name
LIMIT 20;

-- Test 4: Monthly booking statistics (partition-aware aggregation)
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    DATE_TRUNC('month', start_date) as booking_month,
    status,
    COUNT(*) as booking_count,
    SUM(total_price) as total_revenue,
    AVG(total_price) as avg_booking_value
FROM Booking 
WHERE start_date >= '2025-01-01' 
AND start_date < '2026-01-01'
GROUP BY DATE_TRUNC('month', start_date), status
ORDER BY booking_month, status;

-- Test 5: Cross-partition query (multiple months)
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    user_id,
    COUNT(*) as booking_count,
    SUM(total_price) as total_spent
FROM Booking 
WHERE start_date BETWEEN '2025-03-01' AND '2025-09-30'
AND status = 'confirmed'
GROUP BY user_id
HAVING COUNT(*) >= 3
ORDER BY total_spent DESC
LIMIT 15;

-- =====================================================
-- STEP 8: PARTITION MAINTENANCE FUNCTIONS
-- =====================================================

-- Function to create new monthly partitions automatically
CREATE OR REPLACE FUNCTION create_booking_partition(partition_date DATE)
RETURNS TEXT AS $$
DECLARE
    partition_name TEXT;
    start_date DATE;
    end_date DATE;
BEGIN
    -- Generate partition name
    partition_name := 'booking_' || TO_CHAR(partition_date, 'YYYY_MM');
    
    -- Calculate date range
    start_date := DATE_TRUNC('month', partition_date);
    end_date := start_date + INTERVAL '1 month';
    
    -- Create partition
    EXECUTE format('CREATE TABLE %I PARTITION OF Booking FOR VALUES FROM (%L) TO (%L)',
                   partition_name, start_date, end_date);
    
    RETURN 'Created partition: ' || partition_name || ' for range ' || start_date || ' to ' || end_date;
END;
$$ LANGUAGE plpgsql;

-- Function to check and create future partitions
CREATE OR REPLACE FUNCTION ensure_future_partitions(months_ahead INTEGER DEFAULT 6)
RETURNS TEXT AS $$
DECLARE
    current_month DATE;
    partition_date DATE;
    result TEXT := '';
BEGIN
    current_month := DATE_TRUNC('month', CURRENT_DATE);
    
    FOR i IN 1..months_ahead LOOP
        partition_date := current_month + (i || ' months')::INTERVAL;
        
        -- Check if partition exists
        IF NOT EXISTS (
            SELECT 1 FROM pg_tables 
            WHERE tablename = 'booking_' || TO_CHAR(partition_date, 'YYYY_MM')
        ) THEN
            result := result || create_booking_partition(partition_date) || E'\n';
        END IF;
    END LOOP;
    
    RETURN COALESCE(NULLIF(result, ''), 'All required partitions already exist');
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- STEP 9: PARTITION MONITORING QUERIES
-- =====================================================

-- View partition information
SELECT 
    pt.relname as partition_name,
    pg_get_expr(pt.relpartbound, pt.oid, true) as partition_bound,
    pg_size_pretty(pg_total_relation_size(pt.oid)) as size,
    (SELECT COUNT(*) FROM pg_inherits WHERE inhrelid = pt.oid) as inheritance_count
FROM pg_class pt
JOIN pg_inherits pi ON pt.oid = pi.inhrelid
JOIN pg_class parent ON pi.inhparent = parent.oid
WHERE parent.relname = 'booking'
ORDER BY pt.relname;

-- Check partition pruning effectiveness
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT COUNT(*) 
FROM Booking 
WHERE start_date BETWEEN '2025-06-01' AND '2025-06-30';

-- Partition size analysis
WITH partition_stats AS (
    SELECT 
        schemaname,
        tablename,
        pg_total_relation_size(schemaname||'.'||tablename) as size_bytes,
        pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size_pretty
    FROM pg_tables 
    WHERE tablename LIKE 'booking_%'
    AND schemaname = 'public'
)
SELECT 
    tablename,
    size_pretty,
    ROUND(100.0 * size_bytes / SUM(size_bytes) OVER(), 2) as percentage
FROM partition_stats
ORDER BY size_bytes DESC;

-- =====================================================
-- STEP 10: CLEANUP AND VALIDATION
-- =====================================================

-- Validate partitioning is working correctly
DO $$
DECLARE
    total_in_partitions BIGINT;
    total_in_backup BIGINT;
BEGIN
    SELECT COUNT(*) INTO total_in_partitions FROM Booking;
    SELECT COUNT(*) INTO total_in_backup FROM booking_backup;
    
    IF total_in_partitions = total_in_backup THEN
        RAISE NOTICE 'SUCCESS: Partitioning completed successfully. Records: %', total_in_partitions;
    ELSE
        RAISE WARNING 'DATA MISMATCH: Partitions have % records, backup has %', 
                      total_in_partitions, total_in_backup;
    END IF;
END
$$;

-- Create future partitions for next 6 months
SELECT ensure_future_partitions(6);

-- Optional: Drop backup table after validation
-- DROP TABLE booking_backup;

-- Turn off timing
\timing off
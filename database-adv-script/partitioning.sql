-- ============================================================================
-- BOOKING TABLE PARTITIONING IMPLEMENTATION
-- ============================================================================
-- This script implements range partitioning on the Booking table based on start_date
-- Partitioning improves query performance for date-range queries on large datasets
--
-- IMPORTANT: This script will recreate the booking table with partitioning.
-- Backup your data before running this script in production!
-- ============================================================================

-- Step 1: Create a backup of existing booking data (if needed)
-- Uncomment and run before partitioning if you have existing data
/*
CREATE TABLE booking_backup AS SELECT * FROM booking;
*/

-- Step 2: Drop foreign key constraints that reference the booking table
-- These constraints will need to be recreated after partitioning
-- First, find the constraint name by running: SHOW CREATE TABLE payment;
-- Then uncomment and use the appropriate constraint name below:
-- Common constraint names:
-- ALTER TABLE payment DROP FOREIGN KEY payment_ibfk_1;
-- Or if you need to find it dynamically, the constraint will be automatically
-- dropped when we drop the booking table in the next step

-- Step 3: Drop the existing booking table
DROP TABLE IF EXISTS booking;

-- Step 4: Create the booking table with RANGE partitioning by start_date
-- Partitioning by year (2020-2024, and future dates)
CREATE TABLE booking (
    booking_id CHAR(36) NOT NULL,
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (booking_id, start_date),  -- Partition key must be part of PRIMARY KEY
    FOREIGN KEY (property_id) REFERENCES property(property_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    INDEX idx_property_id (property_id),
    INDEX idx_user_id (user_id),
    INDEX idx_dates (start_date, end_date),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),
    CONSTRAINT chk_dates CHECK (end_date > start_date)
) PARTITION BY RANGE (YEAR(start_date)) (
    PARTITION p2020 VALUES LESS THAN (2021),
    PARTITION p2021 VALUES LESS THAN (2022),
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- Step 5: Restore data from backup (if applicable)
-- Uncomment and run if you backed up data earlier
/*
INSERT INTO booking 
SELECT * FROM booking_backup;
DROP TABLE booking_backup;
*/

-- Step 6: Recreate foreign key constraint on payment table
-- Note: In partitioned tables, foreign keys work but with some limitations
-- The referenced table (booking) can be partitioned, but the referencing table (payment) cannot be partitioned
ALTER TABLE payment 
ADD CONSTRAINT payment_ibfk_booking 
FOREIGN KEY (booking_id) REFERENCES booking(booking_id) ON DELETE CASCADE;

-- ============================================================================
-- ALTERNATIVE: Monthly Partitioning (for very large datasets)
-- ============================================================================
-- If you have millions of bookings per year, consider monthly partitioning instead:
/*
CREATE TABLE booking (
    booking_id CHAR(36) NOT NULL,
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (booking_id, start_date),
    FOREIGN KEY (property_id) REFERENCES property(property_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    INDEX idx_property_id (property_id),
    INDEX idx_user_id (user_id),
    INDEX idx_dates (start_date, end_date),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),
    CONSTRAINT chk_dates CHECK (end_date > start_date)
) PARTITION BY RANGE (TO_DAYS(start_date)) (
    PARTITION p2024_01 VALUES LESS THAN (TO_DAYS('2024-02-01')),
    PARTITION p2024_02 VALUES LESS THAN (TO_DAYS('2024-03-01')),
    PARTITION p2024_03 VALUES LESS THAN (TO_DAYS('2024-04-01')),
    PARTITION p2024_04 VALUES LESS THAN (TO_DAYS('2024-05-01')),
    PARTITION p2024_05 VALUES LESS THAN (TO_DAYS('2024-06-01')),
    PARTITION p2024_06 VALUES LESS THAN (TO_DAYS('2024-07-01')),
    PARTITION p2024_07 VALUES LESS THAN (TO_DAYS('2024-08-01')),
    PARTITION p2024_08 VALUES LESS THAN (TO_DAYS('2024-09-01')),
    PARTITION p2024_09 VALUES LESS THAN (TO_DAYS('2024-10-01')),
    PARTITION p2024_10 VALUES LESS THAN (TO_DAYS('2024-11-01')),
    PARTITION p2024_11 VALUES LESS THAN (TO_DAYS('2024-12-01')),
    PARTITION p2024_12 VALUES LESS THAN (TO_DAYS('2025-01-01')),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);
*/

-- ============================================================================
-- PARTITION MANAGEMENT QUERIES
-- ============================================================================

-- View partition information
SELECT 
    TABLE_NAME,
    PARTITION_NAME,
    PARTITION_METHOD,
    PARTITION_EXPRESSION,
    PARTITION_DESCRIPTION,
    TABLE_ROWS,
    AVG_ROW_LENGTH,
    DATA_LENGTH
FROM INFORMATION_SCHEMA.PARTITIONS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'booking'
ORDER BY PARTITION_ORDINAL_POSITION;

-- Check which partitions are used in a query (after running EXPLAIN)
-- EXPLAIN PARTITIONS SELECT * FROM booking WHERE start_date BETWEEN '2023-01-01' AND '2023-12-31';

-- Add new partition for future years (example: for 2026)
-- ALTER TABLE booking ADD PARTITION (PARTITION p2026 VALUES LESS THAN (2027));

-- Merge partitions (example: merge old partitions)
-- ALTER TABLE booking REORGANIZE PARTITION p2020, p2021 INTO (
--     PARTITION p_historical VALUES LESS THAN (2022)
-- );

-- Drop old partition (example: remove data older than 2020)
-- ALTER TABLE booking DROP PARTITION p2020;

-- ============================================================================
-- PERFORMANCE TEST QUERIES
-- ============================================================================

-- Test Query 1: Date range query (should benefit from partition pruning)
-- This query should only scan the relevant partition(s)
SELECT 
    booking_id,
    start_date,
    end_date,
    total_price,
    status,
    user_id,
    property_id
FROM booking
WHERE start_date BETWEEN '2023-01-01' AND '2023-12-31'
ORDER BY start_date;

-- Test Query 2: Single year query
SELECT 
    COUNT(*) AS total_bookings,
    SUM(total_price) AS total_revenue,
    AVG(total_price) AS avg_booking_price
FROM booking
WHERE YEAR(start_date) = 2023
  AND status = 'confirmed';

-- Test Query 3: Multi-year query (will scan multiple partitions)
SELECT 
    YEAR(start_date) AS booking_year,
    COUNT(*) AS booking_count,
    SUM(total_price) AS yearly_revenue
FROM booking
WHERE start_date >= '2022-01-01'
  AND start_date < '2024-01-01'
GROUP BY YEAR(start_date)
ORDER BY booking_year;

-- Test Query 4: Recent bookings (current year)
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.status,
    u.first_name,
    u.last_name,
    p.name AS property_name
FROM booking b
INNER JOIN user u ON b.user_id = u.user_id
INNER JOIN property p ON b.property_id = p.property_id
WHERE b.start_date >= DATE_FORMAT(CURDATE(), '%Y-01-01')
  AND b.start_date <= CURDATE()
ORDER BY b.start_date DESC
LIMIT 100;

-- Test Query 5: Upcoming bookings (future dates)
SELECT 
    booking_id,
    start_date,
    end_date,
    total_price,
    status
FROM booking
WHERE start_date > CURDATE()
  AND status IN ('pending', 'confirmed')
ORDER BY start_date ASC
LIMIT 50;

-- ============================================================================
-- EXPLAIN PARTITIONS - Use to verify partition pruning
-- ============================================================================

-- Check which partitions are accessed for a specific query
EXPLAIN PARTITIONS
SELECT 
    booking_id,
    start_date,
    end_date,
    total_price
FROM booking
WHERE start_date BETWEEN '2023-06-01' AND '2023-12-31';

-- The 'partitions' column in the EXPLAIN output will show which partitions are scanned
-- Example output should show: partitions: p2023 (only one partition scanned)

-- ============================================================================
-- PERFORMANCE MEASUREMENT QUERIES
-- ============================================================================

-- Measure query execution time (before partitioning)
-- Run this query, record time, then compare after partitioning

-- Query performance test for date range
SET @start_time = NOW(6);
SELECT COUNT(*) FROM booking WHERE start_date BETWEEN '2023-01-01' AND '2023-12-31';
SET @end_time = NOW(6);
SELECT TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) AS execution_time_microseconds;

-- Compare full table scan vs partitioned scan
SET @start_time = NOW(6);
SELECT COUNT(*) FROM booking WHERE start_date >= '2024-01-01';
SET @end_time = NOW(6);
SELECT TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) AS execution_time_microseconds;


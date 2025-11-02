-- ============================================================================
-- PERFORMANCE MONITORING QUERIES
-- ============================================================================
-- This file contains SQL queries for monitoring database performance
-- Use these queries regularly to identify bottlenecks and optimization opportunities

-- ============================================================================
-- ENABLE PROFILING (MySQL 5.6.7+ alternative to EXPLAIN ANALYZE)
-- ============================================================================

-- Enable profiling for current session
SET profiling = 1;

-- Run your query here
-- Example:
-- SELECT * FROM booking ORDER BY created_at DESC LIMIT 100;

-- View profiling results
SHOW PROFILES;

-- View detailed profile for a specific query
-- SHOW PROFILE FOR QUERY 1;

-- View profile with timing information
-- SHOW PROFILE CPU, BLOCK IO FOR QUERY 1;

-- Disable profiling
SET profiling = 0;

-- ============================================================================
-- EXPLAIN ANALYZE QUERIES FOR FREQUENT QUERIES
-- ============================================================================

-- Query 1: Booking Details Query
EXPLAIN ANALYZE
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    h.first_name AS host_first_name,
    h.last_name AS host_last_name,
    h.email AS host_email,
    (
        SELECT COALESCE(SUM(amount), 0)
        FROM payment
        WHERE booking_id = b.booking_id
    ) AS total_paid
FROM booking b
INNER JOIN user u ON b.user_id = u.user_id
INNER JOIN property p ON b.property_id = p.property_id
INNER JOIN user h ON p.host_id = h.user_id
ORDER BY b.created_at DESC
LIMIT 100;

-- Query 2: Bookings Count per User
EXPLAIN ANALYZE
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    COUNT(b.booking_id) AS total_bookings
FROM user u
LEFT JOIN booking b ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name, u.email, u.role
ORDER BY total_bookings DESC, u.last_name, u.first_name
LIMIT 50;

-- Query 3: Users with More Than 3 Bookings (Optimized Version)
EXPLAIN ANALYZE
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    COUNT(b.booking_id) AS total_bookings
FROM user u
INNER JOIN booking b ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name, u.email, u.role
HAVING COUNT(b.booking_id) > 3
ORDER BY total_bookings DESC;

-- Query 4: Properties Ranked by Booking Count
EXPLAIN ANALYZE
SELECT 
    p.property_id,
    p.name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank
FROM property p
LEFT JOIN booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name, p.location, p.pricepernight
ORDER BY total_bookings DESC;

-- Query 5: Recent Bookings Paginated
EXPLAIN ANALYZE
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.first_name,
    u.last_name,
    p.name AS property_name
FROM booking b
INNER JOIN user u ON b.user_id = u.user_id
INNER JOIN property p ON b.property_id = p.property_id
ORDER BY b.created_at DESC
LIMIT 50 OFFSET 0;

-- ============================================================================
-- ADDITIONAL OPTIMIZATION INDEXES
-- ============================================================================
-- These indexes address specific bottlenecks identified in monitoring

-- Composite index for date range queries with status filter
CREATE INDEX IF NOT EXISTS idx_booking_dates_range ON booking(start_date, end_date, status);

-- Composite index for property location and price queries
CREATE INDEX IF NOT EXISTS idx_property_location_price ON property(location, pricepernight);

-- Composite index for user email and role queries
CREATE INDEX IF NOT EXISTS idx_user_email_role ON user(email, role);

-- Composite index for booking user_id and created_at (covers JOIN + ORDER BY)
CREATE INDEX IF NOT EXISTS idx_booking_user_created ON booking(user_id, created_at);

-- Composite index for booking status and created_at
CREATE INDEX IF NOT EXISTS idx_booking_status_created ON booking(status, created_at);

-- ============================================================================
-- MONITORING QUERIES
-- ============================================================================

-- 1. Check slow queries from slow query log
-- (Requires slow query log to be enabled)
SELECT 
    start_time,
    user_host,
    query_time,
    lock_time,
    rows_sent,
    rows_examined,
    sql_text
FROM mysql.slow_log
WHERE start_time > DATE_SUB(NOW(), INTERVAL 7 DAY)
ORDER BY query_time DESC
LIMIT 10;

-- 2. Check index usage statistics
SELECT 
    OBJECT_SCHEMA AS database_name,
    OBJECT_NAME AS table_name,
    INDEX_NAME,
    COUNT_FETCH AS times_used,
    COUNT_INSERT AS inserts,
    COUNT_UPDATE AS updates,
    COUNT_DELETE AS deletes
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE OBJECT_SCHEMA = DATABASE()
ORDER BY COUNT_FETCH DESC;

-- 3. Check table sizes and row counts
SELECT 
    TABLE_NAME,
    ROUND(((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024), 2) AS size_mb,
    ROUND((DATA_LENGTH / 1024 / 1024), 2) AS data_mb,
    ROUND((INDEX_LENGTH / 1024 / 1024), 2) AS index_mb,
    TABLE_ROWS AS estimated_rows
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_TYPE = 'BASE TABLE'
ORDER BY size_mb DESC;

-- 4. Check for unused indexes
SELECT 
    t.TABLE_SCHEMA,
    t.TABLE_NAME,
    s.INDEX_NAME,
    s.NON_UNIQUE,
    s.SEQ_IN_INDEX,
    s.COLUMN_NAME,
    s.CARDINALITY
FROM INFORMATION_SCHEMA.STATISTICS s
INNER JOIN INFORMATION_SCHEMA.TABLES t 
    ON s.TABLE_SCHEMA = t.TABLE_SCHEMA 
    AND s.TABLE_NAME = t.TABLE_NAME
LEFT JOIN performance_schema.table_io_waits_summary_by_index_usage p
    ON s.TABLE_SCHEMA = p.OBJECT_SCHEMA
    AND s.TABLE_NAME = p.OBJECT_NAME
    AND s.INDEX_NAME = p.INDEX_NAME
WHERE s.TABLE_SCHEMA = DATABASE()
  AND p.COUNT_FETCH IS NULL
  AND p.COUNT_INSERT IS NULL
  AND p.COUNT_UPDATE IS NULL
  AND s.INDEX_NAME != 'PRIMARY'
ORDER BY t.TABLE_NAME, s.INDEX_NAME;

-- 5. Check table statistics freshness
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    UPDATE_TIME,
    TIMESTAMPDIFF(HOUR, UPDATE_TIME, NOW()) AS hours_since_update
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_TYPE = 'BASE TABLE'
ORDER BY hours_since_update DESC;

-- 6. Analyze specific table statistics
ANALYZE TABLE user;
ANALYZE TABLE booking;
ANALYZE TABLE property;
ANALYZE TABLE payment;

-- 7. Check index cardinality
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS columns,
    AVG(CARDINALITY) AS avg_cardinality
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME IN ('user', 'booking', 'property')
GROUP BY TABLE_NAME, INDEX_NAME
ORDER BY TABLE_NAME, INDEX_NAME;

-- 8. Monitor query cache (if enabled)
SHOW VARIABLES LIKE 'query_cache%';
SHOW STATUS LIKE 'Qcache%';

-- 9. Check current connections and queries
SHOW PROCESSLIST;

-- 10. Monitor table locks
SHOW STATUS LIKE 'Table_locks%';

-- ============================================================================
-- PERFORMANCE TESTING QUERIES
-- ============================================================================

-- Test 1: Measure query execution time
SET @start_time = NOW(6);

-- Your query here
SELECT COUNT(*) FROM booking WHERE start_date BETWEEN '2023-01-01' AND '2023-12-31';

SET @end_time = NOW(6);
SELECT 
    TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) AS execution_time_microseconds,
    TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) / 1000 AS execution_time_milliseconds;

-- Test 2: Compare query performance with different indexes
-- Run EXPLAIN on queries to see which indexes are used

-- Test 3: Check partition pruning (if table is partitioned)
EXPLAIN PARTITIONS
SELECT * FROM booking 
WHERE start_date BETWEEN '2023-01-01' AND '2023-12-31';

-- ============================================================================
-- QUERY OPTIMIZATION HELPERS
-- ============================================================================

-- Show all indexes on a table
SHOW INDEX FROM booking;
SHOW INDEX FROM user;
SHOW INDEX FROM property;

-- Show table creation statement (useful for understanding structure)
SHOW CREATE TABLE booking;

-- Check index usage for a specific query (run EXPLAIN first)
EXPLAIN 
SELECT * FROM booking 
WHERE user_id = '550e8400-e29b-41d4-a716-446655440001' 
ORDER BY created_at DESC;

-- Force index usage (use with caution - usually not needed)
-- SELECT * FROM booking FORCE INDEX (idx_booking_created_at) ORDER BY created_at DESC;

-- ============================================================================
-- MAINTENANCE QUERIES
-- ============================================================================

-- Optimize tables (reclaim space, update statistics)
OPTIMIZE TABLE booking;
OPTIMIZE TABLE user;
OPTIMIZE TABLE property;

-- Check table fragmentation
SELECT 
    TABLE_NAME,
    DATA_FREE,
    ROUND((DATA_FREE / (DATA_LENGTH + INDEX_LENGTH + DATA_FREE) * 100), 2) AS fragmentation_percent
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = DATABASE()
  AND DATA_FREE > 0
ORDER BY fragmentation_percent DESC;


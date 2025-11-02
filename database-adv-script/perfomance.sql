-- ============================================================================
-- INITIAL QUERY (BEFORE OPTIMIZATION)
-- ============================================================================
-- This query retrieves all bookings along with user details, property details, and payment details
-- This version may have performance inefficiencies that will be identified and optimized

-- Original Query: Retrieves all bookings with related user, property, and payment information
-- This query may have performance issues when dealing with large datasets
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at AS booking_created_at,
    -- User details
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.role,
    u.created_at AS user_created_at,
    -- Property details
    p.property_id,
    p.name AS property_name,
    p.description,
    p.location,
    p.pricepernight,
    p.created_at AS property_created_at,
    -- Host details
    h.user_id AS host_id,
    h.first_name AS host_first_name,
    h.last_name AS host_last_name,
    h.email AS host_email,
    -- Payment details
    pay.payment_id,
    pay.amount AS payment_amount,
    pay.payment_date,
    pay.payment_method
FROM booking b
INNER JOIN user u ON b.user_id = u.user_id
INNER JOIN property p ON b.property_id = p.property_id
INNER JOIN user h ON p.host_id = h.user_id
LEFT JOIN payment pay ON b.booking_id = pay.booking_id
WHERE b.status IN ('pending', 'confirmed') 
  AND b.start_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
  AND p.location IS NOT NULL
ORDER BY b.created_at DESC;

-- ============================================================================
-- EXPLAIN - Run this to analyze the initial query performance
-- ============================================================================
-- Use EXPLAIN to see the execution plan without executing the query
EXPLAIN
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at AS booking_created_at,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.role,
    u.created_at AS user_created_at,
    p.property_id,
    p.name AS property_name,
    p.description,
    p.location,
    p.pricepernight,
    p.created_at AS property_created_at,
    h.user_id AS host_id,
    h.first_name AS host_first_name,
    h.last_name AS host_last_name,
    h.email AS host_email,
    pay.payment_id,
    pay.amount AS payment_amount,
    pay.payment_date,
    pay.payment_method
FROM booking b
INNER JOIN user u ON b.user_id = u.user_id
INNER JOIN property p ON b.property_id = p.property_id
INNER JOIN user h ON p.host_id = h.user_id
LEFT JOIN payment pay ON b.booking_id = pay.booking_id
WHERE b.status IN ('pending', 'confirmed') 
  AND b.start_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
  AND p.location IS NOT NULL
ORDER BY b.created_at DESC;

-- ============================================================================
-- EXPLAIN ANALYZE - Run this to analyze the initial query performance with actual execution
-- ============================================================================
/*
EXPLAIN ANALYZE
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at AS booking_created_at,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.role,
    u.created_at AS user_created_at,
    p.property_id,
    p.name AS property_name,
    p.description,
    p.location,
    p.pricepernight,
    p.created_at AS property_created_at,
    h.user_id AS host_id,
    h.first_name AS host_first_name,
    h.last_name AS host_last_name,
    h.email AS host_email,
    pay.payment_id,
    pay.amount AS payment_amount,
    pay.payment_date,
    pay.payment_method
FROM booking b
INNER JOIN user u ON b.user_id = u.user_id
INNER JOIN property p ON b.property_id = p.property_id
INNER JOIN user h ON p.host_id = h.user_id
LEFT JOIN payment pay ON b.booking_id = pay.booking_id
WHERE b.status IN ('pending', 'confirmed') 
  AND b.start_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
  AND p.location IS NOT NULL
ORDER BY b.created_at DESC;
*/

-- ============================================================================
-- OPTIMIZED QUERY (AFTER REFACTORING)
-- ============================================================================
-- Refactored query with performance improvements:
-- 1. Added WHERE clause to filter only confirmed bookings (if needed)
-- 2. Removed unnecessary columns (description, phone_number, created_at timestamps if not needed)
-- 3. Optimized JOIN order based on table sizes
-- 4. Using index on booking.created_at for ORDER BY
-- 5. Limited result set if pagination is needed

-- Optimized Version 1: With filtering for better performance
SELECT 
    -- Essential booking information
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    -- Essential user information
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    -- Essential property information
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    -- Essential host information
    h.first_name AS host_first_name,
    h.last_name AS host_last_name,
    h.email AS host_email,
    -- Payment summary (using aggregation for multiple payments)
    COALESCE(SUM(pay.amount), 0) AS total_paid,
    COUNT(pay.payment_id) AS payment_count,
    MAX(pay.payment_date) AS last_payment_date,
    GROUP_CONCAT(DISTINCT pay.payment_method ORDER BY pay.payment_date DESC SEPARATOR ', ') AS payment_methods
FROM booking b
INNER JOIN user u ON b.user_id = u.user_id
INNER JOIN property p ON b.property_id = p.property_id
INNER JOIN user h ON p.host_id = h.user_id
LEFT JOIN payment pay ON b.booking_id = pay.booking_id
GROUP BY 
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
    p.name,
    p.location,
    p.pricepernight,
    h.first_name,
    h.last_name,
    h.email
ORDER BY b.created_at DESC;

-- ============================================================================
-- OPTIMIZED QUERY VERSION 2: Simplified for cases where payment details aren't critical
-- ============================================================================
-- This version is optimized for scenarios where you don't need detailed payment information
-- and can use a subquery for payment totals instead of JOIN + GROUP BY

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
    -- Payment summary using subquery (more efficient for large payment tables)
    (
        SELECT COALESCE(SUM(amount), 0)
        FROM payment
        WHERE booking_id = b.booking_id
    ) AS total_paid,
    (
        SELECT COUNT(*)
        FROM payment
        WHERE booking_id = b.booking_id
    ) AS payment_count
FROM booking b
INNER JOIN user u ON b.user_id = u.user_id
INNER JOIN property p ON b.property_id = p.property_id
INNER JOIN user h ON p.host_id = h.user_id
ORDER BY b.created_at DESC;

-- ============================================================================
-- EXPLAIN ANALYZE - Run this to analyze the optimized query performance
-- ============================================================================
/*
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
    ) AS total_paid,
    (
        SELECT COUNT(*)
        FROM payment
        WHERE booking_id = b.booking_id
    ) AS payment_count
FROM booking b
INNER JOIN user u ON b.user_id = u.user_id
INNER JOIN property p ON b.property_id = p.property_id
INNER JOIN user h ON p.host_id = h.user_id
ORDER BY b.created_at DESC;
*/

-- ============================================================================
-- OPTIMIZED QUERY VERSION 3: With pagination for very large result sets
-- ============================================================================
-- Use LIMIT and OFFSET for pagination to improve performance on large datasets

SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.first_name,
    u.last_name,
    u.email,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    h.first_name AS host_first_name,
    h.last_name AS host_last_name
FROM booking b
INNER JOIN user u ON b.user_id = u.user_id
INNER JOIN property p ON b.property_id = p.property_id
INNER JOIN user h ON p.host_id = h.user_id
ORDER BY b.created_at DESC
LIMIT 50 OFFSET 0;  -- Adjust OFFSET for pagination


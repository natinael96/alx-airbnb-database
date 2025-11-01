-- SQL Joins Queries for Airbnb Database
-- This file contains examples of different types of SQL joins

-- 1. INNER JOIN: Retrieve all bookings and the respective users who made those bookings
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
    u.role
FROM booking b
INNER JOIN user u ON b.user_id = u.user_id
ORDER BY b.created_at DESC;

-- 2. LEFT JOIN: Retrieve all properties and their reviews, including properties that have no reviews
SELECT 
    p.property_id,
    p.name,
    p.location,
    p.pricepernight,
    r.review_id,
    r.rating,
    r.comment,
    r.created_at as review_date,
    u.first_name as reviewer_first_name,
    u.last_name as reviewer_last_name
FROM property p
LEFT JOIN review r ON p.property_id = r.property_id
LEFT JOIN user u ON r.user_id = u.user_id
ORDER BY p.name, r.created_at DESC;

-- 3. FULL OUTER JOIN: Retrieve all users and all bookings, even if the user has no booking or a booking is not linked to a user
-- Note: MySQL doesn't support FULL OUTER JOIN directly, so we use UNION of LEFT and RIGHT JOINs
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
    b.status
FROM user u
LEFT JOIN booking b ON u.user_id = b.user_id

UNION

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
    b.status
FROM booking b
RIGHT JOIN user u ON b.user_id = u.user_id
ORDER BY user_id, booking_id;

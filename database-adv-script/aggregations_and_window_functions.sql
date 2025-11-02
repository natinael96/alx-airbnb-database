-- SQL Aggregations and Window Functions for Airbnb Database
-- This file contains examples of aggregation functions and window functions

-- 1. Aggregation Query: Find the total number of bookings made by each user
-- Uses COUNT function with GROUP BY clause to aggregate bookings per user
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
ORDER BY total_bookings DESC, u.last_name, u.first_name;

-- Alternative: Using INNER JOIN to show only users who have made bookings
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
ORDER BY total_bookings DESC, u.last_name, u.first_name;

-- 2. Window Functions: Rank properties based on the total number of bookings they have received
-- Uses RANK() and ROW_NUMBER() window functions to assign ranks to properties

-- Using RANK() - assigns the same rank to properties with the same number of bookings,
-- leaving gaps in ranking (e.g., if two properties are tied for 1st, next is ranked 3rd)
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
ORDER BY booking_rank, p.name;

-- Using ROW_NUMBER() - assigns unique sequential numbers to each property,
-- even if they have the same number of bookings (deterministic based on ordering)
SELECT 
    p.property_id,
    p.name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC, p.name ASC) AS row_number
FROM property p
LEFT JOIN booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name, p.location, p.pricepernight
ORDER BY row_number;

-- Combined: Shows both RANK() and ROW_NUMBER() for comparison
SELECT 
    p.property_id,
    p.name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank,
    DENSE_RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS dense_rank,
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC, p.name ASC) AS row_number
FROM property p
LEFT JOIN booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name, p.location, p.pricepernight
ORDER BY total_bookings DESC, p.name;

-- Additional window function examples:

-- Using DENSE_RANK() - assigns same rank to ties but doesn't leave gaps
-- (e.g., if two properties are tied for 1st, next is ranked 2nd)
SELECT 
    p.property_id,
    p.name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    DENSE_RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS dense_rank
FROM property p
LEFT JOIN booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name, p.location, p.pricepernight
ORDER BY dense_rank, p.name;

-- Percentage of total bookings using window functions
SELECT 
    p.property_id,
    p.name,
    COUNT(b.booking_id) AS property_bookings,
    SUM(COUNT(b.booking_id)) OVER () AS total_all_bookings,
    ROUND(
        (COUNT(b.booking_id) * 100.0 / SUM(COUNT(b.booking_id)) OVER ()), 
        2
    ) AS percentage_of_total
FROM property p
LEFT JOIN booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name
HAVING COUNT(b.booking_id) > 0
ORDER BY property_bookings DESC;


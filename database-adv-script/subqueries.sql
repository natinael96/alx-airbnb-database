-- SQL Subqueries for Airbnb Database
-- This file contains examples of correlated and non-correlated subqueries

-- 1. Non-correlated Subquery: Find all properties where the average rating is greater than 4.0
-- This query uses a non-correlated subquery to first calculate property IDs with average rating > 4.0
-- Then uses that result to filter the properties table
SELECT 
    p.property_id,
    p.name,
    p.location,
    p.pricepernight,
    p.description,
    (
        SELECT AVG(r.rating)
        FROM review r
        WHERE r.property_id = p.property_id
    ) AS average_rating
FROM property p
WHERE p.property_id IN (
    SELECT r.property_id
    FROM review r
    GROUP BY r.property_id
    HAVING AVG(r.rating) > 4.0
)
ORDER BY average_rating DESC;

-- Alternative non-correlated subquery approach using a derived table
SELECT 
    p.property_id,
    p.name,
    p.location,
    p.pricepernight,
    p.description,
    avg_ratings.avg_rating AS average_rating
FROM property p
INNER JOIN (
    SELECT 
        property_id,
        AVG(rating) AS avg_rating
    FROM review
    GROUP BY property_id
    HAVING AVG(rating) > 4.0
) AS avg_ratings ON p.property_id = avg_ratings.property_id
ORDER BY avg_ratings.avg_rating DESC;

-- 2. Correlated Subquery: Find users who have made more than 3 bookings
-- This query uses a correlated subquery where the inner query references the outer query's user_id
-- The subquery is executed once for each row in the outer query, checking if that user has more than 3 bookings
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    (
        SELECT COUNT(*)
        FROM booking b
        WHERE b.user_id = u.user_id
    ) AS total_bookings
FROM user u
WHERE (
    SELECT COUNT(*)
    FROM booking b
    WHERE b.user_id = u.user_id
) > 3
ORDER BY total_bookings DESC;

-- Alternative correlated subquery approach with EXISTS
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.role,
    (
        SELECT COUNT(*)
        FROM booking b
        WHERE b.user_id = u.user_id
    ) AS total_bookings
FROM user u
WHERE EXISTS (
    SELECT 1
    FROM booking b
    WHERE b.user_id = u.user_id
    HAVING COUNT(*) > 3
);


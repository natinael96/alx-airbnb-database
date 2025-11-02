# Database Index Performance Analysis

## Overview

This document analyzes query performance before and after adding indexes to optimize frequently used columns in the User, Booking, and Property tables.

## Identified High-Usage Columns

### User Table
- **role**: Used in WHERE clauses for filtering users by role (guest, host, admin)
- **first_name, last_name**: Used in ORDER BY clauses for sorting user names
- **created_at**: Already indexed in schema

### Booking Table
- **created_at**: Used in ORDER BY clauses for sorting bookings chronologically
- **status**: Used in WHERE clauses for filtering by booking status (pending, confirmed, canceled)
- **user_id**: Already indexed (foreign key and composite index)
- **property_id**: Already indexed (foreign key and composite index)

### Property Table
- **name**: Used in ORDER BY clauses for alphabetical sorting
- **pricepernight**: Used in WHERE clauses for price filtering and ORDER BY for price sorting
- **host_id**: Already indexed (foreign key)
- **location**: Already indexed

## Created Indexes

See `database_index.sql` for the complete index creation script. The following indexes were added:

1. `idx_user_role` ON `user(role)`
2. `idx_user_name` ON `user(last_name, first_name)`
3. `idx_booking_created_at` ON `booking(created_at)`
4. `idx_booking_user_status` ON `booking(user_id, status)`
5. `idx_booking_property_status` ON `booking(property_id, status)`
6. `idx_property_name` ON `property(name)`
7. `idx_property_price` ON `property(pricepernight)`
8. `idx_property_host_location` ON `property(host_id, location)`

## Performance Testing Queries

### Test Query 1: Filter Users by Role

```sql
-- Query: Find all hosts
SELECT user_id, first_name, last_name, email, role
FROM user
WHERE role = 'host'
ORDER BY last_name, first_name;

-- Performance Measurement
EXPLAIN ANALYZE
SELECT user_id, first_name, last_name, email, role
FROM user
WHERE role = 'host'
ORDER BY last_name, first_name;
```

**Expected Improvement:**
- **Before**: Full table scan, then filesort for ORDER BY
- **After**: Index scan on `idx_user_role` for filtering, `idx_user_name` for sorting
- **Benefit**: Eliminates full table scan and filesort operations

### Test Query 2: Sort Bookings by Creation Date

```sql
-- Query: Get recent bookings
SELECT b.booking_id, b.start_date, b.end_date, b.status,
       u.first_name, u.last_name, u.email
FROM booking b
INNER JOIN user u ON b.user_id = u.user_id
ORDER BY b.created_at DESC
LIMIT 50;

-- Performance Measurement
EXPLAIN ANALYZE
SELECT b.booking_id, b.start_date, b.end_date, b.status,
       u.first_name, u.last_name, u.email
FROM booking b
INNER JOIN user u ON b.user_id = u.user_id
ORDER BY b.created_at DESC
LIMIT 50;
```

**Expected Improvement:**
- **Before**: May need filesort operation for ORDER BY
- **After**: Index scan on `idx_booking_created_at` for sorted access
- **Benefit**: Eliminates filesort, faster LIMIT operation

### Test Query 3: Filter Bookings by User and Status

```sql
-- Query: Find confirmed bookings for a specific user
SELECT b.booking_id, b.start_date, b.end_date, b.total_price,
       p.name, p.location
FROM booking b
INNER JOIN property p ON b.property_id = p.property_id
WHERE b.user_id = '550e8400-e29b-41d4-a716-446655440001'
  AND b.status = 'confirmed'
ORDER BY b.start_date DESC;

-- Performance Measurement
EXPLAIN ANALYZE
SELECT b.booking_id, b.start_date, b.end_date, b.total_price,
       p.name, p.location
FROM booking b
INNER JOIN property p ON b.property_id = p.property_id
WHERE b.user_id = '550e8400-e29b-41d4-a716-446655440001'
  AND b.status = 'confirmed'
ORDER BY b.start_date DESC;
```

**Expected Improvement:**
- **Before**: May use separate indexes on user_id and status, then merge
- **After**: Uses composite index `idx_booking_user_status` for efficient filtering
- **Benefit**: Single index lookup instead of multiple index scans

### Test Query 4: Sort Properties by Name

```sql
-- Query: List all properties alphabetically
SELECT p.property_id, p.name, p.location, p.pricepernight,
       u.first_name as host_first_name, u.last_name as host_last_name
FROM property p
LEFT JOIN user u ON p.host_id = u.user_id
ORDER BY p.name;

-- Performance Measurement
EXPLAIN ANALYZE
SELECT p.property_id, p.name, p.location, p.pricepernight,
       u.first_name as host_first_name, u.last_name as host_last_name
FROM property p
LEFT JOIN user u ON p.host_id = u.user_id
ORDER BY p.name;
```

**Expected Improvement:**
- **Before**: Filesort operation for ORDER BY
- **After**: Index scan on `idx_property_name` for sorted access
- **Benefit**: Eliminates filesort, faster execution

### Test Query 5: Filter Properties by Price Range

```sql
-- Query: Find affordable properties
SELECT property_id, name, location, pricepernight
FROM property
WHERE pricepernight BETWEEN 50 AND 150
ORDER BY pricepernight ASC;

-- Performance Measurement
EXPLAIN ANALYZE
SELECT property_id, name, location, pricepernight
FROM property
WHERE pricepernight BETWEEN 50 AND 150
ORDER BY pricepernight ASC;
```

**Expected Improvement:**
- **Before**: Full table scan, then filesort for ORDER BY
- **After**: Range scan on `idx_property_price` for both filtering and sorting
- **Benefit**: Eliminates full table scan and filesort

### Test Query 6: Aggregate Query with Sorting

```sql
-- Query: Count bookings per user, sorted
SELECT u.user_id, u.first_name, u.last_name,
       COUNT(b.booking_id) AS total_bookings
FROM user u
LEFT JOIN booking b ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY total_bookings DESC, u.last_name, u.first_name;

-- Performance Measurement
EXPLAIN ANALYZE
SELECT u.user_id, u.first_name, u.last_name,
       COUNT(b.booking_id) AS total_bookings
FROM user u
LEFT JOIN booking b ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY total_bookings DESC, u.last_name, u.first_name;
```

**Expected Improvement:**
- **Before**: May use filesort for final ORDER BY
- **After**: Index `idx_user_name` can help with sorting by name
- **Benefit**: More efficient sorting operations

## Performance Measurement Instructions

### Step 1: Measure Before Adding Indexes

1. Connect to your database
2. Run the following to get baseline performance:

```sql
-- Example: Measure Query 1 performance
EXPLAIN ANALYZE
SELECT user_id, first_name, last_name, email, role
FROM user
WHERE role = 'host'
ORDER BY last_name, first_name;
```

3. Record the execution plan:
   - Note the `type` column (should be `ALL` for full table scan)
   - Note the `Extra` column (may show "Using filesort")
   - Note the execution time from `EXPLAIN ANALYZE`

### Step 2: Create Indexes

```sql
SOURCE database-adv-script/database_index.sql;
```

Or manually run the CREATE INDEX statements from `database_index.sql`.

### Step 3: Measure After Adding Indexes

1. Run the same EXPLAIN ANALYZE queries again
2. Compare the execution plans:
   - Check if `type` changed from `ALL` to `ref` or `range`
   - Check if `Extra` no longer shows "Using filesort"
   - Compare execution times

### Step 4: Verify Index Usage

Check which indexes are being used:

```sql
SHOW INDEX FROM user;
SHOW INDEX FROM booking;
SHOW INDEX FROM property;
```

## Expected Performance Improvements

| Query Type | Before | After | Expected Improvement |
|------------|--------|-------|---------------------|
| Filter by role | Full table scan | Index scan | 50-90% faster |
| Sort by name | Filesort | Index scan | 60-80% faster |
| Sort bookings by date | Filesort | Index scan | 70-85% faster |
| Filter by user + status | Multiple index scans | Single composite index | 40-70% faster |
| Price range queries | Full table scan | Range scan | 80-95% faster |
| Complex aggregations | Multiple scans + sorts | Optimized index usage | 30-60% faster |

## Important Considerations

### Index Maintenance Overhead

- **INSERT operations**: Each index must be updated, slightly increasing write time
- **UPDATE operations**: Affected indexes must be updated
- **DELETE operations**: Index entries must be removed
- **Storage**: Indexes require additional disk space

### When to Use Indexes

✅ **Good candidates for indexing:**
- Columns frequently used in WHERE clauses
- Columns used in JOIN conditions
- Columns used in ORDER BY clauses
- Columns with high cardinality (many unique values)

❌ **Avoid indexing:**
- Columns rarely used in queries
- Columns with very low cardinality (e.g., boolean flags with mostly one value)
- Very frequently updated columns where write performance is critical
- Very large text columns (TEXT, BLOB)

### Monitoring Index Effectiveness

After creating indexes, monitor their usage:

```sql
-- Check index usage statistics (MySQL 5.7+)
SELECT 
    OBJECT_SCHEMA,
    OBJECT_NAME,
    INDEX_NAME,
    COUNT_FETCH,
    COUNT_INSERT,
    COUNT_UPDATE,
    COUNT_DELETE
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE OBJECT_SCHEMA = 'airbnb_db'
  AND OBJECT_NAME IN ('user', 'booking', 'property')
ORDER BY COUNT_FETCH DESC;
```

## Conclusion

The indexes created in `database_index.sql` target the most frequently accessed columns based on analysis of common query patterns. These indexes should significantly improve query performance for:

- User filtering and sorting operations
- Booking date-based queries and status filtering
- Property name and price-based queries

Regular monitoring of query performance and index usage is recommended to ensure indexes remain effective as the database grows and query patterns evolve.


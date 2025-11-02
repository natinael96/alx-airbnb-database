# SQL Advanced Queries

This directory contains SQL queries demonstrating different types of joins and subqueries for the Airbnb database.

## Files

- `joins_queries.sql` - SQL queries using INNER JOIN, LEFT JOIN, and FULL OUTER JOIN
- `subqueries.sql` - SQL queries using correlated and non-correlated subqueries
- `aggregations_and_window_functions.sql` - SQL queries using aggregation functions and window functions

## Join Query Types

### 1. INNER JOIN
Retrieves all bookings and the respective users who made those bookings. Only returns rows where there is a match in both tables.

### 2. LEFT JOIN
Retrieves all properties and their reviews, including properties that have no reviews. Returns all properties regardless of whether they have reviews.

### 3. FULL OUTER JOIN
Retrieves all users and all bookings, even if the user has no booking or a booking is not linked to a user. Since MySQL doesn't support FULL OUTER JOIN directly, this is implemented using a UNION of LEFT and RIGHT JOINs.

## Subquery Types

### 1. Non-correlated Subquery
Finds all properties where the average rating is greater than 4.0. The subquery executes independently and returns a list of property IDs that meet the criteria. The main query then uses this list to filter properties.

**Key Characteristics:**
- The subquery can be executed independently
- It doesn't reference columns from the outer query
- Results are computed once and reused

### 2. Correlated Subquery
Finds users who have made more than 3 bookings. The subquery references the outer query's `user_id` and is executed once for each row in the outer query.

**Key Characteristics:**
- The subquery references columns from the outer query
- It executes once for each row in the outer query
- Can use EXISTS or comparison operators

## Aggregation Functions

### COUNT with GROUP BY
Finds the total number of bookings made by each user. Uses the `COUNT()` function combined with `GROUP BY` clause to aggregate bookings per user.

**Key Characteristics:**
- `COUNT()` counts the number of rows for each group
- `GROUP BY` groups rows by user attributes
- `LEFT JOIN` ensures all users are included, even those with zero bookings
- Results are ordered by total bookings in descending order

## Window Functions

### RANK() and ROW_NUMBER()
Ranks properties based on the total number of bookings they have received. Window functions allow ranking without collapsing rows like GROUP BY does.

**Key Characteristics:**
- **RANK()**: Assigns the same rank to properties with equal booking counts, leaving gaps (e.g., 1, 1, 3, 4)
- **DENSE_RANK()**: Assigns the same rank to ties but doesn't leave gaps (e.g., 1, 1, 2, 3)
- **ROW_NUMBER()**: Assigns unique sequential numbers, even for ties (deterministic based on ordering)
- Window functions use `OVER()` clause to define the window frame
- Can combine aggregation (`COUNT`) with window functions to rank aggregated results

## Usage

To run these queries:

```sql
SOURCE joins_queries.sql;
SOURCE subqueries.sql;
SOURCE aggregations_and_window_functions.sql;
```

Or run individual queries as needed.

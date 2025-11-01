# SQL Joins Queries

This directory contains SQL queries demonstrating different types of joins for the Airbnb database.

## Files

- `joins_queries.sql` - SQL queries using INNER JOIN, LEFT JOIN, and FULL OUTER JOIN

## Query Types

### 1. INNER JOIN
Retrieves all bookings and the respective users who made those bookings. Only returns rows where there is a match in both tables.

### 2. LEFT JOIN
Retrieves all properties and their reviews, including properties that have no reviews. Returns all properties regardless of whether they have reviews.

### 3. FULL OUTER JOIN
Retrieves all users and all bookings, even if the user has no booking or a booking is not linked to a user. Since MySQL doesn't support FULL OUTER JOIN directly, this is implemented using a UNION of LEFT and RIGHT JOINs.

## Usage

To run these queries:

```sql
SOURCE joins_queries.sql;
```

Or run individual queries as needed.

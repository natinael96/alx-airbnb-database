# Airbnb Database Schema

This directory contains the SQL schema definition for the Airbnb database system.

## Files

- `schema.sql` - Complete database schema with CREATE TABLE statements, constraints, and indexes

## Database Overview

The Airbnb database consists of 6 main tables:

1. **user** - Stores user information (guests, hosts, admins)
2. **property** - Stores property listings and details
3. **booking** - Manages property reservations
4. **payment** - Tracks payment transactions
5. **review** - Stores property reviews and ratings
6. **message** - Handles user-to-user messaging

## Schema Features

### Data Types
- **UUIDs**: All primary keys use CHAR(36) for UUID storage
- **Timestamps**: Automatic timestamp management with DEFAULT CURRENT_TIMESTAMP
- **ENUMs**: Used for status fields and categorical data
- **DECIMAL**: Used for monetary values with appropriate precision

### Constraints
- **Primary Keys**: UUID-based primary keys for all tables
- **Foreign Keys**: Proper referential integrity with CASCADE deletes
- **Unique Constraints**: Email uniqueness in user table
- **Check Constraints**: Date validation and rating range validation
- **NOT NULL**: Required fields are properly constrained

### Indexes
- **Primary Key Indexes**: Automatically created
- **Foreign Key Indexes**: For efficient joins
- **Unique Indexes**: For email field
- **Composite Indexes**: For common query patterns
- **Date Indexes**: For time-based queries

## Usage

To create the database schema:

```sql
-- Option 1: Create database first
CREATE DATABASE airbnb_db;
USE airbnb_db;
SOURCE schema.sql;

-- Option 2: Run directly (uncomment database creation in schema.sql)
SOURCE schema.sql;
```

## Performance Considerations

The schema includes optimized indexes for:
- User lookups by email
- Property searches by location
- Booking queries by date ranges
- Review aggregations by property
- Message threading between users

## Data Integrity

- All foreign key relationships maintain referential integrity
- Cascade deletes ensure data consistency
- Check constraints validate data ranges
- Unique constraints prevent duplicate data

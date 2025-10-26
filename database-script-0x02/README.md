# Airbnb Database Seed Data

This directory contains SQL scripts to populate the Airbnb database with realistic sample data.

## Files

- `seed.sql` - Complete seed data with INSERT statements for all tables

## Sample Data Overview

The seed data includes realistic scenarios that demonstrate the full functionality of the Airbnb platform:

### Users (8 records)
- **3 Hosts**: John Smith, Mike Wilson, Lisa Anderson
- **4 Guests**: Sarah Johnson, Emily Davis, Tom Garcia, Anna Martinez  
- **1 Admin**: David Brown

### Properties (6 records)
- **New York, NY**: Cozy Downtown Apartment ($150/night), Luxury Penthouse Suite ($350/night)
- **Miami, FL**: Beach House Paradise ($280/night)
- **Denver, CO**: Mountain Cabin Retreat ($120/night)
- **San Francisco, CA**: Modern Loft Space ($200/night)
- **Boston, MA**: Historic Brownstone ($180/night)

### Bookings (8 records)
- **Confirmed**: 5 bookings with various date ranges
- **Pending**: 2 bookings awaiting confirmation
- **Canceled**: 1 booking that was canceled

### Payments (5 records)
- **Credit Card**: 2 payments
- **Stripe**: 2 payments  
- **PayPal**: 1 payment
- Only confirmed bookings have payments

### Reviews (5 records)
- **5-star reviews**: 3 properties
- **4-star reviews**: 2 properties
- Realistic comments about property features and experiences

### Messages (10 records)
- **Host-Guest conversations**: Booking inquiries and responses
- **Property-specific questions**: Pet policies, amenities, check-in processes
- **Realistic message flow**: Questions, answers, and booking confirmations

## Data Relationships

The seed data maintains proper referential integrity:

- All foreign keys reference valid primary keys
- Booking dates are realistic and don't conflict
- Payment amounts match booking totals
- Reviews are only for completed stays
- Messages are between actual users

## Usage

To populate the database with sample data:

```sql
-- Option 1: Run after schema creation
SOURCE database-script-0x01/schema.sql;
SOURCE database-script-0x02/seed.sql;

-- Option 2: Run seed data only (if schema already exists)
SOURCE seed.sql;
```

## Data Validation

The seed script includes:
- **Data cleanup**: Deletes existing data before insertion
- **Summary report**: Shows record counts after insertion
- **Realistic scenarios**: Demonstrates real-world usage patterns
- **Proper constraints**: All data respects database constraints

## Sample Queries

After running the seed data, you can test queries like:

```sql
-- Find all properties in New York
SELECT * FROM property WHERE location LIKE '%New York%';

-- Get all confirmed bookings with property details
SELECT b.*, p.name, p.location 
FROM booking b 
JOIN property p ON b.property_id = p.property_id 
WHERE b.status = 'confirmed';

-- Find average rating by property
SELECT p.name, AVG(r.rating) as avg_rating
FROM property p
LEFT JOIN review r ON p.property_id = r.property_id
GROUP BY p.property_id, p.name;
```

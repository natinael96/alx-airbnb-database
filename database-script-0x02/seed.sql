-- Airbnb Database Seed Data
-- This script populates the database with realistic sample data

-- Clear existing data (in reverse dependency order)
DELETE FROM message;
DELETE FROM review;
DELETE FROM payment;
DELETE FROM booking;
DELETE FROM property;
DELETE FROM user;

-- Insert Users
INSERT INTO user (user_id, first_name, last_name, email, password_hash, phone_number, role, created_at) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'John', 'Smith', 'john.smith@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/4.5.6.7.8.9.0', '+1-555-0101', 'host', '2023-01-15 10:30:00'),
('550e8400-e29b-41d4-a716-446655440002', 'Sarah', 'Johnson', 'sarah.johnson@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/4.5.6.7.8.9.1', '+1-555-0102', 'guest', '2023-01-20 14:15:00'),
('550e8400-e29b-41d4-a716-446655440003', 'Mike', 'Wilson', 'mike.wilson@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/4.5.6.7.8.9.2', '+1-555-0103', 'host', '2023-02-01 09:45:00'),
('550e8400-e29b-41d4-a716-446655440004', 'Emily', 'Davis', 'emily.davis@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/4.5.6.7.8.9.3', '+1-555-0104', 'guest', '2023-02-10 16:20:00'),
('550e8400-e29b-41d4-a716-446655440005', 'David', 'Brown', 'david.brown@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/4.5.6.7.8.9.4', '+1-555-0105', 'admin', '2023-01-01 08:00:00'),
('550e8400-e29b-41d4-a716-446655440006', 'Lisa', 'Anderson', 'lisa.anderson@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/4.5.6.7.8.9.5', '+1-555-0106', 'host', '2023-02-15 11:30:00'),
('550e8400-e29b-41d4-a716-446655440007', 'Tom', 'Garcia', 'tom.garcia@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/4.5.6.7.8.9.6', '+1-555-0107', 'guest', '2023-03-01 13:45:00'),
('550e8400-e29b-41d4-a716-446655440008', 'Anna', 'Martinez', 'anna.martinez@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/4.5.6.7.8.9.7', '+1-555-0108', 'guest', '2023-03-05 15:10:00');

-- Insert Properties
INSERT INTO property (property_id, host_id, name, description, location, pricepernight, created_at, updated_at) VALUES
('650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'Cozy Downtown Apartment', 'Beautiful 2-bedroom apartment in the heart of downtown with modern amenities and stunning city views.', 'New York, NY', 150.00, '2023-01-16 10:00:00', '2023-01-16 10:00:00'),
('650e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'Luxury Penthouse Suite', 'Spacious penthouse with panoramic city views, private terrace, and premium furnishings.', 'New York, NY', 350.00, '2023-01-20 14:30:00', '2023-01-20 14:30:00'),
('650e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440003', 'Beach House Paradise', 'Stunning beachfront property with direct beach access, private pool, and ocean views.', 'Miami, FL', 280.00, '2023-02-02 09:00:00', '2023-02-02 09:00:00'),
('650e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440003', 'Mountain Cabin Retreat', 'Rustic cabin in the mountains with fireplace, hiking trails, and peaceful surroundings.', 'Denver, CO', 120.00, '2023-02-05 16:45:00', '2023-02-05 16:45:00'),
('650e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440006', 'Modern Loft Space', 'Industrial-style loft with exposed brick, high ceilings, and contemporary design.', 'San Francisco, CA', 200.00, '2023-02-16 11:00:00', '2023-02-16 11:00:00'),
('650e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440006', 'Historic Brownstone', 'Charming historic brownstone with original details and modern updates.', 'Boston, MA', 180.00, '2023-02-20 13:15:00', '2023-02-20 13:15:00');

-- Insert Bookings
INSERT INTO booking (booking_id, property_id, user_id, start_date, end_date, total_price, status, created_at) VALUES
('750e8400-e29b-41d4-a716-446655440001', '650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', '2023-03-15', '2023-03-18', 450.00, 'confirmed', '2023-03-01 10:30:00'),
('750e8400-e29b-41d4-a716-446655440002', '650e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440004', '2023-03-20', '2023-03-25', 1750.00, 'confirmed', '2023-03-05 14:20:00'),
('750e8400-e29b-41d4-a716-446655440003', '650e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440007', '2023-04-01', '2023-04-05', 1120.00, 'pending', '2023-03-10 16:45:00'),
('750e8400-e29b-41d4-a716-446655440004', '650e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440008', '2023-04-10', '2023-04-12', 240.00, 'confirmed', '2023-03-12 09:15:00'),
('750e8400-e29b-41d4-a716-446655440005', '650e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440002', '2023-04-15', '2023-04-18', 600.00, 'confirmed', '2023-03-15 11:30:00'),
('750e8400-e29b-41d4-a716-446655440006', '650e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440004', '2023-04-20', '2023-04-22', 360.00, 'canceled', '2023-03-18 13:20:00'),
('750e8400-e29b-41d4-a716-446655440007', '650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440007', '2023-05-01', '2023-05-03', 300.00, 'pending', '2023-03-20 15:10:00'),
('750e8400-e29b-41d4-a716-446655440008', '650e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440008', '2023-05-10', '2023-05-15', 1400.00, 'confirmed', '2023-03-25 12:45:00');

-- Insert Payments
INSERT INTO payment (payment_id, booking_id, amount, payment_date, payment_method) VALUES
('850e8400-e29b-41d4-a716-446655440001', '750e8400-e29b-41d4-a716-446655440001', 450.00, '2023-03-01 10:35:00', 'credit_card'),
('850e8400-e29b-41d4-a716-446655440002', '750e8400-e29b-41d4-a716-446655440002', 1750.00, '2023-03-05 14:25:00', 'stripe'),
('850e8400-e29b-41d4-a716-446655440003', '750e8400-e29b-41d4-a716-446655440004', 240.00, '2023-03-12 09:20:00', 'paypal'),
('850e8400-e29b-41d4-a716-446655440004', '750e8400-e29b-41d4-a716-446655440005', 600.00, '2023-03-15 11:35:00', 'credit_card'),
('850e8400-e29b-41d4-a716-446655440005', '750e8400-e29b-41d4-a716-446655440008', 1400.00, '2023-03-25 12:50:00', 'stripe');

-- Insert Reviews
INSERT INTO review (review_id, property_id, user_id, rating, comment, created_at) VALUES
('950e8400-e29b-41d4-a716-446655440001', '650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 5, 'Amazing apartment with great views! The location was perfect and the host was very responsive.', '2023-03-20 14:30:00'),
('950e8400-e29b-41d4-a716-446655440002', '650e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440004', 4, 'Beautiful penthouse with stunning views. The terrace was perfect for evening drinks.', '2023-03-28 16:45:00'),
('950e8400-e29b-41d4-a716-446655440003', '650e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440008', 5, 'Perfect mountain retreat! The cabin was cozy and the surroundings were peaceful.', '2023-04-15 10:20:00'),
('950e8400-e29b-41d4-a716-446655440004', '650e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440002', 4, 'Great loft space with modern amenities. The location was convenient for exploring the city.', '2023-04-20 12:15:00'),
('950e8400-e29b-41d4-a716-446655440005', '650e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440008', 5, 'Incredible beach house! The ocean views were breathtaking and the pool was perfect.', '2023-05-18 09:30:00');

-- Insert Messages
INSERT INTO message (message_id, sender_id, recipient_id, message_body, sent_at) VALUES
('a50e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'Hi! I''m interested in your downtown apartment. Is it available for the weekend?', '2023-02-28 10:15:00'),
('a50e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 'Yes, it''s available! The apartment is fully furnished and ready for your stay.', '2023-02-28 10:30:00'),
('a50e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440001', 'I''d like to book your penthouse for next month. What''s the check-in process?', '2023-03-01 14:20:00'),
('a50e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440004', 'I''ll send you the check-in details via email. The penthouse has 24/7 concierge service.', '2023-03-01 14:35:00'),
('a50e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440003', 'Is the beach house pet-friendly? I''m traveling with my dog.', '2023-03-05 16:45:00'),
('a50e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440007', 'Yes, pets are welcome! There''s a fenced yard and the beach is dog-friendly.', '2023-03-05 17:00:00'),
('a50e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440003', 'I''m interested in your mountain cabin. What activities are nearby?', '2023-03-08 11:30:00'),
('a50e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440008', 'There are hiking trails, fishing spots, and a small town with restaurants 10 minutes away.', '2023-03-08 11:45:00'),
('a50e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440006', 'I''d like to book your loft for a business trip. Is there WiFi?', '2023-03-10 09:15:00'),
('a50e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440002', 'Yes, high-speed WiFi is included. The loft also has a dedicated workspace area.', '2023-03-10 09:30:00');

-- Display summary of inserted data
SELECT 'Data insertion completed successfully!' as status;

-- Show data counts
SELECT 
    'Users' as table_name, COUNT(*) as record_count FROM user
UNION ALL
SELECT 
    'Properties' as table_name, COUNT(*) as record_count FROM property
UNION ALL
SELECT 
    'Bookings' as table_name, COUNT(*) as record_count FROM booking
UNION ALL
SELECT 
    'Payments' as table_name, COUNT(*) as record_count FROM payment
UNION ALL
SELECT 
    'Reviews' as table_name, COUNT(*) as record_count FROM review
UNION ALL
SELECT 
    'Messages' as table_name, COUNT(*) as record_count FROM message;

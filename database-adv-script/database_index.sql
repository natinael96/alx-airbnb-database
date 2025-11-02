-- SQL Index Creation Script for Airbnb Database
-- This script creates additional indexes to improve query performance
-- Based on analysis of high-usage columns in WHERE, JOIN, and ORDER BY clauses

-- ============================================================================
-- USER TABLE INDEXES
-- ============================================================================

-- Index on role for filtering users by role (guest, host, admin)
-- Used in WHERE clauses to filter users by their role
CREATE INDEX idx_user_role ON user(role);

-- Composite index on first_name and last_name for sorting and searching
-- Used in ORDER BY clauses and potentially in WHERE clauses for name searches
CREATE INDEX idx_user_name ON user(last_name, first_name);

-- ============================================================================
-- BOOKING TABLE INDEXES
-- ============================================================================

-- Index on created_at for sorting bookings by creation date
-- Used in ORDER BY b.created_at DESC queries
CREATE INDEX idx_booking_created_at ON booking(created_at);

-- Composite index on user_id and status for filtering bookings by user and status
-- Optimizes queries that filter bookings by user and status together
CREATE INDEX idx_booking_user_status ON booking(user_id, status);

-- Composite index on property_id and status for filtering bookings by property and status
-- Optimizes queries that filter bookings by property and status together
CREATE INDEX idx_booking_property_status ON booking(property_id, status);

-- ============================================================================
-- PROPERTY TABLE INDEXES
-- ============================================================================

-- Index on name for sorting properties alphabetically
-- Used in ORDER BY p.name queries
CREATE INDEX idx_property_name ON property(name);

-- Index on pricepernight for price range queries and sorting
-- Used in WHERE clauses for price filtering and ORDER BY for price sorting
CREATE INDEX idx_property_price ON property(pricepernight);

-- Composite index on host_id and location for filtering properties by host and location
-- Optimizes queries that search for properties by host in a specific location
CREATE INDEX idx_property_host_location ON property(host_id, location);

-- ============================================================================
-- PERFORMANCE NOTES
-- ============================================================================
-- 
-- These indexes are designed to optimize:
-- 1. User queries filtering by role or sorting by name
-- 2. Booking queries sorting by creation date or filtering by status
-- 3. Property queries sorting by name or price, or filtering by price ranges
-- 4. Composite indexes optimize queries with multiple filter conditions
--
-- To measure performance improvement:
-- 1. Run EXPLAIN ANALYZE on queries before creating indexes
-- 2. Create these indexes
-- 3. Run EXPLAIN ANALYZE again on the same queries
-- 4. Compare execution plans and timing
--
-- Note: Indexes improve SELECT query performance but may slightly slow down
-- INSERT, UPDATE, and DELETE operations as indexes need to be maintained.


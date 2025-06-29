# Database Schema (DDL) - Airbnb Clone

## Overview
This directory contains the Data Definition Language (DDL) scripts for creating the complete database schema for the Airbnb Clone project. The schema implements a robust relational database structure supporting user management, property listings, bookings, payments, reviews, and messaging functionality.

---

## Files in this Directory

### `schema.sql`
The main SQL script containing:
- Complete table creation statements
- Primary key and foreign key constraints
- Check constraints for data validation
- Performance-optimized indexes
- Database compatibility considerations

---

## Database Schema Components

### Tables Created

| Table | Purpose | Key Relationships |
|-------|---------|------------------|
| **User** | Store user accounts (guests, hosts, admins) | Parent to Property, Booking, Review, Message |
| **Property** | Manage property listings | Child of User, Parent to Booking, Review |
| **Booking** | Handle reservations and bookings | Child of User & Property, Parent to Payment |
| **Payment** | Track payment transactions | Child of Booking (1:1 relationship) |
| **Review** | Store property reviews and ratings | Child of User & Property |
| **Message** | Enable user-to-user communication | Child of User (sender/recipient) |

### Key Features Implemented

#### 1. **Data Integrity Constraints**
```sql
-- Email format validation
CONSTRAINT chk_user_email_format CHECK (email LIKE '%@%.%')

-- Date validation for bookings
CONSTRAINT chk_booking_dates CHECK (end_date > start_date)

-- Rating constraints for reviews
CONSTRAINT chk_review_rating CHECK (rating >= 1 AND rating <= 5)

-- Price validation
CONSTRAINT chk_property_price CHECK (pricepernight > 0)
```

#### 2. **Optimized Indexing Strategy**
- **Primary Indexes**: UUID primary keys (automatically indexed)
- **Foreign Key Indexes**: All foreign key columns indexed for JOIN performance
- **Query-Specific Indexes**: Common search patterns optimized
- **Composite Indexes**: Multi-column indexes for complex queries

#### 3. **UUID Implementation**
- All primary keys use UUID (CHAR(36)) for better scalability
- Prevents ID enumeration attacks
- Supports distributed database architecture
- Cross-system compatibility

#### 4. **Referential Integrity**
- All foreign key relationships properly defined
- CASCADE rules for data consistency
- Prevents orphaned records

---

## Performance Optimizations

### Index Strategy

#### Single Column Indexes
```sql
-- Frequently queried columns
CREATE INDEX idx_user_email ON User(email);
CREATE INDEX idx_property_location ON Property(location(100));
CREATE INDEX idx_booking_status ON Booking(status);
```

#### Composite Indexes
```sql
-- Multi-condition queries
CREATE INDEX idx_booking_property_dates ON Booking(property_id, start_date, end_date);
CREATE INDEX idx_property_host_price ON Property(host_id, pricepernight);
```

### Query Performance Benefits
- **User Authentication**: Fast email lookups
- **Property Search**: Efficient location and price filtering
- **Booking Management**: Quick availability checking
- **Review Display**: Rapid property review aggregation

---

## Database Compatibility

### MySQL Implementation
- Uses `CHAR(36)` for UUID storage
- `DEFAULT (UUID())` for automatic UUID generation
- MySQL-specific ENUM syntax
- `ON UPDATE CURRENT_TIMESTAMP` for automatic timestamp updates

### PostgreSQL Adaptation Notes
```sql
-- For PostgreSQL, modify UUIDs to:
user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4()

-- And enable UUID extension:
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

---

## Installation Instructions

### Prerequisites
- MySQL 8.0+ or PostgreSQL 12+
- Database user with CREATE, ALTER, INDEX privileges
- Sufficient storage space (estimated 10GB+ for production)

### Deployment Steps

1. **Create Database**
```sql
CREATE DATABASE airbnb_clone_db;
USE airbnb_clone_db;
```

2. **Execute Schema**
```bash
mysql -u username -p airbnb_clone_db < schema.sql
```

3. **Verify Installation**
```sql
SHOW TABLES;
DESCRIBE User;
SHOW INDEX FROM Property;
```

### Validation Queries
```sql
-- Check all tables exist
SELECT COUNT(*) FROM information_schema.tables 
WHERE table_schema = 'airbnb_clone_db';

-- Verify foreign key constraints
SELECT table_name, constraint_name, constraint_type 
FROM information_schema.table_constraints 
WHERE table_schema = 'airbnb_clone_db' 
AND constraint_type = 'FOREIGN KEY';
```

---

## Security Considerations

### Implemented Security Features
- **Password Hashing**: password_hash field for encrypted storage
- **Email Validation**: Format checking at database level
- **UUID Keys**: Prevents ID enumeration attacks
- **Referential Integrity**: Prevents data inconsistency

### Additional Security Recommendations
- Use database connection pooling
- Implement row-level security for multi-tenant scenarios
- Regular backup and recovery procedures
- Database user privilege separation

---

## Maintenance and Monitoring

### Regular Maintenance Tasks
```sql
-- Index usage analysis
SHOW INDEX FROM table_name;

-- Table size monitoring
SELECT table_name, 
       ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.tables 
WHERE table_schema = 'airbnb_clone_db';

-- Query performance monitoring
SHOW PROCESSLIST;
```

### Performance Tuning
- Monitor slow query logs
- Analyze index usage statistics
- Consider partitioning for large tables (Booking, Message)
- Implement archiving strategy for historical data

---

## Future Enhancements

### Potential Schema Extensions
- **Property amenities** (many-to-many relationship)
- **User preferences** (JSON fields for flexible storage)
- **Geo-spatial indexing** for location-based searches
- **Audit trails** for tracking data changes
- **File attachments** for property photos

### Scalability Considerations
- **Horizontal partitioning** by date ranges (Booking table)
- **Read replicas** for query performance
- **Caching layer** integration points
- **Archive tables** for historical data

---

## Troubleshooting

### Common Issues

1. **UUID Generation Error**
```sql
-- Ensure UUID function is available
SELECT UUID(); -- Should return a valid UUID
```

2. **Foreign Key Constraint Failures**
```sql
-- Check constraint definitions
SHOW CREATE TABLE table_name;
```

3. **Index Creation Issues**
```sql
-- Verify index exists
SHOW INDEX FROM table_name WHERE Key_name = 'index_name';
```

### Support
For schema-related issues:
1. Check MySQL/PostgreSQL error logs
2. Verify user permissions
3. Confirm database version compatibility
4. Review constraint violations in application logs

---


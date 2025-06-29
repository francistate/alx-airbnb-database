# Database Seed Data - Airbnb Clone

## Overview
This directory contains SQL scripts to populate the Airbnb Clone database with realistic sample data for development, testing, and demonstration purposes. The data reflects real-world usage patterns and relationships between entities.

---

## Files in this Directory

### `seed.sql`
Main SQL script containing comprehensive sample data:
- **13 Users** with diverse roles (hosts, guests, admin)
- **10 Properties** across multiple cities and price ranges
- **10 Bookings** with various statuses and date ranges
- **7 Payments** linked to confirmed bookings
- **9 Reviews** with realistic ratings and comments
- **15 Messages** showing authentic user communications

---

## Sample Data Breakdown

### 👥 Users (13 records)
```
Hosts: 6 users (Sarah, Michael, Elena, David, Amara, Sophie)
Guests: 6 users (James, Lisa, Robert, Maria, Alex, Chris)
Admin: 1 user (System administrator)
```

**Key Features:**
- Realistic names and email addresses
- Proper password hashing format (bcrypt example)
- Phone numbers with consistent formatting
- Mix of roles reflecting real platform usage
- Creation dates spanning several months

### 🏠 Properties (10 records)
```
Seattle, WA: 2 properties (Downtown Loft, Waterfront Studio)
San Francisco, CA: 2 properties (Tech Hub Apartment, Chinatown Home)
Los Angeles, CA: 2 properties (Art District Penthouse, Beach Bungalow)
New York, NY: 2 properties (Historic Brownstone, Brooklyn Loft)
Nashville, TN: 1 property (Music City Retreat)
Aspen, CO: 1 property (Mountain View Cabin)
```

**Price Range:** $95 - $300 per night

**Property Types:**
- Urban apartments and lofts
- Beachfront properties
- Historic homes
- Mountain retreats
- Themed accommodations (music, art, tech)

### 📅 Bookings (10 records)
```
Confirmed: 7 bookings (completed and upcoming)
Pending: 2 bookings (awaiting confirmation)
Canceled: 1 booking (demonstrates cancellation workflow)
```

**Booking Patterns:**
- Weekend getaways (2-3 nights)
- Extended stays (5+ nights)
- Business travel bookings
- Future reservations for testing
- Realistic pricing calculations

### 💳 Payments (7 records)
**Payment Methods Distribution:**
- Credit Card: 3 payments
- PayPal: 2 payments  
- Stripe: 2 payments

**Financial Data:**
- Total transaction volume: $4,195
- Average booking value: ~$599
- Payment timing matches booking confirmation

### ⭐ Reviews (9 records)
**Rating Distribution:**
- 5 stars: 6 reviews (67%)
- 4 stars: 3 reviews (33%)
- Average rating: 4.7/5.0

**Review Characteristics:**
- Detailed, authentic feedback
- Mentions specific property features
- Balanced positive comments
- Host appreciation
- Constructive observations

### 💬 Messages (15 records)
**Message Types:**
- Pre-booking inquiries (3 messages)
- Check-in instructions (2 messages)
- Guest services requests (4 messages)
- Host-to-host networking (2 messages)
- Booking modifications (2 messages)
- Special requests (2 messages)

---

## Data Relationships and Integrity

### Foreign Key Relationships
✅ **All foreign keys properly linked**
- Properties → Users (host relationships)
- Bookings → Properties & Users (reservation links)
- Payments → Bookings (1:1 relationship maintained)
- Reviews → Properties & Users (feedback connections)
- Messages → Users (sender/recipient pairs)

### Business Logic Validation
✅ **Realistic constraints enforced**
- Booking dates: start_date < end_date
- Payment amounts match booking totals
- Reviews only from users who made bookings
- No self-messaging (sender ≠ recipient)
- Future booking dates for pending reservations

### Data Consistency
✅ **Cross-entity validation**
- Payment timing aligns with booking confirmation
- Review dates follow completed stays
- Message threads reflect booking timeline
- User roles support their activities (hosts have properties)

---

## Installation Instructions

### Prerequisites
- Database schema already created (from database-script-0x01)
- MySQL/PostgreSQL connection with INSERT privileges
- Sufficient storage space (~500KB for sample data)

### Execution Steps

1. **Ensure Schema Exists**
```bash
# Verify tables are created
mysql -u username -p -e "USE airbnb_clone_db; SHOW TABLES;"
```

2. **Execute Seed Script**
```bash
# Run the seed data script
mysql -u username -p airbnb_clone_db < seed.sql
```

3. **Verify Data Loading**
```sql
-- Check record counts
SELECT 'Users' as table_name, COUNT(*) as records FROM User
UNION ALL
SELECT 'Properties', COUNT(*) FROM Property
UNION ALL
SELECT 'Bookings', COUNT(*) FROM Booking
UNION ALL
SELECT 'Payments', COUNT(*) FROM Payment
UNION ALL
SELECT 'Reviews', COUNT(*) FROM Review
UNION ALL
SELECT 'Messages', COUNT(*) FROM Message;
```

### Expected Results
```
Users: 13 records
Properties: 10 records
Bookings: 10 records
Payments: 7 records
Reviews: 9 records
Messages: 15 records
```

---

## Sample Queries for Testing

### Business Analytics Queries

#### 1. Property Performance Analysis
```sql
SELECT p.name, p.location, p.pricepernight,
       COUNT(b.booking_id) as total_bookings,
       COALESCE(AVG(r.rating), 0) as avg_rating,
       SUM(pay.amount) as total_revenue
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Review r ON p.property_id = r.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
GROUP BY p.property_id
ORDER BY total_revenue DESC;
```

#### 2. Host Earnings Summary
```sql
SELECT u.first_name, u.last_name,
       COUNT(DISTINCT p.property_id) as properties,
       COUNT(DISTINCT b.booking_id) as bookings,
       SUM(pay.amount) as total_earnings
FROM User u
JOIN Property p ON u.user_id = p.host_id
LEFT JOIN Booking b ON p.property_id = b.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.status = 'confirmed'
GROUP BY u.user_id
ORDER BY total_earnings DESC;
```

#### 3. Guest Activity Report
```sql
SELECT u.first_name, u.last_name,
       COUNT(b.booking_id) as bookings_made,
       COUNT(r.review_id) as reviews_written,
       AVG(r.rating) as avg_rating_given
FROM User u
LEFT JOIN Booking b ON u.user_id = b.user_id
LEFT JOIN Review r ON u.user_id = r.user_id
WHERE u.role = 'guest'
GROUP BY u.user_id
ORDER BY bookings_made DESC;
```

#### 4. Booking Status Distribution
```sql
SELECT status,
       COUNT(*) as count,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Booking), 2) as percentage
FROM Booking
GROUP BY status
ORDER BY count DESC;
```

### Data Validation Queries

#### 1. Referential Integrity Check
```sql
-- Verify all bookings have valid property and user references
SELECT 'Valid Properties' as check_type,
       COUNT(*) as valid_count,
       (SELECT COUNT(*) FROM Booking) as total_bookings
FROM Booking b
JOIN Property p ON b.property_id = p.property_id
UNION ALL
SELECT 'Valid Users',
       COUNT(*) as valid_count,
       (SELECT COUNT(*) FROM Booking) as total_bookings
FROM Booking b
JOIN User u ON b.user_id = u.user_id;
```

#### 2. Payment Consistency Check
```sql
-- Verify payment amounts match booking totals
SELECT b.booking_id,
       b.total_price as booking_amount,
       p.amount as payment_amount,
       (b.total_price - p.amount) as difference
FROM Booking b
JOIN Payment p ON b.booking_id = p.booking_id
WHERE b.total_price != p.amount;
```

---

## Development and Testing Scenarios

### User Journey Testing
1. **Host Onboarding**: Use Sarah or Michael's accounts to test property management
2. **Guest Booking Flow**: Use James or Lisa's accounts for reservation testing
3. **Review System**: Test review creation using completed bookings
4. **Messaging**: Test communication between hosts and guests
5. **Payment Processing**: Verify payment flow with existing booking data

### Edge Case Testing
- **Cancellation Workflow**: Test with the canceled booking record
- **Multi-property Hosts**: Test with users who have multiple properties
- **Guest-Host Dual Roles**: Test with users who are both guests and hosts
- **Date Validation**: Test booking date constraints
- **Rating Boundaries**: Test review rating validation (1-5 range)

### Performance Testing
- **Search Queries**: Test property search across locations
- **Aggregation Queries**: Test complex reporting queries
- **Index Effectiveness**: Verify query performance with realistic data volume
- **Concurrent Access**: Test simultaneous user operations

---

## Data Maintenance

### Regular Cleanup Tasks
```sql
-- Remove old pending bookings (example: older than 30 days)
DELETE FROM Booking 
WHERE status = 'pending' 
AND created_at < DATE_SUB(NOW(), INTERVAL 30 DAY);

-- Archive old messages (example: older than 1 year)
CREATE TABLE Message_Archive AS 
SELECT * FROM Message 
WHERE sent_at < DATE_SUB(NOW(), INTERVAL 1 YEAR);
```

### Data Refresh Strategy
- **Full Refresh**: Re-run seed.sql after schema updates
- **Incremental Updates**: Add new sample data as needed
- **Test Data Isolation**: Use separate database for testing

---

## Security Considerations

### Sensitive Data Handling
- **Password Hashes**: Using bcrypt format examples (not real hashes)
- **Phone Numbers**: Fictional numbers with consistent formatting
- **Email Addresses**: Clearly fictional domains
- **Personal Information**: Representative but not real user data

### Production Deployment Notes
- **Never use seed data in production**
- **Replace with proper user registration flow**
- **Implement real payment processing**
- **Use environment-specific configuration**

---

## Troubleshooting

### Common Issues

1. **Foreign Key Constraint Errors**
```sql
-- Check if referenced records exist
SELECT 'Missing Properties' as issue,
       COUNT(*) as count
FROM Booking b
LEFT JOIN Property p ON b.property_id = p.property_id
WHERE p.property_id IS NULL;
```

2. **Duplicate Key Errors**
```bash
# Clear existing data before re-seeding
mysql -u username -p -e "
USE airbnb_clone_db;
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Message;
TRUNCATE TABLE Review;
TRUNCATE TABLE Payment;
TRUNCATE TABLE Booking;
TRUNCATE TABLE Property;
TRUNCATE TABLE User;
SET FOREIGN_KEY_CHECKS = 1;"
```

3. **Date Format Issues**
```sql
-- Verify date formatting
SELECT booking_id, start_date, end_date,
       DATEDIFF(end_date, start_date) as duration
FROM Booking
WHERE start_date >= end_date;
```

### Performance Monitoring
```sql
-- Monitor query performance
EXPLAIN SELECT * FROM Property p
JOIN Booking b ON p.property_id = b.property_id
WHERE p.location LIKE '%Seattle%'
AND b.status = 'confirmed';
```

---


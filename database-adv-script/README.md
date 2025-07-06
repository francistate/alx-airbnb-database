# Advanced Database Queries - Airbnb Clone

This repository contains advanced SQL scripts demonstrating complex querying techniques, indexing strategies, and performance optimization for the Airbnb Clone database project.

## 📁 Project Structure

```
database-adv-script/
├── README.md
├── joins_queries.sql
├── subqueries.sql
└── aggregations_and_window_functions.sql
```

## 🗄️ Database Schema Overview

The Airbnb Clone database consists of the following main entities:

- **User**: Guest, host, and admin user accounts
- **Property**: Rental property listings with host information
- **Booking**: Reservation records linking users to properties
- **Review**: Property ratings and comments from guests
- **Payment**: Transaction records for confirmed bookings
- **Message**: Communication between users

### Entity Relationships
- Users can be hosts (owning properties) and/or guests (making bookings)
- Properties belong to host users and can have multiple bookings and reviews
- Bookings link users to properties for specific date ranges
- Payments are associated with confirmed bookings (1:1 relationship)
- Reviews are written by users for properties they've stayed at
- Messages enable communication between any users

## 📝 Completed Tasks

### Task 0: Complex Queries with Joins
**File**: `joins_queries.sql`

Demonstrates mastery of SQL JOIN operations:

#### **INNER JOIN**
- Retrieves all bookings with user details
- Only shows records where bookings have valid users
- Includes booking details, dates, prices, and user information

#### **LEFT JOIN**
- Retrieves all properties and their reviews
- Shows properties even if they have no reviews (NULL values)
- Includes property details, review ratings, and reviewer information

#### **FULL OUTER JOIN**
- Retrieves all users and all bookings
- Shows users without bookings and bookings without valid users
- Demonstrates comprehensive data retrieval patterns

#### **Additional Examples**
- Complex multi-table joins combining bookings, users, properties, and payments
- Properties with host details and calculated average ratings
- PostgreSQL-optimized syntax and best practices

---

### Task 1: Practice Subqueries
**File**: `subqueries.sql`

Showcases both correlated and non-correlated subquery techniques:

#### **Non-Correlated Subquery**
```sql
-- Properties with average rating > 4.0
SELECT p.* FROM Property p
WHERE p.property_id IN (
    SELECT property_id FROM Review
    GROUP BY property_id
    HAVING AVG(rating) > 4.0
);
```

#### **Correlated Subquery**
```sql
-- Users with more than 3 bookings
SELECT u.* FROM User u
WHERE (
    SELECT COUNT(*) FROM Booking b 
    WHERE b.user_id = u.user_id
) > 3;
```

#### **Advanced Examples**
- Above-average priced properties
- Users who never made bookings (NOT IN, NOT EXISTS)
- Properties with most bookings (nested subqueries)
- Recent active users (EXISTS with date conditions)
- High-spending user analysis
- Location-based property grouping

---

### Task 2: Aggregations and Window Functions
**File**: `aggregations_and_window_functions.sql`

Demonstrates advanced analytical SQL capabilities:

#### **Aggregation Functions**
```sql
-- User booking statistics
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_price) AS total_spent,
    AVG(b.total_price) AS average_booking_value
FROM User u
LEFT JOIN Booking b ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name;
```

#### **Window Functions**
```sql
-- Property ranking by booking volume
SELECT 
    p.property_id,
    p.name,
    COUNT(b.booking_id) AS total_bookings,
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC) AS row_number,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS rank_position,
    DENSE_RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS dense_rank
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name;
```

#### **Advanced Window Functions**
- **PARTITION BY**: Location-based price rankings
- **Frame Specifications**: Running totals, moving averages
- **LAG/LEAD**: Temporal analysis of booking patterns
- **FIRST_VALUE/LAST_VALUE**: Boundary value analysis
- **PERCENT_RANK/NTILE**: Statistical percentile calculations
- **Time-based Analytics**: Monthly trends and growth rates

## 🎯 Key Learning Outcomes

### 1. JOIN Mastery
- Understanding different JOIN types and their use cases
- Handling NULL values in outer joins
- Combining multiple tables for comprehensive data retrieval
- PostgreSQL-specific syntax and optimizations

### 2. Subquery Proficiency
- **Non-correlated subqueries**: Independent execution for filtering
- **Correlated subqueries**: Row-by-row execution with outer query references
- **EXISTS/NOT EXISTS**: Efficient existence checking
- **IN/NOT IN**: Set membership operations with NULL handling

### 3. Analytical SQL Skills
- **Aggregation functions**: COUNT, SUM, AVG, MIN, MAX with GROUP BY
- **Window functions**: Ranking, running calculations, and partitioned analysis
- **Frame specifications**: ROWS and RANGE window frames
- **Statistical functions**: Percentiles, quartiles, and distribution analysis

## 🔧 Technical Features

### PostgreSQL-Specific Optimizations
- Native FULL OUTER JOIN syntax
- DATE_TRUNC() for time period grouping
- INTERVAL arithmetic for date calculations
- Advanced window function capabilities
- COALESCE() for NULL handling

### Query Performance Considerations
- Proper indexing strategies for JOIN operations
- Efficient subquery patterns
- Window function optimization
- GROUP BY optimization with appropriate indexes

### Data Integrity
- Proper handling of NULL values
- Referential integrity in JOIN operations
- Consistent data type usage
- Error-resistant query patterns

## 🚀 Running the Queries

### Prerequisites
- PostgreSQL 12+ database
- Airbnb Clone database schema installed
- Sample data populated (recommended for meaningful results)

### Execution Steps
1. **Connect to your PostgreSQL database**
   ```bash
   psql -h localhost -U username -d airbnb_clone_db
   ```

2. **Execute the SQL files in order**
   ```sql
   \i joins_queries.sql
   \i subqueries.sql
   \i aggregations_and_window_functions.sql
   ```

3. **Verify results and analyze query performance**
   ```sql
   EXPLAIN ANALYZE SELECT ...;
   ```

## 📊 Sample Query Results

### User Booking Statistics
```
user_id | first_name | last_name | total_bookings | total_spent | avg_booking_value
--------|------------|-----------|----------------|-------------|------------------
001     | John       | Doe       | 5              | 1250.00     | 250.00
002     | Jane       | Smith     | 3              | 890.00      | 296.67
```

### Property Rankings
```
property_id | property_name     | total_bookings | rank_position
------------|-------------------|----------------|---------------
101         | Downtown Loft     | 12             | 1
102         | Beach House       | 8              | 2
103         | Mountain Cabin    | 8              | 2
```

## 🎓 Advanced Concepts Demonstrated

### Complex JOIN Patterns
- Multi-table joins with proper foreign key relationships
- Handling many-to-many relationships through junction tables
- Outer joins with aggregate functions

### Subquery Strategies
- Performance comparison between subqueries and JOINs
- Correlated vs non-correlated execution patterns
- EXISTS vs IN clause optimization

### Window Function Applications
- Ranking and scoring systems
- Time-series analysis and trend calculations
- Moving averages and cumulative statistics
- Partitioned analytics by geographic regions

### Analytical Reporting
- Business intelligence query patterns
- Revenue and booking trend analysis
- User behavior pattern recognition
- Property performance metrics

## 🔍 Performance Notes

### Query Optimization Tips
1. **Use appropriate indexes** on frequently queried columns
2. **Analyze execution plans** with EXPLAIN ANALYZE
3. **Consider materialized views** for complex analytical queries
4. **Optimize window functions** with proper partitioning
5. **Use LIMIT** for large result sets during development

### Common Performance Patterns
- Indexed columns in WHERE, JOIN, and ORDER BY clauses
- Efficient subquery patterns (EXISTS vs IN)
- Proper window function frame specifications
- GROUP BY optimization with covering indexes

## 📚 Additional Resources

- [PostgreSQL Official Documentation](https://www.postgresql.org/docs/)
- [Window Functions Guide](https://www.postgresql.org/docs/current/tutorial-window.html)
- [Query Performance Tuning](https://www.postgresql.org/docs/current/performance-tips.html)
- [Advanced SQL Techniques](https://www.postgresql.org/docs/current/queries.html)

---

**Next Steps**: Index optimization, query performance analysis, and table partitioning strategies.
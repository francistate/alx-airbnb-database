# Entity-Relationship Diagram (ERD) Requirements

## Project: Airbnb Clone Database Design

### Overview
This document defines the entities, attributes, and relationships for the Airbnb Clone database system. The ERD is designed to support a comprehensive booking platform that handles user management, property listings, bookings, payments, reviews, and messaging functionality.

---

## Entities and Attributes

### 1. User Entity
**Purpose**: Manages all users in the system (guests, hosts, and administrators)

| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| user_id | UUID | PRIMARY KEY, INDEXED | Unique identifier for each user |
| first_name | VARCHAR | NOT NULL | User's first name |
| last_name | VARCHAR | NOT NULL | User's last name |
| email | VARCHAR | UNIQUE, NOT NULL | User's email address (login credential) |
| password_hash | VARCHAR | NOT NULL | Encrypted password for authentication |
| phone_number | VARCHAR | NULL | Optional contact phone number |
| role | ENUM | NOT NULL | User role: guest, host, or admin |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Account creation timestamp |

### 2. Property Entity
**Purpose**: Stores information about rental properties listed on the platform

| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| property_id | UUID | PRIMARY KEY, INDEXED | Unique identifier for each property |
| host_id | UUID | FOREIGN KEY, NOT NULL | References User(user_id) - property owner |
| name | VARCHAR | NOT NULL | Property title/name |
| description | TEXT | NOT NULL | Detailed property description |
| location | VARCHAR | NOT NULL | Property address/location |
| pricepernight | DECIMAL | NOT NULL | Nightly rental price |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Property listing creation time |
| updated_at | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | Last modification timestamp |

### 3. Booking Entity
**Purpose**: Manages reservation records between guests and properties

| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| booking_id | UUID | PRIMARY KEY, INDEXED | Unique identifier for each booking |
| property_id | UUID | FOREIGN KEY, NOT NULL | References Property(property_id) |
| user_id | UUID | FOREIGN KEY, NOT NULL | References User(user_id) - guest making booking |
| start_date | DATE | NOT NULL | Check-in date |
| end_date | DATE | NOT NULL | Check-out date |
| total_price | DECIMAL | NOT NULL | Total cost for the booking period |
| status | ENUM | NOT NULL | Booking status: pending, confirmed, or canceled |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Booking creation timestamp |

### 4. Payment Entity
**Purpose**: Tracks payment transactions for bookings

| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| payment_id | UUID | PRIMARY KEY, INDEXED | Unique identifier for each payment |
| booking_id | UUID | FOREIGN KEY, NOT NULL | References Booking(booking_id) |
| amount | DECIMAL | NOT NULL | Payment amount |
| payment_date | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | When payment was processed |
| payment_method | ENUM | NOT NULL | Payment type: credit_card, paypal, or stripe |

### 5. Review Entity
**Purpose**: Stores guest reviews and ratings for properties

| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| review_id | UUID | PRIMARY KEY, INDEXED | Unique identifier for each review |
| property_id | UUID | FOREIGN KEY, NOT NULL | References Property(property_id) |
| user_id | UUID | FOREIGN KEY, NOT NULL | References User(user_id) - reviewer |
| rating | INTEGER | CHECK (rating >= 1 AND rating <= 5), NOT NULL | Star rating from 1 to 5 |
| comment | TEXT | NOT NULL | Written review content |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Review submission timestamp |

### 6. Message Entity
**Purpose**: Enables communication between users (hosts and guests)

| Attribute | Data Type | Constraints | Description |
|-----------|-----------|-------------|-------------|
| message_id | UUID | PRIMARY KEY, INDEXED | Unique identifier for each message |
| sender_id | UUID | FOREIGN KEY, NOT NULL | References User(user_id) - message sender |
| recipient_id | UUID | FOREIGN KEY, NOT NULL | References User(user_id) - message recipient |
| message_body | TEXT | NOT NULL | Message content |
| sent_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Message sending timestamp |

---

## Entity Relationships

### Primary Relationships

1. **User → Property (One-to-Many)**
   - **Relationship**: A user can host multiple properties
   - **Business Rule**: Each property must have exactly one host
   - **Foreign Key**: Property.host_id → User.user_id

2. **User → Booking (One-to-Many)**
   - **Relationship**: A user (guest) can make multiple bookings
   - **Business Rule**: Each booking is made by exactly one user
   - **Foreign Key**: Booking.user_id → User.user_id

3. **Property → Booking (One-to-Many)**
   - **Relationship**: A property can have multiple bookings over time
   - **Business Rule**: Each booking is for exactly one property
   - **Foreign Key**: Booking.property_id → Property.property_id

4. **Booking → Payment (One-to-One)**
   - **Relationship**: Each booking has exactly one associated payment
   - **Business Rule**: Payments are directly tied to specific bookings
   - **Foreign Key**: Payment.booking_id → Booking.booking_id

5. **User → Review (One-to-Many)**
   - **Relationship**: A user can write multiple reviews
   - **Business Rule**: Each review is written by exactly one user
   - **Foreign Key**: Review.user_id → User.user_id

6. **Property → Review (One-to-Many)**
   - **Relationship**: A property can receive multiple reviews
   - **Business Rule**: Each review is for exactly one property
   - **Foreign Key**: Review.property_id → Property.property_id

7. **User → Message (One-to-Many as Sender)**
   - **Relationship**: A user can send multiple messages
   - **Business Rule**: Each message has exactly one sender
   - **Foreign Key**: Message.sender_id → User.user_id

8. **User → Message (One-to-Many as Recipient)**
   - **Relationship**: A user can receive multiple messages
   - **Business Rule**: Each message has exactly one recipient
   - **Foreign Key**: Message.recipient_id → User.user_id

---

## Database Constraints and Indexes

### Primary Key Constraints
- All entities use UUID primary keys for better scalability and security
- Primary keys are automatically indexed for optimal query performance

### Foreign Key Constraints
- All foreign key relationships enforce referential integrity
- Cascading rules should be defined based on business requirements

### Unique Constraints
- `User.email` must be unique across all users
- Prevents duplicate accounts with the same email address

### Check Constraints
- `Review.rating` must be between 1 and 5 inclusive
- `Booking.end_date` should be after `Booking.start_date` (to be implemented in application logic)

### Recommended Indexes
- `User.email` (for login authentication)
- `Property.host_id` (for host property queries)
- `Booking.property_id` (for property booking history)
- `Booking.user_id` (for user booking history)
- `Review.property_id` (for property reviews)
- `Message.sender_id` and `Message.recipient_id` (for message queries)

---

## Business Rules and Assumptions

1. **User Roles**: Users can have roles of guest, host, or admin
2. **Multi-Role Support**: A user can be both a guest (making bookings) and a host (listing properties)
3. **Booking Status**: Bookings progress through states: pending → confirmed → completed (or canceled)
4. **Payment Timing**: Payments are processed when bookings are confirmed
5. **Review Eligibility**: Only users who have completed bookings can review properties
6. **Message Privacy**: Messages are private between sender and recipient only

---

## Future Considerations

- **Amenities**: Consider a separate entity for property amenities (many-to-many relationship)
- **Photos**: Property and user profile photos (separate entity or file storage references)
- **Availability Calendar**: Property availability tracking for booking conflicts
- **Notification System**: User notification preferences and delivery tracking
- **Pricing Rules**: Dynamic pricing based on seasons, demand, etc.

---

*This ERD serves as the foundation for the Airbnb Clone database implementation and should be reviewed and approved before proceeding to the schema creation phase.*
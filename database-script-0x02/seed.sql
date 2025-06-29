-- =====================================================
-- Airbnb Clone Database Seed Data
-- =====================================================
-- This script populates the database with realistic sample data
-- for testing and development purposes.
-- 
-- Data includes: Users, Properties, Bookings, Payments, Reviews, Messages
-- Reflects real-world usage patterns and relationships
-- =====================================================

-- Disable foreign key checks temporarily for easier insertion
SET FOREIGN_KEY_CHECKS = 0;

-- =====================================================
-- SEED DATA: Users
-- =====================================================

INSERT INTO User (user_id, first_name, last_name, email, password_hash, phone_number, role, created_at) VALUES
-- Hosts
('550e8400-e29b-41d4-a716-446655440001', 'Sarah', 'Johnson', 'sarah.johnson@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmyQ1JEJj9XpNLO', '+1-555-0101', 'host', '2024-01-15 08:30:00'),
('550e8400-e29b-41d4-a716-446655440002', 'Michael', 'Chen', 'michael.chen@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmyQ1JEJj9XpNLO', '+1-555-0102', 'host', '2024-01-20 14:15:00'),
('550e8400-e29b-41d4-a716-446655440003', 'Elena', 'Rodriguez', 'elena.rodriguez@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmyQ1JEJj9XpNLO', '+1-555-0103', 'host', '2024-02-01 09:45:00'),
('550e8400-e29b-41d4-a716-446655440004', 'David', 'Thompson', 'david.thompson@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmyQ1JEJj9XpNLO', '+1-555-0104', 'host', '2024-02-10 16:20:00'),
('550e8400-e29b-41d4-a716-446655440005', 'Amara', 'Okafor', 'amara.okafor@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmyQ1JEJj9XpNLO', '+1-555-0105', 'host', '2024-02-15 11:30:00'),

-- Guests
('550e8400-e29b-41d4-a716-446655440006', 'James', 'Wilson', 'james.wilson@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmyQ1JEJj9XpNLO', '+1-555-0106', 'guest', '2024-03-01 10:15:00'),
('550e8400-e29b-41d4-a716-446655440007', 'Lisa', 'Anderson', 'lisa.anderson@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmyQ1JEJj9XpNLO', '+1-555-0107', 'guest', '2024-03-05 13:45:00'),
('550e8400-e29b-41d4-a716-446655440008', 'Robert', 'Kim', 'robert.kim@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmyQ1JEJj9XpNLO', '+1-555-0108', 'guest', '2024-03-10 15:20:00'),
('550e8400-e29b-41d4-a716-446655440009', 'Maria', 'Garcia', 'maria.garcia@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmyQ1JEJj9XpNLO', '+1-555-0109', 'guest', '2024-03-15 09:30:00'),
('550e8400-e29b-41d4-a716-446655440010', 'Alex', 'Turner', 'alex.turner@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmyQ1JEJj9XpNLO', '+1-555-0110', 'guest', '2024-03-20 12:10:00'),

-- Mixed role users (can be both guest and host)
('550e8400-e29b-41d4-a716-446655440011', 'Sophie', 'Brown', 'sophie.brown@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmyQ1JEJj9XpNLO', '+1-555-0111', 'host', '2024-03-25 14:25:00'),
('550e8400-e29b-41d4-a716-446655440012', 'Chris', 'Lee', 'chris.lee@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmyQ1JEJj9XpNLO', '+1-555-0112', 'guest', '2024-04-01 08:45:00'),

-- Admin
('550e8400-e29b-41d4-a716-446655440013', 'Admin', 'User', 'admin@airbnb-clone.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewmyQ1JEJj9XpNLO', '+1-555-0001', 'admin', '2024-01-01 00:00:00');

-- =====================================================
-- SEED DATA: Properties
-- =====================================================

INSERT INTO Property (property_id, host_id, name, description, location, pricepernight, created_at, updated_at) VALUES
-- Sarah Johnson's properties
('650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'Cozy Downtown Loft', 'Beautiful 1-bedroom loft in the heart of downtown. Features exposed brick walls, high ceilings, and modern amenities. Walking distance to restaurants, shops, and public transportation.', 'Seattle, WA, USA', 125.00, '2024-01-16 09:00:00', '2024-01-16 09:00:00'),
('650e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'Waterfront Studio', 'Stunning studio apartment with breathtaking water views. Perfect for couples or solo travelers. Includes full kitchen and private balcony overlooking the harbor.', 'Seattle, WA, USA', 95.00, '2024-02-01 10:30:00', '2024-02-01 10:30:00'),

-- Michael Chen's properties
('650e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440002', 'Modern Tech Hub Apartment', 'Sleek 2-bedroom apartment in Silicon Valley. High-speed internet, ergonomic workspace, and smart home features. Ideal for business travelers and tech professionals.', 'San Francisco, CA, USA', 180.00, '2024-01-25 11:15:00', '2024-01-25 11:15:00'),
('650e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440002', 'Chinatown Heritage Home', 'Charming traditional home in historic Chinatown. Features authentic architecture, peaceful garden, and walking distance to cultural sites and authentic cuisine.', 'San Francisco, CA, USA', 140.00, '2024-02-05 14:20:00', '2024-02-05 14:20:00'),

-- Elena Rodriguez's properties
('650e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440003', 'Art District Penthouse', 'Luxurious penthouse in the vibrant Arts District. Floor-to-ceiling windows, rooftop terrace, and surrounded by galleries, theaters, and trendy restaurants.', 'Los Angeles, CA, USA', 250.00, '2024-02-10 15:45:00', '2024-02-10 15:45:00'),
('650e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440003', 'Beach Bungalow Paradise', 'Relaxing beachside bungalow just steps from the sand. Features outdoor shower, hammock, and stunning sunset views. Perfect for a peaceful getaway.', 'Santa Monica, CA, USA', 200.00, '2024-02-15 12:30:00', '2024-02-15 12:30:00'),

-- David Thompson's properties
('650e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440004', 'Historic Brownstone', 'Elegant 3-bedroom brownstone in prestigious neighborhood. Original hardwood floors, fireplace, and private garden. Rich history and modern comfort combined.', 'New York, NY, USA', 300.00, '2024-02-20 16:10:00', '2024-02-20 16:10:00'),
('650e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440004', 'Brooklyn Artist Loft', 'Spacious artist loft in trendy Brooklyn neighborhood. High ceilings, natural light, and creative atmosphere. Close to galleries, cafes, and artisan markets.', 'New York, NY, USA', 165.00, '2024-02-25 13:25:00', '2024-02-25 13:25:00'),

-- Amara Okafor's properties
('650e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440005', 'Music City Retreat', 'Charming cottage near Music Row. Perfect for music lovers with guitar collection, vinyl records, and soundproofed room. Walking distance to honky-tonks and studios.', 'Nashville, TN, USA', 110.00, '2024-02-28 17:40:00', '2024-02-28 17:40:00'),

-- Sophie Brown's property
('650e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440011', 'Mountain View Cabin', 'Rustic cabin with panoramic mountain views. Features fireplace, hot tub, and hiking trails nearby. Perfect for nature lovers and outdoor enthusiasts seeking tranquility.', 'Aspen, CO, USA', 220.00, '2024-03-30 18:15:00', '2024-03-30 18:15:00');

-- =====================================================
-- SEED DATA: Bookings
-- =====================================================

INSERT INTO Booking (booking_id, property_id, user_id, start_date, end_date, total_price, status, created_at) VALUES
-- Confirmed bookings (past and current)
('750e8400-e29b-41d4-a716-446655440001', '650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440006', '2024-04-15', '2024-04-18', 375.00, 'confirmed', '2024-04-01 10:30:00'),
('750e8400-e29b-41d4-a716-446655440002', '650e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440007', '2024-04-20', '2024-04-25', 900.00, 'confirmed', '2024-04-05 14:15:00'),
('750e8400-e29b-41d4-a716-446655440003', '650e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440008', '2024-04-22', '2024-04-24', 500.00, 'confirmed', '2024-04-08 09:45:00'),
('750e8400-e29b-41d4-a716-446655440004', '650e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440009', '2024-05-01', '2024-05-04', 900.00, 'confirmed', '2024-04-15 16:20:00'),
('750e8400-e29b-41d4-a716-446655440005', '650e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440010', '2024-05-10', '2024-05-12', 190.00, 'confirmed', '2024-04-25 11:30:00'),

-- Pending bookings (future)
('750e8400-e29b-41d4-a716-446655440006', '650e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440012', '2025-07-15', '2025-07-20', 700.00, 'pending', '2024-06-20 13:45:00'),
('750e8400-e29b-41d4-a716-446655440007', '650e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440006', '2025-08-01', '2025-08-05', 800.00, 'pending', '2024-06-25 15:10:00'),
('750e8400-e29b-41d4-a716-446655440008', '650e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440007', '2025-09-10', '2025-09-15', 550.00, 'confirmed', '2024-07-01 12:20:00'),

-- Canceled booking
('750e8400-e29b-41d4-a716-446655440009', '650e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440011', '2024-06-15', '2024-06-18', 495.00, 'canceled', '2024-05-20 08:30:00'),

-- Recent bookings
('750e8400-e29b-41d4-a716-446655440010', '650e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440008', '2025-07-01', '2025-07-05', 880.00, 'confirmed', '2024-06-15 17:25:00');

-- =====================================================
-- SEED DATA: Payments
-- =====================================================

INSERT INTO Payment (payment_id, booking_id, amount, payment_date, payment_method) VALUES
-- Payments for confirmed bookings
('850e8400-e29b-41d4-a716-446655440001', '750e8400-e29b-41d4-a716-446655440001', 375.00, '2024-04-01 10:35:00', 'credit_card'),
('850e8400-e29b-41d4-a716-446655440002', '750e8400-e29b-41d4-a716-446655440002', 900.00, '2024-04-05 14:20:00', 'paypal'),
('850e8400-e29b-41d4-a716-446655440003', '750e8400-e29b-41d4-a716-446655440003', 500.00, '2024-04-08 09:50:00', 'stripe'),
('850e8400-e29b-41d4-a716-446655440004', '750e8400-e29b-41d4-a716-446655440004', 900.00, '2024-04-15 16:25:00', 'credit_card'),
('850e8400-e29b-41d4-a716-446655440005', '750e8400-e29b-41d4-a716-446655440005', 190.00, '2024-04-25 11:35:00', 'paypal'),
('850e8400-e29b-41d4-a716-446655440008', '750e8400-e29b-41d4-a716-446655440008', 550.00, '2024-07-01 12:25:00', 'stripe'),
('850e8400-e29b-41d4-a716-446655440010', '750e8400-e29b-41d4-a716-446655440010', 880.00, '2024-06-15 17:30:00', 'credit_card');

-- =====================================================
-- SEED DATA: Reviews
-- =====================================================

INSERT INTO Review (review_id, property_id, user_id, rating, comment, created_at) VALUES
-- Reviews for completed stays
('950e8400-e29b-41d4-a716-446655440001', '650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440006', 5, 'Absolutely perfect stay! The loft was exactly as described - beautiful exposed brick, great location, and Sarah was an amazing host. Would definitely book again!', '2024-04-19 14:30:00'),

('950e8400-e29b-41d4-a716-446655440002', '650e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440007', 4, 'Great apartment in excellent location for business travel. High-speed internet worked perfectly for video calls. Only minor issue was street noise at night, but overall very satisfied.', '2024-04-26 09:15:00'),

('950e8400-e29b-41d4-a716-446655440003', '650e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440008', 5, 'Stunning penthouse with incredible views! The rooftop terrace was perfect for morning coffee. Walking distance to amazing galleries and restaurants. Elena was very responsive and helpful.', '2024-04-25 16:45:00'),

('950e8400-e29b-41d4-a716-446655440004', '650e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440009', 4, 'Beautiful historic brownstone with so much character. Loved the original hardwood floors and fireplace. The garden was a peaceful retreat. Great neighborhood for exploring.', '2024-05-05 11:20:00'),

('950e8400-e29b-41d4-a716-446655440005', '650e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440010', 5, 'Amazing waterfront views from this cozy studio! Woke up to beautiful sunrises every morning. The location is perfect - close to everything but quiet at night. Highly recommend!', '2024-05-13 13:10:00'),

-- Additional reviews from different users for variety
('950e8400-e29b-41d4-a716-446655440006', '650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440007', 4, 'Great downtown location and stylish loft. The exposed brick walls and high ceilings create a wonderful atmosphere. Check-in was smooth and host communication was excellent.', '2024-03-10 15:30:00'),

('950e8400-e29b-41d4-a716-446655440007', '650e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440008', 5, 'Loved staying in Chinatown! The house has so much authentic character and the garden is beautiful. Walking distance to incredible food and cultural sites. Michael was a gracious host.', '2024-03-20 12:45:00'),

('950e8400-e29b-41d4-a716-446655440008', '650e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440012', 5, 'Beach bungalow paradise indeed! Fell asleep to the sound of waves and woke up to gorgeous sunsets. The outdoor shower was a unique touch. Perfect for a romantic getaway.', '2024-02-28 18:20:00'),

('950e8400-e29b-41d4-a716-446655440009', '650e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440006', 4, 'Music lovers dream! The guitar collection and vinyl records made for an authentic Nashville experience. Great location near Music Row. Amara provided excellent local recommendations.', '2024-04-05 14:15:00');

-- =====================================================
-- SEED DATA: Messages
-- =====================================================

INSERT INTO Message (message_id, sender_id, recipient_id, message_body, sent_at) VALUES
-- Pre-booking inquiries
('A50e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440001', 'Hi Sarah! I\'m interested in booking your downtown loft for April 15-18. Is it available? Also, is parking included?', '2024-03-30 14:20:00'),

('A50e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440006', 'Hi James! Yes, the loft is available for those dates. Street parking is available and I can provide a parking permit. The space is perfect for your stay - let me know if you have any other questions!', '2024-03-30 15:45:00'),

('A50e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440001', 'Perfect! I\'ll go ahead and book it. Looking forward to staying there!', '2024-03-30 16:10:00'),

-- Check-in instructions
('A50e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440006', 'Hi James! Just wanted to send you the check-in details. The keypad code is 1234*. WiFi password is "DowntownLoft2024". Let me know when you arrive safely!', '2024-04-14 18:30:00'),

-- Post-stay follow up
('A50e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440006', 'Hope you had a wonderful stay! If you have a moment, I\'d really appreciate a review. Thanks for being such a great guest!', '2024-04-19 10:15:00'),

-- Business traveler inquiry
('A50e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440002', 'Hello Michael, I\'m traveling for work and need reliable internet for video conferences. Can you confirm the connection speed at your Tech Hub apartment?', '2024-04-02 09:30:00'),

('A50e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440007', 'Hi Lisa! Absolutely - we have fiber internet with 1GB download/upload speeds. Perfect for video calls. The workspace has a standing desk and great lighting too.', '2024-04-02 10:15:00'),

-- Guest services questions
('A50e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440003', 'Hi Elena! We\'re celebrating our anniversary at your Arts District penthouse. Any restaurant recommendations nearby?', '2024-04-20 19:45:00'),

('A50e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440008', 'Congratulations! For anniversary dinner, I highly recommend Otium or Republique - both amazing and within walking distance. Enjoy your special celebration!', '2024-04-20 20:30:00'),

-- Host-to-host communication
('A50e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440002', 'Hey Michael! Noticed you\'re hosting in SF too. Would love to connect and share hosting tips sometime.', '2024-03-15 16:20:00'),

('A50e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'Hi Sarah! Absolutely, always great to connect with fellow hosts. I\'d be happy to share what I\'ve learned. Maybe we can grab coffee when you\'re in the Bay Area?', '2024-03-15 17:45:00'),

-- Booking modification request
('A50e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440004', 'Hi David, I need to change my Brooklyn loft booking from June 15-18 to June 20-23. Is that possible?', '2024-05-18 14:30:00'),

('A50e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440012', 'Hi Chris! Let me check availability for June 20-23. Unfortunately those dates are already booked. How about June 22-25?', '2024-05-18 15:45:00'),

-- Special requests
('A50e8400-e29b-41d4-a716-446655440014', '550e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440011', 'Hi Sophie! We\'re bringing our small dog - I see you\'re pet-friendly. Any special instructions or nearby dog parks?', '2024-06-10 11:20:00'),

('A50e8400-e29b-41d4-a716-446655440015', '550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440010', 'That\'s wonderful! Dogs are absolutely welcome. There\'s a great dog park just 2 blocks away and several pet-friendly hiking trails. I\'ll send you a map with all the best spots!', '2024-06-10 12:45:00');

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;


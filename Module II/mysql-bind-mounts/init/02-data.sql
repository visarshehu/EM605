-- Sample data for Bind Mounts example
USE testdb;

-- Insert categories
INSERT INTO categories (name, description) VALUES
('Electronics', 'Electronic devices and gadgets'),
('Books', 'Physical and digital books'),
('Clothing', 'Apparel and accessories'),
('Home & Garden', 'Home improvement and gardening supplies'),
('Sports', 'Sports equipment and gear');

-- Insert products
INSERT INTO products (category_id, name, description, price, stock_quantity) VALUES
-- Electronics
(1, 'Wireless Headphones', 'High-quality Bluetooth headphones with noise cancellation', 129.99, 50),
(1, 'Smart Watch', 'Fitness tracking smartwatch with heart rate monitor', 249.99, 30),
(1, 'Laptop Stand', 'Adjustable aluminum laptop stand for better ergonomics', 39.99, 100),

-- Books
(2, 'Docker Deep Dive', 'Comprehensive guide to Docker containerization', 45.99, 75),
(2, 'Kubernetes in Action', 'Learn Kubernetes from the ground up', 52.99, 60),
(2, 'DevOps Handbook', 'Best practices for DevOps implementation', 38.99, 80),

-- Clothing
(3, 'Docker T-Shirt', 'Comfortable cotton t-shirt with Docker logo', 24.99, 200),
(3, 'Tech Hoodie', 'Warm hoodie perfect for coding sessions', 54.99, 120),
(3, 'Developer Cap', 'Adjustable cap with programming themes', 19.99, 150),

-- Home & Garden
(4, 'Standing Desk', 'Height-adjustable standing desk for home office', 299.99, 25),
(4, 'Ergonomic Chair', 'Comfortable office chair with lumbar support', 179.99, 40),
(4, 'Desk Lamp', 'LED desk lamp with adjustable brightness', 34.99, 60),

-- Sports
(5, 'Yoga Mat', 'Non-slip exercise mat for yoga and workouts', 29.99, 85),
(5, 'Water Bottle', 'Insulated stainless steel water bottle', 22.99, 110),
(5, 'Resistance Bands', 'Set of resistance bands for strength training', 18.99, 95);

-- Insert sample orders
INSERT INTO orders (customer_email, total_amount, status) VALUES
('john@example.com', 279.98, 'delivered'),
('sarah@example.com', 98.98, 'shipped'),
('mike@example.com', 45.99, 'processing'),
('lisa@example.com', 154.97, 'pending'),
('david@example.com', 52.99, 'delivered');

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
-- Order 1: john@example.com
(1, 1, 1, 129.99),  -- Wireless Headphones
(1, 11, 1, 34.99),  -- Desk Lamp
(1, 3, 3, 39.99),   -- Laptop Stand

-- Order 2: sarah@example.com
(2, 7, 2, 24.99),   -- Docker T-Shirt
(2, 13, 2, 22.99),  -- Water Bottle

-- Order 3: mike@example.com
(3, 4, 1, 45.99),   -- Docker Deep Dive

-- Order 4: lisa@example.com
(4, 2, 1, 249.99),  -- Smart Watch
(4, 9, 1, 19.99),   -- Developer Cap

-- Order 5: david@example.com
(5, 5, 1, 52.99);   -- Kubernetes in Action

-- Display sample data
SELECT 'Categories:' as info;
SELECT * FROM categories;

SELECT 'Products by category:' as info;
SELECT c.name as category, p.name, p.price, p.stock_quantity 
FROM products p 
JOIN categories c ON p.category_id = c.id 
ORDER BY c.name, p.name;

SELECT 'Recent orders:' as info;
SELECT o.id, o.customer_email, o.total_amount, o.status, o.order_date
FROM orders o 
ORDER BY o.order_date DESC;

SELECT 'Data inserted successfully into BIND MOUNT!' as result;
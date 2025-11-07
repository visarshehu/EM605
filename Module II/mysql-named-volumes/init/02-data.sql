-- Sample data for Named Volumes example
USE testdb;

-- Insert sample users
INSERT INTO users (username, email) VALUES
('alice_admin', 'alice@example.com'),
('bob_developer', 'bob@example.com'),
('charlie_designer', 'charlie@example.com'),
('diana_manager', 'diana@example.com'),
('eve_tester', 'eve@example.com');

-- Insert sample posts
INSERT INTO posts (user_id, title, content, status) VALUES
(1, 'Welcome to Our Platform', 'This is our first post explaining the platform features.', 'published'),
(1, 'Database Volume Management', 'Understanding named volumes vs bind mounts in Docker.', 'published'),
(2, 'Development Best Practices', 'Some tips for containerized application development.', 'published'),
(2, 'Docker Compose Tutorial', 'A comprehensive guide to using Docker Compose.', 'draft'),
(3, 'UI/UX Design Principles', 'Modern design principles for web applications.', 'published'),
(3, 'Color Theory in Web Design', 'How to use colors effectively in web interfaces.', 'draft'),
(4, 'Project Management Tips', 'Managing containerized projects effectively.', 'published'),
(5, 'Testing Strategies', 'Effective testing approaches for Docker applications.', 'draft'),
(5, 'Quality Assurance', 'Ensuring quality in containerized environments.', 'published'),
(1, 'Advanced Docker Features', 'Exploring advanced Docker and Compose features.', 'archived');

-- Display initial data
SELECT 'Users created:' as info;
SELECT id, username, email FROM users;

SELECT 'Posts created:' as info;
SELECT p.id, u.username, p.title, p.status, p.created_at 
FROM posts p 
JOIN users u ON p.user_id = u.id 
ORDER BY p.created_at DESC;

SELECT 'Data inserted successfully into NAMED VOLUME!' as result;
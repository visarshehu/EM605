-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS todoapp;
USE todoapp;

-- Create todos table
CREATE TABLE IF NOT EXISTS todos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create index for better query performance
CREATE INDEX idx_completed ON todos(completed);
CREATE INDEX idx_created_at ON todos(created_at);

-- Insert sample data for demonstration
INSERT INTO todos (title, description, completed) VALUES
('Learn Docker Basics', 'Understand containerization, images, and basic Docker commands', true),
('Master Docker Compose', 'Learn multi-container orchestration with Docker Compose', false),
('Explore Container Networking', 'Understand how containers communicate with each other', false),
('Implement Health Checks', 'Add health checks to ensure container reliability', false),
('Study Volume Management', 'Learn about data persistence and volume mounting', false),
('Deploy to Production', 'Deploy containerized applications to production environment', false);

-- Display initial data
SELECT 'Sample todos inserted:' as message;
SELECT id, title, completed, created_at FROM todos ORDER BY id;
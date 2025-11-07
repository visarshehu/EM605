CREATE DATABASE IF NOT EXISTS todoapp;
USE todoapp;

CREATE TABLE IF NOT EXISTS todos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert some sample data
INSERT INTO todos (title, description, completed) VALUES
('Learn Docker', 'Understand containerization concepts', false),
('Build Todo App', 'Create a multi-container todo application', true),
('Deploy to Production', 'Deploy the application using Docker', false);
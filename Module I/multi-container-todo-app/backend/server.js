const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Database configuration
const dbConfig = {
  host: process.env.DB_HOST || 'mysql-container',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'rootpassword',
  database: process.env.DB_NAME || 'todoapp',
  connectTimeout: 60000,
  acquireTimeout: 60000,
};

let db;

// Initialize database connection
async function initializeDatabase() {
  try {
    console.log('Attempting to connect to database...');
    db = await mysql.createConnection(dbConfig);
    console.log('Connected to MySQL database');
  } catch (error) {
    console.error('Database connection failed:', error.message);
    console.log('Retrying in 5 seconds...');
    setTimeout(initializeDatabase, 5000);
  }
}

// Routes
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Get all todos
app.get('/api/todos', async (req, res) => {
  try {
    const [rows] = await db.execute('SELECT * FROM todos ORDER BY created_at DESC');
    res.json(rows);
  } catch (error) {
    console.error('Error fetching todos:', error);
    res.status(500).json({ error: 'Failed to fetch todos' });
  }
});

// Get todo by ID
app.get('/api/todos/:id', async (req, res) => {
  try {
    const [rows] = await db.execute('SELECT * FROM todos WHERE id = ?', [req.params.id]);
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Todo not found' });
    }
    res.json(rows[0]);
  } catch (error) {
    console.error('Error fetching todo:', error);
    res.status(500).json({ error: 'Failed to fetch todo' });
  }
});

// Create new todo
app.post('/api/todos', async (req, res) => {
  const { title, description } = req.body;
  
  if (!title) {
    return res.status(400).json({ error: 'Title is required' });
  }

  try {
    const [result] = await db.execute(
      'INSERT INTO todos (title, description) VALUES (?, ?)',
      [title, description || '']
    );
    
    const [rows] = await db.execute('SELECT * FROM todos WHERE id = ?', [result.insertId]);
    res.status(201).json(rows[0]);
  } catch (error) {
    console.error('Error creating todo:', error);
    res.status(500).json({ error: 'Failed to create todo' });
  }
});

// Update todo
app.put('/api/todos/:id', async (req, res) => {
  const { title, description, completed } = req.body;
  
  try {
    const [result] = await db.execute(
      'UPDATE todos SET title = ?, description = ?, completed = ? WHERE id = ?',
      [title, description, completed, req.params.id]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Todo not found' });
    }
    
    const [rows] = await db.execute('SELECT * FROM todos WHERE id = ?', [req.params.id]);
    res.json(rows[0]);
  } catch (error) {
    console.error('Error updating todo:', error);
    res.status(500).json({ error: 'Failed to update todo' });
  }
});

// Delete todo
app.delete('/api/todos/:id', async (req, res) => {
  try {
    const [result] = await db.execute('DELETE FROM todos WHERE id = ?', [req.params.id]);
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Todo not found' });
    }
    
    res.status(204).send();
  } catch (error) {
    console.error('Error deleting todo:', error);
    res.status(500).json({ error: 'Failed to delete todo' });
  }
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
  initializeDatabase();
});
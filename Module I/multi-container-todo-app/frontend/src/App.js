import React, { useState, useEffect } from 'react';
import './App.css';

const API_BASE_URL = process.env.REACT_APP_API_URL || '/api';

function App() {
  const [todos, setTodos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [newTodo, setNewTodo] = useState({ title: '', description: '' });

  // Fetch todos from API
  const fetchTodos = async () => {
    try {
      setLoading(true);
      const response = await fetch(`${API_BASE_URL}/todos`);
      if (!response.ok) {
        throw new Error('Failed to fetch todos');
      }
      const data = await response.json();
      setTodos(data);
      setError(null);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  // Create new todo
  const createTodo = async (e) => {
    e.preventDefault();
    if (!newTodo.title.trim()) return;

    try {
      const response = await fetch(`${API_BASE_URL}/todos`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(newTodo),
      });
      
      if (!response.ok) {
        throw new Error('Failed to create todo');
      }
      
      setNewTodo({ title: '', description: '' });
      fetchTodos(); // Refresh the list
    } catch (err) {
      setError(err.message);
    }
  };

  // Toggle todo completion
  const toggleTodo = async (todo) => {
    try {
      const response = await fetch(`${API_BASE_URL}/todos/${todo.id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          ...todo,
          completed: !todo.completed,
        }),
      });
      
      if (!response.ok) {
        throw new Error('Failed to update todo');
      }
      
      fetchTodos(); // Refresh the list
    } catch (err) {
      setError(err.message);
    }
  };

  // Delete todo
  const deleteTodo = async (id) => {
    try {
      const response = await fetch(`${API_BASE_URL}/todos/${id}`, {
        method: 'DELETE',
      });
      
      if (!response.ok) {
        throw new Error('Failed to delete todo');
      }
      
      fetchTodos(); // Refresh the list
    } catch (err) {
      setError(err.message);
    }
  };

  useEffect(() => {
    fetchTodos();
  }, []);

  if (loading) {
    return <div className="loading">Loading todos...</div>;
  }

  return (
    <div className="container">
      <div className="header">
        <h1>Todo App</h1>
        <p>Multi-container Docker application with React, Node.js, and MySQL</p>
      </div>

      {error && (
        <div className="error">
          Error: {error}
        </div>
      )}

      <form className="todo-form" onSubmit={createTodo}>
        <h2>Add New Todo</h2>
        <input
          type="text"
          placeholder="Todo title..."
          value={newTodo.title}
          onChange={(e) => setNewTodo({ ...newTodo, title: e.target.value })}
          required
        />
        <textarea
          placeholder="Description (optional)..."
          value={newTodo.description}
          onChange={(e) => setNewTodo({ ...newTodo, description: e.target.value })}
          rows={3}
        />
        <button type="submit">Add Todo</button>
      </form>

      <div className="todo-list">
        {todos.length === 0 ? (
          <div className="loading">No todos found. Create your first todo!</div>
        ) : (
          todos.map((todo) => (
            <div key={todo.id} className={`todo-item ${todo.completed ? 'completed' : ''}`}>
              <div className="todo-content">
                <h3>{todo.title}</h3>
                {todo.description && <p>{todo.description}</p>}
                <small>Created: {new Date(todo.created_at).toLocaleDateString()}</small>
              </div>
              <div className="todo-actions">
                <button
                  className="complete-btn"
                  onClick={() => toggleTodo(todo)}
                >
                  {todo.completed ? 'Undo' : 'Complete'}
                </button>
                <button
                  className="delete-btn"
                  onClick={() => deleteTodo(todo.id)}
                >
                  Delete
                </button>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}

export default App;
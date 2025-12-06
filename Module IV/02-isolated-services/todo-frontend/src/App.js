import React, { useState, useEffect } from 'react';
import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || '/api';

function App() {
  const [todos, setTodos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [newTodo, setNewTodo] = useState({ title: '', description: '' });

  useEffect(() => {
    fetchTodos();
  }, []);

  const fetchTodos = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`${API_BASE_URL}/todos`);
      setTodos(response.data);
      setError('');
    } catch (err) {
      setError('Failed to fetch todos');
      console.error('Error fetching todos:', err);
    } finally {
      setLoading(false);
    }
  };

  const createTodo = async (e) => {
    e.preventDefault();
    if (!newTodo.title.trim()) return;

    try {
      const response = await axios.post(`${API_BASE_URL}/todos`, newTodo);
      setTodos([...todos, response.data]);
      setNewTodo({ title: '', description: '' });
      setError('');
    } catch (err) {
      setError('Failed to create todo');
      console.error('Error creating todo:', err);
    }
  };

  const toggleTodo = async (todo) => {
    try {
      const response = await axios.put(`${API_BASE_URL}/todos/${todo.id}`, {
        ...todo,
        completed: !todo.completed
      });
      setTodos(todos.map(t => t.id === todo.id ? response.data : t));
      setError('');
    } catch (err) {
      setError('Failed to update todo');
      console.error('Error updating todo:', err);
    }
  };

  const deleteTodo = async (todoId) => {
    try {
      await axios.delete(`${API_BASE_URL}/todos/${todoId}`);
      setTodos(todos.filter(t => t.id !== todoId));
      setError('');
    } catch (err) {
      setError('Failed to delete todo');
      console.error('Error deleting todo:', err);
    }
  };

  return (
    <div className="container">
      <div className="university-header">
        <img src="/seeu-logo.png" alt="South East European University" className="university-logo" />
        <div className="course-info">
          <p className="course-name">Course name: Containerized Architecture</p>
          <p className="course-description">Sample todo application - for educational purposes</p>
        </div>
      </div>
      <h1 className="header">Todo Application</h1>
      
      {error && <div className="error">{error}</div>}
      
      <div className="todo-form">
        <h3>Add New Todo</h3>
        <form onSubmit={createTodo}>
          <div className="form-group">
            <label>Title</label>
            <input
              type="text"
              value={newTodo.title}
              onChange={(e) => setNewTodo({...newTodo, title: e.target.value})}
              placeholder="Enter todo title"
              required
            />
          </div>
          <div className="form-group">
            <label>Description</label>
            <textarea
              value={newTodo.description}
              onChange={(e) => setNewTodo({...newTodo, description: e.target.value})}
              placeholder="Enter todo description (optional)"
            />
          </div>
          <button type="submit" className="btn">Add Todo</button>
        </form>
      </div>

      <div className="todo-list">
        {loading ? (
          <div className="loading">Loading todos...</div>
        ) : todos.length === 0 ? (
          <div className="empty-state">No todos yet. Add one above!</div>
        ) : (
          todos.map(todo => (
            <div key={todo.id} className="todo-item">
              <div className="todo-content">
                <div className={`todo-title ${todo.completed ? 'completed' : ''}`}>
                  {todo.title}
                </div>
                {todo.description && (
                  <div className="todo-description">{todo.description}</div>
                )}
              </div>
              <div className="todo-actions">
                <button
                  onClick={() => toggleTodo(todo)}
                  className={`btn ${todo.completed ? 'btn-success' : ''}`}
                >
                  {todo.completed ? 'Undo' : 'Complete'}
                </button>
                <button
                  onClick={() => deleteTodo(todo.id)}
                  className="btn btn-danger"
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
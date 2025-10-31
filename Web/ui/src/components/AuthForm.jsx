// ABOUTME: Authentication form component for login and registration
// ABOUTME: Handles user authentication with form validation and error handling

import { useState } from 'react'
import { authService } from '../services/auth.js'

export default function AuthForm({ onAuthSuccess }) {
  const [isLogin, setIsLogin] = useState(true)
  const [formData, setFormData] = useState({
    child_name: '',
    child_age: '',
    email: '',
    password: ''
  })
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')
    setLoading(true)

    try {
      if (isLogin) {
        await authService.login(formData.email, formData.password)
      } else {
        await authService.register(formData)
      }
      onAuthSuccess?.()
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const handleChange = (e) => {
    setFormData(prev => ({
      ...prev,
      [e.target.name]: e.target.value
    }))
  }

  return (
    <div style={{ maxWidth: '400px', margin: '0 auto', padding: '2rem' }}>
      <h2>{isLogin ? 'Login' : 'Register'}</h2>
      
      {error && (
        <div style={{ 
          color: 'red', 
          marginBottom: '1rem', 
          padding: '0.5rem', 
          backgroundColor: '#fee', 
          borderRadius: '4px' 
        }}>
          {error}
        </div>
      )}

      <form onSubmit={handleSubmit}>
        {!isLogin && (
          <>
            <div style={{ marginBottom: '1rem' }}>
              <label>
                Child's Name:
                <input
                  type="text"
                  name="child_name"
                  value={formData.child_name}
                  onChange={handleChange}
                  required={!isLogin}
                  style={{ width: '100%', padding: '0.5rem', marginTop: '0.25rem' }}
                />
              </label>
            </div>
            
            <div style={{ marginBottom: '1rem' }}>
              <label>
                Child's Age:
                <input
                  type="number"
                  name="child_age"
                  value={formData.child_age}
                  onChange={handleChange}
                  required={!isLogin}
                  style={{ width: '100%', padding: '0.5rem', marginTop: '0.25rem' }}
                />
              </label>
            </div>
          </>
        )}

        <div style={{ marginBottom: '1rem' }}>
          <label>
            Email:
            <input
              type="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              required
              style={{ width: '100%', padding: '0.5rem', marginTop: '0.25rem' }}
            />
          </label>
        </div>

        <div style={{ marginBottom: '1rem' }}>
          <label>
            Password:
            <input
              type="password"
              name="password"
              value={formData.password}
              onChange={handleChange}
              required
              style={{ width: '100%', padding: '0.5rem', marginTop: '0.25rem' }}
            />
          </label>
        </div>

        <button
          type="submit"
          disabled={loading}
          style={{
            width: '100%',
            padding: '0.75rem',
            backgroundColor: '#007bff',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: loading ? 'not-allowed' : 'pointer'
          }}
        >
          {loading ? 'Please wait...' : (isLogin ? 'Login' : 'Register')}
        </button>
      </form>

      <p style={{ textAlign: 'center', marginTop: '1rem' }}>
        {isLogin ? "Don't have an account? " : "Already have an account? "}
        <button
          type="button"
          onClick={() => setIsLogin(!isLogin)}
          style={{
            background: 'none',
            border: 'none',
            color: '#007bff',
            cursor: 'pointer',
            textDecoration: 'underline'
          }}
        >
          {isLogin ? 'Register' : 'Login'}
        </button>
      </p>
    </div>
  )
}
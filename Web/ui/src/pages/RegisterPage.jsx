// ABOUTME: Registration page component for new user account creation
// ABOUTME: Handles registration form validation, submission, and navigation to login

import { useState } from 'react'
import { Link } from 'react-router-dom'
import { authService } from '../services/auth.js'

export default function RegisterPage() {
  const [formData, setFormData] = useState({
    child_name: '',
    child_age: '',
    email: '',
    password: ''
  })
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const [success, setSuccess] = useState(false)

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')
    setLoading(true)

    try {
      await authService.register(formData)
      setSuccess(true)
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

  if (success) {
    return (
      <div style={{
        minHeight: '100vh',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: '#f9fafb'
      }}>
        <div style={{
          backgroundColor: 'white',
          boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
          borderRadius: '0.75rem',
          padding: '2rem',
          marginBottom: '1rem',
          width: '100%',
          maxWidth: '24rem',
          textAlign: 'center'
        }}>
          <div style={{
            color: '#059669',
            fontSize: '1.25rem',
            fontWeight: 'bold',
            marginBottom: '1rem'
          }}>Registration Successful!</div>
          <p style={{
            color: '#4b5563',
            marginBottom: '1rem'
          }}>Your account has been created successfully.</p>
          <Link 
            to="/login" 
            style={{
              display: 'inline-block',
              backgroundColor: '#2563eb',
              color: 'white',
              padding: '0.5rem 1rem',
              borderRadius: '0.375rem',
              textDecoration: 'none',
              fontWeight: 'bold'
            }}
            onMouseOver={(e) => e.target.style.backgroundColor = '#1d4ed8'}
            onMouseOut={(e) => e.target.style.backgroundColor = '#2563eb'}
          >
            Go to Login
          </Link>
        </div>
      </div>
    )
  }

  return (
    <div style={{
      minHeight: '100vh',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      backgroundColor: '#f9fafb'
    }}>
      <div style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        marginBottom: '2rem'
      }}>
        <div style={{
          display: 'flex',
          alignItems: 'center',
          gap: '0.5rem',
          fontSize: '1.875rem',
          fontWeight: 'bold',
          color: '#111827',
          marginBottom: '0.5rem'
        }}>
          <span style={{
            borderRadius: '50%',
            backgroundColor: '#2563eb',
            color: 'white',
            padding: '0.5rem 1rem',
            marginRight: '0.5rem'
          }}>T</span>
          Tedio
        </div>
        <div style={{
          color: '#6b7280',
          fontSize: '1.125rem',
          fontWeight: '600',
          marginBottom: '0.5rem'
        }}>Create your account</div>
      </div>
      
      <form onSubmit={handleSubmit} style={{
        backgroundColor: 'white',
        boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
        borderRadius: '0.75rem',
        padding: '2rem',
        marginBottom: '1rem',
        width: '100%',
        maxWidth: '24rem'
      }}>
        <div style={{ marginBottom: '1rem' }}>
          <label style={{
            display: 'block',
            color: '#374151',
            fontSize: '0.875rem',
            fontWeight: 'bold',
            marginBottom: '0.5rem'
          }}>Child's Name</label>
          <input 
            name="child_name" 
            value={formData.child_name} 
            onChange={handleChange} 
            type="text" 
            style={{
              boxShadow: '0 1px 2px 0 rgba(0, 0, 0, 0.05)',
              border: '1px solid #d1d5db',
              borderRadius: '0.375rem',
              width: '100%',
              padding: '0.5rem 0.75rem',
              color: '#374151',
              lineHeight: '1.25'
            }}
            required 
          />
        </div>
        
        <div style={{ marginBottom: '1rem' }}>
          <label style={{
            display: 'block',
            color: '#374151',
            fontSize: '0.875rem',
            fontWeight: 'bold',
            marginBottom: '0.5rem'
          }}>Child's Age</label>
          <input 
            name="child_age" 
            value={formData.child_age} 
            onChange={handleChange} 
            type="number" 
            min="1" 
            style={{
              boxShadow: '0 1px 2px 0 rgba(0, 0, 0, 0.05)',
              border: '1px solid #d1d5db',
              borderRadius: '0.375rem',
              width: '100%',
              padding: '0.5rem 0.75rem',
              color: '#374151',
              lineHeight: '1.25'
            }}
            required 
          />
        </div>
        
        <div style={{ marginBottom: '1rem' }}>
          <label style={{
            display: 'block',
            color: '#374151',
            fontSize: '0.875rem',
            fontWeight: 'bold',
            marginBottom: '0.5rem'
          }}>Email</label>
          <input 
            name="email" 
            value={formData.email} 
            onChange={handleChange} 
            type="email" 
            style={{
              boxShadow: '0 1px 2px 0 rgba(0, 0, 0, 0.05)',
              border: '1px solid #d1d5db',
              borderRadius: '0.375rem',
              width: '100%',
              padding: '0.5rem 0.75rem',
              color: '#374151',
              lineHeight: '1.25'
            }}
            required 
          />
        </div>
        
        <div style={{ marginBottom: '1.5rem' }}>
          <label style={{
            display: 'block',
            color: '#374151',
            fontSize: '0.875rem',
            fontWeight: 'bold',
            marginBottom: '0.5rem'
          }}>Password</label>
          <input 
            name="password" 
            value={formData.password} 
            onChange={handleChange} 
            type="password" 
            style={{
              boxShadow: '0 1px 2px 0 rgba(0, 0, 0, 0.05)',
              border: '1px solid #d1d5db',
              borderRadius: '0.375rem',
              width: '100%',
              padding: '0.5rem 0.75rem',
              color: '#374151',
              lineHeight: '1.25'
            }}
            required 
          />
        </div>
        
        {error && <div style={{
          marginBottom: '1rem',
          color: '#ef4444',
          fontSize: '0.875rem'
        }}>{error}</div>}
        
        <button 
          type="submit" 
          disabled={loading} 
          style={{
            width: '100%',
            backgroundColor: loading ? '#9ca3af' : '#2563eb',
            color: 'white',
            fontWeight: 'bold',
            padding: '0.5rem 1rem',
            borderRadius: '0.375rem',
            border: 'none',
            cursor: loading ? 'not-allowed' : 'pointer',
            transition: 'background-color 0.2s'
          }}
          onMouseOver={(e) => !loading && (e.target.style.backgroundColor = '#1d4ed8')}
          onMouseOut={(e) => !loading && (e.target.style.backgroundColor = '#2563eb')}
        >
          {loading ? "Registering..." : "Register"}
        </button>
        
        <div style={{
          marginTop: '1rem',
          textAlign: 'center',
          fontSize: '0.875rem',
          color: '#6b7280'
        }}>
          Already have an account? <Link 
            to="/login" 
            style={{
              color: '#2563eb',
              textDecoration: 'underline'
            }}
            onMouseOver={(e) => e.target.style.color = '#1d4ed8'}
            onMouseOut={(e) => e.target.style.color = '#2563eb'}
          >Sign in</Link>
        </div>
      </form>
    </div>
  )
}
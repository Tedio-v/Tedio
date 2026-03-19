import React, { useState, useEffect } from 'react'
import NavBar from '../components/NavBar.jsx'
import { authService } from '../services/auth.js'
import config from '../config/env.js'
import './settings.css'

export default function Settings() {
  const [currentUser, setCurrentUser] = useState({})
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [childName, setChildName] = useState('')
  const [childAge, setChildAge] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  const API_BASE = config.API_ENDPOINT

  // Load current user settings on component mount
  useEffect(() => {
    const loadUserSettings = async () => {
      try {
        const response = await fetch(`${API_BASE}/settings`, {
          headers: {
            'Authorization': `Bearer ${authService.getToken()}`
          }
        })
        if (response.ok) {
          const settings = await response.json()
          setCurrentUser(settings)
        } else {
          console.error('Failed to load user settings')
        }
      } catch (err) {
        console.error('Error loading settings:', err)
      }
    }
    
    loadUserSettings()
  }, [])

  const updateUser = async (field, value) => {
    setLoading(true)
    setError('')
    
    try {
      const response = await fetch(`${API_BASE}/settings`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${authService.getToken()}`
        },
        body: JSON.stringify({ [field]: value })
      })
      
      if (response.ok) {
        // Update local state
        setCurrentUser(prev => ({ ...prev, [field]: value }))
        // Clear the input field
        if (field === 'email') setEmail('')
        if (field === 'password') setPassword('')
        if (field === 'child_name') setChildName('')
        if (field === 'child_age') setChildAge('')
        alert('Updated successfully!')
      } else {
        const errorData = await response.json()
        setError(errorData.error || 'Update failed')
      }
    } catch (err) {
      setError('Network error occurred')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="settings">
      <NavBar />

      <main className="settings-main">
        <button className="btn-back" onClick={() => window.history.back()}>Back</button>

        <h1 className="settings-title">Settings</h1>

        {error && (
          <div className="error-message" style={{ 
            color: 'red', 
            margin: '10px 0', 
            padding: '10px', 
            backgroundColor: '#fee', 
            borderRadius: '4px' 
          }}>
            {error}
          </div>
        )}

        <section className="setting-group">
          <div className="setting-label">Email</div>
          <div className="setting-value">{currentUser?.email || '—'}</div>
          <div className="setting-row">
            <input className="setting-input" type="email" placeholder="New email" value={email} onChange={(e) => setEmail(e.target.value)} />
            <button className="btn-update" disabled={loading || !email} onClick={() => email && updateUser('email', email)}>
              {loading ? 'Updating...' : 'Update'}
            </button>
          </div>
        </section>

        <section className="setting-group">
          <div className="setting-label">Password</div>
          <div className="setting-value">********</div>
          <div className="setting-row">
            <input className="setting-input" type="password" placeholder="New password" value={password} onChange={(e) => setPassword(e.target.value)} />
            <button className="btn-update" disabled={loading || !password} onClick={() => password && updateUser('password', password)}>
              {loading ? 'Updating...' : 'Update'}
            </button>
          </div>
        </section>

        <section className="setting-group">
          <div className="setting-label">Child's Name</div>
          <div className="setting-value">{currentUser?.child_name || '—'}</div>
          <div className="setting-row">
            <input className="setting-input" type="text" placeholder="New name" value={childName} onChange={(e) => setChildName(e.target.value)} />
            <button className="btn-update" disabled={loading || !childName} onClick={() => childName && updateUser('child_name', childName)}>
              {loading ? 'Updating...' : 'Update'}
            </button>
          </div>
        </section>

        <section className="setting-group">
          <div className="setting-label">Child's Age</div>
          <div className="setting-value">{currentUser?.child_age ?? '—'}</div>
          <div className="setting-row">
            <input className="setting-input" type="number" min="0" placeholder="New age" value={childAge} onChange={(e) => setChildAge(e.target.value)} />
            <button className="btn-update" disabled={loading || !childAge} onClick={() => childAge && updateUser('child_age', Number(childAge))}>
              {loading ? 'Updating...' : 'Update'}
            </button>
          </div>
        </section>

        <div className="setting-actions">
          <button className="btn-logout" onClick={() => { authService.logout(); window.location.href = '/'; }}>Log Out</button>
        </div>
      </main>
    </div>
  )
} 
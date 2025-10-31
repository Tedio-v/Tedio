// ABOUTME: Simple authentication component with login and registration forms
// ABOUTME: Based on tedio auth page design with toggle between login/register modes

import { useState } from 'react'
import { authService } from '../services/auth.js'
import './SimpleAuth.css'

export default function SimpleAuth({ onAuthSuccess }) {
  const [isRegister, setIsRegister] = useState(false)
  const [form, setForm] = useState({ child_name: "", child_age: "", email: "", password: "" })
  const [error, setError] = useState("")
  const [success, setSuccess] = useState("")
  const [loading, setLoading] = useState(false)

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value })
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError("")
    setSuccess("")
    setLoading(true)
    
    try {
      if (isRegister) {
        await authService.register(form)
        // After successful registration, switch to login mode
        setIsRegister(false)
        setForm({ child_name: "", child_age: "", email: form.email, password: "" }) // Keep email but clear password
        setError("") // Clear any errors
        // Show success message briefly
        setSuccess("Registration successful! Please log in with your credentials.")
      } else {
        await authService.login(form.email, form.password)
        onAuthSuccess?.()
      }
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="auth">
      <div className="auth__header">
        <div className="auth__brand">
          <img src="/brand/Tedio.logo.png" alt="Tedio" />
          <span>Tedio</span>
        </div>
      </div>

      <main className="auth__main">
        <form className="auth__card" onSubmit={handleSubmit}>
          <h2 className="auth__title">{isRegister ? 'Create your account' : 'Welcome back'}</h2>
          <div className="auth__subtitle">{isRegister ? 'Join Tedio to get started' : 'Sign in to your account'}</div>

          {isRegister && (
            <>
              <div className="auth__field">
                <label className="auth__label">Child's Name</label>
                <input className="auth__input" name="child_name" value={form.child_name} onChange={handleChange} required />
              </div>
              <div className="auth__field">
                <label className="auth__label">Child's Age</label>
                <input className="auth__input" name="child_age" value={form.child_age} onChange={handleChange} type="number" min="1" required />
              </div>
            </>
          )}

          <div className="auth__field">
            <label className="auth__label">Email</label>
            <input className="auth__input" name="email" value={form.email} onChange={handleChange} type="email" required />
          </div>

          <div className="auth__field" style={{ marginBottom: '1.1rem' }}>
            <label className="auth__label">Password</label>
            <input className="auth__input" name="password" value={form.password} onChange={handleChange} type="password" required />
          </div>

          {error && <div className="auth__error">{error}</div>}
          {success && <div className="auth__success">{success}</div>}

          <button type="submit" disabled={loading} className="auth__submit">
            {loading ? (isRegister ? 'Registering...' : 'Signing in...') : (isRegister ? 'Register' : 'Sign In')}
          </button>

          <div className="auth__footer">
            {isRegister ? (
              <>Already have an account? <button type="button" className="auth__pointer" onClick={() => { setIsRegister(false); setError(""); setSuccess("") }}>Sign in</button></>
            ) : (
              <>Don&apos;t have an account? <button type="button" className="auth__pointer" onClick={() => { setIsRegister(true); setError(""); setSuccess("") }}>
                Sign up
                <svg viewBox="0 0 20 20" fill="currentColor" aria-hidden="true"><path d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707A1 1 0 118.707 5.293l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z"/></svg>
              </button></>
            )}
          </div>
        </form>
      </main>
    </div>
  )
}
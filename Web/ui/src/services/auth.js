// ABOUTME: Authentication service for handling login, registration, and token management
// ABOUTME: Provides API calls and token storage for user authentication

import config from '../config/env.js'

const API_BASE = config.API_ENDPOINT

class AuthService {
  constructor() {
    this.token = localStorage.getItem('token')
  }

  async register(userData) {
    const response = await fetch(`${API_BASE}/auth/register`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(userData),
    })

    if (!response.ok) {
      const error = await response.json().catch(() => ({}))
      throw new Error(error.error || 'Registration failed')
    }

    return response.json()
  }

  async login(email, password) {
    const response = await fetch(`${API_BASE}/auth/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ email, password }),
    })

    if (!response.ok) {
      const error = await response.json().catch(() => ({}))
      throw new Error(error.error || 'Login failed')
    }

    const data = await response.json()
    this.token = data.token
    localStorage.setItem('token', data.token)
    localStorage.setItem('user', JSON.stringify(data.user))

    return data
  }

  logout() {
    this.token = null
    localStorage.removeItem('token')
    localStorage.removeItem('user')
  }

  getToken() {
    return this.token || localStorage.getItem('token')
  }

  getUser() {
    const user = localStorage.getItem('user')
    return user ? JSON.parse(user) : null
  }

  isAuthenticated() {
    return !!this.getToken()
  }

  getAuthHeaders() {
    const token = this.getToken()
    return token ? { 'Authorization': `Bearer ${token}` } : {}
  }
}

export const authService = new AuthService()
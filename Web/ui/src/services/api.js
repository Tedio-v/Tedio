// ABOUTME: Main API service for handling all backend communications
// ABOUTME: Centralized service for insights, YouTube history, and other API calls

import { authService } from './auth.js'
import config from '../config/env.js'

const API_BASE = config.API_ENDPOINT

class ApiService {
  async makeAuthenticatedRequest(url, options = {}) {
    const headers = {
      'Content-Type': 'application/json',
      ...authService.getAuthHeaders(),
      ...options.headers,
    }

    const response = await fetch(url, {
      ...options,
      headers,
    })

    if (response.status === 401) {
      authService.logout()
      throw new Error('Authentication required')
    }

    if (!response.ok) {
      const error = await response.json().catch(() => ({ error: 'Request failed' }))
      throw new Error(error.error || `HTTP ${response.status}`)
    }

    return response.json()
  }

  // Insights API
  async getInsights() {
    return this.makeAuthenticatedRequest(`${API_BASE}/insights`)
  }

  async getInsight(insightId) {
    return this.makeAuthenticatedRequest(`${API_BASE}/insights/${insightId}`)
  }

  async generateInsights(watchHistory) {
    return this.makeAuthenticatedRequest(`${API_BASE}/insights/generate`, {
      method: 'POST',
      body: JSON.stringify(watchHistory),
    })
  }

  async submitInsightRating(insightId, rating, insightName) {
    return this.makeAuthenticatedRequest(`${API_BASE}/insights/${insightId}/rating`, {
      method: 'POST',
      body: JSON.stringify({
        importanceRating: rating,
        insightName,
      }),
    })
  }

  async getGlobalRatings() {
    const response = await fetch(`${API_BASE}/insights/global-ratings`)
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`)
    }
    return response.json()
  }

  async getInsightGlobalRating(insightName) {
    const response = await fetch(`${API_BASE}/insights/${encodeURIComponent(insightName)}/global-rating`)
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`)
    }
    return response.json()
  }

  // YouTube History API
  async uploadYouTubeHistory(historyData) {
    return this.makeAuthenticatedRequest(`${API_BASE}/youtube-history`, {
      method: 'POST',
      body: JSON.stringify(historyData),
    })
  }

  async getYouTubeHistory() {
    return this.makeAuthenticatedRequest(`${API_BASE}/youtube-history`)
  }

  async checkYouTubeHistoryStatus() {
    return this.makeAuthenticatedRequest(`${API_BASE}/youtube-history/status`)
  }

  // Users API (non-authenticated for now)
  async getUsers() {
    const response = await fetch(`${API_BASE}/users`)
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`)
    }
    return response.json()
  }

  // Authentication API
  async completeOnboarding() {
    return this.makeAuthenticatedRequest(`${API_BASE}/auth/complete-onboarding`, {
      method: 'POST'
    })
  }

  // Quick Actions API
  async completeQuickAction(actionId) {
    return this.makeAuthenticatedRequest(`${API_BASE}/quick-actions/complete`, {
      method: 'POST',
      body: JSON.stringify({ actionId })
    })
  }

  async uncompleteQuickAction(actionId) {
    return this.makeAuthenticatedRequest(`${API_BASE}/quick-actions/uncomplete`, {
      method: 'POST',
      body: JSON.stringify({ actionId })
    })
  }

  async getCompletedActions() {
    return this.makeAuthenticatedRequest(`${API_BASE}/quick-actions/completed`)
  }
}

export const apiService = new ApiService()
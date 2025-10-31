import { useCallback, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import YouTubeUpload from '../components/YouTubeUpload.jsx'
import { apiService } from '../services/api.js'
import NavBar from '../components/NavBar.jsx'
import './onboarding.css'

export default function Onboarding({ onComplete }) {
  const navigate = useNavigate()
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')

  const handleUploadSuccess = useCallback(async () => {
    try {
      setSuccess('Setup complete! Redirecting to your dashboard...')
      setError('')
      await apiService.completeOnboarding()
      onComplete?.()
      setTimeout(() => {
        navigate('/summary', { replace: true })
      }, 1500)
    } catch (e) {
      console.error('Error completing onboarding:', e)
      setError('Setup complete, but could not update user state. Redirecting...')
      setTimeout(() => {
        navigate('/summary', { replace: true })
      }, 2000)
    }
  }, [navigate, onComplete])

  return (
    <div className="onboarding-layout">
      <NavBar minimal />
      
      <main className="onboarding-main">
        <header className="onboarding-header">
          <h1 className="onboarding-title">Welcome to Tedio</h1>
          <p className="onboarding-description">
            Let's analyze your child's YouTube viewing history to generate personalized insights and recommendations.
          </p>
        </header>

        <div className="onboarding-video-container">
          <video controls className="onboarding-video">
            <source src="/videos/onboarding.mp4" type="video/mp4" />
            Your browser does not support the video tag.
          </video>
        </div>

        {error && (
          <div className="onboarding-callout onboarding-callout--error">
            {error}
          </div>
        )}

        {success && (
          <div className="onboarding-callout onboarding-callout--success">
            {success}
          </div>
        )}

        <YouTubeUpload onUploadSuccess={handleUploadSuccess} />
      </main>
      
      <footer className="onboarding-footer">
        <span>©2024 Tedio. All rights reserved.</span>
      </footer>
    </div>
  )
}




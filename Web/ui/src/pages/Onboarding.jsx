import { useCallback, useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { apiService } from '../services/api.js'
import NavBar from '../components/NavBar.jsx'
import './onboarding.css'

const STORAGE_KEY = 'tedio_onboarding_step'
const TAKEOUT_URL = 'https://takeout.google.com/settings/takeout/custom/youtube'

function StepIndicator({ current, total }) {
  return (
    <div className="wizard-progress">
      {Array.from({ length: total }, (_, i) => (
        <div key={i} className="wizard-progress-step">
          <div
            className={`wizard-dot ${i < current ? 'wizard-dot--done' : ''} ${i === current ? 'wizard-dot--active' : ''}`}
          >
            {i < current ? (
              <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
                <path d="M3 7l3 3 5-5" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            ) : (
              i + 1
            )}
          </div>
          {i < total - 1 && (
            <div className={`wizard-line ${i < current ? 'wizard-line--done' : ''}`} />
          )}
        </div>
      ))}
    </div>
  )
}

function StepWelcome({ onNext }) {
  return (
    <div className="wizard-step">
      <h2 className="wizard-step-title">Let's understand your child's YouTube habits</h2>
      <p className="wizard-step-desc">
        Tedio analyzes your child's YouTube viewing history to uncover patterns
        like late-night watching, rapid swiping, and Shorts binges — then gives you
        specific, actionable steps to help.
      </p>

      <div className="wizard-card">
        <h3 className="wizard-card-title">How it works</h3>
        <ol className="wizard-steps-list">
          <li>You download your child's YouTube data from Google (free, 2 minutes)</li>
          <li>You upload one file to Tedio</li>
          <li>We analyze the data and show you what we find</li>
        </ol>
      </div>

      <div className="wizard-card wizard-card--subtle">
        <p className="wizard-reassurance">
          Even a few weeks of data generates useful insights. You don't need months
          of history — upload whatever you have.
        </p>
      </div>

      <button className="wizard-btn wizard-btn--primary" onClick={onNext}>
        Let's get started
      </button>
    </div>
  )
}

function StepTakeout({ onNext, onBack }) {
  return (
    <div className="wizard-step">
      <h2 className="wizard-step-title">Download your child's YouTube data</h2>
      <p className="wizard-step-desc">
        Google Takeout lets you download a copy of your YouTube history.
        We've pre-filtered the link so you only download what's needed.
      </p>

      <div className="wizard-card">
        <h3 className="wizard-card-title">What to do</h3>
        <ol className="wizard-steps-list">
          <li>
            Sign into the Google account your child uses for YouTube
          </li>
          <li>
            Click the button below — it opens Google Takeout with YouTube already selected
          </li>
          <li>
            On the Takeout page, click <strong>"Next step"</strong>, then <strong>"Create export"</strong>
          </li>
          <li>
            Google will email you a download link (usually 2–30 minutes)
          </li>
        </ol>
      </div>

      <a
        href={TAKEOUT_URL}
        target="_blank"
        rel="noopener noreferrer"
        className="wizard-btn wizard-btn--primary wizard-btn--link"
      >
        Open Google Takeout
      </a>

      <details className="wizard-help">
        <summary>I'm stuck</summary>
        <div className="wizard-help-content">
          <p><strong>Not sure which Google account?</strong> Open YouTube on your child's device, tap the profile icon in the top right — the email shown there is the account to use.</p>
          <p><strong>Multiple children share an account?</strong> That's fine — upload the file and we'll analyze whatever data is there.</p>
          <p><strong>Can't access the account?</strong> If your child uses a supervised account through Family Link, sign in as the parent and access Takeout from the child's account.</p>
        </div>
      </details>

      <div className="wizard-nav">
        <button className="wizard-btn wizard-btn--secondary" onClick={onBack}>Back</button>
        <button className="wizard-btn wizard-btn--primary" onClick={onNext}>
          I've started the export
        </button>
      </div>
    </div>
  )
}

function StepWaiting({ onNext, onBack }) {
  return (
    <div className="wizard-step">
      <h2 className="wizard-step-title">Waiting for your file</h2>
      <p className="wizard-step-desc">
        Google is preparing your download. You'll get an email with a link when it's ready —
        usually within 2–30 minutes.
      </p>

      <div className="wizard-card">
        <h3 className="wizard-card-title">While you wait</h3>
        <p style={{ margin: 0, color: 'var(--text-secondary)' }}>
          You can close this tab. When you come back, we'll pick up right where you left off.
        </p>
      </div>

      <div className="wizard-card">
        <h3 className="wizard-card-title">Once you get the email</h3>
        <ol className="wizard-steps-list">
          <li>Click the download link in Google's email</li>
          <li>Unzip the downloaded file</li>
          <li>
            Find this file inside:
            <code className="wizard-filepath">
              Takeout / YouTube and YouTube Music / history / watch-history.json
            </code>
          </li>
        </ol>
      </div>

      <details className="wizard-help">
        <summary>I'm stuck</summary>
        <div className="wizard-help-content">
          <p><strong>Haven't received the email?</strong> Check your spam folder. Google Takeout emails come from <em>no-reply@accounts.google.com</em>. Large exports can take up to an hour.</p>
          <p><strong>Can't find watch-history.json?</strong> After unzipping, look for a folder called "Takeout". Inside it, navigate to YouTube and YouTube Music then history. The file is called <em>watch-history.json</em>.</p>
          <p><strong>File is called something else?</strong> Make sure you're looking at the history folder, not subscriptions or playlists. The file must end in <em>.json</em>, not <em>.html</em>.</p>
        </div>
      </details>

      <div className="wizard-nav">
        <button className="wizard-btn wizard-btn--secondary" onClick={onBack}>Back</button>
        <button className="wizard-btn wizard-btn--primary" onClick={onNext}>
          I have the file
        </button>
      </div>
    </div>
  )
}

function StepUpload({ onBack, onUploadSuccess }) {
  const [uploading, setUploading] = useState(false)
  const [error, setError] = useState('')
  const [progress, setProgress] = useState('')
  const [dragActive, setDragActive] = useState(false)

  const processFile = async (file) => {
    if (!file) return
    if (!file.name.endsWith('.json')) {
      setError('Please upload a .json file. The file should be called watch-history.json.')
      return
    }

    setUploading(true)
    setError('')
    setProgress('Reading file...')

    try {
      const text = await file.text()
      let historyData

      try {
        historyData = JSON.parse(text)
      } catch {
        throw new Error('This doesn\'t look like a valid JSON file. Make sure you\'re uploading watch-history.json from your Google Takeout download.')
      }

      if (!Array.isArray(historyData)) {
        throw new Error('This file doesn\'t contain YouTube history data. It should be watch-history.json from Google Takeout.')
      }

      setProgress(`Uploading ${historyData.length.toLocaleString()} videos...`)
      await apiService.uploadYouTubeHistory(historyData)

      setProgress('Analyzing viewing patterns...')
      await apiService.generateInsights(historyData)

      setProgress('Done! Redirecting to your dashboard...')
      onUploadSuccess?.()
    } catch (err) {
      setError(err.message)
      setProgress('')
    } finally {
      setUploading(false)
    }
  }

  const handleFileInput = (e) => processFile(e.target.files[0])

  const handleDrop = (e) => {
    e.preventDefault()
    setDragActive(false)
    processFile(e.dataTransfer.files[0])
  }

  const handleDrag = (e) => {
    e.preventDefault()
    setDragActive(e.type === 'dragenter' || e.type === 'dragover')
  }

  return (
    <div className="wizard-step">
      <h2 className="wizard-step-title">Upload your file</h2>
      <p className="wizard-step-desc">
        Drop your <strong>watch-history.json</strong> file here and we'll do the rest.
      </p>

      <div
        className={`wizard-dropzone ${dragActive ? 'wizard-dropzone--active' : ''} ${uploading ? 'wizard-dropzone--uploading' : ''}`}
        onDragEnter={handleDrag}
        onDragLeave={handleDrag}
        onDragOver={handleDrag}
        onDrop={handleDrop}
      >
        {uploading ? (
          <div className="wizard-upload-progress">
            <div className="wizard-spinner" />
            <p>{progress}</p>
          </div>
        ) : (
          <>
            <div className="wizard-dropzone-icon">
              <svg width="48" height="48" viewBox="0 0 48 48" fill="none">
                <path d="M24 32V16m0 0l-8 8m8-8l8 8" stroke="var(--navy)" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/>
                <path d="M8 32v4a4 4 0 004 4h24a4 4 0 004-4v-4" stroke="var(--navy)" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            </div>
            <p className="wizard-dropzone-text">
              Drag and drop <strong>watch-history.json</strong> here
            </p>
            <label className="wizard-btn wizard-btn--secondary wizard-file-label">
              Or choose file
              <input
                type="file"
                accept=".json"
                onChange={handleFileInput}
                disabled={uploading}
                style={{ display: 'none' }}
              />
            </label>
          </>
        )}
      </div>

      {error && (
        <div className="onboarding-callout onboarding-callout--error">
          {error}
        </div>
      )}

      <div className="wizard-nav">
        <button className="wizard-btn wizard-btn--secondary" onClick={onBack} disabled={uploading}>
          Back
        </button>
      </div>
    </div>
  )
}

export default function Onboarding({ onComplete }) {
  const navigate = useNavigate()
  const [step, setStep] = useState(() => {
    const saved = localStorage.getItem(STORAGE_KEY)
    return saved ? Math.min(parseInt(saved, 10), 3) : 0
  })

  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, String(step))
  }, [step])

  const handleUploadSuccess = useCallback(async () => {
    try {
      await apiService.completeOnboarding()
      onComplete?.()
    } catch (e) {
      console.error('Error completing onboarding:', e)
    }
    localStorage.removeItem(STORAGE_KEY)
    setTimeout(() => {
      navigate('/summary', { replace: true })
    }, 1500)
  }, [navigate, onComplete])

  const goNext = () => setStep((s) => Math.min(s + 1, 3))
  const goBack = () => setStep((s) => Math.max(s - 1, 0))

  return (
    <div className="onboarding-layout">
      <NavBar minimal />

      <main className="onboarding-main">
        <StepIndicator current={step} total={4} />

        {step === 0 && <StepWelcome onNext={goNext} />}
        {step === 1 && <StepTakeout onNext={goNext} onBack={goBack} />}
        {step === 2 && <StepWaiting onNext={goNext} onBack={goBack} />}
        {step === 3 && <StepUpload onBack={goBack} onUploadSuccess={handleUploadSuccess} />}
      </main>

      <footer className="onboarding-footer">
        <span>Tedio. All rights reserved.</span>
      </footer>
    </div>
  )
}

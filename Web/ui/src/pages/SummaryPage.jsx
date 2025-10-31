import { useState, useEffect, useMemo } from 'react'
import { apiService } from '../services/api.js'
import { authService } from '../services/auth.js'
import './summary.css'
import NavBar from '../components/NavBar.jsx'

function SeverityBadge({ level }) {
  const color = level === 'high' ? '#dc2626' : level === 'moderate' ? '#d97706' : '#16a34a'
  const bgColor = level === 'high' ? '#fee2e2' : level === 'moderate' ? '#fef3c7' : '#dcfce7'
  return (
    <span 
      style={{ 
        display: 'inline-block',
        padding: '2px 6px',
        borderRadius: '4px',
        fontSize: '11px',
        fontWeight: '500',
        textTransform: 'capitalize',
        color,
        backgroundColor: bgColor,
        border: `1px solid ${color}20`
      }}
    >
      {level}
    </span>
  )
}

function InsightTile({ title, imageSrc, severity }) {
  return (
    <div className="insight-item">
      <div className="insight-tile" title={title}>
        <img
          className="insight-img"
          src={imageSrc}
          alt={title}
          loading="lazy"
          onError={(e) => {
            e.currentTarget.src = '/vite.svg'
          }}
        />
        {severity && (
          <div style={{ 
            position: 'absolute', 
            top: '8px', 
            right: '8px' 
          }}>
            <SeverityBadge level={severity} />
          </div>
        )}
      </div>
    </div>
  )
}

export default function SummaryPage() {
  const [insights, setInsights] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [hasUploadedHistory, setHasUploadedHistory] = useState(true)

  const fetchInsights = async () => {
    try {
      setError('')
      setLoading(true)
      const data = await apiService.getInsights()
      const filtered = Array.isArray(data)
        ? data.filter(i => i?.name !== 'Content Category Balance' && i?.name !== 'Single-Channel Reliance')
        : []
      setInsights(filtered)
    } catch (err) {
      setError(err.message)
      console.error('Error fetching insights:', err)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    if (authService.isAuthenticated()) {
      const user = authService.getUser()
      // Check if user has uploaded history (first_login will be false after upload)
      setHasUploadedHistory(!user?.first_login)
      fetchInsights()
    } else {
      setLoading(false)
      setError('Please log in to view insights')
    }
  }, [])

  const summaryLine = useMemo(() => {
    const user = authService.getUser()
    const name = user?.child_name || (user?.email ? user.email.split('@')[0] : 'your child')
    const rsi = insights.find(i => i?.name?.includes('Rapid Swipe'))
    const ladder = insights.find(i => i?.name?.includes('Short-Ladder'))
    
    // Extract Shorts minutes from Short-Ladder Load insight message
    const ladderMinutes = (() => {
      const msg = ladder?.message || ''
      const m = msg.match(/(\d+(?:\.\d+)?)\s*min/i)
      return m ? Math.round(parseFloat(m[1])) : null
    })()

    // Calculate total viewing hours from insights data
    const totalHours = (() => {
      // Use the total_watch_minutes field from any insight (they all have the same value)
      const insightWithTotal = insights.find(i => i.total_watch_minutes != null)
      if (insightWithTotal && insightWithTotal.total_watch_minutes > 0) {
        // Convert total minutes to average hours per day (assuming ~3 weeks of data)
        const totalMinutes = insightWithTotal.total_watch_minutes
        const avgHoursPerDay = totalMinutes / (60 * 21) // 3 weeks = 21 days
        return avgHoursPerDay.toFixed(1)
      }
      return null
    })()

    const parts = []
    parts.push(`Over the past 3 weeks, ${name} watched YouTube`)
    
    // Add total viewing hours if available
    if (totalHours) {
      parts.push(`an average of ${totalHours} hours per day —`)
    }
    
    // Add Shorts info if available
    if (ladderMinutes != null) {
      parts.push(`including about ${ladderMinutes} minutes of Shorts, and`)
    }
    
    const rsiPart = rsi ? `Rapid-Swipe Index (${Math.round(rsi.matchScore)}%)` : null
    const ladderPart = ladder ? `Short-Ladder Load (${Math.round(ladder.matchScore)}%)` : null
    const metrics = [rsiPart, ladderPart].filter(Boolean).join(' and ')
    
    if (metrics) {
      parts.push(`showed a high ${metrics} — both flagged for your attention.`)
    }
    
    return parts.join(' ')
  }, [insights])

  const getInsightImage = (insightName) => {
    const imageMap = {
      'Rapid Swipe': '/insights/insight1.png',
      'Short-Ladder': '/insights/insight2.png', 
      'Late-Night': '/insights/insight3.png',
      'Thumbnail-Roulette': '/insights/insight4.png',
      'Content Category': '/insights/insight5.png'
    }
    
    const matchedKey = Object.keys(imageMap).find(key => insightName.includes(key))
    return matchedKey ? imageMap[matchedKey] : '/insights/insight1.png'
  }

  const staticInsights = useMemo(
    () => [
      { key: 'insight-1', title: 'Rapid-Swipe Taste Test', imageSrc: '/insights/insight1.png' },
      { key: 'insight-2', title: 'Endless Shorts Ladder', imageSrc: '/insights/insight2.png' },
      { key: 'insight-3', title: 'Late-Night Minutes', imageSrc: '/insights/insight3.png' },
      { key: 'insight-4', title: 'Thumbnail Roulette', imageSrc: '/insights/insight4.png' },
    ],
    [],
  )

  const renderUploadBanner = () => (
    <section className="summary-callout" style={{
      background: 'linear-gradient(135deg, #e0f2fe 0%, #dbeafe 100%)',
      border: '2px solid #3b82f6',
      padding: '1.5rem',
      marginBottom: '2rem'
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
        <div style={{ fontSize: '2.5rem' }}>📊</div>
        <div style={{ flex: 1 }}>
          <h3 style={{ margin: 0, marginBottom: '0.5rem', fontSize: '1.25rem', fontWeight: 'bold', color: '#1e40af' }}>
            Upload YouTube History
          </h3>
          <p style={{ margin: 0, color: '#1e40af', fontSize: '0.95rem' }}>
            Get personalized insights about viewing patterns
          </p>
        </div>
        <a
          href="/onboarding"
          style={{
            display: 'inline-block',
            backgroundColor: '#2563eb',
            color: 'white',
            padding: '0.625rem 1.25rem',
            borderRadius: '0.5rem',
            textDecoration: 'none',
            fontWeight: 'bold',
            fontSize: '0.95rem',
            whiteSpace: 'nowrap'
          }}
          onMouseOver={(e) => e.target.style.backgroundColor = '#1d4ed8'}
          onMouseOut={(e) => e.target.style.backgroundColor = '#2563eb'}
        >
          Upload Now →
        </a>
      </div>
    </section>
  )

  return (
    <div className="summary-layout">
      <NavBar />

      <main className="summary-main">
        <h1 className="summary-title">
          {hasUploadedHistory ? "What We Noticed From Your Child's Watch History" : "Dashboard"}
        </h1>

        {/* Show upload banner when no data */}
        {!hasUploadedHistory && renderUploadBanner()}

        {/* Show analytics summary when has data */}
        {hasUploadedHistory && (
          <section className="summary-callout">
            {loading && <p>Loading insights...</p>}
            {error && <p style={{ color: 'red' }}>Error: {error}</p>}
            {!loading && !error && insights.length === 0 && (
              <p>No insights available yet.</p>
            )}
            {!loading && !error && insights.length > 0 && (
              <p>{summaryLine}</p>
            )}
          </section>
        )}

        {/* Always show 4 clue cards */}
        <section className="insight-row" role="list">
          {loading ? (
            <p>Loading insights...</p>
          ) : hasUploadedHistory && insights.length > 0 ? (
            // Show real insights when data available
            insights.map((insight) => (
              <a key={insight._id} href={`/insight/${insight._id}`} style={{ textDecoration: 'none', color: 'inherit' }}>
                <InsightTile
                  title={insight.name}
                  imageSrc={getInsightImage(insight.name)}
                  severity={insight.severity}
                />
              </a>
            ))
          ) : (
            // Show static placeholder cards when no data
            staticInsights.map((c) => (
              <a key={c.key} href={`/insight/${c.key}`} style={{ textDecoration: 'none', color: 'inherit' }}>
                <InsightTile {...c} />
              </a>
            ))
          )}
        </section>
      </main>

      <footer className="summary-footer">
        <a>Terms of Service</a>
        <a>Privacy Policy</a>
        <a>Contact Us</a>
        <span>©2024 Tedio. All rights reserved.</span>
      </footer>
    </div>
  )
}


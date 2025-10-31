import { useEffect, useMemo, useState } from 'react'
import NavBar from '../components/NavBar.jsx'
import { apiService } from '../services/api.js'
import { authService } from '../services/auth.js'
import './summary.css'

function SeverityBadge({ level }) {
  const color = level === 'high' ? '#dc2626' : level === 'moderate' ? '#d97706' : '#16a34a'
  return (
    <span className="badge" style={{ borderColor: 'rgba(0,0,0,0.08)', color }}>{level}</span>
  )
}

function SparkBar({ values = [] }) {
  if (!Array.isArray(values) || values.length === 0) return null
  const max = Math.max(...values)
  return (
    <div style={{ display: 'flex', gap: 6, alignItems: 'flex-end', height: 48 }}>
      {values.map((v, idx) => (
        <div key={idx} style={{ width: 14, height: Math.max(6, (v / (max || 1)) * 48), background: '#c7d2fe', borderRadius: 3 }} />
      ))}
    </div>
  )
}

function generateWeeklyInsights(percentages, days) {
  const insights = []
  
  // Find peak day
  const maxIndex = percentages.indexOf(Math.max(...percentages))
  const maxPercentage = Math.round(percentages[maxIndex])
  
  // Weekend vs weekday analysis
  const weekendTotal = Math.round(percentages[0] + percentages[6]) // Sun + Sat
  const weekdayTotal = Math.round(percentages.slice(1, 6).reduce((sum, pct) => sum + pct, 0))
  
  // School day pattern (Mon-Fri)
  const schoolDays = percentages.slice(1, 6)
  const avgSchoolDay = Math.round(schoolDays.reduce((sum, pct) => sum + pct, 0) / 5)
  
  // Peak day insight
  if (maxPercentage >= 25) {
    insights.push(`📊 ${days[maxIndex]} is the heaviest viewing day with ${maxPercentage}% of total screen time`)
  } else if (maxPercentage >= 20) {
    insights.push(`📈 Peak viewing occurs on ${days[maxIndex]} (${maxPercentage}% of weekly time)`)
  }
  
  // Weekend vs weekday comparison
  if (weekendTotal > weekdayTotal * 0.5) {
    insights.push(`🏠 Weekend viewing (${weekendTotal}%) suggests flexible home schedule vs structured weekdays`)
  } else if (weekdayTotal > weekendTotal * 2) {
    insights.push(`🎒 School days dominate viewing time (${weekdayTotal}% vs ${weekendTotal}% weekends)`)
  }
  
  // Pattern recognition
  const isEvenlyDistributed = Math.max(...percentages) - Math.min(...percentages) < 10
  if (isEvenlyDistributed) {
    insights.push(`⚖️ Very consistent daily viewing pattern across the week`)
  }
  
  // Friday analysis
  const fridayPct = Math.round(percentages[5])
  if (fridayPct >= 20) {
    insights.push(`🎉 Friday shows high screen time (${fridayPct}%) - typical end-of-week relaxation`)
  }
  
  // Return max 2 insights
  return insights.slice(0, 2)
}

function WeeklyPattern({ values = [] }) {
  if (!Array.isArray(values) || values.length === 0) return null
  
  const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
  const totalMinutes = values.reduce((sum, val) => sum + val, 0)
  
  // Convert to percentages
  const percentages = values.map(val => totalMinutes > 0 ? (val / totalMinutes) * 100 : 0)
  const maxPercentage = Math.max(...percentages, 1)
  
  // Generate insights
  const insights = generateWeeklyInsights(percentages, days)
  
  // SVG dimensions
  const width = 400
  const height = 120
  const padding = 40
  const chartWidth = width - (padding * 2)
  const chartHeight = height - (padding * 2)
  
  // Calculate points for line chart
  const points = percentages.map((pct, i) => {
    const x = padding + (i * chartWidth / 6)
    const y = padding + chartHeight - (pct / maxPercentage) * chartHeight
    return { x, y, pct: Math.round(pct) }
  })
  
  // Create path string for line
  const pathData = points.map((point, i) => 
    `${i === 0 ? 'M' : 'L'} ${point.x} ${point.y}`
  ).join(' ')

  return (
    <section className="summary-callout" style={{ marginTop: 18 }}>
      <h3 style={{ margin: '0 0 12px 0' }}>Weekly Viewing Distribution</h3>
      
      {/* Line Chart */}
      <div style={{ display: 'flex', justifyContent: 'center', marginBottom: 16 }}>
        <svg width={width} height={height} style={{ background: '#f8fafc', borderRadius: 8 }}>
          {/* Grid lines */}
          {[0, 25, 50, 75, 100].map(pct => {
            const y = padding + chartHeight - (pct / maxPercentage) * chartHeight
            return (
              <line 
                key={pct} 
                x1={padding} 
                y1={y} 
                x2={width - padding} 
                y2={y} 
                stroke="#e2e8f0" 
                strokeWidth="1"
              />
            )
          })}
          
          {/* Line */}
          <path 
            d={pathData} 
            fill="none" 
            stroke="#3b82f6" 
            strokeWidth="3" 
            strokeLinecap="round"
            strokeLinejoin="round"
          />
          
          {/* Data points */}
          {points.map((point, i) => (
            <g key={i}>
              <circle 
                cx={point.x} 
                cy={point.y} 
                r="4" 
                fill="#3b82f6" 
                stroke="#fff" 
                strokeWidth="2"
              />
              {/* Day labels */}
              <text 
                x={point.x} 
                y={height - 10} 
                textAnchor="middle" 
                fontSize="11" 
                fill="#64748b"
              >
                {days[i]}
              </text>
              {/* Percentage labels */}
              <text 
                x={point.x} 
                y={point.y - 10} 
                textAnchor="middle" 
                fontSize="10" 
                fill="#0f172a"
                fontWeight="600"
              >
                {point.pct}%
              </text>
            </g>
          ))}
        </svg>
      </div>

      {/* Insights */}
      <div style={{ display: 'grid', gap: 8 }}>
        {insights.map((insight, i) => (
          <div key={i} style={{ 
            fontSize: 13, 
            color: '#475569', 
            padding: '8px 12px', 
            background: '#f1f5f9', 
            borderRadius: 6,
            borderLeft: '3px solid #3b82f6'
          }}>
            {insight}
          </div>
        ))}
      </div>
      
      <div style={{ fontSize: 11, color: '#94a3b8', marginTop: 8, textAlign: 'center' }}>
        Total: {totalMinutes} minutes across the week
      </div>
    </section>
  )
}

function getInsightDescription(insightName, matchScore) {
  const score = Math.round(matchScore)
  
  if (insightName.includes('Rapid Swipe')) {
    if (score >= 70) return `High tendency to quickly skip through videos without engaging with content. This may indicate difficulty focusing or overstimulation.`
    if (score >= 35) return `Moderate quick-swiping behavior detected. Some videos are being skipped rapidly, which could reduce content absorption.`
    return `Low levels of rapid video skipping. Content engagement appears healthy with adequate viewing time per video.`
  }
  
  if (insightName.includes('Short-Ladder')) {
    if (score >= 50) return `Significant portion of viewing time spent in binge-watching sessions of short content. This pattern can be highly addictive.`
    if (score >= 20) return `Some binge-watching patterns detected with short-form content. Consider introducing viewing breaks to prevent habit formation.`
    return `Minimal binge-watching of short content. Viewing patterns show good self-regulation and variety.`
  }
  
  if (insightName.includes('Late-Night')) {
    if (score >= 15) return `Regular screen time extending past appropriate bedtime hours. This can significantly impact sleep quality and development.`
    if (score >= 5) return `Occasional late-night viewing detected. Consider establishing stricter bedtime routines to protect sleep schedules.`
    return `Minimal late-night screen use. Good adherence to healthy bedtime boundaries is maintained.`
  }
  
  if (insightName.includes('Single-Channel')) {
    if (score >= 71) return `Heavy reliance on one content creator or channel. This limits exposure to diverse perspectives and learning opportunities.`
    if (score >= 51) return `Moderate focus on specific channels. Consider encouraging exploration of varied content to broaden interests.`
    return `Good variety in content sources. Exposure to diverse creators and topics supports well-rounded digital consumption.`
  }
  
  if (insightName.includes('Thumbnail-Roulette')) {
    if (score >= 10) return `Frequent rapid channel-hopping behavior detected. This pattern often indicates restlessness or difficulty finding satisfying content.`
    if (score >= 2) return `Some thumbnail browsing behavior present. Monitor for increasing patterns that might indicate content dissatisfaction.`
    return `Minimal thumbnail-hunting behavior. Content selection appears deliberate and satisfying.`
  }
  
  if (insightName.includes('Content Category')) {
    if (score >= 70) return `Very narrow content focus detected. Encourage exploration of educational, creative, or diverse topics to support balanced development.`
    if (score >= 35) return `Moderate content concentration. Consider introducing new categories to expand interests and learning opportunities.`
    return `Good content variety across multiple categories. Balanced exposure supports diverse skill development and interests.`
  }
  
  return `Analyzing viewing patterns to understand digital behavior and its potential impact on development.`
}

function getInsightContext(insightName) {
  if (insightName.includes('Rapid Swipe')) {
    return `Tracking video engagement duration • Healthy viewing: 30+ seconds per video`
  }
  
  if (insightName.includes('Short-Ladder')) {
    return `Monitoring binge-watching sessions • Recommended: Breaks every 20 minutes`
  }
  
  if (insightName.includes('Late-Night')) {
    return `Sleep hygiene monitoring • Recommended screen-off time: 1 hour before bed`
  }
  
  if (insightName.includes('Single-Channel')) {
    return `Content diversity tracking • Healthy range: 3-5 different channels daily`
  }
  
  if (insightName.includes('Thumbnail-Roulette')) {
    return `Channel-hopping behavior • Indicates content satisfaction levels`
  }
  
  if (insightName.includes('Content Category')) {
    return `Content balance analysis • Recommended: Mix of education, entertainment, and creativity`
  }
  
  return `Digital wellbeing analysis • Part of comprehensive viewing pattern assessment`
}

export default function Relevancy() {
  const [insights, setInsights] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [hasUploadedHistory, setHasUploadedHistory] = useState(true)

  useEffect(() => {
    const run = async () => {
      try {
        setError('')
        setLoading(true)
        const user = authService.getUser()
        // Check if user has uploaded history (first_login will be false after upload)
        setHasUploadedHistory(!user?.first_login)

        const data = await apiService.getInsights()
        // rank: severity first, then matchScore desc
        const severityRank = { high: 3, moderate: 2, low: 1 }
        const allowed = (data || []).filter(i =>
          i?.name?.includes('Rapid Swipe') ||
          i?.name?.includes('Short-Ladder') ||
          i?.name?.includes('Late-Night') ||
          i?.name?.includes('Thumbnail-Roulette')
        )
        const ranked = allowed.sort((a, b) => {
          const s = (severityRank[b.severity] || 0) - (severityRank[a.severity] || 0)
          if (s !== 0) return s
          return (b.matchScore || 0) - (a.matchScore || 0)
        })
        setInsights(ranked)
      } catch (e) {
        setError(e.message)
      } finally {
        setLoading(false)
      }
    }
    run()
  }, [])

  const user = authService.getUser()
  const name = user?.child_name || (user?.email ? user.email.split('@')[0] : 'your child')

  const renderUploadPrompt = () => (
    <main className="summary-main" style={{ maxWidth: 980 }}>
      <h1 className="summary-title" style={{ marginBottom: 8 }}>Relevancy Overview</h1>

      <section className="summary-callout" style={{
        background: 'linear-gradient(135deg, #e0f2fe 0%, #dbeafe 100%)',
        border: '2px solid #3b82f6',
        padding: '2rem'
      }}>
        <div style={{ textAlign: 'center', marginBottom: '1.5rem' }}>
          <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>🔒</div>
          <h2 style={{ marginBottom: '1rem', fontSize: '1.5rem', fontWeight: 'bold' }}>
            Upload YouTube History to Access Relevancy Analysis
          </h2>
          <p style={{ marginBottom: '1.5rem', color: '#1e40af' }}>
            Relevancy insights require your child's YouTube watch history to analyze viewing patterns and behavioral metrics.
          </p>
          <a
            href="/onboarding"
            style={{
              display: 'inline-block',
              backgroundColor: '#2563eb',
              color: 'white',
              padding: '0.75rem 1.5rem',
              borderRadius: '0.5rem',
              textDecoration: 'none',
              fontWeight: 'bold',
              fontSize: '1rem'
            }}
            onMouseOver={(e) => e.target.style.backgroundColor = '#1d4ed8'}
            onMouseOut={(e) => e.target.style.backgroundColor = '#2563eb'}
          >
            Upload YouTube History
          </a>
        </div>
      </section>

      <footer className="summary-footer" style={{ marginTop: '2rem' }}>
        <span>©2024 Tedio. All rights reserved.</span>
      </footer>
    </main>
  )

  // Show upload prompt if user hasn't uploaded history
  if (!hasUploadedHistory) {
    return (
      <div className="summary-layout">
        <NavBar />
        {renderUploadPrompt()}
      </div>
    )
  }

  return (
    <div className="summary-layout">
      <NavBar />
      <main className="summary-main" style={{ maxWidth: 980 }}>
        <h1 className="summary-title" style={{ marginBottom: 8 }}>Relevancy Overview</h1>
        <section className="summary-callout">
          {loading ? (
            <p>Loading…</p>
          ) : error ? (
            <p style={{ color: 'red' }}>{error}</p>
          ) : (
            <p>Insights are ranked by severity and behavioral detection scores for {name}. The percentage shows how much of {name}'s viewing behavior matches each pattern - higher percentages indicate stronger presence of that behavior.</p>
          )}
        </section>

        <div style={{ display: 'grid', gap: 12 }}>
          {insights.map((insight) => (
            <div key={insight._id} style={{ display: 'grid', gridTemplateColumns: '1fr 120px', gap: 16, alignItems: 'center', background: '#fff', padding: '14px 16px', borderRadius: 12, border: '1px solid rgba(0,0,0,0.06)' }}>
              <div>
                <div style={{ display: 'flex', gap: 8, alignItems: 'center', marginBottom: 6 }}>
                  <strong>{insight.name}</strong>
                  <SeverityBadge level={insight.severity} />
                </div>
                <div style={{ color: '#475569', fontSize: 14, marginBottom: 8 }}>{insight.message}</div>
                <div style={{ color: '#64748b', fontSize: 13, lineHeight: 1.4 }}>
                  {getInsightDescription(insight.name, insight.matchScore || insight.score_pct || 0)}
                </div>
                <div style={{ color: '#94a3b8', fontSize: 12, marginTop: 6 }}>
                  {getInsightContext(insight.name)}
                </div>
              </div>
              <div style={{ textAlign: 'center' }}>
                <div style={{ fontWeight: 700 }}>{Math.min(100, Math.max(0, Math.round(insight.matchScore || 0)))}%</div>
                <div style={{ fontSize: 11, color: '#475569', lineHeight: 1.2 }}>behavior<br/>detected</div>
              </div>
            </div>
          ))}
        </div>

        {insights.length > 0 && (
          <WeeklyPattern values={insights[0]?.spark || []} />
        )}
      </main>
      <footer className="summary-footer">
        <span>©2024 Tedio. All rights reserved.</span>
      </footer>
    </div>
  )
}



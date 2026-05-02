import { useState, useEffect } from 'react'
import { apiService } from '../services/api.js'
import { authService } from '../services/auth.js'
import './summary.css'
import NavBar from '../components/NavBar.jsx'

const TIER_LABELS = {
  educational: 'Educational',
  neutral: 'Neutral',
  junk: 'Junk',
}
const TIER_ORDER = ['educational', 'neutral', 'junk']
const TIER_CYCLE = { educational: 'neutral', neutral: 'junk', junk: 'educational' }

function GoodNewsCard({ summary, childName }) {
  const goodPct = Math.round(
    (summary.educational_pct || 0) + (summary.neutral_pct || 0)
  )
  const topChannels = summary._topGoodChannels || []

  return (
    <section className="good-news-card">
      <div className="good-news-pct">{goodPct}%</div>
      <h2 className="good-news-headline">good screen time</h2>
      <p className="good-news-sub">
        {childName}'s viewing is mostly age-appropriate content.
      </p>
      {topChannels.length > 0 && (
        <p className="good-news-channels">
          Top quality: {topChannels.map(c => c.name).join(', ')}
        </p>
      )}
    </section>
  )
}

function TierBadge({ tier }) {
  return (
    <span className={`tier-badge tier-${tier}`}>
      {TIER_LABELS[tier] || tier}
    </span>
  )
}

function ChannelRow({ channel, onOverride }) {
  const handleCycle = () => {
    const nextTier = TIER_CYCLE[channel.tier] || 'neutral'
    onOverride(channel.name, nextTier)
  }

  return (
    <div className="channel-row">
      <button
        className="channel-tier-btn"
        onClick={handleCycle}
        title="Tap to change tier"
      >
        <TierBadge tier={channel.tier} />
      </button>
      <span className="channel-name">{channel.name}</span>
      <span className="channel-minutes">{Math.round(channel.minutes)} min</span>
    </div>
  )
}

function ChannelBreakdown({ channels, onOverride }) {
  if (!channels || channels.length === 0) return null

  const grouped = {}
  for (const tier of TIER_ORDER) {
    grouped[tier] = channels.filter(c => c.tier === tier)
  }

  return (
    <section className="channel-breakdown">
      <h2 className="section-heading">Channel Breakdown</h2>
      {TIER_ORDER.map(tier =>
        grouped[tier].length > 0 ? (
          <div key={tier} className="tier-group">
            <h3 className="tier-group-label">
              <TierBadge tier={tier} />
              <span className="tier-group-count">{grouped[tier].length} channels</span>
            </h3>
            {grouped[tier].map(ch => (
              <ChannelRow
                key={ch.name}
                channel={ch}
                onOverride={onOverride}
              />
            ))}
          </div>
        ) : null
      )}
      <p className="channel-hint">Tap a badge to reclassify a channel.</p>
    </section>
  )
}

const INSIGHT_COLORS = [
  { bg: 'var(--melon)',      badge: 'var(--melon-ripe)' },
  { bg: 'var(--peach)',      badge: 'var(--peach-ripe)' },
  { bg: '#E8B98D',          badge: '#D4A57A' },
  { bg: 'var(--candyfloss)', badge: 'var(--candyfloss-ripe)' },
]

function InsightCard({ insight, rank, color, childName }) {
  const score = Math.min(100, Math.max(0, Math.round(insight.matchScore || insight.score_pct || 0)))
  const displayName = getDisplayName(insight.name)
  const description = getShortDescription(insight.name, insight.message, childName)
  const isHero = rank === 1

  return (
    <div className={`dash-card${isHero ? ' dash-card-hero' : ''}`}>
      <div className="dash-pill" style={{ background: color.bg }}>
        <div className="dash-rank">#{rank}</div>
        <div className="dash-pill-name">{displayName}</div>
        <div className="dash-pill-score" style={{ background: color.badge }}>{score}%</div>
      </div>
      <p className="dash-card-desc">{description}</p>
      <a href={`/insight/${insight._id}`} className="dash-card-btn">
        {isHero ? 'Tell me more' : 'Learn more'}
      </a>
    </div>
  )
}

function WorthWatching({ insights, childName }) {
  if (!insights || insights.length === 0) return null

  return (
    <section className="worth-watching">
      <h2 className="section-heading">Worth Watching</h2>
      <p className="worth-watching-sub">
        A few patterns that might be worth a conversation.
      </p>
      <div className="dash-cards">
        {insights.map((insight, i) => (
          <InsightCard
            key={insight._id}
            insight={insight}
            rank={i + 1}
            color={INSIGHT_COLORS[i] || INSIGHT_COLORS[0]}
            childName={childName}
          />
        ))}
      </div>
    </section>
  )
}

const DISPLAY_NAMES = {
  'Rapid Swipe': 'Rapid Swiping',
  'Short-Ladder': 'Endless Shorts',
  'Late-Night': 'Late Night Sessions',
  'Thumbnail-Roulette': 'Thumbnail Roulette',
}

function getDisplayName(name) {
  const key = Object.keys(DISPLAY_NAMES).find(k => name?.includes(k))
  return key ? DISPLAY_NAMES[key] : name
}

function getShortDescription(name, message, childName) {
  if (name?.includes('Rapid Swipe'))
    return `${childName} has been skipping through videos quickly — common with autoplay and algorithmic feeds.`
  if (name?.includes('Short-Ladder'))
    return `Long sessions of short clips can keep ${childName} in a passive loop.`
  if (name?.includes('Late-Night'))
    return `Some viewing is happening after a typical bedtime window.`
  if (name?.includes('Thumbnail-Roulette'))
    return `${childName} hops between many channels quickly, often driven by thumbnails.`
  return message || ''
}

export default function SummaryPage() {
  const [channelData, setChannelData] = useState(null)
  const [insights, setInsights] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [hasUploadedHistory, setHasUploadedHistory] = useState(true)

  const user = authService.getUser()
  const parentName = user?.child_name ? `${user.child_name}'s parent` : 'there'
  const childName = user?.child_name || 'your child'

  useEffect(() => {
    if (!authService.isAuthenticated()) {
      setLoading(false)
      setError('Please log in to view insights')
      return
    }
    const u = authService.getUser()
    setHasUploadedHistory(!u?.first_login)

    const load = async () => {
      try {
        setLoading(true)
        const [cq, rawInsights] = await Promise.all([
          apiService.getChannelQuality().catch(() => null),
          apiService.getInsights(),
        ])

        // Channel quality
        if (cq && cq.channels && cq.channels.length > 0) {
          // Attach top good channels to summary for the hero card
          const goodChannels = cq.channels
            .filter(c => c.tier === 'educational' || c.tier === 'neutral')
            .sort((a, b) => b.minutes - a.minutes)
            .slice(0, 3)
          cq.summary._topGoodChannels = goodChannels
          setChannelData(cq)
        }

        // Insights — filter to moderate/high severity behavioral ones
        const filtered = Array.isArray(rawInsights)
          ? rawInsights
              .filter(
                i =>
                  i?.name !== 'Content Category Balance' &&
                  i?.name !== 'Single-Channel Reliance'
              )
              .map(i => ({
                ...i,
                displayName: getDisplayName(i.name),
                description: getShortDescription(i.name, i.message, childName),
              }))
          : []
        setInsights(filtered)
      } catch (err) {
        setError(err.message)
      } finally {
        setLoading(false)
      }
    }
    load()
  }, [])

  const handleOverride = async (channelName, newTier) => {
    try {
      await apiService.overrideChannelQuality(channelName, newTier)
      // Optimistically update local state
      setChannelData(prev => {
        if (!prev) return prev
        const updated = prev.channels.map(c =>
          c.name === channelName ? { ...c, tier: newTier, source: 'override' } : c
        )
        // Recalc summary
        const totalMin = updated.reduce((s, c) => s + (c.minutes || 0), 0)
        const tierMin = { educational: 0, neutral: 0, junk: 0 }
        for (const c of updated) tierMin[c.tier] += c.minutes || 0
        const goodMin = tierMin.educational + tierMin.neutral
        const goodChannels = updated
          .filter(c => c.tier === 'educational' || c.tier === 'neutral')
          .sort((a, b) => b.minutes - a.minutes)
          .slice(0, 3)
        return {
          channels: updated,
          summary: {
            educational_pct: totalMin ? Math.round(tierMin.educational / totalMin * 1000) / 10 : 0,
            neutral_pct: totalMin ? Math.round(tierMin.neutral / totalMin * 1000) / 10 : 0,
            junk_pct: totalMin ? Math.round(tierMin.junk / totalMin * 1000) / 10 : 0,
            total_minutes: Math.round(totalMin * 10) / 10,
            good_minutes: Math.round(goodMin * 10) / 10,
            _topGoodChannels: goodChannels,
          },
        }
      })
    } catch (err) {
      console.error('Override failed:', err)
    }
  }

  const hasChannelData = channelData && channelData.channels && channelData.channels.length > 0

  return (
    <div className="summary-layout">
      <NavBar />

      <main className="dash-main">
        <h1 className="dash-greeting">Hi, {parentName}</h1>
        <p className="dash-subtitle">
          {hasChannelData
            ? `Here's what's going well with ${childName}'s screen time.`
            : `Here's a breakdown of ${childName}'s recent viewing patterns and habits.`}
        </p>

        {!hasUploadedHistory && (
          <a href="/onboarding" className="dash-upload-banner">
            <span className="dash-upload-text">
              Upload YouTube history to get started
            </span>
            <span className="dash-upload-arrow">&rarr;</span>
          </a>
        )}

        {loading && <p className="dash-loading">Loading insights...</p>}
        {error && <p className="dash-error">{error}</p>}

        {!loading && hasChannelData && (
          <>
            <GoodNewsCard summary={channelData.summary} childName={childName} />
            <ChannelBreakdown
              channels={channelData.channels}
              onOverride={handleOverride}
            />
            {insights.length > 0 && (
              <WorthWatching insights={insights} childName={childName} />
            )}
            <a href="/cheat-sheet" className="cheat-sheet-cta">
              Print Caregiver Cheat Sheet
            </a>
          </>
        )}

        {!loading && !hasChannelData && insights.length > 0 && (
          <div className="dash-cards">
            {insights.map((insight, i) => (
              <InsightCard
                key={insight._id}
                insight={insight}
                rank={i + 1}
                color={INSIGHT_COLORS[i] || INSIGHT_COLORS[0]}
                childName={childName}
              />
            ))}
          </div>
        )}

        {!loading && !hasChannelData && insights.length === 0 && hasUploadedHistory && (
          <p className="dash-empty">
            No data yet. Upload YouTube history from the onboarding page to see
            your dashboard.
          </p>
        )}
      </main>

      <footer className="summary-footer">
        <a>Terms of Service</a>
        <a>Privacy Policy</a>
        <a>Contact Us</a>
        <span>Tedio. All rights reserved.</span>
      </footer>
    </div>
  )
}

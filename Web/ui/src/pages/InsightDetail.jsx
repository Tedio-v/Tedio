import './insight-detail.css'
import NavBar from '../components/NavBar.jsx'
import { useEffect, useMemo, useState } from 'react'
import { useParams } from 'react-router-dom'
import { apiService } from '../services/api.js'
import { authService } from '../services/auth.js'

function InsightHero({ name }) {
  const imageSrc = useMemo(() => {
    const map = {
      'Rapid Swipe': '/dinsights/insight1.png',
      'Short-Ladder': '/dinsights/insight2.png',
      'Late-Night': '/dinsights/insight3.png',
      'Thumbnail-Roulette': '/dinsights/insight4.png',
      'Content Category': '/dinsights/insight5.png',
    }
    const key = Object.keys(map).find((k) => name?.includes(k))
    return key ? map[key] : '/dinsights/insight1.png'
  }, [name])
  return (
    <div className="hero">
      <div className="hero-image" role="img" aria-label="Insight cover">
        <img src={imageSrc} alt="" />
        <h1 className="hero-title">{name || 'Insight'}</h1>
      </div>
    </div>
  )
}

function getInsightContent(name) {
  if (!name) return null
  if (name.includes('Rapid Swipe')) {
    return {
      whyThis:
        "YouTube quickly learns what grabs your child’s attention—even if they only pause on a video for a split second. Bright colors, silly faces, loud noises... anything that gets a quick glance is treated as a success. The app is designed to catch their eye right away, not help them think about what they’re watching.",
      whyKids:
        "Kids often treat videos like tasting jelly beans—one quick try, then on to the next. If a clip doesn’t excite them right away, they swipe, knowing another option is just one flick away.",
      whyMatters:
        "According to Common Sense Media, this habit of constant skipping teaches kids to expect instant excitement. But that can make it harder for them to stick with anything longer or more meaningful—like reading, learning, or even just relaxing with one video. When kids choose videos more thoughtfully and watch all the way through, they’re actually building focus, patience, and self-control—skills that really help in school and in life.",
  sourceText: "Parents’ Ultimate Guide to YouTube Kids",
  sourceHref: 'https://www.commonsensemedia.org/articles/parents-ultimate-guide-to-youtube-kids',
    }
  }
  if (name.includes('Short-Ladder')) {
    return {
      whyThis:
        "Short videos play one after another with no stopping point. There’s no \"Are you still watching?\" pop-up—just swipe up, and a new one starts instantly. The app keeps track of what your child likes and keeps serving more of the same. It’s built to keep them watching without noticing how much time has passed.",
      whyKids:
        "Each clip feels short and easy to watch—‘just one more’ doesn’t feel like a big deal. But because the videos never really stop, and there’s no clear ending, kids can end up scrolling for 20 minutes (or more) without even realizing it.",
      whyMatters:
        "Experts at the 5Rights Foundation say this kind of never-ending feed isn't a good match for how kids grow and learn. The constant swiping keeps their brain busy but not focused, which can affect memory, attention, and how they manage emotions. Over time, kids who watch a lot of short videos like this may have a harder time staying focused in school or sticking with activities that don’t give instant rewards.",
      sourceText: undefined,
      sourceHref: undefined,
    }
  }
  if (name.includes('Late-Night')) {
    return {
      whyThis:
        "Kids can dismiss YouTube’s ‘Bedtime’ pop-up with one tap, and the video keeps playing in the background. After that, the next video just starts on its own. The screen’s blue light also makes it harder for their brain to wind down, even if they’re tired.",
      whyKids:
        "At night, screens can feel like a friend. When the house is quiet, kids may turn to glowing screens for comfort or distraction. Some rewatch favorite cartoons to fall asleep, while others stay up chasing live streams happening in different time zones.",
      whyMatters:
        "Using screens before bed—especially within an hour of sleep—can throw off your child’s body clock. The blue light and excitement from videos or games delay melatonin (the sleep hormone) and cut into deep, restful sleep. Experts recommend keeping all screens out of the bedroom and turning them off at least 30–60 minutes before bedtime. Calming activities like reading, drawing, or quiet conversation can add meaningful minutes of sleep, improving memory, mood, and next‑day focus.",
      sourceText: 'National Library of Medicine – Screen use and sleep',
      sourceHref: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC5839336/',
    }
  }
  if (name.includes('Thumbnail-Roulette')) {
    return {
      whyThis:
        "YouTube carefully tests and selects thumbnails that will grab your child’s attention the fastest. Flashy colors, surprised faces, and words like ‘OMG!’ or ‘You won’t believe this’ work best. These pictures load instantly and are much easier to react to than reading a title. The more your child clicks, the more of the same flashy images they’ll see.",
      whyKids:
        "Younger kids are drawn to bright colors and bold images—they look fun, even if they have no idea what the video is about. Since reading takes effort and the images feel exciting, kids start picking videos based on looks alone, without really thinking about what they’re choosing.",
      whyMatters:
        "Common Sense warns that eye‑popping images and words like unbelievable or amazing are designed to influence clicks, and that children need explicit coaching to spot these tactics. When children select videos based purely on flashy thumbnails, their choices become limited to the most attention‑grabbing content, exposing them to low‑quality or commercialized material that can shape attention span and taste over time.",
  sourceText: 'Common Sense Media – How Do I Teach My Kid About Clickbait?',
  sourceHref: 'https://www.commonsensemedia.org/articles/how-do-i-teach-my-kid-about-clickbait',
    }
  }
  return null
}

function getQuickActions(insightName) {
  if (!insightName) return []
  
  // Rapid Swipe Taste Test
  if (insightName.includes('Rapid Swipe')) {
    return [
      { label: 'Remove Shorts from Home', path: '/remove-shorts', id: 'remove-shorts' },
      { label: 'Make "waiting-time kits" (toy, book)', path: '/waiting-time-kit', id: 'waiting-time-kit' },
      { label: 'Pause & Predict "30-second rule"', path: '/pause-predict', id: 'pause-predict' },
      { label: 'Suggest to do something together', path: '/time-together', id: 'time-together' },
      { label: 'Set a "Take-a-break" timer (physical timer recommended)', path: '/set-timer', id: 'set-timer' }
    ]
  }
  
  // Endless Shorts Ladder
  if (insightName.includes('Short-Ladder')) {
    return [
      { label: 'Build a watch list', path: '/build-watchlist', id: 'build-watchlist' },
      { label: 'Use a 20-minute kitchen timer (physical timer)', path: '/physical-timer', id: 'physical-timer' },
      { label: 'Remove Shorts from Home', path: '/remove-shorts', id: 'remove-shorts' },
      { label: 'Suggest to do something together', path: '/time-together', id: 'time-together' },
      { label: 'Set a "Take-a-break" timer (physical timer recommended)', path: '/set-timer', id: 'set-timer' }
    ]
  }
  
  // Late-Night Minutes
  if (insightName.includes('Late-Night')) {
    return [
      { label: 'Remove devices from bedroom + relaxing routine', path: '/remove-devices', id: 'remove-devices' },
      { label: 'Set Screen-Time "Downtime"', path: '/set-downtime', id: 'set-downtime' }
    ]
  }
  
  // Default actions for other insights (Thumbnail Roulette, etc.)
  return [
    { label: 'Block a channel', path: '/block-channel', id: 'block-channel' },
    { label: 'Pause & Predict "30-second rule"', path: '/pause-predict', id: 'pause-predict' }
  ]
}

function getDetailedAnalysis(insight, user) {
  const childName = user?.child_name || 'your child'
  const headline = insight?.message || 'Detailed analysis'

  if (insight?.name?.includes('Rapid Swipe')) {
    return {
      title: 'Detailed Analysis',
      headline,
      lines: [
        `Out of 187 total videos watched, ${childName} exited 128 videos within 3 seconds and 163 videos within 4–10 seconds.`,
        'This Rapid Swipe pattern represents 77.8% of all viewing sessions, including normal exploration in content selection.',
      ],
    }
  }
  if (insight?.name?.includes('Short-Ladder')) {
    return {
      title: 'Detailed Analysis',
      headline,
      lines: [
        `${childName} watched multiple very short videos back-to-back with no clear stopping point.`,
        'These uninterrupted short-video ladders can quickly add up without noticing the time passing.',
      ],
    }
  }
  if (insight?.name?.includes('Late-Night')) {
    return {
      title: 'Detailed Analysis',
      headline,
      lines: [
        `${childName} spent part of their watch time after typical bedtime hours.`,
        'Late-night viewing reduces deep, restorative sleep and may impact next‑day focus and mood.',
      ],
    }
  }
  if (insight?.name?.includes('Thumbnail-Roulette')) {
    return {
      title: 'Detailed Analysis',
      headline,
      lines: [
        `${childName} frequently chose videos based on attention‑grabbing thumbnails rather than titles.`,
        'This can bias selection toward low‑quality, high‑sensory content that trains quick, reactive choices.',
      ],
    }
  }
  return { title: 'Detailed Analysis', headline, lines: ['This pattern summarizes your child’s recent viewing behavior.'] }
}

function getStaticInsight(insightKey) {
  const staticInsights = {
    'insight-1': { name: 'Rapid Swipe Taste Test', _id: 'insight-1' },
    'insight-2': { name: 'Endless Shorts Ladder', _id: 'insight-2' },
    'insight-3': { name: 'Late-Night Minutes', _id: 'insight-3' },
    'insight-4': { name: 'Thumbnail Roulette', _id: 'insight-4' },
  }
  return staticInsights[insightKey] || null
}

export default function InsightDetail() {
  const { id } = useParams()
  const [insight, setInsight] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [selectedRating, setSelectedRating] = useState(null)
  const [submitting, setSubmitting] = useState(false)
  const [globalRating, setGlobalRating] = useState({ average: null, totalRaters: 0 })
  const [completedActions, setCompletedActions] = useState([])
  const [isStatic, setIsStatic] = useState(false)
  const user = authService.getUser()

  useEffect(() => {
    const fetchInsight = async () => {
      try {
        setError('')
        setLoading(true)

        // Check if this is a static insight ID
        const staticInsight = getStaticInsight(id)
        if (staticInsight) {
          // Check if there's a saved rating in localStorage
          const storedRatings = JSON.parse(localStorage.getItem('pendingRatings') || '{}')
          const savedRating = storedRatings[id]

          setInsight({
            ...staticInsight,
            userImportanceRating: savedRating?.rating || null
          })
          setIsStatic(true)
          setLoading(false)
          return
        }

        // Otherwise fetch from API
        const data = await apiService.getInsight(id)
        setInsight(data)
        setIsStatic(false)

        // Set global rating if available
        if (data.globalRating) {
          setGlobalRating({
            average: data.globalRating.average,
            totalRaters: data.globalRating.totalRaters
          })
        }
      } catch (e) {
        // If API fails, try showing static content
        const staticInsight = getStaticInsight(id)
        if (staticInsight) {
          // Check if there's a saved rating in localStorage
          const storedRatings = JSON.parse(localStorage.getItem('pendingRatings') || '{}')
          const savedRating = storedRatings[id]

          setInsight({
            ...staticInsight,
            userImportanceRating: savedRating?.rating || null
          })
          setIsStatic(true)
          setError('')
        } else {
          setError(e.message)
        }
      } finally {
        setLoading(false)
      }
    }

    const fetchCompletedActions = async () => {
      try {
        const data = await apiService.getCompletedActions()
        setCompletedActions(data.completed_actions || [])
      } catch (e) {
        console.error('Error fetching completed actions:', e)
      }
    }

    if (id) {
      fetchInsight()
      fetchCompletedActions()
    }
  }, [id])

  const submitRating = async () => {
    const ratingToSubmit = selectedRating || insight.userImportanceRating
    if (!ratingToSubmit) return

    // If this is a static insight, store rating locally and show upload prompt
    if (isStatic) {
      // Store the rating in localStorage
      const storedRatings = JSON.parse(localStorage.getItem('pendingRatings') || '{}')
      storedRatings[id] = { rating: ratingToSubmit, insightName: insight?.name }
      localStorage.setItem('pendingRatings', JSON.stringify(storedRatings))

      // Update UI to show submitted
      setInsight(prev => ({
        ...prev,
        userImportanceRating: ratingToSubmit
      }))
      setSelectedRating(null)

      // Show success message
      alert('Rating saved! Upload your YouTube history to unlock personalized insights.')
      return
    }

    try {
      setSubmitting(true)
      const response = await apiService.submitInsightRating(id, ratingToSubmit, insight?.name)

      // Update insight state with user's rating
      setInsight(prev => ({
        ...prev,
        userImportanceRating: ratingToSubmit
      }))

      // Clear the selected rating
      setSelectedRating(null)

      // Update global rating with response data
      if (response.global_average && response.total_raters) {
        setGlobalRating({
          average: response.global_average,
          totalRaters: response.total_raters
        })
      }
    } catch (e) {
      setError(e.message)
    } finally {
      setSubmitting(false)
    }
  }

  if (loading) return <div className="detail-layout"><main className="detail-main"><p>Loading...</p></main></div>
  if (error) return <div className="detail-layout"><main className="detail-main"><p style={{color:'red'}}>{error}</p></main></div>
  if (!insight) return null

  // Determine layout class based on insight type for button colors
  const getLayoutClass = () => {
    const insightName = insight?.name || ''
    if (insightName.includes('Rapid Swipe')) return 'detail-layout insight-1'
    if (insightName.includes('Short-Ladder')) return 'detail-layout insight-2' 
    if (insightName.includes('Late-Night')) return 'detail-layout insight-3'
    if (insightName.includes('Thumbnail-Roulette')) return 'detail-layout insight-4'
    return 'detail-layout insight-1' // Default to first insight color
  }
  
  const layoutClass = getLayoutClass()

  return (
    <div className={layoutClass}>
      <NavBar />
      <main className="detail-main">
        <div className="detail-grid">
          <section className="detail-left">
            <InsightHero name={insight.name} />
            <div className="metric-card">
              <div style={{fontWeight:600, marginBottom: '8px'}}>Detailed Analysis</div>
              {isStatic ? (
                <>
                  <div style={{
                    backgroundColor: '#f0f9ff',
                    border: '2px solid #3b82f6',
                    borderRadius: '8px',
                    padding: '1rem',
                    marginTop: '8px',
                    textAlign: 'center'
                  }}>
                    <div style={{fontSize: '2rem', marginBottom: '0.5rem'}}>🔒</div>
                    <div style={{fontWeight: 'bold', marginBottom: '0.5rem', color: '#1e40af'}}>
                      Upload YouTube History
                    </div>
                    <p style={{margin: 0, fontSize: '0.9rem', color: '#1e40af'}}>
                      Upload your child's watch history to see personalized analytics and insights
                    </p>
                    <a href="/onboarding" style={{
                      display: 'inline-block',
                      marginTop: '1rem',
                      backgroundColor: '#2563eb',
                      color: 'white',
                      padding: '0.5rem 1rem',
                      borderRadius: '0.5rem',
                      textDecoration: 'none',
                      fontWeight: 'bold',
                      fontSize: '0.9rem'
                    }}>Upload Now →</a>
                  </div>
                </>
              ) : (
                <>
                  <a className="metric-link" href="/relevancy" onClick={e => { e.preventDefault(); window.location.href = '/relevancy'; }}>{getDetailedAnalysis(insight, user).headline}</a>
                  {getDetailedAnalysis(insight, user).lines.map((t, idx) => (
                    <p key={idx} className={idx === 0 ? 'metric-sub' : 'metric-foot'}>{t}</p>
                  ))}
                </>
              )}
            </div>

            <article className="explain">
              <h3>Why this happens (design trigger)</h3>
              <p>{getInsightContent(insight.name)?.whyThis || 'Apps learn quickly what grabs attention in the first seconds. Features like autoplay and swipe-to-next reward novelty-seeking and quick switches.'}</p>

              <h3>Why kids do it (what it feels like to them)</h3>
              <p>{getInsightContent(insight.name)?.whyKids || 'Short, punchy clips feel fun and effortless. If a video doesn’t excite right away, it’s easy to move on instantly.'}</p>

              <h3>Why it matters (expert insight)</h3>
              <p>{getInsightContent(insight.name)?.whyMatters || 'Over time, repeated micro-switching can make it harder to practice focus and stick with longer, more meaningful content like learning or reading.'}</p>

              {(() => {
                const c = getInsightContent(insight.name)
                if (!c?.sourceText) return null
                return (
                  <p className="source">Source: <a href={c.sourceHref || '#'} target={c.sourceHref ? '_blank' : undefined} rel={c.sourceHref ? 'noreferrer' : undefined}>{c.sourceText}</a></p>
                )
              })()}
            </article>
          </section>

          <aside className="detail-right">
            <section className="rating-card">
              <h4>How important is this behavior to you?</h4>
              <p className="muted">Rate how important this behavior pattern is for your children's digital well being.</p>


              <div className="radio-list">
                {[1,2,3,4,5].map((val, i) => (
                  <label key={val} className="radio-item">
                    <input
                      name="importance"
                      type="radio"
                      checked={selectedRating === val || (!selectedRating && insight.userImportanceRating === val)}
                      onChange={() => setSelectedRating(val)}
                    />
                    <span className="radio-label">{val} {['Not important','Somewhat important','Important','Very important','Critical'][i]}</span>
                  </label>
                ))}
              </div>
              <button
                className={`submit-btn ${insight.userImportanceRating ? 'submitted' : ''}`}
                disabled={(!selectedRating && !insight.userImportanceRating) || submitting}
                onClick={submitRating}
              >
                {submitting ? 'Submitting...' :
                 insight.userImportanceRating && !selectedRating ? 'Rating Submitted ✓' :
                 insight.userImportanceRating && selectedRating ? 'Update Rating' :
                 'Submit Rating'}
              </button>
            </section>

            <section className="actions-card">
              <h4>Quick Actions</h4>
              <p className="muted">Click and see the suggested steps and resources for each action!</p>
              <div className="action-list">
                {getQuickActions(insight.name).map((action) => {
                  const isCompleted = completedActions.includes(action.id)
                  return (
                    <button 
                      key={action.label} 
                      className={`action-btn ${isCompleted ? 'completed' : ''}`}
                      onClick={() => window.location.href = action.path}
                    >
                      {action.label} {isCompleted ? '✓' : ''}
                    </button>
                  )
                })}
              </div>
            </section>
          </aside>
        </div>
      </main>
    </div>
  )
}


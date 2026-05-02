import NavBar from '../components/NavBar.jsx'
import './quick-actions.css'

const QUICK_FIXES = [
  {
    title: 'Waiting time kits',
    desc: 'Gives children an offline alternative during micro-idle moments.',
    href: '/waiting-time-kit',
    cta: 'Dive in',
    bg: '#E8E09D',
    helps: ['Rapid swiping', 'Endless shorts', 'Thumbnail roulette'],
    dots: ['var(--melon)', 'var(--peach)', 'var(--candyfloss)'],
  },
  {
    title: 'Remove Shorts from Home',
    desc: 'Removes the Shorts shelf from YouTube so your child sees full-length videos instead.',
    href: '/remove-shorts',
    cta: 'See how',
    bg: 'var(--sandstone)',
    helps: ['Rapid swiping', 'Endless shorts'],
    dots: ['var(--melon)', 'var(--peach)'],
  },
  {
    title: 'Build a watchlist',
    desc: 'Curate a list of approved videos so your child picks from quality content.',
    href: '/build-watchlist',
    cta: 'See how',
    bg: 'var(--sandstone)',
    helps: ['Endless shorts', 'Thumbnail roulette'],
    dots: ['var(--peach)', 'var(--candyfloss)'],
  },
  {
    title: 'Block a channel',
    desc: 'Block channels that keep showing up with low-quality or overstimulating content.',
    href: '/block-channel',
    cta: 'See how',
    bg: 'var(--sandstone)',
    helps: ['Thumbnail roulette'],
    dots: ['var(--candyfloss)'],
  },
]

const BUILDING_HABITS = [
  {
    title: 'Pause and predict',
    subtitle: 'Helps fix rapid swiping.',
    desc: 'Before each new video, pause and ask "what do you think this video is about?" Builds intentional viewing.',
    href: '/pause-predict',
    cta: 'See instructions',
    bg: 'var(--melon)',
  },
  {
    title: 'Remove devices from bedroom',
    subtitle: 'Helps fix late night sessions.',
    desc: 'Create a charging station outside the bedroom and build a relaxing screen-free bedtime routine.',
    href: '/remove-devices',
    cta: 'See instructions',
    bg: 'var(--candyfloss)',
  },
  {
    title: 'Set screen-time downtime',
    subtitle: 'Helps fix late night sessions.',
    desc: 'Use iOS Screen Time or Google Family Link to automatically lock apps after bedtime.',
    href: '/set-downtime',
    cta: 'See instructions',
    bg: 'var(--peach)',
  },
  {
    title: 'Use a break timer',
    subtitle: 'Helps fix endless shorts.',
    desc: 'Set a physical kitchen timer for 20 minutes. When it rings, take a 5-minute break before watching more.',
    href: '/set-timer',
    cta: 'See instructions',
    bg: 'var(--sandstone)',
  },
  {
    title: 'Do something together',
    subtitle: 'Helps fix all patterns.',
    desc: 'Co-viewing and co-play replace passive screen time with quality connection.',
    href: '/time-together',
    cta: 'See ideas',
    bg: 'var(--sandstone)',
  },
]

function QuickFixCard({ action }) {
  return (
    <div className="qa-card" style={{ background: action.bg }}>
      <h3 className="qa-card-title">{action.title}</h3>
      <p className="qa-card-desc">{action.desc}</p>
      <a href={action.href} className="qa-card-cta">{action.cta}</a>
      {action.helps && (
        <div className="qa-card-tags">
          <span className="qa-card-helps">
            Helps fix {action.helps.join(', ').toLowerCase()}
          </span>
          <span className="qa-card-dots">
            {action.dots.map((c, i) => (
              <span key={i} className="qa-dot" style={{ background: c }} />
            ))}
          </span>
        </div>
      )}
    </div>
  )
}

function HabitCard({ action }) {
  return (
    <div className="qa-card qa-card--habit" style={{ background: action.bg }}>
      <h3 className="qa-card-title">{action.title}</h3>
      <p className="qa-card-subtitle">{action.subtitle}</p>
      <p className="qa-card-desc">{action.desc}</p>
      <a href={action.href} className="qa-card-cta">{action.cta}</a>
    </div>
  )
}

export default function QuickActions() {
  return (
    <div className="qa-page">
      <NavBar />

      <div className="qa-container">
        {/* Quick Fixes */}
        <div className="qa-section-header">
          <h1 className="qa-section-title">Quick fixes</h1>
          <span className="qa-section-time">~15 min each</span>
        </div>
        <p className="qa-section-desc">Activities you can do right now to help.</p>
        <hr className="qa-divider" />

        <div className="qa-list">
          {QUICK_FIXES.map((a) => (
            <QuickFixCard key={a.title} action={a} />
          ))}
        </div>

        {/* Building Habits */}
        <div className="qa-section-header qa-section-header--habits">
          <h2 className="qa-section-title">Building habits</h2>
          <span className="qa-section-time">10 min/day</span>
        </div>
        <p className="qa-section-desc">Activities you can do daily to build habits long-term.</p>
        <hr className="qa-divider" />

        <div className="qa-list">
          {BUILDING_HABITS.map((a) => (
            <HabitCard key={a.title} action={a} />
          ))}
        </div>
      </div>
    </div>
  )
}

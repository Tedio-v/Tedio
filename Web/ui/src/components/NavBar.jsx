import '../pages/summary.css'

export default function NavBar({ minimal = false }) {
  return (
    <header className="summary-nav">
      <a className="brand" href="/summary" style={{ textDecoration: 'none', color: 'inherit' }}>
  <img className="brand-logo" src="/brand/Tedio.logo.png" alt="Tedio logo" />
  <div className="name">Tedio</div>
      </a>
      {!minimal && (
        <nav className="nav-links">
          <a href="/summary">Dashboard</a>
          <a href="/relevancy">Relevancy</a>
          <a href="/quick-actions">Quick Actions</a>
          <a href="/settings">Settings</a>
        </nav>
      )}
    </header>
  )
}



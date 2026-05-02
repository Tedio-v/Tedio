import { useState } from 'react'
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { authService } from './services/auth.js'
import SimpleAuth from './components/SimpleAuth.jsx'
import SummaryPage from './pages/SummaryPage.jsx'
import InsightDetail from './pages/InsightDetail.jsx'
import Onboarding from './pages/Onboarding.jsx'
import Relevancy from './pages/Relevancy.jsx'
import './App.css'
import Landing from './pages/Landing.jsx'
import PausePredict from './pages/PausePredict.jsx'
import BuildWatchlist from './pages/BuildWatchlist.jsx'
import SetTimer from './pages/SetTimer.jsx'
import PhysicalTimer from './pages/PhysicalTimer.jsx'
import SetDowntime from './pages/SetDowntime.jsx'
import RemoveShorts from './pages/RemoveShorts.jsx'
import WaitingTimeKit from './pages/WaitingTimeKit.jsx'
import BlockChannel from './pages/BlockChannel.jsx'
import TimeTogether from './pages/TimeTogether.jsx'
import RemoveDevices from './pages/RemoveDevices.jsx'
import QuickActions from './pages/QuickActions.jsx'
import Settings from './pages/Settings.jsx'
import CheatSheet from './pages/CheatSheet.jsx'

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(authService.isAuthenticated())
  const [user, setUser] = useState(authService.getUser())
  const [showAuth, setShowAuth] = useState(false)
  
  // Determine where to redirect based on auth and onboarding status
  const getHomeRedirect = () => {
    if (!isAuthenticated) return '/login' // This won't be used since we show SimpleAuth
    // Always redirect to summary (dashboard) after login
    return '/summary'
  }

  const handleAuthSuccess = () => {
    setIsAuthenticated(true)
    const u = authService.getUser()
    setUser(u)
  }

  const handleLogout = () => {
    authService.logout()
    setIsAuthenticated(false)
    setUser(null)
  }

  const handleOnboardingComplete = () => {
    // Update the user state to mark onboarding as complete
    const currentUser = authService.getUser()
    if (currentUser) {
      const updatedUser = { ...currentUser, first_login: false }
      localStorage.setItem('user', JSON.stringify(updatedUser))
      setUser(updatedUser) // Update App state immediately
    }
  }

  const publicPaths = new Set(['/pause-predict', '/build-watchlist', '/set-timer', '/physical-timer', '/set-downtime', '/remove-shorts', '/waiting-time-kit', '/block-channel', '/time-together', '/remove-devices', '/quick-actions', '/settings', '/cheat-sheet'])
  const isPublicPath = typeof window !== 'undefined' && publicPaths.has(window.location?.pathname)

  if (!isAuthenticated && !isPublicPath) {
    return showAuth 
      ? <div className="page-container"><SimpleAuth onAuthSuccess={handleAuthSuccess} /></div>
      : <Landing onGetStarted={() => setShowAuth(true)} />
  }

  return (
    <Router>
      <div className="App page-container">
        <Routes>
          <Route path="/" element={<Navigate to={getHomeRedirect()} replace />} />
          <Route path="/onboarding" element={<Onboarding onComplete={handleOnboardingComplete} />} />
          <Route path="/summary" element={<SummaryPage />} />
          <Route path="/relevancy" element={<Relevancy />} />
          <Route path="/pause-predict" element={<PausePredict />} />
          <Route path="/build-watchlist" element={<BuildWatchlist />} />
          <Route path="/set-timer" element={<SetTimer />} />
          <Route path="/physical-timer" element={<PhysicalTimer />} />
          <Route path="/set-downtime" element={<SetDowntime />} />
          <Route path="/remove-shorts" element={<RemoveShorts />} />
          <Route path="/waiting-time-kit" element={<WaitingTimeKit />} />
          <Route path="/block-channel" element={<BlockChannel />} />
          <Route path="/time-together" element={<TimeTogether />} />
          <Route path="/remove-devices" element={<RemoveDevices />} />
          <Route path="/quick-actions" element={<QuickActions />} />
          <Route path="/settings" element={<Settings />} />
          <Route path="/cheat-sheet" element={<CheatSheet />} />
          <Route path="/insight/:id" element={<InsightDetail />} />
          <Route path="*" element={<Navigate to={getHomeRedirect()} replace />} />
        </Routes>
      </div>
    </Router>
  )
}

export default App

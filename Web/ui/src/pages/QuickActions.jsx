import React from 'react'
import NavBar from '../components/NavBar.jsx'
import './quick-actions.css'

export default function QuickActions() {
  return (
    <div className="qa-page">
      <NavBar />

      <div className="qa-container">
        <h1 className="qa-title">Quick Actions</h1>

        <section className="qa-panel">
          <div className="qa-grid">
            <div className="qa-col qa-col--1">
              <div className="qa-col-header">
                <div className="qa-col-title">Rapid Swipe</div>
                <img className="qa-icon" src="/images/quick/icon-rapid.png" alt="Rapid Swipe" />
              </div>
              <a className="qa-action" href="/remove-shorts">Remove Shorts from Home</a>
              <a className="qa-action" href="/waiting-time-kit">Make “waiting-time kits” (toy, book)</a>
              <a className="qa-action" href="/pause-predict">Pause & Predict “30-second rule”</a>
              <a className="qa-action" href="/time-together">Suggest to do something together</a>
            </div>

            <div className="qa-col qa-col--2">
              <div className="qa-col-header">
                <div className="qa-col-title">Endless Shorts Ladder</div>
                <img className="qa-icon" src="/images/quick/icon-shorts.png" alt="Endless Shorts Ladder" />
              </div>
              <a className="qa-action" href="/build-watchlist">Build a watch list</a>
              <a className="qa-action" href="/set-timer">Use a 20-minute kitchen timer (physical timer)</a>
              <a className="qa-action" href="/physical-timer">Set a “Take-a-break” timer (physical timer recommended)</a>
            </div>

            <div className="qa-col qa-col--3">
              <div className="qa-col-header">
                <div className="qa-col-title">Late-Night Minutes</div>
                <img className="qa-icon" src="/images/quick/icon-late-night.png" alt="Late-Night Minutes" />
              </div>
              <a className="qa-action" href="/set-downtime">Set Screen-Time “Downtime”</a>
              <a className="qa-action" href="/remove-devices">Remove devices from bedroom + relaxing routine</a>
            </div>

            <div className="qa-col qa-col--4">
              <div className="qa-col-header">
                <div className="qa-col-title">Thumbnail Roulette</div>
                <img className="qa-icon" src="/images/quick/icon-roulette.png" alt="Thumbnail Roulette" />
              </div>
              <a className="qa-action" href="/block-channel">Block a Channel</a>
            </div>
          </div>
        </section>
      </div>
    </div>
  )
} 
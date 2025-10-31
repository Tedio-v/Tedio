import React, { useState, useEffect } from 'react'
import NavBar from '../components/NavBar.jsx'
import { apiService } from '../services/api.js'
import './set-downtime.css'

export default function SetDowntime() {
  const [isCompleted, setIsCompleted] = useState(false)
  const actionId = 'set-downtime'

  useEffect(() => {
    // Check if this action is already completed
    const checkCompletion = async () => {
      try {
        const data = await apiService.getCompletedActions()
        setIsCompleted(data.completed_actions.includes(actionId))
      } catch (e) {
        console.error('Error checking completion status:', e)
      }
    }
    checkCompletion()
  }, [])

  const handleCheckboxChange = async (event) => {
    const checked = event.target.checked
    try {
      if (checked) {
        await apiService.completeQuickAction(actionId)
        setIsCompleted(true)
      } else {
        await apiService.uncompleteQuickAction(actionId)
        setIsCompleted(false)
      }
    } catch (e) {
      console.error('Error updating completion status:', e)
      // Revert checkbox state on error
      event.target.checked = !checked
    }
  }
  return (
    <div className="set-downtime">
      <NavBar />

      <div className="sd-layout">
        <aside className="sd-sidebar">
          <button 
            className="sd-back-btn" 
            onClick={() => window.history.back()}
            style={{
              background: 'none',
              border: '1px solid #ddd',
              borderRadius: '6px',
              padding: '8px 12px',
              marginBottom: '16px',
              cursor: 'pointer',
              fontSize: '14px',
              display: 'flex',
              alignItems: 'center',
              gap: '6px'
            }}
          >
            ← Back
          </button>
          <h2 className="sd-title">Set Downtime</h2>

          <label className="sd-done">
            <input 
              type="checkbox" 
              checked={isCompleted}
              onChange={handleCheckboxChange}
            /> Done?
          </label>

          <div className="sd-section">How to tutorial</div>
          <button className="sd-card sd-card--tall" onClick={() => window.open('https://www.youtube.com/watch?v=kNgdb2ozVkc', '_blank')}>
            <img src="/images/downtime/downtime-tutorial.jpg" alt="How to set downtime tutorial" />
            <span>How to tutorial</span>
          </button>

          <div className="sd-section">Resources</div>
          <button className="sd-card" onClick={() => window.open('https://www.commonsensemedia.org/articles/be-a-role-model-4-ways-to-balance-screen-time-around-children', '_blank')}>
            <img src="/images/downtime/res-be-role-model.jpg" alt="Be a Role Model: 4 Ways to Balance Screen Time Around Children" />
            <span>Be a Role Model: 4 Ways to Balance Screen Time Around Children</span>
          </button>
          <button className="sd-card" onClick={() => window.open('https://www.commonsensemedia.org/articles/are-some-types-of-screen-time-better-than-others', '_blank')}>
            <img src="/images/downtime/res-screen-time-types.jpg" alt="Are Some Types of Screen Time Better Than Others?" />
            <span>Are Some Types of Screen Time Better Than Others?</span>
          </button>
          <button className="sd-card" onClick={() => window.open('https://www.commonsensemedia.org/articles/4-conversations-to-have-with-older-kids-and-teens-about-their-screen-time-habits', '_blank')}>
            <img src="/images/downtime/res-conversations-older-kids.jpg" alt="4 Conversations to Have with Older Kids and Teens About Their Screen Time Habits" />
            <span>4 Conversations to Have with Older Kids and Teens About Their Screen Time Habits</span>
          </button>
        </aside>

        <main className="sd-content">
          <section className="sd-card-main">
            <h3>Setting screen time boundaries</h3>

            <ol className="sd-steps">
              <li>Talk with your partner or caregiver to get on the same page.</li>
              <li>Set a daily screen time limit for each child—split it between weekdays and weekends.</li>
              <li>Create a separate Google or Apple account for your child to turn on parental controls.</li>
              <li>Keep bedrooms screen-free. You can also make places like the dinner table or car screen-free.</li>
              <li>Stay consistent—and connect with other parents doing the same. You’ve got this.</li>
            </ol>
            <div style={{ fontSize: '13px', color: '#94a3b8', fontWeight: 400, marginTop: 8 }}>
              Source: <a href="https://sageparents.org/guidebook/" target="_blank" rel="noopener noreferrer" style={{ color: '#94a3b8', textDecoration: 'underline' }}>Guidebook – Sage Parents</a>
            </div>

            <figure className="sd-figure">
              <img src="/images/downtime/hero-downtime.jpg" alt="Kids using phones on couch" />
              <figcaption>Image from Getty Images</figcaption>
            </figure>
          </section>

          <section className="sd-card-main">
            <h3>Why it helps</h3>
            <p>Set a screen time rule and let technology support you. Use built‑in parental control tools in your devices and apps to make it easier to stay on track.</p>
          </section>

          <section className="sd-card-main">
            <h3>Tips</h3>
            <p>As you set screen time rules, remember that what they watch matters too. (See <a href="/build-watchlist" style={{color: '#007bff', textDecoration: 'underline'}}>"Build a Watch List"</a> for help.)</p>
          </section>
        </main>
      </div>
    </div>
  )
} 
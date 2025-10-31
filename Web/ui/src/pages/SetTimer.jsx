import React, { useState, useEffect } from 'react'
import NavBar from '../components/NavBar.jsx'
import { apiService } from '../services/api.js'
import './set-timer.css'

export default function SetTimer() {
  const [isCompleted, setIsCompleted] = useState(false)
  const actionId = 'set-timer'

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
    <div className="set-timer">
      <NavBar />

      <div className="st-layout">
        <aside className="st-sidebar">
          <button 
            className="st-back-btn" 
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
          <h2 className="st-title">Set a Timer on Youtube</h2>

          <label className="st-done">
            <input 
              type="checkbox" 
              checked={isCompleted}
              onChange={handleCheckboxChange}
            /> Done?
          </label>

          <div className="st-section">How to tutorial</div>
          <button className="st-card st-card--tall" onClick={() => window.open('https://www.youtube.com/watch?v=m8liKZx2DKs', '_blank')}>
            <img src="/images/timer/timer-tutorial.jpg" alt="How to tutorial" />
            <span>How to tutorial</span>
          </button>

          <div className="st-section">Resources</div>
          <button className="st-card" onClick={() => window.open('https://www.commonsensemedia.org/articles/ditch-the-distractions-supporting-kids-and-teens-with-phone-notifications', '_blank')}>
            <img src="/images/timer/timer-resource-phone-notifications.jpg" alt="Ditch the Distractions: Supporting Kids and Teens with Phone Notifications" />
            <span>Ditch the Distractions: Supporting Kids and Teens with Phone Notifications</span>
          </button>
        </aside>

        <main className="st-content">
          <section className="st-card-main">
            <h3>How to do it</h3>
            <ol className="st-steps">
              <li>Tap your profile picture .</li>
              <li>Tap Settings.</li>
              <li>Tap General.</li>
              <li>
                Next to Remind me to take a break, tap the switch on or off.
                <ul className="st-sublist">
                  <li>If switching to On, select your Reminder frequency and tap OK.</li>
                </ul>
              </li>
            </ol>

            <div className="st-screenshot">
              <img src="/images/timer/take-a-break-reminder.png" alt="YouTube take a break reminder UI" />
            </div>
          </section>

          <section className="st-card-main">
            <h3>Why it helps</h3>
            <p>YouTube pops a gentle pause reminder every X minutes—just enough friction to stop rapid-swiping.</p>
          </section>

          <section className="st-card-main">
            <h3>Tips</h3>
            <p>
              When you get a reminder, you can tap to keep watching a video. You can tap Change break reminder to edit the reminder frequency or turn the reminder on or off.
            </p>
            <div className="st-keep-in-mind">Keep in mind:</div>
            <ul className="st-points">
              <li>If you close the app, sign out, switch devices, or pause a video for more than 30 minutes, the timer will reset.</li>
              <li>When watching offline videos or casting from your phone, the timer doesn’t run.</li>
            </ul>
          </section>
        </main>
      </div>
    </div>
  )
} 
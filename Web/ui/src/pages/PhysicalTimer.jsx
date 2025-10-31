import React, { useState, useEffect } from 'react'
import NavBar from '../components/NavBar.jsx'
import { apiService } from '../services/api.js'
import './physical-timer.css'

export default function PhysicalTimer() {
  const [isCompleted, setIsCompleted] = useState(false)
  const actionId = 'physical-timer'

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
    <div className="physical-timer">
      <NavBar />

      <div className="pt-layout">
        <aside className="pt-sidebar">
          <button 
            className="pt-back-btn" 
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
          <h2 className="pt-title">Use a Physical Timer</h2>

          <label className="pt-done">
            <input 
              type="checkbox" 
              checked={isCompleted}
              onChange={handleCheckboxChange}
            /> Done?
          </label>

          <div className="pt-section">Resources</div>
          <button className="pt-card" onClick={() => window.open('https://www.commonsensemedia.org/articles/how-to-share-screen-time-rules-with-relatives-babysitters-and-other-caregivers', '_blank')}>
            <img src="/images/physical/res-share-screen-rules.png" alt="How to Share Screen Time Rules with Relatives, Babysitters, and Other Caregivers" />
            <span>How to Share Screen Time Rules with Relatives, Babysitters, and Other Caregivers</span>
          </button>
          <button className="pt-card" onClick={() => window.open('https://www.commonsensemedia.org/articles/my-kid-seems-addicted-to-their-phone-what-do-i-do', '_blank')}>
            <img src="/images/physical/res-addicted-phone.png" alt="My Kid Seems Addicted to Their Phone. What Do I Do?" />
            <span>My Kid Seems Addicted to Their Phone. What Do I Do?</span>
          </button>
          <button className="pt-card" onClick={() => window.open('https://www.commonsensemedia.org/articles/how-to-prepare-your-kids-for-school-after-a-summer-of-screen-time', '_blank')}>
            <img src="/images/physical/res-prepare-after-summer.png" alt="How to Prepare Your Kids for School After a Summer of Screen Time" />
            <span>How to Prepare Your Kids for School After a Summer of Screen Time</span>
          </button>
          <button className="pt-card" onClick={() => window.open('https://www.washingtonpost.com/technology/interactive/2024/kids-screen-time-quiz-recommendations-age/', '_blank')}>
            <img src="/images/physical/res-wapo-screen-quiz.png" alt="Washington Post: Kids' Screen Time Quiz" />
            <span>Washington Post: Kids' Screen Time Quiz & Recommendations by Age</span>
          </button>
        </aside>

        <main className="pt-content">
          <section className="pt-card-main">
            <h3>How to do it</h3>
            <ol className="pt-steps">
              <li>
                Place a kitchen timer—or any physical timer—in a shared space like the living room, where everyone (parents and children) can see it. Set a clear, visible screen time limit as a public family commitment.
              </li>
              <li>
                As a general guide, the UK's recommended screen time limits are:
                <ul className="pt-sublist">
                  <li>Ages 0–2: No screen time (except for video calls)</li>
                  <li>Ages 2–5: Up to 1 hour per day</li>
                  <li>Ages 6–12: Up to 2 hours per day</li>
                  <li>Ages 13+: Ideally no more than 2 hours per day</li>
                </ul>
                <div style={{ fontSize: '13px', color: '#94a3b8', fontWeight: 400, marginTop: 8 }}>
                  * These UK guidelines are based on recent child-digital well being research and are widely used in studies on healthy media habits.<br/>
                  (Source: <a href="https://kids-first.com.au/recommended-screen-time-limits-children/" target="_blank" rel="noopener noreferrer" style={{ color: '#94a3b8', textDecoration: 'underline' }}>How Much Screen Time is Too Much? Practical Guidelines for Parents - Kids First Children's Services</a>)
                </div>
              </li>
            </ol>
          </section>

          <section className="pt-card-main">
            <h3>Why it helps</h3>
            <p>Provides a tangible endpoint instead of relying on an in‑app service that kids can ignore.</p>
          </section>

          <section className="pt-card-main">
            <h3>Tips</h3>
            <p>
              Sometimes, children struggle with discipline simply because the rules around when to stop aren’t clear or consistent.
            </p>
            <figure className="pt-figure">
              <img src="/images/physical/hero-physical-timer.png" alt="Kids using devices with a visible timer on table" />
              <figcaption style={{ fontSize: '13px', color: '#94a3b8', fontWeight: 400, marginTop: 4 }}>Image from TIME TIMER</figcaption>
            </figure>
            <p>
              By setting clear, physical boundaries (like a timer or a visual schedule) parents and children can better communicate when it’s time to watch YouTube and when it’s time to stop. This not only reduces confusion but also helps children learn important values like keeping promises, taking responsibility, and practicing self‑discipline.
            </p>
          </section>
        </main>
      </div>
    </div>
  )
} 
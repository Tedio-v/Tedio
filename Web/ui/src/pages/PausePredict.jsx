import React, { useState, useEffect } from 'react'
import NavBar from '../components/NavBar.jsx'
import { apiService } from '../services/api.js'
import './pause-predict.css'

export default function PausePredict() {
  const [isCompleted, setIsCompleted] = useState(false)
  const actionId = 'pause-predict'

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
    <div className="pause-predict">
      <NavBar />

      <div className="pp-layout">
        <aside className="pp-sidebar">
          <button 
            className="pp-back-btn" 
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
          <h2 className="pp-title">Pause & Predict</h2>
          <label className="pp-done">
            <input 
              type="checkbox" 
              checked={isCompleted}
              onChange={handleCheckboxChange}
            /> Done?
          </label>

          <div className="pp-section">Resources</div>

          <button className="pp-resource" onClick={() => window.open('https://www.commonsensemedia.org/articles/what-are-the-deep-web-and-the-dark-web', '_blank')}>
            <img src="/images/pp-resource-darkweb.jpg" alt="What Are the Deep Web and the Dark Web?" />
            <span>What Are the Deep Web and the Dark Web?</span>
          </button>

          <button className="pp-resource" onClick={() => window.open('https://www.commonsensemedia.org/articles/why-watching-tv-and-movies-is-better-together', '_blank')}>
            <img src="/images/pp-resource-tv-better.jpg" alt="Why Watching TV and Movies Is Better Together" />
            <span>Why Watching TV and Movies Is Better Together</span>
          </button>
        </aside>

        <main className="pp-content">
          <section className="pp-card">
            <h3>How to do it</h3>
            <p><strong>Make a household rule to think 30 seconds:</strong></p>
            <ol className="pp-steps">
              <li>Read the title aloud (with parents' help depending on the age)</li>
              <li>What is this video probably about?</li>
              <li>Why do I want to click on this video?</li>
              <li>Do I see any sign of untrustworthiness or danger from the Thumbnail or the creator?</li>
            </ol>
          </section>

          <section className="pp-card">
            <h3>Tips</h3>
            <p><strong>Frame this exercise as A COOL BRAIN CHALLENGE (fidget!)</strong></p>
            <p>
              Teach children about the value of intentionality. If kids learn and train practicing intention from the young age, this could significantly impact their social media viewing habits (what am I viewing and why I want to view this?) and could help build life-long muscle to think intentionally.
            </p>
          </section>

          <section className="pp-card">
            <h3>Quick Exercise</h3>
            <div className="pp-video">
              <img src="/images/pp-exercise-thumb.jpg" alt="Cocomelon video example" />
            </div>

            <div className="pp-after">After seeing the above thumbnail for 10s, discuss:</div>
            <ol className="pp-points">
              <li>
                <strong>Title Time:</strong> “Let’s read the title together. What words jump out?” (Parent reads if needed.)
              </li>
              <li>
                <strong>Guess the Story:</strong> “Take one guess: ‘I think this video will show…’”
              </li>
              <li>
                <strong>Check Your Why:</strong> “Why do you want to watch it? Curious? Bored? Excited?”
              </li>
              <li>
                <strong>Safety Scan:</strong> “Look at the picture. Any uh-oh signs (ex: scary faces, ALL-CAPS, ‘Prank gone wrong’)? Thumbs-up if safe, thumbs-down if not sure.”
              </li>
              <li>
                <strong>Decide Together:</strong> “Watch now, watch with a parent, or swipe away?”
              </li>
            </ol>
          </section>
        </main>
      </div>
    </div>
  )
} 
import React, { useState, useEffect } from 'react'
import NavBar from '../components/NavBar.jsx'
import { apiService } from '../services/api.js'
import './waiting-time-kit.css'

export default function WaitingTimeKit() {
  const [isCompleted, setIsCompleted] = useState(false)
  const actionId = 'waiting-time-kit'

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
    <div className="waiting-kit">
      <NavBar />

      <div className="wk-layout">
        <aside className="wk-sidebar">
          <button 
            className="wk-back-btn" 
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
          <h2 className="wk-title">Make a Waiting Time Kit</h2>

          <label className="wk-done">
            <input 
              type="checkbox" 
              checked={isCompleted}
              onChange={handleCheckboxChange}
            /> Done?
          </label>

          <div className="wk-section">How to tutorial</div>
          <button className="wk-card wk-card--tall" onClick={() => window.open('https://www.youtube.com/watch?v=pbiu1_nYFSQ', '_blank')}>
            <img src="/images/kit/kit-tutorial.jpg" alt="How to make a waiting time kit tutorial" />
            <span>How to tutorial</span>
          </button>

          <div className="wk-section">Resources</div>
          <button className="wk-card" onClick={() => window.open('https://www.commonsensemedia.org/articles/how-to-raise-a-reader', '_blank')}>
            <img src="/images/kit/res-keep-kids-busy.jpg" alt="How to raise a reader" />
            <span>How to raise a reader</span>
          </button>
        </aside>

        <main className="wk-content">
          <section className="wk-card-main">
            <h3>How to do it</h3>
            <ol className="wk-steps">
              <li>Grab a small pouch, ziplock bag, or mini tote that your child can carry or keep in your car/purse.</li>
              <li>Pick 3–5 lightweight, screen‑free items: a tiny puzzle, a pop‑it toy, small book, crayons + paper, stickers, or a scavenger list.</li>
              <li>Customize based on your child's interests — rotate items every few weeks so the kit feels fresh.</li>
              <li>Add one "slow‑down" item: like a calming audio playlist, gratitude prompts, or coloring pages about emotions.</li>
              <li>Keep it handy for idle moments like waiting in line, at restaurants, doctor's offices, or in the car.</li>
            </ol>
            
            <figure className="wk-figure">
              <img src="/images/kit/res-raise-a-reader.jpg" alt="How to raise a reader" />
              <figcaption>Image from Connie Park</figcaption>
            </figure>
          </section>

          <section className="wk-card-main">
            <h3>Why it helps</h3>
            <p>Gives children an offline alternative during micro‑idle moments. Works better for younger kids under 5, BUT carrying books can work for all ages. Time to complete: 5–10 minutes.</p>
          </section>

          <section className="wk-card-main">
            <h3>Tips</h3>
            <ul className="wk-points">
              <li>Make it a shared activity: Let your child help "build" their kit for a sense of control and ownership.</li>
              <li>Pair the kit with a habit cue — for example, say: "We pull this out while we wait!" to replace default screen time.</li>
              <li>Normalize boredom: Remind kids (and yourself!) that micro‑boredom is okay and builds patience and imagination.</li>
              <li>For older kids, consider a small journal, trivia cards, or a pocket sketchbook instead of toys.</li>
            </ul>
          </section>
        </main>
      </div>
    </div>
  )
} 
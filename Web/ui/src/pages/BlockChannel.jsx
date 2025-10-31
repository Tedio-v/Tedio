import React, { useState, useEffect } from 'react'
import NavBar from '../components/NavBar.jsx'
import { apiService } from '../services/api.js'
import './block-channel.css'

export default function BlockChannel() {
  const [isCompleted, setIsCompleted] = useState(false)
  const actionId = 'block-channel'

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
    <div className="block-channel">
      <NavBar />

      <div className="bc-layout">
        <aside className="bc-sidebar">
          <button 
            className="bc-back-btn" 
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
          <h2 className="bc-title">Block a Channel</h2>

          <label className="bc-done">
            <input 
              type="checkbox" 
              checked={isCompleted}
              onChange={handleCheckboxChange}
            /> Done?
          </label>

          <div className="bc-section">How to tutorial</div>
          <button className="bc-card bc-card--tall" onClick={() => window.open('https://www.youtube.com/watch?v=spCYR59Hbbo', '_blank')}>
            <img src="/images/block/block-tutorial.jpg" alt="How to block a YouTube channel tutorial" />
            <span>How to tutorial</span>
          </button>
        </aside>

        <main className="bc-content">
          <section className="bc-card-main">
            <h3>How to do it</h3>
            <ol className="bc-steps">
              <li>
                Remove an entire channel:
                <ol className="bc-sublist">
                  <li>From your HOME SCREEN dashboard, tap More (⋮) next to the video title you'd like to remove.</li>
                  <li>Select <strong>Don't recommend channel</strong>.</li>
                </ol>
              </li>
              <li>
                Remove a single video from recommendations:
                <ol className="bc-sublist">
                  <li>Go to the recommended video you'd like to remove.</li>
                  <li>Tap the More (⋮) button next to the video title.</li>
                  <li>Select <strong>Not interested</strong>.</li>
                  <li>Tell us why — choose from options like "I've already watched this" or "I don't like this video."</li>
                </ol>
              </li>
              <li>
                Turn ON Approved Content Only (only for YouTube Kids):
                <ol className="bc-sublist">
                  <li>Open YouTube Kids on your child's device.</li>
                  <li>Tap the lock icon (bottom corner) → solve the math or enter your passcode.</li>
                  <li>Go to Settings → select your child's profile → enter your parent password if asked.</li>
                  <li>Tap Edit settings (under "Content settings").</li>
                  <li>Choose <strong>Approve content yourself</strong> and confirm.</li>
                  <li>Select the channels/videos/collections you want to allow → tap Done.</li>
                </ol>
              </li>
              <li>
                Checkout <strong>"Build a Watch List"</strong> for a starter list of high quality channels to approve
              </li>
            </ol>
          </section>

          <section className="bc-card-main">
            <h3>Why it helps</h3>
            <p>This process trains the YouTube algorithm away from junk content. Instantly removes that content creator from your child’s feed — no more similar videos from them in the future.</p>

            <figure className="bc-figure">
              <img src="/images/block/block-hero.jpg" alt="Family watching together" />
              <figcaption>Image from Buena Vista Pictures</figcaption>
            </figure>
          </section>

          <section className="bc-card-main">
            <h3>Tips</h3>
            <p>This works best when done with your child. It shows them why certain content isn’t ideal — and that they have power over their feed.</p>
            <p>
              Make it a <strong>monthly ritual</strong>: Sit down and scan the homepage with your child — talk through what to keep and what to toss.
            </p>
          </section>

          <section className="bc-card-main">
            <h3>Content Rubric</h3>
            <p className="bc-source">
              Source: <a href="https://sageparents.org/guidebook/" target="_blank" rel="noopener noreferrer">Guidebook — Sage Parents</a>
            </p>

            <div className="bc-table-wrap">
              <table className="bc-table">
                <thead>
                  <tr>
                    <th>Types of Content to Limit/Avoid</th>
                    <th>Rationale from Child Development Experts</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>Style & beauty content (intended for teenagers)</td>
                    <td>
                      A lot of style and beauty content is intended for teenagers and adults. When young girls under 12 years old watch these videos, they often mimic this older behavior and “grow up more quickly.” Age-appropriate content is fine, but be cautious of GRWM content intended for teenagers.
                    </td>
                  </tr>
                  <tr>
                    <td>“Overconsumption” content</td>
                    <td>
                      Overconsumption content includes videos of kids buying toys, sharing clothing “hauls,” etc. Exposing kids to excessive consumption can lead to feelings of insufficiency and unhealthy social comparisons.
                    </td>
                  </tr>
                  <tr>
                    <td>Vlog-style content</td>
                    <td>
                      Many vlog-style videos include someone recording their own personal experiences throughout the day and “broadcasting” their life. Kids mimic this and want to record their every move with friends online, leading to broadcast culture and increased social comparison.
                    </td>
                  </tr>
                  <tr>
                    <td>Violent content</td>
                    <td>
                      Violent imagery and videos can be alarming or gory. Kids are especially vulnerable—violent imagery can negatively impact their mental health.
                    </td>
                  </tr>
                  <tr>
                    <td>Overtly sexual content</td>
                    <td>
                      Exposing kids to mature content can negatively impact their mental health. Try to limit overtly sexual content including certain celebrity videos, etc.
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </section>
        </main>
      </div>
    </div>
  )
} 
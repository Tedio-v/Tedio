import React, { useState, useEffect } from 'react'
import NavBar from '../components/NavBar.jsx'
import { apiService } from '../services/api.js'
import './remove-shorts.css'

export default function RemoveShorts() {
  const [isCompleted, setIsCompleted] = useState(false)
  const actionId = 'remove-shorts'

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
    <div className="remove-shorts">
      <NavBar />

      <div className="rs-layout">
        <aside className="rs-sidebar">
          <button 
            className="rs-back-btn" 
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
          <h2 className="rs-title">Remove Shorts from Home</h2>

          <label className="rs-done">
            <input 
              type="checkbox" 
              checked={isCompleted}
              onChange={handleCheckboxChange}
            /> Done?
          </label>

          <div className="rs-section">How to tutorial</div>
          <button className="rs-card rs-card--tall" onClick={() => window.open('https://www.youtube.com/watch?v=LLrb7N_0HSs', '_blank')}>
            <img src="/images/shorts/shorts-tutorial.jpg" alt="How to remove shorts tutorial" />
            <span>How to tutorial</span>
          </button>

          <div className="rs-section">Resources</div>
          <button className="rs-card" onClick={() => window.open('https://www.commonsensemedia.org/articles/cellphones-and-devices-a-guide-for-parents-and-caregivers', '_blank')}>
            <img src="/images/shorts/res-cellphones-devices.jpg" alt="Cellphones and Devices: A Guide for Parents and Caregivers" />
            <span>Cellphones and devices</span>
          </button>
          <button className="rs-card" onClick={() => window.open('https://www.commonsensemedia.org/articles/who-is-collecting-my-kids-data-and-what-are-they-doing-with-it', '_blank')}>
            <img src="/images/shorts/res-who-collects-kids-data.jpg" alt="Who is collecting my kid's data" />
            <span>Who collects kids data</span>
          </button>
        </aside>

        <main className="rs-content">
          <section className="rs-card-main">
            <h3>How to do it</h3>
            <ol className="rs-steps">
              <li>On YouTube, navigate to your Home screen.</li>
              <li>Find the Shorts section.</li>
              <li>Click the three vertical dots.</li>
              <li>
                Click Not Interested.
                <ul className="rs-sublist">
                  <li>Time to complete: ~1 minute</li>
                </ul>
              </li>
              <li>
                Repeat this process for every shorts you see on the screen
              </li>
              <li>
                If you want to remove the Shorts section entirely, go to Settings &gt; General &gt; Shorts and toggle it off.
                <ul className="rs-sublist">
                  <li>Time to complete: ~1 minute</li>
                </ul>
              </li>
            </ol>
          </section>

          <section className="rs-card-main">
            <h3>Why it helps</h3>
            <p>Making Shorts less accessible in the first place helps prevent mindlessly entering the endless loop. This encourages intentional viewing.</p>
          </section>

          <section className="rs-card-main">
            <h3>Tips</h3>
            <div className="rs-bubble">
              <div className="rs-bubble-title">You can say something like:</div>
              <p><strong>"There are a lot of fun things in the world!"</strong></p>
              <p>
                Imagine last time you found something interesting on the street, at school, or any places: whether it be watching ants walking in straight line or looking up to the sky to see different airplanes, imagining where they go…
              </p>
              <p>
                If you don't stop being curious and look at the world with playful eyes, there are so many funs you can appreciate. (and compliment children's inherent curiosity here with real examples in the past)
              </p>
              <p>
                However, these videos on screen flashy and cool are designed to take our attention away. Although they may look and feel more interesting, they can weaken your ability to appreciate cute, fun, and interesting pieces, especially in the real world!
              </p>
              <p>
                YouTube is fun but do you want it to take away your curious and playful mind? Let's remind ourselves how precious our curious mind is and the little fun things that are hiding around us that we can only find when we see the world with curiosity.
              </p>
              <p>
                <strong>The number of joyful and fun things you can enjoy will increase hundred times when we keep our curiosity and sensitivity to small things :)</strong>
              </p>
            </div>
          </section>
        </main>
      </div>
    </div>
  )
} 
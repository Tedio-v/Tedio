import React, { useState, useEffect } from 'react'
import NavBar from '../components/NavBar.jsx'
import { apiService } from '../services/api.js'
import './remove-devices.css'

export default function RemoveDevices() {
  const [isCompleted, setIsCompleted] = useState(false)
  const actionId = 'remove-devices'

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
    <div className="remove-devices">
      <NavBar />

      <div className="br-layout">
        <aside className="br-sidebar">
          <button 
            className="br-back-btn" 
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
          <h2 className="br-title">Remove Devices from the Bedroom + Offline Routine</h2>

          <label className="br-done">
            <input 
              type="checkbox" 
              checked={isCompleted}
              onChange={handleCheckboxChange}
            /> Done?
          </label>

          <div className="br-section">Resources</div>
          <button className="br-card br-card--tall" onClick={() => window.open('https://www.commonsensemedia.org/articles/how-to-help-kids-balance-phones-and-screens-with-sleep', '_blank')}>
            <img src="/images/bedroom/res-balance-phones-sleep.jpg" alt="How to Help Kids Balance Phones and Screens with Sleep" />
            <span>How to Help Kids Balance Phones and Screens with Sleep</span>
          </button>
          <button className="br-card br-card--tall" onClick={() => window.open('https://www.commonsensemedia.org/articles/how-to-raise-a-reader', '_blank')}>
            <img src="/images/bedroom/res-raise-a-reader.jpg" alt="How to Raise a Reader" />
            <span>How to Raise a Reader</span>
          </button>
          <button className="br-card br-card--tall" onClick={() => window.open('https://www.babysensemonitors.com/blogs/news/the-power-of-bedtime-best-stories-and-activities-for-kids', '_blank')}>
            <img src="/images/bedroom/res-power-of-bedtime.jpg" alt="The Power of Bedtime: Best Stories and Activities for Kids" />
            <span>The Power of Bedtime: Best Stories and Activities for Kids</span>
          </button>
        </aside>

        <main className="br-content">
          <section className="br-card-main">
            <h3>How to do it</h3>
            <ol className="br-steps">
              <li>Pick a new charging spot — choose a neutral, shared space like the kitchen counter or living room shelf.</li>
              <li>
                Communicate the change clearly and kindly:
                <div className="br-quote">“Phones sleep in the kitchen so our brains can rest, too.”</div>
              </li>
              <li>Create a bedtime basket for devices if needed. Label it “tech bedtime” to normalize the habit.</li>
              <li>Set a consistent hand-off time, like “8:30 p.m. is tech tuck-in.”</li>
              <li>Lead by example — parents’ devices go in the basket too!</li>
            </ol>

            <h4 className="br-subheading">Soothing Activity Pairing</h4>
            <p>When turning the device off (especially before bed), immediately follow with a calm offline routine so the transition feels comforting, not abrupt.</p>
            <div className="br-examples-title">Examples:</div>
            <ul className="br-bullets">
              <li>Parent-read bedtime story 📖 (no screens — so the last input before sleep is your voice and imagination, not a video).</li>
              <li>Quiet music or lullabies 🎵 (low volume, slow tempo).</li>
              <li>Gentle drawing or coloring 🎨 (soft lighting, minimal conversation).</li>
              <li>Simple puzzle or tactile toy ✨ (fidgets, soft blocks).</li>
              <li>Guided relaxation 🍃 (deep breaths together or short mindfulness exercise).</li>
            </ul>

            <figure className="br-figure">
              <img src="/images/bedroom/hero-bedtime-reading.jpg" alt="Parent and child reading at bedtime" />
              <figcaption>Image from Babysense</figcaption>
            </figure>
          </section>

          <section className="br-card-main">
            <h3>Why it helps</h3>
            <ul className="br-bullets">
              <li>Signals a consistent “wind-down” cue to the brain.</li>
              <li>Prevents stimulating content from being the final experience before sleep.</li>
              <li>Strengthens positive parent–child connection during the transition.</li>
            </ul>
          </section>

          <section className="br-card-main">
            <h3>Tips 💬</h3>
            <p>Kids mirror adult behavior — if your phone stays in the bedroom, it’s harder to justify the rule.</p>
            <p>Let your child pick a wind-down replacement: a book, nightlight, music, or podcast.</p>
            <p>Use charging cables with limited range to discourage sneaky overnight use.</p>
            <p>
              If resistance is high, <strong>transition slowly</strong>: start with just weekends or one night per week. Sleep is so important to kids’ development (including mental and physical health), so it is important to keep screens out of your kids’ bedrooms at night.
            </p>
          </section>
        </main>
      </div>
    </div>
  )
} 
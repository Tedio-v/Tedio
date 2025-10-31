import React, { useState, useEffect } from 'react'
import NavBar from '../components/NavBar.jsx'
import { apiService } from '../services/api.js'
import './time-together.css'

export default function TimeTogether() {
  const [isCompleted, setIsCompleted] = useState(false)
  const actionId = 'time-together'

  useEffect(() => {
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
      event.target.checked = !checked
    }
  }
  return (
    <div className="time-together">
      <NavBar />

      <div className="tt-layout">
        <aside className="tt-sidebar">
          <button 
            className="tt-back-btn" 
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
          <h2 className="tt-title">Time Together</h2>

          <label className="tt-done">
            <input 
              type="checkbox" 
              checked={isCompleted}
              onChange={handleCheckboxChange}
            /> Done?
          </label>

          <div className="tt-section">Resources</div>
          <button className="tt-card tt-card--tall" onClick={() => window.open('https://offline.kids/activities/', '_blank')}>
            <img src="/images/together/res-activities-100.jpg" alt="100+ screen-free activities for kids" />
            <span>100+ Screen-Free Activities for Kids</span>
          </button>
          <button className="tt-card tt-card--tall" onClick={() => window.open('https://www.commonsensemedia.org/articles/screen-free-activities-for-kids-and-teens-to-enjoy-over-the-summer', '_blank')}>
            <img src="/images/together/res-activities-summer.jpg" alt="Screen-free activities for kids and teens to enjoy over the summer" />
            <span>Screen-Free Activities for Kids and Teens to Enjoy Over the Summer</span>
          </button>
        </aside>

        <main className="tt-content">
          <section className="tt-card-main">
            <h3>How to do it</h3>
            <ol className="tt-steps">
              <li>Observe when your child is about to dive into screen time out of boredom or habit.</li>
              <li>
                Offer a warm alternative with a smile:
                <div className="tt-quote">“Hey, let’s take a silly walk to the park together,” or</div>
                <div className="tt-quote">“Want to snuggle up and watch a movie with me instead?”</div>
              </li>
            </ol>
            <p className="tt-note">Tip: Get kids outside as much as you can. Research shows that kids who have more physical activity and outdoor play have better relationships with peers.</p>
            <ol start={3} className="tt-steps">
              <li>Keep it specific and short-term — the activity should sound easy and fun.</li>
              <li>Match their energy level: Choose something calm if they seem tired or something active if they’re fidgety.</li>
              <li>Celebrate the switch with affirming language: “That was fun! I’m glad we did that together.”</li>
            </ol>

            <figure className="tt-figure">
              <img src="/images/together/hero-time-together.jpg" alt="Family spending time together" />
              <figcaption>Image from Pathways</figcaption>
            </figure>
          </section>

          <section className="tt-card-main">
            <h3>Why it helps</h3>
            <p>
              Research shows that when kids lead their own play—especially creative or adventurous play—they build better focus, emotional control, and mental health over time. But playtime is shrinking. As children grow, play often gets pushed aside for screens or packed schedules.
            </p>
            <p>
              Kids up to age 12 (and beyond) still need lots of free, tech-free playtime—not just sports or structured activities. This kind of play can include art, puzzles, cooking, made-up games, or kicking a ball around. Whether it's alone, with siblings, or friends, unstructured play is key to healthy development—and it's worth protecting. <strong>Source:</strong> <a href="https://sageparents.org/guidebook/" target="_blank" rel="noopener noreferrer">Guidebook — Sage Parents</a>
            </p>
            <p>
              Kids are more likely to say “yes” to together-time if it feels genuinely fun, not like a <strong>forced replacement</strong>.
            </p>
            <p>
              Use small rituals — Friday movie night, walk after dinner, weekend waffles — to <strong>build routines that feel special</strong>.
            </p>
            <p>
              Even 15 minutes of shared time can meet a child’s need for connection and reduce their urge to fill space with solo screen use.
            </p>
            <p>
              Frame it as “doing something cool with you” — not “taking the screen away.”
            </p>
          </section>
        </main>
      </div>
    </div>
  )
} 
import React, { useState, useEffect } from 'react'
import NavBar from '../components/NavBar.jsx'
import { apiService } from '../services/api.js'
import './build-watchlist.css'

export default function BuildWatchlist() {
  const [isCompleted, setIsCompleted] = useState(false)
  const actionId = 'build-watchlist'

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
    <div className="watchlist">
      <NavBar />

      <div className="wl-layout">
        <aside className="wl-sidebar">
          <button 
            className="wl-back-btn" 
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
          <h2 className="wl-title">Build a Watchlist</h2>

          <label className="wl-done">
            <input 
              type="checkbox" 
              checked={isCompleted}
              onChange={handleCheckboxChange}
            /> Done?
          </label>

          <div className="wl-section">How to tutorial</div>
          <button className="wl-card wl-card--tall" onClick={() => window.open('https://www.youtube.com/watch?v=pbiu1_nYFSQ', '_blank')}>
            <img src="/images/watchlist/tutorial-create-playlist.jpg" alt="How to create a playlist" />
            <span>How to create a playlist</span>
          </button>

          <div className="wl-section">Resources</div>
          <button className="wl-card" onClick={() => window.open('https://www.commonsensemedia.org/articles/sensical-selections-for-kids', '_blank')}>
            <img src="/images/watchlist/res-playlists-sensical.jpg" alt="15 awesome video playlists by Sensical" />
            <span>15 awesome video playlists by Sensical</span>
          </button>
          <button className="wl-card" onClick={() => window.open('https://www.commonsensemedia.org/youtube-kids-channels-by-topic', '_blank')}>
            <img src="/images/watchlist/res-kids-channels.jpg" alt="YouTube Kids Channels by Topic" />
            <span>YouTube Kids Channels by Topic</span>
          </button>
          <button className="wl-card" onClick={() => window.open('https://www.commonsensemedia.org/articles/the-best-kids-entertainment-of-2024', '_blank')}>
            <img src="/images/watchlist/res-best-entertainment-2024.jpg" alt="The Best Kids' Entertainment of 2024" />
            <span>The Best Kids' Entertainment of 2024</span>
          </button>
          <button className="wl-card" onClick={() => window.open('https://www.commonsensemedia.org/articles/how-to-help-kids-build-character-strengths-with-quality-media', '_blank')}>
            <img src="/images/watchlist/res-build-character-strengths.jpg" alt="How to Help Kids Build Character Strengths with Quality Media" />
            <span>How to Help Kids Build Character Strengths with Quality Media</span>
          </button>
          <button className="wl-card" onClick={() => window.open('https://www.commonsensemedia.org/articles/how-to-tell-if-an-app-or-a-website-is-good-for-learning', '_blank')}>
            <img src="/images/watchlist/res-good-app-learning.jpg" alt="How to Tell if an App is Good for Learning" />
            <span>How to Tell if an App is Good for Learning</span>
          </button>
        </aside>

        <main className="wl-content">
          <section className="wl-card-main">
            <h3>How to do it</h3>
            <ol className="wl-steps">
              <li>Check out the right expert-curated playlists and contents on the left</li>
              <li>
                Add them to your YouTube playlist (
                <a href="https://www.youtube.com/watch?v=pbiu1_nYFSQ" target="_blank" rel="noreferrer">
                  tutorial
                </a>
                ) or save the playlist to watch for later
              </li>
            </ol>
            <p className="wl-tip">Tip: Press “like” or subscribe to the channel that parents actually liked so that the algorithm can recommend similar content.</p>

            <figure className="wl-figure">
              <img src="/images/watchlist/hero-family-hug.jpg" alt="Family-friendly movie still" />
              <figcaption>Image from Pixar</figcaption>
            </figure>
          </section>

          <section className="wl-card-main">
            <h3>Why it helps</h3>
            <p>
              It’s better to pause a good full-length video than to watch many low-quality shorts. Think about films you’ve enjoyed and would want to share with your child, or YouTube channels recommended by teachers.
            </p>
            <p>
              This doesn’t need to be complicated—simply note down these suggestions when you come across them and add them to a YouTube playlist. Here are some suggestions by Common Sense in case you are actively searching for resources.
            </p>
            <p>
              Parents and kids can do this <strong>together</strong>: they talk about what videos are good, why they are good, how does such video make kids feel, why should kids not watch video, etc.
            </p>
          </section>

          <section className="wl-card-main">
            <h3>Tips</h3>
            <ol className="wl-steps">
              <li>Kids learn more when you watch together. If you can’t, asking about the show later is still a great way to connect.</li>
              <li>Use Common Sense Media to check if a show, game, or video is age-appropriate.</li>
              <li>Avoid leaving the TV on in the background—it can affect focus and mood.</li>
              <li>Be mindful of harmful themes. Sage Parents’s Content Rubric can help you spot what to avoid.</li>
            </ol>
          </section>

          <section className="wl-card-main">
            <h3>Content Rubric</h3>
            <p className="wl-source">
              Source:
              {' '}
              <a href="https://sageparents.org/guidebook/" target="_blank" rel="noopener noreferrer">Guidebook — Sage Parents</a>
            </p>
            <div className="wl-table-wrap">
              <table className="wl-table">
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
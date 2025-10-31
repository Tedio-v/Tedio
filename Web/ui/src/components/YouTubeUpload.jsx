// ABOUTME: YouTube history upload component for processing watch history data
// ABOUTME: Handles file upload, validation, and insight generation from YouTube data

import { useState } from 'react'
import { apiService } from '../services/api.js'

export default function YouTubeUpload({ onUploadSuccess }) {
  const [uploading, setUploading] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')

  const handleFileUpload = async (event) => {
    const file = event.target.files[0]
    if (!file) return

    setUploading(true)
    setError('')
    setSuccess('')

    try {
      const text = await file.text()
      let historyData

      try {
        historyData = JSON.parse(text)
      } catch (parseError) {
        throw new Error('Invalid JSON file. Please upload a valid YouTube history JSON file.')
      }

      if (!Array.isArray(historyData)) {
        throw new Error('YouTube history should be an array of videos.')
      }

      await apiService.uploadYouTubeHistory(historyData)
      setSuccess(`Successfully uploaded ${historyData.length} history items.`)
      
      setSuccess(prev => prev + ' Generating insights...')
      await apiService.generateInsights(historyData)
      setSuccess(prev => prev.replace(' Generating insights...', ' Insights generated successfully!'))
      
      onUploadSuccess?.()
      
    } catch (err) {
      setError(err.message)
      console.error('Upload error:', err)
    } finally {
      setUploading(false)
    }
  }

  return (
    <div style={{ 
      border: '2px dashed #ccc', 
      borderRadius: '8px', 
      padding: '2rem', 
      textAlign: 'center',
      margin: '1rem 0'
    }}>
      <h3>Upload YouTube History</h3>
      <p>Upload your YouTube history JSON file to generate insights</p>
      
      {error && (
        <div style={{ 
          color: 'red', 
          marginBottom: '1rem', 
          padding: '0.5rem', 
          backgroundColor: '#fee', 
          borderRadius: '4px' 
        }}>
          {error}
        </div>
      )}

      {success && (
        <div style={{ 
          color: 'green', 
          marginBottom: '1rem', 
          padding: '0.5rem', 
          backgroundColor: '#efe', 
          borderRadius: '4px' 
        }}>
          {success}
        </div>
      )}

      <input
        type="file"
        accept=".json"
        onChange={handleFileUpload}
        disabled={uploading}
        style={{ marginBottom: '1rem' }}
      />
      
      {uploading && <p>Uploading and processing...</p>}
      
      <div style={{ marginTop: '1rem', fontSize: '0.9em', color: '#666' }}>
        <p>To get your YouTube history:</p>
        <ol style={{ textAlign: 'left', display: 'inline-block' }}>
          <li>Go to <a href="https://takeout.google.com" target="_blank">Google Takeout</a></li>
          <li>Select YouTube and YouTube Music</li>
          <li>Choose "history" in the options</li>
          <li>Download and extract the JSON file</li>
          <li>Upload the "watch-history.json" file here</li>
        </ol>
      </div>
    </div>
  )
}
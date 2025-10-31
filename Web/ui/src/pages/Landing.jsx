import React from 'react'
import './landing.css'

export default function Landing({ onGetStarted }) {
  return (
    <div className="landing">
      <div className="landing__overlay" />
      <div className="landing__content">
        <h1 className="landing__title">Welcome to Tedio</h1>
        <p className="landing__subtitle">
          Gain insights into your child's online behavior and foster healthy digital habits. Tedio helps you understand your child's digital world, providing emotional support and valuable insights.
        </p>
        <button className="landing__cta" onClick={onGetStarted}>
          Get Started
        </button>
      </div>
    </div>
  )
} 
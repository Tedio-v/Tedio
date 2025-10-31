// ABOUTME: Error boundary component to catch and display React errors gracefully
// ABOUTME: Provides fallback UI when component tree encounters errors

import React from 'react'

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props)
    this.state = { hasError: false, error: null, errorInfo: null }
  }

  static getDerivedStateFromError(error) {
    return { hasError: true }
  }

  componentDidCatch(error, errorInfo) {
    this.setState({
      error: error,
      errorInfo: errorInfo
    })
  }

  render() {
    if (this.state.hasError) {
      return (
        <div style={{
          minHeight: '100vh',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          backgroundColor: '#f9fafb'
        }}>
          <div style={{
            backgroundColor: 'white',
            boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
            borderRadius: '0.75rem',
            padding: '2rem',
            maxWidth: '32rem',
            textAlign: 'center'
          }}>
            <div style={{
              fontSize: '1.5rem',
              fontWeight: 'bold',
              color: '#ef4444',
              marginBottom: '1rem'
            }}>
              Oops! Something went wrong
            </div>
            <p style={{
              color: '#6b7280',
              marginBottom: '1rem'
            }}>
              We encountered an error while loading this page. Please try refreshing or go back to the home page.
            </p>
            <div style={{
              display: 'flex',
              gap: '1rem',
              justifyContent: 'center'
            }}>
              <button
                onClick={() => window.location.reload()}
                style={{
                  backgroundColor: '#2563eb',
                  color: 'white',
                  padding: '0.5rem 1rem',
                  borderRadius: '0.375rem',
                  border: 'none',
                  cursor: 'pointer',
                  fontWeight: 'bold'
                }}
              >
                Refresh Page
              </button>
              <button
                onClick={() => window.location.href = '/'}
                style={{
                  backgroundColor: '#6b7280',
                  color: 'white',
                  padding: '0.5rem 1rem',
                  borderRadius: '0.375rem',
                  border: 'none',
                  cursor: 'pointer',
                  fontWeight: 'bold'
                }}
              >
                Go Home
              </button>
            </div>
            {process.env.NODE_ENV === 'development' && this.state.error && (
              <details style={{ 
                marginTop: '1rem', 
                textAlign: 'left',
                backgroundColor: '#fee',
                padding: '1rem',
                borderRadius: '0.375rem',
                fontSize: '0.875rem'
              }}>
                <summary style={{ fontWeight: 'bold', marginBottom: '0.5rem' }}>
                  Error Details (Development)
                </summary>
                <pre style={{ 
                  whiteSpace: 'pre-wrap', 
                  wordBreak: 'break-word',
                  margin: 0
                }}>
                  {this.state.error && this.state.error.toString()}
                  <br />
                  {this.state.errorInfo.componentStack}
                </pre>
              </details>
            )}
          </div>
        </div>
      )
    }

    return this.props.children
  }
}

export default ErrorBoundary
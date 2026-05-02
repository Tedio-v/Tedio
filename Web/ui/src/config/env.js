// ABOUTME: Environment configuration management for the frontend application
// ABOUTME: Centralizes all environment variables and provides fallbacks for development

const config = {
  // API endpoint - in dev, Vite proxies /api to localhost:5001.
  // In production (Vercel), use the full Render backend URL.
  API_ENDPOINT: import.meta.env.VITE_API_URL || '/api',
  API_TIMEOUT: parseInt(import.meta.env.VITE_API_TIMEOUT) || 30000,

  // Environment info
  NODE_ENV: import.meta.env.MODE || 'development',

  get IS_DEV() {
    return this.NODE_ENV === 'development';
  },

  get IS_PROD() {
    return this.NODE_ENV === 'production';
  }
};

export default config;
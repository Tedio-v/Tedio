// ABOUTME: Environment configuration management for the frontend application
// ABOUTME: Centralizes all environment variables and provides fallbacks for development

const config = {
  // API endpoint - always use relative /api path.
  // In production, nginx proxies /api to the backend.
  // In development, Vite proxies /api to localhost:5001.
  API_ENDPOINT: '/api',
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
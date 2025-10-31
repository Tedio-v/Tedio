// ABOUTME: Environment configuration management for the frontend application
// ABOUTME: Centralizes all environment variables and provides fallbacks for development

const config = {
  // API Configuration
  API_BASE_URL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:5001',
  API_TIMEOUT: parseInt(import.meta.env.VITE_API_TIMEOUT) || 30000,
  
  // Environment info
  NODE_ENV: import.meta.env.MODE || 'development',
  
  // Derived values
  get API_ENDPOINT() {
    return `${this.API_BASE_URL}/api`;
  },
  
  get IS_DEV() {
    return this.NODE_ENV === 'development';
  },
  
  get IS_PROD() {
    return this.NODE_ENV === 'production';
  }
};

// Validate required environment variables
const requiredVars = ['API_BASE_URL'];
const missingVars = requiredVars.filter(varName => !config[varName]);

if (missingVars.length > 0) {
  console.error('Missing required environment variables:', missingVars);
  console.error('Please check your .env file or environment configuration');
}

// Log configuration in development
if (config.IS_DEV) {
  console.log('App Configuration:', {
    API_BASE_URL: config.API_BASE_URL,
    API_ENDPOINT: config.API_ENDPOINT,
    NODE_ENV: config.NODE_ENV
  });
}

export default config;
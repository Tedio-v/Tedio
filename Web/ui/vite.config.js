import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig(({ command, mode }) => {
  // Load env file based on `mode` in the current working directory.
  const env = loadEnv(mode, process.cwd(), '')
  
  return {
    plugins: [react()],
    server: {
      // Allow ngrok and other external hosts
      host: true,
      allowedHosts: [
        'localhost',
        '.localhost',
        '.ngrok.io',
        '.ngrok-free.app',
        '.ngrok.app'
      ],
      // Only use proxy in development when API_BASE_URL is localhost
      ...(mode === 'development' && env.VITE_API_BASE_URL?.includes('localhost') && {
        proxy: {
          '/api': {
            target: env.VITE_API_BASE_URL || 'http://localhost:5001',
            changeOrigin: true,
            secure: false,
          },
        },
      }),
    },
  }
})

import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig(({ mode }) => {
  return {
    plugins: [react()],
    server: {
      host: true,
      allowedHosts: [
        'localhost',
        '.localhost',
        '.ngrok.io',
        '.ngrok-free.app',
        '.ngrok.app'
      ],
      // Proxy /api to local backend in development
      ...(mode === 'development' && {
        proxy: {
          '/api': {
            target: 'http://localhost:5001',
            changeOrigin: true,
            secure: false,
          },
        },
      }),
    },
  }
})

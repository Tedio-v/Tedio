# Tedio UI

Your child's digital wellness dashboard - React frontend connected to Flask backend.

## Features

✅ **Authentication System**
- User registration and login
- JWT token management
- Persistent auth state

✅ **Insights Dashboard** 
- Real-time insights from backend API
- Dynamic insight visualization
- Fallback to static content when no data

✅ **YouTube History Upload**
- File upload for YouTube history JSON
- Automatic insight generation
- Progress feedback and error handling

✅ **API Integration**
- Full connection to Flask backend (`localhost:5001`)
- Proxy configuration for development
- Authenticated API calls

## Configuration

### Environment Setup
1. Copy the example environment file:
```bash
cp .env.example .env
```

2. Update `.env` with your configuration:
```bash
# For local development (default)
VITE_API_BASE_URL=http://localhost:5001
VITE_API_TIMEOUT=30000

# For production deployment
# VITE_API_BASE_URL=https://api.yourdomain.com
# VITE_API_TIMEOUT=30000
```

## Running the Application

### 1. Start the Backend
```bash
cd ../backend
python run.py
```
The backend will run on `http://localhost:5001` (or your configured URL)

### 2. Start the Frontend
```bash
cd ui  # (this directory)
npm run dev
```
The frontend will run on `http://localhost:5173`

### 3. Access the Application
Open `http://localhost:5173` in your browser

## Deployment

For production deployment:
1. Update `.env` with your production API URL
2. Build the application: `npm run build`
3. Serve the `dist/` folder with your web server

## API Endpoints Used

- `POST /api/auth/register` - User registration  
- `POST /api/auth/login` - User login
- `GET /api/insights` - Get user insights (authenticated)
- `POST /api/insights/generate` - Generate insights from history (authenticated)
- `POST /api/youtube-history` - Upload YouTube history (authenticated)
- `GET /api/users` - Get all users (for debugging)

## File Structure

```
src/
├── components/
│   ├── AuthForm.jsx          # Login/registration form
│   └── YouTubeUpload.jsx     # YouTube history upload
├── config/
│   └── env.js               # Environment configuration management
├── pages/
│   ├── SummaryPage.jsx       # Main dashboard
│   └── InsightDetail.jsx     # Individual insight view
├── services/
│   ├── auth.js              # Authentication service
│   └── api.js               # API communication service
└── App.jsx                  # Main app with routing
```

## Development Notes

- Environment-based configuration via `.env` files
- Vite proxy is conditionally configured for localhost development
- Authentication state persists in localStorage
- All API calls include proper error handling
- UI gracefully handles backend unavailability with fallbacks
- Configuration is centralized in `src/config/env.js`

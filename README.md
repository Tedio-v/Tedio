# Tedio - Digital Wellness Platform

A comprehensive digital wellness platform with Web and Mobile applications to help users manage their digital consumption habits.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Environment Configuration](#environment-configuration)
- [Web Application Setup](#web-application-setup)
  - [Option 1: Docker Setup (Recommended)](#option-1-docker-setup-recommended)
  - [Option 2: Local Setup (No Docker)](#option-2-local-setup-no-docker)
- [Mobile Application Setup](#mobile-application-setup)
- [API Documentation](#api-documentation)
- [Troubleshooting](#troubleshooting)
- [Development Tips](#development-tips)

---

## Project Overview

Tedio consists of two main components:

1. **Web Application**: React frontend + Flask backend
2. **Mobile Application**: Flutter cross-platform app (iOS/Android)

**Key Features:**
- User authentication and profile management
- Digital wellness insights powered by AI
- Quick actions for digital detox
- Cross-platform support

---

## Architecture

```
Tedio/
├── Web/                      # Web application
│   ├── backend/             # Flask REST API
│   │   ├── app/            # Application code
│   │   ├── requirements.txt # Python dependencies
│   │   ├── run.py          # Application entry point
│   │   └── Dockerfile      # Backend Docker config
│   ├── ui/                 # React frontend
│   │   ├── src/           # React source code
│   │   ├── package.json   # npm dependencies
│   │   └── Dockerfile     # Frontend Docker config
│   └── docker-compose.yml  # Docker orchestration
│
└── Mobile/                  # Mobile application
    └── tedio_app/          # Flutter app
        ├── lib/            # Dart source code
        ├── android/        # Android specific
        ├── ios/            # iOS specific
        └── pubspec.yaml    # Flutter dependencies
```

---

## Prerequisites

### For Web Application (Docker)

- **Docker**: 20.10 or higher
- **Docker Compose**: 2.0 or higher

[Install Docker](https://docs.docker.com/get-docker/)

### For Web Application (No Docker)

- **Python**: 3.11 or higher
- **Node.js**: 18.x or higher
- **npm**: 9.x or higher
- **MongoDB**: 7.0 or higher (local or cloud)

### For Mobile Application

- **Flutter SDK**: 3.4.3 or higher
- **Dart SDK**: Comes with Flutter
- **Android Studio** (for Android development)
- **Xcode** (for iOS development - macOS only)

### Check Installed Versions

```bash
# Docker
docker --version
docker-compose --version

# Python
python3 --version

# Node.js
node --version
npm --version

# MongoDB
mongod --version

# Flutter
flutter --version
flutter doctor
```

---

## Environment Configuration

The application uses environment variables for configuration. You need to create `.env` files with your credentials.

### Root .env File

Create a `.env` file in the project root directory:

```bash


# MongoDB Configuration
# Used by Docker Compose for MongoDB container
MONGO_PASSWORD=your-secure-mongodb-password-here

# OpenAI API Key
# Get your API key from: https://platform.openai.com/api-keys
OPENAI_API_KEY=sk-your-openai-api-key-here
```

**Important Notes:**
- Replace `your-secure-mongodb-password-here` with a strong password
- Replace `sk-your-openai-api-key-here` with your actual OpenAI API key
- Never commit `.env` files to version control
- Keep your API keys secure

### Backend .env File

Create a `.env` file in `Web/backend/` directory:

```bash
# Location: Web/backend/.env

# Flask Environment
FLASK_ENV=development

# MongoDB Connection
# For Docker: mongodb://admin:YOUR_PASSWORD@mongodb:27017/tedio?authSource=admin
# For Local: mongodb://localhost:27017/tedio
MONGO_URI=mongodb://localhost:27017/tedio

# Security Keys (MUST CHANGE IN PRODUCTION!)
SECRET_KEY=your-super-secret-key-change-this-in-production-min-32-chars
JWT_SECRET_KEY=your-jwt-secret-key-change-this-in-production-min-32-chars

# OpenAI API
OPENAI_API_KEY=sk-your-openai-api-key-here

# Server Configuration
HOST=0.0.0.0
PORT=5001

# Logging
LOG_LEVEL=INFO
```

**Security Notes:**
- Generate strong random keys for `SECRET_KEY` and `JWT_SECRET_KEY`
- Use different keys for development and production
- Example to generate secure keys:
  ```bash
  python3 -c "import secrets; print(secrets.token_hex(32))"
  ```

### Frontend .env File (Optional)

Create a `.env` file in `Web/ui/` directory if needed:

```bash
# Location: Web/ui/.env

# Backend API URL
VITE_API_URL=http://localhost:5001
```

### Mobile Environment Configuration

Create `lib/config/environment.dart` in `Mobile/tedio_app/`:

```dart
// Location: Mobile/tedio_app/lib/config/environment.dart

class Environment {
  // Backend API URL
  // For Android Emulator: http://10.0.2.2:5001
  // For iOS Simulator: http://localhost:5001
  // For Physical Device: http://YOUR_LOCAL_IP:5001
  // For Production: https://your-production-api.com
  static const String apiUrl = 'http://localhost:5001';

  // API Endpoints
  static const String baseUrl = '$apiUrl/api';
  static const String authEndpoint = '$baseUrl/auth';
  static const String insightsEndpoint = '$baseUrl/insights';
  static const String actionsEndpoint = '$baseUrl/actions';

  // App Configuration
  static const String appName = 'Tedio';
  static const String appVersion = '1.0.0';
}
```

**Mobile API URL Guide:**
- **Android Emulator**: `http://10.0.2.2:5001` (10.0.2.2 is the host machine from emulator)
- **iOS Simulator**: `http://localhost:5001`
- **Physical Device**: `http://YOUR_LOCAL_IP:5001` (find your IP with `ipconfig getifaddr en0` on Mac)
- **Production**: Your deployed backend URL

---

## Web Application Setup

### Option 1: Docker Setup (Recommended)

Docker setup is recommended because it:
- Handles all dependencies automatically
- Ensures consistent environment across machines
- Includes MongoDB, backend, and frontend in one command
- Easier for production deployment

#### Step 1: Install Docker

If you don't have Docker installed:

- **macOS**: Download [Docker Desktop for Mac](https://docs.docker.com/desktop/install/mac-install/)
- **Windows**: Download [Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/)
- **Linux**: Follow [Docker Engine installation](https://docs.docker.com/engine/install/)

#### Step 2: Create Environment File

Create `.env` file in the project root as described in [Environment Configuration](#environment-configuration).

#### Step 3: Navigate to Web Directory

```bash
cd Web
```

#### Step 4: Build Docker Containers

```bash
docker-compose build
```

This command:
- Downloads base images (Python, Node.js, MongoDB)
- Installs all dependencies
- Builds the backend and frontend containers
- Takes 5-10 minutes on first run

#### Step 5: Start the Application

```bash
docker-compose up -d
```

The `-d` flag runs containers in detached mode (background).

#### Step 6: Verify Containers are Running

```bash
docker-compose ps
```

You should see 4 containers running:
- `tedio-backend` (Flask API)
- `tedio-frontend` (React UI)
- `mongodb` (Database)
- `traefik` (Reverse proxy)

#### Step 7: Access the Application

- **Frontend**: http://localhost:80
- **Backend API**: http://localhost:5001
- **API Health Check**: http://localhost:5001/health

#### Docker Management Commands

```bash
# View logs
docker-compose logs -f              # All services
docker-compose logs -f backend      # Backend only
docker-compose logs -f frontend     # Frontend only

# Stop containers
docker-compose down

# Stop and remove volumes (WARNING: deletes database data)
docker-compose down -v

# Restart containers
docker-compose restart

# Rebuild and restart
docker-compose up -d --build

# Stop a specific service
docker-compose stop backend

# Start a specific service
docker-compose start backend

# Execute commands inside containers
docker-compose exec backend bash
docker-compose exec mongodb mongosh
```

#### What Docker Compose Does

The `docker-compose.yml` file orchestrates 4 services:

1. **MongoDB Container**
   - Image: `mongo:7`
   - Port: 27017
   - Stores data in named volume `mongodb_data`
   - Credentials from `.env` file

2. **Backend Container**
   - Built from `Web/backend/Dockerfile`
   - Port: 5001
   - Connects to MongoDB
   - Uses OpenAI API

3. **Frontend Container**
   - Built from `Web/ui/Dockerfile`
   - Port: 80
   - Serves React app via Nginx

4. **Traefik Container** (Optional)
   - Reverse proxy for HTTPS
   - Port: 443
   - Handles SSL certificates

---

### Option 2: Local Setup (No Docker)

Local setup gives you more control and is better for active development.

#### Prerequisites

Make sure you have installed:
- Python 3.11+
- Node.js 18+
- MongoDB 7+

#### Part A: MongoDB Setup

You have 3 options for MongoDB:

**Option 1: Install MongoDB Locally**

- **macOS**:
  ```bash
  brew tap mongodb/brew
  brew install mongodb-community@7.0
  brew services start mongodb-community@7.0
  ```

- **Windows**: Download from [MongoDB Download Center](https://www.mongodb.com/try/download/community)

- **Linux**:
  ```bash
  # Ubuntu/Debian
  sudo apt-get install -y mongodb-org
  sudo systemctl start mongod
  ```

**Option 2: Use MongoDB Atlas (Cloud)**

1. Create free account at [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Create a cluster
3. Get connection string
4. Update `MONGO_URI` in `Web/backend/.env`:
   ```
   MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/tedio?retryWrites=true&w=majority
   ```

**Option 3: Run MongoDB in Docker**

```bash
docker run -d -p 27017:27017 --name mongodb \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=your_password \
  mongo:7
```

#### Part B: Backend Setup

**Step 1: Navigate to Backend Directory**

```bash
cd Web/backend
```

**Step 2: Create Virtual Environment**

```bash
python3 -m venv venv
```

This creates an isolated Python environment.

**Step 3: Activate Virtual Environment**

- **macOS/Linux**:
  ```bash
  source venv/bin/activate
  ```

- **Windows**:
  ```bash
  venv\Scripts\activate
  ```

You should see `(venv)` in your terminal prompt.

**Step 4: Install Python Dependencies**

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

This installs:
- Flask (web framework)
- PyMongo (MongoDB driver)
- OpenAI (AI integration)
- JWT, bcrypt (authentication)
- And more...

**Step 5: Create .env File**

Create `Web/backend/.env` as described in [Backend .env File](#backend-env-file).

**Step 6: Start Backend Server**

```bash
python run.py
```

You should see:
```
* Running on http://0.0.0.0:5001
* Debug mode: on
```

Keep this terminal open. The backend is now running!

**Step 7: Test Backend** (in new terminal)

```bash
curl http://localhost:5001/health
```

Should return: `{"status": "healthy"}`

#### Part C: Frontend Setup

Open a **new terminal window** (keep backend running).

**Step 1: Navigate to Frontend Directory**

```bash
cd Web/ui
```

**Step 2: Install npm Dependencies**

```bash
npm install
```

This installs:
- React
- Vite (build tool)
- React Router
- And more...

**Step 3: Create Frontend .env** (optional)

Create `Web/ui/.env`:
```
VITE_API_URL=http://localhost:5001
```

**Step 4: Start Development Server**

```bash
npm run dev
```

You should see:
```
VITE v7.1.0  ready in 500 ms

➜  Local:   http://localhost:5173/
```

**Step 5: Access the Application**

Open browser to http://localhost:5173

#### Local Development Commands

**Backend Commands** (from `Web/backend/`):
```bash
# Start development server
python run.py

# Start with production settings
gunicorn -c gunicorn_config.py wsgi:app

# Run tests (if available)
pytest

# Database operations
python -c "from app import create_app; app = create_app(); app.run()"
```

**Frontend Commands** (from `Web/ui/`):
```bash
# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Run linter
npm run lint
```

#### Stopping Local Services

- **Backend**: Press `Ctrl+C` in the backend terminal
- **Frontend**: Press `Ctrl+C` in the frontend terminal
- **MongoDB** (if using brew): `brew services stop mongodb-community@7.0`

---

## Mobile Application Setup

### Prerequisites

#### Install Flutter

**macOS:**
```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Or use homebrew
brew install --cask flutter
```

**Windows:**
1. Download Flutter SDK from [flutter.dev](https://docs.flutter.dev/get-started/install/windows)
2. Extract to `C:\flutter`
3. Add to PATH: `C:\flutter\bin`

**Linux:**
```bash
sudo snap install flutter --classic
```

#### Install Platform-Specific Tools

**For Android:**
1. Install [Android Studio](https://developer.android.com/studio)
2. Install Android SDK and tools
3. Create virtual device or connect physical device
4. Enable USB debugging on physical device

**For iOS (macOS only):**
1. Install [Xcode](https://apps.apple.com/app/xcode/id497799835) from App Store
2. Install CocoaPods: `sudo gem install cocoapods`
3. Accept Xcode license: `sudo xcodebuild -license`

#### Verify Flutter Installation

```bash
flutter doctor
```

This checks your environment and shows what needs to be installed. Fix any issues shown.

### Setup Steps

#### Step 1: Navigate to Mobile Directory

```bash
cd Mobile/tedio_app
```

#### Step 2: Get Flutter Dependencies

```bash
flutter pub get
```

This downloads all packages listed in `pubspec.yaml`:
- provider (state management)
- http, dio (networking)
- shared_preferences (local storage)
- go_router (navigation)
- And more...

#### Step 3: Create Environment Configuration

Create `lib/config/environment.dart` as described in [Mobile Environment Configuration](#mobile-environment-configuration).

**Important:** Update the `apiUrl` based on where you're running:

```dart
// For Android Emulator
static const String apiUrl = 'http://10.0.2.2:5001';

// For iOS Simulator
static const String apiUrl = 'http://localhost:5001';

// For Physical Device (find your IP)
static const String apiUrl = 'http://192.168.1.100:5001';
```

To find your local IP:
- **macOS**: `ipconfig getifaddr en0`
- **Linux**: `hostname -I | awk '{print $1}'`
- **Windows**: `ipconfig` (look for IPv4 Address)

#### Step 4: Check Connected Devices

```bash
flutter devices
```

This shows available devices:
- Physical devices (USB connected)
- Emulators/Simulators
- Chrome (for web)

#### Step 5: Run the App

**Run on Default Device:**
```bash
flutter run
```

**Run on Specific Device:**
```bash
# List devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

**Run on Android Emulator:**
```bash
# Start emulator (if not running)
emulator -avd <avd-name>

# Run app
flutter run -d emulator-5554
```

**Run on iOS Simulator:**
```bash
# Open simulator
open -a Simulator

# Run app
flutter run -d iPhone
```

**Run on Chrome (Web):**
```bash
flutter run -d chrome
```

#### Step 6: Development Mode Features

While the app is running, you can:

- **Hot Reload** (instant UI updates): Press `r`
- **Hot Restart** (full restart): Press `R`
- **Open DevTools**: Press `v`
- **Quit**: Press `q`

### Building for Release

#### Android APK

```bash
# Build APK
flutter build apk

# Build App Bundle (for Play Store)
flutter build appbundle

# Output location:
# build/app/outputs/flutter-apk/app-release.apk
# build/app/outputs/bundle/release/app-release.aab
```

#### iOS App

```bash
# Build for iOS (macOS only)
flutter build ios

# Open in Xcode for signing and deployment
open ios/Runner.xcworkspace
```

### Mobile App Structure

```
Mobile/tedio_app/lib/
├── core/                   # Core utilities
│   └── theme/             # App theming
├── data/                  # Data layer
│   └── services/         # API services
├── presentation/          # UI layer
│   ├── providers/        # State management
│   ├── screens/          # App screens
│   └── widgets/          # Reusable widgets
└── main.dart             # App entry point
```

### Common Mobile Issues

**Issue: Cannot connect to backend**
- Android Emulator: Use `http://10.0.2.2:5001`
- Check backend is running
- Check firewall settings

**Issue: Gradle build failed (Android)**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**Issue: CocoaPods error (iOS)**
```bash
cd ios
pod deintegrate
pod install
cd ..
```

**Issue: Flutter doctor shows issues**
- Follow the suggested fixes
- Run `flutter doctor -v` for detailed info

---

## API Documentation

### Base URL

- Development: `http://localhost:5001`
- Production: Your deployed URL

### Authentication Endpoints

#### Register User
```http
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securepassword123",
  "name": "John Doe"
}

Response: 201 Created
{
  "message": "User created successfully",
  "user_id": "..."
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securepassword123"
}

Response: 200 OK
{
  "token": "eyJ...",
  "user": {
    "id": "...",
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

### Protected Endpoints

Include JWT token in headers:
```http
Authorization: Bearer eyJ...
```

#### Get User Profile
```http
GET /api/user/profile
Authorization: Bearer eyJ...

Response: 200 OK
{
  "id": "...",
  "email": "user@example.com",
  "name": "John Doe",
  "created_at": "2025-01-01T00:00:00"
}
```

### Health Check

```http
GET /health

Response: 200 OK
{
  "status": "healthy"
}
```

---

## Troubleshooting

### Web Application Issues

#### Docker Issues

**Problem: Port already in use**
```
Error: Bind for 0.0.0.0:80 failed: port is already allocated
```

Solution:
```bash
# Find process using port
lsof -i :80

# Kill process or change port in docker-compose.yml
ports:
  - "8080:80"  # Use port 8080 instead
```

**Problem: Containers won't start**
```bash
# Check logs
docker-compose logs backend
docker-compose logs frontend

# Rebuild containers
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

**Problem: Database connection failed**
- Check MongoDB container is running: `docker-compose ps`
- Check credentials in `.env` file match
- Check `MONGO_URI` in backend `.env`

#### Local Development Issues

**Problem: Python dependencies won't install**
```bash
# Update pip
pip install --upgrade pip

# Install individually to find problematic package
pip install Flask
pip install pymongo
# etc...
```

**Problem: Module not found**
```bash
# Make sure virtual environment is activated
source venv/bin/activate  # macOS/Linux
venv\Scripts\activate     # Windows

# Reinstall dependencies
pip install -r requirements.txt
```

**Problem: MongoDB connection refused**
```bash
# Check if MongoDB is running
brew services list  # macOS
sudo systemctl status mongod  # Linux

# Start MongoDB
brew services start mongodb-community@7.0  # macOS
sudo systemctl start mongod  # Linux
```

**Problem: npm install fails**
```bash
# Clear cache
npm cache clean --force

# Delete node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

**Problem: CORS errors**
- Check Flask-CORS is installed
- Verify CORS configuration in backend
- Check frontend is calling correct API URL

### Mobile Application Issues

**Problem: Cannot connect to backend API**

Android Emulator:
```dart
static const String apiUrl = 'http://10.0.2.2:5001';
```

iOS Simulator:
```dart
static const String apiUrl = 'http://localhost:5001';
```

Physical Device:
```dart
static const String apiUrl = 'http://YOUR_LOCAL_IP:5001';
```

**Problem: Gradle build failed**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

**Problem: iOS build failed**
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter run
```

**Problem: Package conflicts**
```bash
flutter pub cache repair
flutter pub get
```

### General Issues

**Problem: Environment variables not loading**
- Check `.env` file is in correct location
- Check `.env` file has no syntax errors
- Restart application after changing `.env`
- Don't use quotes around values in `.env`

**Problem: OpenAI API errors**
- Verify API key is correct
- Check API key has credits
- Check API key permissions
- Verify network connectivity

---

## Development Tips

### Web Development

**Hot Reloading:**
- Backend: Use Flask debug mode (automatic)
- Frontend: Vite provides instant HMR

**Debugging:**
```bash
# Backend debugging
import pdb; pdb.set_trace()  # Python debugger

# Frontend debugging
console.log()  # Browser console
React DevTools (Chrome extension)
```

**Code Quality:**
```bash
# Backend
pip install black flake8
black .  # Format code
flake8 .  # Lint code

# Frontend
npm run lint  # ESLint
```

### Mobile Development

**Debugging:**
```bash
# Verbose logging
flutter run -v

# Debug mode
flutter run --debug

# Profile mode (performance)
flutter run --profile
```

**DevTools:**
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

**Performance:**
- Use `const` constructors when possible
- Avoid rebuilding entire widget tree
- Use `ListView.builder` for long lists
- Profile with DevTools

### Git Workflow

Have a seprate branch and push DO NOT PUSH IN MAIN.

**Commit Message Convention:**
- `Add:` New feature
- `Fix:` Bug fix
- `Update:` Improvements
- `Refactor:` Code restructuring
- `Docs:` Documentation changes

### Environment Best Practices

1. **Never commit `.env` files**
   - Add to `.gitignore`
   - Provide `.env.example` instead

2. **Use different credentials for dev/prod**
   - Development: weak passwords OK
   - Production: strong, unique passwords

3. **Keep dependencies updated**
   ```bash
   # Python
   pip list --outdated

   # Node.js
   npm outdated

   # Flutter
   flutter pub outdated
   ```

4. **Use version control**
   - Commit frequently
   - Write meaningful commit messages
   - Use branches for features

---

## Production Deployment

### Web Application

**Docker Deployment:**
1. Update environment variables for production
2. Use strong passwords and secret keys
3. Configure domain in `docker-compose.yml`
4. Set up SSL with Traefik
5. Deploy to cloud provider (AWS, DigitalOcean, etc.)

**Environment Checklist:**
- [ ] Update `SECRET_KEY` and `JWT_SECRET_KEY`
- [ ] Use strong MongoDB password
- [ ] Set `FLASK_ENV=production`
- [ ] Configure domain for Traefik
- [ ] Set up SSL certificates
- [ ] Configure CORS for production domain
- [ ] Set up monitoring and logging

### Mobile Application

**Android:**
1. Update version in `pubspec.yaml`
2. Configure signing keys
3. Build app bundle: `flutter build appbundle`
4. Upload to Google Play Console

**iOS:**
1. Update version in `pubspec.yaml`
2. Configure signing in Xcode
3. Build: `flutter build ios`
4. Archive and upload to App Store Connect

---

## Support

HMU




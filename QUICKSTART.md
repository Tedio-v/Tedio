# Tedio Quick Start Guide

Get Tedio up and running in 5 minutes!

---

## Choose Your Path

### 🐳 Web with Docker (Easiest)

**Prerequisites:** Docker & Docker Compose installed

```bash
# 1. Navigate to project
cd Tedio

# 2. Create environment file
cp .env.example .env
# Edit .env and add your MONGO_PASSWORD and OPENAI_API_KEY

# 3. Start everything
cd Web
docker-compose up -d

# 4. Access the app
# Frontend: http://localhost:80
# Backend: http://localhost:5001
```

**That's it!** All services (MongoDB, Backend, Frontend) are running.

**Stop everything:**
```bash
docker-compose down
```

---

### 💻 Web without Docker (Local Development)

**Prerequisites:** Python 3.11+, Node.js 18+, MongoDB

#### Backend

```bash
# 1. Navigate to backend
cd Tedio/Web/backend

# 2. Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Setup environment
cp .env.example .env
# Edit .env with your credentials

# 5. Start MongoDB (if not running)
# macOS: brew services start mongodb-community@7.0
# Linux: sudo systemctl start mongod
# Or use Docker: docker run -d -p 27017:27017 mongo:7

# 6. Start backend
python run.py
# Backend running on http://localhost:5001
```

#### Frontend (New Terminal)

```bash
# 1. Navigate to frontend
cd Tedio/Web/ui

# 2. Install dependencies
npm install

# 3. Start frontend
npm run dev
# Frontend running on http://localhost:5173
```

---

### 📱 Mobile App (Flutter)

**Prerequisites:** Flutter SDK installed

```bash
# 1. Navigate to mobile app
cd Tedio/Mobile/tedio_app

# 2. Check Flutter setup
flutter doctor

# 3. Get dependencies
flutter pub get

# 4. Create environment config
mkdir -p lib/config
cp lib/config/environment.dart.example lib/config/environment.dart
# Edit lib/config/environment.dart and set correct API URL:
# - Android Emulator: http://10.0.2.2:5001
# - iOS Simulator: http://localhost:5001
# - Physical Device: http://YOUR_LOCAL_IP:5001

# 5. Make sure backend is running (see above)

# 6. Start app
flutter run
# Select your device when prompted
```

**Hot Reload:** Press `r` while app is running
**Quit:** Press `q`

---

## Environment Variables Quick Reference

### Root `.env`
```bash
MONGO_PASSWORD=your-strong-password
OPENAI_API_KEY=sk-your-key-here
```

### `Web/backend/.env`
```bash
FLASK_ENV=development
MONGO_URI=mongodb://localhost:27017/tedio
SECRET_KEY=generate-random-key-here
JWT_SECRET_KEY=generate-random-key-here
OPENAI_API_KEY=sk-your-key-here
HOST=0.0.0.0
PORT=5001
```

### `Web/ui/.env` (Optional)
```bash
VITE_API_URL=http://localhost:5001
```

### `Mobile/tedio_app/lib/config/environment.dart`
```dart
static const String apiUrl = 'http://10.0.2.2:5001';  // For Android
// Or 'http://localhost:5001' for iOS
```

---

## Common Commands

### Docker
```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# View logs
docker-compose logs -f

# Rebuild
docker-compose up -d --build
```

### Backend (Local)
```bash
# Activate venv
source venv/bin/activate

# Start server
python run.py
```

### Frontend (Local)
```bash
# Dev server
npm run dev

# Build
npm run build
```

### Mobile
```bash
# Run
flutter run

# Run on specific device
flutter run -d <device-id>

# List devices
flutter devices
```

---

## Troubleshooting

### Docker: Port 80 already in use
```bash
# Change port in docker-compose.yml
ports:
  - "8080:80"  # Use 8080 instead
```

### Local: Can't connect to MongoDB
```bash
# Check if MongoDB is running
# macOS
brew services list

# Start MongoDB
brew services start mongodb-community@7.0
```

### Mobile: Can't connect to backend
- **Android Emulator:** Use `http://10.0.2.2:5001`
- **iOS Simulator:** Use `http://localhost:5001`
- **Physical Device:** Use `http://YOUR_LOCAL_IP:5001`
  ```bash
  # Find your IP (macOS)
  ipconfig getifaddr en0
  ```

### Generate Secret Keys
```bash
python3 -c "import secrets; print(secrets.token_hex(32))"
```

---

## Next Steps

1. **Read Full Documentation:** See `README.md` for detailed setup
2. **API Documentation:** Check API endpoints in `README.md`
3. **Development:** Follow development tips in main README

---

## Need Help?

- Check the full `README.md` for detailed instructions
- Review the troubleshooting section
- Check existing issues on GitHub

---

**Happy Coding!** 🚀

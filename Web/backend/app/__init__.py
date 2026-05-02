from flask import Flask, jsonify
from flask_pymongo import PyMongo
from flask_cors import CORS
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = Flask(__name__)
app.config['MONGO_URI'] = os.getenv('MONGO_URI', 'mongodb://localhost:27017/tedio')
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'your-secret-key-here')  # Change in production

# Enable CORS - allow all origins
CORS(app,
     origins="*",
     allow_headers=["Content-Type", "Authorization", "X-Requested-With"],
     methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"])

# Initialize MongoDB
mongo_uri = os.getenv('MONGO_URI', 'mongodb://localhost:27017/tedio')
print(f"[STARTUP] Connecting to MongoDB... URI starts with: {mongo_uri[:30]}...")
print(f"[STARTUP] MONGO_URI env var set: {bool(os.getenv('MONGO_URI'))}")

try:
    mongo = PyMongo(app)
    db = mongo.db
    if db is None:
        print("[STARTUP] ERROR: mongo.db is None! Check that your MONGO_URI includes a database name (e.g. /tedio)")
        print(f"[STARTUP] Current MONGO_URI: {mongo_uri[:50]}...")
    else:
        print(f"[STARTUP] Connected to MongoDB database: {db.name}")
except Exception as e:
    print(f"[STARTUP] ERROR connecting to MongoDB: {e}")
    db = None

# Import routes after app initialization to avoid circular imports
from app.routes import api
app.register_blueprint(api)

# Ensure indexes for better query performance
if db is not None:
    try:
        db.users.create_index('email', unique=True)
        db.videos.create_index('user_id')
        db.insights.create_index([('user_id', 1), ('resolved_at', 1)])
        print("[STARTUP] MongoDB indexes created successfully")
    except Exception as e:
        print(f"[STARTUP] ERROR creating indexes: {e}")
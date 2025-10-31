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

# Enable CORS with more permissive configuration
CORS(app, 
     origins=["*"],  # Allow all origins for now
     allow_headers=["Content-Type", "Authorization", "X-Requested-With"],
     methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
     supports_credentials=True,
     expose_headers=["Content-Type", "Authorization"])

# Initialize MongoDB
mongo = PyMongo(app)
db = mongo.db

# Import routes after app initialization to avoid circular imports
from app.routes import api
app.register_blueprint(api)

# Ensure indexes for better query performance
db.users.create_index('email', unique=True)
db.videos.create_index('user_id')
db.insights.create_index([('user_id', 1), ('resolved_at', 1)])
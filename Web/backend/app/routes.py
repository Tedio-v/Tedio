from flask import Blueprint, request, jsonify, make_response
from .services.mongo_service import MongoService
from .services.auth_service import AuthService
from .services.insight_service import InsightService
from flask_cors import cross_origin
from bson import ObjectId
from bson.errors import InvalidId
from datetime import datetime
from app import db
from app.models import User, Video, Insight
from functools import wraps
import os
from dotenv import load_dotenv
import bcrypt
import jwt
from flask import current_app
from werkzeug.security import check_password_hash
import functools
import traceback
from .llm import call_llm, build_metrics, _preprocess, process_youtube_history
import json

# Load environment variables
load_dotenv()

# Create Blueprint and services
api = Blueprint('api', __name__)
mongo_service = MongoService(db)
auth_service = AuthService(db)

# Get OpenAI API key from environment
openai_api_key = os.getenv('OPENAI_API_KEY')
print(f"Loaded OpenAI API key from environment: {openai_api_key[:8] if openai_api_key else 'None'}...")

if not openai_api_key:
    raise ValueError("OPENAI_API_KEY environment variable is not set")

insight_service = InsightService(openai_api_key)

# Updated CORS origins to include server IP and domain
CORS_ORIGINS = [
    'http://localhost:3000',
    'http://127.0.0.1:3000', 
    'http://localhost:5173',
    'http://127.0.0.1:5173',
    'http://134.199.222.115:3000',  # Added server IP
    'http://134.199.222.115:5173',  # Added server IP for Vite
    'http://178.128.74.9:3000',     # Added second server IP
    'http://178.128.74.9:5173',     # Added second server IP for Vite
    'https://tedio.online',         # Domain HTTPS
    'http://tedio.online'           # Domain HTTP
]

# Robust token_required decorator
def token_required(f):
    @functools.wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get('Authorization', None)
        print('Authorization header:', auth_header)  # Debug print
        if not auth_header or not auth_header.startswith('Bearer '):
            print('No Bearer token found')
            return jsonify({'error': 'Missing or invalid token'}), 401
        token = auth_header.split(' ')[1]
        print('Extracted token:', token)  # Debug print
        try:
            payload = jwt.decode(token, current_app.config['SECRET_KEY'], algorithms=['HS256'])
            print('Decoded JWT payload:', payload)  # Debug print
        except Exception as e:
            print('JWT decode error:', str(e))
            return jsonify({'error': 'Invalid token'}), 401
        return f(*args, **kwargs, current_user=payload)
    return decorated

# Authentication Routes
@api.route('/api/auth/register', methods=['POST'])
@cross_origin(origins=CORS_ORIGINS)
def register():
    data = request.get_json()
    print(f"Registration data received: {data}")  # Debug log
    
    child_name = data.get('child_name')
    child_age = data.get('child_age')
    email = data.get('email')
    password = data.get('password')
    
    print(f"Parsed fields - child_name: {child_name}, child_age: {child_age}, email: {email}, password: {'***' if password else None}")  # Debug log
    
    if not all([child_name, child_age, email, password]):
        missing_fields = []
        if not child_name: missing_fields.append('child_name')
        if not child_age: missing_fields.append('child_age') 
        if not email: missing_fields.append('email')
        if not password: missing_fields.append('password')
        print(f"Missing fields: {missing_fields}")  # Debug log
        return jsonify({'error': f'Missing required fields: {", ".join(missing_fields)}'}), 400
    if mongo_service.db.users.find_one({'email': email}):
        return jsonify({'error': 'Email already registered'}), 409
    hashed_pw = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
    user = {
        'child_name': child_name,
        'child_age': child_age,
        'email': email,
        'password': hashed_pw.decode('utf-8'),
        'first_login': True
    }
    mongo_service.db.users.insert_one(user)
    return jsonify({'message': 'User registered successfully'}), 201

@api.route('/api/auth/login', methods=['POST'])
@cross_origin(origins=CORS_ORIGINS)
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    if not all([email, password]):
        return jsonify({'error': 'Missing email or password'}), 400
    user = mongo_service.db.users.find_one({'email': email})
    if not user:
        return jsonify({'error': 'Invalid credentials'}), 401
    pw_hash = user['password']
    # Support both scrypt and bcrypt hashes
    if pw_hash.startswith('scrypt:'):
        valid = check_password_hash(pw_hash, password)
    else:
        valid = bcrypt.checkpw(password.encode('utf-8'), pw_hash.encode('utf-8'))
    if not valid:
        return jsonify({'error': 'Invalid credentials'}), 401
    # Handle first_login flag (default to False if missing)
    first_login = user.get('first_login', False)
    # DON'T clear first_login on login - only clear it when onboarding is complete
    # Generate JWT token
    payload = {'user_id': str(user['_id']), 'email': user['email'], 'child_name': user.get('child_name', '')}
    token = jwt.encode(payload, current_app.config['SECRET_KEY'], algorithm='HS256')
    return jsonify({'token': token, 'user': {'child_name': user.get('child_name'), 'email': user['email'], 'child_age': user.get('child_age'), 'first_login': first_login}}), 200

@api.route('/api/auth/complete-onboarding', methods=['POST'])
@cross_origin(origins=CORS_ORIGINS)
@token_required
def complete_onboarding(current_user):
    """Mark user's onboarding as complete"""
    try:
        user_id = current_user['user_id']
        result = mongo_service.db.users.update_one(
            {'_id': ObjectId(user_id)}, 
            {'$set': {'first_login': False}}
        )
        if result.modified_count:
            return jsonify({'message': 'Onboarding completed successfully'}), 200
        else:
            return jsonify({'message': 'User already completed onboarding'}), 200
    except Exception as e:
        print(f'Error completing onboarding: {str(e)}')
        return jsonify({'error': str(e)}), 500

# YouTube History Routes with authentication
@api.route('/api/youtube-history/status', methods=['GET'])
@cross_origin(origins=CORS_ORIGINS)
@token_required
def check_youtube_history(current_user):
    try:
        has_data = mongo_service.has_youtube_history(current_user['_id'])
        return jsonify({'has_data': has_data}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@api.route('/api/youtube-history', methods=['POST', 'OPTIONS'])
@cross_origin(origins=CORS_ORIGINS)
@token_required
def upload_youtube_history(current_user):
    print('Headers:', dict(request.headers))  # Debug print
    print('Current user:', current_user)      # Debug print
    if request.method == 'OPTIONS':
        return handle_preflight()

    try:
        history_data = request.json
        if not history_data:
            return jsonify({'error': 'No data provided'}), 400
        # Add user_id to history data (fix: use user_id from JWT payload)
        for item in history_data:
            item['user_id'] = current_user['user_id']
        result = mongo_service.save_youtube_history(history_data)
        response = jsonify({'message': f'Successfully saved {result} records'})
        return response, 200
    except Exception as e:
        print('Error in upload_youtube_history:', str(e))
        return jsonify({'error': str(e)}), 500

@api.route('/api/youtube-history', methods=['GET'])
@cross_origin(origins=CORS_ORIGINS)
@token_required
def get_youtube_history(current_user):
    try:
        history = mongo_service.get_youtube_history(current_user['_id'])
        return jsonify(history), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

def handle_preflight():
    response = make_response()
    response.headers.add('Access-Control-Allow-Origin', '*')  # Allow all origins
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type, Authorization')
    response.headers.add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
    response.headers.add('Access-Control-Allow-Credentials', 'true')
    response.headers.add('Access-Control-Max-Age', '3600')
    return response

# User Routes
@api.route('/api/users', methods=['GET'])
def get_users():
    try:
        users = list(db.users.find())
        return jsonify([User.format_user(user) for user in users])
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@api.route('/api/users/<user_id>', methods=['GET'])
def get_user(user_id):
    try:
        user = db.users.find_one({'_id': ObjectId(user_id)})
        if user:
            return jsonify(User.format_user(user))
        return jsonify({'error': 'User not found'}), 404
    except InvalidId:
        return jsonify({'error': 'Invalid user ID'}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@api.route('/api/users', methods=['POST'])
def create_user():
    try:
        data = request.get_json()
        User.validate_user(data)
        result = db.users.insert_one(data)
        return jsonify({
            'message': 'User created successfully',
            'id': str(result.inserted_id)
        }), 201
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Video Routes
@api.route('/api/videos', methods=['GET'])
def get_videos():
    try:
        videos = list(db.videos.find())
        return jsonify([Video.format_video(video) for video in videos])
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@api.route('/api/videos/<video_id>', methods=['GET'])
def get_video(video_id):
    try:
        video = Video.get_video_with_insights(db, video_id)
        if video:
            return jsonify(Video.format_video(video))
        return jsonify({'error': 'Video not found'}), 404
    except InvalidId:
        return jsonify({'error': 'Invalid video ID'}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Insight Routes
@api.route('/api/insights', methods=['GET'])
@cross_origin(origins=CORS_ORIGINS)
@token_required
def get_insights(current_user):
    try:
        print('--- /api/insights called ---')
        # Get insights for the current user only
        user_id = current_user['user_id']
        print(f'Fetching insights for user: {user_id}')
        
        raw_insights = list(mongo_service.db.insights.find({'user_id': user_id}).sort('created_at', -1))
        print(f'Found {len(raw_insights)} raw insights in DB for user {user_id}')
        
        # Get global ratings for all insights
        global_stats = list(mongo_service.db.global_insight_stats.find({}))
        global_ratings_map = {stat['insight_name']: stat for stat in global_stats}
        
        # Map LLM output to frontend expected structure
        mapped_insights = []
        for insight in raw_insights:
            print(f'Processing insight: {insight.get("name", "Unknown")}')
            # Get the intervention object from the insight
            intervention_data = insight.get('intervention', {})
            insight_name = insight.get('name', 'Unknown')
            
            # Get global rating data for this insight type
            global_rating_data = global_ratings_map.get(insight_name, {})
            
            mapped_insight = {
                '_id': str(insight['_id']),
                'name': insight_name,
                'severity': insight.get('severity', 'moderate'),
                'message': insight.get('description', insight.get('message', 'No description available')),
                'spark': insight.get('spark', [0, 0, 0, 0, 0, 0, 0]),  # Default spark data
                'matchScore': insight.get('relevance score', insight.get('matchScore', 50)),  # Map relevance score to matchScore
                'userImportanceRating': insight.get('user_importance_rating'),
                'globalRating': {
                    'average': global_rating_data.get('average_rating'),
                    'totalRaters': global_rating_data.get('total_raters', 0)
                },
                'intervention': {
                    'whyItMatters': intervention_data.get('whyItMatters', insight.get('why it matters', 'This insight matters for your child\'s digital wellbeing.')),
                    'primaryTip': intervention_data.get('primaryTip', {
                        'title': 'Take Action',
                        'description': insight.get('actionable tip', 'Consider implementing the suggested intervention.'),
                        'actionLabel': 'Learn More'
                    }),
                    'moreTips': intervention_data.get('moreTips', [
                        {
                            'title': 'Monitor Progress',
                            'description': 'Track how this behavior changes over time.'
                        }
                    ]),
                    'evidence': intervention_data.get('evidence'),
                    'developmentalContext': intervention_data.get('developmentalContext'),
                    'warningSigns': intervention_data.get('warningSigns'),
                    'positiveAspects': intervention_data.get('positiveAspects')
                }
            }
            mapped_insights.append(mapped_insight)
        
        print(f'Returning {len(mapped_insights)} mapped insights')
        return jsonify(mapped_insights), 200
    except Exception as e:
        print(f"Error getting insights: {str(e)}")
        return jsonify({'error': str(e)}), 500

@api.route('/api/insights/<insight_id>', methods=['GET'])
def get_insight(insight_id):
    try:
        insight = mongo_service.db.insights.find_one({'_id': ObjectId(insight_id)})
        if insight:
            # Map the insight to include all the new detailed fields
            intervention_data = insight.get('intervention', {})
            insight_name = insight.get('name', 'Unknown')
            
            # Get global rating data for this insight type
            global_rating_data = mongo_service.db.global_insight_stats.find_one({'insight_name': insight_name})
            global_rating = {}
            if global_rating_data:
                global_rating = {
                    'average': global_rating_data.get('average_rating'),
                    'totalRaters': global_rating_data.get('total_raters', 0)
                }
            else:
                global_rating = {
                    'average': None,
                    'totalRaters': 0
                }
            
            mapped_insight = {
                '_id': str(insight['_id']),
                'name': insight_name,
                'severity': insight.get('severity', 'moderate'),
                'message': insight.get('description', insight.get('message', 'No description available')),
                'spark': insight.get('spark', [0, 0, 0, 0, 0, 0, 0]),
                'matchScore': insight.get('relevance score', insight.get('matchScore', 50)),
                'userImportanceRating': insight.get('user_importance_rating'),
                'globalRating': global_rating,
                'intervention': {
                    'whyItMatters': intervention_data.get('whyItMatters', insight.get('why it matters', 'This insight matters for your child\'s digital wellbeing.')),
                    'primaryTip': intervention_data.get('primaryTip', {
                        'title': 'Take Action',
                        'description': insight.get('actionable tip', 'Consider implementing the suggested intervention.'),
                        'actionLabel': 'Learn More'
                    }),
                    'moreTips': intervention_data.get('moreTips', [
                        {
                            'title': 'Monitor Progress',
                            'description': 'Track how this behavior changes over time.'
                        }
                    ]),
                    'evidence': intervention_data.get('evidence'),
                    'developmentalContext': intervention_data.get('developmentalContext'),
                    'warningSigns': intervention_data.get('warningSigns'),
                    'positiveAspects': intervention_data.get('positiveAspects')
                }
            }
            return jsonify(mapped_insight)
        return jsonify({'error': 'Insight not found'}), 404
    except InvalidId:
        return jsonify({'error': 'Invalid insight ID'}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@api.route('/api/insights/<insight_id>/resolve', methods=['POST'])
def resolve_insight(insight_id):
    try:
        result = mongo_service.db.insights.update_one(
            {'_id': ObjectId(insight_id)},
            {'$set': {'resolved_at': datetime.utcnow()}}
        )
        if result.modified_count:
            return jsonify({'message': 'Insight resolved successfully'})
        return jsonify({'error': 'Insight not found'}), 404
    except InvalidId:
        return jsonify({'error': 'Invalid insight ID'}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@api.route('/api/insights/<insight_id>/rating', methods=['POST'])
@cross_origin(origins=CORS_ORIGINS)
@token_required
def submit_insight_rating(insight_id, current_user):
    if request.method == 'OPTIONS':
        return handle_preflight()
    
    try:
        data = request.json
        importance_rating = data.get('importanceRating')
        insight_name = data.get('insightName')
        user_id = current_user['user_id']
        
        if not importance_rating or not isinstance(importance_rating, int) or importance_rating < 1 or importance_rating > 5:
            return jsonify({'error': 'Invalid rating. Must be between 1 and 5.'}), 400
        
        # Check if user has already rated this insight (by insight name, not ID since insights are user-specific)
        existing_rating = mongo_service.db.global_insight_ratings.find_one({
            'user_id': user_id,
            'insight_name': insight_name
        })
        
        if existing_rating:
            # Update existing rating
            mongo_service.db.global_insight_ratings.update_one(
                {'_id': existing_rating['_id']},
                {'$set': {
                    'importance_rating': importance_rating,
                    'updated_at': datetime.utcnow()
                }}
            )
        else:
            # Store new rating in global ratings collection
            rating_data = {
                'insight_name': insight_name,
                'importance_rating': importance_rating,
                'user_id': user_id,
                'submitted_at': datetime.utcnow(),
                'updated_at': datetime.utcnow()
            }
            mongo_service.db.global_insight_ratings.insert_one(rating_data)
        
        # Calculate and update global average for this insight type
        all_ratings = list(mongo_service.db.global_insight_ratings.find({'insight_name': insight_name}))
        if all_ratings:
            total_rating = sum(r['importance_rating'] for r in all_ratings)
            avg_rating = total_rating / len(all_ratings)
            rater_count = len(all_ratings)
            
            # Update or create global stats for this insight
            mongo_service.db.global_insight_stats.update_one(
                {'insight_name': insight_name},
                {'$set': {
                    'average_rating': round(avg_rating, 2),
                    'total_raters': rater_count,
                    'last_updated': datetime.utcnow()
                }},
                upsert=True
            )
        
        # Also update the specific insight with the user's rating
        mongo_service.db.insights.update_one(
            {'_id': ObjectId(insight_id)},
            {'$set': {'user_importance_rating': importance_rating}}
        )
        
        return jsonify({
            'message': 'Rating submitted successfully',
            'global_average': round(avg_rating, 2) if all_ratings else importance_rating,
            'total_raters': len(all_ratings) if all_ratings else 1
        }), 200
        
    except InvalidId:
        return jsonify({'error': 'Invalid insight ID'}), 400
    except Exception as e:
        print('Error submitting rating:', str(e))
        return jsonify({'error': str(e)}), 500

@api.route('/api/insights/global-ratings', methods=['GET'])
@cross_origin(origins=CORS_ORIGINS)
def get_global_insight_ratings():
    """Get global rating averages for all insight types"""
    try:
        # Get all global insight stats
        global_stats = list(mongo_service.db.global_insight_stats.find({}))
        
        # Format the response
        ratings_data = {}
        for stat in global_stats:
            ratings_data[stat['insight_name']] = {
                'average_rating': stat['average_rating'],
                'total_raters': stat['total_raters'],
                'last_updated': stat['last_updated'].isoformat() if stat.get('last_updated') else None
            }
        
        return jsonify(ratings_data), 200
        
    except Exception as e:
        print('Error getting global ratings:', str(e))
        return jsonify({'error': str(e)}), 500

@api.route('/api/insights/<insight_name>/global-rating', methods=['GET'])
@cross_origin(origins=CORS_ORIGINS)
def get_insight_global_rating(insight_name):
    """Get global rating average for a specific insight type"""
    try:
        # Get global stats for this insight
        global_stat = mongo_service.db.global_insight_stats.find_one({'insight_name': insight_name})
        
        if global_stat:
            return jsonify({
                'insight_name': insight_name,
                'average_rating': global_stat['average_rating'],
                'total_raters': global_stat['total_raters'],
                'last_updated': global_stat['last_updated'].isoformat() if global_stat.get('last_updated') else None
            }), 200
        else:
            return jsonify({
                'insight_name': insight_name,
                'average_rating': None,
                'total_raters': 0,
                'last_updated': None
            }), 200
        
    except Exception as e:
        print('Error getting insight global rating:', str(e))
        return jsonify({'error': str(e)}), 500

@api.route('/api/insights/generate', methods=['POST', 'OPTIONS'])
@cross_origin(origins=CORS_ORIGINS)
@token_required
def generate_insights(current_user):
    if request.method == 'OPTIONS':
        return handle_preflight()
    try:
        watch_history = request.json
        print('--- /api/insights/generate called ---')
        print('Current user:', current_user)
        print('Watch history sample:', str(watch_history)[:500])
        if not watch_history:
            print('No data provided!')
            return jsonify({'error': 'No data provided'}), 400
        
        # Use the new two-stage LLM processing pipeline
        print('Processing with two-stage LLM pipeline...')
        
        # Stage 1: Preprocess and classify videos
        # Stage 2: Generate behavioral insights
        insights, total_watch_minutes = process_youtube_history(watch_history)
        print('LLM insights generated:', insights)
        print('Total watch minutes:', total_watch_minutes)
        
        if not insights:
            print('No insights generated - likely no kids content found')
            return jsonify({'message': 'No insights could be generated from the provided history'}), 200
        
        # Add user_id and other required fields to each insight
        processed_insights = []
        for insight in insights:
            # Use the score_pct provided by the LLM, fallback to spark calculation if needed
            match_score = insight.get('score_pct', 50)  # Use LLM's score_pct field
            
            # If no score_pct provided, fallback to old calculation
            if 'score_pct' not in insight:
                print(f"Warning: No score_pct found for {insight['name']}, using fallback calculation")
                match_score = 50  # Safe fallback
            
            processed_insight = {
                'user_id': current_user['user_id'],
                'name': insight['name'],
                'severity': insight['severity'],
                'message': insight['message'],
                'spark': insight['spark'],
                'matchScore': int(match_score),
                # Attach category distribution provided by the processing pipeline (same across insights)
                'category_distribution': insight.get('category_distribution'),
                # Add total viewing minutes for summary calculation
                'total_watch_minutes': total_watch_minutes,
                'created_at': datetime.utcnow(),
                'first_flagged': datetime.utcnow(),
                'last_seen': datetime.utcnow(),
                'evidence': [],
                'resolved_at': None
            }
            processed_insights.append(processed_insight)
        
        # Store insights in the database (overwrite previous for this user)
        user_id = current_user['user_id']
        print(f'Deleting old insights for user: {user_id}')
        mongo_service.db.insights.delete_many({'user_id': user_id})
        
        # Create clean copies for database insertion
        db_insights = []
        for insight in processed_insights:
            print('Inserting insight:', insight)
            # Insert and get the result
            result = mongo_service.db.insights.insert_one(insight.copy())
            # Create a clean copy for JSON response (without ObjectId)
            clean_insight = insight.copy()
            clean_insight['_id'] = str(result.inserted_id)  # Convert ObjectId to string
            db_insights.append(clean_insight)
        
        print('All insights inserted successfully.')
        return jsonify(db_insights), 200
    except Exception as e:
        print('Error in /api/insights/generate:', str(e))
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500

# Settings Routes
@api.route('/api/settings', methods=['GET'])
@cross_origin(origins=CORS_ORIGINS)
@token_required
def get_user_settings(current_user):
    """Get current user's settings"""
    try:
        user_id = current_user['user_id']
        user = mongo_service.db.users.find_one({'_id': ObjectId(user_id)})
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        # Return user settings (excluding password)
        settings = {
            'email': user.get('email', ''),
            'child_name': user.get('child_name', ''),
            'child_age': user.get('child_age', ''),
        }
        return jsonify(settings), 200
    except Exception as e:
        print(f'Error getting user settings: {str(e)}')
        return jsonify({'error': str(e)}), 500

@api.route('/api/settings', methods=['PUT'])
@cross_origin(origins=CORS_ORIGINS)
@token_required
def update_user_settings(current_user):
    """Update current user's settings"""
    try:
        user_id = current_user['user_id']
        data = request.get_json()
        
        # Prepare update data (only include fields that are provided)
        update_fields = {}
        if 'email' in data:
            # Check if email is already taken by another user
            existing_user = mongo_service.db.users.find_one({
                'email': data['email'],
                '_id': {'$ne': ObjectId(user_id)}
            })
            if existing_user:
                return jsonify({'error': 'Email already in use'}), 409
            update_fields['email'] = data['email']
        
        if 'child_name' in data:
            update_fields['child_name'] = data['child_name']
        
        if 'child_age' in data:
            update_fields['child_age'] = data['child_age']
        
        if 'password' in data and data['password']:
            # Hash the new password
            hashed_pw = bcrypt.hashpw(data['password'].encode('utf-8'), bcrypt.gensalt())
            update_fields['password'] = hashed_pw.decode('utf-8')
        
        if not update_fields:
            return jsonify({'error': 'No valid fields to update'}), 400
        
        # Update the user
        result = mongo_service.db.users.update_one(
            {'_id': ObjectId(user_id)},
            {'$set': update_fields}
        )
        
        if result.modified_count:
            return jsonify({'message': 'Settings updated successfully'}), 200
        else:
            return jsonify({'message': 'No changes made'}), 200
    except Exception as e:
        print(f'Error updating user settings: {str(e)}')
        return jsonify({'error': str(e)}), 500

# Quick Actions Routes
@api.route('/api/quick-actions/complete', methods=['POST'])
@cross_origin(origins=CORS_ORIGINS)
@token_required
def complete_quick_action(current_user):
    """Mark a quick action as completed for the current user"""
    try:
        data = request.get_json()
        action_id = data.get('actionId')
        
        if not action_id:
            return jsonify({'error': 'Action ID is required'}), 400
        
        user_id = current_user['user_id']
        
        # Check if action is already completed
        existing = mongo_service.db.completed_actions.find_one({
            'user_id': user_id,
            'action_id': action_id
        })
        
        if existing:
            return jsonify({'message': 'Action already marked as completed'}), 200
        
        # Insert completion record
        completion_data = {
            'user_id': user_id,
            'action_id': action_id,
            'completed_at': datetime.utcnow()
        }
        
        mongo_service.db.completed_actions.insert_one(completion_data)
        
        return jsonify({'message': 'Action marked as completed successfully'}), 200
        
    except Exception as e:
        print(f'Error completing quick action: {str(e)}')
        return jsonify({'error': str(e)}), 500

@api.route('/api/quick-actions/uncomplete', methods=['POST'])
@cross_origin(origins=CORS_ORIGINS)
@token_required
def uncomplete_quick_action(current_user):
    """Unmark a quick action as completed for the current user"""
    try:
        data = request.get_json()
        action_id = data.get('actionId')
        
        if not action_id:
            return jsonify({'error': 'Action ID is required'}), 400
        
        user_id = current_user['user_id']
        
        # Remove completion record
        result = mongo_service.db.completed_actions.delete_one({
            'user_id': user_id,
            'action_id': action_id
        })
        
        if result.deleted_count:
            return jsonify({'message': 'Action unmarked successfully'}), 200
        else:
            return jsonify({'message': 'Action was not marked as completed'}), 200
        
    except Exception as e:
        print(f'Error uncompleting quick action: {str(e)}')
        return jsonify({'error': str(e)}), 500

@api.route('/api/quick-actions/completed', methods=['GET'])
@cross_origin(origins=CORS_ORIGINS)
@token_required
def get_completed_actions(current_user):
    """Get list of completed quick actions for the current user"""
    try:
        user_id = current_user['user_id']
        
        completed_actions = list(mongo_service.db.completed_actions.find({
            'user_id': user_id
        }, {'action_id': 1, 'completed_at': 1, '_id': 0}))
        
        # Return just the action IDs for easy checking
        action_ids = [action['action_id'] for action in completed_actions]
        
        return jsonify({'completed_actions': action_ids}), 200
        
    except Exception as e:
        print(f'Error getting completed actions: {str(e)}')
        return jsonify({'error': str(e)}), 500
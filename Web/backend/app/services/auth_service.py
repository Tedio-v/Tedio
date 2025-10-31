from werkzeug.security import generate_password_hash, check_password_hash
from bson.objectid import ObjectId
import jwt
import datetime
from ..config import JWT_SECRET_KEY

class AuthService:
    def __init__(self, db):
        self.db = db
        self.users = db.users

    def register_user(self, email, password, name=''):
        """Register a new user"""
        # Check if user already exists
        if self.users.find_one({"email": email}):
            raise ValueError("Email already registered")
        
        # Create new user document
        user = {
            "email": email,
            "password": generate_password_hash(password),
            "name": name,
            "created_at": datetime.datetime.utcnow()
        }
        
        # Insert into database
        result = self.users.insert_one(user)
        
        # Create response user object (without password)
        user_response = {
            "_id": str(result.inserted_id),
            "email": email,
            "name": name,
            "created_at": user["created_at"]
        }
        
        # Generate token for the new user
        token = self.generate_token(user_response)
        
        return {
            'token': token,
            'user': user_response
        }

    def login_user(self, email, password):
        """Login a user and return JWT token"""
        user = self.users.find_one({"email": email})
        
        if not user or not check_password_hash(user['password'], password):
            raise ValueError("Invalid email or password")
        
        # Create response user object (without password)
        user_response = {
            "_id": str(user["_id"]),
            "email": user["email"],
            "name": user.get("name", ""),
            "created_at": user.get("created_at")
        }
        
        # Generate token
        token = self.generate_token(user_response)
        
        return {
            'token': token,
            'user': user_response
        }

    def get_user_by_id(self, user_id):
        """Get user by ID"""
        try:
            user = self.users.find_one({"_id": ObjectId(user_id)})
            if user:
                return {
                    "_id": str(user["_id"]),
                    "email": user["email"],
                    "name": user.get("name", ""),
                    "created_at": user.get("created_at")
                }
        except Exception:
            return None
        return None

    def verify_token(self, token):
        """Verify JWT token and return user"""
        try:
            data = jwt.decode(token, JWT_SECRET_KEY, algorithms=['HS256'])
            user = self.get_user_by_id(data['user_id'])
            if not user:
                raise ValueError('User not found')
            return user
        except jwt.ExpiredSignatureError:
            raise ValueError('Token has expired')
        except jwt.InvalidTokenError:
            raise ValueError('Invalid token')

    def generate_token(self, user):
        """
        Generate a JWT token for the user
        """
        payload = {
            'user_id': str(user['_id']),
            'email': user['email'],
            'exp': datetime.datetime.utcnow() + datetime.timedelta(days=1)  # Token expires in 1 day
        }
        return jwt.encode(payload, JWT_SECRET_KEY, algorithm='HS256') 
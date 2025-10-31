from bson import ObjectId
from datetime import datetime

class User:
    collection_name = 'users'
    
    @staticmethod
    def validate_user(data):
        required_fields = ['name', 'email']
        if not all(field in data for field in required_fields):
            raise ValueError('Name and email are required')
        return True
    
    @staticmethod
    def format_user(user):
        if user:
            user['_id'] = str(user['_id'])
        return user
    
    @staticmethod
    def get_watch_history(db, user_id):
        """Get all videos watched by a user with their insights"""
        pipeline = [
            {'$match': {'_id': ObjectId(user_id)}},
            {
                '$lookup': {
                    'from': 'videos',
                    'localField': '_id',
                    'foreignField': 'user_id',
                    'as': 'watch_history'
                }
            },
            {
                '$lookup': {
                    'from': 'insights',
                    'localField': '_id',
                    'foreignField': 'user_id',
                    'as': 'insights'
                }
            }
        ]
        result = list(db.users.aggregate(pipeline))
        return result[0] if result else None 
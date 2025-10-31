from bson import ObjectId
from datetime import datetime

class Video:
    collection_name = 'videos'
    
    @staticmethod
    def validate_video(data):
        required_fields = ['URL', 'title', 'notes', 'user_id']
        if not all(field in data for field in required_fields):
            raise ValueError('URL, title, notes, and user_id are required')
            
        # Validate user exists
        user = db.users.find_one({'_id': ObjectId(data['user_id'])})
        if not user:
            raise ValueError('User does not exist')
            
        return True
    
    @staticmethod
    def format_video(video):
        if video:
            video['_id'] = str(video['_id'])
            if 'user_id' in video:
                video['user_id'] = str(video['user_id'])
        return video
    
    @staticmethod
    def get_video_with_insights(db, video_id):
        """Get video with its associated insights"""
        pipeline = [
            {'$match': {'_id': ObjectId(video_id)}},
            {
                '$lookup': {
                    'from': 'insights',
                    'localField': '_id',
                    'foreignField': 'evidence.video',
                    'as': 'insights'
                }
            }
        ]
        result = list(db.videos.aggregate(pipeline))
        return result[0] if result else None 
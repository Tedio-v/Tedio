from bson import ObjectId
from datetime import datetime

class Insight:
    collection_name = 'insights'
    
    VALID_PROMPT_CODES = [
        'late_night_viewing',
        'excessive_watching',
        'inappropriate_content'
    ]
    
    VALID_SEVERITIES = ['low', 'moderate', 'high']
    
    @staticmethod
    def validate_insight(data):
        required_fields = ['user_id', 'prompt_code', 'severity', 'evidence']
        if not all(field in data for field in required_fields):
            raise ValueError('user_id, prompt_code, severity, and evidence are required')
            
        if data['prompt_code'] not in Insight.VALID_PROMPT_CODES:
            raise ValueError(f'Invalid prompt_code. Must be one of: {", ".join(Insight.VALID_PROMPT_CODES)}')
            
        if data['severity'] not in Insight.VALID_SEVERITIES:
            raise ValueError(f'Invalid severity. Must be one of: {", ".join(Insight.VALID_SEVERITIES)}')
            
        # Validate evidence format
        if not isinstance(data['evidence'], list):
            raise ValueError('Evidence must be a list')
            
        for evidence in data['evidence']:
            if not all(key in evidence for key in ['video', 'watched_at', 'duration_sec']):
                raise ValueError('Each evidence must contain video, watched_at, and duration_sec')
        
        return True
    
    @staticmethod
    def format_insight(insight):
        if insight:
            insight['_id'] = str(insight['_id'])
            insight['user_id'] = str(insight['user_id'])
        return insight
    
    @staticmethod
    def create_insight(db, data):
        """Create a new insight with current timestamps"""
        now = datetime.utcnow()
        data['first_flagged'] = now
        data['last_seen'] = now
        data['resolved_at'] = None
        return db.insights.insert_one(data) 
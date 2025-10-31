from pymongo import MongoClient
from ..config import MONGO_URI, DATABASE_NAME, YOUTUBE_HISTORY_COLLECTION

class MongoService:
    def __init__(self, db=None):
        if db is not None:
            self.db = db
        else:
            self.client = MongoClient(MONGO_URI)
            self.db = self.client[DATABASE_NAME]
        self.youtube_history = self.db[YOUTUBE_HISTORY_COLLECTION]

    def has_youtube_history(self, user_id):
        """
        Check if user has uploaded YouTube history data
        """
        count = self.youtube_history.count_documents({"user_id": user_id})
        return count > 0

    def save_youtube_history(self, history_data):
        """
        Save YouTube history data to MongoDB
        """
        if isinstance(history_data, list):
            result = self.youtube_history.insert_many(history_data)
            return len(result.inserted_ids)
        else:
            result = self.youtube_history.insert_one(history_data)
            return str(result.inserted_id)

    def get_youtube_history(self, user_id):
        """
        Retrieve YouTube history data for a specific user
        """
        return list(self.youtube_history.find({"user_id": user_id}, {'_id': 0})) 
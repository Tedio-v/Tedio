#!/usr/bin/env python3
"""
WSGI entry point for production deployment
"""
import os
import sys
from pathlib import Path

# Add the backend directory to Python path
backend_dir = Path(__file__).parent
sys.path.insert(0, str(backend_dir))

from app import app

# Set production environment
os.environ.setdefault('FLASK_ENV', 'production')

if __name__ == "__main__":
    app.run()
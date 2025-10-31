#!/bin/bash

# Production startup script for Tedio Backend

echo "🚀 Starting Tedio Backend in Production Mode..."

# Set production environment
export FLASK_ENV=production
export PYTHONPATH="${PYTHONPATH}:$(pwd)"

# Install/upgrade gunicorn if needed
pip install gunicorn==21.2.0

# Check if gunicorn config exists
if [ ! -f "gunicorn_config.py" ]; then
    echo "❌ Error: gunicorn_config.py not found!"
    exit 1
fi

# Check if wsgi.py exists  
if [ ! -f "wsgi.py" ]; then
    echo "❌ Error: wsgi.py not found!"
    exit 1
fi

echo "📋 Configuration:"
echo "   - Workers: 4"
echo "   - Host: 0.0.0.0"
echo "   - Port: 5001"
echo "   - Logs: access.log, error.log"
echo ""

# Start gunicorn
echo "🔥 Starting Gunicorn server..."
gunicorn --config gunicorn_config.py wsgi:app

echo "✅ Production server started successfully!"
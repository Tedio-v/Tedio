from app import app
import os

if __name__ == '__main__':
    # Check if we're in production
    is_production = os.getenv('FLASK_ENV') == 'production'
    
    if is_production:
        print("ERROR: Do not use Flask's development server in production!")
        print("Use gunicorn instead:")
        print("  gunicorn --config gunicorn_config.py wsgi:app")
        exit(1)
    else:
        print("Running in development mode...")
        app.run(debug=True, host='0.0.0.0', port=5001) 
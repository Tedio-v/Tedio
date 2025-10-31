# Gunicorn configuration file
import os

# Server socket
bind = "0.0.0.0:5001"
backlog = 2048

# Worker processes
workers = 4  # 2 * CPU cores + 1
worker_class = "sync"
worker_connections = 1000
timeout = 30
keepalive = 2

# Restart workers after this many requests (prevents memory leaks)
max_requests = 1000
max_requests_jitter = 50

# Logging
accesslog = "access.log"
errorlog = "error.log"
loglevel = "info"
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'

# Process naming
proc_name = "tedio_backend"

# Server mechanics
daemon = False
pidfile = "gunicorn.pid"
user = None
group = None
tmp_upload_dir = None

# SSL (uncomment if you have SSL certificates)
# keyfile = "path/to/keyfile"
# certfile = "path/to/certfile"
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY Web/backend/requirements.txt .

# Install Python dependencies with specific versions
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application code (excluding __pycache__ and other unnecessary files)
COPY Web/backend/ .

# Remove any __pycache__ directories that might have been copied
RUN find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
RUN find . -name "*.pyc" -delete 2>/dev/null || true

# Create a non-root user for security
RUN adduser --disabled-password --gecos '' appuser && \
    chown -R appuser:appuser /app
USER appuser

EXPOSE 5001

CMD ["python", "run.py"]
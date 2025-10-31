#!/bin/bash

# Tedio Deployment Script - Zero Downtime
# Syncs code to server and performs rolling updates

set -e  # Exit on error

# Configuration - UPDATE THESE
SERVER_USER="root"
SERVER_HOST="178.128.74.9"
SERVER_PATH="/root/Tedio"
LOCAL_PATH="/Users/fawwazali/Vsprojs/Tedio/Web"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Tedio Deployment Starting...${NC}\n"

# Check if server details are configured
if [ "$SERVER_HOST" = "your-server-ip-or-domain" ]; then
    echo -e "${RED}❌ Error: Please update SERVER_HOST in deploy.sh${NC}"
    exit 1
fi

# Step 1: Sync code to server
echo -e "${YELLOW}📦 Step 1/4: Syncing code to server...${NC}"
rsync -avz --progress \
    --exclude 'node_modules' \
    --exclude '__pycache__' \
    --exclude '*.pyc' \
    --exclude '.env' \
    --exclude 'dist' \
    --exclude '.DS_Store' \
    "$LOCAL_PATH/" "${SERVER_USER}@${SERVER_HOST}:${SERVER_PATH}/"

echo -e "${GREEN}✅ Code synced successfully!${NC}\n"

# Step 2: Backup database (quick, just in case)
echo -e "${YELLOW}📊 Step 2/4: Creating quick backup...${NC}"
ssh "${SERVER_USER}@${SERVER_HOST}" << 'EOF'
    cd /root/Tedio
    BACKUP_NAME="pre_deploy_$(date +%Y%m%d_%H%M%S)"
    mkdir -p ~/tedio_backups
    docker exec tedio-mongodb-1 mongodump \
        --username admin \
        --password "${MONGO_PASSWORD:-admin}" \
        --authenticationDatabase admin \
        --db tedio \
        --archive=/tmp/${BACKUP_NAME}.archive \
        --gzip
    docker cp tedio-mongodb-1:/tmp/${BACKUP_NAME}.archive ~/tedio_backups/
    docker exec tedio-mongodb-1 rm /tmp/${BACKUP_NAME}.archive
    echo "Backup saved: ~/tedio_backups/${BACKUP_NAME}.archive"
EOF

echo -e "${GREEN}✅ Backup created!${NC}\n"

# Step 3: Rebuild and update containers (zero downtime)
echo -e "${YELLOW}🔄 Step 3/4: Rebuilding and updating containers...${NC}"
ssh "${SERVER_USER}@${SERVER_HOST}" << 'EOF'
    cd /root/Tedio

    echo "Building new images..."
    docker-compose build --no-cache

    echo "Updating backend (rolling)..."
    docker-compose up -d --no-deps --build backend
    sleep 5  # Wait for backend to be ready

    echo "Updating frontend (rolling)..."
    docker-compose up -d --no-deps --build frontend
    sleep 3

    echo "Checking container health..."
    docker ps | grep tedio
EOF

echo -e "${GREEN}✅ Containers updated!${NC}\n"

# Step 4: Health check
echo -e "${YELLOW}🏥 Step 4/4: Running health checks...${NC}"
ssh "${SERVER_USER}@${SERVER_HOST}" << 'EOF'
    # Check if all containers are running
    if docker ps | grep -q "tedio-backend" && docker ps | grep -q "tedio-frontend" && docker ps | grep -q "tedio-mongodb"; then
        echo "✅ All containers are running"
    else
        echo "❌ Some containers are not running!"
        docker ps -a | grep tedio
        exit 1
    fi

    # Check backend health
    sleep 2
    if curl -f http://localhost:5001/health > /dev/null 2>&1 || curl -f http://localhost:5001/ > /dev/null 2>&1; then
        echo "✅ Backend is responding"
    else
        echo "⚠️  Backend health check failed (might not have /health endpoint)"
    fi

    # Check frontend
    if curl -f http://localhost:80 > /dev/null 2>&1; then
        echo "✅ Frontend is responding"
    else
        echo "⚠️  Frontend health check failed"
    fi
EOF

echo -e "\n${GREEN}✨ Deployment completed successfully!${NC}"
echo -e "${BLUE}📍 Your app should now be running with the latest code${NC}"
echo -e "${YELLOW}💡 Tip: Check logs with: ssh ${SERVER_USER}@${SERVER_HOST} 'cd ${SERVER_PATH} && docker-compose logs -f'${NC}\n"

#!/bin/bash

# Server-Side Update Script
# Run this directly on the server after uploading new code

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔄 Starting Tedio Update...${NC}\n"

# Quick backup before update
echo -e "${YELLOW}1. Creating backup...${NC}"
BACKUP_NAME="pre_update_$(date +%Y%m%d_%H%M%S)"
mkdir -p ~/tedio_backups

docker exec tedio-mongodb-1 mongodump \
    --username admin \
    --password "${MONGO_PASSWORD:-admin}" \
    --authenticationDatabase admin \
    --db tedio \
    --archive=/tmp/${BACKUP_NAME}.archive \
    --gzip 2>/dev/null || echo "Backup skipped"

if docker exec tedio-mongodb-1 test -f /tmp/${BACKUP_NAME}.archive; then
    docker cp tedio-mongodb-1:/tmp/${BACKUP_NAME}.archive ~/tedio_backups/
    docker exec tedio-mongodb-1 rm /tmp/${BACKUP_NAME}.archive
    echo -e "${GREEN}✅ Backup saved${NC}\n"
fi

# Build new images
echo -e "${YELLOW}2. Building new images...${NC}"
docker-compose build --no-cache

# Update backend first (zero downtime - old container runs until new one is ready)
echo -e "${YELLOW}3. Updating backend...${NC}"
docker-compose up -d --no-deps --build backend
sleep 5

# Update frontend
echo -e "${YELLOW}4. Updating frontend...${NC}"
docker-compose up -d --no-deps --build frontend
sleep 2

# Clean up old images
echo -e "${YELLOW}5. Cleaning up...${NC}"
docker image prune -f

# Status check
echo -e "\n${YELLOW}📊 Container Status:${NC}"
docker ps | grep tedio || docker ps

echo -e "\n${GREEN}✅ Update complete!${NC}"
echo -e "${BLUE}💡 Check logs: docker-compose logs -f${NC}\n"

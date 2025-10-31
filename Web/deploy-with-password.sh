#!/bin/bash

# Tedio Deployment Script - Password-based version
# This will prompt for password 3-4 times during deployment

set -e

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

echo -e "${BLUE}🚀 Tedio Deployment Starting...${NC}"
echo -e "${YELLOW}⚠️  You'll be prompted for password multiple times${NC}\n"

# Step 1: Sync code
echo -e "${YELLOW}📦 Step 1/3: Syncing code to server...${NC}"
rsync -avz --progress \
    --exclude 'node_modules' \
    --exclude '__pycache__' \
    --exclude '*.pyc' \
    --exclude '.env' \
    --exclude 'dist' \
    --exclude '.DS_Store' \
    "$LOCAL_PATH/" "${SERVER_USER}@${SERVER_HOST}:${SERVER_PATH}/"

echo -e "${GREEN}✅ Code synced!${NC}\n"

# Step 2: Make update script executable
echo -e "${YELLOW}🔧 Step 2/3: Preparing update script...${NC}"
ssh "${SERVER_USER}@${SERVER_HOST}" "cd ${SERVER_PATH} && chmod +x update.sh"

# Step 3: Run update on server
echo -e "${YELLOW}🔄 Step 3/3: Running update on server...${NC}"
ssh -t "${SERVER_USER}@${SERVER_HOST}" "cd ${SERVER_PATH} && ./update.sh"

echo -e "\n${GREEN}✨ Deployment completed!${NC}"
echo -e "${BLUE}📍 Check status: ssh ${SERVER_USER}@${SERVER_HOST} 'cd ${SERVER_PATH} && docker ps'${NC}\n"

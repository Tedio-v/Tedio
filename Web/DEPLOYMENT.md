# Tedio Deployment Guide

## Quick Overview

You have **two deployment methods**:

### Method 1: Automated Deploy from Local Machine (Recommended)
Automatically syncs code and updates server

### Method 2: Manual Upload + Update
Upload code manually, then run update script on server

---

## Method 1: Automated Deployment (Recommended)

### Setup (One-time)

1. **Update deploy.sh with your server details:**
   ```bash
   nano deploy.sh
   # Change SERVER_HOST to your server IP or domain
   ```

2. **Make script executable:**
   ```bash
   chmod +x deploy.sh
   ```

3. **Ensure SSH key access to server:**
   ```bash
   ssh-copy-id root@your-server-ip
   ```

### Deploy Updates

Simply run from your local machine:
```bash
./deploy.sh
```

That's it! The script will:
- ✅ Sync code to server (excluding node_modules, etc.)
- ✅ Create automatic backup
- ✅ Rebuild Docker images
- ✅ Update containers with zero downtime
- ✅ Run health checks

**MongoDB data is NEVER touched** - it lives in Docker volumes and persists through updates.

---

## Method 2: Manual Deployment

### Step 1: Upload Code to Server

**Option A - Using rsync:**
```bash
rsync -avz --exclude 'node_modules' --exclude '__pycache__' \
  ./Web/ root@your-server:/root/Tedio/
```

**Option B - Using scp:**
```bash
# Create a zip first
zip -r tedio-update.zip backend ui docker-compose.yml update.sh \
  -x "*/node_modules/*" "*/__pycache__/*" "*.pyc"

# Copy to server
scp tedio-update.zip root@your-server:/root/

# On server: extract
ssh root@your-server
cd /root/Tedio
unzip -o /root/tedio-update.zip
```

### Step 2: Run Update Script on Server

```bash
ssh root@your-server
cd /root/Tedio
chmod +x update.sh
./update.sh
```

---

## What Happens During Update?

1. **Backup Created** - Quick MongoDB dump (just in case)
2. **Images Built** - New Docker images with your latest code
3. **Backend Updated** - Old backend keeps running until new one is ready
4. **Frontend Updated** - Seamless switch to new frontend
5. **Cleanup** - Old unused images removed

**Zero Downtime!** Users won't notice anything.

---

## Data Safety

### Your data is safe because:
- MongoDB data lives in Docker **volume** (`mongodb_data`)
- Volumes persist even when containers restart
- Update process never touches volumes
- Backup created before every deployment

### Check your data volumes:
```bash
docker volume ls | grep tedio
docker volume inspect tedio_mongodb_data
```

---

## Common Commands

### Check deployment status:
```bash
ssh root@your-server 'cd /root/Tedio && docker ps'
```

### View logs:
```bash
ssh root@your-server 'cd /root/Tedio && docker-compose logs -f'
```

### View backend logs only:
```bash
ssh root@your-server 'docker logs -f tedio-backend'
```

### View frontend logs only:
```bash
ssh root@your-server 'docker logs -f tedio-frontend'
```

### Restart a specific service (if needed):
```bash
ssh root@your-server 'cd /root/Tedio && docker-compose restart backend'
```

---

## Rollback (If Something Goes Wrong)

### Quick rollback to previous images:
```bash
ssh root@your-server
cd /root/Tedio

# See recent images
docker images | grep tedio

# Use image ID to rollback (find the previous image)
docker tag <old-image-id> tedio-backend:latest
docker-compose up -d --no-deps backend
```

### Restore from backup:
```bash
ssh root@your-server
cd ~/tedio_backups
ls -lt  # Find your backup

# Restore
docker exec -i tedio-mongodb-1 mongorestore \
  --username admin \
  --password $MONGO_PASSWORD \
  --authenticationDatabase admin \
  --archive=/tmp/restore.archive \
  --gzip \
  --drop

docker cp <backup-file> tedio-mongodb-1:/tmp/restore.archive
```

---

## Tips

1. **Always test locally first** before deploying to production
2. **Deploy during low-traffic times** (though zero-downtime, still safer)
3. **Check logs after deployment** to ensure everything is working
4. **Keep backups** - they're stored in `~/tedio_backups/` on server
5. **Monitor disk space** - old backups accumulate

---

## Troubleshooting

### "Container won't start"
```bash
# Check logs
docker logs tedio-backend
docker logs tedio-frontend

# Check if env variables are set
docker exec tedio-backend env | grep MONGO
```

### "Can't connect to database"
```bash
# Check if MongoDB is running
docker ps | grep mongo

# Check connection from backend
docker exec tedio-backend ping mongodb
```

### "rsync command not found"
Install rsync on your local machine:
- Mac: `brew install rsync`
- Linux: `sudo apt install rsync`

---

## Environment Variables

Make sure these are set on your server:
```bash
# On server
export MONGO_PASSWORD="your-password"
export OPENAI_API_KEY="your-key"

# Or in ~/.bashrc for persistence
echo 'export MONGO_PASSWORD="your-password"' >> ~/.bashrc
echo 'export OPENAI_API_KEY="your-key"' >> ~/.bashrc
```

---

## Next Steps: CI/CD (Optional)

Consider setting up GitHub Actions for automatic deployment:
- Push to `main` branch → Auto deploy
- Run tests before deploying
- Automatic rollback on failure

Let me know if you want help setting this up!

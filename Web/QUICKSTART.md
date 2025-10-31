# Quick Deployment Guide

## Your Server Details (Already Configured)
- **IP:** 178.128.74.9
- **User:** root
- **Path:** /root/Tedio
- **Containers:** tedio-backend, tedio-frontend, tedio-mongodb-1

---

## First Time Setup (Do This Once)

### Option A: Set Up SSH Keys (Recommended)
This allows password-less deployment:

```bash
# Copy your SSH key to server
ssh-copy-id root@178.128.74.9
# Password: TedioServer2025yay

# Test it works
ssh root@178.128.74.9 "echo 'Connected!'"
```

**After this, use:** `./deploy.sh`

---

### Option B: Use Password Each Time
Skip SSH key setup and use password when prompted.

**Use:** `./deploy-with-password.sh`

---

## Deploy Your Updates

### If you set up SSH keys:
```bash
cd /Users/fawwazali/Vsprojs/Tedio/Web
./deploy.sh
```

### If using password:
```bash
cd /Users/fawwazali/Vsprojs/Tedio/Web
./deploy-with-password.sh
# Enter password when prompted: TedioServer2025yay
```

---

## What Happens During Deployment

1. ✅ **Syncs your code** to server (excludes node_modules, cache)
2. ✅ **Creates backup** of database (just in case)
3. ✅ **Rebuilds Docker images** with new code
4. ✅ **Updates backend** (old one keeps running until new is ready)
5. ✅ **Updates frontend** (seamless switch)
6. ✅ **Health checks** verify everything works

**Your MongoDB data is NEVER touched - it's in Docker volumes and persists through all updates.**

---

## Check Deployment Status

```bash
# See running containers
ssh root@178.128.74.9 "docker ps"

# View logs
ssh root@178.128.74.9 "cd /root/Tedio && docker-compose logs -f"

# Check specific service
ssh root@178.128.74.9 "docker logs -f tedio-backend"
```

---

## If Something Goes Wrong

### Quick rollback:
```bash
ssh root@178.128.74.9
cd /root/Tedio
docker-compose restart backend
docker-compose restart frontend
```

### Check what's wrong:
```bash
ssh root@178.128.74.9 "cd /root/Tedio && docker-compose logs --tail=50"
```

---

## Tips

1. **Always test locally first** before deploying
2. **Deploy during low traffic** (though it's zero-downtime)
3. **Check logs after deploy** to ensure everything works
4. **Backups are automatic** - stored in ~/tedio_backups/ on server

---

## Quick Commands Reference

```bash
# Deploy
./deploy.sh  # (with SSH keys)
./deploy-with-password.sh  # (with password)

# Check server status
ssh root@178.128.74.9 "docker ps"

# View logs
ssh root@178.128.74.9 "cd /root/Tedio && docker logs -f tedio-backend"

# Restart a service
ssh root@178.128.74.9 "cd /root/Tedio && docker-compose restart backend"

# Access server
ssh root@178.128.74.9
```

---

## Need Help?

- **Full guide:** See DEPLOYMENT.md
- **Server issues:** Check logs with `docker-compose logs`
- **Connection issues:** Verify SSH access with `ssh root@178.128.74.9`

# 🚀 How to Save and Deploy Your Ghost Theme

## Current Status
✅ Ghost theme v15 is ready with:
- Lift-only hover animations (no color changes)
- Ghost CSS override fixes
- All buttons and cards working correctly

## 📁 Theme Location
Your complete theme is in: `/Users/henry/Dev/helen/hugo-to-ghost/cybermonkey-ghost-theme-repo/`

## 💾 Save to Git (Preserve Your Work)

### 1. Initialize Git Repository
```bash
cd /Users/henry/Dev/helen/hugo-to-ghost/cybermonkey-ghost-theme-repo
git init
git add .
git commit -m "feat: Ghost theme v15 - lift-only animations with Ghost overrides"
```

### 2. Push to GitHub/GitLab
```bash
# Create a new repository on GitHub/GitLab first, then:
git remote add origin git@github.com:YOUR_USERNAME/cybermonkey-ghost-theme.git
git branch -M main
git push -u origin main
```

### 3. Create Development Branches
```bash
git checkout -b develop
git push -u origin develop

git checkout -b staging
git push -u origin staging
```

## 🏗️ Deploy to Environments

### Option 1: Quick Manual Deploy
```bash
# Build the theme
cd /Users/henry/Dev/helen/hugo-to-ghost/cybermonkey-ghost-theme-repo
./build.sh

# This creates: cybermonkey-ghost-theme.zip
# Upload via Ghost Admin > Settings > Design > Upload theme
```

### Option 2: Docker Deployment
```bash
# Copy to your Ghost container
docker cp cybermonkey-ghost-theme.zip YOUR_GHOST_CONTAINER:/tmp/

# Install in container
docker exec YOUR_GHOST_CONTAINER bash -c "
  cd /var/lib/ghost/content/themes/
  unzip -o /tmp/cybermonkey-ghost-theme.zip
  rm /tmp/cybermonkey-ghost-theme.zip
  chown -R node:node cybermonkey-ghost-theme/
"

# Restart Ghost
docker restart YOUR_GHOST_CONTAINER
```

### Option 3: Nomad CI/CD Setup

#### 1. Set GitHub Secrets
In your GitHub repository settings, add:
```
NOMAD_ADDR_STAGING=http://your-nomad-server:4646
NOMAD_TOKEN_STAGING=your-staging-token
GHOST_URL_STAGING=https://staging.cybermonkey.net.au
NOMAD_ADDR_PROD=http://your-nomad-server:4646
NOMAD_TOKEN_PROD=your-production-token
GHOST_URL_PROD=https://cybermonkey.net.au
```

#### 2. Deploy via Git Push
```bash
# Deploy to staging
git checkout staging
git merge develop
git push origin staging  # Triggers CI/CD

# Deploy to production
git checkout main
git merge staging
git push origin main     # Triggers CI/CD
```

#### 3. Manual Nomad Deploy
```bash
# Deploy using the simple Nomad job
nomad job dispatch ghost-theme-update \
  -meta environment="production" \
  -meta theme_url="https://your-storage.com/theme.zip" \
  -meta ghost_container="ghost-prod"
```

## 📋 Quick Reference

### File Locations
- **Theme source**: `/Users/henry/Dev/helen/hugo-to-ghost/cybermonkey-ghost-theme-repo/`
- **Built theme**: `cybermonkey-ghost-theme.zip` (after running `./build.sh`)
- **CI/CD config**: `.github/workflows/deploy.yml`
- **Nomad jobs**: `nomad/ghost-theme-deploy.hcl` and `nomad/ghost-theme-deploy-simple.hcl`

### Key Commands
```bash
# Build theme
./build.sh

# Deploy to staging
./deploy.sh staging

# Deploy to production
./deploy.sh production

# Test theme locally
cd /path/to/ghost/content/themes
ln -s /Users/henry/Dev/helen/hugo-to-ghost/cybermonkey-ghost-theme-repo cybermonkey-ghost-theme
ghost restart
```

## 🔍 Verify Deployment

### Check Theme is Active
1. Visit your Ghost site
2. View page source
3. Look for: `<link rel="stylesheet" type="text/css" href="/assets/css/main.css?v=bc74c0abe9">`
4. Check hover effects work (lift animations only)

### Troubleshooting
```bash
# Check Ghost logs
docker logs YOUR_GHOST_CONTAINER --tail 100

# Verify theme files
docker exec YOUR_GHOST_CONTAINER ls -la /var/lib/ghost/content/themes/cybermonkey-ghost-theme/

# Clear Ghost cache
docker restart YOUR_GHOST_CONTAINER
```

## 📝 Next Steps

1. **Test thoroughly** in staging before production
2. **Monitor** Ghost logs during first deployment
3. **Tag releases** for easy rollback: `git tag -a v1.15.0 -m "Initial production release"`
4. **Document** any environment-specific changes

## Need Help?
- Check `DEPLOYMENT.md` for detailed instructions
- Review Ghost logs for errors
- Ensure all GitHub secrets are set correctly
# Helen Project - Deployment Guide

## Current Status
This repository contains:
- Hugo static site (production)
- Ghost CMS setup (in migration)
- Migration tools and scripts
- Custom Ghost theme with Hugo styling

## Known Issues
1. Ghost is currently running in development mode on local Docker
2. Some pages have null content due to database issues
3. Multiple duplicate pages need cleanup
4. URL structure needs standardization

## Ubuntu/Nomad Deployment Steps

### Prerequisites
- Ubuntu 20.04+ server
- Docker installed
- Nomad and Consul installed
- PostgreSQL or MySQL for production Ghost

### 1. Clone Repository
```bash
git clone <your-repo-url>
cd helen
```

### 2. Environment Setup
```bash
# Copy environment template
cp .env.example .env

# Edit with your production values
# - GHOST_URL
# - Database credentials
# - SMTP settings
```

### 3. Database Setup
For production, use PostgreSQL or MySQL instead of SQLite:

```bash
# PostgreSQL example
sudo -u postgres createdb ghost_production
sudo -u postgres createuser ghost_user -P
```

### 4. Nomad Job Files
See `nomad/` directory for:
- `ghost-app.nomad` - Ghost CMS job
- `hugo-static.nomad` - Hugo static site job
- `nginx-proxy.nomad` - Reverse proxy configuration

### 5. Migration Steps
1. Build Hugo site: `hugo --minify`
2. Import content to Ghost: `cd migration && ./import_now.sh`
3. Upload theme: Use `cybermonkey-ghost-theme-clean.zip`
4. Configure navigation in Ghost admin
5. Set up redirects for old URLs

### 6. Production Configuration
Update `docker-compose-production.yml` with:
- Production database
- Persistent volumes
- Proper networking
- SSL/TLS configuration

## Architecture Overview
```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Nginx     │────▶│    Hugo     │     │ PostgreSQL  │
│   Proxy     │     │   Static    │     │     DB      │
│             │────▶│   Files     │     │             │
└─────────────┘     └─────────────┘     └─────────────┘
       │                                        ▲
       │                                        │
       ▼                                        │
┌─────────────┐                                │
│   Ghost     │────────────────────────────────┘
│    CMS      │
└─────────────┘
```

## Next Steps on Ubuntu
1. Set up Consul for service discovery
2. Configure Nomad jobs for each service
3. Set up Traefik/Nginx for routing
4. Configure SSL with Let's Encrypt
5. Set up monitoring (Prometheus/Grafana)
6. Configure backups

## Important Notes
- Current Ghost container uses development mode - DO NOT use in production
- Theme navigation is partially hardcoded - needs Ghost dynamic nav
- Migration scripts assume local environment - update for production
- Some Hugo content didn't migrate properly (_index.md files)
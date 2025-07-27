# Quick Deploy Guide for Code Monkey Cybersecurity Website

## Prerequisites Checklist
- [ ] Ubuntu server with Docker, Nomad, and Consul installed
- [ ] PostgreSQL database set up
- [ ] Domain pointing to your server (cybermonkey.net.au)
- [ ] SSL certificates configured (or Traefik auto-SSL)

## Step 1: Create Environment File
```bash
cp .env.example .env
# Edit .env with your actual values:
# - DB_PASSWORD: Strong database password
# - MAIL_USER: Your Mailgun SMTP username
# - MAIL_PASSWORD: Your Mailgun SMTP password
```

## Step 2: Test with Docker Compose First
```bash
# Test the setup locally first
docker-compose -f docker-compose-production.yml up -d

# Check logs
docker-compose -f docker-compose-production.yml logs -f ghost

# If everything works, stop it
docker-compose -f docker-compose-production.yml down
```

## Step 3: Set Up Consul Secrets
```bash
# Store secrets in Consul KV store
consul kv put ghost/db/password "your_database_password"
consul kv put ghost/mail/user "your_mailgun_user"
consul kv put ghost/mail/password "your_mailgun_password"
```

## Step 4: Deploy with Nomad
```bash
# Deploy the job
nomad job run nomad/ghost-cms.nomad

# Check status
nomad job status ghost-cms

# Get allocation ID
nomad job status ghost-cms | grep -A1 "Allocations"

# View logs (replace with your alloc ID)
nomad alloc logs -f <allocation-id>
```

## Step 5: Verify Deployment
1. Check Ghost is running: `curl http://localhost:2368/ghost/api/admin/site/`
2. Access admin panel: https://cybermonkey.net.au/ghost
3. Complete Ghost setup wizard

## Troubleshooting Commands
```bash
# Check Nomad job status
nomad job status ghost-cms

# Check allocation status
nomad alloc status <allocation-id>

# View task logs
nomad alloc logs <allocation-id> ghost
nomad alloc logs <allocation-id> postgres

# Check Consul services
consul catalog services
consul catalog nodes -service=ghost-cms

# Check Docker containers (if using docker-compose)
docker ps
docker logs ghost-cms
```

## Important Notes
1. The Nomad job creates both Ghost and PostgreSQL in the same job
2. Data is persisted in Docker volumes
3. Traefik handles SSL automatically via Let's Encrypt
4. Ghost content is stored in the `ghost-content` volume
5. Database data is in the `postgres-data` volume

## Next Steps After Deployment
1. Set up regular backups of volumes
2. Configure monitoring (Prometheus/Grafana)
3. Set up log aggregation
4. Configure CDN for static assets
5. Import existing Ghost content
# Ghost CMS Deployment Guide

This guide covers the deployment of Ghost CMS using Nomad with SQLite database and Mailcow SMTP integration.

## Overview

The Ghost CMS deployment is configured with:
- **SQLite3 database** - Production-ready, no separate database container needed
- **Port 8009** - Direct exposure for Caddy reverse proxy integration
- **Mailcow SMTP** - Email functionality via your Mailcow instance
- **Persistent storage** - Nomad host volumes for data persistence
- **Lightweight** - No Traefik, TLS handled by external Caddy proxy

## Prerequisites

1. Nomad and Consul running on your system
2. Mailcow instance for SMTP
3. Caddy reverse proxy configured to forward to port 8009

## Quick Start

### 1. Configure Mail Settings

Copy the template and edit with your Mailcow details:

```bash
cp .env.mailcow .env
nano .env
```

Required settings:
- `MAIL_HOST`: Your Mailcow server (e.g., mail.yourdomain.com)
- `MAIL_PORT`: Usually 587 for STARTTLS
- `MAIL_USER`: Full email address for authentication
- `MAIL_PASSWORD`: SMTP password from Mailcow
- `MAIL_FROM`: Default from address for Ghost emails

### 2. Deploy Ghost

```bash
./deploy-ghost-sqlite.sh
```

This script will:
- Create persistent volume at `/opt/nomad/volumes/ghost-data`
- Store mail credentials in Consul
- Deploy Ghost on port 8009
- Display the allocation ID for monitoring

### 3. Access Ghost

- **Direct**: http://localhost:8009
- **Via Caddy**: https://cybermonkey.net.au (configure your domain)
- **Admin**: http://localhost:8009/ghost

## Caddy Configuration

Add to your Caddyfile:

```caddy
cybermonkey.net.au {
    reverse_proxy localhost:8009
}
```

## Data Management

### Backup

Create manual backups:
```bash
./nomad/backup-sqlite.sh
```

Schedule automatic backups:
```bash
# Add to crontab
0 2 * * * /opt/helen/nomad/backup-sqlite.sh >> /var/log/ghost-backup.log 2>&1
```

### Restore

List available backups:
```bash
ls -1 /opt/nomad/backups/
```

Restore from backup:
```bash
./nomad/restore-sqlite.sh 20240121_140530
```

## File Locations

- **Ghost data**: `/opt/nomad/volumes/ghost-data/`
- **SQLite database**: `/opt/nomad/volumes/ghost-data/data/ghost.db`
- **Uploaded content**: `/opt/nomad/volumes/ghost-data/content/`
- **Backups**: `/opt/nomad/backups/`

## Monitoring

View logs:
```bash
# Get allocation ID
nomad job status ghost-cms

# Stream logs
nomad alloc logs -f <alloc-id> ghost
```

Check job status:
```bash
nomad job status ghost-cms
```

## Troubleshooting

### Port 8009 Not Accessible

1. Check if Ghost is running:
   ```bash
   nomad job status ghost-cms
   ```

2. Verify port binding:
   ```bash
   ss -tlnp | grep 8009
   ```

3. Check Nomad allocation:
   ```bash
   nomad alloc status <alloc-id>
   ```

### Mail Not Working

1. Verify Consul KV:
   ```bash
   consul kv get ghost/mail/user
   consul kv get ghost/mail/password
   ```

2. Check Ghost logs for SMTP errors:
   ```bash
   nomad alloc logs <alloc-id> ghost | grep -i smtp
   ```

3. Test Mailcow credentials manually

### Database Issues

1. Check database file:
   ```bash
   ls -la /opt/nomad/volumes/ghost-data/data/ghost.db
   ```

2. Verify permissions:
   ```bash
   ls -la /opt/nomad/volumes/ghost-data/
   # Should be owned by UID 1000
   ```

3. Check database integrity:
   ```bash
   sqlite3 /opt/nomad/volumes/ghost-data/data/ghost.db "PRAGMA integrity_check;"
   ```

## Security Considerations

1. **Consul ACLs**: Enable ACLs in production to protect mail credentials
2. **Volume Permissions**: Ensure volumes are only accessible by Nomad
3. **Backup Encryption**: Consider encrypting backups before storage
4. **Network Security**: Use firewall rules to restrict port 8009 access

## Migration from Docker

If you have an existing Ghost Docker deployment:

1. Export your content from the old Ghost admin panel
2. Deploy the new Nomad-based Ghost
3. Import your content via the new Ghost admin panel
4. Update DNS/proxy to point to the new instance

## Updates

To update Ghost:

1. Update the image version in `nomad/ghost-sqlite.nomad`
2. Create a backup: `./nomad/backup-sqlite.sh`
3. Redeploy: `nomad job run nomad/ghost-sqlite.nomad`
4. Verify the update in Ghost admin
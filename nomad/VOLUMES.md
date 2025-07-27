# Nomad Persistent Volume Management

This document describes the persistent volume setup for the Ghost CMS deployment on Nomad.

## Overview

The Ghost CMS deployment uses Nomad host volumes for persistent storage, providing better control and portability compared to Docker volumes. This setup includes:

- **Ghost Content Volume**: Stores themes, images, and uploaded content
- **PostgreSQL Data Volume**: Stores the database files

## Architecture

```
/opt/nomad/volumes/
├── ghost-content/     # Ghost CMS content (themes, images, uploads)
└── postgres-data/     # PostgreSQL database files
```

## Initial Setup

### 1. Configure Nomad Client

Add the host volume configuration to your Nomad client config (`/etc/nomad.d/client.hcl`):

```bash
sudo cp nomad/client-config.hcl /etc/nomad.d/
sudo systemctl restart nomad
```

### 2. Create Volume Directories

Run the setup script to create and configure the volume directories:

```bash
./nomad/setup-volumes.sh
```

This script:
- Creates volume directories at `/opt/nomad/volumes/`
- Sets appropriate permissions (UID 1000 for Ghost, UID 999 for PostgreSQL)
- Provides instructions for next steps

### 3. Deploy the Application

Use the persistent volume deployment script:

```bash
./deploy-nomad-persistent.sh
```

## Volume Management

### Backup Procedures

Regular backups are crucial for data protection. The backup script creates timestamped backups of both volumes.

#### Manual Backup

```bash
./nomad/backup-volumes.sh
```

This creates:
- `ghost-content-TIMESTAMP.tar.gz`: Complete Ghost content directory
- `ghost-db-TIMESTAMP.sql`: PostgreSQL database dump (if job is running)
- `postgres-data-TIMESTAMP.tar.gz`: Raw PostgreSQL data files (fallback)

Backups are stored in `/opt/nomad/backups/TIMESTAMP/`

#### Automated Backups

Set up a cron job for regular backups:

```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * /opt/helen/nomad/backup-volumes.sh >> /var/log/ghost-backup.log 2>&1
```

### Restore Procedures

To restore from a backup:

1. List available backups:
   ```bash
   ls -1 /opt/nomad/backups/
   ```

2. Restore from a specific backup:
   ```bash
   ./nomad/restore-volumes.sh 20240121_140530
   ```

The restore script:
- Stops the running job
- Backs up current volumes (with `.pre-restore` suffix)
- Restores the selected backup
- Restarts the job
- Restores database from SQL dump if available

### Migration from Docker Volumes

If migrating from an existing Docker-based deployment:

1. The deployment script will detect existing Docker volumes
2. Choose "yes" when prompted to migrate data
3. Data will be copied from Docker volumes to Nomad host volumes
4. Original Docker volumes remain intact as backup

## Troubleshooting

### Volume Permission Issues

If you encounter permission errors:

```bash
# Fix Ghost content permissions
sudo chown -R 1000:1000 /opt/nomad/volumes/ghost-content
sudo chmod -R 755 /opt/nomad/volumes/ghost-content

# Fix PostgreSQL permissions
sudo chown -R 999:999 /opt/nomad/volumes/postgres-data
sudo chmod -R 700 /opt/nomad/volumes/postgres-data
```

### Volume Not Found Errors

If Nomad reports volume not found:

1. Verify Nomad client configuration includes the host volumes
2. Restart Nomad client after configuration changes
3. Ensure volume directories exist on the Nomad client node

### Database Connection Issues

If Ghost cannot connect to PostgreSQL after restore:

1. Check PostgreSQL logs: `nomad alloc logs -f <alloc-id> postgres`
2. Verify database credentials in Consul KV store
3. Ensure PostgreSQL service is healthy in Nomad

## Best Practices

1. **Regular Backups**: Schedule daily backups and retain for at least 7 days
2. **Test Restores**: Periodically test restore procedures in a staging environment
3. **Monitor Disk Space**: Ensure adequate space for volumes and backups
4. **Document Changes**: Keep track of any manual volume modifications
5. **Multi-node Considerations**: 
   - Use shared storage (NFS, GlusterFS) for multi-node clusters
   - Consider CSI plugins for cloud storage backends
   - Implement job constraints to pin to nodes with volumes

## Advanced Configuration

### Using CSI Volumes

For production multi-node clusters, consider using CSI (Container Storage Interface) volumes:

1. Deploy a CSI plugin (e.g., AWS EBS, GCE PD, Ceph)
2. Create CSI volumes in Nomad
3. Update job file to use CSI volumes instead of host volumes

### NFS Shared Storage

For on-premise deployments, NFS provides shared storage across nodes:

1. Set up NFS server with exports for Ghost volumes
2. Mount NFS shares on all Nomad client nodes
3. Configure host volumes pointing to NFS mount points

## Security Considerations

1. **Encryption at Rest**: Consider encrypting volume directories
2. **Backup Encryption**: Encrypt backup files before storing
3. **Access Control**: Restrict volume directory access to Nomad user
4. **Network Security**: Use private networks for NFS/shared storage

## Monitoring

Monitor volume health and usage:

```bash
# Check volume disk usage
df -h /opt/nomad/volumes/*

# Monitor volume directory sizes
du -sh /opt/nomad/volumes/*

# Check recent modifications
find /opt/nomad/volumes -type f -mtime -1 -ls
```
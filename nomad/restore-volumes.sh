#!/bin/bash
# Restore script for Ghost CMS volumes
# Restores from a backup created by backup-volumes.sh

set -e

# Check if backup timestamp provided
if [ -z "$1" ]; then
    echo "❌ Error: Backup timestamp required"
    echo "Usage: $0 <backup_timestamp>"
    echo ""
    echo "Available backups:"
    ls -1 /opt/nomad/backups 2>/dev/null || echo "No backups found"
    exit 1
fi

TIMESTAMP=$1
VOLUME_BASE="/opt/nomad/volumes"
BACKUP_BASE="/opt/nomad/backups"
BACKUP_DIR="${BACKUP_BASE}/${TIMESTAMP}"

echo "🔄 Ghost CMS Volume Restore Script"
echo "=================================="
echo "Restoring from backup: ${TIMESTAMP}"

# Check if backup exists
if [ ! -d "${BACKUP_DIR}" ]; then
    echo "❌ Error: Backup directory not found: ${BACKUP_DIR}"
    exit 1
fi

# Confirm restore
echo ""
echo "⚠️  WARNING: This will replace current data with backup data!"
echo "Current volumes will be backed up with suffix .pre-restore"
read -p "Continue with restore? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Restore cancelled."
    exit 0
fi

# Stop the Ghost CMS job if running
echo ""
echo "🛑 Stopping Ghost CMS job..."
nomad job stop -purge ghost-cms || echo "Job might not be running"
sleep 5

# Backup current volumes before restore
echo ""
echo "📦 Backing up current volumes..."
PRESTORE_TIMESTAMP=$(date +%Y%m%d_%H%M%S)

if [ -d "${VOLUME_BASE}/ghost-content" ]; then
    sudo mv "${VOLUME_BASE}/ghost-content" "${VOLUME_BASE}/ghost-content.pre-restore-${PRESTORE_TIMESTAMP}"
fi

if [ -d "${VOLUME_BASE}/postgres-data" ]; then
    sudo mv "${VOLUME_BASE}/postgres-data" "${VOLUME_BASE}/postgres-data.pre-restore-${PRESTORE_TIMESTAMP}"
fi

# Create fresh volume directories
sudo mkdir -p "${VOLUME_BASE}/ghost-content"
sudo mkdir -p "${VOLUME_BASE}/postgres-data"

# Restore Ghost content
echo ""
echo "📦 Restoring Ghost content..."
if [ -f "${BACKUP_DIR}/ghost-content-${TIMESTAMP}.tar.gz" ]; then
    sudo tar -xzf "${BACKUP_DIR}/ghost-content-${TIMESTAMP}.tar.gz" -C "${VOLUME_BASE}"
    echo "✅ Ghost content restored"
else
    echo "⚠️  Ghost content backup not found"
fi

# Restore PostgreSQL
echo ""
echo "🗄️  Restoring PostgreSQL..."

# Check if we have SQL dump
if [ -f "${BACKUP_DIR}/ghost-db-${TIMESTAMP}.sql" ]; then
    echo "📝 SQL dump found. Will restore after starting the job."
    SQL_RESTORE_NEEDED=true
else
    # Restore from tar backup
    if [ -f "${BACKUP_DIR}/postgres-data-${TIMESTAMP}.tar.gz" ]; then
        sudo tar -xzf "${BACKUP_DIR}/postgres-data-${TIMESTAMP}.tar.gz" -C "${VOLUME_BASE}"
        echo "✅ PostgreSQL data restored from tar backup"
        SQL_RESTORE_NEEDED=false
    else
        echo "❌ No PostgreSQL backup found!"
        SQL_RESTORE_NEEDED=false
    fi
fi

# Fix permissions
echo ""
echo "🔒 Setting permissions..."
sudo chown -R 1000:1000 "${VOLUME_BASE}/ghost-content"
sudo chown -R 999:999 "${VOLUME_BASE}/postgres-data"

# Restart the job
echo ""
echo "🚀 Starting Ghost CMS job..."
nomad job run nomad/ghost-cms-persistent.nomad

# Wait for PostgreSQL to be ready
if [ "$SQL_RESTORE_NEEDED" = true ]; then
    echo ""
    echo "⏳ Waiting for PostgreSQL to start..."
    sleep 20
    
    # Get PostgreSQL allocation
    POSTGRES_ALLOC=$(nomad job status ghost-cms | grep -A10 "Allocations" | grep running | grep postgres | awk '{print $1}' | head -1)
    
    if [ ! -z "$POSTGRES_ALLOC" ]; then
        echo "🗄️  Restoring database from SQL dump..."
        
        # Drop existing database and recreate
        nomad alloc exec -task postgres $POSTGRES_ALLOC psql -U ghost -c "DROP DATABASE IF EXISTS ghost;"
        nomad alloc exec -task postgres $POSTGRES_ALLOC psql -U ghost -c "CREATE DATABASE ghost;"
        
        # Restore from dump
        cat "${BACKUP_DIR}/ghost-db-${TIMESTAMP}.sql" | nomad alloc exec -task postgres -i $POSTGRES_ALLOC psql -U ghost ghost
        
        echo "✅ Database restored from SQL dump"
    else
        echo "❌ Could not find PostgreSQL allocation for SQL restore"
    fi
fi

echo ""
echo "✅ Restore completed!"
echo ""
echo "📋 Post-restore checklist:"
echo "1. Check job status: nomad job status ghost-cms"
echo "2. View logs: nomad alloc logs -f <alloc-id>"
echo "3. Test Ghost at: https://cybermonkey.net.au"
echo ""
echo "💾 Previous volumes backed up with suffix: .pre-restore-${PRESTORE_TIMESTAMP}"
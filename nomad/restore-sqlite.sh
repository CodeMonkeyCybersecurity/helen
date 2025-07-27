#!/bin/bash
# Restore script for Ghost CMS with SQLite
# Restores from a backup created by backup-sqlite.sh

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

echo "🔄 Ghost CMS Restore Script (SQLite)"
echo "===================================="
echo "Restoring from backup: ${TIMESTAMP}"

# Check if backup exists
if [ ! -d "${BACKUP_DIR}" ]; then
    echo "❌ Error: Backup directory not found: ${BACKUP_DIR}"
    exit 1
fi

# Confirm restore
echo ""
echo "⚠️  WARNING: This will replace current Ghost data!"
echo "Current data will be backed up with suffix .pre-restore"
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

# Backup current data before restore
echo ""
echo "📦 Backing up current data..."
PRESTORE_TIMESTAMP=$(date +%Y%m%d_%H%M%S)

if [ -d "${VOLUME_BASE}/ghost-data" ]; then
    sudo mv "${VOLUME_BASE}/ghost-data" "${VOLUME_BASE}/ghost-data.pre-restore-${PRESTORE_TIMESTAMP}"
fi

# Create fresh volume directory
sudo mkdir -p "${VOLUME_BASE}/ghost-data"

# Restore Ghost content
echo ""
echo "📦 Restoring Ghost content..."
if [ -f "${BACKUP_DIR}/ghost-data-${TIMESTAMP}.tar.gz" ]; then
    sudo tar -xzf "${BACKUP_DIR}/ghost-data-${TIMESTAMP}.tar.gz" -C "${VOLUME_BASE}"
    echo "✅ Ghost content restored"
else
    echo "❌ Ghost content backup not found!"
    exit 1
fi

# Restore SQLite database
echo ""
echo "🗄️  Restoring SQLite database..."
DB_BACKUP="${BACKUP_DIR}/ghost-${TIMESTAMP}.db"
DB_RESTORE="${VOLUME_BASE}/ghost-data/data/ghost.db"

if [ -f "$DB_BACKUP" ]; then
    # Ensure data directory exists
    sudo mkdir -p "${VOLUME_BASE}/ghost-data/data"
    
    # Restore database
    sudo cp "$DB_BACKUP" "$DB_RESTORE"
    
    # Restore WAL/SHM files if they exist
    [ -f "${DB_BACKUP}-wal" ] && sudo cp "${DB_BACKUP}-wal" "${DB_RESTORE}-wal"
    [ -f "${DB_BACKUP}-shm" ] && sudo cp "${DB_BACKUP}-shm" "${DB_RESTORE}-shm"
    
    echo "✅ Database restored"
else
    echo "⚠️  Database backup not found - using restored content directory database"
fi

# Fix permissions
echo ""
echo "🔒 Setting permissions..."
sudo chown -R 1000:1000 "${VOLUME_BASE}/ghost-data"
sudo chmod -R 755 "${VOLUME_BASE}/ghost-data"

# Restart the job
echo ""
echo "🚀 Starting Ghost CMS..."
nomad job run nomad/ghost-sqlite.nomad

echo ""
echo "⏳ Waiting for Ghost to start..."
sleep 10

# Get job status
nomad job status ghost-cms

echo ""
echo "✅ Restore completed!"
echo ""
echo "📋 Post-restore checklist:"
echo "1. Check job status: nomad job status ghost-cms"
echo "2. View logs: nomad alloc logs -f <alloc-id> ghost"
echo "3. Test Ghost at: http://localhost:8009"
echo ""
echo "💾 Previous data backed up at: ${VOLUME_BASE}/ghost-data.pre-restore-${PRESTORE_TIMESTAMP}"
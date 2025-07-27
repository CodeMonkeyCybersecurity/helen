#!/bin/bash
# Backup script for Ghost CMS volumes
# Creates timestamped backups of both Ghost content and PostgreSQL data

set -e

# Configuration
VOLUME_BASE="/opt/nomad/volumes"
BACKUP_BASE="/opt/nomad/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="${BACKUP_BASE}/${TIMESTAMP}"

echo "🔄 Ghost CMS Volume Backup Script"
echo "================================="
echo "Backup timestamp: ${TIMESTAMP}"

# Create backup directory
echo "📁 Creating backup directory..."
sudo mkdir -p "${BACKUP_DIR}"

# Function to get Nomad allocation ID
get_alloc_id() {
    local task_name=$1
    nomad job status ghost-cms | grep -A10 "Allocations" | grep running | grep $task_name | awk '{print $1}' | head -1
}

# Backup Ghost content volume
echo ""
echo "📦 Backing up Ghost content..."
if [ -d "${VOLUME_BASE}/ghost-content" ]; then
    sudo tar -czf "${BACKUP_DIR}/ghost-content-${TIMESTAMP}.tar.gz" -C "${VOLUME_BASE}" ghost-content
    echo "✅ Ghost content backed up to: ${BACKUP_DIR}/ghost-content-${TIMESTAMP}.tar.gz"
else
    echo "⚠️  Ghost content directory not found!"
fi

# Backup PostgreSQL data
echo ""
echo "🗄️  Backing up PostgreSQL database..."

# Try to get allocation ID for postgres task
POSTGRES_ALLOC=$(get_alloc_id "postgres")

if [ ! -z "$POSTGRES_ALLOC" ]; then
    echo "Found PostgreSQL allocation: $POSTGRES_ALLOC"
    
    # Create SQL dump using nomad exec
    echo "Creating SQL dump..."
    nomad alloc exec -task postgres $POSTGRES_ALLOC \
        pg_dump -U ghost ghost > "${BACKUP_DIR}/ghost-db-${TIMESTAMP}.sql"
    
    echo "✅ Database dump created: ${BACKUP_DIR}/ghost-db-${TIMESTAMP}.sql"
else
    echo "⚠️  Could not find running PostgreSQL allocation"
    echo "   Falling back to file-based backup..."
    
    # Backup raw PostgreSQL data files
    if [ -d "${VOLUME_BASE}/postgres-data" ]; then
        sudo tar -czf "${BACKUP_DIR}/postgres-data-${TIMESTAMP}.tar.gz" -C "${VOLUME_BASE}" postgres-data
        echo "✅ PostgreSQL data backed up to: ${BACKUP_DIR}/postgres-data-${TIMESTAMP}.tar.gz"
    else
        echo "❌ PostgreSQL data directory not found!"
    fi
fi

# Calculate backup sizes
echo ""
echo "📊 Backup summary:"
sudo ls -lh "${BACKUP_DIR}"

# Cleanup old backups (keep last 7 days)
echo ""
echo "🧹 Cleaning up old backups..."
find "${BACKUP_BASE}" -type d -mtime +7 -exec rm -rf {} + 2>/dev/null || true

echo ""
echo "✅ Backup completed successfully!"
echo "📍 Backup location: ${BACKUP_DIR}"
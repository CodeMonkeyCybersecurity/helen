#!/bin/bash
# Backup script for Ghost CMS with SQLite
# Creates timestamped backups of Ghost data and SQLite database

set -e

# Configuration
VOLUME_BASE="/opt/nomad/volumes"
BACKUP_BASE="/opt/nomad/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="${BACKUP_BASE}/${TIMESTAMP}"

echo "🔄 Ghost CMS Backup Script (SQLite)"
echo "==================================="
echo "Backup timestamp: ${TIMESTAMP}"

# Create backup directory
echo "📁 Creating backup directory..."
sudo mkdir -p "${BACKUP_DIR}"

# Check if Ghost volume exists
if [ ! -d "${VOLUME_BASE}/ghost-data" ]; then
    echo "❌ Ghost data directory not found at ${VOLUME_BASE}/ghost-data"
    exit 1
fi

# Backup SQLite database with proper locking
echo ""
echo "🗄️  Backing up SQLite database..."
DB_PATH="${VOLUME_BASE}/ghost-data/data/ghost.db"

if [ -f "$DB_PATH" ]; then
    # Use sqlite3 backup command for consistency
    if command -v sqlite3 &> /dev/null; then
        echo "Using sqlite3 backup command..."
        sudo sqlite3 "$DB_PATH" ".backup '${BACKUP_DIR}/ghost-${TIMESTAMP}.db'"
    else
        echo "sqlite3 not found, using file copy with integrity check..."
        # Copy database file
        sudo cp "$DB_PATH" "${BACKUP_DIR}/ghost-${TIMESTAMP}.db"
        # Also copy WAL and SHM files if they exist
        [ -f "${DB_PATH}-wal" ] && sudo cp "${DB_PATH}-wal" "${BACKUP_DIR}/ghost-${TIMESTAMP}.db-wal"
        [ -f "${DB_PATH}-shm" ] && sudo cp "${DB_PATH}-shm" "${BACKUP_DIR}/ghost-${TIMESTAMP}.db-shm"
    fi
    echo "✅ Database backed up"
else
    echo "⚠️  Database file not found - Ghost might not be initialized yet"
fi

# Backup entire Ghost content directory
echo ""
echo "📦 Backing up Ghost content directory..."
sudo tar -czf "${BACKUP_DIR}/ghost-data-${TIMESTAMP}.tar.gz" \
    -C "${VOLUME_BASE}" \
    --exclude="ghost-data/logs" \
    --exclude="ghost-data/data/ghost.db-wal" \
    --exclude="ghost-data/data/ghost.db-shm" \
    ghost-data

echo "✅ Ghost content backed up to: ${BACKUP_DIR}/ghost-data-${TIMESTAMP}.tar.gz"

# Create backup metadata
echo ""
echo "📝 Creating backup metadata..."
cat > "${BACKUP_DIR}/backup-info.txt" << EOF
Ghost CMS Backup
================
Timestamp: ${TIMESTAMP}
Date: $(date)
Ghost Volume: ${VOLUME_BASE}/ghost-data
Database: SQLite3

Files in this backup:
- ghost-${TIMESTAMP}.db: SQLite database backup
- ghost-data-${TIMESTAMP}.tar.gz: Complete Ghost content directory

To restore, use: ./restore-sqlite.sh ${TIMESTAMP}
EOF

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
echo ""
echo "💡 Tip: Set up a cron job for automated backups:"
echo "   0 2 * * * ${PWD}/nomad/backup-sqlite.sh >> /var/log/ghost-backup.log 2>&1"
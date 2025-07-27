#!/bin/bash
# Setup script for Nomad host volumes
# Run this on each Nomad client node before deploying the job

set -e

echo "🔧 Setting up Nomad host volumes for Ghost CMS"
echo "============================================="

# Create volume directories
VOLUME_BASE="/opt/nomad/volumes"

echo "📁 Creating volume directories..."
sudo mkdir -p "${VOLUME_BASE}/ghost-content"
sudo mkdir -p "${VOLUME_BASE}/postgres-data"

# Set appropriate permissions
# Docker containers typically run as specific UIDs
# Ghost runs as UID 1000, Postgres as UID 999
echo "🔒 Setting permissions..."
sudo chown -R 1000:1000 "${VOLUME_BASE}/ghost-content"
sudo chown -R 999:999 "${VOLUME_BASE}/postgres-data"
sudo chmod -R 755 "${VOLUME_BASE}"

echo "✅ Volume directories created:"
echo "   - ${VOLUME_BASE}/ghost-content (for Ghost content)"
echo "   - ${VOLUME_BASE}/postgres-data (for PostgreSQL data)"

# Check if Nomad client config exists
NOMAD_CONFIG_DIR="/etc/nomad.d"
if [ -d "$NOMAD_CONFIG_DIR" ]; then
    echo ""
    echo "📝 Nomad configuration directory found at $NOMAD_CONFIG_DIR"
    echo "   Copy client-config.hcl to this directory and restart Nomad"
else
    echo ""
    echo "⚠️  Nomad configuration directory not found"
    echo "   Create $NOMAD_CONFIG_DIR and copy client-config.hcl there"
fi

echo ""
echo "📋 Next steps:"
echo "1. Copy nomad/client-config.hcl to your Nomad configuration directory"
echo "2. Restart Nomad client: sudo systemctl restart nomad"
echo "3. Deploy the job: nomad job run nomad/ghost-cms-persistent.nomad"
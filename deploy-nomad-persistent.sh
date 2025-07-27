#!/bin/bash
# Deploy Ghost CMS to Nomad with Persistent Volumes
# This version includes proper volume setup and management

set -e

echo "🚀 Ghost CMS Nomad Deployment Script (with Persistent Volumes)"
echo "=============================================================="

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ .env file not found!"
    echo "Creating from template..."
    cp .env.example .env
    echo "⚠️  Please edit .env with your actual values and run this script again"
    exit 1
fi

# Load environment variables
source .env

# Check required variables
if [ -z "$DB_PASSWORD" ] || [ "$DB_PASSWORD" = "your_secure_password_here" ]; then
    echo "❌ DB_PASSWORD not set in .env file!"
    echo "Please set a secure database password"
    exit 1
fi

# Check if Nomad is running
if ! nomad status > /dev/null 2>&1; then
    echo "❌ Nomad is not running or not accessible"
    echo "Start Nomad with: sudo nomad agent -dev"
    exit 1
fi

# Check if Consul is running
if ! consul catalog services > /dev/null 2>&1; then
    echo "⚠️  Consul is not running. Starting in dev mode..."
    consul agent -dev > /tmp/consul.log 2>&1 &
    sleep 5
fi

# Check if volume directories exist
VOLUME_BASE="/opt/nomad/volumes"
VOLUMES_EXIST=true

if [ ! -d "${VOLUME_BASE}/ghost-content" ] || [ ! -d "${VOLUME_BASE}/postgres-data" ]; then
    VOLUMES_EXIST=false
    echo "⚠️  Volume directories not found!"
    echo ""
    echo "Would you like to set up the volumes now? (yes/no)"
    read -p "> " setup_volumes
    
    if [ "$setup_volumes" = "yes" ]; then
        echo "🔧 Setting up volumes..."
        ./nomad/setup-volumes.sh
        echo "✅ Volumes created"
    else
        echo "❌ Cannot proceed without volumes. Please run:"
        echo "   ./nomad/setup-volumes.sh"
        exit 1
    fi
fi

# Check if this is a migration from Docker volumes
echo ""
echo "🔍 Checking for existing Docker volumes..."
DOCKER_VOLUMES=$(docker volume ls --format "{{.Name}}" | grep -E "(ghost-content|postgres-data)" || true)

if [ ! -z "$DOCKER_VOLUMES" ]; then
    echo "📦 Found existing Docker volumes:"
    echo "$DOCKER_VOLUMES"
    echo ""
    echo "Would you like to migrate data from Docker volumes? (yes/no)"
    read -p "> " migrate_data
    
    if [ "$migrate_data" = "yes" ]; then
        echo "🔄 Migrating data from Docker volumes..."
        
        # Stop any running Ghost job
        nomad job stop ghost-cms 2>/dev/null || true
        
        # Copy data from Docker volumes
        if docker volume inspect ghost-content > /dev/null 2>&1; then
            echo "Copying ghost-content..."
            docker run --rm -v ghost-content:/source -v "${VOLUME_BASE}/ghost-content":/dest alpine \
                sh -c "cp -av /source/* /dest/"
        fi
        
        if docker volume inspect postgres-data > /dev/null 2>&1; then
            echo "Copying postgres-data..."
            docker run --rm -v postgres-data:/source -v "${VOLUME_BASE}/postgres-data":/dest alpine \
                sh -c "cp -av /source/* /dest/"
        fi
        
        # Fix permissions
        sudo chown -R 1000:1000 "${VOLUME_BASE}/ghost-content"
        sudo chown -R 999:999 "${VOLUME_BASE}/postgres-data"
        
        echo "✅ Data migration completed"
    fi
fi

# Store secrets in Consul
echo ""
echo "📦 Setting up Consul KV store..."
consul kv put ghost/db/password "$DB_PASSWORD"
consul kv put ghost/mail/user "${MAIL_USER:-postmaster@cybermonkey.net.au}"
consul kv put ghost/mail/password "${MAIL_PASSWORD:-changeme}"

# Deploy the job
echo ""
echo "🔄 Deploying Ghost CMS to Nomad..."
nomad job run nomad/ghost-cms-persistent.nomad

echo "⏳ Waiting for deployment to stabilize..."
sleep 10

# Get job status
echo ""
echo "📊 Job Status:"
nomad job status ghost-cms

# Get allocation ID
ALLOC_ID=$(nomad job status ghost-cms | grep -A2 "Allocations" | tail -1 | awk '{print $1}')

if [ ! -z "$ALLOC_ID" ]; then
    echo ""
    echo "📋 Allocation ID: $ALLOC_ID"
    echo ""
    echo "🔍 To view logs, run:"
    echo "   nomad alloc logs -f $ALLOC_ID ghost"
    echo "   nomad alloc logs -f $ALLOC_ID postgres"
else
    echo "⚠️  Could not determine allocation ID"
fi

echo ""
echo "✅ Deployment completed!"
echo ""
echo "🌐 Ghost will be available at:"
echo "   Frontend: https://cybermonkey.net.au"
echo "   Admin: https://cybermonkey.net.au/ghost"
echo ""
echo "💾 Volume Management:"
echo "   Backup:  ./nomad/backup-volumes.sh"
echo "   Restore: ./nomad/restore-volumes.sh <timestamp>"
echo ""
echo "📝 Next steps:"
echo "1. Check deployment status: nomad job status ghost-cms"
echo "2. View logs: nomad alloc logs -f <alloc-id>"
echo "3. Complete Ghost setup at https://cybermonkey.net.au/ghost"
echo "4. Set up regular backups with cron"
#!/bin/bash
# Deploy Ghost CMS with SQLite to Nomad
# Simplified deployment without PostgreSQL, using SQLite and Mailcow

set -e

echo "🚀 Ghost CMS Deployment (SQLite + Mailcow)"
echo "=========================================="

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ .env file not found!"
    echo "Creating from Mailcow template..."
    cp .env.mailcow .env
    echo "⚠️  Please edit .env with your Mailcow SMTP settings and run again"
    exit 1
fi

# Load environment variables
source .env

# Check required mail variables
if [ -z "$MAIL_HOST" ] || [ "$MAIL_HOST" = "mail.yourdomain.com" ]; then
    echo "❌ MAIL_HOST not configured in .env file!"
    echo "Please set your Mailcow SMTP host"
    exit 1
fi

if [ -z "$MAIL_PASSWORD" ] || [ "$MAIL_PASSWORD" = "your_mailcow_password" ]; then
    echo "❌ MAIL_PASSWORD not set in .env file!"
    echo "Please set your Mailcow SMTP password"
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

# Setup volumes
VOLUME_BASE="/opt/nomad/volumes"
if [ ! -d "${VOLUME_BASE}/ghost-data" ]; then
    echo "🔧 Setting up Ghost data volume..."
    sudo mkdir -p "${VOLUME_BASE}/ghost-data"
    sudo chown -R 1000:1000 "${VOLUME_BASE}/ghost-data"
    sudo chmod -R 755 "${VOLUME_BASE}/ghost-data"
    echo "✅ Volume created at ${VOLUME_BASE}/ghost-data"
fi

# Store mail credentials in Consul
echo ""
echo "📦 Storing mail configuration in Consul..."
consul kv put ghost/mail/user "$MAIL_USER"
consul kv put ghost/mail/password "$MAIL_PASSWORD"

# Deploy the job
echo ""
echo "🔄 Deploying Ghost CMS..."
nomad job run nomad/ghost-sqlite.nomad

echo "⏳ Waiting for deployment..."
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
    echo "🔍 To view logs:"
    echo "   nomad alloc logs -f $ALLOC_ID ghost"
fi

echo ""
echo "✅ Deployment completed!"
echo ""
echo "🌐 Ghost is available at:"
echo "   http://localhost:8009 (direct access)"
echo "   https://cybermonkey.net.au (via Caddy reverse proxy)"
echo ""
echo "📧 Mail configuration:"
echo "   SMTP Host: $MAIL_HOST"
echo "   SMTP User: $MAIL_USER"
echo "   From Address: $MAIL_FROM"
echo ""
echo "💾 Data location: ${VOLUME_BASE}/ghost-data"
echo "   SQLite DB: ${VOLUME_BASE}/ghost-data/data/ghost.db"
echo ""
echo "📝 Next steps:"
echo "1. Access Ghost admin at http://localhost:8009/ghost"
echo "2. Complete the setup wizard"
echo "3. Configure your Caddy reverse proxy to forward to port 8009"
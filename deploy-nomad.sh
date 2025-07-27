#!/bin/bash
# Deploy Ghost CMS to Nomad

set -e

echo "🚀 Ghost CMS Nomad Deployment Script"
echo "===================================="

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

echo "📦 Setting up Consul KV store..."
# Store secrets in Consul
consul kv put ghost/db/password "$DB_PASSWORD"
consul kv put ghost/mail/user "${MAIL_USER:-postmaster@cybermonkey.net.au}"
consul kv put ghost/mail/password "${MAIL_PASSWORD:-changeme}"

echo "🔄 Deploying Ghost CMS to Nomad..."
nomad job run nomad/ghost-cms.nomad

echo "⏳ Waiting for deployment to stabilize..."
sleep 10

# Get job status
echo "📊 Job Status:"
nomad job status ghost-cms

# Get allocation ID
ALLOC_ID=$(nomad job status ghost-cms | grep -A2 "Allocations" | tail -1 | awk '{print $1}')

if [ ! -z "$ALLOC_ID" ]; then
    echo "📋 Allocation ID: $ALLOC_ID"
    echo ""
    echo "🔍 To view logs, run:"
    echo "   nomad alloc logs -f $ALLOC_ID ghost"
    echo "   nomad alloc logs -f $ALLOC_ID postgres"
else
    echo "⚠️  Could not determine allocation ID"
fi

echo ""
echo "✅ Deployment initiated!"
echo ""
echo "🌐 Ghost will be available at:"
echo "   Frontend: https://cybermonkey.net.au"
echo "   Admin: https://cybermonkey.net.au/ghost"
echo ""
echo "📝 Next steps:"
echo "1. Check deployment status: nomad job status ghost-cms"
echo "2. View logs: nomad alloc logs -f <alloc-id>"
echo "3. Complete Ghost setup at https://cybermonkey.net.au/ghost"
#!/bin/bash
# Simple Ghost deployment without Consul dependency

set -e

echo "🚀 Ghost CMS Simple Deployment (SQLite)"
echo "========================================"

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

# Check if Nomad is running
if ! nomad status > /dev/null 2>&1; then
    echo "❌ Nomad is not running or not accessible"
    echo "Start Nomad with: sudo nomad agent -dev"
    exit 1
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

# Create a modified job file with environment variables directly embedded
echo "📝 Creating job file with mail configuration..."
cat > /tmp/ghost-deploy.nomad <<EOF
job "ghost-cms" {
  datacenters = ["dc1"]
  type = "service"

  group "ghost" {
    count = 1

    volume "ghost-data" {
      type = "host"
      source = "ghost-data"
      read_only = false
    }

    network {
      port "web" {
        static = 8009
        to = 2368
      }
    }

    service {
      name = "ghost-cms"
      port = "web"

      check {
        type     = "http"
        path     = "/ghost/api/admin/site/"
        interval = "30s"
        timeout  = "5s"
      }
    }

    task "ghost" {
      driver = "docker"

      config {
        image = "ghost:5-alpine"
        ports = ["web"]
      }

      volume_mount {
        volume = "ghost-data"
        destination = "/var/lib/ghost/content"
      }

      env {
        NODE_ENV = "production"
        database__client = "sqlite3"
        database__connection__filename = "/var/lib/ghost/content/data/ghost.db"
        database__useNullAsDefault = "true"
        database__debug = "false"
        url = "${GHOST_URL:-https://cybermonkey.net.au}"
        
        # Mail configuration
        mail__transport = "SMTP"
        mail__options__host = "${MAIL_HOST}"
        mail__options__port = "${MAIL_PORT}"
        mail__options__secure = "${MAIL_SECURE}"
        mail__options__auth__user = "${MAIL_USER}"
        mail__options__auth__pass = "${MAIL_PASSWORD}"
        mail__from = "${MAIL_FROM}"
      }

      resources {
        cpu    = 500
        memory = 512
      }
    }
  }
}
EOF

# Deploy the job
echo ""
echo "🔄 Deploying Ghost CMS..."
nomad job run /tmp/ghost-deploy.nomad

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
echo "   http://$(hostname):8009 (direct access)"
echo "   https://cybermonkey.net.au (via Caddy reverse proxy)"
echo ""
echo "📧 Mail configuration:"
echo "   SMTP Host: $MAIL_HOST"
echo "   SMTP User: $MAIL_USER"
echo "   From Address: $MAIL_FROM"
echo ""
echo "💾 Data location: ${VOLUME_BASE}/ghost-data"
echo ""
echo "📝 Next steps:"
echo "1. Access Ghost admin at http://$(hostname):8009/ghost"
echo "2. Complete the setup wizard"
echo "3. Configure your Caddy reverse proxy to forward to port 8009"
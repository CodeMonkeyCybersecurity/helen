job "ghost-theme-update" {
  datacenters = ["dc1"]
  type        = "batch"

  parameterized {
    payload       = "required"
    meta_required = ["environment", "theme_url"]
  }

  group "deploy" {
    task "update-theme" {
      driver = "exec"

      config {
        command = "/bin/bash"
        args    = ["-c", <<EOF
#!/bin/bash
set -e

# Extract parameters
ENVIRONMENT="${NOMAD_META_environment}"
THEME_URL="${NOMAD_META_theme_url}"
GHOST_CONTAINER="${NOMAD_META_ghost_container:-ghost}"

echo "🚀 Deploying Ghost theme to $ENVIRONMENT"

# Download theme
echo "📥 Downloading theme from $THEME_URL"
curl -L "$THEME_URL" -o /tmp/theme.zip

# Copy theme to Ghost container
echo "📤 Copying theme to Ghost container"
docker cp /tmp/theme.zip "$GHOST_CONTAINER":/tmp/

# Extract theme in Ghost container
echo "📦 Installing theme"
docker exec "$GHOST_CONTAINER" bash -c "
  cd /var/lib/ghost/content/themes/
  unzip -o /tmp/theme.zip
  rm /tmp/theme.zip
  # Set proper permissions
  chown -R node:node cybermonkey-ghost-theme/
"

# Restart Ghost to pick up theme changes
echo "🔄 Restarting Ghost"
docker restart "$GHOST_CONTAINER"

echo "✅ Theme deployment complete!"
EOF
        ]
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}
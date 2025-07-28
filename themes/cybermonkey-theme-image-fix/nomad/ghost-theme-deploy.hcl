variable "theme_version" {
  type        = string
  description = "Version of the theme to deploy"
}

variable "environment" {
  type        = string
  description = "Deployment environment (staging/production)"
}

variable "ghost_url" {
  type        = string
  description = "URL of the Ghost instance"
}

job "ghost-theme-deploy-${var.environment}" {
  datacenters = ["dc1"]
  type        = "batch"

  meta {
    theme_version = var.theme_version
    environment   = var.environment
  }

  group "deploy" {
    task "upload-theme" {
      driver = "docker"

      config {
        image = "ghost:5-alpine"
        command = "/bin/sh"
        args = ["-c", <<EOF
set -e

echo "🚀 Deploying Ghost theme v${var.theme_version} to ${var.environment}"

# Install required tools
apk add --no-cache curl jq

# Get Ghost Admin API key from Vault or environment
GHOST_ADMIN_KEY="${GHOST_ADMIN_KEY}"

# Upload theme via Ghost Admin API
echo "📤 Uploading theme..."
RESPONSE=$(curl -X POST \
  "${var.ghost_url}/ghost/api/admin/themes/upload/" \
  -H "Authorization: Ghost ${GHOST_ADMIN_KEY}" \
  -F "file=@/local/cybermonkey-ghost-theme.zip" \
  -s)

# Check if upload was successful
if echo "$RESPONSE" | jq -e '.themes' > /dev/null; then
  THEME_NAME=$(echo "$RESPONSE" | jq -r '.themes[0].name')
  echo "✅ Theme uploaded successfully: $THEME_NAME"
  
  # Activate the theme
  echo "🎨 Activating theme..."
  ACTIVATE_RESPONSE=$(curl -X PUT \
    "${var.ghost_url}/ghost/api/admin/themes/${THEME_NAME}/activate/" \
    -H "Authorization: Ghost ${GHOST_ADMIN_KEY}" \
    -H "Content-Type: application/json" \
    -s)
  
  if echo "$ACTIVATE_RESPONSE" | jq -e '.themes' > /dev/null; then
    echo "✅ Theme activated successfully!"
  else
    echo "❌ Failed to activate theme"
    echo "$ACTIVATE_RESPONSE"
    exit 1
  fi
else
  echo "❌ Failed to upload theme"
  echo "$RESPONSE"
  exit 1
fi

echo "🎉 Deployment complete!"
EOF
        ]
        
        # Mount the theme file
        volumes = [
          "/tmp/cybermonkey-ghost-theme.zip:/local/cybermonkey-ghost-theme.zip"
        ]
      }

      # Copy theme artifact from CI/CD
      artifact {
        source = "https://github.com/${GITHUB_REPOSITORY}/releases/download/v${var.theme_version}/cybermonkey-ghost-theme.zip"
        destination = "/tmp/cybermonkey-ghost-theme.zip"
      }

      template {
        data = <<EOH
GHOST_ADMIN_KEY="{{ with secret "kv/ghost/${var.environment}/admin" }}{{ .Data.data.api_key }}{{ end }}"
EOH
        destination = "secrets/env"
        env         = true
      }

      resources {
        cpu    = 100
        memory = 256
      }
    }
  }
}
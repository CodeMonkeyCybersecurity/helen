#!/bin/bash
# generateDevCert.sh

sudo apt update
sudo apt install certbot python3-certbot-nginx

# Define domain and email
DOMAIN="chickenj0.cloud"
EMAIL="main@cybermonkey.dev" # Replace with your email
NGINX_CONF_PATH="/etc/nginx/conf.d"

# Check if Certbot is installed
if ! command -v certbot &> /dev/null; then
  echo "Certbot is not installed. Please install it first."
  exit 1
fi

# Generate SSL certificates using Certbot
echo "Generating SSL certificate for $DOMAIN..."
sudo certbot --nginx \
  -d "$DOMAIN" \
  --non-interactive \
  --agree-tos \
  --email "$EMAIL" \
  --redirect

# Reload NGINX to apply the new configuration
echo "Reloading NGINX..."
sudo systemctl reload nginx

# Check if the process was successful
if [ $? -eq 0 ]; then
  echo "SSL certificate successfully generated for $DOMAIN!"
else
  echo "An error occurred while generating the SSL certificate."
  exit 1
fi

echo "Now run 'docker compose up -d'"
echo ""
echo "finis"
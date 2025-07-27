#!/bin/bash
# Install Consul on Ubuntu/Debian

set -e

echo "📦 Installing Consul..."

# Detect architecture
ARCH=$(uname -m)
case $ARCH in
    x86_64) CONSUL_ARCH="amd64" ;;
    aarch64) CONSUL_ARCH="arm64" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Download Consul
CONSUL_VERSION="1.17.1"
CONSUL_URL="https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_${CONSUL_ARCH}.zip"

echo "Downloading Consul ${CONSUL_VERSION} for ${CONSUL_ARCH}..."
wget -q -O /tmp/consul.zip "$CONSUL_URL"

# Install Consul
echo "Installing Consul..."
sudo unzip -o /tmp/consul.zip -d /usr/local/bin/
sudo chmod +x /usr/local/bin/consul

# Cleanup
rm /tmp/consul.zip

# Verify installation
if consul --version; then
    echo "✅ Consul installed successfully!"
else
    echo "❌ Consul installation failed"
    exit 1
fi
#!/bin/bash

# Vault setup script for Code Monkey Cybersecurity
# This script initializes Vault with necessary secrets and policies

set -e

# Configuration
VAULT_ADDR=${VAULT_ADDR:-"https://vault.cybermonkey.net.au"}
VAULT_TOKEN=${VAULT_TOKEN:-""}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if Vault is accessible
check_vault() {
    log "Checking Vault accessibility..."
    vault status > /dev/null 2>&1 || error "Cannot connect to Vault at $VAULT_ADDR"
    log "Vault is accessible"
}

# Enable secrets engines
enable_secrets_engines() {
    log "Enabling secrets engines..."
    
    # Enable KV v2 for application secrets
    vault secrets enable -path=secret kv-v2 || warn "Secret engine already enabled"
    
    # Enable PKI for certificate management
    vault secrets enable -path=pki pki || warn "PKI engine already enabled"
    vault secrets tune -max-lease-ttl=87600h pki || warn "PKI tune failed"
    
    # Enable database secrets engine
    vault secrets enable database || warn "Database engine already enabled"
    
    log "Secrets engines enabled"
}

# Create policies
create_policies() {
    log "Creating Vault policies..."
    
    # Website production policy
    vault policy write cybermonkey-website-production - <<EOF
path "secret/data/ssl/cybermonkey.net.au" {
  capabilities = ["read"]
}

path "secret/data/website/production/*" {
  capabilities = ["read"]
}

path "secret/data/shared/*" {
  capabilities = ["read"]
}

path "database/creds/website-production" {
  capabilities = ["read"]
}

path "auth/token/lookup-self" {
  capabilities = ["read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "auth/token/revoke-self" {
  capabilities = ["update"]
}
EOF

    # Website staging policy
    vault policy write cybermonkey-website-staging - <<EOF
path "secret/data/ssl/staging.cybermonkey.net.au" {
  capabilities = ["read"]
}

path "secret/data/website/staging/*" {
  capabilities = ["read"]
}

path "secret/data/shared/*" {
  capabilities = ["read"]
}

path "database/creds/website-staging" {
  capabilities = ["read"]
}

path "auth/token/lookup-self" {
  capabilities = ["read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "auth/token/revoke-self" {
  capabilities = ["update"]
}
EOF

    # Monitoring policy
    vault policy write monitoring - <<EOF
path "secret/data/monitoring/*" {
  capabilities = ["read"]
}

path "secret/data/shared/*" {
  capabilities = ["read"]
}

path "auth/token/lookup-self" {
  capabilities = ["read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}
EOF

    log "Policies created"
}

# Setup PKI for SSL certificates
setup_pki() {
    log "Setting up PKI for SSL certificates..."
    
    # Generate root CA
    vault write pki/root/generate/internal \
        common_name="Code Monkey Cybersecurity Root CA" \
        ttl=87600h || warn "Root CA already generated"
    
    # Configure CA and CRL URLs
    vault write pki/config/urls \
        issuing_certificates="$VAULT_ADDR/v1/pki/ca" \
        crl_distribution_points="$VAULT_ADDR/v1/pki/crl"
    
    # Create role for website certificates
    vault write pki/roles/cybermonkey-website \
        allowed_domains="cybermonkey.net.au,staging.cybermonkey.net.au" \
        allow_subdomains=true \
        max_ttl=72h
    
    log "PKI configured"
}

# Store application secrets
store_secrets() {
    log "Storing application secrets..."
    
    # Generate random passwords if not provided
    GRAFANA_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD:-$(openssl rand -base64 32)}
    GRAFANA_SECRET_KEY=${GRAFANA_SECRET_KEY:-$(openssl rand -base64 32)}
    
    # Store SSL certificates (these would be real certificates in production)
    vault kv put secret/ssl/cybermonkey.net.au \
        certificate="$(cat /dev/null)" \
        private_key="$(cat /dev/null)" \
        || warn "SSL certificate already stored"
    
    vault kv put secret/ssl/staging.cybermonkey.net.au \
        certificate="$(cat /dev/null)" \
        private_key="$(cat /dev/null)" \
        || warn "Staging SSL certificate already stored"
    
    # Store monitoring secrets
    vault kv put secret/monitoring/grafana \
        admin_password="$GRAFANA_ADMIN_PASSWORD" \
        secret_key="$GRAFANA_SECRET_KEY"
    
    vault kv put secret/monitoring/alertmanager \
        smtp_username="alerts@cybermonkey.net.au" \
        smtp_password="changeme" \
        slack_webhook="https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
    
    # Store shared secrets
    vault kv put secret/shared/encryption \
        key="$(openssl rand -base64 32)"
    
    log "Secrets stored"
}

# Enable auth methods
enable_auth_methods() {
    log "Enabling auth methods..."
    
    # Enable AppRole for service authentication
    vault auth enable approle || warn "AppRole already enabled"
    
    # Create AppRole for website production
    vault write auth/approle/role/cybermonkey-website-production \
        token_policies="cybermonkey-website-production" \
        token_ttl=1h \
        token_max_ttl=4h
    
    # Create AppRole for website staging
    vault write auth/approle/role/cybermonkey-website-staging \
        token_policies="cybermonkey-website-staging" \
        token_ttl=1h \
        token_max_ttl=4h
    
    # Create AppRole for monitoring
    vault write auth/approle/role/monitoring \
        token_policies="monitoring" \
        token_ttl=1h \
        token_max_ttl=4h
    
    log "Auth methods enabled"
}

# Generate application credentials
generate_app_credentials() {
    log "Generating application credentials..."
    
    # Get role IDs and secret IDs
    WEBSITE_PROD_ROLE_ID=$(vault read -field=role_id auth/approle/role/cybermonkey-website-production/role-id)
    WEBSITE_PROD_SECRET_ID=$(vault write -field=secret_id -f auth/approle/role/cybermonkey-website-production/secret-id)
    
    WEBSITE_STAGING_ROLE_ID=$(vault read -field=role_id auth/approle/role/cybermonkey-website-staging/role-id)
    WEBSITE_STAGING_SECRET_ID=$(vault write -field=secret_id -f auth/approle/role/cybermonkey-website-staging/secret-id)
    
    MONITORING_ROLE_ID=$(vault read -field=role_id auth/approle/role/monitoring/role-id)
    MONITORING_SECRET_ID=$(vault write -field=secret_id -f auth/approle/role/monitoring/secret-id)
    
    # Output credentials (these should be stored securely)
    echo "Application Credentials:"
    echo "========================"
    echo "Website Production:"
    echo "  Role ID: $WEBSITE_PROD_ROLE_ID"
    echo "  Secret ID: $WEBSITE_PROD_SECRET_ID"
    echo ""
    echo "Website Staging:"
    echo "  Role ID: $WEBSITE_STAGING_ROLE_ID"
    echo "  Secret ID: $WEBSITE_STAGING_SECRET_ID"
    echo ""
    echo "Monitoring:"
    echo "  Role ID: $MONITORING_ROLE_ID"
    echo "  Secret ID: $MONITORING_SECRET_ID"
    echo ""
    echo "IMPORTANT: Store these credentials securely and use them in your deployment configurations."
    
    log "Application credentials generated"
}

# Audit logging
enable_audit() {
    log "Enabling audit logging..."
    
    vault audit enable file file_path=/vault/logs/audit.log || warn "Audit already enabled"
    
    log "Audit logging enabled"
}

# Main execution
main() {
    log "Starting Vault setup for Code Monkey Cybersecurity..."
    
    check_vault
    enable_secrets_engines
    create_policies
    setup_pki
    store_secrets
    enable_auth_methods
    generate_app_credentials
    enable_audit
    
    log "Vault setup completed successfully!"
    log "Remember to:"
    log "1. Store the application credentials securely"
    log "2. Update your deployment configurations with the credentials"
    log "3. Replace placeholder SSL certificates with real ones"
    log "4. Update monitoring webhook URLs"
}

# Run main function
main "$@"
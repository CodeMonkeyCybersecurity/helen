# Deployment Guide: Code Monkey Cybersecurity Website

## Overview

This guide provides comprehensive instructions for deploying the Code Monkey Cybersecurity website using modern CI/CD practices with GitHub Actions, Terraform, and Nomad orchestration.

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Actions │    │   Terraform     │    │   Nomad Cluster │
│   CI/CD Pipeline │───▶│   Infrastructure│───▶│   Orchestration │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Security      │    │   Multi-Cloud   │    │   Monitoring    │
│   Scanning      │    │   Support       │    │   & Alerting    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Prerequisites

### Required Tools

**Terraform** >= 1.6.0
**Nomad** >= 1.6.0
**Consul** >= 1.16.0
**Vault** >= 1.14.0
**Docker** >= 24.0.0
**AWS CLI** >= 2.0.0
**Git** >= 2.30.0

### Required Accounts and Access

**AWS Account** with appropriate permissions
**GitHub Account** with repository access
**Container Registry** (AWS ECR, Docker Hub, etc.)
**Domain Name** management access

### Environment Variables

```bash
# AWS Configuration
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="ap-southeast-2"

# Terraform State
export TF_VAR_terraform_state_bucket="cybermonkey-terraform-state"
export TF_VAR_terraform_state_region="ap-southeast-2"

# Container Registry
export CONTAINER_REGISTRY="your-registry.com"
export CONTAINER_REGISTRY_USER="username"
export CONTAINER_REGISTRY_PASSWORD="password"

# HashiCorp Stack
export CONSUL_HTTP_ADDR="https://consul.cybermonkey.net.au"
export NOMAD_ADDR="https://nomad.cybermonkey.net.au"
export VAULT_ADDR="https://vault.cybermonkey.net.au"
```

## Initial Setup

### 1. Infrastructure Preparation

#### Create S3 Bucket for Terraform State

```bash
# Create S3 bucket for Terraform state
aws s3 mb s3://cybermonkey-terraform-state --region ap-southeast-2

# Enable versioning
aws s3api put-bucket-versioning \
    --bucket cybermonkey-terraform-state \
    --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
    --table-name cybermonkey-terraform-locks \
    --attribute-definitions \
        AttributeName=LockID,AttributeType=S \
    --key-schema \
        AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput \
        ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region ap-southeast-2
```

#### Set up DNS

```bash
# Create Route53 hosted zone
aws route53 create-hosted-zone \
    --name cybermonkey.net.au \
    --caller-reference $(date +%s)

# Note the name servers and update your domain registrar
```

### 2. GitHub Repository Setup

#### Required Secrets

Configure these secrets in your GitHub repository:

```bash
# AWS Credentials
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY

# Container Registry
CONTAINER_REGISTRY
CONTAINER_REGISTRY_USER
CONTAINER_REGISTRY_PASSWORD

# HashiCorp Stack
CONSUL_HTTP_ADDR
CONSUL_TOKEN
NOMAD_ADDR
NOMAD_TOKEN
VAULT_ADDR
VAULT_TOKEN

# Monitoring
LHCI_GITHUB_APP_TOKEN
SEMGREP_APP_TOKEN
FOSSA_API_KEY
MONITORING_API_KEY
MONITORING_WEBHOOK_URL
BACKUP_API_KEY
BACKUP_WEBHOOK_URL

# Notifications
SLACK_WEBHOOK
```

#### GitHub Actions Environments

Create two environments in GitHub:
- `staging`
- `production`

Configure environment-specific protection rules and secrets as needed.

### 3. Infrastructure Deployment

#### Deploy Staging Environment

```bash
# Navigate to Terraform directory
cd deploy/terraform

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -var-file="../environments/staging.tfvars"

# Apply deployment
terraform apply -var-file="../environments/staging.tfvars"
```

#### Deploy Production Environment

```bash
# Plan production deployment
terraform plan -var-file="../environments/production.tfvars"

# Apply production deployment
terraform apply -var-file="../environments/production.tfvars"
```

### 4. HashiCorp Stack Configuration

#### Initialize Vault

```bash
# Make setup script executable
chmod +x deploy/vault/setup-vault.sh

# Run Vault setup
./deploy/vault/setup-vault.sh

# Store the root token and unseal keys securely
```

#### Configure Consul

```bash
# Bootstrap Consul ACL system
consul acl bootstrap

# Create tokens for services
consul acl token create -description "Nomad Agent Token" -policy-name "nomad-agent"
consul acl token create -description "Website Service Token" -policy-name "website-service"
```

#### Configure Nomad

```bash
# Bootstrap Nomad ACL system
nomad acl bootstrap

# Create tokens for deployments
nomad acl token create -name "deployment-token" -policy deployment
```

## Deployment Process

### Automated Deployment (Recommended)

The deployment is fully automated through GitHub Actions. Simply push to the appropriate branch:

```bash
# Deploy to staging
git push origin develop

# Deploy to production
git push origin main
```

### Manual Deployment

For manual deployments or troubleshooting:

#### Build Container Image

```bash
# Build the container image
docker build -t cybermonkey/website:latest -f deploy/Dockerfile .

# Push to registry
docker push cybermonkey/website:latest
```

#### Deploy to Nomad

```bash
# Deploy staging
nomad job run deploy/nomad/website-staging.nomad

# Deploy production
nomad job run deploy/nomad/website-production.nomad
```

#### Deploy Monitoring Stack

```bash
# Deploy monitoring
nomad job run deploy/nomad/monitoring-stack.nomad
```

## Configuration Management

### Environment-Specific Settings

#### Staging Configuration

Located in `deploy/environments/staging.tfvars`:

```hcl
# Smaller instance sizes for cost optimization
nomad_instance_type = "t3.small"
nomad_server_count = 1
nomad_client_count = 2

# Relaxed security for development
enable_waf = false
enable_ddos_protection = false

# Shorter retention periods
backup_retention_days = 7
monitoring_retention_days = 7
```

#### Production Configuration

Located in `deploy/environments/production.tfvars`:

```hcl
# Production-ready instance sizes
nomad_instance_type = "t3.medium"
nomad_server_count = 3
nomad_client_count = 3

# Full security enabled
enable_waf = true
enable_ddos_protection = true

# Standard retention periods
backup_retention_days = 30
monitoring_retention_days = 30
```

### Secrets Management

All secrets are managed through HashiCorp Vault:

#### SSL Certificates

```bash
# Store SSL certificates
vault kv put secret/ssl/cybermonkey.net.au \
    certificate=@/path/to/cert.pem \
    private_key=@/path/to/key.pem

vault kv put secret/ssl/staging.cybermonkey.net.au \
    certificate=@/path/to/staging-cert.pem \
    private_key=@/path/to/staging-key.pem
```

#### Application Secrets

```bash
# Database credentials
vault kv put secret/database/website-production \
    username=website_user \
    password=secure_password

# API keys
vault kv put secret/api/external-services \
    analytics_key=your_analytics_key \
    monitoring_key=your_monitoring_key
```

## Monitoring and Observability

### Monitoring Stack Components

**Prometheus**: Metrics collection and storage
**Grafana**: Visualization and dashboards
**Alertmanager**: Alert routing and notifications
**Blackbox Exporter**: Uptime monitoring

### Key Metrics

**Website Availability**: 99.9% uptime target
**Response Time**: < 200ms for 95th percentile
**Error Rate**: < 0.1% of requests
**SSL Certificate**: 30-day expiry warnings

### Alerting Rules

Configured in `deploy/nomad/monitoring-stack.nomad`:

```yaml
# Website down alert
- alert: WebsiteDown
  expr: up{job="website"} == 0
  for: 1m
  labels:
    severity: critical

# High error rate alert
- alert: HighErrorRate
  expr: rate(nginx_http_requests_total{status=~"5.."}[5m]) > 0.1
  for: 5m
  labels:
    severity: warning
```

### Grafana Dashboards

Access Grafana at `https://grafana.cybermonkey.net.au`

Pre-configured dashboards:
- Website Performance
- Infrastructure Overview
- Nomad Cluster Status
- Security Metrics

## Security Considerations

### Container Security

**Base Image**: Alpine Linux for minimal attack surface
**Non-root User**: Containers run as nginx user
**Security Scanning**: Trivy scans for vulnerabilities
**Regular Updates**: Automated dependency updates

### Network Security

**VPC Isolation**: Private subnets for application tiers
**Security Groups**: Restrictive firewall rules
**WAF**: Web Application Firewall for production
**DDoS Protection**: AWS Shield integration

### Secrets Management

**Vault Integration**: All secrets stored in Vault
**Rotation**: Automatic secret rotation
**Encryption**: Data encrypted at rest and in transit
**Access Control**: Role-based access policies

### Compliance

**GDPR**: Data protection measures implemented
**Australian Privacy**: Local data sovereignty
**Security Headers**: Comprehensive HTTP security headers
**Audit Logging**: Complete audit trail

## Troubleshooting

### Common Issues

#### Deployment Failures

```bash
# Check Nomad job status
nomad job status cybermonkey-website-production

# View job logs
nomad alloc logs <allocation-id>

# Check service health
consul catalog services
```

#### SSL Certificate Issues

```bash
# Check certificate in Vault
vault kv get secret/ssl/cybermonkey.net.au

# Verify certificate validity
openssl x509 -in cert.pem -text -noout
```

#### Monitoring Issues

```bash
# Check Prometheus targets
curl https://prometheus.cybermonkey.net.au/api/v1/targets

# Check Grafana logs
nomad alloc logs -f <grafana-allocation-id>
```

### Log Aggregation

Logs are centralized using Fluent Bit:

```bash
# View application logs
aws logs tail /nomad/cybermonkey-website-production --follow

# View infrastructure logs
aws logs tail /aws/nomad/australia --follow
```

### Performance Debugging

```bash
# Check website performance
curl -w "@curl-format.txt" -o /dev/null -s https://cybermonkey.net.au

# Run Lighthouse audit
lighthouse https://cybermonkey.net.au --output json
```

## Backup and Recovery

### Backup Strategy

**Infrastructure State**: Terraform state backed up to S3
**Vault Data**: Encrypted snapshots to S3
**Consul Data**: Periodic snapshots
**Application Data**: Static site regeneration

### Recovery Procedures

#### Infrastructure Recovery

```bash
# Restore from Terraform state
terraform import aws_instance.example i-1234567890abcdef0

# Rebuild infrastructure
terraform apply -var-file="environments/production.tfvars"
```

#### Service Recovery

```bash
# Redeploy services
nomad job run deploy/nomad/website-production.nomad
nomad job run deploy/nomad/monitoring-stack.nomad
```

### Disaster Recovery Testing

Regular DR tests are automated:

```bash
# Run DR test
./scripts/disaster-recovery-test.sh

# Verify recovery
./scripts/verify-recovery.sh
```

## Scaling and Optimization

### Horizontal Scaling

Nomad automatically scales based on demand:

```hcl
# Auto-scaling configuration
scaling {
  enabled = true
  min     = 2
  max     = 10
  
  policy {
    cooldown            = "5m"
    evaluation_interval = "1m"
    
    check "cpu_usage" {
      source = "prometheus"
      query  = "avg(cpu_usage)"
      
      strategy "target-value" {
        target = 70
      }
    }
  }
}
```

### Cost Optimization

**Spot Instances**: Used for non-critical workloads
**Right-sizing**: Regular instance size optimization
**Reserved Instances**: For predictable workloads
**Resource Monitoring**: Continuous optimization

## Maintenance

### Regular Tasks

#### Weekly
- Review monitoring dashboards
- Check for security updates
- Verify backup integrity
- Update SSL certificates if needed

#### Monthly
- Review and update dependencies
- Perform security scans
- Optimize resource allocation
- Review and update documentation

#### Quarterly
- Disaster recovery testing
- Security Development/Code Auditing
- Performance optimization review
- Infrastructure cost review

### Update Procedures

#### Security Updates

```bash
# Update base images
docker pull nginx:latest-alpine
docker pull prometheus/prometheus:latest

# Rebuild and deploy
docker build -t cybermonkey/website:latest .
nomad job run deploy/nomad/website-production.nomad
```

#### Application Updates

Updates are automatically deployed through GitHub Actions when code is pushed to the main branch.

## Support and Troubleshooting

### Getting Help

**Documentation**: Check this deployment guide
**Logs**: Review application and infrastructure logs
**Monitoring**: Check Grafana dashboards
**Status Page**: Monitor system status

### Emergency Procedures

#### Critical Issues

1. **Check monitoring alerts**
2. **Review recent deployments**
3. **Check system health**
4. **Implement rollback if necessary**

#### Rollback Procedures

```bash
# Rollback to previous version
nomad job revert cybermonkey-website-production <version>

# Verify rollback
curl -I https://cybermonkey.net.au
```

### Performance Tuning

#### Database Optimization

```bash
# Monitor database performance
nomad alloc logs -f <db-allocation-id>

# Optimize queries
EXPLAIN ANALYZE SELECT * FROM table;
```

#### Application Performance

```bash
# Profile application
go tool pprof http://localhost:6060/debug/pprof/profile

# Optimize static assets
npm run build --analyze
```

## Conclusion

This deployment guide provides a comprehensive foundation for deploying and managing the Code Monkey Cybersecurity website. The infrastructure is designed to be:

**Scalable**: Automatically handles traffic increases
**Secure**: Implements security best practices
**Reliable**: Provides high availability and disaster recovery
**Observable**: Comprehensive monitoring and alerting
**Maintainable**: Clear documentation and automation

For additional support or questions, contact the DevOps team at devops@cybermonkey.net.au.

---

*This deployment guide is a living document. Please update it as the infrastructure evolves and new procedures are implemented.*
# Production environment configuration

# Environment settings
environment = "production"
domain_name = "cybermonkey.net.au"

# AWS Configuration
aws_region = "ap-southeast-2"
vpc_cidr = "10.0.0.0/16"
private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

# Instance configuration (production-ready)
nomad_server_count = 3
nomad_client_count = 3
nomad_instance_type = "t3.medium"

consul_server_count = 3
consul_instance_type = "t3.small"

vault_server_count = 3
vault_instance_type = "t3.small"

# Cost optimization for production
enable_spot_instances = false
auto_scaling_enabled = true
min_capacity = 3
max_capacity = 10
target_cpu_utilization = 70

# Security settings (strict for production)
enable_waf = true
enable_ddos_protection = true
allowed_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]

# Monitoring configuration
enable_monitoring = true
monitoring_retention_days = 30

# Backup configuration
backup_retention_days = 30
enable_cross_region_backup = true

# Multi-cloud settings
enable_gcp = false
enable_azure = false

# SSL/TLS configuration
enable_ssl_redirect = true
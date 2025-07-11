# Staging environment configuration

# Environment settings
environment = "staging"
domain_name = "staging.cybermonkey.net.au"

# AWS Configuration
aws_region = "ap-southeast-2"
vpc_cidr = "10.1.0.0/16"
private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
public_subnets = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]

# Instance configuration (smaller for staging)
nomad_server_count = 1
nomad_client_count = 2
nomad_instance_type = "t3.small"

consul_server_count = 1
consul_instance_type = "t3.micro"

vault_server_count = 1
vault_instance_type = "t3.micro"

# Cost optimization for staging
enable_spot_instances = true
auto_scaling_enabled = true
min_capacity = 1
max_capacity = 5
target_cpu_utilization = 80

# Security settings (relaxed for staging)
enable_waf = false
enable_ddos_protection = false
allowed_cidr_blocks = ["0.0.0.0/0"]

# Monitoring configuration
enable_monitoring = true
monitoring_retention_days = 7

# Backup configuration
backup_retention_days = 7
enable_cross_region_backup = false

# Multi-cloud settings
enable_gcp = false
enable_azure = false

# SSL/TLS configuration
enable_ssl_redirect = true
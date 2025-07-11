# Network outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.network.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.network.public_subnet_ids
}

# Load balancer outputs
output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.load_balancer.dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = module.load_balancer.zone_id
}

output "website_url" {
  description = "URL of the website"
  value       = var.environment == "production" ? "https://${var.domain_name}" : "https://${var.environment}.${var.domain_name}"
}

# Nomad cluster outputs
output "nomad_server_ips" {
  description = "IP addresses of Nomad servers"
  value       = module.nomad_cluster.server_ips
}

output "nomad_client_ips" {
  description = "IP addresses of Nomad clients"
  value       = module.nomad_cluster.client_ips
}

output "nomad_ui_url" {
  description = "URL of the Nomad UI"
  value       = "https://nomad.${var.domain_name}"
}

# Consul cluster outputs
output "consul_server_ips" {
  description = "IP addresses of Consul servers"
  value       = module.consul_cluster.server_ips
}

output "consul_ui_url" {
  description = "URL of the Consul UI"
  value       = "https://consul.${var.domain_name}"
}

# Vault cluster outputs
output "vault_server_ips" {
  description = "IP addresses of Vault servers"
  value       = module.vault_cluster.server_ips
}

output "vault_ui_url" {
  description = "URL of the Vault UI"
  value       = "https://vault.${var.domain_name}"
}

# Security outputs
output "security_group_ids" {
  description = "Security group IDs"
  value = {
    nomad  = module.security.nomad_security_group_ids
    consul = module.security.consul_security_group_ids
    vault  = module.security.vault_security_group_ids
  }
}

# Monitoring outputs
output "monitoring_dashboard_url" {
  description = "URL of the monitoring dashboard"
  value       = module.monitoring.dashboard_url
}

output "grafana_url" {
  description = "URL of Grafana"
  value       = module.monitoring.grafana_url
}

output "prometheus_url" {
  description = "URL of Prometheus"
  value       = module.monitoring.prometheus_url
}

# Backup outputs
output "backup_bucket_name" {
  description = "Name of the backup S3 bucket"
  value       = module.backup.bucket_name
}

output "backup_vault_name" {
  description = "Name of the backup vault"
  value       = module.backup.vault_name
}

# Certificate outputs
output "ssl_certificate_arn" {
  description = "ARN of the SSL certificate"
  value       = var.ssl_certificate_arn
}

# Multi-cloud outputs
output "gcp_resources" {
  description = "GCP resource information"
  value       = var.enable_gcp ? module.gcp_resources[0] : null
}

output "azure_resources" {
  description = "Azure resource information"
  value       = var.enable_azure ? module.azure_resources[0] : null
}

# Environment information
output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "deployment_time" {
  description = "Deployment timestamp"
  value       = timestamp()
}

# Connection information
output "connection_info" {
  description = "Connection information for services"
  value = {
    nomad = {
      address = var.nomad_address
      ui_url  = "https://nomad.${var.domain_name}"
    }
    consul = {
      address = var.consul_address
      ui_url  = "https://consul.${var.domain_name}"
    }
    vault = {
      address = var.vault_address
      ui_url  = "https://vault.${var.domain_name}"
    }
    website = {
      url = var.environment == "production" ? "https://${var.domain_name}" : "https://${var.environment}.${var.domain_name}"
    }
  }
  sensitive = false
}

# Cost optimization outputs
output "cost_optimization_info" {
  description = "Cost optimization information"
  value = {
    spot_instances_enabled = var.enable_spot_instances
    auto_scaling_enabled   = var.auto_scaling_enabled
    min_capacity          = var.min_capacity
    max_capacity          = var.max_capacity
  }
}

# Security information
output "security_info" {
  description = "Security configuration information"
  value = {
    waf_enabled         = var.enable_waf
    ddos_protection     = var.enable_ddos_protection
    ssl_redirect        = var.enable_ssl_redirect
    monitoring_enabled  = var.enable_monitoring
  }
  sensitive = false
}
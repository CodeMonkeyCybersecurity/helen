# Environment variables
variable "environment" {
  description = "Environment name (staging, production)"
  type        = string
  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "Environment must be either 'staging' or 'production'."
  }
}

variable "domain_name" {
  description = "Domain name for the website"
  type        = string
  default     = "cybermonkey.net.au"
}

variable "container_image" {
  description = "Container image for the website"
  type        = string
  default     = "cybermonkey/website:latest"
}

# AWS Configuration
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

# GCP Configuration
variable "enable_gcp" {
  description = "Enable GCP resources"
  type        = bool
  default     = false
}

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
  default     = ""
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "australia-southeast1"
}

# Azure Configuration
variable "enable_azure" {
  description = "Enable Azure resources"
  type        = bool
  default     = false
}

variable "azure_location" {
  description = "Azure location"
  type        = string
  default     = "Australia East"
}

# Nomad Configuration
variable "nomad_server_count" {
  description = "Number of Nomad servers"
  type        = number
  default     = 3
}

variable "nomad_client_count" {
  description = "Number of Nomad clients"
  type        = number
  default     = 3
}

variable "nomad_instance_type" {
  description = "Instance type for Nomad nodes"
  type        = string
  default     = "t3.medium"
}

variable "nomad_address" {
  description = "Nomad cluster address"
  type        = string
  default     = "https://nomad.cybermonkey.net.au"
}

variable "nomad_region" {
  description = "Nomad region"
  type        = string
  default     = "australia"
}

# Consul Configuration
variable "consul_server_count" {
  description = "Number of Consul servers"
  type        = number
  default     = 3
}

variable "consul_instance_type" {
  description = "Instance type for Consul nodes"
  type        = string
  default     = "t3.small"
}

variable "consul_address" {
  description = "Consul cluster address"
  type        = string
  default     = "https://consul.cybermonkey.net.au"
}

variable "consul_datacenter" {
  description = "Consul datacenter"
  type        = string
  default     = "australia"
}

variable "consul_token" {
  description = "Consul ACL token"
  type        = string
  sensitive   = true
  default     = ""
}

# Vault Configuration
variable "vault_server_count" {
  description = "Number of Vault servers"
  type        = number
  default     = 3
}

variable "vault_instance_type" {
  description = "Instance type for Vault nodes"
  type        = string
  default     = "t3.small"
}

variable "vault_address" {
  description = "Vault cluster address"
  type        = string
  default     = "https://vault.cybermonkey.net.au"
}

variable "vault_token" {
  description = "Vault root token"
  type        = string
  sensitive   = true
  default     = ""
}

# SSL/TLS Configuration
variable "ssl_certificate_arn" {
  description = "ARN of the SSL certificate"
  type        = string
  default     = ""
}

variable "enable_ssl_redirect" {
  description = "Enable HTTP to HTTPS redirect"
  type        = bool
  default     = true
}

# Monitoring Configuration
variable "enable_monitoring" {
  description = "Enable monitoring stack"
  type        = bool
  default     = true
}

variable "monitoring_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 30
}

variable "alert_email" {
  description = "Email address for alerts"
  type        = string
  default     = "devops@cybermonkey.net.au"
}

# Backup Configuration
variable "backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
  default     = 30
}

variable "enable_cross_region_backup" {
  description = "Enable cross-region backup"
  type        = bool
  default     = true
}

# Security Configuration
variable "enable_waf" {
  description = "Enable Web Application Firewall"
  type        = bool
  default     = true
}

variable "enable_ddos_protection" {
  description = "Enable DDoS protection"
  type        = bool
  default     = true
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access admin interfaces"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Cost optimization
variable "enable_spot_instances" {
  description = "Enable spot instances for cost optimization"
  type        = bool
  default     = false
}

variable "auto_scaling_enabled" {
  description = "Enable auto scaling"
  type        = bool
  default     = true
}

variable "min_capacity" {
  description = "Minimum capacity for auto scaling"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum capacity for auto scaling"
  type        = number
  default     = 10
}

variable "target_cpu_utilization" {
  description = "Target CPU utilization for auto scaling"
  type        = number
  default     = 70
}
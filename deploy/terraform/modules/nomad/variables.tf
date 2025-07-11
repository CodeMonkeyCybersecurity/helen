variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs"
  type        = list(string)
}

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

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t3.medium"
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "consul_address" {
  description = "Consul address"
  type        = string
  default     = "consul.service.consul:8500"
}

variable "vault_address" {
  description = "Vault address"
  type        = string
  default     = "vault.service.consul:8200"
}

variable "nomad_datacenter" {
  description = "Nomad datacenter"
  type        = string
  default     = "australia"
}

variable "nomad_encrypt_key" {
  description = "Nomad gossip encryption key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ssl_certificate_arn" {
  description = "SSL certificate ARN"
  type        = string
  default     = ""
}
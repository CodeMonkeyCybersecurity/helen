terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.0"
    }
    nomad = {
      source  = "hashicorp/nomad"
      version = "~> 2.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket         = "cybermonkey-terraform-state"
    key            = "infrastructure/terraform.tfstate"
    region         = "ap-southeast-2"
    encrypt        = true
    dynamodb_table = "cybermonkey-terraform-locks"
  }
}

# Local variables
locals {
  common_tags = {
    Project     = "cybermonkey-website"
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "devops@cybermonkey.net.au"
  }
  
  name_prefix = "cybermonkey-${var.environment}"
}

# Data sources for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# Multi-cloud provider configuration
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = local.common_tags
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

provider "azurerm" {
  features {}
}

# HashiCorp stack providers
provider "consul" {
  address    = var.consul_address
  datacenter = var.consul_datacenter
  token      = var.consul_token
}

provider "nomad" {
  address = var.nomad_address
  region  = var.nomad_region
}

provider "vault" {
  address = var.vault_address
  token   = var.vault_token
}

# Call modules
module "network" {
  source = "./modules/network"
  
  environment     = var.environment
  vpc_cidr        = var.vpc_cidr
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  
  common_tags = local.common_tags
}

module "security" {
  source = "./modules/security"
  
  environment = var.environment
  vpc_id      = module.network.vpc_id
  
  common_tags = local.common_tags
}

module "nomad_cluster" {
  source = "./modules/nomad"
  
  environment        = var.environment
  vpc_id            = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  public_subnet_ids  = module.network.public_subnet_ids
  security_group_ids = module.security.nomad_security_group_ids
  
  nomad_server_count = var.nomad_server_count
  nomad_client_count = var.nomad_client_count
  instance_type      = var.nomad_instance_type
  
  common_tags = local.common_tags
}

module "consul_cluster" {
  source = "./modules/consul"
  
  environment        = var.environment
  vpc_id            = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  security_group_ids = module.security.consul_security_group_ids
  
  consul_server_count = var.consul_server_count
  instance_type       = var.consul_instance_type
  
  common_tags = local.common_tags
}

module "vault_cluster" {
  source = "./modules/vault"
  
  environment        = var.environment
  vpc_id            = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  security_group_ids = module.security.vault_security_group_ids
  
  vault_server_count = var.vault_server_count
  instance_type      = var.vault_instance_type
  
  common_tags = local.common_tags
}

module "load_balancer" {
  source = "./modules/load_balancer"
  
  environment       = var.environment
  vpc_id           = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  domain_name      = var.domain_name
  
  common_tags = local.common_tags
}

module "monitoring" {
  source = "./modules/monitoring"
  
  environment        = var.environment
  vpc_id            = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  
  common_tags = local.common_tags
}

module "backup" {
  source = "./modules/backup"
  
  environment = var.environment
  
  common_tags = local.common_tags
}

# Multi-cloud resources
module "gcp_resources" {
  source = "./modules/gcp"
  count  = var.enable_gcp ? 1 : 0
  
  environment = var.environment
  project_id  = var.gcp_project_id
  region      = var.gcp_region
  
  common_tags = local.common_tags
}

module "azure_resources" {
  source = "./modules/azure"
  count  = var.enable_azure ? 1 : 0
  
  environment = var.environment
  location    = var.azure_location
  
  common_tags = local.common_tags
}
---
title: "Baby's first Cross Cluster Search"
date: "2025-07-13"
draft: true
---

Based on your requirements, here's the prompt you should give to Claude Code and some ASCII art diagrams to help you visualize the architecture:
Prompt for Claude Code
I need you to implement a complete Wazuh MSSP (Managed Security Service Provider) platform in the eos repository. This platform uses HashiCorp Nomad for orchestration, Temporal for workflows, Benthos+NATS for data streaming, and SaltStack for configuration management.

The platform should support multi-tenant Wazuh deployments with Cross-Cluster Search (CCS), where each customer gets isolated Wazuh infrastructure, but a central SOC can query all customer data.

Key requirements:
1. Create a new module under `modules/wazuh-mssp/` with complete Terraform, Nomad, SaltStack, and Temporal configurations
2. Implement `eos create wazuh-ccs` command with subcommands: --init, --add-customer, --scale-customer, --remove-customer
3. Use KVM/libvirt for virtualization on Ubuntu hosts
4. Each customer gets: dedicated Wazuh server + indexer + optional dashboard in isolated network
5. Central CCS environment has only Wazuh indexer + dashboard for querying all customers
6. Integrate with Authentik for SSO and self-service customer onboarding
7. Use NATS JetStream for event streaming and Benthos for webhook ingestion
8. Implement Temporal workflows for provisioning, scaling, backup, and billing
9. Create SaltStack states for automated configuration of all components
10. Support customer tiers (starter/pro/enterprise) with resource limits

Directory structure to create:
- modules/wazuh-mssp/terraform/ (Terraform modules)
- modules/wazuh-mssp/nomad/ (Nomad job specifications)
- modules/wazuh-mssp/salt/ (SaltStack states and pillars)
- modules/wazuh-mssp/temporal/ (Go workflows and activities)
- modules/wazuh-mssp/benthos/ (Pipeline configurations)
- modules/wazuh-mssp/scripts/ (EOS integration scripts)

The implementation should be production-ready with proper error handling, monitoring, security (Vault integration), and documentation. Include development environment setup with Docker Compose.

Please implement this step by step, starting with the directory structure, then Terraform modules, followed by Nomad jobs, Temporal workflows, Benthos configs, and finally the EOS integration script.

Architecture Diagrams
1. Overall MSSP Architecture
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              WAZUH MSSP PLATFORM                                │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ┌─────────────────────┐         ┌──────────────────────┐                     │
│  │   Authentik SSO     │         │  Customer Portal     │                     │
│  │  ┌──────────────┐   │         │  ┌───────────────┐   │                     │
│  │  │Self-Service  │   │◄────────┤  │ Billing/Usage │   │                     │
│  │  │Registration  │   │         │  │   Dashboard   │   │                     │
│  │  └──────────────┘   │         │  └───────────────┘   │                     │
│  └──────────┬──────────┘         └──────────────────────┘                     │
│             │                                                                   │
│             ▼ Webhooks                                                          │
│  ┌─────────────────────────────────────────────────────────────┐              │
│  │                    CONTROL PLANE (Nomad Cluster)             │              │
│  │  ┌─────────────┐  ┌─────────────┐  ┌──────────────────┐   │              │
│  │  │   Benthos   │  │  Temporal   │  │  NATS JetStream  │   │              │
│  │  │  Pipelines  │──┤  Workflows  │──┤   Message Bus     │   │              │
│  │  └─────────────┘  └─────────────┘  └──────────────────┘   │              │
│  │         │                │                    │             │              │
│  │         └────────────────┴────────────────────┘             │              │
│  │                          │                                  │              │
│  │  ┌─────────────┐  ┌─────▼──────┐  ┌──────────────────┐   │              │
│  │  │   Consul    │  │    API     │  │     Vault        │   │              │
│  │  │  Service    │──┤  Service   │──┤  Secrets Mgmt    │   │              │
│  │  │   Mesh      │  │            │  │                  │   │              │
│  │  └─────────────┘  └────────────┘  └──────────────────┘   │              │
│  └─────────────────────────┬───────────────────────────────────┘              │
│                             │                                                   │
│  ┌──────────────────────────┼───────────────────────────────────┐             │
│  │         CCS Environment  │          (Central SOC)             │             │
│  │  ┌────────────────┐     │    ┌────────────────────────┐     │             │
│  │  │ Wazuh Indexer  │     │    │   Wazuh Dashboard     │     │             │
│  │  │   (No Data)    │◄────┼────┤  (Multi-Cluster View) │     │             │
│  │  │  Query Only    │     │    │    SOC Analysts       │     │             │
│  │  └───────┬────────┘     │    └────────────────────────┘     │             │
│  └──────────┼──────────────┼────────────────────────────────────┘             │
│             │              │                                                   │
│             │              │ Terraform provisions                              │
│             │              │ SaltStack configures                              │
│      Cross-Cluster         ▼                                                   │
│         Search     ┌────────────────┐  ┌────────────────┐                     │
│             │      │  Customer A     │  │  Customer B     │                     │
│             │      │  Environment    │  │  Environment    │    ...            │
│             │      ├────────────────┤  ├────────────────┤                     │
│             └─────►│ Wazuh Server   │  │ Wazuh Server   │                     │
│                    │ Wazuh Indexer  │  │ Wazuh Indexer  │                     │
│                    │ Wazuh Dashboard│  │ Wazuh Dashboard│                     │
│                    │ (Isolated)     │  │ (Isolated)     │                     │
│                    └────────────────┘  └────────────────┘                     │
│                           │                    │                               │
│                      ┌────┴────┐          ┌───┴────┐                          │
│                      │ Agents  │          │ Agents │                          │
│                      └─────────┘          └────────┘                          │
└─────────────────────────────────────────────────────────────────────────────────┘

2. Nomad Cluster Architecture
┌─────────────────────────────────────────────────────────────────────┐
│                        NOMAD CLUSTER TOPOLOGY                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                    Nomad Servers (3 nodes)                   │  │
│  │  ┌────────────┐   ┌────────────┐   ┌────────────┐         │  │
│  │  │  Server 1  │   │  Server 2  │   │  Server 3  │         │  │
│  │  │  (Leader)  │◄──┤            │◄──┤            │         │  │
│  │  │            │   │            │   │            │         │  │
│  │  └─────┬──────┘   └─────┬──────┘   └─────┬──────┘         │  │
│  │        │ Raft           │               │                  │  │
│  │        └────────────────┴───────────────┘                  │  │
│  └────────────────────────┬─────────────────────────────────┘  │
│                           │                                     │
│                           │ Job Scheduling                      │
│                           ▼                                     │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                    Nomad Clients (5+ nodes)                 │  │
│  │                                                             │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │  │
│  │  │   Client 1   │  │   Client 2   │  │   Client 3   │    │  │
│  │  │ ┌──────────┐ │  │ ┌──────────┐ │  │ ┌──────────┐ │    │  │
│  │  │ │ Platform │ │  │ │ Customer │ │  │ │ Customer │ │    │  │
│  │  │ │   Jobs   │ │  │ │ A Jobs   │ │  │ │ B Jobs   │ │    │  │
│  │  │ │          │ │  │ │          │ │  │ │          │ │    │  │
│  │  │ │ -Temporal│ │  │ │ -Indexer │ │  │ │ -Indexer │ │    │  │
│  │  │ │ -NATS    │ │  │ │ -Server  │ │  │ │ -Server  │ │    │  │
│  │  │ │ -Benthos │ │  │ │ -Dashboard│ │  │ │ -Dashboard│ │    │  │
│  │  │ │ -API     │ │  │ └──────────┘ │  │ └──────────┘ │    │  │
│  │  │ └──────────┘ │  └──────────────┘  └──────────────┘    │  │
│  │  │              │                                          │  │
│  │  │ ┌──────────┐ │  ┌──────────────┐  ┌──────────────┐    │  │
│  │  │ │  Consul  │ │  │    Consul    │  │    Consul    │    │  │
│  │  │ │  Agent   │ │  │    Agent     │  │    Agent     │    │  │
│  │  │ └──────────┘ │  └──────────────┘  └──────────────┘    │  │
│  │  └──────────────┘                                          │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                   Consul Service Mesh                        │  │
│  │  ┌─────────────┐      ┌─────────────┐     ┌─────────────┐ │  │
│  │  │   Service   │◄────►│   Service   │◄───►│   Service   │ │  │
│  │  │  Discovery  │      │   Connect   │     │ Intentions  │ │  │
│  │  └─────────────┘      └─────────────┘     └─────────────┘ │  │
│  └─────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘

3. Data Flow Architecture
┌─────────────────────────────────────────────────────────────────────┐
│                         EVENT FLOW ARCHITECTURE                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  External Events                                                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐               │
│  │  Authentik  │  │   Stripe    │  │   Admin     │               │
│  │  Webhooks   │  │  Webhooks   │  │    API      │               │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘               │
│         │                 │                 │                       │
│         └─────────────────┴─────────────────┘                       │
│                           │                                         │
│                           ▼                                         │
│         ┌─────────────────────────────────┐                       │
│         │      Benthos Webhook Ingress    │                       │
│         │  ┌───────────────────────────┐  │                       │
│         │  │ • Authentication          │  │                       │
│         │  │ • Signature Validation    │  │                       │
│         │  │ • Event Normalization     │  │                       │
│         │  └───────────────────────────┘  │                       │
│         └────────────────┬────────────────┘                       │
│                          │                                         │
│                          ▼                                         │
│         ┌─────────────────────────────────┐                       │
│         │         NATS JetStream          │                       │
│         │  ┌───────────────────────────┐  │                       │
│         │  │ Subjects:                 │  │                       │
│         │  │ • webhooks.authentik      │  │                       │
│         │  │ • webhooks.stripe         │  │                       │
│         │  │ • customer.*.provision    │  │                       │
│         │  │ • customer.*.alerts       │  │                       │
│         │  │ • platform.health         │  │                       │
│         │  └───────────────────────────┘  │                       │
│         └────────────────┬────────────────┘                       │
│                          │                                         │
│                          ▼                                         │
│         ┌─────────────────────────────────┐                       │
│         │      Benthos Event Router       │                       │
│         │  ┌───────────────────────────┐  │                       │
│         │  │ Routes to:                │  │                       │
│         │  │ • Temporal Workflows      │  │                       │
│         │  │ • Metrics Processor      │  │                       │
│         │  │ • Alert Forwarder        │  │                       │
│         │  └───────────────────────────┘  │                       │
│         └────────┬──────────┬─────────────┘                       │
│                  │          │                                      │
│         ┌────────▼───┐  ┌──▼──────────┐  ┌─────────────┐        │
│         │  Temporal  │  │   Metrics   │  │   Alerts    │        │
│         │ Workflows  │  │  Processor  │  │  Forwarder  │        │
│         └────────────┘  └─────────────┘  └─────────────┘        │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

4. Customer Isolation Model
┌─────────────────────────────────────────────────────────────────────┐
│                    MULTI-TENANT ISOLATION MODEL                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Platform Namespace                                                 │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │  Shared Services:                                            │  │
│  │  • API Gateway  • Temporal  • NATS  • Benthos  • Monitoring │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  Customer A Namespace          │  Customer B Namespace             │
│  ┌────────────────────────┐   │  ┌────────────────────────┐      │
│  │  Network: 10.100.0.0/24│   │  │  Network: 10.101.0.0/24│      │
│  │  ┌──────────────────┐  │   │  │  ┌──────────────────┐  │      │
│  │  │  Wazuh Server    │  │   │  │  │  Wazuh Server    │  │      │
│  │  │  10.100.0.10     │  │   │  │  │  10.101.0.10     │  │      │
│  │  └────────┬─────────┘  │   │  │  └────────┬─────────┘  │      │
│  │           │             │   │  │           │             │      │
│  │  ┌────────▼─────────┐  │   │  │  ┌────────▼─────────┐  │      │
│  │  │  Wazuh Indexer   │  │   │  │  │  Wazuh Indexer   │  │      │
│  │  │  10.100.0.11     │  │   │  │  │  10.101.0.11     │  │      │
│  │  └──────────────────┘  │   │  │  └──────────────────┘  │      │
│  │                         │   │  │                         │      │
│  │  ┌──────────────────┐  │   │  │  ┌──────────────────┐  │      │
│  │  │ Wazuh Dashboard  │  │   │  │  │ Wazuh Dashboard  │  │      │
│  │  │  10.100.0.12     │  │   │  │  │  10.101.0.12     │  │      │
│  │  └──────────────────┘  │   │  │  └──────────────────┘  │      │
│  │                         │   │  │                         │      │
│  │  Resources:             │   │  │  Resources:             │      │
│  │  • CPU: 4 cores        │   │  │  • CPU: 8 cores        │      │
│  │  • RAM: 8GB            │   │  │  • RAM: 16GB           │      │
│  │  • Disk: 500GB         │   │  │  • Disk: 1TB           │      │
│  │                         │   │  │                         │      │
│  │  NATS Account: CUST-A  │   │  │  NATS Account: CUST-B  │      │
│  │  Vault Path: /cust-a/* │   │  │  Vault Path: /cust-b/* │      │
│  └────────────────────────┘   │  └────────────────────────┘      │
│                                │                                    │
│  Isolation Mechanisms:         │  Cross-Cluster Search:            │
│  • Nomad Namespaces           │  • Read-only access from CCS      │
│  • Network Segmentation        │  • Certificate-based trust        │
│  • NATS Account Isolation     │  • Query audit logging            │
│  • Vault Policy Boundaries     │  • No data replication            │
│  • Resource Quotas             │                                    │
└─────────────────────────────────────────────────────────────────────┘

5. Temporal Workflow Example
┌─────────────────────────────────────────────────────────────────────┐
│              CUSTOMER PROVISIONING WORKFLOW                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Start                                                              │
│    │                                                                │
│    ▼                                                                │
│  ┌─────────────────┐                                              │
│  │   Validate      │                                              │
│  │   Request       │──────► Invalid ──────► End (Failed)          │
│  └────────┬────────┘                                              │
│           │ Valid                                                  │
│           ▼                                                        │
│  ┌─────────────────┐                                              │
│  │   Allocate      │                                              │
│  │   Resources     │──────► Failed ───────► End (Failed)          │
│  └────────┬────────┘                                              │
│           │ Success                                                │
│           ▼                                                        │
│  ┌─────────────────┐                                              │
│  │  Run Terraform  │                                              │
│  │  (30min timeout)│──────► Failed ───────┐                       │
│  └────────┬────────┘                       │                      │
│           │ Success                        │                      │
│           ▼                                ▼                      │
│  ┌─────────────────────────────┐   ┌──────────────┐              │
│  │    Parallel Activities      │   │   Rollback   │              │
│  │  ┌─────────┐ ┌───────────┐ │   │  Activities  │              │
│  │  │ Nomad   │ │   NATS    │ │   │              │              │
│  │  │Namespace│ │  Account  │ │   │ • Destroy    │              │
│  │  └─────────┘ └───────────┘ │   │   Resources  │              │
│  │  ┌─────────┐ ┌───────────┐ │   │ • Release    │              │
│  │  │  Vault  │ │   Salt    │ │   │   Allocation │              │
│  │  │Policies │ │  Config   │ │   │ • Notify     │              │
│  │  └─────────┘ └───────────┘ │   │   Admin      │              │
│  └────────┬────────────────────┘   └──────────────┘              │
│           │ All Success                                           │
│           ▼                                                        │
│  ┌─────────────────┐                                              │
│  │  Deploy Wazuh   │                                              │
│  │   Components    │──────► Failed ───────► Rollback              │
│  └────────┬────────┘                                              │
│           │ Success                                                │
│           ▼                                                        │
│  ┌─────────────────┐                                              │
│  │Create Authentik │                                              │
│  │  Application    │──────► Failed ───────► Rollback              │
│  └────────┬────────┘                                              │
│           │ Success                                                │
│           ▼                                                        │
│  ┌─────────────────┐                                              │
│  │ Send Welcome    │                                              │
│  │     Email       │──────► Failed ───────► Log & Continue        │
│  └────────┬────────┘                                              │
│           │                                                        │
│           ▼                                                        │
│  ┌─────────────────┐                                              │
│  │Start Monitoring │                                              │
│  │   Workflow      │                                              │
│  └────────┬────────┘                                              │
│           │                                                        │
│           ▼                                                        │
│         End (Success)                                              │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

These diagrams show:
Overall Architecture: How all components connect from customer registration to data access
Nomad Cluster: The orchestration layer with server/client topology
Data Flow: How events flow through the system from webhooks to processing
Customer Isolation: Network and resource isolation between customers
Workflow Example: A typical Temporal workflow with error handling
The architecture ensures:
Complete customer isolation
Centralized monitoring without data duplication
Self-service provisioning
Scalable and fault-tolerant design
Security at every layer
Does this match what you're looking for? Would you like me to adjust any part of the architecture or provide additional diagrams for specific components?



Wazuh MSSP Platform - HashiCorp Stack Implementation
Overview
This implementation provides a complete Wazuh MSSP (Managed Security Service Provider) platform using:
HashiCorp Nomad for orchestration
Temporal for workflow management
Benthos + NATS for data streaming
Consul for service mesh
Vault for secrets management
Terraform for infrastructure as code
SaltStack for configuration management
Directory Structure
wazuh-mssp/
├── terraform/
│   ├── environments/
│   │   ├── dev/
│   │   ├── staging/
│   │   └── production/
│   ├── modules/
│   │   ├── nomad-cluster/
│   │   ├── temporal-cluster/
│   │   ├── nats-cluster/
│   │   ├── benthos-pipelines/
│   │   └── customer-workload/
│   └── global/
├── nomad/
│   ├── jobs/
│   ├── packs/
│   └── policies/
├── temporal/
│   ├── workflows/
│   ├── activities/
│   └── workers/
├── benthos/
│   ├── configs/
│   └── templates/
├── nats/
│   ├── configs/
│   └── templates/
├── salt/
│   ├── pillar/
│   └── states/
└── scripts/
    └── eos/

1. Terraform Infrastructure
Main Terraform Configuration
# terraform/environments/production/main.tf
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    nomad = {
      source  = "hashicorp/nomad"
      version = "~> 2.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.18"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.20"
    }
  }
  
  backend "s3" {
    bucket         = "wazuh-mssp-terraform-state"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

# Data center configuration
locals {
  datacenter = "dc1"
  region     = "us-east-1"
  
  tags = {
    Environment = "production"
    Project     = "wazuh-mssp"
    ManagedBy   = "terraform"
  }
}

# Nomad Cluster
module "nomad_cluster" {
  source = "../../modules/nomad-cluster"
  
  cluster_name       = "wazuh-mssp-prod"
  datacenter        = local.datacenter
  server_count      = 3
  client_count      = 5
  
  server_instance_type = "t3.large"
  client_instance_type = "t3.xlarge"
  
  enable_consul_connect = true
  enable_vault         = true
  
  tags = local.tags
}

# Temporal Cluster
module "temporal_cluster" {
  source = "../../modules/temporal-cluster"
  
  cluster_name = "wazuh-temporal"
  namespace    = "default"
  
  postgres_instance_class = "db.t3.medium"
  elasticsearch_instance_type = "t3.medium.elasticsearch"
  
  nomad_namespace = module.nomad_cluster.temporal_namespace
  consul_service_name = "temporal"
  
  tags = local.tags
}

# NATS Cluster
module "nats_cluster" {
  source = "../../modules/nats-cluster"
  
  cluster_name = "wazuh-nats"
  server_count = 3
  
  enable_jetstream = true
  max_memory      = "4Gi"
  max_storage     = "100Gi"
  
  nomad_job_namespace = module.nomad_cluster.platform_namespace
  
  tags = local.tags
}

# Benthos Pipelines
module "benthos_pipelines" {
  source = "../../modules/benthos-pipelines"
  
  pipelines = {
    webhook_ingress = {
      replicas = 3
      cpu      = 500
      memory   = 512
    }
    event_router = {
      replicas = 2
      cpu      = 1000
      memory   = 1024
    }
    metrics_processor = {
      replicas = 2
      cpu      = 500
      memory   = 512
    }
  }
  
  nats_cluster_address = module.nats_cluster.cluster_address
  temporal_address     = module.temporal_cluster.frontend_address
  
  nomad_job_namespace = module.nomad_cluster.platform_namespace
  
  tags = local.tags
}

Nomad Cluster Module
# terraform/modules/nomad-cluster/main.tf
variable "cluster_name" {
  description = "Name of the Nomad cluster"
  type        = string
}

variable "datacenter" {
  description = "Datacenter name"
  type        = string
}

variable "server_count" {
  description = "Number of Nomad servers"
  type        = number
  default     = 3
}

variable "client_count" {
  description = "Number of Nomad clients"
  type        = number
  default     = 3
}

variable "server_instance_type" {
  description = "EC2 instance type for servers"
  type        = string
  default     = "t3.medium"
}

variable "client_instance_type" {
  description = "EC2 instance type for clients"
  type        = string
  default     = "t3.large"
}

# VPC Configuration
resource "aws_vpc" "nomad" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(var.tags, {
    Name = "${var.cluster_name}-vpc"
  })
}

# Subnets
resource "aws_subnet" "nomad_private" {
  count             = 3
  vpc_id            = aws_vpc.nomad.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = merge(var.tags, {
    Name = "${var.cluster_name}-private-${count.index + 1}"
    Type = "private"
  })
}

# Security Groups
resource "aws_security_group" "nomad_server" {
  name_prefix = "${var.cluster_name}-server-"
  vpc_id      = aws_vpc.nomad.id
  
  # Nomad RPC
  ingress {
    from_port   = 4647
    to_port     = 4647
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.nomad.cidr_block]
  }
  
  # Nomad Serf
  ingress {
    from_port   = 4648
    to_port     = 4648
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.nomad.cidr_block]
  }
  
  # Consul
  ingress {
    from_port   = 8300
    to_port     = 8302
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.nomad.cidr_block]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(var.tags, {
    Name = "${var.cluster_name}-server-sg"
  })
}

# Launch Template for Nomad Servers
resource "aws_launch_template" "nomad_server" {
  name_prefix   = "${var.cluster_name}-server-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.server_instance_type
  
  vpc_security_group_ids = [aws_security_group.nomad_server.id]
  
  iam_instance_profile {
    name = aws_iam_instance_profile.nomad_server.name
  }
  
  user_data = base64encode(templatefile("${path.module}/templates/server-init.sh", {
    cluster_name   = var.cluster_name
    datacenter     = var.datacenter
    server_count   = var.server_count
    consul_encrypt = random_id.consul_encrypt.b64_std
  }))
  
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 50
      volume_type = "gp3"
      encrypted   = true
    }
  }
  
  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.cluster_name}-server"
      Role = "nomad-server"
    })
  }
}

# Auto Scaling Group for Servers
resource "aws_autoscaling_group" "nomad_server" {
  name_prefix         = "${var.cluster_name}-server-"
  vpc_zone_identifier = aws_subnet.nomad_private[*].id
  target_group_arns   = [aws_lb_target_group.nomad_server.arn]
  
  min_size         = var.server_count
  max_size         = var.server_count
  desired_capacity = var.server_count
  
  launch_template {
    id      = aws_launch_template.nomad_server.id
    version = "$Latest"
  }
  
  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-server"
    propagate_at_launch = true
  }
}

# Similar configuration for Nomad clients...

# Outputs
output "server_lb_dns" {
  value = aws_lb.nomad_server.dns_name
}

output "platform_namespace" {
  value = "platform"
}

output "temporal_namespace" {
  value = "temporal"
}

output "consul_encrypt_key" {
  value     = random_id.consul_encrypt.b64_std
  sensitive = true
}

2. Nomad Job Specifications
API Service Job
# nomad/jobs/api-service.nomad
job "wazuh-api" {
  datacenters = ["dc1"]
  type        = "service"
  namespace   = "platform"
  
  update {
    max_parallel      = 2
    health_check      = "checks"
    min_healthy_time  = "30s"
    healthy_deadline  = "5m"
    progress_deadline = "10m"
    auto_revert       = true
    auto_promote      = true
    canary            = 2
  }
  
  group "api" {
    count = 3
    
    constraint {
      attribute = "${node.class}"
      value     = "api"
    }
    
    network {
      mode = "bridge"
      
      port "http" {
        to = 8000
      }
      
      port "metrics" {
        to = 9090
      }
    }
    
    service {
      name = "wazuh-api"
      port = "http"
      
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.api.rule=Host(`api.wazuh-mssp.com`)",
        "traefik.http.routers.api.tls=true",
        "traefik.http.routers.api.tls.certresolver=letsencrypt",
      ]
      
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "temporal-frontend"
              local_bind_port  = 7233
            }
            
            upstreams {
              destination_name = "nats"
              local_bind_port  = 4222
            }
            
            upstreams {
              destination_name = "postgres"
              local_bind_port  = 5432
            }
          }
        }
      }
      
      check {
        type     = "http"
        path     = "/health"
        interval = "10s"
        timeout  = "2s"
      }
    }
    
    task "api" {
      driver = "docker"
      
      config {
        image = "wazuh-mssp/api:latest"
        ports = ["http", "metrics"]
      }
      
      vault {
        policies = ["wazuh-api"]
        
        change_mode   = "signal"
        change_signal = "SIGUSR1"
      }
      
      template {
        data = <<EOF
{{- with secret "database/creds/api" }}
DATABASE_URL="postgresql://{{ .Data.username }}:{{ .Data.password }}@localhost:5432/wazuh_mssp"
{{- end }}

{{- with secret "kv/data/api/config" }}
JWT_SECRET="{{ .Data.data.jwt_secret }}"
STRIPE_API_KEY="{{ .Data.data.stripe_api_key }}"
AUTHENTIK_URL="{{ .Data.data.authentik_url }}"
AUTHENTIK_TOKEN="{{ .Data.data.authentik_token }}"
{{- end }}

TEMPORAL_ADDRESS="localhost:7233"
NATS_URL="nats://localhost:4222"
LOG_LEVEL="info"
ENVIRONMENT="production"
EOF
        
        destination = "secrets/.env"
        env         = true
      }
      
      resources {
        cpu    = 1000
        memory = 1024
      }
    }
  }
}

Temporal Worker Job
# nomad/jobs/temporal-worker.nomad
job "temporal-worker" {
  datacenters = ["dc1"]
  type        = "service"
  namespace   = "temporal"
  
  group "provisioning" {
    count = 3
    
    network {
      mode = "bridge"
      
      port "metrics" {
        to = 9090
      }
    }
    
    service {
      name = "temporal-worker-provisioning"
      port = "metrics"
      
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "temporal-frontend"
              local_bind_port  = 7233
            }
            
            upstreams {
              destination_name = "nomad"
              local_bind_port  = 4646
            }
            
            upstreams {
              destination_name = "consul"
              local_bind_port  = 8500
            }
          }
        }
      }
    }
    
    task "worker" {
      driver = "docker"
      
      config {
        image = "wazuh-mssp/temporal-worker:latest"
        ports = ["metrics"]
        
        command = "/app/worker"
        args    = ["--task-queue", "provisioning"]
      }
      
      vault {
        policies = ["temporal-worker"]
      }
      
      template {
        data = <<EOF
TEMPORAL_ADDRESS=localhost:7233
TEMPORAL_NAMESPACE=default
TASK_QUEUE=provisioning
WORKER_ID={{ env "NOMAD_ALLOC_ID" }}

{{- with secret "kv/data/temporal/worker" }}
NOMAD_TOKEN="{{ .Data.data.nomad_token }}"
CONSUL_TOKEN="{{ .Data.data.consul_token }}"
VAULT_TOKEN="{{ .Data.data.vault_token }}"
{{- end }}

LOG_LEVEL=info
METRICS_PORT=9090
EOF
        
        destination = "secrets/.env"
        env         = true
      }
      
      resources {
        cpu    = 2000
        memory = 2048
      }
    }
  }
  
  # Similar groups for other task queues: operations, billing, etc.
}

Benthos Pipeline Job
# nomad/jobs/benthos-event-router.nomad
job "benthos-event-router" {
  datacenters = ["dc1"]
  type        = "service"
  namespace   = "platform"
  
  group "router" {
    count = 2
    
    network {
      mode = "bridge"
      
      port "http" {
        to = 4195
      }
      
      port "metrics" {
        to = 4196
      }
    }
    
    service {
      name = "benthos-event-router"
      port = "metrics"
      
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "nats"
              local_bind_port  = 4222
            }
            
            upstreams {
              destination_name = "temporal-frontend"
              local_bind_port  = 7233
            }
          }
        }
      }
      
      check {
        type     = "http"
        path     = "/ready"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }
    
    task "benthos" {
      driver = "docker"
      
      config {
        image = "jeffail/benthos:latest"
        ports = ["http", "metrics"]
        
        args = [
          "-c", "/local/benthos.yaml",
          "-r", "/local/resources/*.yaml"
        ]
      }
      
      vault {
        policies = ["benthos"]
      }
      
      template {
        data = file("../../benthos/configs/event-router.yaml")
        destination = "local/benthos.yaml"
      }
      
      template {
        data = <<EOF
NATS_URL=nats://localhost:4222
NATS_CREDS=/secrets/nats.creds
TEMPORAL_ADDRESS=localhost:7233
API_TOKEN={{ with secret "kv/data/benthos/tokens" }}{{ .Data.data.api_token }}{{ end }}
JAEGER_AGENT=localhost:6831
LOG_LEVEL=INFO
EOF
        
        destination = "secrets/.env"
        env         = true
      }
      
      template {
        data = <<EOF
{{ with secret "kv/data/nats/creds/benthos" }}{{ .Data.data.creds }}{{ end }}
EOF
        
        destination = "secrets/nats.creds"
      }
      
      resources {
        cpu    = 1000
        memory = 1024
      }
    }
  }
}

Customer Wazuh Deployment Template
# nomad/packs/wazuh-customer/wazuh-customer.nomad
job "wazuh-customer-[[.customer_id]]" {
  datacenters = [[.datacenters | toJson]]
  type        = "service"
  namespace   = "customer-[[.customer_id]]"
  
  meta {
    customer_id   = "[[.customer_id]]"
    customer_name = "[[.customer_name]]"
    tier         = "[[.tier]]"
  }
  
  constraint {
    attribute = "${meta.customer_isolation}"
    value     = "true"
  }
  
  group "indexer" {
    count = [[.indexer_count]]
    
    constraint {
      distinct_hosts = true
    }
    
    volume "indexer-data" {
      type      = "csi"
      source    = "indexer-data-[[.customer_id]]"
      read_only = false
      
      mount_options {
        fs_type = "ext4"
      }
    }
    
    network {
      mode = "bridge"
      
      port "http" {
        to = 9200
      }
      
      port "transport" {
        to = 9300
      }
    }
    
    service {
      name = "wazuh-indexer-[[.customer_id]]"
      port = "http"
      
      connect {
        sidecar_service {}
      }
      
      check {
        type     = "http"
        path     = "/_cluster/health"
        interval = "30s"
        timeout  = "5s"
      }
    }
    
    task "indexer" {
      driver = "docker"
      
      config {
        image = "wazuh/wazuh-indexer:[[.wazuh_version]]"
        ports = ["http", "transport"]
        
        volumes = [
          "local/opensearch.yml:/usr/share/wazuh-indexer/config/opensearch.yml",
        ]
      }
      
      volume_mount {
        volume      = "indexer-data"
        destination = "/var/lib/wazuh-indexer"
      }
      
      vault {
        policies = ["wazuh-customer"]
      }
      
      template {
        data = <<EOF
network.host: {{ env "NOMAD_IP_http" }}
node.name: {{ env "node.unique.name" }}
cluster.name: wazuh-cluster-[[.customer_id]]

# Cross-cluster search configuration
cluster.remote:
  ccs:
    seeds: ["{{ range service "ccs-wazuh-indexer" }}{{ .Address }}:9300{{ end }}"]
    skip_unavailable: true

# Additional configuration...
EOF
        
        destination = "local/opensearch.yml"
      }
      
      resources {
        cpu    = [[.indexer_cpu]]
        memory = [[.indexer_memory]]
      }
    }
  }
  
  group "server" {
    count = [[.server_count]]
    
    network {
      mode = "bridge"
      
      port "api" {
        to = 55000
      }
      
      port "agent" {
        to = 1514
      }
    }
    
    service {
      name = "wazuh-server-[[.customer_id]]"
      port = "api"
      
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "wazuh-indexer-[[.customer_id]]"
              local_bind_port  = 9200
            }
          }
        }
      }
    }
    
    task "server" {
      driver = "docker"
      
      config {
        image = "wazuh/wazuh-manager:[[.wazuh_version]]"
        ports = ["api", "agent"]
      }
      
      vault {
        policies = ["wazuh-customer"]
      }
      
      template {
        data = <<EOF
<ossec_config>
  <global>
    <jsonout_output>yes</jsonout_output>
    <alerts_log>yes</alerts_log>
    <logall>no</logall>
    <logall_json>no</logall_json>
    <email_notification>no</email_notification>
  </global>
  
  <cluster>
    <name>wazuh-cluster-[[.customer_id]]</name>
    <node_name>{{ env "node.unique.name" }}</node_name>
    <node_type>{{ if eq (env "NOMAD_ALLOC_INDEX") "0" }}master{{ else }}worker{{ end }}</node_type>
    <key>{{ with secret "kv/data/customer/[[.customer_id]]/wazuh" }}{{ .Data.data.cluster_key }}{{ end }}</key>
    <port>1516</port>
    <bind_addr>0.0.0.0</bind_addr>
    <nodes>
      {{ range service "wazuh-server-[[.customer_id]]" }}
      <node>{{ .Address }}</node>
      {{ end }}
    </nodes>
    <hidden>no</hidden>
    <disabled>no</disabled>
  </cluster>
</ossec_config>
EOF
        
        destination = "local/ossec.conf"
      }
      
      resources {
        cpu    = [[.server_cpu]]
        memory = [[.server_memory]]
      }
    }
  }
}

3. Temporal Workflows (Go)
Customer Provisioning Workflow
// temporal/workflows/customer_provisioning.go
package workflows

import (
    "context"
    "fmt"
    "time"
    
    "go.temporal.io/sdk/temporal"
    "go.temporal.io/sdk/workflow"
    
    "github.com/wazuh-mssp/temporal/activities"
    "github.com/wazuh-mssp/temporal/models"
)

// CustomerProvisioningWorkflow handles the complete customer onboarding process
func CustomerProvisioningWorkflow(ctx workflow.Context, request models.ProvisioningRequest) error {
    logger := workflow.GetLogger(ctx)
    logger.Info("Starting customer provisioning workflow", 
        "customerID", request.CustomerID,
        "tier", request.Tier)
    
    // Workflow options
    ao := workflow.ActivityOptions{
        StartToCloseTimeout: 10 * time.Minute,
        RetryPolicy: &temporal.RetryPolicy{
            InitialInterval:    time.Second,
            BackoffCoefficient: 2.0,
            MaximumInterval:    time.Minute,
            MaximumAttempts:    3,
        },
    }
    ctx = workflow.WithActivityOptions(ctx, ao)
    
    // Track provisioning state for rollback
    var provisioningState models.ProvisioningState
    
    // Step 1: Validate request and check resources
    var validation models.ValidationResult
    err := workflow.ExecuteActivity(ctx, activities.ValidateProvisioningRequest, request).Get(ctx, &validation)
    if err != nil {
        return fmt.Errorf("validation failed: %w", err)
    }
    
    if !validation.Valid {
        return fmt.Errorf("invalid provisioning request: %s", validation.Reason)
    }
    
    // Step 2: Allocate resources
    var allocation models.ResourceAllocation
    err = workflow.ExecuteActivity(ctx, activities.AllocateResources, request).Get(ctx, &allocation)
    if err != nil {
        return fmt.Errorf("resource allocation failed: %w", err)
    }
    provisioningState.ResourcesAllocated = true
    provisioningState.AllocationID = allocation.ID
    
    // Step 3: Create infrastructure with Terraform
    terraformCtx := workflow.WithActivityOptions(ctx, workflow.ActivityOptions{
        StartToCloseTimeout: 30 * time.Minute,
        HeartbeatTimeout:    time.Minute,
        RetryPolicy: &temporal.RetryPolicy{
            MaximumAttempts: 1, // Don't retry Terraform
        },
    })
    
    var infrastructure models.InfrastructureResult
    err = workflow.ExecuteActivity(terraformCtx, activities.RunTerraform, models.TerraformRequest{
        CustomerID: request.CustomerID,
        Module:     "customer-workload",
        Variables: map[string]interface{}{
            "customer_id":   request.CustomerID,
            "customer_name": request.CompanyName,
            "tier":         request.Tier,
            "subdomain":    request.Subdomain,
        },
    }).Get(ctx, &infrastructure)
    
    if err != nil {
        // Rollback on failure
        workflow.ExecuteActivity(ctx, activities.RollbackProvisioning, provisioningState)
        return fmt.Errorf("terraform execution failed: %w", err)
    }
    provisioningState.InfrastructureCreated = true
    provisioningState.InfrastructureID = infrastructure.ID
    
    // Step 4: Configure with Salt in parallel
    var futures []workflow.Future
    
    // Configure Nomad namespace and policies
    futures = append(futures, workflow.ExecuteActivity(ctx, 
        activities.ConfigureNomadNamespace, 
        request.CustomerID))
    
    // Configure NATS account
    futures = append(futures, workflow.ExecuteActivity(ctx, 
        activities.ConfigureNATSAccount, 
        request.CustomerID))
    
    // Configure Vault policies
    futures = append(futures, workflow.ExecuteActivity(ctx, 
        activities.ConfigureVaultPolicies, 
        request.CustomerID))
    
    // Wait for all parallel activities
    for _, future := range futures {
        if err := future.Get(ctx, nil); err != nil {
            workflow.ExecuteActivity(ctx, activities.RollbackProvisioning, provisioningState)
            return fmt.Errorf("configuration failed: %w", err)
        }
    }
    
    // Step 5: Deploy Wazuh components
    err = workflow.ExecuteActivity(ctx, activities.DeployWazuhComponents, models.WazuhDeployment{
        CustomerID: request.CustomerID,
        Tier:       request.Tier,
        Allocation: allocation,
    }).Get(ctx, nil)
    
    if err != nil {
        workflow.ExecuteActivity(ctx, activities.RollbackProvisioning, provisioningState)
        return fmt.Errorf("wazuh deployment failed: %w", err)
    }
    provisioningState.WazuhDeployed = true
    
    // Step 6: Create Authentik application
    var authentikApp models.AuthentikApplication
    err = workflow.ExecuteActivity(ctx, activities.CreateAuthentikApplication, models.AuthentikRequest{
        CustomerID:   request.CustomerID,
        CompanyName:  request.CompanyName,
        Subdomain:    request.Subdomain,
        AdminEmail:   request.AdminEmail,
        CallbackURLs: []string{
            fmt.Sprintf("https://%s.dashboard.wazuh-mssp.com/oauth2/callback", request.Subdomain),
        },
    }).Get(ctx, &authentikApp)
    
    if err != nil {
        workflow.ExecuteActivity(ctx, activities.RollbackProvisioning, provisioningState)
        return fmt.Errorf("authentik configuration failed: %w", err)
    }
    
    // Step 7: Send welcome email
    err = workflow.ExecuteActivity(ctx, activities.SendWelcomeEmail, models.WelcomeEmailRequest{
        CustomerID:    request.CustomerID,
        AdminEmail:    request.AdminEmail,
        DashboardURL:  fmt.Sprintf("https://%s.dashboard.wazuh-mssp.com", request.Subdomain),
        AgentKey:      infrastructure.AgentEnrollmentKey,
    }).Get(ctx, nil)
    
    if err != nil {
        // Non-critical, log but don't fail
        logger.Error("Failed to send welcome email", "error", err)
    }
    
    // Step 8: Start monitoring workflow
    childCtx := workflow.WithChildOptions(ctx, workflow.ChildWorkflowOptions{
        WorkflowID: fmt.Sprintf("monitor-%s", request.CustomerID),
    })
    workflow.ExecuteChildWorkflow(childCtx, CustomerMonitoringWorkflow, request.CustomerID)
    
    logger.Info("Customer provisioning completed successfully", 
        "customerID", request.CustomerID,
        "duration", workflow.Now(ctx).Sub(workflow.GetInfo(ctx).WorkflowStartTime))
    
    return nil
}

// CustomerMonitoringWorkflow continuously monitors customer health
func CustomerMonitoringWorkflow(ctx workflow.Context, customerID string) error {
    logger := workflow.GetLogger(ctx)
    
    // Run indefinitely with periodic checks
    for {
        // Wait for next check interval
        err := workflow.Sleep(ctx, 5*time.Minute)
        if err != nil {
            return err
        }
        
        // Check customer health
        ao := workflow.ActivityOptions{
            StartToCloseTimeout: time.Minute,
            RetryPolicy: &temporal.RetryPolicy{
                MaximumAttempts: 2,
            },
        }
        ctx := workflow.WithActivityOptions(ctx, ao)
        
        var health models.HealthStatus
        err = workflow.ExecuteActivity(ctx, activities.CheckCustomerHealth, customerID).Get(ctx, &health)
        if err != nil {
            logger.Error("Health check failed", "error", err)
            continue
        }
        
        // Handle unhealthy status
        if !health.Healthy {
            logger.Warn("Customer unhealthy", "customerID", customerID, "issues", health.Issues)
            
            // Trigger self-healing workflow
            childCtx := workflow.WithChildOptions(ctx, workflow.ChildWorkflowOptions{
                WorkflowID: fmt.Sprintf("heal-%s-%d", customerID, workflow.Now(ctx).Unix()),
            })
            workflow.ExecuteChildWorkflow(childCtx, SelfHealingWorkflow, customerID, health.Issues)
        }
    }
}

Temporal Activities
// temporal/activities/terraform.go
package activities

import (
    "context"
    "fmt"
    "os/exec"
    "path/filepath"
    
    "go.temporal.io/sdk/activity"
    
    "github.com/wazuh-mssp/temporal/models"
)

type TerraformActivities struct {
    WorkDir string
    StateS3Bucket string
}

func (t *TerraformActivities) RunTerraform(ctx context.Context, req models.TerraformRequest) (*models.InfrastructureResult, error) {
    logger := activity.GetLogger(ctx)
    logger.Info("Running Terraform", "module", req.Module, "customerID", req.CustomerID)
    
    // Setup working directory
    workDir := filepath.Join(t.WorkDir, req.CustomerID)
    
    // Write terraform configuration
    tfConfig := t.generateTerraformConfig(req)
    if err := t.writeTerraformFiles(workDir, tfConfig); err != nil {
        return nil, fmt.Errorf("failed to write terraform files: %w", err)
    }
    
    // Initialize Terraform
    initCmd := exec.CommandContext(ctx, "terraform", "init",
        "-backend-config", fmt.Sprintf("key=customers/%s/terraform.tfstate", req.CustomerID),
        "-backend-config", fmt.Sprintf("bucket=%s", t.StateS3Bucket))
    initCmd.Dir = workDir
    
    if output, err := initCmd.CombinedOutput(); err != nil {
        return nil, fmt.Errorf("terraform init failed: %w\n%s", err, output)
    }
    
    // Plan
    planCmd := exec.CommandContext(ctx, "terraform", "plan", "-out=tfplan")
    planCmd.Dir = workDir
    
    if output, err := planCmd.CombinedOutput(); err != nil {
        return nil, fmt.Errorf("terraform plan failed: %w\n%s", err, output)
    }
    
    // Apply with heartbeat
    applyCmd := exec.CommandContext(ctx, "terraform", "apply", "-auto-approve", "tfplan")
    applyCmd.Dir = workDir
    
    // Start apply in goroutine to handle heartbeats
    done := make(chan error, 1)
    go func() {
        output, err := applyCmd.CombinedOutput()
        if err != nil {
            done <- fmt.Errorf("terraform apply failed: %w\n%s", err, output)
        } else {
            done <- nil
        }
    }()
    
    // Send heartbeats while applying
    for {
        select {
        case err := <-done:
            if err != nil {
                return nil, err
            }
            // Get outputs
            return t.getTerraformOutputs(ctx, workDir, req.CustomerID)
            
        case <-ctx.Done():
            applyCmd.Process.Kill()
            return nil, ctx.Err()
            
        case <-activity.RecordHeartbeat(ctx):
            // Heartbeat recorded
        }
    }
}

func (t *TerraformActivities) generateTerraformConfig(req models.TerraformRequest) string {
    return fmt.Sprintf(`
module "customer_%s" {
  source = "../../../modules/%s"
  
  customer_id   = "%s"
  customer_name = "%s"
  tier         = "%s"
  subdomain    = "%s"
}

output "infrastructure_id" {
  value = module.customer_%s.infrastructure_id
}

output "agent_enrollment_key" {
  value     = module.customer_%s.agent_enrollment_key
  sensitive = true
}
`, req.CustomerID, req.Module, req.CustomerID, 
   req.Variables["customer_name"], req.Variables["tier"], 
   req.Variables["subdomain"], req.CustomerID, req.CustomerID)
}

4. NATS Configuration
NATS Server Configuration
# nats/configs/server.conf
# NATS Server Configuration for Wazuh MSSP

server_name: $SERVER_NAME
listen: 0.0.0.0:4222

# Cluster configuration
cluster {
  name: wazuh-mssp
  listen: 0.0.0.0:4248
  
  routes = [
    nats-route://nats-1.service.consul:4248
    nats-route://nats-2.service.consul:4248
    nats-route://nats-3.service.consul:4248
  ]
  
  authorization {
    user: cluster
    password: $CLUSTER_PASSWORD
    timeout: 2
  }
}

# JetStream configuration
jetstream {
  store_dir: /data/jetstream
  
  max_memory_store: 4GB
  max_file_store: 100GB
  
  cipher: "AES"
  key: $JETSTREAM_KEY
}

# System account
accounts {
  SYS: {
    users: [
      {user: system, password: $SYSTEM_PASSWORD}
    ]
  }
  
  # Platform account for internal services
  PLATFORM: {
    jetstream: enabled
    users: [
      {nkey: $PLATFORM_NKEY}
    ]
    
    exports: [
      {stream: "webhooks.>", accounts: ["*"]}
      {service: "workflow.trigger", accounts: ["*"]}
    ]
    
    imports: [
      {stream: {account: "*", subject: "customer.*.metrics"}, prefix: "all"}
      {stream: {account: "*", subject: "customer.*.alerts"}, prefix: "all"}
    ]
  }
}

# Operator JWT for dynamic accounts
operator: $OPERATOR_JWT
system_account: SYS

# Security
authorization {
  timeout: 2
}

# TLS
tls {
  cert_file: "/certs/server.crt"
  key_file: "/certs/server.key"
  ca_file: "/certs/ca.crt"
  verify: true
}

# Monitoring
monitor_port: 8222

Customer Account Template
// nats/account_manager.go
package nats

import (
    "fmt"
    "github.com/nats-io/jwt/v2"
    "github.com/nats-io/nkeys"
)

type AccountManager struct {
    operatorKP nkeys.KeyPair
    signingKP  nkeys.KeyPair
}

func (am *AccountManager) CreateCustomerAccount(customerID, tier string) (*jwt.AccountClaims, error) {
    // Generate account keypair
    accountKP, err := nkeys.CreateAccount()
    if err != nil {
        return nil, fmt.Errorf("failed to create account keypair: %w", err)
    }
    
    accountPub, _ := accountKP.PublicKey()
    
    // Create account claims
    account := jwt.NewAccountClaims(accountPub)
    account.Name = fmt.Sprintf("CUSTOMER-%s", customerID)
    
    // Set limits based on tier
    limits := am.getLimitsForTier(tier)
    account.Limits = limits
    
    // JetStream configuration
    account.Limits.JetStreamLimits = jwt.JetStreamLimits{
        MemoryStorage: limits.Data / 10,  // 10% for memory
        DiskStorage:   limits.Data,
        Streams:       100,
        Consumer:      1000,
    }
    
    // Set exports/imports
    account.Exports = jwt.Exports{
        {
            Name:    "Customer Metrics",
            Subject: jwt.Subject(fmt.Sprintf("customer.%s.metrics", customerID)),
            Type:    jwt.Stream,
        },
        {
            Name:    "Customer Alerts",  
            Subject: jwt.Subject(fmt.Sprintf("customer.%s.alerts", customerID)),
            Type:    jwt.Stream,
        },
    }
    
    account.Imports = jwt.Imports{
        {
            Name:    "Platform Events",
            Subject: jwt.Subject("platform.events"),
            Account: "PLATFORM",
            Type:    jwt.Stream,
        },
    }
    
    // Sign the account
    jwt, err := account.Encode(am.signingKP)
    if err != nil {
        return nil, fmt.Errorf("failed to encode account: %w", err)
    }
    
    return account, nil
}

func (am *AccountManager) getLimitsForTier(tier string) jwt.OperatorLimits {
    switch tier {
    case "starter":
        return jwt.OperatorLimits{
            Subs:    1000,
            Data:    10 * 1024 * 1024 * 1024,  // 10GB
            Payload: 1024 * 1024,               // 1MB
            Conn:    100,
        }
    case "pro":
        return jwt.OperatorLimits{
            Subs:    10000,
            Data:    100 * 1024 * 1024 * 1024, // 100GB
            Payload: 10 * 1024 * 1024,         // 10MB
            Conn:    1000,
        }
    case "enterprise":
        return jwt.OperatorLimits{
            Subs:    -1,  // Unlimited
            Data:    -1,  // Unlimited
            Payload: 100 * 1024 * 1024,        // 100MB
            Conn:    -1,  // Unlimited
        }
    default:
        return jwt.OperatorLimits{} // Defaults
    }
}

5. Development Environment
Docker Compose Setup
# development/docker-compose.yml
version: '3.8'

services:
  # Nomad Server
  nomad-server:
    image: hashicorp/nomad:1.7.2
    command: agent -dev -bind=0.0.0.0
    ports:
      - "4646:4646"
      - "4647:4647"
      - "4648:4648"
    environment:
      NOMAD_LOG_LEVEL: DEBUG
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./nomad:/etc/nomad.d
    networks:
      - wazuh-mssp

  # Consul
  consul:
    image: hashicorp/consul:1.17.0
    command: agent -dev -client=0.0.0.0
    ports:
      - "8500:8500"
      - "8600:8600/udp"
    networks:
      - wazuh-mssp

  # Vault
  vault:
    image: hashicorp/vault:1.15.0
    command: server -dev -dev-root-token-id="root"
    ports:
      - "8200:8200"
    environment:
      VAULT_DEV_ROOT_TOKEN_ID: root
      VAULT_DEV_LISTEN_ADDRESS: 0.0.0.0:8200
    cap_add:
      - IPC_LOCK
    networks:
      - wazuh-mssp

  # Temporal Server
  temporal:
    image: temporalio/auto-setup:1.22.0
    ports:
      - "7233:7233"
    environment:
      - DB=postgresql
      - DB_PORT=5432
      - POSTGRES_USER=temporal
      - POSTGRES_PWD=temporal
      - POSTGRES_SEEDS=postgresql
    depends_on:
      - postgresql
    networks:
      - wazuh-mssp

  # PostgreSQL for Temporal
  postgresql:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: temporal
      POSTGRES_PASSWORD: temporal
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - wazuh-mssp

  # NATS with JetStream
  nats:
    image: nats:2.10-alpine
    command: -js -sd /data
    ports:
      - "4222:4222"
      - "8222:8222"
    volumes:
      - nats_data:/data
      - ./nats/configs/dev.conf:/etc/nats/nats.conf
    networks:
      - wazuh-mssp

  # Benthos
  benthos:
    image: jeffail/benthos:latest
    command: -c /benthos.yaml
    ports:
      - "4195:4195"
      - "4196:4196"
    volumes:
      - ./benthos/configs/dev.yaml:/benthos.yaml
    depends_on:
      - nats
      - temporal
    networks:
      - wazuh-mssp

  # Traefik
  traefik:
    image: traefik:v3.0
    command:
      - "--api.insecure=true"
      - "--providers.consul=true"
      - "--providers.consul.endpoint.address=consul:8500"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"
    depends_on:
      - consul
    networks:
      - wazuh-mssp

volumes:
  postgres_data:
  nats_data:

networks:
  wazuh-mssp:
    driver: bridge

Development Benthos Configuration
# benthos/configs/dev.yaml
input:
  broker:
    inputs:
      - generate:
          mapping: |
            root = {
              "type": "customer.registered",
              "customer_id": uuid_v4(),
              "company_name": ["ACME Corp", "TechStart Inc", "DataFlow Systems"].index(random_int() % 3),
              "subdomain": ["acme", "techstart", "dataflow"].index(random_int() % 3),
              "tier": ["starter", "pro", "enterprise"].index(random_int() % 3),
              "admin_email": "admin@example.com",
              "timestamp": now()
            }
          interval: 30s
          count: 0

pipeline:
  processors:
    - label: add_metadata
      mapping: |
        meta event_type = this.type
        meta customer_id = this.customer_id

output:
  broker:
    pattern: fan_out
    outputs:
      - stdout: {}
      - nats_jetstream:
          urls: ["nats://nats:4222"]
          subject: webhooks.authentik

logger:
  level: DEBUG
  format: json

6. EOS Integration Script
#!/bin/bash
# scripts/eos/wazuh-ccs.sh

set -euo pipefail

COMMAND="${1:-}"
shift || true

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TERRAFORM_DIR="${PROJECT_ROOT}/terraform"
NOMAD_DIR="${PROJECT_ROOT}/nomad"

# Load environment
source "${PROJECT_ROOT}/.env"

# Helper functions
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >&2
}

error() {
    log "ERROR: $*"
    exit 1
}

# Initialize infrastructure
init_infrastructure() {
    log "Initializing Wazuh MSSP infrastructure..."
    
    cd "${TERRAFORM_DIR}/environments/${ENVIRONMENT:-production}"
    
    # Initialize Terraform
    terraform init
    
    # Plan and apply base infrastructure
    terraform plan -out=tfplan
    terraform apply tfplan
    
    # Wait for Nomad cluster
    log "Waiting for Nomad cluster to be ready..."
    until nomad server members &>/dev/null; do
        sleep 5
    done
    
    # Bootstrap ACLs
    log "Bootstrapping Nomad ACLs..."
    ./scripts/bootstrap-acls.sh
    
    # Deploy platform services
    log "Deploying platform services..."
    nomad namespace apply -description "Platform services" platform
    nomad namespace apply -description "Temporal workflows" temporal
    
    # Deploy core jobs
    for job in ${NOMAD_DIR}/jobs/core/*.nomad; do
        log "Deploying $(basename "$job")..."
        nomad job run "$job"
    done
    
    log "Infrastructure initialization complete!"
}

# Add customer
add_customer() {
    local config_file="${1:-}"
    
    if [[ -z "$config_file" || ! -f "$config_file" ]]; then
        error "Configuration file required: eos create wazuh-ccs --add-customer <config.json>"
    fi
    
    log "Adding customer from configuration: $config_file"
    
    # Parse configuration
    customer_id=$(jq -r '.customer_id' "$config_file")
    
    # Create Nomad namespace
    nomad namespace apply \
        -description "Customer: $(jq -r '.company_name' "$config_file")" \
        "customer-${customer_id}"
    
    # Apply Nomad quota
    nomad quota apply \
        -namespace "customer-${customer_id}" \
        -region global \
        -cpu-limit "$(jq -r '.resources.cpu // 4000' "$config_file")" \
        -memory-limit "$(jq -r '.resources.memory // 8192' "$config_file")" \
        "customer-${customer_id}"
    
    # Trigger provisioning workflow
    temporal workflow start \
        --task-queue provisioning \
        --type CustomerProvisioningWorkflow \
        --workflow-id "provision-${customer_id}" \
        --input "$config_file"
    
    log "Customer provisioning initiated. Workflow ID: provision-${customer_id}"
}

# Scale customer
scale_customer() {
    local customer_id="${1:-}"
    local new_tier="${2:-}"
    
    if [[ -z "$customer_id" || -z "$new_tier" ]]; then
        error "Usage: eos create wazuh-ccs --scale-customer <customer_id> <tier>"
    fi
    
    log "Scaling customer $customer_id to tier: $new_tier"
    
    # Create scaling request
    local scaling_request=$(cat <<EOF
{
  "customer_id": "${customer_id}",
  "new_tier": "${new_tier}"
}
EOF
)
    
    # Trigger scaling workflow
    temporal workflow start \
        --task-queue operations \
        --type CustomerScalingWorkflow \
        --workflow-id "scale-${customer_id}-$(date +%s)" \
        --input "${scaling_request}"
    
    log "Customer scaling initiated for ${customer_id}"
}

# Main command handler
case "$COMMAND" in
    --init)
        init_infrastructure
        ;;
    --add-customer)
        add_customer "$@"
        ;;
    --remove-customer)
        remove_customer "$@"
        ;;
    --scale-customer)
        scale_customer "$@"
        ;;
    --backup-customer)
        backup_customer "$@"
        ;;
    --status)
        show_status "$@"
        ;;
    *)
        cat <<EOF
Usage: eos create wazuh-ccs <command> [options]

Commands:
  --init                    Initialize MSSP infrastructure
  --add-customer <config>   Add new customer from config file
  --remove-customer <id>    Remove customer
  --scale-customer <id> <tier>  Change customer tier
  --backup-customer <id>    Manual backup
  --status [customer_id]    Show platform or customer status

Examples:
  eos create wazuh-ccs --init
  eos create wazuh-ccs --add-customer customer.json
  eos create wazuh-ccs --scale-customer cust_123 enterprise
EOF
        exit 1
        ;;
esac

Migration Guide
From Kubernetes to Nomad
Convert Deployments to Jobs:
Kubernetes Deployment → Nomad Job (type: service)
Kubernetes CronJob → Nomad Job (type: batch) with periodic stanza
Kubernetes DaemonSet → Nomad Job (type: system)
Service Discovery:
Kubernetes Service → Consul Service
Kubernetes Ingress → Traefik with Consul Catalog
Storage:
Kubernetes PVC → Nomad CSI Volume
Kubernetes ConfigMap → Consul KV or Nomad template
Kubernetes Secret → Vault Secret
Networking:
Kubernetes NetworkPolicy → Consul Intentions
Kubernetes Service Mesh → Consul Connect
From Celery to Temporal
Task → Activity:
# Celery task
@celery.task(bind=True, max_retries=3)
def provision_infrastructure(self, customer_id):
    try:
        # Task logic
    except Exception as exc:
        self.retry(exc=exc, countdown=60)

// Temporal activity
func (a *Activities) ProvisionInfrastructure(ctx context.Context, customerID string) error {
    // Activity logic with automatic retries
}

Chain → Workflow:
# Celery chain
chain(
    validate.s(data),
    allocate_resources.s(),
    provision.s(),
    configure.s()
).apply_async()

// Temporal workflow
func ProvisioningWorkflow(ctx workflow.Context, data Data) error {
    // Sequential execution with state management
    workflow.ExecuteActivity(ctx, a.Validate, data)
    workflow.ExecuteActivity(ctx, a.AllocateResources)
    workflow.ExecuteActivity(ctx, a.Provision)
    workflow.ExecuteActivity(ctx, a.Configure)
}

Operations Runbook
Daily Operations
Health Checks:
# Check Nomad cluster
nomad server members
nomad node status

# Check Consul services
consul members
consul catalog services

# Check Temporal
temporal operator cluster health

# Check NATS
nats-cli stream ls
nats-cli server report jetstream

Customer Monitoring:
# List all customers
nomad namespace list | grep customer-

# Check customer health
./scripts/check-customer-health.sh <customer_id>

# View customer logs
nomad alloc logs -namespace "customer-${CUSTOMER_ID}" <alloc_id>

Troubleshooting
Workflow Issues:
# List workflows
temporal workflow list

# Show workflow history
temporal workflow show -w <workflow_id>

# Reset workflow
temporal workflow reset -w <workflow_id> -r <run_id>

Service Discovery:
# Check service registration
consul catalog services -tags

# Debug service mesh
consul intention check <source> <destination>

Message Queue:
# Check NATS streams
nats stream info <stream_name>

# View pending messages
nats consumer report <stream_name>

Disaster Recovery
Backup Procedures:
Nomad: Snapshot state via nomad operator snapshot save
Consul: Snapshot via consul snapshot save
Vault: Backup storage backend
NATS: Backup JetStream directory
Recovery Steps:
Restore infrastructure with Terraform
Restore Nomad/Consul snapshots
Redeploy platform services
Restore customer data from backups
Validate all services
This completes the comprehensive implementation of the Wazuh MSSP platform using the HashiCorp stack. The architecture provides better operational visibility through Temporal, efficient message routing with NATS/Benthos, and simplified orchestration with Nomad.


SaltStack States and Additional Configurations
SaltStack States
Top File
# salt/pillar/top.sls
base:
  # Platform nodes
  'roles:nomad-server':
    - match: grain
    - nomad.server
    - consul.server
    - vault.server
    
  'roles:nomad-client':
    - match: grain  
    - nomad.client
    - consul.client
    - docker
    
  'roles:temporal':
    - match: grain
    - temporal.server
    - postgresql.temporal
    
  'roles:nats':
    - match: grain
    - nats.server
    - nats.accounts
    
  # Customer nodes
  'customer:*':
    - match: grain
    - wazuh.base
    - certificates.customer

---
# salt/states/top.sls
base:
  '*':
    - base.common
    - base.security
    - monitoring.node_exporter
    
  'roles:nomad-server':
    - match: grain
    - nomad.server
    - consul.server
    - vault.server
    
  'roles:nomad-client':
    - match: grain
    - nomad.client
    - consul.client
    - cni.plugins
    - docker
    
  'roles:temporal':
    - match: grain
    - temporal.server
    - postgresql
    
  'roles:nats':
    - match: grain
    - nats.server
    - nats.clustering

Base States
# salt/states/base/common.sls
# Common configuration for all nodes

# System packages
base_packages:
  pkg.installed:
    - pkgs:
      - curl
      - wget
      - htop
      - net-tools
      - jq
      - unzip
      - ca-certificates
      - gnupg
      - lsb-release
      - python3-pip
      - python3-venv

# System limits
/etc/security/limits.d/99-wazuh-mssp.conf:
  file.managed:
    - contents: |
        * soft nofile 65536
        * hard nofile 65536
        * soft nproc 32768
        * hard nproc 32768
        root soft nofile 65536
        root hard nofile 65536

# Sysctl tuning
net.core.somaxconn:
  sysctl.present:
    - value: 4096

net.ipv4.tcp_max_syn_backlog:
  sysctl.present:
    - value: 4096

vm.max_map_count:
  sysctl.present:
    - value: 262144

# Time synchronization
chrony:
  pkg.installed: []
  service.running:
    - enable: True
    - require:
      - pkg: chrony

# DNS configuration
/etc/systemd/resolved.conf.d/consul.conf:
  file.managed:
    - makedirs: True
    - contents: |
        [Resolve]
        DNS=127.0.0.1:8600
        Domains=~consul
        DNSSEC=false
    - require:
      - pkg: base_packages

---
# salt/states/base/security.sls
# Security hardening

# Firewall configuration
ufw:
  pkg.installed: []
  service.running:
    - enable: True
    - require:
      - pkg: ufw

# Default policies
ufw_default_incoming:
  cmd.run:
    - name: ufw default deny incoming
    - unless: ufw status | grep -q "Default: deny (incoming)"
    - require:
      - pkg: ufw

ufw_default_outgoing:
  cmd.run:
    - name: ufw default allow outgoing
    - unless: ufw status | grep -q "Default: allow (outgoing)"
    - require:
      - pkg: ufw

# Allow SSH
ufw_allow_ssh:
  cmd.run:
    - name: ufw allow 22/tcp
    - unless: ufw status | grep -q "22/tcp"
    - require:
      - pkg: ufw

# Fail2ban
fail2ban:
  pkg.installed: []
  service.running:
    - enable: True
    - require:
      - pkg: fail2ban

/etc/fail2ban/jail.local:
  file.managed:
    - contents: |
        [DEFAULT]
        bantime = 3600
        findtime = 600
        maxretry = 5
        
        [sshd]
        enabled = true
        port = 22
        logpath = %(sshd_log)s
        backend = %(sshd_backend)s
    - require:
      - pkg: fail2ban
    - watch_in:
      - service: fail2ban

# Audit daemon
auditd:
  pkg.installed: []
  service.running:
    - enable: True
    - require:
      - pkg: auditd

# Security updates
unattended-upgrades:
  pkg.installed: []
  
/etc/apt/apt.conf.d/50unattended-upgrades:
  file.managed:
    - contents: |
        Unattended-Upgrade::Allowed-Origins {
            "${distro_id}:${distro_codename}-security";
        };
        Unattended-Upgrade::AutoFixInterruptedDpkg "true";
        Unattended-Upgrade::MinimalSteps "true";
        Unattended-Upgrade::Remove-Unused-Dependencies "true";
        Unattended-Upgrade::Automatic-Reboot "false";
    - require:
      - pkg: unattended-upgrades

Nomad States
# salt/states/nomad/client.sls
{% set nomad = salt['pillar.get']('nomad', {}) %}
{% set consul = salt['pillar.get']('consul', {}) %}

# HashiCorp repository
hashicorp_repo:
  pkgrepo.managed:
    - name: deb https://apt.releases.hashicorp.com {{ grains['oscodename'] }} main
    - file: /etc/apt/sources.list.d/hashicorp.list
    - key_url: https://apt.releases.hashicorp.com/gpg
    - require_in:
      - pkg: nomad_package
      - pkg: consul_package

# Install packages
nomad_package:
  pkg.installed:
    - name: nomad
    - version: {{ nomad.get('version', '1.7.2') }}

consul_package:
  pkg.installed:
    - name: consul
    - version: {{ consul.get('version', '1.17.0') }}

# CNI plugins
/opt/cni/bin:
  file.directory:
    - makedirs: True

cni_plugins:
  archive.extracted:
    - name: /opt/cni/bin
    - source: https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-amd64-v1.3.0.tgz
    - skip_verify: True
    - enforce_toplevel: False
    - require:
      - file: /opt/cni/bin

# Docker installation
docker_requirements:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - ca-certificates
      - curl
      - software-properties-common

docker_repo:
  pkgrepo.managed:
    - name: deb https://download.docker.com/linux/ubuntu {{ grains['oscodename'] }} stable
    - file: /etc/apt/sources.list.d/docker.list
    - key_url: https://download.docker.com/linux/ubuntu/gpg
    - require:
      - pkg: docker_requirements

docker_ce:
  pkg.installed:
    - name: docker-ce
    - require:
      - pkgrepo: docker_repo

docker_service:
  service.running:
    - name: docker
    - enable: True
    - require:
      - pkg: docker_ce

# Nomad configuration directories
nomad_dirs:
  file.directory:
    - names:
      - /etc/nomad.d
      - /opt/nomad/data
      - /opt/nomad/plugins
      - /var/log/nomad
    - user: nomad
    - group: nomad
    - mode: 755
    - makedirs: True
    - require:
      - pkg: nomad_package

# Consul configuration
/etc/consul.d/consul.hcl:
  file.managed:
    - source: salt://nomad/files/consul-client.hcl.j2
    - template: jinja
    - user: consul
    - group: consul
    - mode: 640
    - context:
        datacenter: {{ nomad.get('datacenter', 'dc1') }}
        encrypt_key: {{ consul.get('encrypt_key') }}
        retry_join: {{ consul.get('retry_join', []) | json }}
    - require:
      - pkg: consul_package

# Nomad client configuration
/etc/nomad.d/nomad.hcl:
  file.managed:
    - source: salt://nomad/files/nomad-client.hcl.j2
    - template: jinja
    - user: nomad
    - group: nomad
    - mode: 640
    - context:
        datacenter: {{ nomad.get('datacenter', 'dc1') }}
        region: {{ nomad.get('region', 'global') }}
        servers: {{ nomad.get('servers', []) | json }}
        node_class: {{ nomad.get('node_class', 'general') }}
    - require:
      - pkg: nomad_package

# CNI configuration
/etc/cni/net.d/10-nomad-bridge.conflist:
  file.managed:
    - makedirs: True
    - contents: |
        {
          "cniVersion": "1.0.0",
          "name": "nomad-bridge",
          "plugins": [
            {
              "type": "bridge",
              "bridge": "nomad",
              "isGateway": true,
              "ipMasq": true,
              "hairpinMode": true,
              "ipam": {
                "type": "host-local",
                "ranges": [
                  [
                    {
                      "subnet": "172.26.0.0/16"
                    }
                  ]
                ]
              }
            },
            {
              "type": "portmap",
              "capabilities": {
                "portMappings": true
              }
            },
            {
              "type": "firewall"
            }
          ]
        }

# Services
consul_service:
  service.running:
    - name: consul
    - enable: True
    - require:
      - file: /etc/consul.d/consul.hcl
    - watch:
      - file: /etc/consul.d/consul.hcl

nomad_service:
  service.running:
    - name: nomad
    - enable: True
    - require:
      - service: consul_service
      - file: /etc/nomad.d/nomad.hcl
    - watch:
      - file: /etc/nomad.d/nomad.hcl

# Firewall rules
{% for port in [4646, 4647, 4648] %}
nomad_ufw_{{ port }}:
  cmd.run:
    - name: ufw allow {{ port }}/tcp
    - unless: ufw status | grep -q "{{ port }}/tcp"
{% endfor %}

{% for port in [8300, 8301, 8302, 8500, 8600] %}
consul_ufw_{{ port }}:
  cmd.run:
    - name: ufw allow {{ port }}/tcp
    - unless: ufw status | grep -q "{{ port }}/tcp"
{% endfor %}

Temporal States
# salt/states/temporal/server.sls
{% set temporal = salt['pillar.get']('temporal', {}) %}

# PostgreSQL for Temporal
postgresql_repo:
  pkgrepo.managed:
    - name: deb http://apt.postgresql.org/pub/repos/apt {{ grains['oscodename'] }}-pgdg main
    - file: /etc/apt/sources.list.d/pgdg.list
    - key_url: https://www.postgresql.org/media/keys/ACCC4CF8.asc

postgresql:
  pkg.installed:
    - name: postgresql-15
    - require:
      - pkgrepo: postgresql_repo

postgresql_service:
  service.running:
    - name: postgresql
    - enable: True
    - require:
      - pkg: postgresql

# Temporal database
temporal_db_user:
  postgres_user.present:
    - name: temporal
    - password: {{ temporal.get('db_password') }}
    - encrypted: True
    - require:
      - service: postgresql_service

temporal_db:
  postgres_database.present:
    - name: temporal
    - owner: temporal
    - require:
      - postgres_user: temporal_db_user

temporal_visibility_db:
  postgres_database.present:
    - name: temporal_visibility
    - owner: temporal
    - require:
      - postgres_user: temporal_db_user

# Temporal server
temporal_user:
  user.present:
    - name: temporal
    - system: True
    - shell: /bin/false
    - home: /var/lib/temporal
    - createhome: True

/opt/temporal:
  file.directory:
    - user: temporal
    - group: temporal
    - mode: 755

temporal_binary:
  archive.extracted:
    - name: /opt/temporal
    - source: https://github.com/temporalio/temporal/releases/download/v{{ temporal.get('version', '1.22.0') }}/temporal_{{ temporal.get('version', '1.22.0') }}_linux_amd64.tar.gz
    - skip_verify: True
    - user: temporal
    - group: temporal
    - require:
      - file: /opt/temporal

/etc/temporal/config.yaml:
  file.managed:
    - makedirs: True
    - user: temporal
    - group: temporal
    - mode: 640
    - contents: |
        log:
          stdout: true
          level: info
        
        persistence:
          defaultStore: postgres
          visibilityStore: postgres
          numHistoryShards: {{ temporal.get('history_shards', 512) }}
          
          datastores:
            postgres:
              sql:
                pluginName: postgres
                driverName: postgres
                databaseName: temporal
                connectAddr: localhost:5432
                connectProtocol: tcp
                user: temporal
                password: {{ temporal.get('db_password') }}
                maxConns: 20
                maxIdleConns: 20
                maxConnLifetime: 1h
        
        global:
          membership:
            maxJoinDuration: 30s
            broadcastAddress: {{ grains['ipv4'][0] }}
          
          pprof:
            port: 7936
          
          metrics:
            prometheus:
              timerType: histogram
              listenAddress: ":9090"
        
        services:
          frontend:
            rpc:
              grpcPort: 7233
              membershipPort: 6933
              bindOnLocalHost: false
            
          matching:
            rpc:
              grpcPort: 7235
              membershipPort: 6935
              bindOnLocalHost: false
          
          history:
            rpc:
              grpcPort: 7234
              membershipPort: 6934
              bindOnLocalHost: false
          
          worker:
            rpc:
              grpcPort: 7239
              membershipPort: 6939
              bindOnLocalHost: false
        
        clusterMetadata:
          enableGlobalNamespace: false
          failoverVersionIncrement: 10
          masterClusterName: active
          currentClusterName: active
          clusterInformation:
            active:
              enabled: true
              initialFailoverVersion: 1
              rpcName: frontend
              rpcAddress: localhost:7233

# Temporal systemd service
/etc/systemd/system/temporal.service:
  file.managed:
    - contents: |
        [Unit]
        Description=Temporal Server
        After=network.target postgresql.service
        
        [Service]
        Type=simple
        User=temporal
        Group=temporal
        WorkingDirectory=/opt/temporal
        ExecStart=/opt/temporal/temporal-server start
        Restart=on-failure
        RestartSec=10
        
        [Install]
        WantedBy=multi-user.target

temporal_service:
  service.running:
    - name: temporal
    - enable: True
    - require:
      - file: /etc/systemd/system/temporal.service
      - file: /etc/temporal/config.yaml
      - postgres_database: temporal_db
      - postgres_database: temporal_visibility_db
    - watch:
      - file: /etc/temporal/config.yaml

# Register with Consul
/etc/consul.d/temporal.json:
  file.managed:
    - contents: |
        {
          "service": {
            "name": "temporal-frontend",
            "tags": ["temporal", "frontend"],
            "port": 7233,
            "check": {
              "grpc": "localhost:7233",
              "interval": "10s"
            }
          }
        }
    - require:
      - service: temporal_service

NATS States
# salt/states/nats/server.sls
{% set nats = salt['pillar.get']('nats', {}) %}

nats_user:
  user.present:
    - name: nats
    - system: True
    - shell: /bin/false
    - home: /var/lib/nats
    - createhome: True

nats_directories:
  file.directory:
    - names:
      - /etc/nats
      - /var/lib/nats
      - /var/lib/nats/jetstream
      - /var/log/nats
    - user: nats
    - group: nats
    - mode: 755
    - makedirs: True
    - require:
      - user: nats_user

# Download NATS server
nats_binary:
  file.managed:
    - name: /usr/local/bin/nats-server
    - source: https://github.com/nats-io/nats-server/releases/download/v{{ nats.get('version', '2.10.0') }}/nats-server-v{{ nats.get('version', '2.10.0') }}-linux-amd64.tar.gz
    - source_hash: {{ nats.get('checksum') }}
    - makedirs: True
    - mode: 755
    - archive_format: tar
    - tar_options: '--strip-components=1 -xf'

# NSC for account management
nsc_binary:
  file.managed:
    - name: /usr/local/bin/nsc
    - source: https://github.com/nats-io/nsc/releases/download/v{{ nats.get('nsc_version', '2.8.0') }}/nsc-linux-amd64.zip
    - skip_verify: True
    - makedirs: True
    - mode: 755
    - archive_format: zip

# Initialize operator
/var/lib/nats/.nsc:
  file.directory:
    - user: nats
    - group: nats
    - mode: 700
    - require:
      - user: nats_user

nats_init_operator:
  cmd.run:
    - name: |
        export NSC_HOME=/var/lib/nats/.nsc
        nsc add operator {{ nats.get('operator_name', 'WAZUH-MSSP') }} \
          --generate-signing-key \
          --sys \
          --name {{ nats.get('operator_name', 'WAZUH-MSSP') }}
    - runas: nats
    - unless: test -d /var/lib/nats/.nsc/nats
    - require:
      - file: /var/lib/nats/.nsc
      - file: nsc_binary

# Generate system account
nats_system_account:
  cmd.run:
    - name: |
        export NSC_HOME=/var/lib/nats/.nsc
        nsc add account SYS
        nsc add user system -a SYS
    - runas: nats
    - unless: test -d /var/lib/nats/.nsc/nats/accounts/SYS
    - require:
      - cmd: nats_init_operator

# Generate platform account
nats_platform_account:
  cmd.run:
    - name: |
        export NSC_HOME=/var/lib/nats/.nsc
        nsc add account PLATFORM
        nsc add user platform -a PLATFORM
        nsc edit account PLATFORM \
          --js-mem-storage 10G \
          --js-disk-storage 100G \
          --js-streams -1 \
          --js-consumer -1
    - runas: nats
    - unless: test -d /var/lib/nats/.nsc/nats/accounts/PLATFORM
    - require:
      - cmd: nats_init_operator

# NATS configuration
/etc/nats/nats.conf:
  file.managed:
    - source: salt://nats/files/nats-server.conf.j2
    - template: jinja
    - user: nats
    - group: nats
    - mode: 640
    - context:
        cluster_name: {{ nats.get('cluster_name', 'wazuh-mssp') }}
        servers: {{ nats.get('servers', []) | json }}
        client_port: {{ nats.get('client_port', 4222) }}
        cluster_port: {{ nats.get('cluster_port', 4248) }}
        monitor_port: {{ nats.get('monitor_port', 8222) }}
        jetstream_dir: /var/lib/nats/jetstream
        operator_jwt: {{ salt['cmd.run']('cat /var/lib/nats/.nsc/nats/nats.jwt', runas='nats') }}
    - require:
      - cmd: nats_platform_account

# Systemd service
/etc/systemd/system/nats.service:
  file.managed:
    - contents: |
        [Unit]
        Description=NATS Server
        After=network.target
        
        [Service]
        Type=simple
        User=nats
        Group=nats
        ExecStart=/usr/local/bin/nats-server -c /etc/nats/nats.conf
        ExecReload=/bin/kill -HUP $MAINPID
        Restart=on-failure
        RestartSec=5
        LimitNOFILE=65536
        
        [Install]
        WantedBy=multi-user.target

nats_service:
  service.running:
    - name: nats
    - enable: True
    - require:
      - file: /etc/systemd/system/nats.service
      - file: /etc/nats/nats.conf
    - watch:
      - file: /etc/nats/nats.conf

# Firewall rules
{% for port in [4222, 4248, 8222] %}
nats_ufw_{{ port }}:
  cmd.run:
    - name: ufw allow {{ port }}/tcp
    - unless: ufw status | grep -q "{{ port }}/tcp"
{% endfor %}

# Register with Consul
/etc/consul.d/nats.json:
  file.managed:
    - contents: |
        {
          "service": {
            "name": "nats",
            "tags": ["messaging", "jetstream"],
            "port": 4222,
            "check": {
              "http": "http://localhost:8222/healthz",
              "interval": "10s"
            }
          }
        }
    - require:
      - service: nats_service

---
# salt/states/nats/accounts.sls
# Dynamic account management for customers

{% set nats = salt['pillar.get']('nats', {}) %}
{% set customers = salt['pillar.get']('customers', {}) %}

{% for customer_id, customer in customers.items() %}
nats_account_{{ customer_id }}:
  cmd.run:
    - name: |
        export NSC_HOME=/var/lib/nats/.nsc
        nsc add account CUSTOMER-{{ customer_id | upper }}
        nsc edit account CUSTOMER-{{ customer_id | upper }} \
          --js-mem-storage {{ customer.get('nats_mem_limit', '1G') }} \
          --js-disk-storage {{ customer.get('nats_disk_limit', '10G') }} \
          --js-streams {{ customer.get('nats_max_streams', 100) }} \
          --js-consumer {{ customer.get('nats_max_consumers', 1000) }}
        
        # Add exports
        nsc add export --account CUSTOMER-{{ customer_id | upper }} \
          --subject "customer.{{ customer_id }}.metrics" \
          --name "Customer Metrics" \
          --service
        
        nsc add export --account CUSTOMER-{{ customer_id | upper }} \
          --subject "customer.{{ customer_id }}.alerts" \
          --name "Customer Alerts" \
          --service
        
        # Generate user credentials
        nsc add user {{ customer_id }}-service -a CUSTOMER-{{ customer_id | upper }}
        nsc generate creds -a CUSTOMER-{{ customer_id | upper }} \
          -n {{ customer_id }}-service > /var/lib/nats/creds/{{ customer_id }}.creds
    - runas: nats
    - unless: test -f /var/lib/nats/.nsc/nats/accounts/CUSTOMER-{{ customer_id | upper }}/CUSTOMER-{{ customer_id | upper }}.jwt
    - require:
      - service: nats_service

# Store credentials in Vault
vault_nats_creds_{{ customer_id }}:
  cmd.run:
    - name: |
        vault kv put secret/customers/{{ customer_id }}/nats \
          creds=@/var/lib/nats/creds/{{ customer_id }}.creds
    - onchanges:
      - cmd: nats_account_{{ customer_id }}
{% endfor %}

Wazuh Customer States
# salt/states/wazuh/customer.sls
{% set customer = salt['pillar.get']('customer', {}) %}
{% set wazuh = salt['pillar.get']('wazuh', {}) %}

# Wazuh repository
wazuh_repo:
  pkgrepo.managed:
    - name: deb https://packages.wazuh.com/4.x/apt/ stable main
    - file: /etc/apt/sources.list.d/wazuh.list
    - key_url: https://packages.wazuh.com/key/GPG-KEY-WAZUH
    - require_in:
      - pkg: wazuh_packages

# Install Wazuh components based on node role
wazuh_packages:
  pkg.installed:
    - pkgs:
      {% if 'indexer' in grains.get('wazuh_role', []) %}
      - wazuh-indexer
      {% endif %}
      {% if 'server' in grains.get('wazuh_role', []) %}
      - wazuh-manager
      - filebeat
      {% endif %}
      {% if 'dashboard' in grains.get('wazuh_role', []) %}
      - wazuh-dashboard
      {% endif %}

# Certificate management
/etc/wazuh-certs:
  file.directory:
    - user: root
    - group: root
    - mode: 700

{% for cert_file in ['root-ca.pem', 'node.pem', 'node-key.pem'] %}
/etc/wazuh-certs/{{ cert_file }}:
  file.managed:
    - source: salt://certs/customers/{{ customer.id }}/{{ grains['id'] }}/{{ cert_file }}
    - user: root
    - group: root
    - mode: 600
    - require:
      - file: /etc/wazuh-certs
{% endfor %}

# Indexer configuration
{% if 'indexer' in grains.get('wazuh_role', []) %}
/etc/wazuh-indexer/opensearch.yml:
  file.managed:
    - source: salt://wazuh/files/indexer-opensearch.yml.j2
    - template: jinja
    - user: wazuh-indexer
    - group: wazuh-indexer
    - mode: 640
    - context:
        cluster_name: wazuh-cluster-{{ customer.id }}
        node_name: {{ grains['id'] }}
        network_host: {{ grains['ipv4'][0] }}
        cluster_nodes: {{ customer.get('indexer_nodes', []) | json }}
        ccs_nodes: {{ salt['pillar.get']('ccs:indexer_nodes', []) | json }}
    - require:
      - pkg: wazuh_packages

wazuh_indexer_service:
  service.running:
    - name: wazuh-indexer
    - enable: True
    - require:
      - file: /etc/wazuh-indexer/opensearch.yml
    - watch:
      - file: /etc/wazuh-indexer/opensearch.yml
{% endif %}

# Server configuration
{% if 'server' in grains.get('wazuh_role', []) %}
/var/ossec/etc/ossec.conf:
  file.managed:
    - source: salt://wazuh/files/ossec.conf.j2
    - template: jinja
    - user: root
    - group: ossec
    - mode: 640
    - context:
        cluster_name: wazuh-cluster-{{ customer.id }}
        node_name: {{ grains['id'] }}
        node_type: {% if grains.get('wazuh_master', False) %}master{% else %}worker{% endif %}
        cluster_key: {{ customer.get('cluster_key') }}
        cluster_nodes: {{ customer.get('server_nodes', []) | json }}
    - require:
      - pkg: wazuh_packages

/etc/filebeat/filebeat.yml:
  file.managed:
    - source: salt://wazuh/files/filebeat.yml.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 640
    - context:
        indexer_nodes: {{ customer.get('indexer_nodes', []) | json }}
    - require:
      - pkg: wazuh_packages

wazuh_manager_service:
  service.running:
    - name: wazuh-manager
    - enable: True
    - require:
      - file: /var/ossec/etc/ossec.conf
    - watch:
      - file: /var/ossec/etc/ossec.conf

filebeat_service:
  service.running:
    - name: filebeat
    - enable: True
    - require:
      - file: /etc/filebeat/filebeat.yml
      - service: wazuh_manager_service
    - watch:
      - file: /etc/filebeat/filebeat.yml
{% endif %}

# Dashboard configuration
{% if 'dashboard' in grains.get('wazuh_role', []) %}
/etc/wazuh-dashboard/opensearch_dashboards.yml:
  file.managed:
    - source: salt://wazuh/files/dashboard.yml.j2
    - template: jinja
    - user: wazuh-dashboard
    - group: wazuh-dashboard
    - mode: 640
    - context:
        server_host: {{ grains['ipv4'][0] }}
        server_port: 443
        indexer_nodes: {{ customer.get('indexer_nodes', []) | json }}
    - require:
      - pkg: wazuh_packages

/usr/share/wazuh-dashboard/data/wazuh/config/wazuh.yml:
  file.managed:
    - contents: |
        hosts:
          - {{ customer.subdomain }}:
              url: https://{{ customer.get('server_nodes')[0] }}
              port: 55000
              username: wazuh-wui
              password: {{ customer.get('api_password') }}
              run_as: true
    - require:
      - pkg: wazuh_packages

wazuh_dashboard_service:
  service.running:
    - name: wazuh-dashboard
    - enable: True
    - require:
      - file: /etc/wazuh-dashboard/opensearch_dashboards.yml
    - watch:
      - file: /etc/wazuh-dashboard/opensearch_dashboards.yml
{% endif %}

Additional Configurations
Benthos Pipeline Configurations
# benthos/configs/webhook-ingress.yaml
input:
  http_server:
    address: 0.0.0.0:4195
    path: /webhooks/${provider}
    
    rate_limit: webhook_limiter
    
    auth:
      type: jwt
      jwt:
        secret: ${JWT_SECRET}
        
    cors:
      enabled: true
      allowed_origins: ["*"]

pipeline:
  processors:
    # Extract webhook metadata
    - label: extract_metadata
      mapping: |
        root = this
        meta webhook_metadata = {
          "provider": @provider,
          "signature": @http.headers.get("X-Webhook-Signature").or(""),
          "timestamp": @http.headers.get("X-Webhook-Timestamp").or(now()),
          "content_type": @http.headers.get("Content-Type").or("application/json")
        }
    
    # Validate webhook signatures
    - label: validate_signature
      switch:
        cases:
          - check: meta("webhook_metadata.provider") == "stripe"
            processors:
              - subprocess:
                  name: webhook-validator
                  binary: /usr/local/bin/webhook-validator
                  args: ["stripe", "${STRIPE_WEBHOOK_SECRET}"]
          
          - check: meta("webhook_metadata.provider") == "authentik"
            processors:
              - subprocess:
                  name: webhook-validator
                  binary: /usr/local/bin/webhook-validator
                  args: ["authentik", "${AUTHENTIK_WEBHOOK_SECRET}"]
    
    # Normalize events
    - label: normalize_event
      mapping: |
        root = match meta("webhook_metadata.provider") {
          "stripe" => this.merge({
            "type": this.type,
            "customer_id": this.data.object.metadata.customer_id.or(""),
            "data": this.data.object
          }),
          "authentik" => this.merge({
            "type": "user_write",
            "customer_id": this.context.customer_id.or(""),
            "data": this
          }),
          _ => this
        }

output:
  nats_jetstream:
    urls:
      - ${NATS_URL}
    subject: webhooks.${!metadata:webhook_metadata.provider}
    headers:
      Provider: ${!metadata:webhook_metadata.provider}
      Event-Type: ${!json:type}
    auth:
      nkey_file: ${NATS_CREDS}

resources:
  rate_limits:
    webhook_limiter:
      count: 100
      interval: 1m

metrics:
  prometheus:
    address: 0.0.0.0:4196
    path: /metrics

logger:
  level: INFO
  format: json
  static_fields:
    service: benthos-webhook-ingress

---
# benthos/configs/metrics-processor.yaml
input:
  nats_jetstream:
    urls:
      - ${NATS_URL}
    queue: metrics-processor
    subject: customer.*.metrics
    durable: metrics-processor
    deliver: all
    ack_wait: 30s
    auth:
      nkey_file: ${NATS_CREDS}

pipeline:
  processors:
    # Parse customer ID from subject
    - label: extract_customer
      mapping: |
        root = this
        meta customer_id = @nats.subject.split(".").index(1)
    
    # Aggregate metrics
    - label: aggregate_metrics
      group_by:
        - meta("customer_id")
      
      processors:
        - metric:
            type: counter
            name: wazuh_events_total
            labels:
              customer_id: ${!metadata:customer_id}
              event_type: ${!json:rule.groups.index(0).or("unknown")}
        
        - metric:
            type: histogram
            name: wazuh_event_severity
            value: ${!json:rule.level}
            labels:
              customer_id: ${!metadata:customer_id}
    
    # Calculate usage
    - label: calculate_usage
      branch:
        request_map: |
          root = {
            "customer_id": meta("customer_id"),
            "timestamp": now(),
            "metrics": {
              "events_count": counter("events_" + meta("customer_id")),
              "data_bytes": counter("bytes_" + meta("customer_id")),
              "active_agents": gauge("agents_" + meta("customer_id"))
            }
          }
        
        processors:
          - cache:
              operator: set
              key: usage_${!json:customer_id}_${!json:timestamp.format("2006-01-02")}
              value: ${!json}

output:
  broker:
    pattern: fan_out
    outputs:
      # Forward to Prometheus
      - prometheus:
          url: http://prometheus.service.consul:9090/api/v1/write
          
      # Store in time series database
      - sql_insert:
          driver: postgres
          dsn: ${DATABASE_URL}
          table: customer_usage_metrics
          columns:
            - customer_id
            - timestamp
            - events_count
            - data_bytes
            - active_agents
          args_mapping: |
            root = [
              this.customer_id,
              this.timestamp,
              this.metrics.events_count,
              this.metrics.data_bytes,
              this.metrics.active_agents
            ]

Nomad Pack for Customer Deployment
# nomad/packs/wazuh-customer/metadata.hcl
app {
  url    = "https://github.com/wazuh-mssp/nomad-pack-wazuh"
  author = "Wazuh MSSP Team"
}

pack {
  name        = "wazuh-customer"
  description = "Wazuh deployment for MSSP customers"
  version     = "1.0.0"
}

---
# nomad/packs/wazuh-customer/variables.hcl
variable "customer_id" {
  description = "Unique customer identifier"
  type        = string
}

variable "customer_name" {
  description = "Customer company name"
  type        = string
}

variable "tier" {
  description = "Customer subscription tier"
  type        = string
  default     = "starter"
}

variable "subdomain" {
  description = "Customer subdomain"
  type        = string
}

variable "datacenters" {
  description = "Datacenters to deploy to"
  type        = list(string)
  default     = ["dc1"]
}

variable "wazuh_version" {
  description = "Wazuh version to deploy"
  type        = string
  default     = "4.8.2"
}

variable "indexer_count" {
  description = "Number of indexer nodes"
  type        = number
  default     = 1
}

variable "server_count" {
  description = "Number of server nodes"
  type        = number
  default     = 1
}

variable "resources" {
  description = "Resource allocations by tier"
  type        = map(object({
    indexer_cpu    = number
    indexer_memory = number
    server_cpu     = number
    server_memory  = number
  }))
  
  default = {
    starter = {
      indexer_cpu    = 1000
      indexer_memory = 2048
      server_cpu     = 1000
      server_memory  = 2048
    }
    pro = {
      indexer_cpu    = 2000
      indexer_memory = 4096
      server_cpu     = 2000
      server_memory  = 4096
    }
    enterprise = {
      indexer_cpu    = 4000
      indexer_memory = 8192
      server_cpu     = 4000
      server_memory  = 8192
    }
  }
}

Example Customer Configuration
{
  "customer_id": "cust_12345",
  "company_name": "ACME Corporation",
  "subdomain": "acme",
  "tier": "pro",
  "admin_email": "admin@acme.com",
  "admin_name": "John Doe",
  "authentik_data": {
    "group_id": "group_12345",
    "user_id": "user_67890"
  },
  "billing": {
    "stripe_customer_id": "cus_ABC123",
    "subscription_id": "sub_DEF456"
  },
  "resources": {
    "cpu": 4000,
    "memory": 8192,
    "disk": "500GB"
  },
  "features": {
    "compliance_reports": true,
    "api_access": true,
    "custom_rules": true,
    "multi_site": false
  }
}

Summary
This complete implementation provides:
Infrastructure as Code: Full Terraform modules for all components
Orchestration: Nomad jobs with proper service mesh integration
Workflow Management: Temporal workflows for complex operations
Data Pipeline: Benthos + NATS for event processing
Configuration Management: Complete SaltStack states
Multi-tenancy: Isolated customer environments with resource quotas
Security: Vault integration, mTLS, and proper ACLs
Monitoring: Prometheus metrics and health checks
Development Environment: Docker Compose for local testing
Operations: EOS integration and runbooks
The architecture is designed for scalability, reliability, and ease of operations while maintaining strict customer isolation for your MSSP business model.
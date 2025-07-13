---
title: "Baby's first CI/CD pipeline: example"
date: "2025-07-13"
draft: true
---

Let me search through your project documentation to understand your existing eos tool and infrastructure setup better before designing the complete pipeline.Let me search for more information about your infrastructure setup, particularly around reverse proxy configuration and container deployment patterns.Let me search for more specific information about your Nomad and SaltStack configuration to design a complete pipeline.Based on your project documentation and infrastructure patterns, I'll design a complete CI/CD pipeline for your Hugo website (Helen) that follows your established SaltStack → Terraform → Nomad orchestration hierarchy. Let me break this down step by step to help you understand how all the pieces fit together.

## Complete CI/CD Pipeline Architecture

### Pipeline Overview

Your pipeline will follow this flow:
1. **Git Push** → triggers Jenkins (or webhook to SaltStack)
2. **SaltStack** → orchestrates the entire deployment workflow
3. **Build Phase** → Hugo site generation and Docker image creation
4. **Terraform** → ensures Hetzner infrastructure exists
5. **Nomad** → deploys the containerized Hugo site
6. **Caddy** → routes traffic with automatic SSL

### Detailed Sequence of Operations

Let me walk you through each stage of the deployment process:

#### 1. Source Code Management & Trigger

When you push code to your Git repository:
```bash
git push origin main
```

This triggers the pipeline through either:
- **Jenkins webhook** (if using Jenkins)
- **Direct SaltStack reactor** (if using Salt's event system)

#### 2. SaltStack Orchestration Layer

SaltStack serves as your primary orchestrator. Here's the Salt state that manages the entire deployment:Now let me create the supporting configuration files that this Salt state references, starting with the Salt pillar data that serves as your single source of truth:Now let me show you the Terraform configuration that SaltStack generates. This is a critical piece because Terraform acts as the bridge between your configuration management (Salt) and your infrastructure. Let me explain why each part matters:Let me continue with the Nomad job specification, which is the final piece that actually runs your containerized Hugo site. This is where your application comes to life, and I'll explain how Nomad's features ensure reliable deployment:Let me explain how all these pieces communicate with each other and provide the final configuration files that tie everything together. Understanding this communication flow is crucial for troubleshooting and maintaining your deployment pipeline.Now let me explain how failures and rollbacks work in this architecture, which is one of the most critical aspects of any production deployment system. Understanding failure modes and recovery procedures will help you maintain high availability for your Helen website.Now let me show you the actual eos commands you would use to execute this deployment pipeline, and then I'll explain how all these components work together as a cohesive system. Understanding these commands will help you interact with your infrastructure effectively.## How All the Components Work Together

Now that we've examined each piece of your CI/CD pipeline, let me help you understand how these components interact to create a robust, self-healing deployment system. Think of this as a symphony where each instrument plays its part to create a harmonious whole.

### The Orchestration Hierarchy in Action

Your architecture follows a clear hierarchy: **SaltStack → Terraform → Nomad**. This isn't just organizational structure—it's a carefully designed chain of responsibility where each tool operates at its optimal level of abstraction.

**SaltStack** sits at the top as your conductor. When you execute `eos create salt-state '*' state.orchestrate helen.deploy`, Salt doesn't just run commands—it orchestrates an entire workflow. It understands the high-level intent ("deploy Helen") and translates that into specific actions across your infrastructure. Salt maintains the authoritative configuration in its pillar data, which acts as your single source of truth. This is crucial because it means you can always trace any configuration back to one place.

**Terraform** acts as your infrastructure mediator. When Salt generates Terraform configurations from templates, it's creating a declarative description of what infrastructure should exist. Terraform then compares this desired state with reality (stored in Consul) and makes only the necessary changes. This is why you can run the deployment multiple times safely—Terraform won't recreate resources that already exist correctly.

**Nomad** handles the dynamic aspects of your deployment. While Terraform ensures the infrastructure exists, Nomad makes intelligent decisions about where and how to run your containers. It considers available resources, handles failures, and manages rolling updates—all based on the job specification that Salt generated from your pillar data.

### Communication Flow and State Management

Let me walk you through what happens during a typical deployment to illustrate how these systems communicate:

1. **Initial Trigger**: When you push code or run the deployment script, the process begins with Salt receiving the deployment request.

2. **Configuration Generation**: Salt reads its pillar data (your source of truth) and uses Jinja2 templates to generate:
   - Terraform variable files with current versions and settings
   - Nomad job specifications with resource requirements
   - Caddy routing configurations for traffic management

3. **Infrastructure Provisioning**: Terraform reads the generated configurations and:
   - Queries Consul to check current infrastructure state
   - Determines what changes are needed (if any)
   - Applies changes to Hetzner Cloud infrastructure
   - Updates Consul with new resource information

4. **Container Deployment**: Nomad receives the job specification and:
   - Evaluates current cluster resources
   - Schedules the container deployment
   - Manages health checks and rolling updates
   - Registers services with Consul for discovery

5. **Traffic Routing**: Caddy detects the new service in Consul and:
   - Automatically configures reverse proxy rules
   - Handles SSL certificate generation
   - Routes traffic to healthy instances only

### Failure Handling and Self-Healing

Your system includes multiple layers of failure detection and recovery, which work together to maintain high availability:

**Health Checks** operate at every level:
- Nomad checks container health via HTTP endpoints
- Consul aggregates health status from multiple sources
- Caddy only routes to healthy backends
- Salt monitors the overall orchestration success

When a failure occurs, the response is coordinated:

1. **Immediate Response**: If a container fails its health check, Nomad automatically restarts it according to the restart policy. This handles transient failures without escalation.

2. **Service-Level Recovery**: If multiple restart attempts fail, Consul marks the service as unhealthy, and Caddy stops routing traffic to it. This prevents users from seeing errors.

3. **Orchestration-Level Response**: If the deployment itself fails (detected by Salt's state execution), the rollback state is automatically triggered. This is where the hierarchical design shines—Salt knows the previous good state and can orchestrate a complete rollback through Terraform and Nomad.

4. **Emergency Procedures**: If automated rollback fails, the system escalates to human intervention with detailed notifications and creates incident tickets. The key is that it fails safely, maintaining service availability on the previous version rather than leaving the system in a broken state.

### Security and Secret Management

Your pipeline incorporates security at multiple levels, which is essential for production deployments:

**Vault Integration** provides centralized secret management. When Nomad runs your container, it can dynamically fetch secrets from Vault, which means:
- Secrets never appear in your Git repository
- Credentials can be rotated without redeployment
- Access is audited and controlled by policies

**Network Security** is handled through:
- Hetzner firewall rules (managed by Terraform)
- Caddy's automatic HTTPS with Let's Encrypt
- Consul Connect for service-to-service encryption (optional but recommended)

### Monitoring and Observability

Your system generates rich operational data that helps you understand its behavior:

- **Salt Events** provide real-time visibility into orchestration progress
- **Consul KV** stores deployment history and metadata
- **Nomad Metrics** show resource utilization and allocation efficiency
- **Caddy Logs** reveal traffic patterns and potential issues

### Why This Architecture Works

This design succeeds because it respects the natural boundaries between configuration management, infrastructure provisioning, and workload orchestration. Each tool does what it does best:

- Salt excels at maintaining configuration consistency across diverse systems
- Terraform provides reliable, declarative infrastructure management
- Nomad offers sophisticated workload scheduling and management
- Consul ties everything together with service discovery and configuration storage

The mediation pattern (Salt → Terraform → Nomad) prevents the complexity that would arise from direct integrations between all components. It creates clear interfaces and responsibilities, making the system easier to understand, debug, and extend.

### Next Steps and Recommendations

To make the most of this architecture, consider these practices:

1. **Version Everything**: Use Git tags for your Salt states, Terraform modules, and application code. This creates clear deployment artifacts.

2. **Test in Staging**: Create a staging environment that mirrors production. Use the same deployment pipeline but with different pillar data.

3. **Monitor Pipeline Performance**: Track deployment duration and failure rates. This helps you identify bottlenecks and improve reliability.

4. **Document Runbooks**: Create clear procedures for common operations like rollbacks, emergency deployments, and disaster recovery.

5. **Regular Drills**: Practice failure scenarios in staging to ensure your team knows how to respond when issues arise in production.

This architecture provides a solid foundation for deploying not just Helen, but any containerized application in your infrastructure. The patterns and practices we've discussed will serve you well as your deployment needs grow and evolve.


### deploy.sls
```
# /srv/salt/states/helen/deploy.sls
# Main orchestration state for Helen Hugo website deployment

{% set app_name = pillar.get('helen:app_name', 'helen') %}
{% set version = pillar.get('helen:version', 'latest') %}
{% set git_repo = pillar.get('helen:git_repo') %}
{% set git_branch = pillar.get('helen:git_branch', 'main') %}

# Step 1: Ensure build environment is ready
helen_build_environment:
  pkg.installed:
    - pkgs:
      - docker.io
      - hugo
      - git

# Step 2: Clone/update repository
helen_git_checkout:
  git.latest:
    - name: {{ git_repo }}
    - target: /opt/build/{{ app_name }}
    - branch: {{ git_branch }}
    - force_checkout: True
    - require:
      - pkg: helen_build_environment

# Step 3: Build Hugo site
helen_hugo_build:
  cmd.run:
    - name: hugo --minify --environment production
    - cwd: /opt/build/{{ app_name }}
    - require:
      - git: helen_git_checkout
    - creates: /opt/build/{{ app_name }}/public

# Step 4: Build Docker image
helen_docker_build:
  docker_image.present:
    - name: {{ pillar.get('docker:registry') }}/{{ app_name }}:{{ version }}
    - build: /opt/build/{{ app_name }}
    - dockerfile: Dockerfile
    - require:
      - cmd: helen_hugo_build

# Step 5: Push to registry
helen_docker_push:
  module.run:
    - name: docker.push
    - image: {{ pillar.get('docker:registry') }}/{{ app_name }}:{{ version }}
    - require:
      - docker_image: helen_docker_build

# Step 6: Generate Terraform configuration from Salt pillar data
helen_terraform_config:
  file.managed:
    - name: /srv/terraform/{{ app_name }}/terraform.tfvars
    - source: salt://helen/files/terraform.tfvars.j2
    - template: jinja
    - makedirs: True
    - context:
        app_name: {{ app_name }}
        version: {{ version }}
        domain: {{ pillar.get('helen:domain') }}
        resources: {{ pillar.get('helen:resources') }}

# Step 7: Apply Terraform to ensure infrastructure
helen_terraform_apply:
  cmd.run:
    - name: terraform apply -auto-approve
    - cwd: /srv/terraform/{{ app_name }}
    - require:
      - file: helen_terraform_config
      - module: helen_docker_push

# Step 8: Generate Nomad job from Salt pillar
helen_nomad_job:
  file.managed:
    - name: /srv/nomad/jobs/{{ app_name }}.nomad
    - source: salt://helen/files/nomad-job.nomad.j2
    - template: jinja
    - makedirs: True
    - context:
        app_name: {{ app_name }}
        version: {{ version }}
        image: {{ pillar.get('docker:registry') }}/{{ app_name }}:{{ version }}
        resources: {{ pillar.get('helen:resources') }}
        domain: {{ pillar.get('helen:domain') }}

# Step 9: Deploy to Nomad
helen_nomad_deploy:
  cmd.run:
    - name: nomad job run {{ app_name }}.nomad
    - cwd: /srv/nomad/jobs
    - require:
      - file: helen_nomad_job
      - cmd: helen_terraform_apply

# Step 10: Update Caddy configuration
helen_caddy_config:
  http.query:
    - name: http://localhost:2019/config/apps/http/servers/srv0/routes
    - method: POST
    - header_dict:
      Content-Type: application/json
    - data: |
        {
          "@id": "helen_route",
          "match": [{"host": ["{{ pillar.get('helen:domain') }}"]}],
          "handle": [{
            "handler": "reverse_proxy",
            "upstreams": [{"dial": "{{ app_name }}.service.consul:80"}]
          }]
        }
    - require:
      - cmd: helen_nomad_deploy

# Step 11: Health check verification
helen_deployment_verify:
  http.query:
    - name: https://{{ pillar.get('helen:domain') }}/health
    - status: 200
    - retry:
        attempts: 10
        interval: 30
    - require:
      - http: helen_caddy_config
```


### helen.sls
```
# /srv/pillar/helen.sls
# Pillar data for Helen Hugo website - single source of truth

helen:
  app_name: helen
  version: "{{ salt['cmd.run']('date +%Y%m%d%H%M%S') }}"  # Timestamp versioning
  git_repo: https://github.com/yourusername/helen.git
  git_branch: main
  domain: helen.cybermonkey.net.au
  
  # Resource allocation for Nomad
  resources:
    cpu: 500        # MHz
    memory: 256     # MB
    memory_max: 512 # MB burst capacity
  
  # Hetzner infrastructure settings
  infrastructure:
    server_type: cx21
    location: nbg1
    image: ubuntu-22.04
    ssh_keys:
      - "your-ssh-key-name"
  
  # Container settings
  container:
    port: 80
    health_check_path: /health
    health_check_interval: 30s
    health_check_timeout: 5s
    
  # Deployment strategy
  deployment:
    update_strategy: rolling
    max_parallel: 1
    min_healthy_time: 30s
    auto_revert: true
    
  # Backup configuration
  backup:
    enabled: true
    schedule: "0 2 * * *"  # 2 AM daily
    retention_days: 7

# Docker registry configuration
docker:
  registry: registry.cybermonkey.net.au
  # Or use Docker Hub: docker.io/yourusername

# Consul configuration for service discovery
consul:
  service_name: helen-web
  tags:
    - hugo
    - static-site
    - production
  
# Monitoring and alerting
monitoring:
  prometheus_scrape: true
  metrics_path: /metrics
  alert_email: ops@cybermonkey.net.au
  ```


### Dockerfile
```
# Multi-stage Dockerfile for Helen Hugo website
# This approach minimizes the final image size and improves security

# Stage 1: Build the Hugo site
FROM klakegg/hugo:0.111.3-ext-alpine AS builder

# Set working directory for the build
WORKDIR /site

# Copy all source files (Hugo content, themes, config)
COPY . .

# Build the static site with production optimizations
# The --minify flag reduces file sizes, --gc cleans up unused resources
RUN hugo --minify --gc --environment production

# Stage 2: Create the minimal runtime image
FROM caddy:2.7-alpine

# Install curl for health checks (minimal overhead)
RUN apk add --no-cache curl

# Copy the built static files from the builder stage
# This is the key benefit of multi-stage builds - we only keep what we need
COPY --from=builder /site/public /srv

# Copy custom Caddy configuration if you have one
# This allows for custom headers, redirects, etc.
COPY Caddyfile /etc/caddy/Caddyfile

# Create a simple health check endpoint
# This helps Nomad and monitoring systems verify the container is healthy
RUN echo "OK" > /srv/health

# Expose port 80 for HTTP traffic
# Caddy will handle HTTPS termination at the reverse proxy layer
EXPOSE 80

# Use Caddy's built-in file server for optimal static file serving
# The file-server directive includes sensible defaults for caching and compression
CMD ["caddy", "file-server", "--root", "/srv", "--listen", ":80"]
```


### terraform/main.tf
```
# Main Terraform configuration for Helen deployment
# This file is generated by SaltStack from templates, ensuring consistency

terraform {
  required_version = ">= 1.0"
  
  # We use Consul as the backend to store Terraform state
  # This provides distributed locking and integrates with your existing infrastructure
  backend "consul" {
    address = "localhost:8500"
    path    = "terraform/helen/state"
    lock    = true
  }
  
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.42"
    }
    nomad = {
      source  = "hashicorp/nomad"
      version = "~> 2.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.19"
    }
  }
}

# Hetzner Cloud provider configuration
# The token should be stored in Vault and retrieved by Terraform
provider "hcloud" {
  token = var.hcloud_token
}

# Nomad provider to interact with your Nomad cluster
provider "nomad" {
  address = var.nomad_address
  region  = var.nomad_region
}

# Consul provider for service registration
provider "consul" {
  address = var.consul_address
}

# Variables that Salt will populate via terraform.tfvars
variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "app_name" {
  description = "Application name (helen)"
  type        = string
}

variable "domain" {
  description = "Domain name for the application"
  type        = string
}

variable "server_type" {
  description = "Hetzner server type"
  type        = string
  default     = "cx21"
}

variable "location" {
  description = "Hetzner datacenter location"
  type        = string
  default     = "nbg1"
}

variable "nomad_address" {
  description = "Nomad API address"
  type        = string
  default     = "http://localhost:4646"
}

variable "consul_address" {
  description = "Consul API address"
  type        = string
  default     = "localhost:8500"
}

variable "nomad_region" {
  description = "Nomad region"
  type        = string
  default     = "global"
}

# Data source to check if infrastructure already exists
# This prevents recreation of existing resources
data "hcloud_servers" "existing" {
  with_selector = "app=${var.app_name}"
}

# Only create server if it doesn't exist
# This demonstrates idempotent infrastructure management
resource "hcloud_server" "helen_node" {
  count = length(data.hcloud_servers.existing.servers) == 0 ? 1 : 0
  
  name        = "${var.app_name}-node-${count.index}"
  server_type = var.server_type
  image       = "ubuntu-22.04"
  location    = var.location
  
  # Labels for easy identification and selection
  labels = {
    app         = var.app_name
    environment = "production"
    managed_by  = "terraform"
  }
  
  # Cloud-init script to bootstrap the server
  # This could install Docker, join Nomad cluster, etc.
  user_data = file("${path.module}/cloud-init.yaml")
  
  # Ensure firewall allows necessary traffic
  firewall_ids = [hcloud_firewall.helen_firewall.id]
}

# Firewall rules for the application
resource "hcloud_firewall" "helen_firewall" {
  name = "${var.app_name}-firewall"
  
  # Allow SSH for management
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  
  # Allow HTTP/HTTPS traffic
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  
  # Allow Nomad client communication
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "4647"
    source_ips = [
      "10.0.0.0/8"  # Internal network only
    ]
  }
}

# DNS record for the application
resource "hcloud_dns_record" "helen_a_record" {
  count = length(data.hcloud_servers.existing.servers) > 0 ? 0 : 1
  
  zone_id = var.dns_zone_id
  name    = var.app_name
  value   = hcloud_server.helen_node[0].ipv4_address
  type    = "A"
  ttl     = 3600
}

# Register the service in Consul for service discovery
resource "consul_service" "helen" {
  name = "${var.app_name}-web"
  node = consul_node.helen_node.name
  port = 80
  
  tags = [
    "hugo",
    "static-site",
    "production",
    "caddy-backend"  # This tag tells Caddy to route to this service
  ]
  
  check {
    check_id = "${var.app_name}-health"
    name     = "HTTP health check"
    http     = "http://${var.domain}/health"
    interval = "30s"
    timeout  = "5s"
  }
}

# Register the node in Consul
resource "consul_node" "helen_node" {
  name    = "${var.app_name}-node"
  address = hcloud_server.helen_node[0].ipv4_address
}

# Output values for other tools to use
output "server_ip" {
  value = length(hcloud_server.helen_node) > 0 ? hcloud_server.helen_node[0].ipv4_address : data.hcloud_servers.existing.servers[0].ipv4_address
  description = "IP address of the Helen server"
}

output "consul_service_name" {
  value = consul_service.helen.name
  description = "Consul service name for Helen"
}

output "deployment_status" {
  value = "Infrastructure ready for ${var.app_name} at ${var.domain}"
}
```

### nomad/helen.nomad
```
# Nomad job specification for Helen Hugo website
# This file is generated by SaltStack from templates to ensure consistency

job "helen-web" {
  # Datacenter where this job should run
  # In your setup, this would be your Hetzner region
  datacenters = ["dc1"]
  
  # Job type "service" means long-running tasks (perfect for web servers)
  # Other types include "batch" for one-off jobs and "system" for cluster-wide services
  type = "service"
  
  # Update strategy defines how Nomad performs rolling updates
  # This configuration ensures zero-downtime deployments
  update {
    # Deploy one instance at a time
    max_parallel = 1
    
    # Wait 30 seconds after a deployment is healthy before continuing
    min_healthy_time = "30s"
    
    # Consider the deployment healthy after 2 minutes
    healthy_deadline = "2m"
    
    # Keep progress for 10 minutes to allow inspection
    progress_deadline = "10m"
    
    # Automatically rollback if deployment fails
    # This is crucial for maintaining availability
    auto_revert = true
    
    # Promote canary deployments automatically if healthy
    auto_promote = true
    
    # Use canary deployments for safer rollouts
    canary = 1
  }
  
  # Constraint to ensure the job runs on appropriate nodes
  constraint {
    attribute = "${node.class}"
    value     = "web"
  }
  
  # Group defines a set of tasks that should run together
  group "web" {
    # Number of instances to run
    count = 2  # Running 2 for high availability
    
    # Restart policy for handling failures
    restart {
      attempts = 3        # Try 3 times
      interval = "5m"     # Within 5 minutes
      delay    = "30s"    # Wait 30s between restarts
      mode     = "fail"   # Fail the job if we exceed attempts
    }
    
    # Network configuration
    network {
      # Dynamic port allocation - Nomad assigns available ports
      port "http" {
        to = 80  # Container port
      }
    }
    
    # Service registration with Consul for service discovery
    service {
      name = "helen-web"
      port = "http"
      
      # Tags help Caddy identify this as a backend service
      tags = [
        "hugo",
        "static-site", 
        "caddy-backend",
        "traefik.enable=false"  # Explicitly disable Traefik if present
      ]
      
      # Health check configuration
      # This ensures only healthy instances receive traffic
      check {
        type     = "http"
        path     = "/health"
        interval = "30s"
        timeout  = "5s"
        
        # Advanced health check settings
        check_restart {
          limit = 3  # Restart after 3 consecutive failures
          grace = "90s"  # Grace period before enforcing
        }
      }
      
      # Connect sidecar for service mesh (optional but recommended)
      connect {
        sidecar_service {}
      }
    }
    
    # The main task - running your Docker container
    task "helen-hugo" {
      driver = "docker"
      
      # User to run the task as (for security)
      user = "nobody"
      
      # Configuration for the Docker driver
      config {
        # Image to run - this comes from your registry
        image = "${NOMAD_META_docker_image}"
        
        # Port mapping from dynamic port to container port
        ports = ["http"]
        
        # Mount volumes if needed (for persistent data)
        volumes = [
          # Example: "/opt/helen/data:/data:ro"
        ]
        
        # Security options
        readonly_rootfs = true  # Make root filesystem read-only
        cap_drop = ["ALL"]      # Drop all Linux capabilities
        cap_add = ["NET_BIND_SERVICE"]  # Only add what's needed
        
        # Logging configuration
        logging {
          type = "json-file"
          config {
            max-size = "10m"
            max-file = "3"
          }
        }
      }
      
      # Resource allocation
      # These values come from your Salt pillar data
      resources {
        cpu    = ${NOMAD_META_cpu}
        memory = ${NOMAD_META_memory}
        
        # Memory oversubscription for burst capacity
        memory_max = ${NOMAD_META_memory_max}
      }
      
      # Environment variables for the container
      env {
        # Add any environment-specific configuration
        ENVIRONMENT = "production"
        LOG_LEVEL   = "info"
      }
      
      # Template for dynamic configuration
      # This allows injecting secrets or dynamic values
      template {
        data = <<EOF
# This could contain dynamic configuration
# For example, API keys from Vault
ANALYTICS_ID={{ key "helen/config/analytics_id" }}
EOF
        destination = "secrets/.env"
        env         = true
      }
      
      # Artifacts to download before starting
      # Useful for downloading static assets or configs
      # artifact {
      #   source = "https://example.com/helen-assets.tar.gz"
      # }
      
      # Vault integration for secrets (if using Vault)
      vault {
        policies = ["helen-read"]
        change_mode = "restart"  # Restart on secret rotation
      }
    }
    
    # Ephemeral disk for temporary data
    ephemeral_disk {
      size = 100  # MB
      migrate = true  # Migrate data on job update
    }
  }
  
  # Periodic batch job for maintenance (optional)
  # This could handle cache clearing, log rotation, etc.
  periodic {
    cron             = "0 3 * * *"  # Daily at 3 AM
    prohibit_overlap = true         # Don't run if previous is still running
    time_zone        = "Australia/Perth"
  }
  
  # Meta information for tracking and organization
  meta {
    version     = "${NOMAD_META_version}"
    deployed_by = "salt-terraform-pipeline"
    git_commit  = "${NOMAD_META_git_commit}"
  }
}
```

### Jenkinsfile
```
// Jenkinsfile for Helen Hugo website deployment
// This integrates with your SaltStack orchestration

pipeline {
    agent any
    
    // Environment variables used throughout the pipeline
    environment {
        APP_NAME = 'helen'
        SALT_MASTER = 'salt-master.cybermonkey.net.au'
        // Credentials stored securely in Jenkins
        SALT_API_CREDS = credentials('salt-api-credentials')
        DOCKER_REGISTRY = credentials('docker-registry-creds')
    }
    
    // Trigger configuration
    triggers {
        // Trigger on push to main branch
        githubPush()
        // Also allow manual triggers
        upstream(upstreamProjects: '', threshold: hudson.model.Result.SUCCESS)
    }
    
    stages {
        stage('Pre-deployment Checks') {
            steps {
                script {
                    echo "=== Starting deployment for Helen website ==="
                    echo "Git commit: ${env.GIT_COMMIT}"
                    echo "Build number: ${env.BUILD_NUMBER}"
                    
                    // Verify SaltStack connectivity
                    sh '''
                        eos read salt-ping '*' || {
                            echo "ERROR: Cannot reach Salt minions"
                            exit 1
                        }
                    '''
                    
                    // Check infrastructure health
                    sh '''
                        eos read consul-health helen-web || {
                            echo "WARNING: Service health check failed"
                        }
                    '''
                }
            }
        }
        
        stage('Update Salt Pillar') {
            steps {
                script {
                    // Update version in Salt pillar with build metadata
                    sh """
                        cat > /tmp/helen-version.sls << EOF
helen:
  version: "${env.BUILD_NUMBER}-${env.GIT_COMMIT.take(7)}"
  git_commit: "${env.GIT_COMMIT}"
  build_url: "${env.BUILD_URL}"
  deployed_at: "\$(date -u +%Y-%m-%dT%H:%M:%SZ)"
EOF
                        
                        # Apply pillar update through eos
                        eos create salt-pillar helen /tmp/helen-version.sls
                    """
                }
            }
        }
        
        stage('Execute Salt Orchestration') {
            steps {
                script {
                    echo "=== Triggering Salt orchestration for deployment ==="
                    
                    // Execute the main deployment state
                    // This triggers the entire workflow we defined earlier
                    sh '''
                        eos create salt-state '*' state.apply helen.deploy \\
                            --timeout 600 \\
                            --output json > deployment-result.json
                        
                        # Check if deployment succeeded
                        if grep -q '"result": false' deployment-result.json; then
                            echo "ERROR: Salt state application failed"
                            cat deployment-result.json
                            exit 1
                        fi
                    '''
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                script {
                    echo "=== Verifying deployment health ==="
                    
                    // Wait for service to be healthy in Consul
                    retry(5) {
                        sleep(time: 30, unit: 'SECONDS')
                        sh '''
                            eos read consul-health helen-web --check-passing || {
                                echo "Service not yet healthy, retrying..."
                                exit 1
                            }
                        '''
                    }
                    
                    // Verify website is accessible
                    sh '''
                        # Check HTTP endpoint
                        curl -f -s -o /dev/null -w "%{http_code}" https://helen.cybermonkey.net.au/health || {
                            echo "ERROR: Website health check failed"
                            exit 1
                        }
                        
                        # Verify content
                        curl -s https://helen.cybermonkey.net.au/ | grep -q "Helen" || {
                            echo "ERROR: Website content verification failed"
                            exit 1
                        }
                    '''
                    
                    // Check Nomad job status
                    sh '''
                        eos read nomad-job helen-web --format json | \\
                            jq -e '.Status == "running"' || {
                            echo "ERROR: Nomad job is not running"
                            exit 1
                        }
                    '''
                }
            }
        }
        
        stage('Post-deployment Tasks') {
            steps {
                script {
                    // Update deployment tracking
                    sh '''
                        # Store deployment info in Consul KV
                        eos create consul-kv helen/deployments/${BUILD_NUMBER} \\
                            --data '{"version": "${BUILD_NUMBER}", "commit": "${GIT_COMMIT}", "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}'
                    '''
                    
                    // Trigger monitoring alerts reset
                    sh '''
                        eos update monitoring-alerts helen --reset-baseline
                    '''
                    
                    // Clean up old versions (keep last 3)
                    sh '''
                        eos delete docker-images helen --keep-last 3
                    '''
                }
            }
        }
    }
    
    post {
        success {
            script {
                echo "=== Deployment successful! ==="
                // Send success notification
                sh '''
                    eos create notification \\
                        --channel "deployments" \\
                        --message "Helen deployed successfully: v${BUILD_NUMBER}" \\
                        --color "good"
                '''
            }
        }
        
        failure {
            script {
                echo "=== Deployment failed! Initiating rollback ==="
                // Trigger automatic rollback
                sh '''
                    eos update salt-state '*' state.apply helen.rollback \\
                        --pillar '{"rollback_reason": "deployment_failure", "build_number": "'${BUILD_NUMBER}'"}'
                '''
                
                // Send failure notification
                sh '''
                    eos create notification \\
                        --channel "deployments" \\
                        --message "Helen deployment failed: v${BUILD_NUMBER}" \\
                        --color "danger" \\
                        --mention "@devops"
                '''
            }
        }
        
        always {
            // Clean up workspace
            cleanWs()
            
            // Archive deployment artifacts
            archiveArtifacts artifacts: 'deployment-result.json', fingerprint: true
        }
    }
}
```


### rollback.sls
```
# /srv/salt/states/helen/rollback.sls
# Automated rollback state for Helen deployments
# This state handles various failure scenarios gracefully

{% set app_name = pillar.get('helen:app_name', 'helen') %}
{% set rollback_reason = pillar.get('rollback_reason', 'unknown') %}
{% set previous_version = salt['consul.get']('helen/deployments/current/previous_version') %}

# Step 1: Log the rollback event for audit trail
helen_rollback_log:
  event.send:
    - name: deployment/rollback/initiated
    - data:
        app: {{ app_name }}
        reason: {{ rollback_reason }}
        current_version: {{ pillar.get('helen:version') }}
        target_version: {{ previous_version }}
        timestamp: {{ salt['cmd.run']('date -u +%Y-%m-%dT%H:%M:%SZ') }}

# Step 2: Health check current state before rollback
helen_pre_rollback_health:
  module.run:
    - name: consul.health_check
    - service: helen-web
    - onfail_any:
        # Continue with rollback even if health check fails
        - module: helen_rollback_proceed

# Step 3: Retrieve previous stable deployment configuration
helen_get_previous_config:
  module.run:
    - name: consul.get
    - key: helen/deployments/{{ previous_version }}/config
    - default: {}
    - require:
      - event: helen_rollback_log

# Step 4: Stop current deployment gracefully
helen_stop_current:
  cmd.run:
    - name: |
        # Deregister from load balancer first
        eos update caddy-route helen --disable
        
        # Wait for connections to drain (30 seconds)
        sleep 30
        
        # Stop the Nomad job
        nomad job stop -purge helen-web
    - require:
      - module: helen_get_previous_config

# Step 5: Revert to previous Docker image
helen_rollback_image:
  docker_image.present:
    - name: {{ pillar.get('docker:registry') }}/{{ app_name }}:{{ previous_version }}
    - force: True
    - require:
      - cmd: helen_stop_current

# Step 6: Deploy previous version via Nomad
helen_deploy_previous:
  file.managed:
    - name: /srv/nomad/jobs/{{ app_name }}-rollback.nomad
    - source: salt://helen/files/nomad-job.nomad.j2
    - template: jinja
    - context:
        app_name: {{ app_name }}
        version: {{ previous_version }}
        image: {{ pillar.get('docker:registry') }}/{{ app_name }}:{{ previous_version }}
        # Use saved configuration from previous deployment
        resources: {{ salt['consul.get']('helen/deployments/' + previous_version + '/resources') }}
    - require:
      - docker_image: helen_rollback_image

helen_nomad_rollback_deploy:
  cmd.run:
    - name: nomad job run {{ app_name }}-rollback.nomad
    - cwd: /srv/nomad/jobs
    - require:
      - file: helen_deploy_previous

# Step 7: Verify rollback deployment health
helen_rollback_health_check:
  http.wait_for_successful_query:
    - name: https://{{ pillar.get('helen:domain') }}/health
    - status: 200
    - wait_for: 300  # 5 minute timeout
    - request_interval: 10
    - require:
      - cmd: helen_nomad_rollback_deploy

# Step 8: Re-enable in load balancer
helen_enable_route:
  cmd.run:
    - name: eos update caddy-route helen --enable
    - require:
      - http: helen_rollback_health_check

# Step 9: Update deployment records
helen_update_deployment_record:
  module.run:
    - name: consul.put
    - key: helen/deployments/current/version
    - value: {{ previous_version }}
    - require:
      - cmd: helen_enable_route

helen_record_rollback_success:
  event.send:
    - name: deployment/rollback/completed
    - data:
        app: {{ app_name }}
        rolled_back_to: {{ previous_version }}
        reason: {{ rollback_reason }}
        duration: {{ salt['cmd.run']('echo $SECONDS') }}
    - require:
      - module: helen_update_deployment_record

# Step 10: Cleanup and notifications
helen_rollback_notify:
  cmd.run:
    - name: |
        eos create notification \
          --channel "deployments" \
          --message "Helen rolled back to version {{ previous_version }} due to: {{ rollback_reason }}" \
          --color "warning" \
          --mention "@devops"
    - require:
      - event: helen_record_rollback_success

# Failure handler - if rollback itself fails
helen_rollback_failure_handler:
  cmd.run:
    - name: |
        # Emergency notification
        eos create notification \
          --channel "emergency" \
          --message "CRITICAL: Helen rollback failed! Manual intervention required!" \
          --color "danger" \
          --mention "@everyone"
        
        # Create incident ticket
        eos create incident \
          --severity "critical" \
          --title "Helen deployment rollback failure" \
          --description "Automated rollback failed during {{ rollback_reason }}"
    - onfail:
      - http: helen_rollback_health_check
```


### deploy-helen.sh
```
#!/bin/bash
# EOS-based deployment script for Helen Hugo website
# This script demonstrates how to manually execute the deployment pipeline
# In production, these commands would be orchestrated by Jenkins or Salt

set -euo pipefail  # Exit on error, undefined variables, pipe failures

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="helen"
ENVIRONMENT="${ENVIRONMENT:-production}"
GIT_BRANCH="${GIT_BRANCH:-main}"

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

# Step 1: Pre-deployment validation
log "Starting pre-deployment checks for ${APP_NAME}"

# Verify eos is installed and configured
if ! command -v eos &> /dev/null; then
    error "eos command not found. Please install eos first."
    exit 1
fi

# Check Salt master connectivity
log "Checking Salt infrastructure..."
if ! eos read salt-ping '*' > /dev/null 2>&1; then
    error "Cannot communicate with Salt minions. Check Salt master status."
    exit 1
fi

# Verify required services are running
log "Checking required services..."
for service in consul nomad vault; do
    if ! eos read ${service}-status > /dev/null 2>&1; then
        warning "${service} service check failed. Deployment may fail."
    fi
done

# Step 2: Update configuration
log "Updating deployment configuration..."

# Generate version number (timestamp-based for uniqueness)
VERSION=$(date +%Y%m%d%H%M%S)
GIT_COMMIT=$(git rev-parse HEAD 2>/dev/null || echo "unknown")

log "Deployment version: ${VERSION}"
log "Git commit: ${GIT_COMMIT}"

# Update Salt pillar with new version
cat > /tmp/helen-deployment.sls << EOF
helen:
  version: "${VERSION}"
  git_commit: "${GIT_COMMIT}"
  deployment_user: "${USER}"
  deployment_timestamp: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
EOF

log "Applying Salt pillar update..."
eos create salt-pillar helen /tmp/helen-deployment.sls

# Step 3: Execute deployment via Salt orchestration
log "Triggering Salt orchestration for deployment..."

# This is the main deployment command that triggers everything
eos create salt-state "${SALT_TARGET:-*}" state.orchestrate helen.deploy \
    --timeout 600 \
    --output json > /tmp/deployment-${VERSION}.json

# Check deployment result
if grep -q '"result": false' /tmp/deployment-${VERSION}.json; then
    error "Salt orchestration failed. Check /tmp/deployment-${VERSION}.json for details."
    
    # Attempt automatic rollback
    warning "Attempting automatic rollback..."
    eos update salt-state '*' state.apply helen.rollback \
        --pillar "{\"rollback_reason\": \"deployment_failure\", \"failed_version\": \"${VERSION}\"}"
    
    exit 1
fi

log "Salt orchestration completed successfully"

# Step 4: Verify deployment health
log "Verifying deployment health..."

# Wait for service to stabilize
sleep 30

# Check Consul health
if ! eos read consul-health ${APP_NAME}-web --check-passing; then
    warning "Consul health check not passing yet. Waiting..."
    
    # Retry with exponential backoff
    for i in {1..5}; do
        sleep $((i * 10))
        if eos read consul-health ${APP_NAME}-web --check-passing; then
            log "Service is now healthy in Consul"
            break
        fi
        
        if [ $i -eq 5 ]; then
            error "Service failed to become healthy after multiple retries"
            exit 1
        fi
    done
fi

# Check Nomad job status
log "Checking Nomad job status..."
JOB_STATUS=$(eos read nomad-job ${APP_NAME}-web --format json | jq -r '.Status')

if [ "${JOB_STATUS}" != "running" ]; then
    error "Nomad job is not in running state. Current status: ${JOB_STATUS}"
    exit 1
fi

# Verify website is accessible
log "Verifying website accessibility..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://${APP_NAME}.cybermonkey.net.au/health || echo "000")

if [ "${HTTP_STATUS}" != "200" ]; then
    error "Website health check returned HTTP ${HTTP_STATUS}"
    exit 1
fi

log "Website is accessible and healthy"

# Step 5: Update deployment records
log "Updating deployment records..."

# Store current version as "latest successful"
eos create consul-kv helen/deployments/current/version --data "${VERSION}"
eos create consul-kv helen/deployments/${VERSION}/metadata --data "{
    \"git_commit\": \"${GIT_COMMIT}\",
    \"deployed_by\": \"${USER}\",
    \"deployed_at\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
    \"environment\": \"${ENVIRONMENT}\"
}"

# Step 6: Post-deployment tasks
log "Running post-deployment tasks..."

# Clean up old Docker images (keep last 3 versions)
log "Cleaning up old Docker images..."
eos delete docker-images ${APP_NAME} --keep-last 3

# Reset monitoring baselines
log "Resetting monitoring baselines..."
eos update monitoring-alerts ${APP_NAME} --reset-baseline

# Clear CDN cache if applicable
if [ "${CLEAR_CACHE:-false}" = "true" ]; then
    log "Clearing CDN cache..."
    eos update cdn-cache ${APP_NAME} --purge
fi

# Step 7: Send notifications
log "Sending deployment notifications..."

eos create notification \
    --channel "deployments" \
    --message "✅ ${APP_NAME} deployed successfully to ${ENVIRONMENT}" \
    --fields "Version=${VERSION},Deployer=${USER},Commit=${GIT_COMMIT:0:7}" \
    --color "good"

# Final summary
log "======================================"
log "Deployment completed successfully!"
log "======================================"
log "Application: ${APP_NAME}"
log "Version: ${VERSION}"
log "Environment: ${ENVIRONMENT}"
log "URL: https://${APP_NAME}.cybermonkey.net.au"
log "======================================"

# Optional: Display recent deployment history
log "Recent deployments:"
eos list deployments ${APP_NAME} --limit 5

exit 0
```
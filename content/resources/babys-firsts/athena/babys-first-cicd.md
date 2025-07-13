---
title: "Baby's first CI/CD pipeline"
date: "2025-07-13"
draft: true
---

Let me walk you through designing a comprehensive CI/CD workflow for your EOS tooling. I'll start with the conceptual foundation and build up to a practical command structure that follows industry best practices.

## Understanding the CI/CD Flow

Think of CI/CD as a factory assembly line for your software. Each stage performs specific quality checks and transformations, with clear handoff points between stages. The goal is to move changes from a developer's laptop to production in a controlled, repeatable, and safe manner.

The traditional flow looks like this:
```
Code → Build → Test → Package → Deploy → Verify → Promote → Monitor
```

Let's explore what commands you'll need to support this flow effectively.

## Core Command Categories

Based on industry best practices and your infrastructure needs, here's a comprehensive command structure:

### 1. Build Commands

These commands handle the initial transformation of your code into deployable artifacts:

```bash
# Build a specific component or all components
eos build [component] [--all] [--parallel]

# Validate build configuration without actually building
eos validate [component] [--strict]

# Clean build artifacts and caches
eos clean [--cache] [--artifacts] [--all]
```

The build stage is where you compile code, generate configuration files from templates, and create container images. For your Hecate infrastructure, this might generate Nomad job files from templates and build custom container images.

### 2. Environment Management Commands

Environments are isolated spaces where your applications run. Think of them as different worlds with their own rules:

```bash
# List all environments and their status
eos env list

# Show detailed information about an environment
eos env show [environment]

# Create or update an environment
eos env apply [environment] [--config-file=env.yaml]

# Connect to an environment (sets context)
eos env use [environment]
```

### 3. Deployment Commands

Deployment is the act of taking your built artifacts and running them in an environment:

```bash
# Deploy to the current environment
eos deploy [component] [--version=tag] [--strategy=blue-green|rolling|canary]

# Deploy with a specific configuration override
eos deploy [component] --values=custom-values.yaml

# Dry-run to see what would change
eos deploy [component] --dry-run

# Deploy multiple components in order
eos deploy-stack [stack-name] [--parallel=3]
```

Here's where it gets interesting. The deployment strategy determines how your new version replaces the old one:

- **Blue-Green**: Spin up a complete new version alongside the old, then switch traffic
- **Rolling**: Replace instances one by one
- **Canary**: Send a small percentage of traffic to the new version first

### 4. Promotion Commands

Promotion moves a tested deployment from one environment to another:

```bash
# Promote from one environment to another
eos promote [component] --from=staging --to=production

# Promote with approval workflow
eos promote [component] --from=staging --to=production --require-approval

# Promote a specific version
eos promote [component] --version=v1.2.3 --to=production

# Batch promotion of multiple components
eos promote-stack [stack-name] --from=staging --to=production
```

The key insight here is that promotion isn't deploying new code – it's taking something that's already proven to work in one environment and replicating that exact configuration in another environment.

### 5. Status and Monitoring Commands

Visibility into what's happening is crucial:

```bash
# Show status of all deployments
eos status [--environment=production] [--component=all]

# Show deployment history
eos history [component] [--limit=10]

# Watch a deployment in progress
eos watch [deployment-id]

# Get logs from a component
eos logs [component] [--tail=100] [--follow]

# Health check status
eos health [component] [--detailed]
```

### 6. Rollback and Recovery Commands

When things go wrong (and they will), you need quick recovery options:

```bash
# Rollback to previous version
eos rollback [component] [--steps=1]

# Rollback to a specific version
eos rollback [component] --to-version=v1.2.2

# Emergency rollback (skip health checks)
eos rollback [component] --emergency --force

# Create a snapshot before risky operations
eos snapshot create [environment] --name="before-upgrade"

# Restore from snapshot
eos snapshot restore [snapshot-name]
```

### 7. Configuration and Secrets Management

Configuration and secrets need special handling:

```bash
# Manage configuration values
eos config set [key] [value] --environment=production
eos config get [key] --environment=production
eos config list --environment=production

# Manage secrets (integrates with Vault)
eos secret set [path] [key=value] --environment=production
eos secret rotate [path] --all-environments

# Template configuration files
eos template render [template] --output=config.yaml
```

### 8. Pipeline Commands

For complex workflows, you need pipeline orchestration:

```bash
# Run a complete pipeline
eos pipeline run [pipeline-name] --watch

# Show pipeline definition
eos pipeline show [pipeline-name]

# Validate pipeline configuration
eos pipeline validate [pipeline-file]

# Pause/resume pipelines
eos pipeline pause [pipeline-name]
eos pipeline resume [pipeline-name]
```

## Putting It All Together

Let me show you how these commands work together in a typical workflow. Imagine you're deploying a new version of your Hecate infrastructure:

```bash
# 1. First, validate your changes
eos validate hecate-reverse-proxy --strict

# 2. Build the new version
eos build hecate-reverse-proxy --tag=v2.0.0

# 3. Deploy to development
eos env use development
eos deploy hecate-reverse-proxy --version=v2.0.0 --strategy=canary

# 4. Watch the deployment
eos watch deployment-123

# 5. Check health
eos health hecate-reverse-proxy --detailed

# 6. If healthy, promote to staging
eos promote hecate-reverse-proxy --from=development --to=staging

# 7. Run integration tests (automated via pipeline)
eos pipeline run integration-tests --environment=staging

# 8. Promote to production with approval
eos promote hecate-reverse-proxy --from=staging --to=production --require-approval

# 9. Monitor the production deployment
eos status --environment=production --watch

# 10. If issues arise, rollback
eos rollback hecate-reverse-proxy --emergency
```

## Implementation Architecture

Here's how you might structure the EOS tool internally:

```yaml
# ~/.eos/config.yaml
current_context: production
contexts:
  development:
    nomad_addr: http://nomad-dev.internal:4646
    consul_addr: http://consul-dev.internal:8500
    vault_addr: http://vault-dev.internal:8200
    
  staging:
    nomad_addr: http://nomad-staging.internal:4646
    consul_addr: http://consul-staging.internal:8500
    vault_addr: http://vault-staging.internal:8200
    
  production:
    nomad_addr: http://nomad-prod.internal:4646
    consul_addr: http://consul-prod.internal:8500
    vault_addr: http://vault-prod.internal:8200

defaults:
  deployment_strategy: rolling
  health_check_timeout: 300s
  rollback_on_failure: true
```

## Advanced Features to Consider

As your tooling matures, consider adding these advanced capabilities:

**Dependency Management**: Components often depend on each other. Your tool should understand these relationships:
```bash
eos deps show hecate-authentik
eos deploy hecate-authentik --with-dependencies
```

**Diff and Preview**: Show what will change before making changes:
```bash
eos diff --from=current --to=v2.0.0
eos plan deployment --component=hecate-reverse-proxy
```

**Batch Operations**: Operate on multiple components at once:
```bash
eos deploy-all --filter="tag=backend" --strategy=rolling
eos rollback-all --environment=staging --to-time="2 hours ago"
```

**GitOps Integration**: Tie deployments to git commits:
```bash
eos deploy --from-git=main --auto-tag
eos promote --from-pr=123
```

## Design Principles

As you build this tooling, keep these principles in mind:

1. **Idempotency**: Running the same command twice should be safe
2. **Dry-Run Everything**: Users should be able to preview changes
3. **Atomic Operations**: Operations should fully succeed or fully fail
4. **Audit Trail**: Every action should be logged with who, what, when, why
5. **Progressive Disclosure**: Simple tasks should be simple, complex tasks should be possible

The beauty of this design is that it scales from simple single-component deployments to complex multi-region, multi-environment orchestrations. Each command has a clear purpose and they compose together naturally.

Your EOS tool becomes the single interface through which all deployments flow, providing consistency, safety, and visibility across your entire infrastructure. This is how modern platforms teams enable developers to ship safely and quickly.
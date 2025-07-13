---
title: "Introduction to Hera"
date: "2025-07-13"
draft: true
---

Does authentik have terraform / salt stack / nomad modules/ integrations ?
Edit

Investigating authentik's integration with infrastructure management tools
4s
Let me search for current information about authentik's integrations with these infrastructure tools.

authentik terraform provider
10 results

Great! I found that authentik does have a Terraform provider.
1s

authentik salt stack integration module
10 results

From the search results, I can see that Salt Stack integrations with authentik are not direct
1s

authentik nomad integration
10 results

Investigated authentik's integration capabilities across different platforms.
7s
Based on my research, here's what I found about authentik's integrations with these infrastructure tools:
Terraform ✅
authentik has an official Terraform provider maintained by goauthentik that allows you to manage authentik resources through Terraform 
GitHub - goauthentik/terraform-provider-authentik: Manage https://goauthentik.io with terraform.
. The provider is available at:
GitHub Repository: https://github.com/goauthentik/terraform-provider-authentik
GitHub - goauthentik/terraform-provider-authentik: Manage https://goauthentik.io with terraform.
Terraform Registry: Available on the official Terraform Registry at registry.terraform.io/providers/goauthentik/authentik 
Terraform Registry
Terraform Registry
The Terraform provider allows you to manage various authentik resources including:
Applications and providers (OAuth2, SAML, LDAP, etc.)
Users, groups, and flows
Property mappings and policies
Outposts and other authentik components
Example usage includes creating SAML providers, applications, and configuring property mappings through Terraform code 
Integrate with SonarQube | authentik
.
Salt Stack ❌
There are no dedicated Salt Stack modules for authentik. What exists is:
Salt Stack can be used for general deployment and configuration management of authentik (like any other application) 
Authentik - docs.saltbox.dev
Salt has its own External Authentication System (eAuth) that supports PAM, LDAP, and other auth methods 
External Authentication System - Salt Project
, but this is for Salt's own authentication, not for integrating with authentik
You could potentially integrate authentik with Salt using authentik's LDAP provider, but there's no native Salt module for managing authentik resources
Nomad ❌
There are no specific Nomad integrations for authentik. From the search results:
Some users have deployed authentik on HashiCorp Nomad clusters
Can't copy AUTHENTIK_TOKEN from Outpost Deployment Info · Issue #1219 · goauthentik/authentik
, but this is just using Nomad as a container orchestrator
Nomad has its own workload identity system for Consul and Vault integration
identity block in the job specification | Nomad | HashiCorp Developer
, but no specific authentik integration
You would need to write your own Nomad job specifications to deploy authentik, similar to how you'd deploy any containerized application
Summary
Terraform: ✅ Full official support with a comprehensive provider
Salt Stack: ❌ No dedicated modules (deployment only)
Nomad: ❌ No specific integration (deployment only)
If you need infrastructure-as-code management for authentik, Terraform is currently your best option with its official provider. For Salt Stack and Nomad, you'd be limited to using them for deployment and basic configuration management rather than managing authentik resources programmatically.
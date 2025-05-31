---
title: "Internal Device and Endpoint Policy"
description: "Security and usage requirements for Code Monkey Cybersecurity devices and systems"
---

# Internal Device and Endpoint Policy

This policy outlines the responsibilities and requirements for anyone using devices or systems managed by or connected to Code Monkey Cybersecurity’s infrastructure.

It applies to all team members, contractors, and trusted contributors who access internal tools, data, or systems.

---

## Purpose

To ensure:

- Security of our internal systems and sensitive data
- Safe use of devices handling production or client data
- Compliance with our ethical and cybersecurity obligations

---

## Device Requirements

All work-related devices (laptops, desktops, mobile phones) **must**:

- Run an actively supported OS (e.g. Ubuntu LTS, macOS, Windows 11)
- Have full-disk encryption enabled
- Be configured to auto-lock after inactivity
- Use strong passwords and/or biometric authentication
- Have antivirus/EDR tooling installed (e.g. Wazuh agent, CrowdSec)
- Receive timely security updates and patches

---

## Network and Access

- VPN or Tailscale mesh is required to access internal services
- SSH keys must be rotated every 90 days
- Access to Vault, Delphi, or infrastructure must use role-based access control (RBAC) with MFA
- Endpoint logs may be collected for compliance and auditing

---

## Software and Tools

Approved tools include:

- Code editors (VS Code, JetBrains IDEs)
- Communication (Mattermost, email)
- Infrastructure (Docker, Terraform, QEMU/KVM)
- VPNs (Tailscale, WireGuard)

Unapproved or high-risk tools (e.g. cracked software, Tor, insecure proxies) are not permitted on managed devices.

---

## Device Lifecycle

- Devices must be wiped securely before reuse or disposal
- Staff must notify us if a device is lost, stolen, or compromised
- Temporary access devices must follow the same standards as primary systems

---

## Incident Reporting

Security events (e.g. malware detection, suspected intrusion) must be reported immediately to:

  **security@cybermonkey.net.au**

---

## Acknowledgement

By using a Code Monkey Cybersecurity-managed device, you agree to comply with this policy. Violations may lead to revoked access or other administrative actions.

---

Let’s keep our systems and community secure — together.

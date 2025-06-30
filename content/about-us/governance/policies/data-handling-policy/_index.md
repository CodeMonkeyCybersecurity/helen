---
title: "Data Handling Policy"
description: "How Code Monkey Cybersecurity manages and protects sensitive data."
---

# Data Handling & Retention Policy

This policy outlines how **Code Monkey Cybersecurity**, as a Managed Security Service Provider (MSSP) and MDR provider, manages, stores, retains, and secures sensitive data — including secrets, logs, telemetry, and client metadata — across all systems including **Hashicorp Vault**, **Delphi**, **Keycloak**, **Authentik**, and **Eos**.

---

## Data Classification

| Level         | Examples                                      | Safety                            |
|---------------|-----------------------------------------------|----------------------------------------|
| **Confidential** | Vault keys, client secrets, PII              | AES-256 encryption, RBAC, full audit   |
| **Internal**     | Metrics, configs, agent telemetry            | Scoped access, encrypted at rest       |
| **Public**       | Docs, source code, anonymized usage stats    | No restrictions                        |

---

## Vault & Secrets Management

- All secrets (TLS, API keys, LDAP creds) are managed via **HashiCorp Vault**
- Secrets are **versioned, expiring**, and optionally **audit-logged**
- Agent-based auth and **per-tenant RBAC** restrict human access
- Vault lifecycle (init, unseal, backup) is automated with `eos`

---

## Encryption: In Transit & At Rest

- **TLS 1.2-1.3** with modern ciphers for all transport
- **AES-256 encryption** at rest (LUKS/APFS/S3-SSE + GPG)
- Optional **append-only storage** (e.g. S3 Object Lock, ZFS snapshot)

---

## Retention & Enforcement

We retain logs long enough to support full incident investigation, forensic tracebacks, and regulatory compliance.

| Data Type                        | Default Retention     | Notes                                 |
|----------------------------------|------------------------|----------------------------------------|
| Authentication logs             | 24–36 months           | Required for forensics and audit       |
| Security alerts (Wazuh, AV, etc.) | 24–36 months          | Dwell time and pattern detection       |
| Endpoint & agent telemetry      | 12–24 months           | Includes Sysmon, Delphi                |
| Network flow logs               | 12 months              | NetFlow, Zeek for lateral tracing      |
| SIEM events / enrichments       | 24–36 months           | High-value alerting data               |
| Audit trails (Vault, Eos)       | 36 months              | Mandatory for compliance               |
| System/app logs (e.g. Docker)   | 90–180 days            | Rotated frequently                     |
| Incident artifacts              | With ticket lifecycle  | SLA- or client-driven duration         |
| Config backups                  | 180 days + annual snap | GPG-encrypted, offsite                 |

---

### Tiered Retention by Tenant

| Tier         | Retention Duration | Example Use Case              |
|--------------|--------------------|-------------------------------|
| Base         | 180 days           | NGOs, non-regulated orgs      |
| Standard     | 12 months          | Tech companies, education     |
| Compliance+  | 24 months          | PCI-DSS, ISO 27001, SOC 2     |
| Custom       | ≥ 36 months        | Healthcare, government, IRAP  |

---

## Lifecycle & Purging

- Expiry is enforced by `eos secure retention`
- All deletions are:
  - Logged and reviewed quarterly
  - Available for tenant audit
  - Optionally GPG-shredded
- Clients may request early purging post-termination

---

## Security & Compliance

| Area               | Control                                 |
|--------------------|------------------------------------------|
| **Access Control** | Per-tenant RBAC + 2FA + agent identity   |
| **Audit Logging**  | All admin/system access is logged        |
| **Client Isolation**| VMs, networks, and storage per tenant    |
| **Immutability**   | S3 Object Lock, ZFS snapshots available  |
| **Compliance**     | PCI, ISO 27001, IRAP, SOC 2-aligned      |

---

## Data Sharing

We **never sell** data.  
We share data **only if**:

- Required to deliver the service (e.g. SMTP provider)
- Mandated by law (e.g. subpoena)
- Explicitly authorized by the client

---

## Why Long Retention Matters

- APT dwell time exceeds **180+ days**
- Historical logs aid in **correlating new IOCs**
- Security is about **depth, not minimalism**
- Trust = Retain what matters, purge what doesn’t

---

## Contact

For custom SLAs, data inquiries, or opt-out requests:

[main@cybermonkey.net.au](mailto:main@cybermonkey.net.au)

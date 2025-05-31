---
title: "Responsible Disclosure Policy"
description: "How to report vulnerabilities to Code Monkey Cybersecurity"
---

# Responsible Disclosure Policy

At **Code Monkey Cybersecurity**, we welcome reports from security researchers and the community to help us keep our systems and our clients safe.

---

## Our Commitment

- We will respond promptly to valid reports.
- We will not take legal action against researchers who follow this policy.
- We will keep your report confidential unless you give us permission to disclose it.
- We will work with you to remediate verified issues.

---

## How to Report a Vulnerability

Please email your findings to:

  **security@cybermonkey.net.au**

Include the following (where possible):

- A detailed description of the issue
- Steps to reproduce (proof of concept appreciated)
- Your contact information (PGP available on request)

We aim to acknowledge reports within **3 business days**, and triage within **7 business days**.

---

## What’s In Scope

We’re especially interested in:

- Authentication issues (SSO, Vault access, Keycloak misconfigurations)
- Authorization flaws (e.g. tenant boundary violations)
- Information leakage (e.g. logs, metadata)
- Injection vulnerabilities (e.g. XSS, SQLi, command injection)
- Configuration or deployment issues (e.g. insecure defaults, hardcoded secrets)

---

## What’s Not in Scope

- Denial-of-service (DoS) or rate-limiting issues
- Spam or social engineering attacks
- Issues requiring physical access
- Reports without actionable security relevance

---

## Coordinated Disclosure

Please allow us reasonable time to fix the issue before any public disclosure.
We’re happy to provide public thanks or attribution (if desired), and we may list contributors on our [Hall of Fame](../hall-of-fame.md).

If you responsibly disclose an issue that leads to a meaningful security improvement, we may also:

- Offer a bounty (case-by-case)
- Provide a CVE or public credit

---

Thank you for helping us build a safer and more ethical cybersecurity platform.

# Helen

Company website: Hugo static site for Cybermonkey Ethical Technologies.

## Commands

```bash
hugo server --buildDrafts    # Dev server with drafts
hugo server --port 1313      # Dev on specific port
hugo --minify                # Production build
docker-compose up -d         # Docker deployment (port 8009)
```

## Governing contracts

**IMPORTANT:** Read the relevant contract before starting any work.

Compact ruleset (60 rules, always loaded): @third_party/prompts/GOVERNANCE-SUMMARY.md

All governance contracts vendored from `cybermonkey/prompts` at `third_party/prompts/`:

| Contract | File | Governs |
|----------|------|---------|
| Session workflow | @third_party/prompts/SOAPIER.md | 14-step SOAPIER process |
| Documentation | @third_party/prompts/DOCUMENTATION.md | Diataxis, frontmatter, naming |
| Testing | @third_party/prompts/TESTING.md | 70/20/10, coverage, evidence |
| Git Rules | @third_party/prompts/GIT-RULES.md | Signing, linear history |
| Security | @third_party/prompts/SECURITY.md | Secrets, OWASP, SLSA |

## Architecture

- **Hugo Extended 0.128.0+** with SCSS via Hugo Pipes
- **Go-first:** Prefer Hugo's Go-based templating over JS/Node tools
- **Progressive enhancement:** All functionality works without JavaScript
- Content: `content/posts/` (blog), `content/docs/` (pages), `content/docs/training/` (scam education)
- Templates: `layouts/`, Assets: `assets/`, Static: `static/`
- Config: `config.toml`, Base URL: `https://cybermonkey.net.au`

## Writing Style

**Target audience:** Home users, small businesses, community groups (not IT professionals)
**Tone:** Approachable, helpful, confidence-building — never intimidating

**Prohibited:** "Military-grade", "threat intelligence", "killchain", "cyber warfare", padlock symbols, FUD
**Preferred:** "Easy to use", "helps you stay safe", "practical tools", "peace of mind"

**References:** ~1 citation per 100 words from reputable sources. Work citations naturally into narrative flow. Blog content serves as basis for social media posts.

## Cross-repo work

If a fix or issue belongs in a different cybermonkey repo:
1. Create the issue in the **target repo** first (`tea issues create --title`)
2. Use the **cross-repo ISoBAR template** from `third_party/prompts/COORDINATION.md`
3. Cross-link issues bidirectionally

Repo inventory: moni (backend, vhost11), hecate (gateway, vhost7), contracts (data contracts), aphrodite (UI), prompts (governance)

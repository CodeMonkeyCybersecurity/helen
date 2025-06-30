---
title: "Example Feature Card Usage"
draft: true
---

# Example of Feature Card Usage

## Method 1: Using the feature-card-wrapper shortcode

You can wrap any content in a feature card like this:

{{< feature-card-wrapper eyebrow="DELPHI.AI" title="Meet Delphi Notify" cta-label="Learn More" cta-url="/offerings/delphi/" cta-style="teal" >}}

**Delphi Notify** is our flagship XDR security platform that provides:

- Real-time threat detection
- Human-reviewed alerts
- Plain English explanations
- 24/7 monitoring

Perfect for small businesses who want enterprise-level security without the complexity.

{{< /feature-card-wrapper >}}

{{< feature-card-wrapper eyebrow="BACKUP.AI" title="Persephone Backups" cta-label="Explore Backups" cta-url="/offerings/persephone/" cta-style="primary" >}}

Automated, secure backups that just work. Set it and forget it.

{{< /feature-card-wrapper >}}

## Method 2: Creating feature content files

Create files in `content/features/` with this frontmatter:

```yaml
---
title: "Meet Claude Opus 4"
eyebrow: "CLAUDE.AI"
summary: "Claude Opus 4, our most intelligent AI model, is now available."
cta:
  label: "Talk to Claude"
  url: "https://claude.ai/"
  style: "primary"
weight: 10
---
```

Then display them all with:

```
{{< card-feature-list section="features" >}}
```
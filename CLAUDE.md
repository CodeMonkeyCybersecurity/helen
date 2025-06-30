# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Hugo-based static website for Code Monkey Cybersecurity, a cybersecurity company based in Fremantle, Western Australia. The site promotes their "Delphi Notify" XDR/SIEM security service and follows a transparency-focused approach with dual licensing (AGPL v3 and Do No Harm License).

## Development Commands

### Local Development
```bash
# Start development server with drafts enabled
hugo server --buildDrafts

# Start development server on specific port
hugo server --port 1313

# Build for production
hugo --minify
```

### Docker Deployment
```bash
# Build and serve via Docker (accessible on port 8009)
docker-compose up -d

# Stop Docker deployment
docker-compose down
```

### Hugo Installation
```bash
# Install Hugo Extended (Linux)
./install-hugo.sh

# Manual installation (requires Hugo Extended 0.128.0+)
# Download from https://github.com/gohugoio/hugo/releases/latest
```

## Architecture Overview

### Core Technology Stack
- **Hugo Extended 0.128.0+** - Static site generator
- **Hugo Book Theme** - Managed as git submodule in `themes/hugo-book/`
- **SCSS** - Styling with Hugo's asset pipeline
- **Docker + Nginx** - Production deployment

### Directory Structure
- `content/` - Markdown content files
  - `content/posts/` - Blog posts (used to track Facebook/LinkedIn posts and company news)
  - `content/docs/` - Main documentation and service pages
  - `content/docs/industries/` - Industry-specific landing pages (Healthcare, Legal, Retail)
  - `content/docs/training/` - Scam education and phishing training content
  - `content/docs/delphi/` - Delphi Notify product information and sign-up flows
  - `content/docs/governance/` - Company policies and compliance documentation

### Blog Strategy
The `/posts/` section serves dual purposes:
1. **Public blog** for company news, achievements, and industry insights
2. **Social media tracking** - content often repurposed for Facebook/LinkedIn posts
3. **SEO content marketing** - industry-specific articles and case studies

**Blog content types:**
- Company milestones (Microsoft partnership, Chamber membership, directory listings)
- Security awareness articles and tips
- Case studies and customer success stories
- Industry news and commentary
- Product updates and feature announcements
- `layouts/` - Hugo HTML templates and partials
- `assets/` - Source assets (SCSS, JavaScript)
- `static/` - Static files (images, fonts)
- `public/` - Generated site output (excluded from git)

### Key Configuration
- `config.toml` - Main Hugo configuration
- `go.mod` - Go module dependencies
- `docker-compose.yml` - Container orchestration
- Base URL: `https://cybermonkey.net.au`

### Theme Management
The Hugo Book theme is included as a git submodule. When working with the theme:
```bash
# Initialize submodules after cloning
git submodule update --init --recursive

# Update theme
git submodule update --remote themes/hugo-book
```

### Content Features
- Mathematical notation support (KaTeX)
- Diagram rendering (Mermaid)
- Search functionality with JSON index
- Custom Hugo shortcodes for interactive elements
- Multi-theme support (light/dark/auto)

### Build Process
Hugo handles asset compilation automatically:
- SCSS compilation via Hugo Pipes
- JavaScript minification and bundling
- Search index generation (JSON output format)
- Sitemap and RSS feed generation

### Development Notes
- Always use `hugo server --buildDrafts` for local development to see draft content
- The site generates JSON search index accessible at `/index.json`
- Custom shortcodes are available in `layouts/shortcodes/`
- Static assets should be placed in `static/` directory
- All content uses Markdown with Hugo frontmatter

## Writing Style Guidelines

### Tone and Language
- **Target audience**: Home users, small businesses, and community groups (not enterprise IT professionals)
- **Tone**: Approachable, helpful, and confidence-building rather than intimidating
- **Avoid**: Military terminology, threat-focused language, imposing costs, "cyber warfare" rhetoric
- **No padlock emojis or symbols** - use friendly alternatives like , 🏠, 🛠️, 
- **Focus on empowerment** rather than fear-based messaging

### Prohibited Terms/Phrases
- ❌ "Military-grade" or "Enterprise-grade" (use "reliable" or "professional-quality")
- ❌ "Threat intelligence" or "killchain" 
- ❌ "Cyber warfare" or aggressive security terminology
- ❌ Padlock symbols  🔐 (use alternatives)
- ❌ Fear-inducing language about costs or consequences

### Preferred Language
-  "Easy to use" instead of "enterprise-ready"
-  "Helps you stay safe" instead of "defends against threats"
-  "Practical tools" instead of "security arsenal"
-  "Peace of mind" instead of "threat mitigation"
-  Focus on positive outcomes and user empowerment

### Reference Guidelines
- **Blog posts require citations**: Include approximately one reference/link per 100 words
- **Use reputable sources**: Link to research studies, industry reports, government data, established news outlets
- **Reference integration**: Work citations naturally into the narrative flow
- **Social media ready**: Blog content serves as basis for Facebook, LinkedIn, and Instagram posts
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Hugo-based static website for Code Monkey Cybersecurity, a cybersecurity company based in Fremantle, Western Australia. The site promotes their "Delphi Notify" XDR/SIEM security service and follows a transparency-focused approach with dual licensing (AGPL v3 and Do No Harm License).

### Ghost CMS Integration
The project includes a Ghost CMS deployment for managing blog content:
- **Database**: SQLite3 (production-ready, simplified deployment)
- **Port**: 8009 (exposed for Caddy reverse proxy)
- **Mail**: Mailcow SMTP integration
- **Deployment**: Nomad with persistent host volumes
- **No Traefik**: Direct port exposure, TLS handled by Caddy

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

### Ghost CMS Deployment
```bash
# Deploy Ghost with SQLite (production)
./deploy-ghost-sqlite.sh

# View logs
nomad alloc logs -f <alloc-id> ghost

# Backup Ghost data
./nomad/backup-sqlite.sh

# Restore from backup
./nomad/restore-sqlite.sh <timestamp>
```

### Docker Troubleshooting
```bash
# Check container status and restart behavior
docker ps -a

# View container logs for debugging
docker logs <container-name>

# Follow container logs in real-time
docker logs -f <container-name>

# Restart specific service
docker-compose restart <service-name>

# Rebuild and restart all services
docker-compose down && docker-compose up -d

# Remove volumes and rebuild (WARNING: destroys data)
docker-compose down -v && docker-compose up -d
```

### Database Configuration Best Practices
**SQLite Configuration (Ghost CMS)**:
- Always specify full database file path: `database__connection__filename`
- Enable null handling: `database__useNullAsDefault: 'true'`
- Disable debug logging in production: `database__debug: 'false'`
- Use persistent volumes for data directory: `/var/lib/ghost/content`

**Common Database Connection Issues**:
- Verify database client matches actual database type
- Check that database files/volumes are properly mounted
- Ensure container has write permissions to data directory
- Confirm database service dependencies are met

## Development Notes
- Always use `hugo server --buildDrafts` for local development to see draft content
- Use `hugo server` for development without draft posts
- Hugo handles all build processes natively without external dependencies

## Architecture Overview

### Core Technology Stack
**Hugo Extended 0.128.0+** - Static site generator
**SCSS** - Styling with Hugo's asset pipeline
**Docker + Nginx** - Production deployment

### Directory Structure
- `content/` - Markdown content files
  - `content/posts/` - Blog posts (used to track Facebook/LinkedIn posts and company news)
  - `content/docs/` - Main documentation and service pages
  - `content/docs/training/` - Scam education and phishing training content
  - `content/docs/delphi/` - Delphi Notify product information and sign-up flows
  - `content/docs/governance/` - Company policies and compliance documentation

### Blog Strategy
The `/posts/` section serves dual purposes:
1. **Public blog** for company news, achievements, and industry insights
2. **Social media tracking** - content often repurposed for Facebook/LinkedIn posts
3. **SEO content marketing** Industry-specific articles and case studies

**Blog content types:**
- Company milestones (Microsoft Founders Sponsorship, Chamber membership, directory listings)
- Security awareness articles and tips
- Case studies and customer success stories
Industry news and commentary
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
**Target audience**: Home users, small businesses, and community groups (not  IT professionals)
**Tone**: Approachable, helpful, and confidence-building rather than intimidating
**Avoid**: Military terminology, threat-focused language, imposing costs, "cyber warfare" rhetoric
**No padlock emojis or symbols** - use friendly alternatives like , , , 
**Focus on empowerment** rather than fear-based messaging

### Prohibited Terms/Phrases
"Military-grade" or "" (use "reliable" or "professional-quality")
"Threat intelligence" or "killchain" 
"Cyber warfare" or aggressive security terminology
Padlock symbols   (use alternatives)
Fear-inducing language about costs or consequences
FUD

### Preferred Language
"Easy to use" instead of "-ready"
"Helps you stay safe" instead of "defends against threats"
"Practical tools" instead of "security arsenal"
"Peace of mind" instead of "threat mitigation"
Focus on positive outcomes and user empowerment

### Reference Guidelines
**Blog posts require citations**: Include approximately one reference/link per 100 words
**Use reputable sources**: Link to research studies, industry reports, government data, established news outlets
**Reference integration**: Work citations naturally into the narrative flow
**Social media ready**: Blog content serves as basis for Facebook, LinkedIn, and Instagram posts

## Technical Implementation Philosophy

### Go-First Development Approach
**Primary technology preference**: Go language for all backend functionality
**Hugo integration**: Leverage Hugo's Go-based templating and processing capabilities
**Minimal external dependencies**: Avoid JavaScript, Python, Node.js when Go alternatives exist
**Build process**: Prefer Go-based tools and Hugo's native asset pipeline over complex build systems

### Language Priority Order
1. **Go** - Primary choice for all server-side logic, data processing, and Hugo templates
2. **Hugo templates** - Go-based templating for all HTML generation
3. **SCSS/CSS** - Styling only, compiled via Hugo Pipes
4. **HTML** - Semantic markup following accessibility standards
5. **JavaScript** - Only when absolutely necessary for client-side interactivity
6. **Other languages** - Avoid unless no Go-based alternative exists

### Development Constraints
**No unnecessary JavaScript**: Implement features using CSS-only solutions when possible
**Hugo-native functionality**: Use Hugo's built-in features before external tools
**Progressive enhancement**: Ensure all functionality works without JavaScript
**Go tooling**: Prefer Go-based development tools and utilities
**Simple deployment**: Maintain Hugo's static site generation advantages
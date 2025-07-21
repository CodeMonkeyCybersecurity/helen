# Hugo to Ghost Migration Plan
## Code Monkey Cybersecurity Website

### Executive Summary
This document outlines the comprehensive migration from Hugo static site to Ghost CMS while maintaining dual operation during transition. The migration will preserve all content, SEO value, and visual design while working within Ghost's content model.

---

## Phase 1: Pre-Migration Setup (Week 1)

### 1.1 Ghost Infrastructure Setup
- ✅ Ghost v5 running on Docker (port 2368)
- ✅ Custom theme v15 ready
- 🔄 Install and configure custom theme
- 🔄 Configure Ghost basic settings
- 🔄 Set up staging environment

### 1.2 Dual-Site Strategy Setup
```
Current:   Hugo → Nginx → Production (cybermonkey.net.au)
Target:    Hugo → Nginx → Production (cybermonkey.net.au)
           Ghost → Docker → Development (localhost:2368)

Phase 2:   Hugo → Nginx → Production (cybermonkey.net.au)
           Ghost → Nginx → Staging (staging.cybermonkey.net.au)

Phase 3:   Ghost → Nginx → Production (cybermonkey.net.au)
           Hugo → Archive (archive.cybermonkey.net.au)
```

### 1.3 Docker Compose Enhancement
```yaml
services:
  ghost:
    image: ghost:5-alpine
    restart: unless-stopped
    container_name: ghost-cms
    ports:
      - "2368:2368"
    environment:
      NODE_ENV: development  # Change to production later
      database__client: sqlite3
      url: http://localhost:2368  # Update for staging/prod
      mail__transport: SMTP  # Configure email
    volumes:
      - ghost-data:/var/lib/ghost/content
      - ./hugo-to-ghost/cybermonkey-ghost-theme-repo:/var/lib/ghost/content/themes/cybermonkey-ghost-theme
      - ./migration/assets:/var/lib/ghost/content/images  # For migrated images
    networks:
      - ghost-network

  # Optional: Add staging nginx proxy
  nginx-staging:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./nginx/staging.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - ghost
    networks:
      - ghost-network
```

---

## Phase 2: Content Analysis & Preparation (Week 2)

### 2.1 Content Inventory & Categorization

#### Blog Posts (9 posts)
- **Company News** (3 posts)
  - Chamber membership announcements
  - Business updates
  - Community engagement
- **Technical Guides** (4 posts)
  - Password manager guides
  - Privacy tools reviews
  - Security setup instructions
- **Industry News** (2 posts)
  - Industry commentary
  - Product reviews

#### Static Pages (35+ pages)
- **Core Pages**
  - Homepage (complex with shortcodes)
  - About Us (business info)
  - Contact (forms)
  - Services overview
- **Service Pages**
  - Delphi XDR platform (detailed product info)
  - Phishing simulation
  - Security consulting
- **Resources**
  - Educational content (5 phishing articles)
  - Documentation (Baby's Firsts series)
  - Case studies
  - FAQ sections
- **Governance**
  - 9 policy documents
  - Open source licensing
  - Accessibility statement

#### Assets
- **Images**: 30+ images (logos, featured images, certificates)
- **Fonts**: 4 font families
- **Documents**: PDFs and downloads

### 2.2 Hugo Shortcode Analysis & Ghost Conversion Strategy

| Hugo Shortcode | Frequency | Ghost Conversion Strategy |
|---|---|---|
| `card-unified` | High | Convert to Ghost cards or HTML blocks |
| `btn` | Medium | Convert to HTML with preserved CSS classes |
| `cta` | Medium | Convert to Ghost callout cards |
| `columns` | Medium | Convert to HTML with CSS Grid |
| `recent-posts` | Low | Use Ghost's related posts feature |
| `tabs` | Low | Convert to HTML with preserved JavaScript |
| `details` | Low | Convert to HTML summary/details |
| `grid` | Low | Convert to HTML with CSS Grid |
| `hint` | Low | Convert to Ghost callout cards |

### 2.3 Navigation Structure Mapping

#### Hugo Navigation (Hierarchical)
```
├── Services
│   ├── Delphi XDR
│   ├── Phishing Training
│   └── Consulting
├── Resources
│   ├── Education
│   ├── Documentation
│   ├── Case Studies
│   └── FAQ
├── About Us
│   ├── Our Story
│   ├── Governance
│   └── Contact
└── Blog
```

#### Ghost Navigation (Flat with grouping)
```
Services → /services/ (page with links to sub-services)
Resources → /resources/ (page with links to resources)
About → /about/
Blog → /blog/
Contact → /contact/
```

---

## Phase 3: Migration Scripts Development (Week 3)

### 3.1 Content Extraction Scripts

```bash
#!/bin/bash
# extract-hugo-content.sh

# Extract frontmatter and content from Hugo markdown files
python3 scripts/hugo-extractor.py \
  --source /Users/henry/Dev/helen/content \
  --output migration/extracted-content.json \
  --include-assets \
  --preserve-metadata
```

### 3.2 Ghost Import Script

```python
# ghost-importer.py
import requests
import json
from datetime import datetime

class GhostImporter:
    def __init__(self, ghost_url, admin_key):
        self.api_url = f"{ghost_url}/ghost/api/admin"
        self.headers = {
            'Authorization': f'Ghost {admin_key}',
            'Content-Type': 'application/json'
        }
    
    def import_posts(self, posts_data):
        # Convert Hugo posts to Ghost format
        # Handle frontmatter conversion
        # Upload featured images
        # Create posts with proper metadata
        pass
    
    def import_pages(self, pages_data):
        # Convert Hugo pages to Ghost pages
        # Handle shortcode conversion
        # Preserve URL structure where possible
        pass
    
    def import_assets(self, assets_path):
        # Upload images to Ghost
        # Update content references
        pass
```

### 3.3 Shortcode Conversion Engine

```python
# shortcode-converter.py
import re
from typing import Dict, Any

class ShortcodeConverter:
    def __init__(self):
        self.converters = {
            'card-unified': self.convert_card,
            'btn': self.convert_button,
            'cta': self.convert_cta,
            'columns': self.convert_columns,
            'tabs': self.convert_tabs,
            'hint': self.convert_hint,
            'details': self.convert_details,
        }
    
    def convert_card(self, shortcode_content: str) -> str:
        # Parse card parameters
        # Convert to Ghost card or HTML
        return ghost_card_html
    
    def convert_button(self, shortcode_content: str) -> str:
        # Extract button parameters
        # Generate HTML with preserved CSS classes
        return button_html
```

---

## Phase 4: Ghost Setup & Configuration (Week 4)

### 4.1 Ghost Installation & Theme Setup
```bash
# 1. Install custom theme
cd /Users/henry/Dev/helen/hugo-to-ghost/cybermonkey-ghost-theme-repo
./build.sh

# 2. Copy theme to Ghost
docker cp cybermonkey-ghost-theme.zip ghost-cms:/tmp/
docker exec ghost-cms bash -c "
  cd /var/lib/ghost/content/themes
  unzip -o /tmp/cybermonkey-ghost-theme.zip
  chown -R node:node cybermonkey-ghost-theme/
"

# 3. Restart Ghost and activate theme
docker restart ghost-cms
```

### 4.2 Ghost Configuration

#### Admin Settings (Ghost Admin UI)
- **General Settings**
  - Site title: "Code Monkey Cybersecurity"
  - Description: "Cybersecurity. Now with Humans | Phishing awareness training..."
  - Site URL: http://localhost:2368 (staging)
  - Email: admin@cybermonkey.net.au
- **Design Settings**
  - Logo: favicon.png
  - Cover image: cover_puppy_moni_monkey_optimized.jpg
  - Accent color: #a625a4
- **Navigation Setup**
  - Primary: Services, Resources, About, Blog, Contact
  - Secondary: Privacy Policy, Terms, Accessibility
- **Code Injection**
  - Site header: Analytics, font loading
  - Site footer: Additional scripts if needed

#### Ghost Features Configuration
- **Members & Subscriptions**: Enable for future newsletter
- **Email Settings**: Configure SMTP for member emails
- **Integrations**: Set up necessary webhooks
- **Labs**: Enable any experimental features needed

### 4.3 Asset Migration
```bash
# Copy all static assets
mkdir -p migration/assets
cp -r /Users/henry/Dev/helen/static/images/* migration/assets/
cp -r /Users/henry/Dev/helen/static/favicon.png migration/assets/
cp -r /Users/henry/Dev/helen/static/fonts/* migration/assets/

# Resize images for Ghost (if needed)
python3 scripts/resize-images.py migration/assets/
```

---

## Phase 5: Content Migration Execution (Week 5-6)

### 5.1 Migration Order
1. **Assets first** (images, files)
2. **Static pages** (about, services, resources)
3. **Blog posts** (with proper dating)
4. **Navigation structure**
5. **URL redirects setup**

### 5.2 Content Conversion Process

#### Step 1: Extract Hugo Content
```bash
python3 scripts/hugo-extractor.py \
  --content-dir /Users/henry/Dev/helen/content \
  --output migration/hugo-content.json \
  --include-frontmatter \
  --process-shortcodes
```

#### Step 2: Convert Shortcodes
```bash
python3 scripts/shortcode-converter.py \
  --input migration/hugo-content.json \
  --output migration/converted-content.json \
  --preserve-styling
```

#### Step 3: Upload to Ghost
```bash
python3 scripts/ghost-importer.py \
  --input migration/converted-content.json \
  --ghost-url http://localhost:2368 \
  --admin-key YOUR_GHOST_ADMIN_KEY \
  --dry-run  # Test first
```

### 5.3 Content Mapping Strategy

#### Blog Posts Conversion
```
Hugo Post → Ghost Post
├── frontmatter.title → post.title
├── frontmatter.date → post.published_at
├── frontmatter.author → post.author
├── frontmatter.tags → post.tags
├── frontmatter.categories → post.tags (merged)
├── frontmatter.description → post.meta_description
├── frontmatter.featured_image → post.feature_image
└── content (converted) → post.html
```

#### Page Conversion
```
Hugo Page → Ghost Page
├── frontmatter.title → page.title
├── frontmatter.description → page.meta_description
├── frontmatter.weight → page.sort_order
├── URL structure → page.slug (simplified)
└── content (converted) → page.html
```

### 5.4 URL Preservation & SEO

#### URL Mapping
```
Hugo URLs → Ghost URLs
/blog/post-name/ → /blog-post-name/
/about-us/ → /about/
/services/delphi/ → /delphi/
/resources/education/ → /security-education/
```

#### Redirect Setup (nginx)
```nginx
# Add to nginx config
location /about-us/ { return 301 /about/; }
location /services/delphi/ { return 301 /delphi/; }
location /resources/education/ { return 301 /security-education/; }
```

---

## Phase 6: Testing & Validation (Week 7)

### 6.1 Content Validation Checklist
- [ ] All blog posts migrated with correct dates
- [ ] All pages accessible and properly formatted
- [ ] Images loading correctly
- [ ] Navigation working
- [ ] Search functionality (if implemented)
- [ ] Contact forms working
- [ ] SEO metadata preserved
- [ ] Site performance acceptable

### 6.2 Design Validation
- [ ] Theme matches Hugo design
- [ ] Responsive design working
- [ ] Typography consistent
- [ ] Color scheme correct
- [ ] Button hover animations (lift only)
- [ ] Card layouts preserved

### 6.3 Functionality Testing
- [ ] Ghost admin interface working
- [ ] Member signup (if enabled)
- [ ] Comment system (if enabled)
- [ ] RSS feeds generating
- [ ] Sitemap generation
- [ ] Email notifications working

---

## Phase 7: Staging Deployment (Week 8)

### 7.1 Staging Environment Setup
```yaml
# staging-docker-compose.yml
services:
  ghost-staging:
    image: ghost:5-alpine
    environment:
      NODE_ENV: production
      url: https://staging.cybermonkey.net.au
      database__client: sqlite3
      mail__transport: SMTP
      mail__options__host: smtp.example.com
    volumes:
      - ghost-staging-data:/var/lib/ghost/content
    networks:
      - staging-network

  nginx-staging:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/staging.conf:/etc/nginx/conf.d/default.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - ghost-staging
```

### 7.2 Staging Migration
1. Deploy staging environment
2. Run full content migration
3. Configure SSL certificates
4. Set up monitoring
5. Run comprehensive testing

---

## Phase 8: Production Deployment (Week 9)

### 8.1 Production Cutover Plan
```
Day 1: 
- Deploy Ghost production
- Import all content
- Set up monitoring

Day 2-3:
- Parallel testing (Hugo + Ghost)
- User acceptance testing
- Performance validation

Day 4:
- DNS/proxy cutover
- Hugo → backup mode
- Ghost → production mode

Day 5-7:
- Monitor for issues
- Fix any problems
- Optimize performance
```

### 8.2 Rollback Procedures
```bash
# Quick rollback to Hugo
# 1. Update nginx config
cp nginx/hugo-production.conf /etc/nginx/sites-available/cybermonkey.conf
nginx -s reload

# 2. Restore DNS if changed
# 3. Communicate to stakeholders
```

---

## Risk Mitigation

### High-Risk Items
1. **Content Loss**: Full backups before migration
2. **SEO Impact**: Comprehensive redirect mapping
3. **Downtime**: Dual-site strategy prevents downtime
4. **Design Differences**: Thorough theme testing
5. **Functionality Loss**: Feature gap analysis completed

### Contingency Plans
1. **Migration Failure**: Keep Hugo as fallback
2. **Performance Issues**: Optimize Ghost configuration
3. **User Issues**: Provide training documentation
4. **Technical Problems**: Maintain development environment for testing

---

## Success Metrics

### Technical Metrics
- [ ] 100% content migrated successfully
- [ ] <500ms page load times
- [ ] All URLs redirected properly
- [ ] Zero broken links
- [ ] Mobile responsiveness maintained

### Business Metrics
- [ ] No SEO ranking drops
- [ ] User feedback positive
- [ ] Admin workflow acceptable
- [ ] Email functionality working
- [ ] Lead generation maintained

---

## Timeline Summary

| Week | Phase | Key Deliverables |
|------|-------|------------------|
| 1 | Setup | Ghost configured, theme installed |
| 2 | Analysis | Content inventory, conversion strategy |
| 3 | Scripts | Migration tools built and tested |
| 4 | Configuration | Ghost fully configured |
| 5-6 | Migration | All content migrated |
| 7 | Testing | Full validation completed |
| 8 | Staging | Staging environment live |
| 9 | Production | Production cutover |

**Total Timeline: 9 weeks**

---

## Next Steps

1. **Immediate**: Set up Ghost with custom theme
2. **This Week**: Build migration scripts
3. **Next Week**: Start content migration
4. **Monitor**: Track progress against timeline

This plan provides a comprehensive roadmap for migrating from Hugo to Ghost while minimizing risk and preserving all valuable content and functionality.
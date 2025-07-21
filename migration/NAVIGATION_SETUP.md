# Ghost Navigation Setup Guide

## ✅ Content Reorganization Complete

Successfully reorganized **32 pages** with the following structure:

### 🏠 Main Website Pages
- `/about/` - About Us & Company Info  
- `/contact/` - Contact Information
- `/services/` - Pricing & Services
- `/accessibility/` - Accessibility Statement

### 📘 Delphi Product Pages  
- `/delphi/` - Main Delphi Overview
- `/delphi-notify/` - Delphi Notify Features
- `/delphi-roadmap/` - Product Roadmap
- `/delphi-technology/` - Technology Overview
- `/delphi-docs/` - Technical Documentation
- `/delphi-signup/` - Sign Up Process
- `/delphi-login/` - Customer Login

### 🎓 Resources & Training
- `/resources-guides/` - Security Guides & Checklists
- `/resources-training/` - Main Training Hub
- `/resources-training-phishing/` - Phishing Training
- `/resources-training-simulation/` - Phishing Simulation
- `/resources-training-phishing-awareness/` - Awareness Training
- `/resources-training-phishing-success/` - Training Success
- `/resources-case-studies/` - Customer Success Stories
- `/resources-education/` - Security Education
- `/resources-faq/` - Frequently Asked Questions
- `/resources-comparisons/` - Solution Comparisons
- `/resources-guides-bce-prevention/` - BEC Prevention Playbook

### 📋 Legal & Governance
- `/legal/` - Policies Overview
- `/legal-privacy/` - Privacy Policy
- `/legal-terms/` - Terms of Service
- `/legal-conduct/` - Code of Conduct
- `/legal-security/` - Security Policy
- `/legal-governance/` - Governance Framework
- `/legal-disclosure/` - Responsible Disclosure
- `/legal-data-handling/` - Data Handling Policy
- `/legal-device-policy/` - Device Policy
- `/legal-licensing/` - Open Source Licensing

### 🔧 Technical Documentation
- `/docs-api/` - API Documentation
- `/docs-ossec/` - OSSEC Configuration
- `/docs-agent-config/` - Agent Configuration
- `/docs-blocking/` - Malicious Actor Blocking
- `/docs-persephone/` - Persephone Documentation

## 🗂️ Manual Navigation Setup Required

Since Ghost navigation API is not available, please set up navigation manually:

### 1. Access Ghost Admin
Visit: http://localhost:2368/ghost/

### 2. Primary Navigation Setup
Go to **Settings → Navigation**

Configure these main menu items:
```
Home → /
About → /about/  
Delphi → /delphi/
Resources → /resources-guides/
Blog → / (Ghost posts)
Contact → /contact/
```

### 3. Secondary/Footer Navigation
Configure these secondary menu items:
```
Privacy → /legal-privacy/
Terms → /legal-terms/
Documentation → /delphi-docs/
Customer Login → /delphi-login/
```

### 4. Blog vs Website Content Distinction

**Blog Posts (28 total):**
- Remain at their current URLs (e.g., `/business-email-compromise-in-wa/`)
- Will be accessible through Ghost's native blog functionality
- Can be browsed at the root URL or through archive pages

**Website Pages (42 total):**
- Now organized with clear URL prefixes:
  - `/delphi-*` = Product pages
  - `/resources-*` = Resources and training
  - `/legal-*` = Policies and governance
  - `/docs-*` = Technical documentation
  - Root level = Main site pages

## 🎯 Content Strategy

### Blog Content
Use for:
- Company news and updates
- Industry insights and commentary  
- Security awareness articles
- Case studies and customer stories
- Product announcements

### Website Content
Use for:
- Static business information
- Product documentation
- Legal and policy pages
- Training materials
- Technical guides

## ✅ Next Steps

1. **Review reorganized content** - Check that all pages are accessible
2. **Set up navigation menus** - Follow manual setup instructions above
3. **Update internal links** - Review page content for any broken internal links
4. **Configure homepage** - Set up a proper homepage or landing page
5. **Test user journeys** - Ensure clear paths from landing to conversion

## 📊 Migration Summary

- ✅ **32 pages reorganized** with logical URL structure
- ✅ **2 duplicate pages removed** (cleaned up _index files)
- ✅ **Clear content hierarchy** established
- ✅ **Blog vs website distinction** clarified
- ✅ **SEO-friendly URLs** implemented

Your Ghost site now has a clean, organized structure that clearly separates blog content from business website content!
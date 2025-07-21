# Hugo to Ghost Migration Guide

## Overview

The migration tool has successfully exported 24 content items from your Hugo site. Here's what you need to complete the migration to Ghost.

## Import Process

1. **Import the JSON file**
   - Log into your Ghost admin panel
   - Navigate to Settings → Labs
   - Under "Import content", upload `ghost-export.json`
   - Review the import summary

2. **Content Organization**
   - Blog posts (from `/content/blog/`) → imported as Ghost posts
   - Documentation pages → imported as Ghost pages
   - Review and adjust post/page types as needed

## Post-Migration Tasks

### 1. Images and Media

Your Hugo site stores images in `/static/`. You'll need to:

```bash
# Copy images to Ghost content directory
cp -r ../static/images/* /path/to/ghost/content/images/

# Update image paths in Ghost posts
# From: /images/filename.jpg
# To: /content/images/filename.jpg
```

### 2. URL Structure

Ghost uses a flatter URL structure. Set up redirects:

```json
{
  "^/resources/education/phishing/(.*)": "/phishing-$1",
  "^/resources/babys-firsts/(.*)": "/docs-$1",
  "^/services/delphi-notify/(.*)": "/delphi-notify-$1"
}
```

### 3. Custom Shortcodes

The following Hugo shortcodes were converted to HTML:
- `btn` → `<a class="button">`
- `card` → `<div class="card">`
- `grid` → `<div class="grid">`
- `cta` → `<div class="cta">`
- `section` → `<section>`

Apply CSS styling to match your original design.

### 4. Navigation Menu

Recreate your navigation structure in Ghost:
- Ghost Admin → Settings → Navigation
- Add menu items matching your Hugo menu structure

### 5. Theme Selection

Consider these Ghost themes that match your design philosophy:
- **Casper** - Clean, minimalist default theme
- **Edition** - Good for documentation sites
- **Solo** - Simple, focused theme

### 6. Missing Content

Some files had parsing issues:
- `/content/blog/proton_pass.md`
- `/content/resources/babys-firsts/delphi/api.md`
- Several configuration files

Review these manually and add to Ghost as needed.

## Verification Checklist

- [ ] All blog posts imported correctly
- [ ] Documentation pages converted to Ghost pages
- [ ] Images displaying properly
- [ ] Internal links working
- [ ] Navigation menu recreated
- [ ] SEO metadata preserved
- [ ] Tags and categories migrated
- [ ] Draft posts marked correctly

## Next Steps

1. **Test thoroughly** before going live
2. **Set up redirects** from old URLs
3. **Configure Ghost integrations** (analytics, newsletters)
4. **Update DNS** when ready to switch
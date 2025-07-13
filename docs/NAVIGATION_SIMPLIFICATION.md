# Navigation Simplification Recommendations

## Current Issues
1. URL mismatch: "Services" menu points to `/offerings/` but page title is "Pricing"
2. Resources has redundant child item pointing to same URL
3. Mixed terminology (offerings vs services)

## Recommended URL Structure

### Option 1: Simplified Flat Structure (Recommended)
```toml
[[menu.main]]
name = "Services"
url = "/services/"
weight = 10

[[menu.main]]
name = "Resources"
url = "/resources/"
weight = 20

[[menu.main]]
name = "About"
url = "/about/"
weight = 30

[[menu.main]]
name = "Blog"
url = "/blog/"
weight = 40

[[menu.main]]
name = "Contact"
url = "/contact/"
weight = 50
```

### Option 2: With Dropdown Menus
```toml
[[menu.main]]
name = "Services"
url = "/services/"
weight = 10
hasChildren = true

  [[menu.main]]
  parent = "Services"
  name = "Delphi Notify XDR"
  url = "/services/delphi/"
  weight = 11

  [[menu.main]]
  parent = "Services"
  name = "Phishing Training"
  url = "/services/training/"
  weight = 12

[[menu.main]]
name = "Resources"
url = "/resources/"
weight = 20
hasChildren = true

  [[menu.main]]
  parent = "Resources"
  name = "Documentation"
  url = "/resources/docs/"
  weight = 21

  [[menu.main]]
  parent = "Resources"
  name = "Security Education"
  url = "/resources/education/"
  weight = 22
```

## Changes Needed

1. **Rename directories:**
   - `/offerings/` → `/services/`
   - `/about-us/` → `/about/`
   - `/about-us/contact/` → `/contact/`

2. **Update content files:**
   - Change "Pricing" title to "Services" in `/services/_index.md`
   - Update all internal links

3. **Implement dropdown menus** (if chosen):
   - Add CSS for dropdown functionality
   - Update navigation template to handle nested menus

## Benefits
- Cleaner URLs
- Better navigation highlighting
- Consistent terminology
- Improved user experience
---
title: "Interactive Navbar Demo"
date: 2025-06-30
draft: true
---

# Alpine.js + Tailwind Dropdown Navbar

This page demonstrates the new interactive navigation system with Alpine.js dropdowns and responsive design.

## Features Implemented

### ✅ **Desktop Experience**
- **Hover Dropdowns**: Platform and Training menus appear on hover
- **Smooth Animations**: Fade and scale transitions for professional feel
- **Active States**: Current page highlighting with brand teal color
- **Clean Design**: Minimalist styling with generous whitespace

### ✅ **Mobile Experience**
- **Hamburger Menu**: Clean toggle animation between menu and close icons
- **Organized Sections**: Platform, Training, and main links grouped logically
- **Touch-Friendly**: Large tap targets and proper spacing
- **Slide Animations**: Smooth reveal/hide transitions

### ✅ **Dynamic Content**
- **Hugo Menu Integration**: All links driven by `config.toml` menu definitions
- **Flexible Structure**: Easy to add/remove menu items without code changes
- **Active State Logic**: Uses Hugo's `IsMenuCurrent` for proper highlighting
- **Descriptions**: Platform and Training items include helpful descriptions

## Menu Configuration

The navbar is powered by Hugo menus defined in `config.toml`:

```toml
[menu]
# Main navigation
[[menu.main]]
name = "Documentation"
url = "/docs/"
weight = 10

# Platform dropdown
[[menu.platform]]
name = "Delphi Notify"
url = "/docs/delphi/"
description = "XDR Security Platform"
weight = 10

# Training dropdown
[[menu.training]]
name = "Scam Education"
url = "/docs/training/"
description = "Protect against fraud"
weight = 10
```

## Interactive Elements

Try these interactions:

1. **Desktop**: Hover over "Platform" or "Training" to see dropdown menus
2. **Mobile**: Click the hamburger menu icon to reveal the mobile navigation
3. **Navigation**: Click any link to see active state highlighting
4. **Responsive**: Resize your browser to see the mobile/desktop transition

## Technical Benefits

- **Performance**: Alpine.js is lightweight (only ~15KB)
- **Accessibility**: Proper focus management and keyboard navigation
- **SEO Friendly**: All links are standard `<a>` tags, no JavaScript required for crawling
- **Maintainable**: Menu structure defined in configuration, not hardcoded in templates

The navbar maintains the minimalist design philosophy while providing rich interactivity for improved user experience.
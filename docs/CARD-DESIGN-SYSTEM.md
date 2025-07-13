# Card Design System

## Overview

This document describes the card design system implemented for Code Monkey Cybersecurity. Cards are interactive UI elements that group related content with consistent styling and behavior.

## Card Types

### 1. Feature Cards (`.card-feature`)
- **Purpose**: Large service/product cards
- **Characteristics**:
  - Colored borders (gold, purple, orange)
  - Full card is clickable
  - NO purple underline on hover
  - Prominent lift effect (4px) on hover
  - Used for: Main services like Delphi Notify XDR, Security Training, Backup Solutions

### 2. Indicator Cards (`.card-indicator`)
- **Purpose**: Trust signals and key information
- **Characteristics**:
  - Subtle background change on hover
  - Purple underline animation on title (H3 only)
  - More link-like behavior
  - Minimal lift effect (2px)
  - Used for: Australian Based, Open Source, Microsoft Partner badges

### 3. Content Cards (`.card-content`)
- **Purpose**: Blog posts, case studies, resources
- **Characteristics**:
  - Clean 1px borders
  - Subtle shadow on hover
  - NO purple underline
  - Small lift effect (2px)
  - Used for: Blog post previews, resource cards

### 4. Minor Cards (`.card-minor`)
- **Purpose**: Small utility cards for secondary information
- **Characteristics**:
  - Compact size
  - Minimal styling
  - Context-dependent underline behavior
  - Subtle hover effects
  - Used for: Small info boxes, secondary CTAs

## Implementation

### HTML Structure

```html
<!-- Feature Card -->
<a href="/offerings/delphi/" class="feature-card-link">
  <article class="card-feature card-gold">
    <h3>Delphi Notify XDR</h3>
    <p>Advanced threat detection...</p>
    <span class="feature-link">Learn More →</span>
  </article>
</a>

<!-- Indicator Card -->
<a href="/about-us/" class="indicator-link">
  <div class="card-indicator">
    <h3>Australian Based</h3>
    <p>Fremantle, WA • ABN 77 177 673 061</p>
  </div>
</a>

<!-- Content Card -->
<a href="/blog/post-title/" class="content-card-link">
  <article class="card-content">
    <div class="card-meta">Jan 10, 2025</div>
    <h3>Blog Post Title</h3>
    <p>Post excerpt...</p>
  </article>
</a>
```

### CSS Classes

- Wrapper classes: `.feature-card-link`, `.indicator-link`, `.content-card-link`, `.minor-card-link`
- Card classes: `.card-feature`, `.card-indicator`, `.card-content`, `.card-minor`
- Color modifiers: `.card-gold`, `.card-purple`, `.card-orange`

### Universal Hover System Integration

The universal hover system (purple underline animation) is selectively applied:
- **Excluded**: `.feature-card-link` (uses its own hover system)
- **Included**: `.indicator-link h3` (only the title gets underline)
- **Excluded**: `.content-card-link` (standard card behavior)

## Visual Hierarchy

1. **Feature Cards**: Most prominent, largest, colored borders
2. **Content Cards**: Medium prominence, clean design
3. **Indicator Cards**: Subtle but interactive, link-like behavior
4. **Minor Cards**: Least prominent, minimal styling

## Responsive Behavior

- Feature cards: 300px minimum width, responsive grid
- Indicator cards: 250px minimum width, responsive grid
- Content cards: Single column on mobile, 2-3 columns on larger screens

## Color Palette

- Gold borders: `#b66b02`
- Purple borders: `#a625a4`
- Orange borders: `#d77350`
- Purple underline: `$brand-purple`

## Maintenance

All card styles are centralized in `/assets/_cards-design-system.scss`. To add new card types or modify existing ones, update this file and follow the established patterns.
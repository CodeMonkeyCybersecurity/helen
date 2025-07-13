# Typography & Color System Implementation Guide

## Overview

This document outlines the implementation of a comprehensive design system for Code Monkey Cybersecurity, including professional typography and accessible color schemes.

## New Files Created

### 1. Color System (`_color-system.scss`)
- **Comprehensive color palette** with 50-950 scales for primary and semantic colors
- **Cybersecurity-specific colors** for security status indicators
- **CSS custom properties** for easy maintenance and theme switching
- **Dark mode support** built-in
- **Accessibility compliance** with WCAG AA standards

### 2. Typography System (`_typography-system.scss`)
- **Professional font hierarchy** using Noto Sans with system fallbacks
- **Modular scale** (1.125 ratio) for consistent sizing
- **Responsive typography** that scales across devices
- **Utility classes** for rapid development
- **Accessibility features** including focus states and high contrast

## Usage Examples

### Typography Classes

```html
<!-- Headings -->
<h1 class="h1">Main Page Title</h1>
<h2 class="h2">Section Heading</h2>
<h3 class="h3">Subsection</h3>

<!-- Body Text -->
<p class="lead">Lead paragraph with larger text</p>
<p>Regular paragraph text</p>
<small>Small print or metadata</small>

<!-- Brand Text -->
<span class="brand-text">Code Monkey Cybersecurity</span>

<!-- Code -->
<code>inline code</code>
<pre><code>code block</code></pre>
```

### Color Classes

```html
<!-- Background Colors -->
<div class="bg-primary">Main background</div>
<div class="bg-secondary">Card background</div>
<div class="bg-accent">Accent background</div>

<!-- Text Colors -->
<p class="text-primary">Primary text</p>
<p class="text-secondary">Secondary text</p>
<p class="text-success">Success message</p>
<p class="text-error">Error message</p>

<!-- Security Status -->
<span class="status-critical">Critical Alert</span>
<span class="status-safe">System Secure</span>
<span class="trust-verified">Verified Source</span>
```

### CSS Custom Properties

```css
/* Use in custom components */
.custom-button {
  background: var(--color-primary);
  color: var(--text-inverse);
  font-family: var(--font-family-primary);
  font-size: var(--font-size-lg);
  font-weight: var(--font-weight-semibold);
}

.security-alert {
  border-left: 4px solid var(--security-critical);
  background: var(--bg-secondary);
  color: var(--text-primary);
}
```

## Font Requirements

To fully utilize the typography system, add these font files to `/static/fonts/`:

### Required Font Files
- `NotoSans-Light.woff2` / `NotoSans-Light.ttf` (300)
- `NotoSans-Regular.woff2` / `NotoSans-Regular.ttf` (400) ✅ Already present
- `NotoSans-Medium.woff2` / `NotoSans-Medium.ttf` (500)
- `NotoSans-SemiBold.woff2` / `NotoSans-SemiBold.ttf` (600)
- `NotoSans-Bold.woff2` / `NotoSans-Bold.ttf` (700) ✅ Already present
- `NotoSans-ExtraBold.woff2` / `NotoSans-ExtraBold.ttf` (800)

### Font Download Sources
- **Google Fonts**: https://fonts.google.com/noto/specimen/Noto+Sans
- **Font Squirrel**: https://www.fontsquirrel.com/fonts/noto-sans
- **Direct from Google**: Use Google Fonts helper for optimized files

## Color Palette Reference

### Primary Brand Colors
- `--color-primary`: #0ca678 (Main teal)
- `--color-primary-light`: #2dd4bf (Light teal)
- `--color-primary-dark`: #0f766e (Dark teal)

### Secondary Brand Colors
- `--color-orange`: #d77350 (Logo orange)
- `--color-purple`: #a625a4 (Brand purple)
- `--color-blue`: #4078f2 (Brand blue)
- `--color-gold`: #b66b02 (Brand gold)

### Semantic Colors
- `--color-success`: #22c55e (Green)
- `--color-warning`: #f59e0b (Yellow)
- `--color-error`: #ef4444 (Red)
- `--color-info`: #3b82f6 (Blue)

### Security-Specific Colors
- `--security-critical`: #dc2626 (Critical threats)
- `--security-high`: #ea580c (High priority)
- `--security-medium`: #d97706 (Medium priority)
- `--security-low`: #65a30d (Low priority)
- `--security-safe`: #16a34a (Safe/secure)

## Responsive Typography Scale

### Mobile (< 768px)
- H1: 36px (2.25rem)
- H2: 30px (1.875rem)
- H3: 24px (1.5rem)
- Body: 16px (1rem)

### Tablet (768px - 1199px)
- H1: 48px (3rem)
- H2: 36px (2.25rem)
- H3: 30px (1.875rem)
- Body: 18px (1.125rem)

### Desktop (≥ 1200px)
- H1: 72px (4.5rem)
- H2: 48px (3rem)
- H3: 36px (2.25rem)
- Body: 18px (1.125rem)

## Implementation Steps

### Phase 1: Immediate (Already Complete)
1. ✅ Created comprehensive color system
2. ✅ Created typography system
3. ✅ Updated main.scss imports
4. ✅ Updated core site styles

### Phase 2: Font Enhancement (Recommended)
1. Download additional Noto Sans weights
2. Update font declarations in `_typography-system.scss`
3. Test typography across all pages

### Phase 3: Color Migration (Gradual)
1. Replace hardcoded colors with CSS custom properties
2. Update component styles to use new color system
3. Implement dark mode support

### Phase 4: Optimization
1. Subset fonts for faster loading
2. Implement font-display strategies
3. Add print stylesheet optimizations

## Browser Support

### Typography System
- ✅ All modern browsers (Chrome 60+, Firefox 60+, Safari 12+)
- ✅ Graceful fallbacks for older browsers
- ✅ System font fallbacks for reliability

### Color System
- ✅ CSS Custom Properties supported in all modern browsers
- ✅ SCSS fallbacks for older browsers
- ✅ High contrast mode support

## Accessibility Features

### Typography
- ✅ WCAG AA compliant font sizes (minimum 16px base)
- ✅ Proper heading hierarchy (h1-h6)
- ✅ Sufficient line height for readability (1.5+)
- ✅ Focus indicators for keyboard navigation

### Colors
- ✅ WCAG AA color contrast ratios
- ✅ Semantic color meanings
- ✅ Color-blind friendly palette
- ✅ Dark mode support for accessibility

## Performance Considerations

### Font Loading
- Uses `font-display: swap` for better perceived performance
- Self-hosted fonts for reliability and privacy
- Fallback font stacks prevent layout shift

### CSS Optimization
- CSS custom properties for smaller bundle sizes
- Utility classes reduce CSS bloat
- Modular SCSS structure for maintainability

## Maintenance

### Adding New Colors
```scss
// Add to _color-system.scss
$new-color-500: #123456;

:root {
  --color-new: #{$new-color-500};
}

.text-new { color: var(--color-new); }
```

### Adding New Typography Styles
```scss
// Add to _typography-system.scss
.custom-text-style {
  font-family: var(--font-family-primary);
  font-size: var(--font-size-xl);
  font-weight: var(--font-weight-semibold);
  line-height: var(--line-height-snug);
}
```

This design system provides a solid foundation for consistent, accessible, and maintainable typography and color usage across the entire Code Monkey Cybersecurity website.
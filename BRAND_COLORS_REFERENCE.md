# Code Monkey Cybersecurity - Brand Color Reference

## Exact Color Palette Implementation

Your custom brand colors have been implemented exactly as specified:

### 🎨 Primary Brand Colors

| Color | Hex Code | CSS Variable | Usage |
|-------|----------|--------------|-------|
| **Teal 7** (Main) | `#0ca678` | `--color-primary` | Main brand color, links, CTAs |
| **Green** | `#51a14f` | `--color-green` | Success states, security "safe" |
| **Purple** | `#a625a4` | `--color-purple` | Visited links, accent |
| **Blue** | `#4078f2` | `--color-blue` | Info states, accent |
| **Gold** | `#b66b02` | `--color-gold` | Warnings, medium priority |

### 🟠 Orange Variations

| Color | Hex Code | CSS Variable | Usage |
|-------|----------|--------------|-------|
| **Logo Orange** | `#d77350` | `--color-orange-logo` | Logo, branding |
| **Alt Orange** | `#da7756` | `--color-orange-alt` | High priority alerts |

### 🚨 Alert Color

| Color | Hex Code | CSS Variable | Usage |
|-------|----------|--------------|-------|
| **Alert Red** | `#e45549` | `--color-alert-red` | Critical alerts, errors |

### 🌫️ Neutral Colors (Text & Backgrounds)

| Color | Hex Code | CSS Variable | Usage |
|-------|----------|--------------|-------|
| **Primary Text** | `#141413` | `--text-primary` | Main body text |
| **Secondary Text** | `#393a42` | `--text-secondary` | Subheadings, metadata |
| **Tertiary Text** | `#a0a1a6` | `--text-tertiary` | Muted text, disabled |
| **Letters Color** | `#002a1e` | `--text-letters` | High contrast text |

### 🎭 Background Colors

| Color | Hex Code | CSS Variable | Usage |
|-------|----------|--------------|-------|
| **Website Background** | `#f0eee6` | `--bg-website` | Main site background |
| **Section Background** | `#e3dacc` | `--bg-section` | Content sections |
| **Light Background** | `#fdfbf9` | `--bg-primary` | Cards, panels |
| **Alt Light Background** | `#faf9f5` | `--bg-alt-primary` | Alternative surfaces |
| **Mint Section** | `#bcd1ca` | `--bg-mint-section` | Special sections |
| **Blue Section** | `#cbcadb` | `--bg-blue-section` | Special sections |
| **Highlight** | `#fff8d0` | `--bg-highlight` | Highlighted content |

### 🔘 Button Colors

| Color | Hex Code | CSS Variable | Usage |
|-------|----------|--------------|-------|
| **Button Type 1** | `#b9b2a7` | `--bg-button-primary` | Primary buttons |
| **Button Type 2** | `#cdc6b9` | `--bg-button-secondary` | Secondary buttons |

## 🔒 Security-Specific Colors

| Priority | Color | Hex Code | CSS Variable |
|----------|-------|----------|--------------|
| **Critical** | Red | `#e45549` | `--security-critical` |
| **High** | Orange | `#da7756` | `--security-high` |
| **Medium** | Gold | `#b66b02` | `--security-medium` |
| **Low** | Green | `#51a14f` | `--security-low` |
| **Safe** | Teal | `#0ca678` | `--security-safe` |

##  Trust Indicators

| Status | Color | Hex Code | CSS Variable |
|--------|-------|----------|--------------|
| **Verified** | Green | `#51a14f` | `--trust-verified` |
| **Warning** | Gold | `#b66b02` | `--trust-warning` |
| **Unknown** | Gray | `#a0a1a6` | `--trust-unknown` |

## 💻 Usage Examples

### In HTML Classes
```html
<!-- Backgrounds -->
<div class="bg-primary">Light background</div>
<div class="bg-section">Section background</div>
<div class="bg-mint-section">Mint section</div>

<!-- Text Colors -->
<p class="text-primary">Primary text</p>
<p class="text-secondary">Secondary text</p>
<span class="status-critical">Critical alert</span>

<!-- Security Status -->
<span class="status-safe">System secure</span>
<span class="trust-verified">Verified source</span>
```

### In CSS
```css
.custom-component {
  background: var(--bg-website);
  color: var(--text-primary);
  border: 1px solid var(--color-primary);
}

.security-alert {
  background: var(--bg-highlight);
  border-left: 4px solid var(--security-critical);
  color: var(--text-primary);
}

.brand-button {
  background: var(--bg-button-primary);
  color: var(--text-primary);
  border: 1px solid var(--color-primary);
}
```

## 🔄 Legacy Compatibility

All existing CSS variables are maintained for backward compatibility:
- `--accent-color` → `#0ca678` (teal 7)
- `--body-background` → `#f0eee6` (website background)
- `--gray-*` → Mapped to new neutral system

## ✅ Implementation Status

- ✅ All 22 custom brand colors implemented
- ✅ CSS custom properties created
- ✅ Utility classes generated
- ✅ Security-specific colors mapped
- ✅ Legacy compatibility maintained
- ✅ Typography system integrated

Your exact color palette is now fully implemented and ready to use across the entire website!
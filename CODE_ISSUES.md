# Code Issues & Refactoring Recommendations

## Current Issues That May Cause Surprising Behavior

### 1. **Duplicate Style Files**
- `main.scss` and `main-unified.scss` both exist
- `_typography-system.scss` and `_typography-unified.scss` have overlapping rules
- Multiple navigation files were created instead of refactoring

**Fix**: Delete unused files and consolidate into single sources

### 2. **Text Alignment Chaos**
- No global default, so elements inherit unpredictably
- Multiple places setting `text-align` without clear hierarchy
- Center alignment set in `_mixins.scss` but overridden elsewhere

**Fix**: Created `_global-defaults.scss` with clear rules

### 3. **Color System Fragmentation**
- Colors defined in multiple places
- Some files use hex values directly instead of variables
- CSS custom properties and SCSS variables mixed inconsistently

**Fix**: Enforce use of `$brand-*` variables from `_colors-unified.scss`

### 4. **Responsive Layout Issues**
- Main content doesn't consistently account for sidebar
- Footer alignment separate from main content
- No single source of truth for layout measurements

**Fix**: Created `_responsive-layout.scss` with unified approach

### 5. **Import Order Problems**
- No clear import hierarchy
- Some files depend on others but import order is random
- Mixins imported after they're needed

**Recommended Import Order**:
```scss
1. Global defaults
2. Variables (colors, spacing)
3. Mixins and functions
4. Base styles
5. Components
6. Utilities
```

### 6. **Specificity Wars**
- Using `!important` to fix cascade issues
- Overly specific selectors competing
- No clear specificity guidelines

**Fix**: Reduce specificity, use single classes where possible

### 7. **Missing Semantic HTML Classes**
- Using element selectors (h1, p) instead of classes
- Makes styling fragile and unpredictable
- Hard to override for specific cases

**Fix**: Add semantic classes like `.page-title`, `.section-heading`

### 8. **JavaScript Duplication**
- Navigation JavaScript inline in HTML
- No central script file
- Event handlers added multiple times

**Fix**: Create unified `navigation.js` file

### 9. **No Clear Component Boundaries**
- Styles leak between components
- No namespace convention
- Components can affect each other

**Fix**: Use BEM or similar naming convention

### 10. **Configuration Scattered**
- Breakpoints defined in multiple files
- Sizes and measurements not centralized
- No single configuration file

**Fix**: Create `_config.scss` with all settings

## Priority Fixes

1. **Delete duplicate files** - Remove confusion
2. **Centralize configuration** - Single source of truth
3. **Fix import order** - Predictable cascade
4. **Add semantic classes** - Reduce element selectors
5. **Document conventions** - Prevent future issues

## Files to Delete

- `/assets/main-unified.scss`
- `/assets/_typography-system.scss`
- `/assets/_color-system.scss` (already deleted)
- Any other duplicate style files

## Naming Conventions to Adopt

```scss
// Components
.nav-primary {}
.card-product {}

// Elements
.nav-primary__link {}
.card-product__title {}

// Modifiers
.nav-primary--dark {}
.card-product--featured {}

// States
.is-active {}
.is-loading {}
.has-error {}
```

This will prevent the surprising behaviors you're experiencing and make the codebase much more maintainable.
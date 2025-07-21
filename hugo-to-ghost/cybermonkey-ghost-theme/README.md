# Code Monkey Cybersecurity Ghost Theme

A clean, accessible Ghost theme that matches the design of the original Hugo site for Code Monkey Cybersecurity.

## Features

- **Responsive Design**: Mobile-first approach with sidebar navigation on desktop
- **Accessibility**: High contrast colors, semantic HTML, keyboard navigation
- **Search**: Client-side search functionality
- **Custom Components**: Cards, buttons, CTAs matching the original design
- **Performance**: Minimal JavaScript, optimized CSS
- **SEO**: Structured data, meta tags, sitemap support

## Installation

1. **Download the theme**
   ```bash
   cd cybermonkey-ghost-theme
   zip -r cybermonkey.zip . -x "*.DS_Store" -x "__MACOSX"
   ```

2. **Upload to Ghost**
   - Go to Ghost Admin → Settings → Theme
   - Click "Upload theme"
   - Select the `cybermonkey.zip` file
   - Activate the theme

3. **Configure the theme**
   - Set your navigation in Settings → Navigation
   - Configure theme options in Settings → Design
   - Add your logo and site icon

## Theme Structure

```
cybermonkey-ghost-theme/
├── assets/
│   ├── css/
│   │   └── main.css        # All styles
│   ├── js/
│   │   ├── main.js         # Core functionality
│   │   └── search.js       # Search feature
│   └── fonts/              # Custom fonts (add Atkinson Hyperlegible)
├── partials/
│   ├── navigation.hbs      # Main navigation
│   ├── post-card.hbs       # Post card component
│   ├── footer.hbs          # Site footer
│   └── pagination.hbs      # Pagination component
├── default.hbs             # Base template
├── index.hbs               # Homepage
├── post.hbs                # Single post
├── page.hbs                # Static page
├── tag.hbs                 # Tag archive
├── author.hbs              # Author archive
├── error.hbs               # Error pages
└── package.json            # Theme configuration
```

## Customization

### Colors

Edit the CSS variables in `assets/css/main.css`:

```css
:root {
  --color-primary: #0ca678;    /* Teal - main brand color */
  --color-secondary: #51a14f;   /* Green - secondary actions */
  --color-accent: #d77350;      /* Orange - accents */
  --color-purple: #a625a4;      /* Purple - hover states */
}
```

### Fonts

The theme uses:
- **Atkinson Hyperlegible** for headings (add font files to assets/fonts/)
- **Inter** for body text (system font stack fallback)

### Navigation

Configure your navigation menu in Ghost Admin → Settings → Navigation. The theme supports:
- Primary navigation (displayed in sidebar)
- Secondary navigation (displayed in footer)

## Content Migration

1. Import your content using the migration tool's JSON export
2. Upload images to Ghost's content directory
3. Update internal links to match Ghost's URL structure
4. Review and adjust custom HTML from converted shortcodes

## Features from Hugo

The following Hugo features have been adapted:

- **Shortcodes** → Converted to HTML with matching CSS classes
- **Menu structure** → Use Ghost's navigation settings
- **Search** → Client-side search using Ghost Content API
- **Categories** → Use Ghost tags
- **Custom pages** → Create as Ghost pages

## Browser Support

- Chrome/Edge (latest)
- Firefox (latest)
- Safari (latest)
- Mobile browsers (iOS Safari, Chrome Android)

## License

Copyright © 2024 Code Monkey Cybersecurity. All rights reserved.
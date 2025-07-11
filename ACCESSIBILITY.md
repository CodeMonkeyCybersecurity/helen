# Accessibility Guidelines for Code Monkey Cybersecurity Website

This document outlines the accessibility standards and implementation guidelines for the Code Monkey Cybersecurity website.

## Compliance Standards

### Primary Standards
- **WCAG 2.1 Level AA** - Web Content Accessibility Guidelines
- **Australian Disability Discrimination Act (DDA) 1992**
- **Australian Government Digital Service Standard**

### Additional Guidelines
- **Section 508** (US Federal accessibility standard)
- **EN 301 549** (European accessibility standard)

## Implementation Checklist

### 1. Semantic HTML Structure
- [ ] Use proper heading hierarchy (H1 → H2 → H3)
- [ ] Implement semantic landmarks (main, nav, aside, footer)
- [ ] Use lists (ul, ol) for grouped content
- [ ] Proper form labels and fieldsets

### 2. Keyboard Navigation
- [ ] All interactive elements keyboard accessible
- [ ] Logical tab order
- [ ] Skip links for main content areas
- [ ] Visible focus indicators
- [ ] No keyboard traps

### 3. Screen Reader Support
- [ ] Descriptive alt text for all images
- [ ] ARIA labels where necessary
- [ ] Proper form labeling
- [ ] Descriptive link text
- [ ] Table headers properly associated

### 4. Color and Contrast
- [ ] Minimum 4.5:1 contrast ratio for normal text
- [ ] Minimum 3:1 contrast ratio for large text
- [ ] Color not used as sole indicator
- [ ] Focus indicators meet contrast requirements

### 5. Typography and Layout
- [ ] Readable fonts (minimum 16px base size)
- [ ] Line height of at least 1.5
- [ ] Text resizable to 200% without loss of function
- [ ] Responsive design for different screen sizes

## Hugo Theme Accessibility Features

### Required Hugo Shortcodes
```html
<!-- Accessible button -->
{{< button href="/link" aria-label="Descriptive button text" >}}Button Text{{< /button >}}

<!-- Accessible image -->
{{< image src="/path/image.jpg" alt="Descriptive alt text" >}}

<!-- Accessible form -->
{{< form-field type="email" label="Email Address" required="true" >}}
```

### CSS Requirements
```css
/* Focus indicators */
:focus {
    outline: 2px solid #0066cc;
    outline-offset: 2px;
}

/* Skip links */
.skip-link {
    position: absolute;
    top: -40px;
    left: 6px;
    background: #000;
    color: #fff;
    padding: 8px;
    text-decoration: none;
    z-index: 9999;
}

.skip-link:focus {
    top: 6px;
}

/* High contrast mode support */
@media (prefers-contrast: high) {
    /* Enhanced contrast styles */
}

/* Reduced motion support */
@media (prefers-reduced-motion: reduce) {
    * {
        animation-duration: 0.01ms !important;
        animation-iteration-count: 1 !important;
        transition-duration: 0.01ms !important;
    }
}
```

## Content Guidelines

### Writing for Accessibility
1. **Use plain language** - Write for 8th-grade reading level
2. **Descriptive headings** - Headings should clearly describe section content
3. **Meaningful link text** - Avoid "click here" or "read more"
4. **Clear instructions** - Provide explicit form instructions
5. **Error messages** - Clear, helpful error descriptions

### Image Alt Text Guidelines
- **Decorative images**: Use empty alt="" or CSS background-image
- **Informative images**: Describe the image content and purpose
- **Complex images**: Provide detailed description or link to long description
- **Text in images**: Include all text in alt attribute

### Form Accessibility
- **Labels**: Every form field must have a label
- **Instructions**: Provide clear field instructions
- **Error handling**: Clear error messages with suggestions
- **Required fields**: Clearly marked with asterisk and text
- **Grouping**: Use fieldsets for related fields

## Testing Procedures

### Automated Testing
- **axe-core** - Browser extension for automated accessibility testing
- **WAVE** - Web Accessibility Evaluation Tool
- **Lighthouse** - Accessibility audit in Chrome DevTools

### Manual Testing
- **Keyboard navigation** - Test with Tab, Shift+Tab, Enter, Space
- **Screen readers** - Test with NVDA, JAWS, VoiceOver
- **Color contrast** - Use color contrast analyzer tools
- **Mobile accessibility** - Test on mobile devices and screen readers

### User Testing
- **Disability user testing** - Include users with disabilities in testing
- **Assistive technology testing** - Test with various assistive technologies
- **Cognitive load testing** - Test with users who have cognitive disabilities

## Common Issues and Solutions

### Issue: Missing Alt Text
**Solution**: Add descriptive alt text to all images
```html
<img src="security-dashboard.jpg" alt="Delphi Notify security dashboard showing threat detection statistics">
```

### Issue: Poor Color Contrast
**Solution**: Use colors that meet WCAG contrast ratios
```css
.button {
    background-color: #0066cc; /* Meets contrast requirement */
    color: #ffffff;
}
```

### Issue: Inaccessible Forms
**Solution**: Add proper labels and instructions
```html
<label for="email">Email Address (required)</label>
<input type="email" id="email" name="email" required aria-describedby="email-help">
<div id="email-help">We'll use this to send you security alerts</div>
```

### Issue: Poor Keyboard Navigation
**Solution**: Ensure all interactive elements are keyboard accessible
```css
.button:focus {
    outline: 2px solid #0066cc;
    outline-offset: 2px;
}
```

## Compliance Monitoring

### Regular Audits
- **Monthly**: Automated accessibility scans
- **Quarterly**: Manual accessibility review
- **Annually**: Comprehensive accessibility audit
- **Ongoing**: User feedback collection

### Documentation
- **Accessibility statement** - Published and updated regularly
- **Compliance reports** - Document accessibility testing results
- **Issue tracking** - Log and track accessibility issues
- **Training records** - Document staff accessibility training

## Resources

### Testing Tools
- [axe DevTools](https://www.deque.com/axe/devtools/)
- [WAVE Web Accessibility Evaluator](https://wave.webaim.org/)
- [Color Contrast Analyzer](https://www.tpgi.com/color-contrast-checker/)

### Guidelines and Standards
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/Understanding/)
- [Australian Government Digital Service Standard](https://www.dta.gov.au/help-and-advice/digital-service-standard)
- [WebAIM Accessibility Resources](https://webaim.org/)

### Screen Readers
- [NVDA](https://www.nvaccess.org/) (Free, Windows)
- [JAWS](https://www.freedomscientific.com/products/software/jaws/) (Windows)
- [VoiceOver](https://www.apple.com/accessibility/mac/vision/) (macOS/iOS)

---

*This document should be reviewed and updated regularly as accessibility standards evolve and new requirements are identified.*
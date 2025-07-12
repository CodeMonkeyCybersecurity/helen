# Testing Guide for Code Monkey Cybersecurity Website

This guide covers all testing procedures, tools, and configurations for maintaining a robust and secure website.

## Quick Start

```bash
# Install all dependencies
npm install

# Run all tests
npm test

# Run specific test suites
npm run lint          # All linting
npm run test:security # Security tests
npm run test:a11y     # Accessibility tests
```

## Testing Categories

### 1. Code Quality & Linting

#### JavaScript Linting (ESLint)
```bash
npm run lint:js
```

**Configuration**: `.eslintrc.json`
- Security plugin enabled
- DOM sanitization checks
- No eval/Function constructor allowed

#### CSS/SCSS Linting (Stylelint)
```bash
npm run lint:css
```

**Configuration**: `.stylelintrc.json`
- Standard config with SCSS support
- Tailwind-aware rules
- Property ordering enforced

#### HTML Validation
```bash
npm run lint:html
```

**Configuration**: `.htmlvalidate.json`
- W3C compliance
- Accessibility rules
- Security headers validation

### 2. Security Testing

#### Dependency Scanning
```bash
# NPM audit
npm audit

# High severity only
npm run test:deps

# Snyk scanning (requires token)
npm run scan:deps
```

#### Security Headers Testing
```bash
# Check security headers in built site
npm run build
npm run test:headers
```

#### Content Security Policy Testing
- Automated CSP validation in CI
- Manual testing with browser developer tools

### 3. Accessibility Testing

#### Automated Testing
```bash
# Run axe-core on built site
npm run test:accessibility

# Pa11y testing
npm run test:pa11y
```

**Configuration**: `.axe.json`
- WCAG 2.1 AA compliance
- All critical rules enabled

#### Manual Testing
- Keyboard navigation
- Screen reader testing
- Color contrast validation

### 4. Performance Testing

#### Lighthouse CI
```bash
# Run Lighthouse locally
npm run lighthouse

# CI configuration
npm run lhci autorun
```

**Configuration**: `.lighthouserc.json`
- Performance score: 85+
- Accessibility score: 95+
- Best practices: 90+
- SEO score: 95+

#### Bundle Analysis
```bash
npm run analyze
```

### 5. Link & Content Validation

#### Markdown Link Checking
```bash
npm run test:links
```

#### Broken Link Detection
- Automated in CI pipeline
- Uses lychee for comprehensive checking

### 6. Hugo-Specific Testing

#### Build Testing
```bash
# Test production build
hugo --minify --environment production

# Test with drafts
hugo server --buildDrafts
```

#### Content Validation
- Front matter validation
- Shortcode testing
- Template syntax checking

## CI/CD Pipeline

### GitHub Actions Workflow

The `.github/workflows/ci.yml` file runs:

1. **On every push/PR**:
   - Linting (JS, CSS, HTML)
   - Security scanning
   - Build verification
   - Link checking

2. **After successful build**:
   - HTML validation
   - Accessibility testing
   - Performance testing

3. **Daily scheduled**:
   - Full security audit
   - Dependency updates check
   - Fuzz testing

### Pre-commit Hooks

Create `.git/hooks/pre-commit`:
```bash
#!/bin/bash
npm run lint
npm run test:security
```

## Monitoring & Alerts

### Dependency Monitoring

**Dependabot** (`.github/dependabot.yml`):
- Weekly updates for npm packages
- Grouped updates for dev dependencies
- Security patches prioritized

### Security Monitoring

**GitHub Security Advisories**:
- Automatic vulnerability alerts
- CodeQL analysis for JavaScript

**Snyk Integration**:
- Real-time vulnerability monitoring
- License compliance checking

## Manual Testing Checklist

### Before Major Releases

- [ ] Test all navigation menus on mobile/desktop
- [ ] Verify forms submission and validation
- [ ] Check all CTAs and conversion paths
- [ ] Test search functionality
- [ ] Verify responsive design breakpoints
- [ ] Test in multiple browsers (Chrome, Firefox, Safari, Edge)
- [ ] Check print styles
- [ ] Validate RSS/JSON feeds
- [ ] Test 404 page
- [ ] Verify sitemap generation

### Security Checklist

- [ ] No exposed API keys or secrets
- [ ] All external resources use HTTPS
- [ ] CSP headers properly configured
- [ ] No inline scripts without nonce
- [ ] Form inputs properly validated
- [ ] XSS prevention in user content

### Accessibility Checklist

- [ ] All images have alt text
- [ ] Proper heading hierarchy
- [ ] Sufficient color contrast
- [ ] Keyboard navigation works
- [ ] ARIA labels where needed
- [ ] Focus indicators visible

## Troubleshooting

### Common Issues

**Build Failures**:
```bash
# Clear Hugo cache
hugo mod clean
rm -rf resources/_gen

# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

**Linting Errors**:
```bash
# Auto-fix where possible
npm run lint:js -- --fix
npm run lint:css -- --fix
```

**Test Failures**:
- Check Node.js version (requires 18+)
- Ensure Hugo Extended is installed
- Verify all git submodules are initialized

## Performance Optimization

### Image Optimization
```bash
npm run optimize:images
```

### CSS/JS Optimization
```bash
npm run optimize:css
npm run optimize:js
```

### Critical CSS Generation
- Automated in build process
- Manual extraction for above-fold content

## Reporting

### Test Reports

All test results are:
- Displayed in GitHub Actions
- Saved as artifacts
- Sent to monitoring dashboard

### Metrics Tracking

Key metrics monitored:
- Build time
- Bundle size
- Lighthouse scores
- Security vulnerabilities
- Accessibility violations

## Best Practices

1. **Run tests locally** before pushing
2. **Fix warnings** not just errors
3. **Update dependencies** regularly
4. **Document new tests** added
5. **Monitor performance** trends
6. **Review security alerts** promptly

## Additional Resources

- [Hugo Testing Guide](https://gohugo.io/troubleshooting/)
- [Web.dev Testing Guide](https://web.dev/learn/#testing)
- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
- [A11y Testing Guide](https://www.a11yproject.com/checklist/)

---

For questions or improvements to testing procedures, please open an issue or contact the development team.
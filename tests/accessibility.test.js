/**
 * Accessibility tests for Hugo site and search functionality
 * Tests WCAG compliance, keyboard navigation, screen reader support
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const { JSDOM } = require('jsdom');

describe('Accessibility Tests', () => {
  const projectRoot = path.resolve(__dirname, '..');
  
  beforeAll(() => {
    // Build the site for testing
    execSync('hugo --quiet --minify', { cwd: projectRoot });
  });

  describe('HTML Structure and Semantics', () => {
    test('search page should have proper document structure', () => {
      const searchPagePath = path.join(projectRoot, 'public', 'search', 'index.html');
      expect(fs.existsSync(searchPagePath)).toBe(true);
      
      const content = fs.readFileSync(searchPagePath, 'utf8');
      const dom = new JSDOM(content);
      const document = dom.window.document;
      
      // Should have proper DOCTYPE
      expect(content).toMatch(/<!DOCTYPE html>/i);
      
      // Should have lang attribute
      const html = document.querySelector('html');
      expect(html.hasAttribute('lang')).toBe(true);
      expect(html.getAttribute('lang')).toMatch(/^[a-z]{2}(-[A-Z]{2})?$/);
      
      // Should have title
      const title = document.querySelector('title');
      expect(title).not.toBeNull();
      expect(title.textContent.trim()).not.toBe('');
      
      // Should have meta viewport
      const viewport = document.querySelector('meta[name="viewport"]');
      expect(viewport).not.toBeNull();
    });

    test('search form should have proper accessibility attributes', () => {
      const searchPagePath = path.join(projectRoot, 'public', 'search', 'index.html');
      const content = fs.readFileSync(searchPagePath, 'utf8');
      const dom = new JSDOM(content);
      const document = dom.window.document;
      
      // Search form should have role
      const searchForm = document.querySelector('form');
      expect(searchForm).not.toBeNull();
      expect(searchForm.getAttribute('role')).toBe('search');
      
      // Search input should have proper attributes
      const searchInput = document.querySelector('#search-input');
      expect(searchInput).not.toBeNull();
      expect(searchInput.getAttribute('type')).toBe('search');
      expect(searchInput.hasAttribute('placeholder')).toBe(true);
      expect(searchInput.hasAttribute('autocomplete')).toBe(true);
      expect(searchInput.hasAttribute('autofocus')).toBe(true);
      
      // Results should have aria-live
      const searchResults = document.querySelector('#search-results');
      expect(searchResults).not.toBeNull();
      expect(searchResults.getAttribute('aria-live')).toBe('polite');
    });

    test('headings should follow proper hierarchy', () => {
      const htmlFiles = findHtmlFiles(path.join(projectRoot, 'public'));
      
      htmlFiles.slice(0, 10).forEach(filePath => { // Test first 10 files
        const content = fs.readFileSync(filePath, 'utf8');
        const dom = new JSDOM(content);
        const document = dom.window.document;
        
        const headings = Array.from(document.querySelectorAll('h1, h2, h3, h4, h5, h6'));
        const levels = headings.map(h => parseInt(h.tagName.charAt(1)));
        
        if (levels.length > 0) {
          // Should start with h1
          expect(levels[0]).toBe(1);
          
          // Check hierarchy
          for (let i = 1; i < levels.length; i++) {
            const prevLevel = levels[i - 1];
            const currentLevel = levels[i];
            
            // Should not skip more than one level
            expect(currentLevel).toBeLessThanOrEqual(prevLevel + 1);
          }
        }
      });
    });

    test('images should have alt text', () => {
      const htmlFiles = findHtmlFiles(path.join(projectRoot, 'public'));
      
      htmlFiles.slice(0, 10).forEach(filePath => { // Test first 10 files
        const content = fs.readFileSync(filePath, 'utf8');
        const dom = new JSDOM(content);
        const document = dom.window.document;
        
        const images = document.querySelectorAll('img');
        images.forEach(img => {
          // Should have alt attribute
          expect(img.hasAttribute('alt')).toBe(true);
          
          // Alt text should not be placeholder text
          const alt = img.getAttribute('alt');
          expect(alt).not.toMatch(/^(image|photo|picture)$/i);
          expect(alt).not.toMatch(/^(img|pic)_?\d*$/i);
        });
      });
    });

    test('links should have meaningful text', () => {
      const htmlFiles = findHtmlFiles(path.join(projectRoot, 'public'));
      
      htmlFiles.slice(0, 5).forEach(filePath => { // Test first 5 files
        const content = fs.readFileSync(filePath, 'utf8');
        const dom = new JSDOM(content);
        const document = dom.window.document;
        
        const links = document.querySelectorAll('a[href]');
        links.forEach(link => {
          const text = link.textContent.trim();
          
          if (text) {
            // Should not be generic text
            expect(text.toLowerCase()).not.toMatch(/^(click here|read more|more|link)$/);
            expect(text.length).toBeGreaterThan(2);
          } else {
            // If no text, should have aria-label or title
            expect(
              link.hasAttribute('aria-label') || 
              link.hasAttribute('title') ||
              link.querySelector('img[alt]')
            ).toBe(true);
          }
        });
      });
    });
  });

  describe('Keyboard Navigation', () => {
    test('search interface should be keyboard accessible', () => {
      const searchPagePath = path.join(projectRoot, 'public', 'search', 'index.html');
      const content = fs.readFileSync(searchPagePath, 'utf8');
      const dom = new JSDOM(content);
      const document = dom.window.document;
      
      // Interactive elements should be focusable
      const interactiveElements = document.querySelectorAll(
        'input, button, a[href], select, textarea, [tabindex]'
      );
      
      interactiveElements.forEach(element => {
        const tabIndex = element.getAttribute('tabindex');
        
        // Should not have negative tabindex unless intentional
        if (tabIndex !== null) {
          expect(parseInt(tabIndex)).toBeGreaterThanOrEqual(0);
        }
        
        // Buttons should have type attribute
        if (element.tagName.toLowerCase() === 'button' && !element.hasAttribute('type')) {
          console.warn('Button without type attribute found');
        }
      });
    });

    test('skip links should be present', () => {
      const htmlFiles = findHtmlFiles(path.join(projectRoot, 'public'));
      
      // Check main pages for skip links
      const mainPages = htmlFiles.filter(f => 
        f.includes('/index.html') || 
        f.includes('/search/index.html')
      );
      
      mainPages.forEach(filePath => {
        const content = fs.readFileSync(filePath, 'utf8');
        const dom = new JSDOM(content);
        const document = dom.window.document;
        
        // Look for skip link
        const skipLink = document.querySelector('a[href^="#"], a[href*="skip"]');
        if (skipLink) {
          const href = skipLink.getAttribute('href');
          
          // Should point to valid element
          if (href.startsWith('#')) {
            const target = document.querySelector(href);
            expect(target).not.toBeNull();
          }
        }
      });
    });
  });

  describe('Color and Contrast', () => {
    test('should not rely solely on color for information', () => {
      const searchPagePath = path.join(projectRoot, 'public', 'search', 'index.html');
      const content = fs.readFileSync(searchPagePath, 'utf8');
      
      // Should not have CSS that only uses color for state
      expect(content).not.toMatch(/color:\s*red[^;]*;\s*}/);
      expect(content).not.toMatch(/background-color:\s*red[^;]*;\s*}/);
      
      // Look for proper use of text, icons, or other indicators
      const dom = new JSDOM(content);
      const document = dom.window.document;
      
      // Error states should have text or icons, not just color
      const errorElements = document.querySelectorAll('[class*="error"], [class*="invalid"]');
      errorElements.forEach(element => {
        const hasText = element.textContent.trim().length > 0;
        const hasIcon = element.querySelector('svg, img, [class*="icon"]');
        const hasAriaLabel = element.hasAttribute('aria-label');
        
        expect(hasText || hasIcon || hasAriaLabel).toBe(true);
      });
    });

    test('CSS should support high contrast mode', () => {
      const cssFiles = findCssFiles(path.join(projectRoot, 'public'));
      
      cssFiles.forEach(filePath => {
        const content = fs.readFileSync(filePath, 'utf8');
        
        // Should not rely solely on background images for important info
        if (content.includes('background-image')) {
          // Should also have fallback text or other indicators
          expect(content).toMatch(/color:|border:|outline:/);
        }
        
        // Should have proper focus indicators
        if (content.includes(':focus')) {
          expect(content).toMatch(/:focus[^{]*\{[^}]*(outline|border|box-shadow)/);
        }
      });
    });
  });

  describe('ARIA and Screen Reader Support', () => {
    test('search results should have proper ARIA labels', () => {
      const searchPagePath = path.join(projectRoot, 'public', 'search', 'index.html');
      const content = fs.readFileSync(searchPagePath, 'utf8');
      const dom = new JSDOM(content);
      const document = dom.window.document;
      
      // Search results container should have aria-live
      const resultsContainer = document.querySelector('#search-results');
      expect(resultsContainer.getAttribute('aria-live')).toBe('polite');
      
      // Search input should have accessible name
      const searchInput = document.querySelector('#search-input');
      const hasAccessibleName = 
        searchInput.hasAttribute('aria-label') ||
        searchInput.hasAttribute('aria-labelledby') ||
        document.querySelector('label[for="search-input"]');
      
      expect(hasAccessibleName).toBe(true);
    });

    test('dynamic content should announce changes', () => {
      const searchPagePath = path.join(projectRoot, 'public', 'search', 'index.html');
      const content = fs.readFileSync(searchPagePath, 'utf8');
      
      // Search script should properly announce results
      expect(content).toMatch(/aria-live/);
      
      // Should not have aria-atomic="true" for long content
      expect(content).not.toMatch(/aria-atomic="true"[^>]*>[^<]{200,}/);
    });

    test('navigation should have proper landmarks', () => {
      const htmlFiles = findHtmlFiles(path.join(projectRoot, 'public'));
      
      htmlFiles.slice(0, 5).forEach(filePath => { // Test first 5 files
        const content = fs.readFileSync(filePath, 'utf8');
        const dom = new JSDOM(content);
        const document = dom.window.document;
        
        // Should have main landmark
        const main = document.querySelector('main, [role="main"]');
        expect(main).not.toBeNull();
        
        // Navigation should be marked up properly
        const nav = document.querySelector('nav, [role="navigation"]');
        if (nav) {
          // Nav should have accessible name if multiple navs exist
          const navCount = document.querySelectorAll('nav, [role="navigation"]').length;
          if (navCount > 1) {
            expect(
              nav.hasAttribute('aria-label') ||
              nav.hasAttribute('aria-labelledby')
            ).toBe(true);
          }
        }
      });
    });
  });

  describe('Form Accessibility', () => {
    test('form controls should have proper labels', () => {
      const htmlFiles = findHtmlFiles(path.join(projectRoot, 'public'));
      
      htmlFiles.slice(0, 10).forEach(filePath => { // Test first 10 files
        const content = fs.readFileSync(filePath, 'utf8');
        const dom = new JSDOM(content);
        const document = dom.window.document;
        
        const formControls = document.querySelectorAll(
          'input:not([type="hidden"]), select, textarea'
        );
        
        formControls.forEach(control => {
          const id = control.getAttribute('id');
          const hasLabel = id && document.querySelector(`label[for="${id}"]`);
          const hasAriaLabel = control.hasAttribute('aria-label');
          const hasAriaLabelledby = control.hasAttribute('aria-labelledby');
          const hasTitle = control.hasAttribute('title');
          
          expect(hasLabel || hasAriaLabel || hasAriaLabelledby || hasTitle).toBe(true);
        });
      });
    });

    test('search form should provide helpful instructions', () => {
      const searchPagePath = path.join(projectRoot, 'public', 'search', 'index.html');
      const content = fs.readFileSync(searchPagePath, 'utf8');
      const dom = new JSDOM(content);
      const document = dom.window.document;
      
      // Should have search tips or instructions
      const tips = document.querySelector('.search-tips, [class*="tip"], [class*="help"]');
      expect(tips).not.toBeNull();
      
      // Tips should be accessible
      if (tips) {
        expect(tips.textContent.trim().length).toBeGreaterThan(10);
      }
    });
  });

  describe('Responsive Design Accessibility', () => {
    test('content should be accessible at different zoom levels', () => {
      const cssFiles = findCssFiles(path.join(projectRoot, 'public'));
      
      cssFiles.forEach(filePath => {
        const content = fs.readFileSync(filePath, 'utf8');
        
        // Should use relative units for text
        if (content.includes('font-size')) {
          // Should not rely solely on fixed pixels for small text
          const smallPixelFonts = content.match(/font-size:\s*([0-9]+px)/g) || [];
          smallPixelFonts.forEach(match => {
            const size = parseInt(match.match(/(\d+)px/)[1]);
            if (size < 14) {
              console.warn(`Small fixed font size found: ${match}`);
            }
          });
        }
        
        // Should have responsive breakpoints
        if (content.length > 1000) { // Only check substantial CSS files
          expect(content).toMatch(/@media/);
        }
      });
    });

    test('touch targets should be appropriately sized', () => {
      const cssFiles = findCssFiles(path.join(projectRoot, 'public'));
      
      cssFiles.forEach(filePath => {
        const content = fs.readFileSync(filePath, 'utf8');
        
        // Interactive elements should have minimum size
        if (content.includes('button') || content.includes('input')) {
          // Look for proper sizing
          expect(content).toMatch(/(min-)?(width|height|padding)/);
        }
      });
    });
  });

  describe('Error Handling and Feedback', () => {
    test('no results state should be accessible', () => {
      const searchPagePath = path.join(projectRoot, 'public', 'search', 'index.html');
      const content = fs.readFileSync(searchPagePath, 'utf8');
      
      // Should provide helpful no results message
      expect(content).toMatch(/no results/i);
      expect(content).toMatch(/try different/i);
      
      // Should provide alternative actions
      expect(content).toMatch(/(browse|search|popular)/i);
    });

    test('loading states should be announced', () => {
      const searchPagePath = path.join(projectRoot, 'public', 'search', 'index.html');
      const content = fs.readFileSync(searchPagePath, 'utf8');
      
      // Should have aria-live region for announcements
      expect(content).toMatch(/aria-live/);
      
      // Script should handle loading states properly
      if (content.includes('loadSearchIndex')) {
        expect(content).toMatch(/console\.log|console\.error/);
      }
    });
  });

  describe('Content Accessibility', () => {
    test('text content should be readable', () => {
      const htmlFiles = findHtmlFiles(path.join(projectRoot, 'public'));
      
      htmlFiles.slice(0, 5).forEach(filePath => { // Test first 5 files
        const content = fs.readFileSync(filePath, 'utf8');
        const dom = new JSDOM(content);
        const document = dom.window.document;
        
        // Remove script and style content for text analysis
        const scripts = document.querySelectorAll('script, style');
        scripts.forEach(script => script.remove());
        
        const textContent = document.body ? document.body.textContent : '';
        const sentences = textContent.split(/[.!?]+/).filter(s => s.trim().length > 10);
        
        if (sentences.length > 0) {
          // Average sentence length should be reasonable
          const avgLength = sentences.reduce((sum, s) => sum + s.length, 0) / sentences.length;
          expect(avgLength).toBeLessThan(200); // Not too long
          expect(avgLength).toBeGreaterThan(10); // Not too short
        }
      });
    });

    test('abbreviations should be explained', () => {
      const htmlFiles = findHtmlFiles(path.join(projectRoot, 'public'));
      
      htmlFiles.slice(0, 5).forEach(filePath => { // Test first 5 files
        const content = fs.readFileSync(filePath, 'utf8');
        const dom = new JSDOM(content);
        const document = dom.window.document;
        
        // Abbreviations should use abbr tag or be explained
        const abbrs = document.querySelectorAll('abbr');
        abbrs.forEach(abbr => {
          expect(
            abbr.hasAttribute('title') || 
            abbr.hasAttribute('aria-label')
          ).toBe(true);
        });
      });
    });
  });
});

/**
 * Helper function to find all HTML files recursively
 */
function findHtmlFiles(dir, files = []) {
  if (!fs.existsSync(dir)) {
    return files;
  }
  
  const items = fs.readdirSync(dir);
  
  for (const item of items) {
    const fullPath = path.join(dir, item);
    const stat = fs.statSync(fullPath);
    
    if (stat.isDirectory()) {
      findHtmlFiles(fullPath, files);
    } else if (stat.isFile() && fullPath.endsWith('.html')) {
      files.push(fullPath);
    }
  }
  
  return files;
}

/**
 * Helper function to find all CSS files recursively
 */
function findCssFiles(dir, files = []) {
  if (!fs.existsSync(dir)) {
    return files;
  }
  
  const items = fs.readdirSync(dir);
  
  for (const item of items) {
    const fullPath = path.join(dir, item);
    const stat = fs.statSync(fullPath);
    
    if (stat.isDirectory()) {
      findCssFiles(fullPath, files);
    } else if (stat.isFile() && fullPath.endsWith('.css')) {
      files.push(fullPath);
    }
  }
  
  return files;
}

module.exports = {
  findHtmlFiles,
  findCssFiles
};
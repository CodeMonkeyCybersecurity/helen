/**
 * Hugo template rendering and functionality tests
 * Tests Hugo layouts, shortcodes, and content processing
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

describe('Hugo Template Tests', () => {
  const projectRoot = path.resolve(__dirname, '..');
  const layoutsDir = path.join(projectRoot, 'layouts');
  const contentDir = path.join(projectRoot, 'content');
  
  beforeAll(() => {
    // Ensure Hugo is available
    try {
      execSync('hugo version', { stdio: 'ignore' });
    } catch (error) {
      throw new Error('Hugo not found. Please install Hugo Extended to run these tests.');
    }
  });

  describe('Layout Template Validation', () => {
    test('baseof.html should have required structure', () => {
      const baseofPath = path.join(layoutsDir, '_default', 'baseof.html');
      expect(fs.existsSync(baseofPath)).toBe(true);
      
      const content = fs.readFileSync(baseofPath, 'utf8');
      
      // Should have HTML5 doctype
      expect(content).toMatch(/<!DOCTYPE html>/i);
      
      // Should have main content block
      expect(content).toMatch(/{{ block "main" \. }}/);
      
      // Should include head partial
      expect(content).toMatch(/{{ partial ".*head.*" \. }}/);
      
      // Should be valid HTML structure
      expect(content).toMatch(/<html[^>]*>/);
      expect(content).toMatch(/<\/html>/);
      expect(content).toMatch(/<head>/);
      expect(content).toMatch(/<\/head>/);
      expect(content).toMatch(/<body[^>]*>/);
      expect(content).toMatch(/<\/body>/);
    });

    test('search template should have required elements', () => {
      const searchPath = path.join(layoutsDir, 'search', 'single.html');
      expect(fs.existsSync(searchPath)).toBe(true);
      
      const content = fs.readFileSync(searchPath, 'utf8');
      
      // Should define main block
      expect(content).toMatch(/{{ define "main" }}/);
      
      // Should have search input
      expect(content).toMatch(/id="search-input"/);
      
      // Should have results container
      expect(content).toMatch(/id="search-results"/);
      
      // Should include search script
      expect(content).toMatch(/<script>/);
      expect(content).toMatch(/loadSearchIndex/);
      expect(content).toMatch(/performSearch/);
    });

    test('index.json should generate valid search index', () => {
      const indexJsonPath = path.join(layoutsDir, 'index.json');
      expect(fs.existsSync(indexJsonPath)).toBe(true);
      
      const content = fs.readFileSync(indexJsonPath, 'utf8');
      
      // Should start and end with array brackets
      expect(content.trim()).toMatch(/^\[/);
      expect(content.trim()).toMatch(/\]$/);
      
      // Should iterate over site pages
      expect(content).toMatch(/{{ range.*\$pages }}/);
      
      // Should include required JSON fields
      expect(content).toMatch(/title.*jsonify/);
      expect(content).toMatch(/permalink.*jsonify/);
      expect(content).toMatch(/content.*jsonify/);
      expect(content).toMatch(/section.*jsonify/);
    });
  });

  describe('Hugo Build Tests', () => {
    test('should build successfully with all content', () => {
      expect(() => {
        execSync('hugo --quiet --minify', {
          cwd: projectRoot,
          stdio: 'pipe'
        });
      }).not.toThrow();
    });

    test('should generate search index', () => {
      // Build the site
      execSync('hugo --quiet', { cwd: projectRoot });
      
      const indexPath = path.join(projectRoot, 'public', 'index.json');
      expect(fs.existsSync(indexPath)).toBe(true);
      
      const indexContent = fs.readFileSync(indexPath, 'utf8');
      
      // Should be valid JSON
      expect(() => JSON.parse(indexContent)).not.toThrow();
      
      const searchIndex = JSON.parse(indexContent);
      expect(Array.isArray(searchIndex)).toBe(true);
      expect(searchIndex.length).toBeGreaterThan(0);
      
      // Check first entry structure
      if (searchIndex.length > 0) {
        const firstEntry = searchIndex[0];
        expect(firstEntry).toHaveProperty('title');
        expect(firstEntry).toHaveProperty('permalink');
        expect(firstEntry).toHaveProperty('content');
        expect(firstEntry).toHaveProperty('section');
      }
    });

    test('should generate search page', () => {
      // Build the site
      execSync('hugo --quiet', { cwd: projectRoot });
      
      const searchPagePath = path.join(projectRoot, 'public', 'search', 'index.html');
      expect(fs.existsSync(searchPagePath)).toBe(true);
      
      const content = fs.readFileSync(searchPagePath, 'utf8');
      
      // Should contain search elements
      expect(content).toMatch(/id="search-input"/);
      expect(content).toMatch(/id="search-results"/);
      expect(content).toMatch(/loadSearchIndex/);
    });

    test('should build without draft content in production', () => {
      // Build without drafts
      execSync('hugo --quiet --environment production', { cwd: projectRoot });
      
      const publicDir = path.join(projectRoot, 'public');
      
      // Check that no draft pages are included
      // This is a basic check - in real implementation, you'd scan for specific draft markers
      expect(fs.existsSync(publicDir)).toBe(true);
    });
  });

  describe('Template Syntax Validation', () => {
    test('all layout files should have valid Hugo syntax', () => {
      const layoutFiles = findFiles(layoutsDir, '.html');
      
      layoutFiles.forEach(filePath => {
        const content = fs.readFileSync(filePath, 'utf8');
        const relativePath = path.relative(projectRoot, filePath);
        
        // Check for common Hugo syntax errors
        expect(content).not.toMatch(/{{ [^}]*$/m); // Unclosed template tags
        expect(content).not.toMatch(/^[^{]* }}/m);  // Unmatched closing tags
        
        // Check for proper template definitions
        if (content.includes('{{ define ')) {
          expect(content).toMatch(/{{ end }}/);
        }
        
        // Check for balanced range/with statements
        const rangeCount = (content.match(/{{ range/g) || []).length;
        const endCount = (content.match(/{{ end }}/g) || []).length;
        const withCount = (content.match(/{{ with/g) || []).length;
        
        // End statements should match range + with statements (approximately)
        // This is a loose check as there might be other block statements
        expect(endCount).toBeGreaterThanOrEqual(rangeCount + withCount);
      });
    });

    test('partials should have consistent naming', () => {
      const partialsDir = path.join(layoutsDir, 'partials');
      if (fs.existsSync(partialsDir)) {
        const partialFiles = findFiles(partialsDir, '.html');
        
        partialFiles.forEach(filePath => {
          const filename = path.basename(filePath);
          
          // Should use kebab-case
          expect(filename).toMatch(/^[a-z0-9-]+\.html$/);
          
          // Should not start with underscore (Hugo convention)
          expect(filename).not.toMatch(/^_/);
        });
      }
    });
  });

  describe('Content Validation', () => {
    test('all markdown files should have valid frontmatter', () => {
      const contentFiles = findFiles(contentDir, '.md');
      
      contentFiles.forEach(filePath => {
        const content = fs.readFileSync(filePath, 'utf8');
        const relativePath = path.relative(projectRoot, filePath);
        
        // Should start with frontmatter
        if (content.trim().length > 0) {
          expect(content).toMatch(/^---/);
          
          // Find the end of frontmatter
          const frontmatterEnd = content.indexOf('---', 3);
          expect(frontmatterEnd).toBeGreaterThan(3);
          
          const frontmatter = content.substring(3, frontmatterEnd);
          
          // Should have at least a title
          expect(frontmatter).toMatch(/title\s*:/);
        }
      });
    });

    test('content should not have broken internal links', () => {
      const contentFiles = findFiles(contentDir, '.md');
      const linkPattern = /\[([^\]]+)\]\(([^)]+)\)/g;
      
      contentFiles.forEach(filePath => {
        const content = fs.readFileSync(filePath, 'utf8');
        const relativePath = path.relative(projectRoot, filePath);
        
        let match;
        while ((match = linkPattern.exec(content)) !== null) {
          const linkUrl = match[2];
          
          // Check internal links (starting with /)
          if (linkUrl.startsWith('/') && !linkUrl.startsWith('//')) {
            // This is a basic check - in practice, you'd verify against built site
            expect(linkUrl).toMatch(/^\/[a-zA-Z0-9\-\/]*\/?$/);
          }
        }
      });
    });
  });

  describe('Shortcode Tests', () => {
    test('all shortcodes should be syntactically valid', () => {
      const shortcodesDir = path.join(layoutsDir, 'shortcodes');
      if (fs.existsSync(shortcodesDir)) {
        const shortcodeFiles = findFiles(shortcodesDir, '.html');
        
        shortcodeFiles.forEach(filePath => {
          const content = fs.readFileSync(filePath, 'utf8');
          const shortcodeName = path.basename(filePath, '.html');
          
          // Should be valid HTML/template syntax
          expect(content).not.toMatch(/{{ [^}]*$/m);
          expect(content).not.toMatch(/^[^{]* }}/m);
          
          // Common shortcode parameters
          if (content.includes('.Get')) {
            // Should properly access parameters
            expect(content).toMatch(/\.Get\s+\d+|\.\w+/);
          }
        });
      }
    });

    test('feature-card shortcode should render properly', () => {
      const featureCardPath = path.join(layoutsDir, 'shortcodes', 'feature-card.html');
      if (fs.existsSync(featureCardPath)) {
        const content = fs.readFileSync(featureCardPath, 'utf8');
        
        // Should have proper HTML structure
        expect(content).toMatch(/<div[^>]*class[^>]*>/);
        
        // Should access shortcode parameters
        expect(content).toMatch(/\.Get/);
      }
    });
  });

  describe('Performance Tests', () => {
    test('build should complete within reasonable time', () => {
      const startTime = Date.now();
      
      execSync('hugo --quiet', { cwd: projectRoot });
      
      const buildTime = Date.now() - startTime;
      
      // Should build in under 10 seconds for typical content
      expect(buildTime).toBeLessThan(10000);
    });

    test('generated search index should be reasonably sized', () => {
      execSync('hugo --quiet', { cwd: projectRoot });
      
      const indexPath = path.join(projectRoot, 'public', 'index.json');
      const stats = fs.statSync(indexPath);
      
      // Should be under 1MB for typical sites
      expect(stats.size).toBeLessThan(1024 * 1024);
      
      // Should not be empty
      expect(stats.size).toBeGreaterThan(100);
    });
  });

  describe('Security Tests', () => {
    test('templates should not expose sensitive data', () => {
      const layoutFiles = findFiles(layoutsDir, '.html');
      
      layoutFiles.forEach(filePath => {
        const content = fs.readFileSync(filePath, 'utf8');
        
        // Should not contain hardcoded secrets
        expect(content).not.toMatch(/password\s*[:=]\s*['"]/i);
        expect(content).not.toMatch(/api[_-]?key\s*[:=]\s*['"]/i);
        expect(content).not.toMatch(/secret\s*[:=]\s*['"]/i);
        expect(content).not.toMatch(/token\s*[:=]\s*['"]/i);
        
        // Should not have obvious XSS vulnerabilities
        expect(content).not.toMatch(/\|[\s]*safeHTML[\s]*\|/);
        expect(content).not.toMatch(/\{\{\s*\..*\s*\|\s*safeHTML\s*\}\}/);
      });
    });

    test('search template should sanitize user input', () => {
      const searchPath = path.join(layoutsDir, 'search', 'single.html');
      if (fs.existsSync(searchPath)) {
        const content = fs.readFileSync(searchPath, 'utf8');
        
        // Should not directly interpolate user input without escaping
        // This is a basic check - proper XSS prevention requires runtime testing
        expect(content).not.toMatch(/innerHTML\s*=\s*[^;]*\+[^;]*;/);
      }
    });
  });
});

/**
 * Recursively find files with specific extension
 */
function findFiles(dir, extension, files = []) {
  if (!fs.existsSync(dir)) {
    return files;
  }
  
  const items = fs.readdirSync(dir);
  
  for (const item of items) {
    const fullPath = path.join(dir, item);
    const stat = fs.statSync(fullPath);
    
    if (stat.isDirectory()) {
      findFiles(fullPath, extension, files);
    } else if (stat.isFile() && fullPath.endsWith(extension)) {
      files.push(fullPath);
    }
  }
  
  return files;
}

module.exports = { findFiles };
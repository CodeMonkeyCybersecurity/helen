/**
 * Content validation and quality tests
 * Tests markdown files, frontmatter, links, and content structure
 */

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

describe('Content Validation Tests', () => {
  const projectRoot = path.resolve(__dirname, '..');
  const contentDir = path.join(projectRoot, 'content');
  
  describe('Markdown File Structure', () => {
    test('all markdown files should have valid frontmatter', () => {
      const markdownFiles = findMarkdownFiles(contentDir);
      
      markdownFiles.forEach(filePath => {
        const content = fs.readFileSync(filePath, 'utf8');
        const relativePath = path.relative(projectRoot, filePath);
        
        if (content.trim().length === 0) {
          return; // Skip empty files
        }
        
        // Should start with frontmatter delimiter
        expect(content.trim()).toMatch(/^---\n/);
        
        // Find frontmatter boundaries
        const frontmatterStart = content.indexOf('---');
        const frontmatterEnd = content.indexOf('---', frontmatterStart + 3);
        
        expect(frontmatterEnd).toBeGreaterThan(frontmatterStart);
        
        const frontmatterContent = content.substring(frontmatterStart + 3, frontmatterEnd);
        
        // Should be valid YAML
        expect(() => {
          yaml.load(frontmatterContent);
        }).not.toThrow(`Invalid YAML in ${relativePath}`);
        
        const frontmatter = yaml.load(frontmatterContent);
        
        // Should have required fields
        expect(frontmatter).toHaveProperty('title');
        expect(typeof frontmatter.title).toBe('string');
        expect(frontmatter.title.trim()).not.toBe('');
      });
    });

    test('blog posts should have proper frontmatter', () => {
      const blogDir = path.join(contentDir, 'blog');
      if (!fs.existsSync(blogDir)) return;
      
      const blogPosts = findMarkdownFiles(blogDir).filter(f => !f.endsWith('_index.md'));
      
      blogPosts.forEach(filePath => {
        const content = fs.readFileSync(filePath, 'utf8');
        const frontmatter = extractFrontmatter(content);
        const relativePath = path.relative(projectRoot, filePath);
        
        // Required fields for blog posts
        expect(frontmatter).toHaveProperty('title');
        expect(frontmatter).toHaveProperty('date');
        
        // Date should be valid
        if (frontmatter.date) {
          const date = new Date(frontmatter.date);
          expect(date).toBeInstanceOf(Date);
          expect(date.toString()).not.toBe('Invalid Date');
        }
        
        // Categories and tags should be arrays if present
        if (frontmatter.categories) {
          expect(Array.isArray(frontmatter.categories)).toBe(true);
        }
        if (frontmatter.tags) {
          expect(Array.isArray(frontmatter.tags)).toBe(true);
        }
        
        // Draft status should be boolean if present
        if (frontmatter.hasOwnProperty('draft')) {
          expect(typeof frontmatter.draft).toBe('boolean');
        }
      });
    });

    test('section index files should exist', () => {
      const expectedSections = ['blog', 'resources', 'offerings', 'about-us'];
      
      expectedSections.forEach(section => {
        const indexPath = path.join(contentDir, section, '_index.md');
        expect(fs.existsSync(indexPath)).toBe(true);
        
        if (fs.existsSync(indexPath)) {
          const content = fs.readFileSync(indexPath, 'utf8');
          const frontmatter = extractFrontmatter(content);
          
          expect(frontmatter).toHaveProperty('title');
        }
      });
    });
  });

  describe('Content Quality', () => {
    test('content should not have placeholder text', () => {
      const markdownFiles = findMarkdownFiles(contentDir);
      const placeholderPatterns = [
        /lorem ipsum/i,
        /placeholder text/i,
        /todo:/i,
        /\[todo\]/i,
        /fix(me|ed)?/i,
        /temp(orary)?/i,
        /xxx+/i,
        /placeholder/i,
        /dummy content/i
      ];
      
      markdownFiles.forEach(filePath => {
        const content = fs.readFileSync(filePath, 'utf8');
        const relativePath = path.relative(projectRoot, filePath);
        
        // Extract content without frontmatter
        const contentBody = extractContentBody(content);
        
        placeholderPatterns.forEach(pattern => {
          if (pattern.test(contentBody)) {
            console.warn(`Possible placeholder text found in ${relativePath}`);
          }
        });
      });
    });

    test('content should have reasonable length', () => {
      const markdownFiles = findMarkdownFiles(contentDir)
        .filter(f => !f.endsWith('_index.md')); // Skip index files
      
      markdownFiles.forEach(filePath => {
        const content = fs.readFileSync(filePath, 'utf8');
        const contentBody = extractContentBody(content);
        const relativePath = path.relative(projectRoot, filePath);
        
        // Content should not be too short (unless it's intentional)
        if (contentBody.trim().length < 50 && contentBody.trim().length > 0) {
          console.warn(`Very short content in ${relativePath}`);
        }
        
        // Content should not be excessively long
        if (contentBody.length > 50000) {
          console.warn(`Very long content in ${relativePath}`);
        }
      });
    });

    test('headings should follow proper hierarchy', () => {
      const markdownFiles = findMarkdownFiles(contentDir);
      
      markdownFiles.forEach(filePath => {
        const content = fs.readFileSync(filePath, 'utf8');
        const contentBody = extractContentBody(content);
        const relativePath = path.relative(projectRoot, filePath);
        
        // Extract heading levels
        const headings = contentBody.match(/^#{1,6}\s+.+$/gm) || [];
        const levels = headings.map(h => h.match(/^#+/)[0].length);
        
        // Check heading hierarchy
        for (let i = 1; i < levels.length; i++) {
          const prevLevel = levels[i - 1];
          const currentLevel = levels[i];
          
          // Should not skip more than one level
          if (currentLevel > prevLevel + 1) {
            console.warn(`Heading hierarchy issue in ${relativePath}: h${prevLevel} followed by h${currentLevel}`);
          }
        }
      });
    });
  });

  describe('Link Validation', () => {
    test('internal links should be properly formatted', () => {
      const markdownFiles = findMarkdownFiles(contentDir);
      const linkPattern = /\[([^\]]+)\]\(([^)]+)\)/g;
      
      markdownFiles.forEach(filePath => {
        const content = fs.readFileSync(filePath, 'utf8');
        const contentBody = extractContentBody(content);
        const relativePath = path.relative(projectRoot, filePath);
        
        let match;
        while ((match = linkPattern.exec(contentBody)) !== null) {
          const linkText = match[1];
          const linkUrl = match[2];
          
          // Check internal links
          if (linkUrl.startsWith('/') && !linkUrl.startsWith('//')) {
            // Should not end with .md
            expect(linkUrl).not.toMatch(/\.md$/);
            
            // Should have proper format
            expect(linkUrl).toMatch(/^\/[a-zA-Z0-9\-\/]*\/?$/);
            
            // Link text should not be empty
            expect(linkText.trim()).not.toBe('');
          }
          
          // External links should use HTTPS where possible
          if (linkUrl.startsWith('http://')) {
            console.warn(`HTTP link found in ${relativePath}: ${linkUrl}`);
          }
        }
      });
    });

    test('images should have alt text', () => {
      const markdownFiles = findMarkdownFiles(contentDir);
      const imagePattern = /!\[([^\]]*)\]\([^)]+\)/g;
      
      markdownFiles.forEach(filePath => {
        const content = fs.readFileSync(filePath, 'utf8');
        const contentBody = extractContentBody(content);
        const relativePath = path.relative(projectRoot, filePath);
        
        let match;
        while ((match = imagePattern.exec(contentBody)) !== null) {
          const altText = match[1];
          
          // Alt text should not be empty for accessibility
          if (altText.trim() === '') {
            console.warn(`Image without alt text in ${relativePath}`);
          }
        }
      });
    });
  });

  describe('SEO and Metadata', () => {
    test('important pages should have descriptions', () => {
      const importantPages = [
        'content/_index.md',
        'content/about-us/_index.md',
        'content/offerings/_index.md',
        'content/resources/_index.md'
      ];
      
      importantPages.forEach(pagePath => {
        const fullPath = path.join(projectRoot, pagePath);
        if (fs.existsSync(fullPath)) {
          const content = fs.readFileSync(fullPath, 'utf8');
          const frontmatter = extractFrontmatter(content);
          
          // Should have description for SEO
          if (!frontmatter.description && !frontmatter.summary) {
            console.warn(`Missing description in ${pagePath}`);
          }
        }
      });
    });

    test('blog posts should have proper SEO metadata', () => {
      const blogDir = path.join(contentDir, 'blog');
      if (!fs.existsSync(blogDir)) return;
      
      const blogPosts = findMarkdownFiles(blogDir).filter(f => !f.endsWith('_index.md'));
      
      blogPosts.forEach(filePath => {
        const content = fs.readFileSync(filePath, 'utf8');
        const frontmatter = extractFrontmatter(content);
        const relativePath = path.relative(projectRoot, filePath);
        
        // Should have at least one SEO field
        const hasSeoField = frontmatter.description || 
                           frontmatter.summary || 
                           frontmatter.excerpt;
        
        if (!hasSeoField) {
          console.warn(`Missing SEO metadata in ${relativePath}`);
        }
        
        // Title should be reasonable length
        if (frontmatter.title && frontmatter.title.length > 60) {
          console.warn(`Long title in ${relativePath} (${frontmatter.title.length} chars)`);
        }
      });
    });
  });

  describe('Security Checks', () => {
    test('content should not contain sensitive information', () => {
      const markdownFiles = findMarkdownFiles(contentDir);
      const sensitivePatterns = [
        /password\s*[:=]\s*['"]\w+['"]/i,
        /api[_-]?key\s*[:=]\s*['"]\w+['"]/i,
        /secret\s*[:=]\s*['"]\w+['"]/i,
        /token\s*[:=]\s*['"]\w+['"]/i,
        /\b[A-Za-z0-9]{32,}\b/, // Potential API keys/hashes
        /ssh-rsa\s+[A-Za-z0-9+\/]+/i, // SSH public keys
        /-----BEGIN\s+[A-Z\s]+KEY-----/i // PEM keys
      ];
      
      markdownFiles.forEach(filePath => {
        const content = fs.readFileSync(filePath, 'utf8');
        const relativePath = path.relative(projectRoot, filePath);
        
        sensitivePatterns.forEach((pattern, index) => {
          if (pattern.test(content)) {
            console.warn(`Potential sensitive data (pattern ${index}) in ${relativePath}`);
          }
        });
      });
    });

    test('content should not have unsafe HTML', () => {
      const markdownFiles = findMarkdownFiles(contentDir);
      const unsafePatterns = [
        /<script[^>]*>/i,
        /<iframe[^>]*>/i,
        /<object[^>]*>/i,
        /<embed[^>]*>/i,
        /javascript:/i,
        /data:text\/html/i,
        /vbscript:/i
      ];
      
      markdownFiles.forEach(filePath => {
        const content = fs.readFileSync(filePath, 'utf8');
        const relativePath = path.relative(projectRoot, filePath);
        
        unsafePatterns.forEach(pattern => {
          if (pattern.test(content)) {
            console.warn(`Potentially unsafe HTML in ${relativePath}`);
          }
        });
      });
    });
  });

  describe('Hugo Shortcode Usage', () => {
    test('shortcodes should be properly formatted', () => {
      const markdownFiles = findMarkdownFiles(contentDir);
      const shortcodePattern = /\{\{<\s*(\w+)[^>]*>\}\}/g;
      
      markdownFiles.forEach(filePath => {
        const content = fs.readFileSync(filePath, 'utf8');
        const contentBody = extractContentBody(content);
        const relativePath = path.relative(projectRoot, filePath);
        
        let match;
        while ((match = shortcodePattern.exec(contentBody)) !== null) {
          const shortcodeName = match[1];
          
          // Should use lowercase shortcode names
          expect(shortcodeName).toMatch(/^[a-z\-]+$/);
          
          // Should be properly closed
          const openTag = match[0];
          if (!openTag.includes('/>')) {
            const closePattern = new RegExp(`\\{\\{<\\s*/${shortcodeName}\\s*>\\}\\}`, 'g');
            const remaining = contentBody.substring(match.index + openTag.length);
            expect(closePattern.test(remaining)).toBe(true);
          }
        }
      });
    });
  });
});

/**
 * Helper function to find all markdown files recursively
 */
function findMarkdownFiles(dir, files = []) {
  if (!fs.existsSync(dir)) {
    return files;
  }
  
  const items = fs.readdirSync(dir);
  
  for (const item of items) {
    const fullPath = path.join(dir, item);
    const stat = fs.statSync(fullPath);
    
    if (stat.isDirectory()) {
      findMarkdownFiles(fullPath, files);
    } else if (stat.isFile() && fullPath.endsWith('.md')) {
      files.push(fullPath);
    }
  }
  
  return files;
}

/**
 * Extract frontmatter from markdown content
 */
function extractFrontmatter(content) {
  if (!content.trim().startsWith('---')) {
    return {};
  }
  
  const frontmatterStart = content.indexOf('---');
  const frontmatterEnd = content.indexOf('---', frontmatterStart + 3);
  
  if (frontmatterEnd === -1) {
    return {};
  }
  
  const frontmatterContent = content.substring(frontmatterStart + 3, frontmatterEnd);
  
  try {
    return yaml.load(frontmatterContent) || {};
  } catch (error) {
    return {};
  }
}

/**
 * Extract content body (without frontmatter)
 */
function extractContentBody(content) {
  if (!content.trim().startsWith('---')) {
    return content;
  }
  
  const frontmatterStart = content.indexOf('---');
  const frontmatterEnd = content.indexOf('---', frontmatterStart + 3);
  
  if (frontmatterEnd === -1) {
    return content;
  }
  
  return content.substring(frontmatterEnd + 3).trim();
}

module.exports = {
  findMarkdownFiles,
  extractFrontmatter,
  extractContentBody
};
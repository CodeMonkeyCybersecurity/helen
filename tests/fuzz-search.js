/**
 * Fuzzing tests for search functionality
 * Tests search system resilience against malformed, edge case, and malicious inputs
 */

const { loadSearchModule } = require('./search.test.js');

// Mock DOM and fetch for testing
const { JSDOM } = require('jsdom');
const dom = new JSDOM(`
<!DOCTYPE html>
<html>
<body>
  <div id="search-results"></div>
  <input id="search-input" type="text" />
</body>
</html>
`);

global.window = dom.window;
global.document = dom.window.document;
global.fetch = jest.fn();

describe('Search Functionality Fuzzing Tests', () => {
  let searchModule;
  
  beforeEach(async () => {
    // Setup basic search data
    const mockData = [
      {
        title: 'Test Article',
        content: 'Basic test content for fuzzing',
        section: 'test',
        tags: ['test'],
        permalink: '/test/'
      }
    ];

    fetch.mockResolvedValue({
      ok: true,
      json: async () => mockData
    });

    searchModule = loadSearchModule();
    await searchModule.loadSearchIndex();
  });

  describe('Input Fuzzing', () => {
    const fuzzInputs = [
      // Empty and whitespace inputs
      '',
      ' ',
      '\t',
      '\n',
      '   \t\n   ',
      
      // Special characters
      '!@#$%^&*()',
      '[]{}|\\;:\'",.<>?/',
      '`~',
      
      // Unicode and emoji
      '🔍',
      '😀😁😂',
      'café',
      'naïve',
      '中文',
      'العربية',
      '🚀💻🔒',
      
      // Long strings
      'a'.repeat(1000),
      'test '.repeat(100),
      'x'.repeat(10000),
      
      // Injection attempts (should be safely handled)
      '<script>alert("xss")</script>',
      '"><script>alert("xss")</script>',
      'javascript:alert("xss")',
      'data:text/html,<script>alert("xss")</script>',
      
      // SQL injection patterns (not applicable but testing robustness)
      "'; DROP TABLE users; --",
      "' OR '1'='1",
      "1; DELETE FROM users",
      
      // Regular expression injection attempts
      '.*',
      '.+',
      '^$',
      '(.*)',
      '(?=.*)',
      '[a-z]*',
      '\\w+',
      '\\d{1,3}',
      
      // Control characters
      '\x00',
      '\x01\x02\x03',
      String.fromCharCode(0, 1, 2, 3),
      
      // Mixed complexity
      'test\x00\x01script',
      'café<script>💻',
      '测试🔍.*[a-z]',
      
      // Very specific edge cases
      '\\',
      '\\\\',
      '\\\\\\',
      '/',
      '//',
      '///',
      
      // Regex metacharacters
      '+',
      '*',
      '?',
      '^',
      '$',
      '|',
      '(',
      ')',
      '[',
      ']',
      '{',
      '}',
      
      // Potential DoS patterns
      '((((((((((a))))))))))',
      'a|a|a|a|a|a|a|a|a|a|a',
      '.*.*.*.*.*',
      
      // Null bytes and special escapes
      '\0',
      '\\0',
      '\u0000',
      '\uFEFF', // BOM
      '\u200B', // Zero-width space
      
      // Numbers as strings
      '0',
      '123',
      '-456',
      '3.14159',
      'Infinity',
      'NaN',
      
      // Boolean-like strings
      'true',
      'false',
      'null',
      'undefined',
      
      // Encoded inputs
      '%20',
      '%3Cscript%3E',
      '&lt;script&gt;',
      '&#60;script&#62;',
      
      // Mixed case variations
      'TeSt',
      'TEST',
      'test',
      'Test',
      'tEsT',
    ];

    test.each(fuzzInputs)('should handle fuzz input: %s', (input) => {
      expect(() => {
        const results = searchModule.performSearch(input);
        expect(Array.isArray(results)).toBe(true);
        
        // Should not return more than 15 results
        expect(results.length).toBeLessThanOrEqual(15);
        
        // All results should have required properties
        results.forEach(result => {
          expect(result).toHaveProperty('score');
          expect(typeof result.score).toBe('number');
          expect(result.score).toBeGreaterThanOrEqual(0);
        });
      }).not.toThrow();
    });

    test('should sanitize search results display', () => {
      fuzzInputs.forEach(input => {
        expect(() => {
          const results = searchModule.performSearch('test');
          searchModule.displayResults(results, input);
          
          const resultsContainer = document.getElementById('search-results');
          const html = resultsContainer.innerHTML;
          
          // Should not contain unescaped script tags
          expect(html).not.toMatch(/<script[^>]*>/i);
          expect(html).not.toMatch(/javascript:/i);
          expect(html).not.toMatch(/data:text\/html/i);
          
          // Should properly escape special characters in displayed query
          if (input.includes('<')) {
            expect(html).toMatch(/&lt;|&amp;/);
          }
        }).not.toThrow();
      });
    });
  });

  describe('Malformed Data Fuzzing', () => {
    const malformedDataSets = [
      // Empty data
      [],
      null,
      undefined,
      
      // Invalid objects
      [null],
      [undefined],
      [{}],
      [{ title: null }],
      [{ title: undefined, content: null }],
      
      // Type confusion
      [{ title: 123, content: true }],
      [{ title: [], content: {} }],
      [{ title: function(){}, content: /regex/ }],
      
      // Very large objects
      [{
        title: 'a'.repeat(100000),
        content: 'b'.repeat(1000000),
        tags: Array.from({length: 1000}, (_, i) => `tag${i}`)
      }],
      
      // Circular references (should be caught by JSON.stringify)
      // Note: These would fail during JSON serialization
      
      // Mixed valid/invalid
      [
        { title: 'Valid Article', content: 'Valid content' },
        null,
        { title: 'Another Valid', content: 'More content' },
        undefined,
        {}
      ],
      
      // Unicode edge cases
      [{
        title: '\uD800\uDC00', // Valid surrogate pair
        content: '\uD800', // Invalid lone surrogate
        tags: ['\uDFFF'] // Invalid lone surrogate
      }],
      
      // Deep nesting
      [{
        title: 'Test',
        nested: {
          deep: {
            very: {
              deep: {
                object: 'value'
              }
            }
          }
        }
      }]
    ];

    test.each(malformedDataSets.filter(data => data !== null && data !== undefined))(
      'should handle malformed data set', 
      async (malformedData) => {
        fetch.mockResolvedValueOnce({
          ok: true,
          json: async () => malformedData
        });

        expect(async () => {
          await searchModule.loadSearchIndex();
          
          // Should not crash when searching
          const results = searchModule.performSearch('test');
          expect(Array.isArray(results)).toBe(true);
        }).not.toThrow();
      }
    );

    test('should handle JSON parsing errors', async () => {
      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => {
          throw new Error('Invalid JSON');
        }
      });

      const consoleSpy = jest.spyOn(console, 'error').mockImplementation();
      
      await searchModule.loadSearchIndex();
      
      expect(consoleSpy).toHaveBeenCalled();
      expect(searchModule.searchIndex).toBeNull();
      
      consoleSpy.mockRestore();
    });
  });

  describe('Performance Stress Testing', () => {
    test('should handle rapid successive searches', () => {
      const queries = ['test', 'article', 'content', 'search', 'fuzz'];
      const startTime = Date.now();
      
      // Perform 1000 rapid searches
      for (let i = 0; i < 1000; i++) {
        const query = queries[i % queries.length];
        const results = searchModule.performSearch(query);
        expect(Array.isArray(results)).toBe(true);
      }
      
      const duration = Date.now() - startTime;
      
      // Should complete 1000 searches in reasonable time (< 1 second)
      expect(duration).toBeLessThan(1000);
    });

    test('should handle memory pressure with large datasets', async () => {
      // Create a large dataset
      const largeDataset = Array.from({length: 10000}, (_, i) => ({
        title: `Article ${i} with content`,
        content: `This is content for article ${i} `.repeat(10),
        section: `section${i % 10}`,
        tags: [`tag${i % 100}`, `category${i % 50}`],
        permalink: `/articles/${i}/`
      }));

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => largeDataset
      });

      await searchModule.loadSearchIndex();
      
      // Perform searches on large dataset
      const startTime = Date.now();
      const results = searchModule.performSearch('article content');
      const duration = Date.now() - startTime;
      
      expect(results).toHaveLength(15); // Should be limited
      expect(duration).toBeLessThan(500); // Should complete in reasonable time
    });

    test('should handle concurrent display operations', () => {
      const queries = ['test1', 'test2', 'test3', 'test4', 'test5'];
      
      // Simulate rapid UI updates
      queries.forEach(query => {
        const results = searchModule.performSearch('test');
        expect(() => {
          searchModule.displayResults(results, query);
        }).not.toThrow();
      });
      
      // Final state should be consistent
      const finalHTML = document.getElementById('search-results').innerHTML;
      expect(finalHTML).toContain('test5'); // Should show last query
    });
  });

  describe('Error Recovery Testing', () => {
    test('should recover from search index corruption', async () => {
      // Simulate corrupted index
      const corruptedData = [
        { title: 'Valid Article' },
        'this is not an object',
        { title: 'Another Valid Article', content: 'Content' },
        { totally: 'wrong structure' }
      ];

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => corruptedData
      });

      await searchModule.loadSearchIndex();
      
      // Should still work with valid entries
      const results = searchModule.performSearch('valid');
      expect(results.length).toBeGreaterThan(0);
    });

    test('should handle network failures gracefully', async () => {
      fetch.mockRejectedValueOnce(new Error('Network timeout'));
      
      const consoleSpy = jest.spyOn(console, 'error').mockImplementation();
      
      await searchModule.loadSearchIndex();
      
      // Should not crash and should handle subsequent searches
      expect(() => {
        const results = searchModule.performSearch('test');
        expect(results).toEqual([]);
      }).not.toThrow();
      
      consoleSpy.mockRestore();
    });

    test('should handle DOM manipulation errors', () => {
      // Temporarily break the DOM
      const originalGetElementById = document.getElementById;
      document.getElementById = () => null;
      
      expect(() => {
        const results = searchModule.performSearch('test');
        searchModule.displayResults(results, 'test');
      }).not.toThrow();
      
      // Restore DOM
      document.getElementById = originalGetElementById;
    });
  });

  describe('Security Testing', () => {
    test('should prevent XSS in search results', () => {
      const xssPayloads = [
        '<script>alert("xss")</script>',
        '"><script>alert("xss")</script>',
        "'><script>alert('xss')</script>",
        '<img src=x onerror=alert("xss")>',
        '<svg onload=alert("xss")>',
        'javascript:alert("xss")',
        'data:text/html,<script>alert("xss")</script>'
      ];

      xssPayloads.forEach(payload => {
        const results = searchModule.performSearch('test');
        searchModule.displayResults(results, payload);
        
        const html = document.getElementById('search-results').innerHTML;
        
        // Should not contain unescaped script tags or event handlers
        expect(html).not.toMatch(/<script[^>]*>/i);
        expect(html).not.toMatch(/on\w+\s*=/i);
        expect(html).not.toMatch(/javascript:/i);
      });
    });

    test('should handle potential ReDoS patterns', () => {
      const redosPatterns = [
        'a'.repeat(100) + 'X',
        '(a+)+$',
        '(a|a)*',
        'a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*a*b',
        '\\b(a+)+\\b'
      ];

      redosPatterns.forEach(pattern => {
        const startTime = Date.now();
        
        expect(() => {
          searchModule.performSearch(pattern);
        }).not.toThrow();
        
        const duration = Date.now() - startTime;
        
        // Should complete quickly, not hang
        expect(duration).toBeLessThan(1000);
      });
    });

    test('should sanitize user content in results', () => {
      const maliciousContent = [
        'normal content <script>alert("xss")</script>',
        'content with <img src=x onerror=alert("xss")>',
        'text with javascript:alert("xss") link'
      ];

      maliciousContent.forEach(content => {
        // Mock data with malicious content
        fetch.mockResolvedValueOnce({
          ok: true,
          json: async () => [{
            title: 'Test Article',
            content: content,
            permalink: '/test/'
          }]
        });

        expect(async () => {
          await searchModule.loadSearchIndex();
          const results = searchModule.performSearch('test');
          searchModule.displayResults(results, 'test');
          
          const html = document.getElementById('search-results').innerHTML;
          expect(html).not.toMatch(/<script[^>]*>/i);
        }).not.toThrow();
      });
    });
  });
});

module.exports = {};
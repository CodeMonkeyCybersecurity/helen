/**
 * Search functionality tests for Hugo-based search system
 * Tests both client-side search logic and search index generation
 */

// Mock DOM environment for testing
const { JSDOM } = require('jsdom');
const fs = require('fs');
const path = require('path');

// Setup DOM environment
const dom = new JSDOM(`
<!DOCTYPE html>
<html>
<head><title>Test</title></head>
<body>
  <div id="search-results"></div>
  <input id="search-input" type="text" />
  <form class="search-form"></form>
</body>
</html>
`);

global.window = dom.window;
global.document = dom.window.document;
global.fetch = jest.fn();

describe('Search Functionality Tests', () => {
  let searchModule;
  
  beforeEach(() => {
    // Reset DOM state
    document.getElementById('search-results').innerHTML = '';
    document.getElementById('search-input').value = '';
    
    // Reset fetch mock
    fetch.mockClear();
    
    // Load search functionality (extracted from search template)
    searchModule = loadSearchModule();
  });

  describe('Search Index Loading', () => {
    test('should load search index from /index.json', async () => {
      const mockSearchData = [
        {
          title: 'Cybersecurity Guide',
          content: 'Complete guide to cybersecurity best practices',
          section: 'resources',
          tags: ['security', 'guide'],
          permalink: '/resources/security-guide/'
        }
      ];

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => mockSearchData
      });

      await searchModule.loadSearchIndex();
      
      expect(fetch).toHaveBeenCalledWith('/index.json');
      expect(searchModule.searchIndex).toHaveLength(1);
      expect(searchModule.searchIndex[0].title).toBe('Cybersecurity Guide');
    });

    test('should handle search index loading errors', async () => {
      fetch.mockRejectedValueOnce(new Error('Network error'));
      
      const consoleSpy = jest.spyOn(console, 'error').mockImplementation();
      
      await searchModule.loadSearchIndex();
      
      expect(consoleSpy).toHaveBeenCalledWith('Failed to load search index:', expect.any(Error));
      expect(searchModule.searchIndex).toBeNull();
      
      consoleSpy.mockRestore();
    });

    test('should normalize search text properly', async () => {
      const mockData = [{
        title: 'Test Article!',
        content: 'This is test content with special chars: @#$%',
        tags: ['test', 'article'],
        section: 'blog'
      }];

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => mockData
      });

      await searchModule.loadSearchIndex();
      
      const searchText = searchModule.searchIndex[0].searchText;
      expect(searchText).not.toContain('!');
      expect(searchText).not.toContain('@');
      expect(searchText).toContain('test article');
      expect(searchText).toContain('test content');
    });
  });

  describe('Search Algorithm', () => {
    beforeEach(async () => {
      const mockSearchData = [
        {
          title: 'Cybersecurity Best Practices',
          content: 'Learn about cybersecurity fundamentals and security practices',
          summary: 'Essential cybersecurity guide',
          section: 'resources',
          tags: ['cybersecurity', 'security', 'guide'],
          permalink: '/resources/cybersecurity-practices/'
        },
        {
          title: 'Phishing Protection Guide',
          content: 'How to protect against phishing attacks and email security',
          summary: 'Phishing prevention techniques',
          section: 'education',
          tags: ['phishing', 'email', 'security'],
          permalink: '/education/phishing-guide/'
        },
        {
          title: 'Backup Solutions',
          content: 'Data backup strategies and recovery solutions',
          summary: 'Comprehensive backup guide',
          section: 'services',
          tags: ['backup', 'data', 'recovery'],
          permalink: '/services/backup/'
        }
      ];

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => mockSearchData
      });

      await searchModule.loadSearchIndex();
    });

    test('should find exact title matches with highest scores', () => {
      const results = searchModule.performSearch('cybersecurity');
      
      expect(results).toHaveLength(2); // cybersecurity appears in 2 documents
      expect(results[0].title).toBe('Cybersecurity Best Practices');
      expect(results[0].score).toBeGreaterThan(results[1].score);
    });

    test('should handle multi-term searches', () => {
      const results = searchModule.performSearch('phishing email');
      
      expect(results).toHaveLength(1);
      expect(results[0].title).toBe('Phishing Protection Guide');
      expect(results[0].matchedTerms).toBe(2);
    });

    test('should apply relevance scoring correctly', () => {
      const results = searchModule.performSearch('security');
      
      // Should find multiple results
      expect(results.length).toBeGreaterThan(1);
      
      // Results should be sorted by score (descending)
      for (let i = 1; i < results.length; i++) {
        expect(results[i-1].score).toBeGreaterThanOrEqual(results[i].score);
      }
    });

    test('should limit results to 15 items', () => {
      // Create mock data with 20 items
      const largeDataset = Array.from({length: 20}, (_, i) => ({
        title: `Article ${i}`,
        content: 'security content here',
        section: 'blog',
        tags: ['security'],
        permalink: `/blog/article-${i}/`
      }));

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => largeDataset
      });

      return searchModule.loadSearchIndex().then(() => {
        const results = searchModule.performSearch('security');
        expect(results).toHaveLength(15);
      });
    });

    test('should handle empty queries', () => {
      expect(searchModule.performSearch('')).toEqual([]);
      expect(searchModule.performSearch('   ')).toEqual([]);
    });

    test('should handle single character queries', () => {
      expect(searchModule.performSearch('a')).toEqual([]);
    });

    test('should escape regex special characters', () => {
      const results = searchModule.performSearch('C++');
      expect(() => searchModule.performSearch('C++')).not.toThrow();
    });
  });

  describe('Search Results Display', () => {
    beforeEach(async () => {
      const mockData = [{
        title: 'Test Article',
        content: 'This is test content about cybersecurity',
        summary: 'Test summary',
        section: 'blog',
        tags: ['test'],
        permalink: '/blog/test-article/',
        date: '2024-01-01'
      }];

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => mockData
      });

      await searchModule.loadSearchIndex();
    });

    test('should display search results with highlighting', () => {
      const results = searchModule.performSearch('test');
      searchModule.displayResults(results, 'test');
      
      const resultsContainer = document.getElementById('search-results');
      expect(resultsContainer.innerHTML).toContain('<mark>test</mark>');
      expect(resultsContainer.innerHTML).toContain('Test Article');
    });

    test('should show no results message for empty results', () => {
      searchModule.displayResults([], 'nonexistent');
      
      const resultsContainer = document.getElementById('search-results');
      expect(resultsContainer.innerHTML).toContain('No results found');
      expect(resultsContainer.innerHTML).toContain('nonexistent');
    });

    test('should include popular search suggestions in no results', () => {
      searchModule.displayResults([], 'xyz');
      
      const resultsContainer = document.getElementById('search-results');
      expect(resultsContainer.innerHTML).toContain('Popular searches');
      expect(resultsContainer.innerHTML).toContain('delphi');
      expect(resultsContainer.innerHTML).toContain('phishing');
    });

    test('should format metadata correctly', () => {
      const results = searchModule.performSearch('test');
      searchModule.displayResults(results, 'test');
      
      const resultsContainer = document.getElementById('search-results');
      expect(resultsContainer.innerHTML).toContain('Blog'); // Capitalized section
      expect(resultsContainer.innerHTML).toContain('1/1/2024'); // Formatted date
    });
  });

  describe('Edge Cases and Error Handling', () => {
    test('should handle malformed search index data', async () => {
      const malformedData = [
        { title: null, content: undefined },
        { title: 'Valid Article', content: 'Valid content' }
      ];

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => malformedData
      });

      await searchModule.loadSearchIndex();
      
      // Should not crash and should handle valid data
      expect(searchModule.searchIndex).toHaveLength(2);
      const results = searchModule.performSearch('valid');
      expect(results).toHaveLength(1);
    });

    test('should handle very long search queries', () => {
      const longQuery = 'a'.repeat(1000);
      expect(() => searchModule.performSearch(longQuery)).not.toThrow();
    });

    test('should handle special characters in search', () => {
      const specialChars = '!@#$%^&*()[]{}|;:,.<>?';
      expect(() => searchModule.performSearch(specialChars)).not.toThrow();
    });
  });

  describe('Performance Tests', () => {
    test('should complete search within reasonable time', async () => {
      // Create large dataset
      const largeDataset = Array.from({length: 1000}, (_, i) => ({
        title: `Article ${i}`,
        content: `Content for article ${i} with various keywords`,
        section: 'blog',
        tags: [`tag${i % 10}`],
        permalink: `/blog/article-${i}/`
      }));

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => largeDataset
      });

      await searchModule.loadSearchIndex();
      
      const start = Date.now();
      searchModule.performSearch('article');
      const duration = Date.now() - start;
      
      // Should complete within 100ms for 1000 items
      expect(duration).toBeLessThan(100);
    });

    test('should handle concurrent searches', async () => {
      const mockData = [{
        title: 'Test Article',
        content: 'test content',
        section: 'blog',
        permalink: '/test/'
      }];

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => mockData
      });

      await searchModule.loadSearchIndex();
      
      // Run multiple searches concurrently
      const searches = Promise.all([
        Promise.resolve(searchModule.performSearch('test')),
        Promise.resolve(searchModule.performSearch('article')),
        Promise.resolve(searchModule.performSearch('content'))
      ]);

      expect(async () => await searches).not.toThrow();
    });
  });
});

/**
 * Load search module functionality
 * This extracts the search logic from the Hugo template for testing
 */
function loadSearchModule() {
  let searchIndex = null;
  let searchData = null;

  async function loadSearchIndex() {
    try {
      const response = await fetch('/index.json');
      searchData = await response.json();
      
      searchIndex = searchData.map((item, index) => ({
        ...item,
        searchText: [
          item.title || '',
          item.summary || '',
          item.content || '',
          (item.tags || []).join(' '),
          (item.categories || []).join(' '),
          item.section || ''
        ].join(' ').toLowerCase().replace(/[^\w\s]/g, ' ').replace(/\s+/g, ' '),
        index: index
      }));
      
      console.log('Search index loaded:', searchIndex.length, 'items');
    } catch (error) {
      console.error('Failed to load search index:', error);
    }
  }

  function performSearch(query) {
    if (!searchIndex || !query.trim()) {
      return [];
    }
    
    const normalizedQuery = query.toLowerCase().replace(/[^\w\s]/g, ' ').replace(/\s+/g, ' ').trim();
    const terms = normalizedQuery.split(' ').filter(term => term.length > 1);
    const results = [];
    
    searchIndex.forEach(item => {
      let score = 0;
      let matchedTerms = 0;
      
      terms.forEach(term => {
        const termRegex = new RegExp(term.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'gi');
        
        const titleMatches = (item.title || '').match(termRegex) || [];
        const summaryMatches = (item.summary || '').match(termRegex) || [];
        const contentMatches = (item.content || '').match(termRegex) || [];
        const tagMatches = (item.tags || []).join(' ').match(termRegex) || [];
        const sectionMatches = (item.section || '').match(termRegex) || [];
        
        if (titleMatches.length > 0) {
          score += titleMatches.length * 15;
          matchedTerms++;
        }
        if (summaryMatches.length > 0) {
          score += summaryMatches.length * 8;
          matchedTerms++;
        }
        if (contentMatches.length > 0) {
          score += Math.min(contentMatches.length, 10) * 2;
          matchedTerms++;
        }
        if (tagMatches.length > 0) {
          score += tagMatches.length * 5;
          matchedTerms++;
        }
        if (sectionMatches.length > 0) {
          score += sectionMatches.length * 3;
          matchedTerms++;
        }
      });
      
      if (matchedTerms > 1) {
        score += matchedTerms * 5;
      }
      
      if (matchedTerms > 0) {
        results.push({ ...item, score, matchedTerms });
      }
    });
    
    return results.sort((a, b) => {
      if (b.score !== a.score) return b.score - a.score;
      return new Date(b.date || 0) - new Date(a.date || 0);
    }).slice(0, 15);
  }

  function displayResults(results, query) {
    const searchResults = document.getElementById('search-results');
    
    if (results.length === 0) {
      searchResults.innerHTML = `
        <div class="search-no-results">
          <h2>No results found for "${query}"</h2>
          <p>Try different keywords or browse our <a href="/resources/">resources</a> and <a href="/blog/">blog posts</a>.</p>
          <div class="search-suggestions">
            <h3>Popular searches:</h3>
            <ul>
              <li><a href="/search/?q=delphi">Delphi XDR</a></li>
              <li><a href="/search/?q=phishing">Phishing protection</a></li>
              <li><a href="/search/?q=backup">Backup services</a></li>
              <li><a href="/search/?q=training">Security training</a></li>
            </ul>
          </div>
        </div>`;
      return;
    }
    
    const resultsHTML = results.map(result => {
      let excerpt = result.summary || result.content;
      if (excerpt.length > 200) {
        excerpt = excerpt.substring(0, 200) + '...';
      }
      
      const terms = query.toLowerCase().split(' ').filter(term => term.length > 1);
      let highlightedTitle = result.title;
      let highlightedExcerpt = excerpt;
      
      terms.forEach(term => {
        const regex = new RegExp(`(${term.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')})`, 'gi');
        highlightedTitle = highlightedTitle.replace(regex, '<mark>$1</mark>');
        highlightedExcerpt = highlightedExcerpt.replace(regex, '<mark>$1</mark>');
      });
      
      const sectionName = result.section ? result.section.charAt(0).toUpperCase() + result.section.slice(1) : 'Page';
      const dateString = result.date ? new Date(result.date).toLocaleDateString() : '';
      
      return `
        <div class="search-result">
          <h3 class="search-result-title">
            <a href="${result.permalink}">${highlightedTitle}</a>
          </h3>
          <p class="search-result-excerpt">${highlightedExcerpt}</p>
          <div class="search-result-meta">
            <span class="search-result-section">${sectionName}</span>
            ${dateString ? `<span class="search-result-date">${dateString}</span>` : ''}
            ${result.tags && result.tags.length > 0 ? `<span class="search-result-tags">${result.tags.slice(0, 3).join(', ')}</span>` : ''}
          </div>
        </div>`;
    }).join('');
    
    searchResults.innerHTML = `
      <div class="search-results-header">
        <h2>Search Results for "${query}"</h2>
        <p>${results.length} result${results.length !== 1 ? 's' : ''} found</p>
      </div>
      <div class="search-results-list">${resultsHTML}</div>`;
  }

  return {
    loadSearchIndex,
    performSearch,
    displayResults,
    get searchIndex() { return searchIndex; },
    get searchData() { return searchData; }
  };
}

module.exports = { loadSearchModule };
/**
 * Performance tests for Hugo site and search functionality
 * Tests build time, search performance, and resource optimization
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const { loadSearchModule } = require('./search.test.js');

// Mock DOM for search tests
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

describe('Performance Tests', () => {
  const projectRoot = path.resolve(__dirname, '..');
  
  describe('Hugo Build Performance', () => {
    test('build should complete within reasonable time', () => {
      const startTime = Date.now();
      
      execSync('hugo --quiet --minify', {
        cwd: projectRoot,
        stdio: 'pipe'
      });
      
      const buildTime = Date.now() - startTime;
      
      // Should build in under 10 seconds for typical content
      expect(buildTime).toBeLessThan(10000);
      
      console.log(`Build completed in ${buildTime}ms`);
    });

    test('incremental builds should be fast', () => {
      // Initial build
      execSync('hugo --quiet', { cwd: projectRoot });
      
      // Touch a content file
      const testFile = path.join(projectRoot, 'content', '_index.md');
      const content = fs.readFileSync(testFile, 'utf8');
      fs.writeFileSync(testFile, content); // Touch file
      
      const startTime = Date.now();
      
      execSync('hugo --quiet', { cwd: projectRoot });
      
      const incrementalTime = Date.now() - startTime;
      
      // Incremental builds should be much faster
      expect(incrementalTime).toBeLessThan(3000);
      
      console.log(`Incremental build completed in ${incrementalTime}ms`);
    });

    test('build with drafts should not significantly impact performance', () => {
      const startTimeNoDrafts = Date.now();
      execSync('hugo --quiet', { cwd: projectRoot });
      const buildTimeNoDrafts = Date.now() - startTimeNoDrafts;
      
      const startTimeWithDrafts = Date.now();
      execSync('hugo --quiet --buildDrafts', { cwd: projectRoot });
      const buildTimeWithDrafts = Date.now() - startTimeWithDrafts;
      
      // Building with drafts should not be more than 50% slower
      expect(buildTimeWithDrafts).toBeLessThan(buildTimeNoDrafts * 1.5);
      
      console.log(`Build without drafts: ${buildTimeNoDrafts}ms`);
      console.log(`Build with drafts: ${buildTimeWithDrafts}ms`);
    });
  });

  describe('Search Index Performance', () => {
    test('search index generation should be efficient', () => {
      execSync('hugo --quiet', { cwd: projectRoot });
      
      const indexPath = path.join(projectRoot, 'public', 'index.json');
      const stats = fs.statSync(indexPath);
      
      // Index should be reasonably sized
      expect(stats.size).toBeLessThan(1024 * 1024); // Under 1MB
      expect(stats.size).toBeGreaterThan(100); // Not empty
      
      // Should be valid JSON
      const indexContent = fs.readFileSync(indexPath, 'utf8');
      expect(() => JSON.parse(indexContent)).not.toThrow();
      
      const searchIndex = JSON.parse(indexContent);
      
      // Performance characteristics
      console.log(`Search index size: ${(stats.size / 1024).toFixed(2)}KB`);
      console.log(`Search index entries: ${searchIndex.length}`);
      console.log(`Average entry size: ${(stats.size / searchIndex.length).toFixed(2)} bytes`);
    });

    test('search index loading should be fast', async () => {
      const mockData = Array.from({length: 1000}, (_, i) => ({
        title: `Article ${i}`,
        content: `Content for article ${i} with various keywords`,
        section: 'blog',
        tags: [`tag${i % 10}`],
        permalink: `/blog/article-${i}/`
      }));

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => mockData
      });

      const searchModule = loadSearchModule();
      
      const startTime = Date.now();
      await searchModule.loadSearchIndex();
      const loadTime = Date.now() - startTime;
      
      // Should load and process 1000 items quickly
      expect(loadTime).toBeLessThan(500);
      expect(searchModule.searchIndex).toHaveLength(1000);
      
      console.log(`Search index loaded in ${loadTime}ms`);
    });
  });

  describe('Search Performance', () => {
    let searchModule;
    
    beforeEach(async () => {
      // Create large dataset for performance testing
      const largeDataset = Array.from({length: 5000}, (_, i) => ({
        title: `Article ${i} about cybersecurity`,
        content: `This is content for article ${i} discussing security topics, cybersecurity best practices, and various technical subjects. Keywords include: security, testing, performance, optimization, search.`,
        summary: `Summary for article ${i}`,
        section: `section${i % 10}`,
        tags: [`tag${i % 100}`, `category${i % 50}`, 'security'],
        categories: [`cat${i % 25}`],
        permalink: `/articles/${i}/`,
        date: new Date(2024, i % 12, (i % 28) + 1).toISOString()
      }));

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => largeDataset
      });

      searchModule = loadSearchModule();
      await searchModule.loadSearchIndex();
    });

    test('single term search should be fast', () => {
      const startTime = Date.now();
      const results = searchModule.performSearch('cybersecurity');
      const searchTime = Date.now() - startTime;
      
      expect(searchTime).toBeLessThan(50); // Should complete in under 50ms
      expect(results.length).toBeGreaterThan(0);
      expect(results.length).toBeLessThanOrEqual(15); // Limited results
      
      console.log(`Single term search completed in ${searchTime}ms, found ${results.length} results`);
    });

    test('multi-term search should remain performant', () => {
      const startTime = Date.now();
      const results = searchModule.performSearch('cybersecurity security best practices');
      const searchTime = Date.now() - startTime;
      
      expect(searchTime).toBeLessThan(100); // Should complete in under 100ms
      expect(results.length).toBeGreaterThan(0);
      
      console.log(`Multi-term search completed in ${searchTime}ms, found ${results.length} results`);
    });

    test('complex search should not cause performance degradation', () => {
      const complexQueries = [
        'cybersecurity best practices security testing',
        'security optimization performance search',
        'technical subjects keywords security',
        'article content discussion topics',
        'various technical cybersecurity practices'
      ];
      
      const startTime = Date.now();
      
      complexQueries.forEach(query => {
        const results = searchModule.performSearch(query);
        expect(results.length).toBeLessThanOrEqual(15);
      });
      
      const totalTime = Date.now() - startTime;
      const avgTime = totalTime / complexQueries.length;
      
      expect(avgTime).toBeLessThan(50); // Average under 50ms per search
      
      console.log(`Complex searches avg time: ${avgTime.toFixed(2)}ms`);
    });

    test('rapid successive searches should not degrade performance', () => {
      const queries = ['test', 'security', 'article', 'content', 'cybersecurity'];
      const searchTimes = [];
      
      // Perform 100 rapid searches
      for (let i = 0; i < 100; i++) {
        const query = queries[i % queries.length];
        const startTime = Date.now();
        searchModule.performSearch(query);
        const searchTime = Date.now() - startTime;
        searchTimes.push(searchTime);
      }
      
      const avgTime = searchTimes.reduce((sum, time) => sum + time, 0) / searchTimes.length;
      const maxTime = Math.max(...searchTimes);
      
      expect(avgTime).toBeLessThan(10); // Average under 10ms
      expect(maxTime).toBeLessThan(50); // No single search over 50ms
      
      console.log(`100 rapid searches - avg: ${avgTime.toFixed(2)}ms, max: ${maxTime}ms`);
    });

    test('search result display should be efficient', () => {
      const results = searchModule.performSearch('security');
      
      const startTime = Date.now();
      searchModule.displayResults(results, 'security');
      const displayTime = Date.now() - startTime;
      
      expect(displayTime).toBeLessThan(20); // Should render quickly
      
      const resultsContainer = document.getElementById('search-results');
      expect(resultsContainer.innerHTML.length).toBeGreaterThan(0);
      
      console.log(`Search results displayed in ${displayTime}ms`);
    });
  });

  describe('Memory Usage', () => {
    test('search index should not consume excessive memory', async () => {
      const memBefore = process.memoryUsage().heapUsed;
      
      // Load large dataset
      const largeDataset = Array.from({length: 10000}, (_, i) => ({
        title: `Article ${i}`,
        content: `Content ${i} `.repeat(50), // Longer content
        section: 'blog',
        tags: [`tag${i}`],
        permalink: `/blog/${i}/`
      }));

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => largeDataset
      });

      const searchModule = loadSearchModule();
      await searchModule.loadSearchIndex();
      
      const memAfter = process.memoryUsage().heapUsed;
      const memUsed = memAfter - memBefore;
      
      // Should not use more than 50MB for 10k articles
      expect(memUsed).toBeLessThan(50 * 1024 * 1024);
      
      console.log(`Memory used for 10k articles: ${(memUsed / 1024 / 1024).toFixed(2)}MB`);
    });

    test('repeated searches should not leak memory', async () => {
      const mockData = Array.from({length: 1000}, (_, i) => ({
        title: `Article ${i}`,
        content: `Content ${i}`,
        section: 'blog',
        permalink: `/blog/${i}/`
      }));

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => mockData
      });

      const searchModule = loadSearchModule();
      await searchModule.loadSearchIndex();
      
      const memBefore = process.memoryUsage().heapUsed;
      
      // Perform many searches
      for (let i = 0; i < 1000; i++) {
        searchModule.performSearch(`article ${i % 100}`);
      }
      
      // Force garbage collection if available
      if (global.gc) {
        global.gc();
      }
      
      const memAfter = process.memoryUsage().heapUsed;
      const memIncrease = memAfter - memBefore;
      
      // Memory increase should be minimal
      expect(memIncrease).toBeLessThan(10 * 1024 * 1024); // Under 10MB
      
      console.log(`Memory increase after 1000 searches: ${(memIncrease / 1024 / 1024).toFixed(2)}MB`);
    });
  });

  describe('Asset Optimization', () => {
    test('generated CSS should be optimized', () => {
      execSync('hugo --quiet --minify', { cwd: projectRoot });
      
      const cssDir = path.join(projectRoot, 'public', 'css');
      if (fs.existsSync(cssDir)) {
        const cssFiles = fs.readdirSync(cssDir).filter(f => f.endsWith('.css'));
        
        cssFiles.forEach(cssFile => {
          const cssPath = path.join(cssDir, cssFile);
          const stats = fs.statSync(cssPath);
          const content = fs.readFileSync(cssPath, 'utf8');
          
          // Should be minified (no excessive whitespace)
          const whitespaceRatio = (content.match(/\s/g) || []).length / content.length;
          expect(whitespaceRatio).toBeLessThan(0.3); // Less than 30% whitespace
          
          // Should be reasonably sized
          expect(stats.size).toBeLessThan(500 * 1024); // Under 500KB
          
          console.log(`CSS file ${cssFile}: ${(stats.size / 1024).toFixed(2)}KB`);
        });
      }
    });

    test('search page should load efficiently', () => {
      execSync('hugo --quiet --minify', { cwd: projectRoot });
      
      const searchPagePath = path.join(projectRoot, 'public', 'search', 'index.html');
      if (fs.existsSync(searchPagePath)) {
        const stats = fs.statSync(searchPagePath);
        const content = fs.readFileSync(searchPagePath, 'utf8');
        
        // Should be reasonably sized
        expect(stats.size).toBeLessThan(100 * 1024); // Under 100KB
        
        // Should be minified
        expect(content).not.toMatch(/\n\s+\n/); // No empty lines with whitespace
        
        console.log(`Search page size: ${(stats.size / 1024).toFixed(2)}KB`);
      }
    });
  });

  describe('Concurrent Operations', () => {
    test('should handle concurrent search operations', async () => {
      const mockData = Array.from({length: 1000}, (_, i) => ({
        title: `Article ${i}`,
        content: `Content ${i}`,
        section: 'blog',
        permalink: `/blog/${i}/`
      }));

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => mockData
      });

      const searchModule = loadSearchModule();
      await searchModule.loadSearchIndex();
      
      const startTime = Date.now();
      
      // Simulate concurrent searches
      const promises = Array.from({length: 10}, (_, i) => 
        Promise.resolve(searchModule.performSearch(`article ${i}`))
      );
      
      const results = await Promise.all(promises);
      const concurrentTime = Date.now() - startTime;
      
      expect(results).toHaveLength(10);
      results.forEach(result => {
        expect(Array.isArray(result)).toBe(true);
      });
      
      expect(concurrentTime).toBeLessThan(100); // Should complete quickly
      
      console.log(`10 concurrent searches completed in ${concurrentTime}ms`);
    });

    test('should handle concurrent display operations', async () => {
      const mockData = [{
        title: 'Test Article',
        content: 'Test content',
        section: 'blog',
        permalink: '/test/'
      }];

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => mockData
      });

      const searchModule = loadSearchModule();
      await searchModule.loadSearchIndex();
      
      const startTime = Date.now();
      
      // Simulate rapid UI updates
      for (let i = 0; i < 50; i++) {
        const results = searchModule.performSearch('test');
        searchModule.displayResults(results, `query${i}`);
      }
      
      const updateTime = Date.now() - startTime;
      
      expect(updateTime).toBeLessThan(200); // Should handle rapid updates
      
      console.log(`50 rapid display updates completed in ${updateTime}ms`);
    });
  });
});

module.exports = {};
/**
 * Jest setup file for Hugo website tests
 * Configures global test environment and utilities
 */

// Mock console methods to reduce noise in tests
global.console = {
  ...console,
  log: jest.fn(),
  warn: jest.fn(),
  error: jest.fn(),
  info: jest.fn(),
  debug: jest.fn()
};

// Mock fetch globally
global.fetch = jest.fn();

// Mock DOM APIs that might not be available in JSDOM
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: jest.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: jest.fn(), // deprecated
    removeListener: jest.fn(), // deprecated
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    dispatchEvent: jest.fn(),
  })),
});

// Mock IntersectionObserver
global.IntersectionObserver = class IntersectionObserver {
  constructor() {}
  disconnect() {}
  observe() {}
  unobserve() {}
};

// Mock ResizeObserver
global.ResizeObserver = class ResizeObserver {
  constructor() {}
  disconnect() {}
  observe() {}
  unobserve() {}
};

// Add custom Jest matchers
expect.extend({
  toBeValidUrl(received) {
    try {
      new URL(received);
      return {
        message: () => `expected ${received} not to be a valid URL`,
        pass: true,
      };
    } catch (error) {
      return {
        message: () => `expected ${received} to be a valid URL`,
        pass: false,
      };
    }
  },
  
  toBeValidHtml(received) {
    // Basic HTML validation
    const hasDoctype = /<!DOCTYPE html>/i.test(received);
    const hasHtmlTag = /<html[^>]*>/i.test(received);
    const hasClosingHtml = /<\/html>/i.test(received);
    const hasHead = /<head>/i.test(received);
    const hasBody = /<body[^>]*>/i.test(received);
    
    const isValid = hasDoctype && hasHtmlTag && hasClosingHtml && hasHead && hasBody;
    
    return {
      message: () => `expected ${received} to be valid HTML`,
      pass: isValid,
    };
  },
  
  toHaveAccessibleName(received) {
    // Check if element has accessible name
    const hasAriaLabel = received.hasAttribute('aria-label');
    const hasAriaLabelledby = received.hasAttribute('aria-labelledby');
    const hasTitle = received.hasAttribute('title');
    const hasAssociatedLabel = received.id && 
      document.querySelector(`label[for="${received.id}"]`);
    
    const hasAccessibleName = hasAriaLabel || hasAriaLabelledby || hasTitle || hasAssociatedLabel;
    
    return {
      message: () => `expected element to have accessible name`,
      pass: hasAccessibleName,
    };
  }
});

// Global test helpers
global.testHelpers = {
  // Create a mock DOM element
  createElement: (tag, attributes = {}, content = '') => {
    const element = document.createElement(tag);
    Object.keys(attributes).forEach(key => {
      element.setAttribute(key, attributes[key]);
    });
    if (content) {
      element.textContent = content;
    }
    return element;
  },
  
  // Wait for async operations
  waitFor: (condition, timeout = 5000) => {
    return new Promise((resolve, reject) => {
      const start = Date.now();
      const check = () => {
        if (condition()) {
          resolve();
        } else if (Date.now() - start > timeout) {
          reject(new Error('Timeout waiting for condition'));
        } else {
          setTimeout(check, 10);
        }
      };
      check();
    });
  },
  
  // Mock Hugo frontmatter
  createMockFrontmatter: (overrides = {}) => ({
    title: 'Test Article',
    date: '2024-01-01',
    draft: false,
    tags: ['test'],
    categories: ['testing'],
    ...overrides
  }),
  
  // Mock search data
  createMockSearchData: (count = 10) => {
    return Array.from({length: count}, (_, i) => ({
      title: `Test Article ${i}`,
      content: `This is test content for article ${i}`,
      summary: `Summary for article ${i}`,
      section: 'blog',
      tags: [`tag${i}`, 'test'],
      categories: ['testing'],
      permalink: `/blog/test-article-${i}/`,
      date: '2024-01-01'
    }));
  }
};

// Clean up after each test
afterEach(() => {
  // Reset all mocks
  jest.clearAllMocks();
  
  // Reset DOM
  if (document.body) {
    document.body.innerHTML = '';
  }
  
  // Reset fetch mock
  if (global.fetch && global.fetch.mockReset) {
    global.fetch.mockReset();
  }
});

// Global test configuration
jest.setTimeout(30000); // 30 second timeout for all tests
---
title: "Search"
type: "search"
layout: "single"
url: "/search/"
---

# Search

Find what you're looking for across our documentation, guides, and resources.

<div id="search-container">
  <form id="search-form" class="search-form">
    <div class="search-input-group">
      <input 
        type="search" 
        id="search-input" 
        name="q"
        class="search-input" 
        placeholder="Search documentation, guides, and resources..."
        autocomplete="off"
        aria-label="Search query"
      >
      <button type="submit" class="search-button" aria-label="Search">
        Search
      </button>
    </div>
  </form>
  
  <div id="search-results" class="search-results">
    <div id="search-results-list" class="search-results-list"></div>
  </div>
  
  <div class="search-tips">
    <h3>Search Tips</h3>
    <ul>
      <li>Use specific terms for better results</li>
      <li>Try different keywords if you don't find what you're looking for</li>
      <li>Browse our <a href="/resources/">resources section</a> for guides and documentation</li>
      <li>Check our <a href="/blog/">blog</a> for the latest news and updates</li>
    </ul>
  </div>
</div>

<script>
// Progressive enhancement - search functionality
(function() {
  const searchForm = document.getElementById('search-form');
  const searchInput = document.getElementById('search-input');
  const searchResults = document.getElementById('search-results-list');
  
  if (!searchForm || !searchInput || !searchResults) return;
  
  let searchIndex = null;
  
  // Load search index
  async function loadSearchIndex() {
    try {
      const response = await fetch('/index.json');
      searchIndex = await response.json();
    } catch (error) {
      console.warn('Search index not available:', error);
    }
  }
  
  // Simple search function
  function searchContent(query) {
    if (!searchIndex || !query.trim()) return [];
    
    const normalizedQuery = query.toLowerCase();
    const results = [];
    
    for (const page of searchIndex) {
      let score = 0;
      const titleMatch = page.title.toLowerCase().includes(normalizedQuery);
      const contentMatch = page.content.toLowerCase().includes(normalizedQuery);
      const summaryMatch = page.summary.toLowerCase().includes(normalizedQuery);
      
      if (titleMatch) score += 3;
      if (summaryMatch) score += 2;
      if (contentMatch) score += 1;
      
      if (score > 0) {
        results.push({ ...page, score });
      }
    }
    
    return results.sort((a, b) => b.score - a.score).slice(0, 15);
  }
  
  // Display search results
  function displayResults(results, query) {
    if (results.length === 0) {
      searchResults.innerHTML = `
        <div class="no-results">
          <p>No results found for "${query}"</p>
          <p>Try different keywords or browse our <a href="/resources/">resources</a>.</p>
        </div>
      `;
      return;
    }
    
    const resultsHtml = results.map(result => `
      <div class="search-result">
        <h3 class="search-result-title">
          <a href="${result.url}">${result.title}</a>
        </h3>
        <p class="search-result-excerpt">${result.summary || result.content}</p>
        <div class="search-result-meta">
          <span class="search-result-section">${result.section}</span>
          <span class="search-result-date">${result.date}</span>
        </div>
      </div>
    `).join('');
    
    searchResults.innerHTML = resultsHtml;
  }
  
  // Handle search
  function handleSearch(event) {
    event.preventDefault();
    const query = searchInput.value.trim();
    
    if (!query) return;
    
    if (searchIndex) {
      const results = searchContent(query);
      displayResults(results, query);
    } else {
      // Fallback: redirect to search URL with query parameter
      window.location.href = `/search/?q=${encodeURIComponent(query)}`;
    }
  }
  
  // Handle URL parameters
  function handleUrlParams() {
    const urlParams = new URLSearchParams(window.location.search);
    const query = urlParams.get('q');
    
    if (query) {
      searchInput.value = query;
      if (searchIndex) {
        const results = searchContent(query);
        displayResults(results, query);
      }
    }
  }
  
  // Initialize
  searchForm.addEventListener('submit', handleSearch);
  loadSearchIndex().then(() => {
    handleUrlParams();
  });
  
  // Real-time search (debounced)
  let searchTimeout;
  searchInput.addEventListener('input', function() {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(() => {
      const query = this.value.trim();
      if (query && searchIndex) {
        const results = searchContent(query);
        displayResults(results, query);
      } else if (!query) {
        searchResults.innerHTML = '';
      }
    }, 300);
  });
})();
</script>
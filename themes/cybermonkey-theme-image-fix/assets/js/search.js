/**
 * Search functionality for Ghost
 * This implements client-side search similar to the Hugo site
 */

(function() {
    'use strict';

    const searchInput = document.getElementById('search-input');
    if (!searchInput) return;

    let searchIndex = [];
    let searchResults = null;

    // Create search results container
    const createSearchResults = () => {
        searchResults = document.createElement('div');
        searchResults.className = 'search-results';
        searchResults.style.display = 'none';
        searchInput.parentElement.appendChild(searchResults);
    };

    // Load search index from Ghost Content API
    const loadSearchIndex = async () => {
        try {
            const response = await fetch('/ghost/api/content/posts/?key=' + ghostContentKey + '&include=tags&limit=all&fields=id,title,slug,excerpt,published_at,primary_tag');
            const data = await response.json();
            searchIndex = data.posts || [];
        } catch (error) {
            console.error('Failed to load search index:', error);
        }
    };

    // Perform search
    const performSearch = (query) => {
        if (!query || query.length < 2) {
            searchResults.style.display = 'none';
            return;
        }

        const results = searchIndex.filter(post => {
            const searchString = `${post.title} ${post.excerpt}`.toLowerCase();
            return searchString.includes(query.toLowerCase());
        });

        displayResults(results, query);
    };

    // Display search results
    const displayResults = (results, query) => {
        if (results.length === 0) {
            searchResults.innerHTML = '<p class="no-results">No results found for "' + query + '"</p>';
        } else {
            const html = results.map(post => `
                <a href="/${post.slug}/" class="search-result">
                    <h4>${highlightMatch(post.title, query)}</h4>
                    <p>${highlightMatch(post.excerpt || '', query)}</p>
                </a>
            `).join('');
            searchResults.innerHTML = html;
        }
        searchResults.style.display = 'block';
    };

    // Highlight matching text
    const highlightMatch = (text, query) => {
        const regex = new RegExp(`(${query})`, 'gi');
        return text.replace(regex, '<mark>$1</mark>');
    };

    // Initialize
    createSearchResults();
    loadSearchIndex();

    // Search input handler
    let searchTimeout;
    searchInput.addEventListener('input', (e) => {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(() => {
            performSearch(e.target.value);
        }, 300);
    });

    // Close search results when clicking outside
    document.addEventListener('click', (e) => {
        if (!searchInput.contains(e.target) && !searchResults.contains(e.target)) {
            searchResults.style.display = 'none';
        }
    });

    // Handle keyboard navigation
    searchInput.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            searchInput.value = '';
            searchResults.style.display = 'none';
        }
    });

})();

// Note: You'll need to add the Ghost Content API key in your theme settings
// Add this to your default.hbs before loading this script:
// <script>var ghostContentKey = '{{@site.ghost_api_key}}';</script>
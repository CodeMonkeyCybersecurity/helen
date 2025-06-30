// @ts-nocheck
// Unified Search System for Navigation Bars
// Supports both sidebar and mobile contexts with shared logic
'use strict';

{{- $searchDataFile := printf "%s.search-data.json" .Language.Lang -}}
{{- $searchData := resources.Get "search-data.json" | resources.ExecuteAsTemplate $searchDataFile . | resources.Minify | resources.Fingerprint -}}
{{- $searchConfig := i18n "bookSearchConfig" | default "{}" -}}

(function () {
  const searchDataURL = '{{ $searchData.RelPermalink }}';
  const indexConfig = Object.assign({{ $searchConfig }}, {
    includeScore: true,
    useExtendedSearch: true,
    fieldNormWeight: 1.5,
    threshold: 0.2,
    ignoreLocation: true,
    keys: [
      {
        name: 'title',
        weight: 0.7
      },
      {
        name: 'content',
        weight: 0.3
      }
    ]
  });

  // Shared search index - loaded once, used by all contexts
  let searchIndex = null;
  let searchDataLoaded = false;

  // Track all search instances
  const searchInstances = new Map();

  // Initialize all search instances on page load
  document.addEventListener('DOMContentLoaded', function() {
    initializeAllSearchInstances();
  });

  function initializeAllSearchInstances() {
    // Find all unified search components
    const searchComponents = document.querySelectorAll('.unified-search');
    
    searchComponents.forEach(component => {
      const context = component.getAttribute('data-search-context');
      const input = component.querySelector('.unified-search-input');
      const results = component.querySelector('.unified-search-results');
      const spinner = component.querySelector('.unified-search-spinner');
      
      if (!input || !results) return;
      
      // Store instance data
      searchInstances.set(context, {
        input,
        results,
        spinner,
        component
      });
      
      // Set up event listeners
      setupSearchInstance(context);
    });
  }

  function setupSearchInstance(context) {
    const instance = searchInstances.get(context);
    if (!instance) return;
    
    const { input, results } = instance;
    
    // Focus handler - load search data if needed
    input.addEventListener('focus', () => initSearchData(context));
    
    // Input handler - perform search
    input.addEventListener('input', () => performSearch(context));
    
    // Keyboard navigation
    input.addEventListener('keydown', (e) => handleKeyNavigation(e, context));
    
    // Global hotkey support
    document.addEventListener('keypress', (e) => focusSearchFieldOnKeyPress(e, context));
    
    // Click outside to close results
    document.addEventListener('click', (e) => {
      if (!instance.component.contains(e.target)) {
        clearResults(context);
      }
    });
  }

  async function initSearchData(context) {
    if (searchDataLoaded) return;
    
    const instance = searchInstances.get(context);
    if (!instance) return;
    
    showSpinner(context, true);
    
    try {
      const response = await fetch(searchDataURL);
      const pages = await response.json();
      searchIndex = new Fuse(pages, indexConfig);
      searchDataLoaded = true;
    } catch (error) {
      console.error('Failed to load search data:', error);
    } finally {
      showSpinner(context, false);
    }
  }

  function performSearch(context) {
    const instance = searchInstances.get(context);
    if (!instance || !searchIndex) return;
    
    const { input, results } = instance;
    const query = input.value.trim();
    
    // Clear previous results
    clearResults(context);
    
    if (!query) return;
    
    // Perform search
    const searchHits = searchIndex.search(query).slice(0, 8);
    
    if (searchHits.length === 0) {
      showNoResults(context, query);
      return;
    }
    
    // Render results
    searchHits.forEach((hit, index) => {
      const resultElement = createSearchResult(hit.item, index === 0);
      results.appendChild(resultElement);
    });
    
    // Show results
    results.style.display = 'block';
  }

  function createSearchResult(item, isFirst = false) {
    const li = document.createElement('li');
    li.className = 'nav-search-result';
    if (isFirst) li.classList.add('highlighted');
    
    const a = document.createElement('a');
    a.href = item.href;
    a.className = 'block';
    
    const title = document.createElement('div');
    title.className = 'search-result-title';
    title.textContent = item.title;
    
    const section = document.createElement('div');
    section.className = 'search-result-excerpt';
    section.textContent = item.section;
    
    a.appendChild(title);
    if (item.section) a.appendChild(section);
    li.appendChild(a);
    
    // Click handler
    a.addEventListener('click', () => {
      // Close search results on navigation
      setTimeout(() => clearAllResults(), 100);
    });
    
    return li;
  }

  function showNoResults(context, query) {
    const instance = searchInstances.get(context);
    if (!instance) return;
    
    const li = document.createElement('li');
    li.className = 'nav-search-result no-results';
    li.innerHTML = `<span>No results for "${query}"</span>`;
    
    instance.results.appendChild(li);
    instance.results.style.display = 'block';
  }

  function clearResults(context) {
    const instance = searchInstances.get(context);
    if (!instance) return;
    
    const { results } = instance;
    while (results.firstChild) {
      results.removeChild(results.firstChild);
    }
    results.style.display = 'none';
  }

  function clearAllResults() {
    searchInstances.forEach((instance, context) => {
      clearResults(context);
    });
  }

  function showSpinner(context, show) {
    const instance = searchInstances.get(context);
    if (!instance) return;
    
    const { spinner } = instance;
    if (show) {
      spinner.classList.remove('hidden');
    } else {
      spinner.classList.add('hidden');
    }
  }

  function handleKeyNavigation(event, context) {
    const instance = searchInstances.get(context);
    if (!instance) return;
    
    const { results } = instance;
    const resultItems = results.querySelectorAll('.nav-search-result');
    
    if (resultItems.length === 0) return;
    
    const currentHighlighted = results.querySelector('.highlighted');
    let nextIndex = 0;
    
    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault();
        if (currentHighlighted) {
          const currentIndex = Array.from(resultItems).indexOf(currentHighlighted);
          nextIndex = Math.min(currentIndex + 1, resultItems.length - 1);
          currentHighlighted.classList.remove('highlighted');
        }
        resultItems[nextIndex].classList.add('highlighted');
        break;
        
      case 'ArrowUp':
        event.preventDefault();
        if (currentHighlighted) {
          const currentIndex = Array.from(resultItems).indexOf(currentHighlighted);
          nextIndex = Math.max(currentIndex - 1, 0);
          currentHighlighted.classList.remove('highlighted');
          resultItems[nextIndex].classList.add('highlighted');
        }
        break;
        
      case 'Enter':
        event.preventDefault();
        if (currentHighlighted) {
          const link = currentHighlighted.querySelector('a');
          if (link) {
            link.click();
          }
        }
        break;
        
      case 'Escape':
        event.preventDefault();
        clearResults(context);
        instance.input.blur();
        break;
    }
  }

  function focusSearchFieldOnKeyPress(event, context) {
    // Only handle if no input is focused and not in a form field
    if (event.target.value !== undefined) return;
    if (document.activeElement.tagName === 'INPUT') return;
    
    const instance = searchInstances.get(context);
    if (!instance) return;
    
    const { input } = instance;
    if (input === document.activeElement) return;
    
    const characterPressed = String.fromCharCode(event.charCode);
    const dataHotkeys = input.getAttribute('data-hotkeys') || '';
    
    if (dataHotkeys.indexOf(characterPressed) >= 0) {
      // Focus the first search input found (prefer sidebar over mobile)
      const sidebarInstance = searchInstances.get('sidebar');
      const targetInput = sidebarInstance ? sidebarInstance.input : input;
      
      targetInput.focus();
      event.preventDefault();
    }
  }

  // Expose API for external use
  window.unifiedSearch = {
    clearAllResults,
    focusSearch: (context = 'sidebar') => {
      const instance = searchInstances.get(context);
      if (instance) instance.input.focus();
    },
    isSearchDataLoaded: () => searchDataLoaded
  };
})();
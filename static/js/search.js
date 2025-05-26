// static/js/search.js
document.addEventListener("DOMContentLoaded", () => {
  const input  = document.getElementById("site-search");
  const resultList = document.getElementById("search-results");
  if (!input || !resultList) return;

  // Load the JSON index
  fetch("/index.json")
    .then(res => {
      if (!res.ok) throw new Error("Network response was not OK");
      return res.json();
    })
    .then(pages => {
      // Initialize Fuse
      const fuse = new Fuse(pages, {
        keys: [
          { name: "title",   weight: 0.7 },
          { name: "summary", weight: 0.3 },
          { name: "body",    weight: 0.1 }
        ],
        includeScore: true,
        threshold: 0.4
      });

      // Listen for user input
      input.addEventListener("input", e => {
        const q = e.target.value.trim();
        if (!q) {
          resultList.innerHTML = "";
          return;
        }
        const hits = fuse.search(q, { limit: 5 });
        if (hits.length === 0) {
          resultList.innerHTML = "<li>No results found</li>";
          return;
        }
        resultList.innerHTML = hits.map(h => {
          const item = h.item;
          return `<li><a href="${item.url}">${item.title}</a></li>`;
        }).join("");
      });
    })
    .catch(err => {
      console.error("Search index load failed:", err);
      resultList.innerHTML = "<li>Search unavailable</li>";
    });
});
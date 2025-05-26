// static/js/search.js
document.addEventListener("DOMContentLoaded", () => {
  const input  = document.getElementById("site-search");
  const resultList = document.getElementById("search-results");
  if (!input || !resultList) return;

  // Load the JSON index
  fetch("/index.json")
    .then(res => res.json())
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

      input.addEventListener("input", e => {
        const q = e.target.value.trim();
        if (!q) {
          resultList.innerHTML = "";
          return;
        }
        const hits = fuse.search(q).slice(0, 10);
        resultList.innerHTML = hits.map(h => {
          const item = h.item;
          return `<li><a href="${item.url}">${item.title}</a></li>`;
        }).join("");
      });
    })
    .catch(err => {
      console.error("Search index load failed:", err);
    });
});
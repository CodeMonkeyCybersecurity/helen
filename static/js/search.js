// static/js/search.js
document.addEventListener("DOMContentLoaded", () => {
  const wrapper    = document.querySelector(".book-search");
  const input      = document.getElementById("site-search");
  const resultList = document.getElementById("search-results");
  if (!wrapper || !input || !resultList) return;

  // toggle an “active” class while focused or containing text
  function updateActiveState() {
    const hasText   = input.value.trim().length > 0;
    const isFocused = document.activeElement === input;
    wrapper.classList.toggle("active", hasText || isFocused);
  }

  // load your JSON index and initialize Fuse
  fetch("/index.json")
    .then(res => {
      if (!res.ok) throw new Error("Network response was not OK");
      return res.json();
    })
    .then(pages => {
      const fuse = new Fuse(pages, {
        keys: [
          { name: "title",   weight: 0.7 },
          { name: "summary", weight: 0.3 },
          { name: "body",    weight: 0.1 }
        ],
        includeScore: true,
        threshold: 0.4
      });

      // wire up events
      input.addEventListener("input", e => {
        updateActiveState();
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
        resultList.innerHTML = hits
          .map(h => `<li><a href="${h.item.url}">${h.item.title}</a></li>`)
          .join("");
      });
      input.addEventListener("focus", updateActiveState);
      input.addEventListener("blur",  updateActiveState);
    })
    .catch(err => {
      console.error("Search index load failed:", err);
      resultList.innerHTML = "<li>Search unavailable</li>";
      updateActiveState();
    });
});
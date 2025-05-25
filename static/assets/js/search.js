document.addEventListener('DOMContentLoaded', async () => {
  const searchInput = document.getElementById('site-search');
  const index = await fetch('/index.json').then(res => res.json());

  const fuse = new Fuse(index, {
    keys: ['title', 'content'],
    threshold: 0.3
  });

  searchInput.addEventListener('input', (e) => {
    const results = fuse.search(e.target.value);
    const list = document.getElementById('search-results');

    list.innerHTML = results.slice(0, 10).map(({ item }) => `
      <li><a href="${item.url}">${item.title}</a></li>
    `).join('');
  });
});

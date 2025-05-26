// static/js/sidebar.js
document.addEventListener('DOMContentLoaded', () => {
  const checkbox = document.getElementById('menu-control');
  const sidebar = document.querySelector('.book-menu');
  const toggleBtn = document.querySelector('.menu-toggle');

  if (!checkbox || !sidebar || !toggleBtn) return;

  toggleBtn.setAttribute('aria-expanded', 'false');

  const closeSidebar = () => { checkbox.checked = false; };
  const openSidebar = () => { checkbox.checked = true; };

  // Dismiss on outside click
  document.addEventListener('click', (e) => {
    if (
      checkbox.checked &&
      !sidebar.contains(e.target) &&
      !e.target.closest('.menu-toggle')
    ) {
      closeSidebar();
    }
  });

  // Hover-to-open (pointer devices only)
  const hoverEnabled = window.matchMedia('(hover: hover)').matches;
  if (hoverEnabled) {
    sidebar.addEventListener('mouseenter', () => {
      if (!checkbox.checked) openSidebar();
    });
    sidebar.addEventListener('mouseleave', () => {
      if (window.innerWidth < 1024) closeSidebar();
    });
  }

  // Update aria-expanded on toggle
  checkbox.addEventListener('change', () => {
    toggleBtn.setAttribute('aria-expanded', checkbox.checked.toString());
  });
});
// static/assets/js/sidebar.js
document.addEventListener('DOMContentLoaded', () => {
  const checkbox = document.getElementById('menu-control');
  const sidebar = document.querySelector('.book-menu');
  const toggleBtn = document.querySelector('.menu-toggle');
  toggleBtn.setAttribute('aria-expanded', 'false');



  // Dismiss on outside click
  document.addEventListener('click', (e) => {
    if (
      checkbox.checked &&
      !sidebar.contains(e.target) &&
      !e.target.closest('.menu-toggle')
    ) {
      checkbox.checked = false;
    }
  });

  // (Optional) Hover-to-open only on pointer devices
  if (window.matchMedia('(hover: hover)').matches) {
    sidebar.addEventListener('mouseenter', () => {
      if (!checkbox.checked) checkbox.checked = true;
    });
    sidebar.addEventListener('mouseleave', () => {
      if (window.innerWidth < 1024) checkbox.checked = false;
    });
  }

  // Accessibility: Update aria-expanded
  checkbox.addEventListener('change', () => {
    toggleBtn.setAttribute('aria-expanded', checkbox.checked.toString());
  });
});

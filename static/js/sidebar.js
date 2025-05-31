// static/js/sidebar.js
document.addEventListener('DOMContentLoaded', () => {
  const checkbox = document.getElementById('menu-control');
  const toggleBtn = document.querySelector('.menu-toggle');

  if (!checkbox || !toggleBtn) return;

  toggleBtn.setAttribute('aria-expanded', 'false');

  checkbox.addEventListener('change', () => {
    toggleBtn.setAttribute('aria-expanded', checkbox.checked.toString());
  });
})
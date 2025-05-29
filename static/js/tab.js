// static/js/tab.js
document.addEventListener('DOMContentLoaded', function() {
  document.querySelectorAll('.tabs').forEach(tabs => {
    tabs.querySelector('.tab-buttons').addEventListener('click', function(e) {
      if (!e.target.classList.contains('tab')) return;
      const target = e.target.dataset.target;
      tabs.querySelectorAll('.tab').forEach(btn => btn.classList.remove('active'));
      e.target.classList.add('active');
      tabs.querySelectorAll('.tab-content').forEach(content =>
        content.classList.toggle('active', content.id === target)
      );
    });
  });
});
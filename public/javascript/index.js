document.getElementById('menu-toggle').addEventListener('click', function() {
  document.getElementById('sidebar').classList.toggle('-translate-x-full');
  document.getElementById('sidebar-overlay').classList.toggle('hidden');
});

// Auto-dismiss flash banner after 3 seconds
setTimeout(function() {
  var el = document.getElementById('flash-banner');
  if (el) {
    el.style.opacity = '0';
    el.style.transform = 'translateY(-8px)';
    setTimeout(function() { el.remove(); }, 500);
  }
}, 3000);

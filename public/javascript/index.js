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

// CSV file upload handling
(function() {
  var fileInput = document.getElementById('csv-file-input');
  var dropZone = document.getElementById('csv-drop-zone');
  var hiddenField = document.getElementById('csv-text-hidden');
  var importBtn = document.getElementById('csv-import-btn');
  var fileLabel = document.getElementById('csv-file-label');

  if (!fileInput) return;

  function handleFile(file) {
    if (!file || !file.name.endsWith('.csv')) {
      if (fileLabel) fileLabel.textContent = 'Please select a valid .csv file';
      return;
    }
    var reader = new FileReader();
    reader.onload = function(e) {
      hiddenField.value = e.target.result;
      importBtn.disabled = false;
      fileLabel.textContent = file.name;
      dropZone.classList.remove('border-gray-300');
      dropZone.classList.add('border-blue-400', 'bg-blue-50');
    };
    reader.readAsText(file);
  }

  fileInput.addEventListener('change', function() {
    if (this.files && this.files[0]) handleFile(this.files[0]);
  });

  dropZone.addEventListener('dragover', function(e) {
    e.preventDefault();
    this.classList.add('border-blue-400', 'bg-blue-50');
  });

  dropZone.addEventListener('dragleave', function() {
    if (!hiddenField.value) {
      this.classList.remove('border-blue-400', 'bg-blue-50');
      this.classList.add('border-gray-300');
    }
  });

  dropZone.addEventListener('drop', function(e) {
    e.preventDefault();
    if (e.dataTransfer.files && e.dataTransfer.files[0]) handleFile(e.dataTransfer.files[0]);
  });
})();

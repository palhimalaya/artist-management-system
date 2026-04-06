var menuToggle = document.getElementById('menu-toggle');
var sidebar = document.getElementById('sidebar');
var sidebarOverlay = document.getElementById('sidebar-overlay');

if (menuToggle && sidebar && sidebarOverlay) {
  menuToggle.addEventListener('click', function() {
    sidebar.classList.toggle('-translate-x-full');
    sidebarOverlay.classList.toggle('hidden');
  });
}

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

// Password policy + confirmation validation (register and create user forms)
(function() {
  var forms = document.querySelectorAll('form[data-password-validation="true"]');
  if (!forms.length) return;

  function isStrongPassword(value) {
    return value.length >= 8 &&
      /[A-Z]/.test(value) &&
      /[a-z]/.test(value) &&
      /[0-9]/.test(value) &&
      /[^A-Za-z0-9]/.test(value);
  }

  forms.forEach(function(form) {
    var passwordInput = form.querySelector('input[name="password"]');
    var confirmationInput = form.querySelector('input[name="password_confirmation"]');
    var mismatchError = form.querySelector('[data-password-mismatch-error]');
    var strengthError = form.querySelector('[data-password-strength-error]');

    if (!passwordInput) return;

    function validatePasswordFields() {
      var password = passwordInput.value;
      var confirmation = confirmationInput ? confirmationInput.value : '';
      var weakPassword = password.length > 0 && !isStrongPassword(password);
      var mismatch = confirmationInput && confirmation.length > 0 && password !== confirmation;

      passwordInput.setCustomValidity(
        weakPassword ? 'Password must be at least 8 characters and include uppercase, lowercase, number, and special character' : ''
      );

      if (confirmationInput) {
        confirmationInput.setCustomValidity(mismatch ? 'Password confirmation does not match' : '');
      }

      if (strengthError) {
        strengthError.classList.toggle('hidden', !weakPassword);
      }

      if (mismatchError) {
        mismatchError.classList.toggle('hidden', !mismatch);
      }
    }

    passwordInput.addEventListener('input', validatePasswordFields);

    if (confirmationInput) {
      confirmationInput.addEventListener('input', validatePasswordFields);
    }

    form.addEventListener('submit', function(event) {
      validatePasswordFields();
      if (!form.checkValidity()) {
        event.preventDefault();
        form.reportValidity();
      }
    });
  });
})();

// Theme Toggle Functionality
(function () {
  const body = document.body;
  const THEME_KEY = "theme-preference";

  // Apply system theme
  function applySystemTheme() {
    if (
      window.matchMedia &&
      window.matchMedia("(prefers-color-scheme: dark)").matches
    ) {
      body.classList.add("dark-mode");
    } else {
      body.classList.remove("dark-mode");
    }
  }

  // Save theme preference
  function saveTheme(theme) {
    localStorage.setItem(THEME_KEY, theme);
  }

  // Load and apply theme immediately
  const savedTheme = localStorage.getItem(THEME_KEY);

  if (savedTheme === "dark") {
    body.classList.add("dark-mode");
    body.setAttribute("data-theme", "dark");
  } else if (savedTheme === "light") {
    body.classList.remove("dark-mode");
    body.setAttribute("data-theme", "light");
  } else {
    // Default: System mode (untuk user baru atau belum set preferensi)
    body.setAttribute("data-theme", "system");
    saveTheme("system"); // Simpan system sebagai default
    applySystemTheme();
  }

  // Set theme
  function setTheme(theme) {
    if (theme === "dark") {
      body.classList.add("dark-mode");
      body.setAttribute("data-theme", "dark");
      saveTheme("dark");
    } else if (theme === "light") {
      body.classList.remove("dark-mode");
      body.setAttribute("data-theme", "light");
      saveTheme("light");
    } else {
      body.setAttribute("data-theme", "system");
      saveTheme("system");
      applySystemTheme();
    }
  }

  // Wait for DOM to be ready for event listeners
  document.addEventListener("DOMContentLoaded", function () {
    const themeToggle = document.getElementById("theme-toggle");
    const themeMenu = document.getElementById("theme-menu");
    const themeOptions = document.querySelectorAll(".theme-option");

    // Toggle menu visibility
    if (themeToggle) {
      themeToggle.addEventListener("click", function (e) {
        e.stopPropagation();
        themeMenu.classList.toggle("show");
      });
    }

    // Handle theme selection
    themeOptions.forEach((option) => {
      option.addEventListener("click", function (e) {
        e.stopPropagation();
        const selectedTheme = this.getAttribute("data-theme");
        setTheme(selectedTheme);
        themeMenu.classList.remove("show");
      });
    });

    // Close menu when clicking outside
    document.addEventListener("click", function () {
      themeMenu.classList.remove("show");
    });
  });

  // Listen for system theme changes
  if (window.matchMedia) {
    window
      .matchMedia("(prefers-color-scheme: dark)")
      .addEventListener("change", (e) => {
        // Only auto-update if in system mode
        const currentTheme = body.getAttribute("data-theme");
        if (currentTheme === "system") {
          if (e.matches) {
            body.classList.add("dark-mode");
          } else {
            body.classList.remove("dark-mode");
          }
        }
      });
  }
})();

// Loading screen animation
window.addEventListener("load", () => {
  const loader = document.getElementById("loading-container");
  setTimeout(() => {
    loader.classList.add("hidden");
    document.body.classList.remove("no-scroll");
  }, 2000);
});

// Copy command to clipboard with SweetAlert
document.querySelectorAll(".copy-btn").forEach(button => {
  button.addEventListener("click", () => {
    const code = button.previousElementSibling.innerText;
    navigator.clipboard.writeText(code).then(() => {
      Swal.fire({
        icon: 'success',
        title: 'Copied!',
        text: 'Command has been copied to clipboard',
        timer: 1500,
        showConfirmButton: false,
      });
    });
  });
});

// Theme toggle
const toggleSwitch = document.getElementById("theme-toggle");
const currentTheme = localStorage.getItem("theme");

if (currentTheme === "dark") {
  document.body.classList.add("dark-theme");
  toggleSwitch.checked = true;
}

toggleSwitch.addEventListener("change", () => {
  if (toggleSwitch.checked) {
    document.body.classList.add("dark-theme");
    localStorage.setItem("theme", "dark");
  } else {
    document.body.classList.remove("dark-theme");
    localStorage.setItem("theme", "light");
  }
});

// Tab switch (for extension categories)
document.querySelectorAll('.tab-btn').forEach(button => {
  button.addEventListener('click', () => {
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));

    button.classList.add('active');
    document.getElementById(button.dataset.tab).classList.add('active');
  });
});

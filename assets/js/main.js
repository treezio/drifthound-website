// Star banner close function
function closeBanner() {
  const banner = document.getElementById('starBanner');
  if (banner) {
    banner.classList.add('hidden');
    // Remember the user closed it (persist for 30 days)
    localStorage.setItem('starBannerClosed', 'true');
    localStorage.setItem('starBannerClosedTime', Date.now().toString());
  }
}

// Tab switching functionality
document.addEventListener('DOMContentLoaded', function() {
  // Check if star banner should be hidden
  const bannerClosed = localStorage.getItem('starBannerClosed');
  const closedTime = localStorage.getItem('starBannerClosedTime');
  const banner = document.getElementById('starBanner');

  if (banner && bannerClosed === 'true' && closedTime) {
    const daysSinceClosed = (Date.now() - parseInt(closedTime)) / (1000 * 60 * 60 * 24);
    if (daysSinceClosed < 30) {
      banner.classList.add('hidden');
    } else {
      // Reset after 30 days
      localStorage.removeItem('starBannerClosed');
      localStorage.removeItem('starBannerClosedTime');
    }
  }

  // Tab switching
  const tabButtons = document.querySelectorAll('.tab-btn');
  const tabContents = document.querySelectorAll('.tab-content');

  tabButtons.forEach(button => {
    button.addEventListener('click', () => {
      const tabName = button.getAttribute('data-tab');

      // Remove active class from all buttons and contents
      tabButtons.forEach(btn => btn.classList.remove('active'));
      tabContents.forEach(content => content.classList.remove('active'));

      // Add active class to clicked button and corresponding content
      button.classList.add('active');
      document.querySelector(`[data-tab-content="${tabName}"]`).classList.add('active');
    });
  });

  // Smooth scroll for anchor links
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
      e.preventDefault();
      const target = document.querySelector(this.getAttribute('href'));
      if (target) {
        target.scrollIntoView({
          behavior: 'smooth',
          block: 'start'
        });
      }
    });
  });

  // Mobile menu toggle
  const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
  const navLinks = document.querySelector('.nav-links');

  if (mobileMenuBtn && navLinks) {
    mobileMenuBtn.addEventListener('click', () => {
      navLinks.classList.toggle('active');
      mobileMenuBtn.classList.toggle('active');
    });
  }
});

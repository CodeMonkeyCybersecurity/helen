/**
 * Main JavaScript for Code Monkey Cybersecurity Ghost Theme
 * Matching Hugo site functionality
 */
(function() {
    'use strict';

    // Mobile menu toggle functionality
    const mobileMenuToggle = document.querySelector('.mobile-menu-toggle');
    const mobileMenuCheckbox = document.getElementById('mobile-menu-toggle');
    const navMenu = document.querySelector('.nav-menu');
    
    if (mobileMenuToggle && mobileMenuCheckbox) {
        // Click handler for mobile menu button
        mobileMenuToggle.addEventListener('click', function(e) {
            e.preventDefault();
            mobileMenuCheckbox.checked = !mobileMenuCheckbox.checked;
            
            // Animate hamburger menu
            const spans = mobileMenuToggle.querySelectorAll('.hamburger');
            if (mobileMenuCheckbox.checked) {
                spans[0].style.transform = 'rotate(45deg) translate(5px, 5px)';
                spans[1].style.opacity = '0';
                spans[2].style.transform = 'rotate(-45deg) translate(7px, -6px)';
            } else {
                spans[0].style.transform = 'none';
                spans[1].style.opacity = '1';
                spans[2].style.transform = 'none';
            }
        });
        
        // Close mobile menu when clicking outside
        document.addEventListener('click', function(e) {
            if (!mobileMenuToggle.contains(e.target) && 
                !navMenu.contains(e.target) && 
                mobileMenuCheckbox.checked) {
                mobileMenuCheckbox.checked = false;
                const spans = mobileMenuToggle.querySelectorAll('.hamburger');
                spans[0].style.transform = 'none';
                spans[1].style.opacity = '1';
                spans[2].style.transform = 'none';
            }
        });
    }
    
    // Smooth scrolling for anchor links
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
    
    // Add active class to current navigation item
    const currentPath = window.location.pathname;
    document.querySelectorAll('.nav-link').forEach(link => {
        if (link.getAttribute('href') === currentPath) {
            link.classList.add('active');
        }
    });
    
    // Lazy loading for images
    if ('IntersectionObserver' in window) {
        const images = document.querySelectorAll('img[loading="lazy"]');
        const imageObserver = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const img = entry.target;
                    img.src = img.dataset.src || img.src;
                    img.classList.add('loaded');
                    imageObserver.unobserve(img);
                }
            });
        });
        
        images.forEach(img => imageObserver.observe(img));
    }
    
    // External link handling
    document.querySelectorAll('a[href^="http"]').forEach(link => {
        if (!link.href.includes(window.location.host)) {
            link.setAttribute('target', '_blank');
            link.setAttribute('rel', 'noopener noreferrer');
        }
    });
})();
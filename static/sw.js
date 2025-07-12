// Service Worker for Code Monkey Cybersecurity
// Progressive Web App offline functionality

const CACHE_NAME = 'codemonkey-v1';
const OFFLINE_URL = '/offline/';

// Resources to cache immediately
const PRECACHE_URLS = [
  '/',
  '/offline/',
  '/search/',
  '/resources/',
  '/resources/education/',
  '/about-us/',
  '/manifest.json'
];

// Install event - precache essential resources
self.addEventListener('install', event => {
  console.log('Service Worker installing...');
  
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('Caching essential resources');
        return cache.addAll(PRECACHE_URLS);
      })
      .then(() => {
        console.log('Service Worker installed successfully');
        return self.skipWaiting();
      })
      .catch(error => {
        console.error('Service Worker installation failed:', error);
      })
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', event => {
  console.log('Service Worker activating...');
  
  event.waitUntil(
    caches.keys()
      .then(cacheNames => {
        return Promise.all(
          cacheNames.map(cacheName => {
            if (cacheName !== CACHE_NAME) {
              console.log('Deleting old cache:', cacheName);
              return caches.delete(cacheName);
            }
          })
        );
      })
      .then(() => {
        console.log('Service Worker activated');
        return self.clients.claim();
      })
  );
});

// Fetch event - serve from cache when offline
self.addEventListener('fetch', event => {
  // Only handle GET requests
  if (event.request.method !== 'GET') {
    return;
  }

  // Skip non-HTTP requests
  if (!event.request.url.startsWith('http')) {
    return;
  }

  // Skip external requests
  if (!event.request.url.startsWith(self.location.origin)) {
    return;
  }

  event.respondWith(
    caches.match(event.request)
      .then(cachedResponse => {
        // Return cached version if available
        if (cachedResponse) {
          return cachedResponse;
        }

        // Fetch from network
        return fetch(event.request)
          .then(response => {
            // Don't cache non-successful responses
            if (!response || response.status !== 200 || response.type !== 'basic') {
              return response;
            }

            // Clone the response for caching
            const responseToCache = response.clone();

            // Cache the response for future use
            caches.open(CACHE_NAME)
              .then(cache => {
                // Only cache GET requests for our domain
                if (event.request.method === 'GET') {
                  cache.put(event.request, responseToCache);
                }
              });

            return response;
          })
          .catch(() => {
            // If network fails, try to serve offline page for navigation requests
            if (event.request.mode === 'navigate') {
              return caches.match(OFFLINE_URL);
            }
            
            // For other requests, just fail
            throw new Error('Network unavailable');
          });
      })
  );
});

// Background sync for form submissions when online
self.addEventListener('sync', event => {
  if (event.tag === 'contact-form') {
    event.waitUntil(
      // Handle queued form submissions when back online
      handleQueuedSubmissions()
    );
  }
});

// Handle queued form submissions
async function handleQueuedSubmissions() {
  // This would handle any queued contact form submissions
  // when the user comes back online
  console.log('Processing queued submissions...');
}

// Push notification handling (for future use)
self.addEventListener('push', event => {
  if (!event.data) {
    return;
  }

  const data = event.data.json();
  const options = {
    body: data.body,
    icon: '/favicon.png',
    badge: '/favicon.png',
    data: data.url ? { url: data.url } : undefined,
    actions: data.url ? [
      {
        action: 'open',
        title: 'Open'
      }
    ] : undefined
  };

  event.waitUntil(
    self.registration.showNotification(data.title, options)
  );
});

// Handle notification clicks
self.addEventListener('notificationclick', event => {
  event.notification.close();

  if (event.action === 'open' && event.notification.data?.url) {
    event.waitUntil(
      clients.openWindow(event.notification.data.url)
    );
  }
});

// Update available notification
self.addEventListener('message', event => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});

console.log('Service Worker script loaded');
// Firebase Messaging Service Worker for background push notifications
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyCDOmI_23EcD5rfL5TV6k1fjHbAOxr31Bs",
  appId: "1:802033087048:web:4f07fe918feae3378a1e7d",
  messagingSenderId: "802033087048",
  projectId: "kompass-maverick",
  authDomain: "kompass-maverick.firebaseapp.com",
  storageBucket: "kompass-maverick.firebasestorage.app",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Background push notification received: ', payload);
  
  const title = payload.notification?.title || payload.data?.title || 'KOMPASS Alert';
  const body = payload.notification?.body || payload.data?.body || '';
  const tourId = payload.data?.tourId || '';
  const type = payload.data?.type || 'chat';
  const isEmergency = type === 'sos';

  const notificationOptions = {
    body: body,
    icon: '/icons/Icon-192.png',
    badge: '/favicon.png',
    tag: payload.data?.messageId || payload.data?.alertId || String(Date.now()),
    requireInteraction: isEmergency,
    data: {
      tourId: tourId,
      type: type,
      click_action: payload.data?.click_action || 'FLUTTER_NOTIFICATION_CLICK',
    },
  };

  return self.registration.showNotification(title, notificationOptions);
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  const tourId = event.notification.data?.tourId;
  const type = event.notification.data?.type;
  let targetUrl = '/';

  if (tourId) {
    if (type === 'chat') {
      targetUrl = `/#/tours/${tourId}/chat`;
    } else if (type === 'announcement') {
      targetUrl = `/#/tours/${tourId}/announcements`;
    } else if (type === 'sos') {
      targetUrl = `/#/tours/${tourId}/sos`;
    } else {
      targetUrl = `/#/tours/${tourId}/chat`;
    }
  }

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
      for (const client of clientList) {
        if ('focus' in client) {
          client.focus();
          client.navigate(targetUrl);
          return;
        }
      }
      if (clients.openWindow) {
        return clients.openWindow(targetUrl);
      }
    })
  );
});

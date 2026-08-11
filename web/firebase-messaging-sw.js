// This file is required by Firebase Cloud Messaging for Web
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyC0XlM0yXtWKLlysK1ulC4aGqQ1z-1eIUM",
  appId: "1:1079245350998:web:2f89409eab1d9926d2b3f7",
  messagingSenderId: "1079245350998",
  projectId: "test0-project-941b8",
  authDomain: "test0-project-941b8.firebaseapp.com",
  storageBucket: "test0-project-941b8.firebasestorage.app",
  measurementId: "G-2FQNCQ8NVF"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification?.title || 'New Notification';
  const notificationOptions = {
    body: payload.notification?.body || '',
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});

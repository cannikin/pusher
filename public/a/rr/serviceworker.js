'use strict';

self.addEventListener('push', function(event) {
  var json = event.data.json()
  event.waitUntil(
    self.registration.showNotification(json.title, { body: json.body, icon: json.icon,
      data: json.data })
  );
});

self.addEventListener('notificationclick', function(event) {
  var openUrl = event.notification.data.url;

  console.log('On notification click: ', event.notification);
  // Android doesn’t close the notification when you click on it, see: http://crbug.com/463146
  event.notification.close();

  // This looks to see if the current is already open and focuses if it is
  event.waitUntil(clients.matchAll({
    type: 'window'
  }).then(function(clientList) {
    for (var i = 0; i < clientList.length; i++) {
      var client = clientList[i];
      if (client.url === '/' && 'focus' in client) {
        return client.focus();
      }
    }
    if (clients.openWindow && openUrl !== '' && openUrl !== null) {
      return clients.openWindow(openUrl);
    }
  }));
});


// request permission on page load
document.addEventListener('DOMContentLoaded', function () {
  if (!Notification) {
    alert('Desktop notifications not available in your browser. Try Chromium.'); 
    return;
  }

  if (Notification.permission !== "granted")
    Notification.requestPermission();
});

let notifications = {
  notifyMe: function(user_url, body) {
    if (Notification.permission !== "granted")
      Notification.requestPermission();
    else {
      var notification = new Notification('Notification title', {
        icon: user_url,
        body: body,
      });

      notification.onclick = function () {
        this.close();
      };

      setTimeout(notification.close.bind(notification), 3000);
    }
  }  
}

export default notifications

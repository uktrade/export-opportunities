// Layout(s): email_notifications#destroy
//

dit.page.notifications = (new function () {

  // Outside function to run immediately
  window.dataLayer.push({'pageCategory': 'NotificationPage'});

  // Page init
  this.init = function() {
  }

});

$(document).ready(function() {
  dit.page.notifications.init();
  dit.tagging.exopps.init("NotificationPage");
});

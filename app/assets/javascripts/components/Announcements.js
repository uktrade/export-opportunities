var ukti = window.ukti || {};

ukti.announcements = (function($) {
  'use strict';

  var currentUpdateCode = 'update-feb-2017-seen';
  var previousUpdateCode = 'update-march-2017-seen';

  Cookies.set(currentUpdateCode, 'true', { expires: 7 });

  var init = function () {
    var el = document.getElementById('my-accessible-dialog');
    var dialog = new A11yDialog(el);
    // Show the dialog
    dialog.show();
    // Hide the dialog
    //dialog.hide();
  };

  return {
    init: init
  };

})();

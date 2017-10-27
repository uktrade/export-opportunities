/* globals A11yDialog, Cookies */

var ukti = window.ukti || {};

ukti.announcements = (function(A11yDialog, Cookies) {
  'use strict';

  var config = {
    DAYS_TO_EXPIRY: 14,
    COOKIE_NAME : 'UPDATE-APRIL-2017-ACCEPTED' // change this when you want to make a new announcement
  };

  var makeAnnouncement = function () {
    var el = document.getElementById('my-accessible-dialog');
    var dialogue = new A11yDialog(el);
    dialogue.show();
    setCookie();
  };

  var userHasReadLatestUpdate = function () {
    return Cookies.get(config.COOKIE_NAME);
  };

  var setCookie = function () {
    Cookies.set(config.COOKIE_NAME, 'true', { expires: config.DAYS_TO_EXPIRY });
  };

  var init = function () {
    if (userHasReadLatestUpdate()) {
      return;
    }
    makeAnnouncement();
  };

  return {
    init: init
  };

})(A11yDialog, Cookies);

/* globals A11yDialog, Cookies */

var ukti = window.ukti || {};

ukti.announcements = (function(A11yDialog, Cookies) {
  'use strict';

  var config = {
    DAYS_TO_EXPIRY: 31,
    COOKIE_NAME : 'UPDATE-APRIL-2017-ACCEPTED' // change this when you want to make a new announcement
  };

  var el,
      form,
      dialogue;

  var cacheElements = function () {
    el = document.getElementById('announcement-dialog');
    form = el.querySelector( '.dialogue__form' );
  };

  var makeAnnouncement = function () {
    addListeners();
    dialogue = new A11yDialog(el);
    dialogue.show();
  };

  var addListeners = function() {
    form.addEventListener('submit', handleFormSubmit);
  };

  var handleFormSubmit = function (event) {
    event.preventDefault();
    var checkbox = el.querySelector( '#announcement-accept' );
    dialogue.hide();
    if (checkbox.checked) {
      setUserHasAcceptedAnnouncement();
    }
  };

  var userHasAcceptedAnnouncement = function () {
    return Cookies.get(config.COOKIE_NAME);
  };

  var setUserHasAcceptedAnnouncement = function () {
    Cookies.set(config.COOKIE_NAME, 'true', { expires: config.DAYS_TO_EXPIRY });
  };

  var init = function () {
    if (!el) {
      return;
    }
    if (userHasAcceptedAnnouncement()) {
      return;
    }
    cacheElements();
    makeAnnouncement();
  };

  //suppress on CI

  // page.driver.browser.set_cookie("auth_token=#{user.auth_token}")
  // suppress announcement flag? or nag?
  // https://stackoverflow.com/questions/4770025/how-to-disable-scrolling-temporarily

  return {
    init: init
  };

})(A11yDialog, Cookies);

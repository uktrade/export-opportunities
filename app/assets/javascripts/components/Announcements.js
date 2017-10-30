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
      dialogue,
      mainEl;

  var cacheElements = function () {
    mainEl = document.getElementById('content');
    el = document.getElementById('announcement-dialog');
    form = el.querySelector( '.dialogue__form' );
  };

  var makeAnnouncement = function () {
    dialogue = new A11yDialog(el);
    addListeners();
    dialogue.show();
  };

  var addListeners = function() {
    dialogue.on('show', function (dialogEl, event) {
      mainEl.classList.add('hidden');
    });

    dialogue.on('hide', function (dialogEl, event) {
      mainEl.classList.remove('hidden');
    });
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
    cacheElements();
    if (!el) {
      return;
    }
    if (userHasAcceptedAnnouncement()) {
      return;
    }
    makeAnnouncement();
  };

  return {
    init: init
  };

})(A11yDialog, Cookies);

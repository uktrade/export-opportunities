/* globals A11yDialog, Cookies */

var ukti = window.ukti || {};

ukti.announcements = (function(A11yDialog, Cookies) {
  'use strict';

  var config = {
    EXCLUDE_PATHS : ['/admin/updates'],
    DAYS_TO_EXPIRY: 90,
    COOKIE_NAME : 'UPDATE-NOVEMBER-2017-ACCEPTED' // change this when you want to make a new announcement
  };

  var el,
      form,
      dialogue,
      mainEl;

  var cacheElements = function () {
    mainEl = document.getElementById('content');
    el = document.getElementById('announcement-dialog');
    if(el) {
        form = el.querySelector('.dialogue__form');
    }
  };

  var makeAnnouncement = function () {
    dialogue = new A11yDialog(el);
    addListeners();
    dialogue.show();
  };

  var addListeners = function() {
    dialogue.on('show', function (dialogEl, event) {
      //mainEl.classList.add('hidden');
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

  var includeCurrentPage = function () {
    var path = window.location.pathname;
    return !config.EXCLUDE_PATHS.indexOf(path);
  };

  var setUserHasAcceptedAnnouncement = function () {
    Cookies.set(config.COOKIE_NAME, 'true', { expires: config.DAYS_TO_EXPIRY });
  };

  var determineIfAnnouncementRequired = function () {
    if (userHasAcceptedAnnouncement() ) {
      return;
    }
    if (includeCurrentPage() ) {
      return;
    }
    if (!el) {
      return;
    }
    makeAnnouncement();
  };

  var init = function () {
    cacheElements();
    determineIfAnnouncementRequired();
  };

  return {
    init: init
  };

})(A11yDialog, Cookies);

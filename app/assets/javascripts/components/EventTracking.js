/* globals $ */

var ukti = window.ukti || {};

ukti.EventTracking = (function() {
  'use strict';

  var attachBehaviour = function () {

  };

  var handleEventTrack = function () {
	ga('send', {
	  hitType: 'event',
	  eventCategory: 'Search',
	  eventAction: 'play',
	  eventLabel: 'New search'
	});
  };

  var init = function () {
    attachBehaviour();
  };

  return {
    init: init
  };

})();

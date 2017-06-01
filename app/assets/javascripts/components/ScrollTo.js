var ukti = window.ukti || {};

ukti.ScrollTo = (function($) {
  'use strict';

  var initScrollIntoView = function (selector) {
    var el = document.querySelector(selector);
    if (el) {
      document.querySelector(selector).scrollIntoView({ 
        behavior: 'smooth' 
      });
    }
  };

  var init = function (selector) {
		initScrollIntoView(selector);
  };

  return {
    init: init
  };

})();

var ukti = window.ukti || {};

ukti.ScrollTo = (function($) {
  'use strict';

  var initScrollIntoView = function (selector) {
		document.querySelector(selector).scrollIntoView({ 
  		behavior: 'smooth' 
		});
  };

  var init = function (selector) {
		initScrollIntoView(selector);
  };

  return {
    init: init
  };

})();

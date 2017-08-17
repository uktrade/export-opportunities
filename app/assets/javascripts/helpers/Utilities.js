var ukti = window.ukti || {};

ukti.Utilities = (function($) {
  'use strict';

  var closestByClass = function (el, className) {
		while (el.className !== className) {
			el = el.parentNode;
			if (!el) {
				return null;
			}
		}
		return el;
  };

  return {
    closestByClass: closestByClass
  };

})();


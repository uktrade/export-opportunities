var ukti = window.ukti || {};

ukti.Utilities = (function($) {
  'use strict';

  var closestByClass = function (el, className) {
		while (el.className && el.className.indexOf(className) < 0) {
			el = el.parentNode;
			if (!el) {
				return null;
			}
		}
		return el;
  };

	var isValueEmpty = function (value) {
		return (/^ *$/.test(value));
	};

  var getValueFromRadioButton = function (name) {
   var buttons = document.getElementsByName(name);
   for(var i = 0; i < buttons.length; i++) {
      var button = buttons[i];
      if(button.checked) {
        return button.value;
      }
   }
   return null;
  };

  var removeEl = function (el) {
    el.parentNode.removeChild(el);
  };

  return {
    closestByClass: closestByClass,
    isValueEmpty: isValueEmpty,
    getValueFromRadioButton: getValueFromRadioButton,
    removeEl: removeEl
  };

})();


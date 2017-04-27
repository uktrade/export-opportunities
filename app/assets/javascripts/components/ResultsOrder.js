/* globals $ */

var ukti = window.ukti || {};

ukti.ResultsOrder = (function($) {
  'use strict';

	function changeHandler(event) {
		event.currentTarget.form.submit();
	}

	var attachBehaviour = function (el) {
		var radios = el.querySelectorAll('input[name="sort_column"]');
		Array.prototype.forEach.call(radios, function(radio) {
   		radio.addEventListener('change', changeHandler);
		});
	}

  var init = function (el) {
		attachBehaviour(el);
  };

  return {
    init: init
  };

})();

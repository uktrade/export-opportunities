var ukti = window.ukti || {};

ukti.ResultsOrder = (function() {
  'use strict';

	var changeHandler = function(event) {
		event.currentTarget.form.submit();
	};

	var attachBehaviour = function (el) {
		var radios = el.querySelectorAll('input[name="sort_column_name"]');
		for ( var i = 0; i < radios.length; i++ ) {
			radios[i].addEventListener('change', changeHandler);
		}
	};

  var init = function (el) {
		attachBehaviour(el);
  };

  return {
    init: init
  };

})();

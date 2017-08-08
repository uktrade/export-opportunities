var ukti = window.ukti || {};

ukti.ToogleFieldEdit = (function($) {
  'use strict';
  var baseEl;
  var fileListStore = [];

  var handleToggle = function () {

  }

  var attachBehaviour = function() {
  	var toggler = returnToggler();
  	var togglerParent = _parentEl.querySelector(_togglerParentSelector);
  	toggler.addEventListener('click', function (event) {
  		event.preventDefault();
			toggleFilters();
  	}, false);
  };

  var init = function (el) {
  	baseEl = el;
    attachBehaviour();
  };

  return {
    init: init
  };

})();


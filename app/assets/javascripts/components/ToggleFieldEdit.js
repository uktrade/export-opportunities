var ukti = window.ukti || {};

ukti.ToogleEditField = (function($) {
  'use strict';
  var selector = 'js-edit-field',
  var baseEl;
  var fileListStore = [];

  var handleToggle = function (event) {
    debugger;
  }

  var attachBehaviour = function() {
  	var togglers = returnToggler();
  	var togglerParent = _parentEl.querySelector(_togglerParentSelector);
  	toggler.addEventListener('click', function (event) {
  		event.preventDefault();
			handleToggle();
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


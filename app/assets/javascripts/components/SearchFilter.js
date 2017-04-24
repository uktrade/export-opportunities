/* globals $ */

var ukti = window.ukti || {};

ukti.SearchFilters = (function($) {
  'use strict';

	var _parentEl;
	var _openClass = 'filters-open';
	var _hiddenClass = 'hide';
  var _togglerParentSelector = '.filters__item__last';
  var _toggleGroup;
  var _toggleGroupSelector = '.filters__groupB';

  var hideFilters = function () {
  	_parentEl.classList.remove(_openClass);
  	_toggleGroup.style.display = 'none';
  	_toggleGroup.setAttribute('aria-hidden', 'true');
  };

  var showFilters = function () {
		_parentEl.classList.add(_openClass);
		_toggleGroup.style.display = 'block';
  	_toggleGroup.setAttribute('aria-hidden', 'false');
  	setFocusAfterToggle();
  };

  var setFocusAfterToggle = function () {
		_parentEl.querySelectorAll('.select2-search__field')[1].focus();
  };

  var returnToggler = function() {
		var toggler = document.createElement('a');
		toggler.classList.add('js-toggler');
		toggler.setAttribute('href', '#');
		toggler.setAttribute('aria-label', 'Filters');
		toggler.setAttribute('aria-controls', 'js-toggler');
		toggler.innerHTML = '<span class="close">Fewer filters</span><span class="open">More filters</span>';
		return toggler;
  };

  var addToggler = function() {
  	var toggler = returnToggler();
  	var togglerParent = _parentEl.querySelector(_togglerParentSelector);
  	toggler.addEventListener('click', function (event) {
  		event.preventDefault();
			toggleFilters();
  	}, false);
  	togglerParent.insertBefore(toggler, togglerParent.firstChild);
  };

  var toggleFilters = function (event) {
		if (_parentEl.classList.contains(_openClass)) {
			hideFilters();
		} else {
			showFilters();
		}
  };

  var initToggleFilters = function (el) {
  	_parentEl = el;
    _toggleGroup = _parentEl.querySelector(_toggleGroupSelector);
		addToggler();
		hideFilters();
  };

  var init = function (el) {
		initToggleFilters(el);
  };

  return {
    init: init
  };

})();

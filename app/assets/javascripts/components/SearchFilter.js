/* globals $ */

var ukti = window.ukti || {};

ukti.SearchFilters = (function() {
  'use strict';

	var _parentEl;
	var _openClass = 'filters-open';
	var _hiddenClass = 'hidden';
  var _togglerParentSelector = '.filters__item__last';
  var _toggleGroup;
  var _toggleGroupSelector = '.filters__groupB';
  var _filterOpenField;
  var _filterOpenFieldSelector = 'input[name$="filterOpen"]';

  var hideFilters = function () {
  	_parentEl.classList.remove(_openClass);
  	_toggleGroup.classList.add(_hiddenClass);
  	_toggleGroup.setAttribute('aria-hidden', 'true');
    setFilterOpenField (false);
  };

  var showFilters = function () {
		_parentEl.classList.add(_openClass);
		_toggleGroup.classList.remove(_hiddenClass);
  	_toggleGroup.setAttribute('aria-hidden', 'false');
  	setFocusAfterToggle();
    setFilterOpenField(true);
  };

  var setFocusAfterToggle = function () {
		var field = _parentEl.querySelectorAll('.select2-search__field')[1];
    if (field) {
      field.focus();
    }
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

  var setFilterOpenField = function (value) {
    _filterOpenField.value = value;
  };

  var returnFilterOpenFieldValue = function () {
    return _filterOpenField.value;
  };

  var checkHiddenFormField = function () {
    if (returnFilterOpenFieldValue() == 'false' || returnFilterOpenFieldValue() === '') {
      hideFilters();
    }
  };

  var initToggleFilters = function (el) {
    _parentEl = el;
    _toggleGroup = _parentEl.querySelector(_toggleGroupSelector);
    _filterOpenField = _parentEl.querySelector(_filterOpenFieldSelector);
    addToggler();
    checkHiddenFormField();
  };

  var init = function (el) {
		initToggleFilters(el);
  };

  return {
    init: init
  };

})();

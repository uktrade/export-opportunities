var ukti = window.ukti || {};

ukti.ToggleFieldEdit = (function($) {
  'use strict';
  var baseEl,
      labelEl,
      buttonEl,
      textEl,
      fieldElWrapper,
      fieldEl,
      hiddenClass = 'js-hidden';

  var cacheElements = function (el) {
    baseEl = el;
    labelEl = baseEl.querySelector( '.form-label' );
    buttonEl = baseEl.querySelector( '.js-toggle-field-edit-button' );
    textEl = baseEl.querySelector( '.js-toggle-field-edit-text' );
    fieldElWrapper = baseEl.querySelector( '.js-toggle-field-edit-field' );
    fieldEl = baseEl.querySelector( 'textarea' );
  };

  var handleToggle = function (event) {
    event.preventDefault();
    textEl.classList.toggle('js-hidden');
    fieldElWrapper.classList.toggle('js-hidden');
  };

  var setup = function () {
    if (fieldEl.value !== '') {
      setupFieldIsNotEmpty();
    } else {
      setupFieldIsEmpty();
    }
  };

  var setupFieldIsEmpty = function () {

  };

  var setupFieldIsNotEmpty = function () {

  };

  var attachBehaviour = function() {
    buttonEl.addEventListener('click', handleToggle, false);
  };

  var init = function (el) {
    cacheElements(el);
    setup();
    attachBehaviour();
  };

  return {
    init: init
  };

})();


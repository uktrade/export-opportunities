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

  var handleChange = function (event) {
    var fieldValue = event.target.value;
    if (!ukti.Utilities.isValueEmpty(fieldValue)) {
      Cookies.set('last_enquiry_response_signature', fieldValue);
    }
    updateText();
  };

  var setup = function () {
    if (Cookies.get('last_enquiry_response_signature')) {
      hasSignatureValue();
    } else {
      noSignatureValue();
    }
  };

  var hasSignatureValue = function () {
    fieldElWrapper.classList.add('js-hidden');
    updateText();
    updateField();
  };

  var noSignatureValue = function () {
    textEl.classList.add('js-hidden');
    buttonEl.add('js-hidden');
  };

  var updateText = function () {
    var text = Cookies.get('last_enquiry_response_signature');
    textEl.querySelector( '.white-space-pre' ).innerHTML = text;
  };

  var updateField = function () {
    var text = Cookies.get('last_enquiry_response_signature');
    fieldEl.value = text;
  };

  var attachBehaviour = function() {
    buttonEl.addEventListener('click', handleToggle, false);
    fieldEl.addEventListener('change', handleChange, false);
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


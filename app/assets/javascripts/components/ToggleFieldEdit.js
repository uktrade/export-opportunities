/* globals Cookies */

var ukti = window.ukti || {};

<<<<<<< HEAD
<<<<<<< HEAD
ukti.ToogleEditField = (function($) {
=======
ukti.ToggleFieldEdit = (function(Cookies) {
>>>>>>> 13799ba... (feature) showinf file name in attachments list
  'use strict';
  var selector = 'js-edit-field',
  var baseEl;
  var fileListStore = [];

  var handleToggle = function (event) {
<<<<<<< HEAD
    debugger;
  }

  var attachBehaviour = function() {
  	var togglers = returnToggler();
  	var togglerParent = _parentEl.querySelector(_togglerParentSelector);
  	toggler.addEventListener('click', function (event) {
  		event.preventDefault();
			handleToggle();
=======
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
>>>>>>> 717075f... PTU comms in stable
  	}, false);
=======
    event.preventDefault();
    textEl.classList.toggle(hiddenClass);
    fieldElWrapper.classList.toggle(hiddenClass);
  };

  var handleChange = function (event) {
    var fieldValue = event.target.value;
    Cookies.set('last_enquiry_response_signature', fieldValue);
    updateText();
  };

  var setup = function () {
    var text = Cookies.get('last_enquiry_response_signature');
    if (text && !ukti.Utilities.isValueEmpty(text)) {
      hasSignatureValue();
    } else {
      noSignatureValue();
    }
  };

  var hasSignatureValue = function () {
    fieldElWrapper.classList.add(hiddenClass);
    updateText();
    updateField();
  };

  var noSignatureValue = function () {
    textEl.classList.add(hiddenClass);
    buttonEl.classList.add(hiddenClass);
    fieldEl.value = '[full name],\n[role],\n[organisation name],\n[city & country],\n[phone number],\n[email]';
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
>>>>>>> 19b3357... (feature) saving signature with cookie
  };

  var init = function (el) {
  	baseEl = el;
    attachBehaviour();
  };

  return {
    init: init
  };

})(Cookies);


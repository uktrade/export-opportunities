var ukti = window.ukti || {};

ukti.Forms = (function($) {
  'use strict';

  var addErrorSummmary = function (el, errors) {
  	var errorEl;
    for (var i = 0; i < errors.length; i++) {
        html += errors[i];
    }
    errorEl.innerHTML = error;
  };

  var addErrorToField = function (el, error) {
  	var html = '';
		var formGroupEl = ukti.Utilities.closestByClass(el, 'form-group');
  	var errorEl = formGroupEl.querySelector( '.error-message' );
  	if (formGroupEl) {
    	formGroupEl.classList.add('form-group-error');
  	}
    if(errorEl) {
    	errorEl.innerHTML = error;
    }
		return el;
  };

  var clearErrorFromField = function (el) {
  	var formGroupEl = ukti.Utilities.closestByClass(el, 'form-group');
  	var errorEl = formGroupEl.querySelector( '.error-message' );
    formGroupEl.classList.remove('form-group-error');
    errorEl.innerHTML = '';
  };

  var clearErrorsFromFields = function (form) {
  	var formGroups = document.getElementsByClassName( 'form-group-error' );
		for(var i = 0; i < formGroups.length; i++) {
			debugger;
			formGroups.item(i);
		}
		var errorMessages = document.getElementsByClassName( '.error-message' );

  };

  return {
    addErrorToField: addErrorToField,
    clearErrorFromField: clearErrorFromField,
    clearErrorsFromFields: clearErrorsFromFields
  };

})();


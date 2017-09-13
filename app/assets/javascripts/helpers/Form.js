var ukti = window.ukti || {};

ukti.Forms = (function() {
  'use strict';

  var config = {
    formGroupClass: 'form-group',
    formGroupErrorClass: 'form-group-error',
    errorSelector: '.error-message'
  };

  var addErrorSummmary = function (el, errors) {
  	var html;
    for (var i = 0; i < errors.length; i++) {
        html += errors[i];
    }
  };

  var addErrorToField = function (el, error) {
		var formGroupEl = returnFormGroup(el);
  	var errorEl = returnErrorEl(formGroupEl);
  	if (formGroupEl) {
    	formGroupEl.classList.add(config.formGroupErrorClass);
  	}
    if(errorEl) {
    	errorEl.innerHTML = error;
    }
		return el;
  };

  var addErrorsToField = function (el, errors) {
    var html = '';
    for (var i = 0; i < errors.length; i++) {
        html += errors[i];
    }
    addErrorToField(el, html);
  };

  var clearErrorFromField = function (el) {
  	var formGroupEl = returnFormGroup(el);
  	var errorEl = returnErrorEl(formGroupEl);
    formGroupEl.classList.remove(config.formGroupErrorClass);
    errorEl.innerHTML = '';
  };

  var clearErrorsFromFields = function (form) {
  	var formGroups = document.getElementsByClassName( config.formGroupErrorClass );
    var formGroupsArray = Array.prototype.slice.call(formGroups);
		for(var i = 0; i < formGroupsArray.length; i++) {
      console.log(formGroupsArray[i]);
			clearErrorFromField(formGroupsArray[i]);
		}
  };

  var returnErrorEl = function (el) {
    return el.querySelector( config.errorSelector );
  };

  var returnFormGroup = function (el) {
    return ukti.Utilities.closestByClass(el, config.formGroupClass);
  };

  return {
    addErrorToField: addErrorToField,
    addErrorsToField: addErrorsToField,
    clearErrorFromField: clearErrorFromField,
    clearErrorsFromFields: clearErrorsFromFields,
    returnFormGroup: returnFormGroup
  };

})();


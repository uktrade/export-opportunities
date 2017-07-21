
var ukti = window.ukti || {};

ukti.OpportunityManagement = (function() {
  'use strict';

	var commentFormGroup = null,
			commentFormErrorEl = null,
			commentField = null,
			errorClass = 'form-group-error',
			errorMessage = 'Please add a comment to be sent to the original uploader before returning opportunity to draft state';

  var cacheElements = function () {
		var commentForm = document.getElementById('new_opportunity_comment_form');
		if (!commentForm) {
			return;
		}
		commentField = commentForm.querySelector('textarea[name="opportunity_comment_form[message]"]');
		commentFormGroup = commentForm.querySelector('.form-group-related');
		commentFormErrorEl = commentForm.querySelector('.error-message');
  };

  var addListeners = function () {
		addDraftButtonListeners();
  };

  var addDraftButtonListeners = function () {
		var buttons = document.querySelectorAll('.js-button-draft');
		for ( var i = 0; i < buttons.length; i++ ) {
			buttons[i].addEventListener('click', draftButtonHandler);
		}
  };

  var draftButtonHandler = function (event) {
		if (isValueEmpty(commentField.value)) {
			event.preventDefault();
			addErrorToCommentFormGroup();
		} else {
			return true;
		}
  };

  var addErrorToCommentFormGroup = function () {
		commentFormGroup.classList.add(errorClass);
		commentFormErrorEl.innerHTML = errorMessage;
		commentFormErrorEl.focus();
	};

  var clearErrorFromCommentField = function () {
		commentFormGroup.classList.remove(errorClass);
		commentFormErrorEl.innerHTML = '';
	};

	var isValueEmpty = function (value) {
		return (/^ *$/.test(value));
	};

  var init = function () {
  	cacheElements();
    addListeners();
  };

  return {
    init: init
  };

})();
/* globals $, moment, datePickerController */

var ukti = window.ukti || {};

ukti.DateFilterValidation = (function($, moment, datePickerController) {
    'use strict';

    var errorMessagesStore = {
      'invalidStartDate': 'The "From" date is invalid',
      'invalidEndDate': 'The "To" date is invalid',
      'invalidRange': 'The "From" date must be before the "To" date'
    };
    var errorMessages = [];

    var formSubmitHandler = function (event) {
      errorMessages = []; // reset error mesages

      var fromDay = $(event.target).find('select[id="created_at_from_day"]').val();
      var fromMonth = $(event.target).find('select[id="created_at_from_month"]').val();
      var fromYear = $(event.target).find('select[id="created_at_from_year"]').val();
      var fromDate = moment(fromDay + '-' + fromMonth + '-' + fromYear, "D-M-YYYY");

      var toDay = $(event.target).find('select[id="created_at_to_day"]').val();
      var toMonth = $(event.target).find('select[id="created_at_to_month"]').val();
      var toYear = $(event.target).find('select[id="created_at_to_year"]').val();
      var toDate = moment(toDay + '-' + toMonth + '-' + toYear, "D-M-YYYY");

      if (!isDateValid(fromDate) ) {
        errorMessages.push(errorMessagesStore.invalidStartDate);
      }

      if (!isDateValid(toDate) ) {
        errorMessages.push(errorMessagesStore.invalidEndDate);
      }

      if (isDateValid(fromDate) && isDateValid(toDate) && !isStartDateBeforeOrEqualToEndDate(fromDate, toDate)) {
        errorMessages.push(errorMessagesStore.invalidRange);
      }

      if (errorMessages.length) {
        event.preventDefault();
        displayErrorMessages(event.target);
        ukti.DisableSubmitButton.enable(event.target);   
        return false;
      }
      else {
        hideErrorMessages(event.target);
        return true;
      }
    };

    var isDateValid = function (date) {
      return date.isValid();
    };

    var isStartDateBeforeOrEqualToEndDate = function (fromDate, toDate) {
      return ( toDate.diff(fromDate, 'days') >= 0 );
    };

    var displayErrorMessages = function (form) {
      var $list = $(form).find('.error-summary-list');
      $list.empty();
      for (var i = 0; i < errorMessages.length; i++) {
          var $item = $('<li/>').text(errorMessages[i]);
          $list.append($item);
      }
      $(form).find('.error-summary').removeClass('hidden').attr('aria-hidden', 'false').focus();
    };

    var hideErrorMessages = function (form) {
      $(form).find('.error-summary').addClass('hidden').attr('aria-hidden', 'true');
    };

    var init = function ($form) {
      if ($form.length) {
        $form.on('submit', formSubmitHandler);
      }
    };

    return {
      init: init
    };

})($, moment, datePickerController);

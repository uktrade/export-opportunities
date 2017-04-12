/* globals $ */

var ukti = window.ukti || {};

ukti.DisableSubmitButton = (function($) {
  'use strict';

  var disable = function (form) {
    $(form).find('input[type="submit"]').attr('disabled', 'true');
  };

  var enable = function (form) {
    $(form).find('input[type="submit"]').removeAttr('disabled');
  };

  var handleFormChange = function (event) {
    enable(event.currentTarget);
  };

  var init = function ($form) {
    if ($form.length) {
      $form.on('submit', function() {
        var target = event.target ? event.target : event.srcElement;
        disable(target);
      });
      $form.on('change', handleFormChange);
    }
  };

  return {
    init: init,
    enable: enable
  };

})($);
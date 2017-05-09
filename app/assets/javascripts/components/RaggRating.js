var ukti = window.ukti || {};

ukti.RaggRating = (function($) {
  'use strict';

  var hiddenClass = 'hidden';

  var hideSubmitButton = function(form) {
    var submitButton = form.querySelector('input[type="submit"]');
    submitButton.classList.add(hiddenClass);
    submitButton.setAttribute('aria-hidden', 'true');
  };

  var changeHandler = function(event) {
    event.currentTarget.form.submit();
  };

  var attachBehaviour = function (form) {
    var radios = form.querySelectorAll('input[name="ragg"]');
    for ( var i = 0; i < radios.length; i++ ) {
      radios[i].addEventListener('change', changeHandler);
    }
  };

  var init = function (form) {
    hideSubmitButton(form);
    attachBehaviour(form);
  };

  return {
    init: init
  };

})();
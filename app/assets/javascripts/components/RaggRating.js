var ukti = window.ukti || {};

ukti.RaggRating = (function($) {
  'use strict';

  var hiddenClass = 'hidden';

  var changeHandler = function(event) {
    event.currentTarget.form.submit();
  };

  var attachBehaviour = function (form) {
    var radios = form.querySelectorAll('input[name="opportunity[ragg]"]');
    for ( var i = 0; i < radios.length; i++ ) {
      radios[i].addEventListener('change', changeHandler);
    }
  };

  var init = function (form) {
    attachBehaviour(form);
  };

  return {
    init: init
  };

})();
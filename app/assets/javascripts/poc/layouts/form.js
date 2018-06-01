// Layout: Form page/process
//
//= require ../dit.class.restricted_input.js

dit.page.form = (new function () {
  this.init = function() {
    enhanceRestrictedInputs();
  }

  function enhanceRestrictedInputs() {
    $("[maxlength]").each(function() {
      new dit.classes.RestrictedInput($(this));
    });
  }
});

$(document).ready(function() {
  dit.page.form.init();
});

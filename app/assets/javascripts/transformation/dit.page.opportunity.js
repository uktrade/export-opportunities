// Layout: opportunities#show
//
//= require transformation/dit.class.expander
//= require transformation/dit.class.simple_text_display_restrictor

dit.page.landing = (new function () {
  
  // Page init
  this.init = function() {
    clipDescription();
  }

  function clipDescription() {
    new dit.classes.SimpleTextDisplayRestrictor($("dd.description"), 50);
  }

});

$(document).ready(function() {
  dit.page.landing.init();
});

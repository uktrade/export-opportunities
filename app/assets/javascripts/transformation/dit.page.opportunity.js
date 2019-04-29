// Layout: opportunities#show
//
//= require transformation/dit.class.expander
//= require transformation/dit.class.simple_text_display_restrictor

dit.page.opportunity = (new function () {

  // Outside function to run immediately
  window.dataLayer.push({'pageCategory': 'OpportunityPage'});

  // Page init
  this.init = function() {
    clipDescription();
  }

  function clipDescription() {
    new dit.classes.SimpleTextDisplayRestrictor($("dd.description"), 50);
  }

});

// Init needs to wait for domReady.
$(document).ready(function() {
  dit.page.opportunity.init();
  dit.tagging.exopps.init("OpportunityPage");
});

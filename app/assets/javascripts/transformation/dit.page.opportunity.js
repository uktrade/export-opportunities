// Layout: opportunities#show
//
//= require transformation/dit.class.expander
//= require transformation/dit.class.simple_text_display_restrictor

dit.page.opportunity = (new function () {

  // Set immediately.
  this.abcButtonText = generateAbcButtonText();


  // Page init
  this.init = function() {
    applyAbcButtonTesting();
    clipDescription();
  }

  function clipDescription() {
    new dit.classes.SimpleTextDisplayRestrictor($("dd.description"), 50);
  }

  /* Quick and simple a/b/c testing.
   * Will create a bigger/more re-usable chunk of 
   * functionality when have time and/or need.
   **/
  function applyAbcButtonTesting() {
    var $button = $(".bid .abcbutton");
    var text = dit.page.opportunity.abcButtonText;

    // Update to the required wording. 
    $button.data("abcbuttontext", text);
    $button.text(text);

    // Add custom GA event to send value.
    $button.on("click", function(e) {
      ga("send", "event", "OpportunityButtonText", "click", dit.page.opportunity.abcButtonText);
    });
  }

  /* Generates appropriate a/b/c button text.
   * Sets value for use in GA
   * Returns value.
   **/
  function generateAbcButtonText() {
    return ["", // Not required.
      "Express your interest", 
      "Register your interest"][Math.floor((Math.random() * 2) + 1)];
  }
});

// Init needs to wait for domReady.
$(document).ready(function() {
  dit.page.opportunity.init();
});

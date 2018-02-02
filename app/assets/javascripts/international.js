// Default International code
//

//= require third_party/jquery-3.2.0.min
//= require dit
//= require dit.utils
//= require dit.responsive
//= require dit.geolocation
//= require dit.class.expander
//= require dit.class.accordion
//= require dit.class.modal
//= require dit.class.select_tracker
//= require dit.component.language_selector
//= require dit.component.menu

dit.pages.international = (new function () {
  var _international = this;
  var _cache = {
    // e.g. teasers_site: $()
  }
  
  // Page init
  this.init = function() {
    dit.responsive.init({
      "desktop": "min-width: 768px",
      "tablet" : "max-width: 767px",
      "mobile" : "max-width: 480px"
    });
    
    enhanceMenu();
    enhanceLanguageSelector();
    cacheComponents();
    viewAdjustments(dit.responsive.mode());
    bindResponsiveListener();
    
    delete this.init; // Run once
  }
  
  
  function cacheComponents() {
    // e.g. _cache.teasers_site = $("[data-component='teaser-site']");
  }

  function viewAdjustments(view) {
    switch(view) {
    case "desktop": // Fall through
      case "tablet":
        break;
      case "mobile":
        break;
    }
  }
    
  /* Bind listener for the dit.responsive.reset event
   * to reset the view when triggered.
   **/
  function bindResponsiveListener() {
    $(document.body).on(dit.responsive.reset, function(e, mode) {
      viewAdjustments(mode);
    });
  }
  
  /* Find and enhance any Language Selector Dialog view
   **/
  function enhanceLanguageSelector() {
    var $dialog = $("[data-component='language-selector-dialog']");
    dit.components.languageSelector.enhanceDialog($dialog, {
      $controlContainer: $("#personal-bar .container")
    });
  }

  /* Activate (Expander) dropdown functionality on the menu
   **/
  function enhanceMenu() {
    dit.components.menu.init();
    $("#menu").addClass("enhanced");
  }

});

$(document).ready(function() {
  dit.pages.international.init();
});


/* DO NOT WAIT FOR $(document).ready()
 * THIS SHOULD FIRE BEFORE <body> tag creation
 * Attempts to redirect user based on detected country
 * only if the location is site root (www.great.gov.uk/)
 **/
var root = location.protocol + "//" + location.host + "/";
if (location.href == root) {
  $(document).on(dit.geolocation.GEO_LOCATION_UPDATE_EVENT, function() { 
    dit.geolocation.redirectToCountryUrl("/"); 
  });
  dit.geolocation.fetchCountryCode();
}

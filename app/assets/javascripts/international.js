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
//= require dit.class.carousel
//= require dit.class.tabbed_area

dit.pages.international = (new function () {
  var _international = this;
  var _carouselResetTimer = null;
  var _cache = {
    effects: []
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
  
  
  /* Grab and store elements that are manipulated throughout
   * the lifetime of the page or, that are used across 
   * several functions
   **/
  function cacheComponents() {
    // e.g. _cache.teasers_site = $("[data-component='teaser-site']");
    _cache.benefitTitles = $(".benefit h3");
  }

  function viewAdjustments(view) {
    var alignHeights = dit.utils.alignHeights;
    switch(view) {
      case "desktop":
        alignHeights(_cache.benefitTitles);
        enhanceTestimonials();
        enhanceMeetCompanies();
        break;
      case "tablet":
        enhanceTestimonials();
        break;
      case "mobile":
        enhanceTestimonials();
        break;
    }
  }

  function clearAdjustments() {
    var clearHeights = dit.utils.clearHeights;
    clearHeights(_cache.benefitTitles);
  }
    
  /* Bind listener for the dit.responsive.reset event
   * to reset the view when triggered.
   **/
  function bindResponsiveListener() {
    $(document.body).on(dit.responsive.reset, function(e, mode) {
      clearAdjustments();
      destroyEffects();
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

  /* Add carousel effect to the testimonial quotes
   **/
  function enhanceTestimonials() {
    var $quotes = $("#testimonials .quote");
    if ($quotes.length) {
      clearTimeout(_carouselResetTimer);
      _cache.effects.push(new dit.classes.Carousel($quotes, {
        auto: 5000,
        controls: true,
        duration: 1000
      }));
    }
  }

  /* Add tabbed area effect to the 'Meet Companies' section
   **/
  function enhanceMeetCompanies() {
    _cache.effects.push(new dit.classes.TabbedArea(
      $("#meet-companies h3"), 
      $("#meet-companies .companies")
    ));
  }


  /* Destroy both carousels and tabbedAreas to 
   * cope with screen resizing.
   **/
  function destroyEffects() {
    while (_cache.effects.length > 0) {
      _cache.effects[0].destroy();
      _cache.effects.shift();
    }
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

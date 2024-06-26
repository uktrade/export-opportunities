// Layout: opportunities#international
//
//= require ../poc/dit.class.carousel
//= require ../poc/dit.class.tabbed_area
//= require ../poc/dit.class.selective_lookup
//= require ../poc/dit.class.filter_select

dit.page.landing = (new function () {
  var _landing = this;
  var _carouselResetTimer = null;
  var _cache = {
    effects: []
  }

  // Page init
  this.init = function() {
    cacheComponents();
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
    _cache.featuredIndustries = $("#featured-industries a");
  }

  function clearAdjustments() {
    var clearHeights = dit.utils.clearHeights;
    clearHeights(_cache.benefitTitles);
    clearHeights(_cache.featuredIndustries);
  }

  /* Bind listener for the dit.responsive.reset event
   * to reset the view when triggered.
   **/
  function bindResponsiveListener() {
    $(document.body).on(dit.responsive.reset, function(e, mode) {
      clearAdjustments();
      destroyEffects();
    });
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
  dit.page.landing.init();
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

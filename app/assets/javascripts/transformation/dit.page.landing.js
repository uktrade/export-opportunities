// Layout: opportunities#index
// ---------------------------------------------
//
//= require transformation/dit.class.carousel
//= require transformation/dit.class.tabbed_area
//= require transformation/dit.class.selective_lookup
//= require transformation/dit.class.filter_select
//= require transformation/dit.class.simple_form_restrictor

dit.page.landing = (new function () {
  var _landing = this;
  var _carouselResetTimer = null;
  var _cache = {
    effects: []
  }
  
  // Page init
  this.init = function() {
    cacheComponents();
    viewAdjustments(dit.responsive.mode());
    bindResponsiveListener();
    addSearchFormRestriction();
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

  function viewAdjustments(view) {
    var alignHeights = dit.utils.alignHeights;
    switch(view) {
      case "desktop":
        alignHeights(_cache.benefitTitles);
        alignHeights(_cache.featuredIndustries);
        enhanceTestimonials();
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
    clearHeights(_cache.featuredIndustries);
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

  /* Prevent user trying to submit an empty opportunity search.
   **/
  function addSearchFormRestriction() {
    $(".search-form").each(function() {
      var $this = $(this);
      new dit.classes.SimpleFormRestrictor($this, {
        errorMessage: $this.data("error-empty")
      });
    });
  }

  /* Add carousel effect to the testimonial quotes
   **/
  function enhanceTestimonials() {
    var $quotes = $("#testimonials .quote");
    if ($quotes.length) {
      clearTimeout(_carouselResetTimer);
      _cache.effects.push(new dit.classes.Carousel($quotes, {
        auto: 9000,
        controls: true,
        duration: 1250,
        fade: 1000
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
  dit.tagging.exopps.init("LandingPage");
});

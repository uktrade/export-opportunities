// Layout: opportunities#international
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
    addTaggings();
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

  function addTaggings() {
    addTaggingForTopCTA();
    addTaggingForBottomCTA();
    addTaggingForFeaturedIndustries;
  }

  function addTaggingForTopCTA() {
  $("#hero-banner-search").on("click", function(e) {
        window.dataLayer.push({'eventName': 'clicking on Export Opportunities landing page top CTA (above fold)'});
        window.dataLayer.push({'eventID': 'landing_cta_search_hero'});
      });
  }

  function addTaggingForBottomCTA() {
    $("#auxiliary-search").on("click", function(e) {
        window.dataLayer.push({'eventName': 'clicking on Export Opportunities landing page bottom CTA (below fold)'});
        window.dataLayer.push({'eventID': 'landing_cta_search_auxiliary'});
    });
  }

  function addTaggingForLogin() {
      $("#header-sign-in-link").on("click", function(e) {
          window.dataLayer.push({'eventName': 'clicking on top right sign in SSO link'});
          window.dataLayer.push({'eventID': 'landing_sso_signin'});
      });
      $("#header-register-link").on("click", function(e) {
          window.dataLayer.push({'eventName': 'clicking on top right register SSO link'});
          window.dataLayer.push({'eventID': 'langing_sso_register'});
          console.log(window.dataLayer);
      });
  }

  function addTaggingForFeaturedIndustries() {
      $('a[href*="/opportunities?sectors[]=creative-media"]').on("click", function(e){
          window.dataLayer.push({'eventName': 'clicking on landing page featured industries'});
          window.dataLayer.push({'eventID': 'creative-media'});
      });
      $('a[href*="/opportunities?sectors[]=education-training"]').on("click", function(e){
          window.dataLayer.push({'eventName': 'clicking on landing page featured industries'});
          window.dataLayer.push({'eventID': 'education-training'});
      });
      $('a[href*="/opportunities?sectors[]=food-drink"]').on("click", function(e){
          window.dataLayer.push({'eventName': 'clicking on landing page featured industries'});
          window.dataLayer.push({'eventID': 'food-drink'});
      });
      $('a[href*="/opportunities?sectors[]=oil-gas"]').on("click", function(e){
          window.dataLayer.push({'eventName': 'clicking on landing page featured industries'});
          window.dataLayer.push({'eventID': 'oil-gas'});
      });
      $('a[href*="/opportunities?sectors[]=security"]').on("click", function(e){
          window.dataLayer.push({'eventName': 'clicking on landing page featured industries'});
          window.dataLayer.push({'eventID': 'security'});
      });
      $('a[href*="/opportunities?sectors[]=retail-and-luxury"]').on("click", function(e){
          window.dataLayer.push({'eventName': 'clicking on landing page featured industries'});
          window.dataLayer.push({'eventID': 'retail-and-luxury'});
      });
  }

});

$(document).ready(function() {
  dit.page.landing.init();
});

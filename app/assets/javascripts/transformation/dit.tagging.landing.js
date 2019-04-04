// GA360 Tagging Functions.
// ---------------------

// REQUIRES
// jQuery

dit.tagging.landing = (new function() {

  // Page Tagging specific for landing
  // Do not wrap in a function because we want
  // this to run immediately on script load.
  window.dataLayer.push({'pageCategory': 'LandingPage'});

  // Event Tagging will be applied upon
  // calling this function.
  this.init = function() {
    addTaggingForSearch();
    addTaggingForFeaturedIndustries();
  }


  function addTaggingForSearch() {
    $("#hero-banner .submit").on("click", function(e) {
      window.dataLayer.push({
        eventName: 'clicking on Export Opportunities landing page top CTA (above fold)',
        eventID: 'landing_cta_search_hero'
      });
    });

    $("#auxiliary-search .submit").on("click", function(e) {
      window.dataLayer.push({
        eventName: 'clicking on Export Opportunities landing page bottom CTA (below fold)',
        eventID: 'landing_cta_search_auxiliary'
      });
    });
  }

  function addTaggingForFeaturedIndustries() {
    $("#featured-industries a").on("click", function() {
      var sector = this.href.replace(/.*?sectors\[\]=([\w]+)/, "$1");
      window.dataLayer.push({
        eventName: 'clicking on landing page featured industries',
        eventID: sector
      });
    });
  }

});

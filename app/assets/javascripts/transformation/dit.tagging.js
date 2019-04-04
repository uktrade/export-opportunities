// GA360 Tagging Functions.
// ---------------------

// REQUIRES
// jQuery

dit.tagging = {};

dit.tagging.all = (new function() {

  // Event Tagging will be applied upon
  // calling this function.
  this.init = function() {
    addTaggingForLogin();
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
});


dit.tagging.landing = (new function() {

    // Page Tagging specific for landing
    // Do not wrap in a function because we want
    // this to run immediately on script load.
    window.dataLayer.push({'pageCategory': 'LandingPage'});

    // Event Tagging will be applied upon
    // calling this function.
    this.init = function() {
        addTaggingForTopCTA();
        addTaggingForBottomCTA();
        addTaggingForFeaturedIndustries();
    }


    function addTaggingForTopCTA() {
        $("#hero-banner .submit").on("click", function(e) {
            window.dataLayer.push({'eventName': 'clicking on Export Opportunities landing page top CTA (above fold)'});
            window.dataLayer.push({'eventID': 'landing_cta_search_hero'});
        });
    }

    function addTaggingForBottomCTA() {
        $("#auxiliary-search .submit").on("click", function(e) {
            window.dataLayer.push({'eventName': 'clicking on Export Opportunities landing page bottom CTA (below fold)'});
            window.dataLayer.push({'eventID': 'landing_cta_search_auxiliary'});
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

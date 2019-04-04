// GA360 Tagging Functions.
// ---------------------

// REQUIRES
// jQuery

dit.tagging = {};

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

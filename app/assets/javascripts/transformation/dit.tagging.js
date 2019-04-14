// Specific Tagging Functionality.
// -------------------------------
// REQUIRES
// jQuery

dit.tagging.landing = (new function() {

  this.init = function() {
    addTaggingForSearch();
    addTaggingForFeaturedIndustries();
  }

  function addTaggingForSearch() {
    $("#hero-banner .search-form").on("submit", function() {
      window.dataLayer.push({
        'eventAction': 'Search',
        'eventCategory': 'Opportunity',
        'eventLabel': 'HeroBanner',
        'eventValue': $(this).find("input[type='search']").val()
      });
    });

    $("#auxiliary-search .search-form").on("submit", function() {
      window.dataLayer.push({
        'eventAction': 'Search',
        'eventCategory': 'Opportunity',
        'eventLabel': 'AuxillarySearch',
        'eventValue': $(this).find("input[type='search']").val()
      });
    });
  }

  function addTaggingForFeaturedIndustries() {
    $("#featured-industries a").on("click", function() {
      var sector = this.href.replace(/.*?sectors\[\]=([\w]+)/, "$1");
      window.dataLayer.push({
        'eventAction': 'Cta',
        'eventLabel': 'FeaturedIndustryTeaser',
        'eventValue': sector
      });
    });
  }
});


dit.tagging.results = (new function() {

  this.init = function() {}
});


// Header and footer pages.
// ------------------------
dit.tagging.headerFooter = (new function() {

  this.init = function() {
    addTaggingForLogin();
  }

  function addTaggingForLogin() {
    $("#header-sign-in-link").on("click", function() {
      window.dataLayer.push({
        'eventAction': 'SignIn',
        'eventCategory': 'Account',
        'eventLabel': 'HeaderSignInLink'
      });
    });

    $("#header-register-link").on("click", function() {
      window.dataLayer.push({
        'eventAction': 'Register',
        'eventCategory': 'Account',
        'eventLabel': 'HeaderRegisterLink'
      });
    });
  }
});



// Domestic
// ------------------------
dit.tagging.domestic = (new function() {

  this.init = function() {
    addTaggingForLogin();
  }

  function addTaggingForLogin() {
    $("#header-sign-in-link").on("click", function() {
      window.dataLayer.push({
        'eventAction': 'Login',
        'eventLabel': 'HeaderLoginLink'
      });
    });

    $("#header-register-link").on("click", function() {
      window.dataLayer.push({
        'eventAction': 'Register',
        'eventLabel': 'HeaderRegisterLink'
      });
    });
  }
});


// Specific Tagging Functionality.
// -------------------------------
// REQUIRES
// jQuery

dit.tagging.exopps = (new function() {

  this.landing = function() {
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




// Header and footer pages specific Tagging Functionality.
// -------------------------------------------------------
// REQUIRES
// jQuery
// dit.js


// dit namespace should exist as this script should be inserted
// after initialisation but, little defensive coding just in case.
var dit = dit || {};
dit.tagging = dit.tagging || {};

dit.tagging.headerFooter = (new function() {

  this.init = function() {
    addTaggingForAccountLinks();
    addTaggingForMenu();
    addTaggingForSearch();
  }

  function addTaggingForAccountLinks() {
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

  function addTaggingForMenu() {
    $("#great-header-nav li").on("click", function() {
      window.dataLayer.push({
        'eventAction': 'Navigation',
        'eventLabel': 'HeaderMenuLink',
        'eventValue': $(this).text()
      });
    });
  }

  function addTaggingForSearch() {
    $("#great-header form").on("submit", function() {
      window.dataLayer.push({
        'eventAction': 'Search',
        'eventCategory': 'General',
        'eventLabel': 'HeaderSearchBar',
        'eventValue': $(this).find("input[type='text']").val()
      });
    });
  }
});

// Instead of calling from existing page type initialisations
// just adding it directly here so inclusion of file should
// be all that is required. 
$(document).ready(function() {
  dit.tagging.headerFooter.init();
});


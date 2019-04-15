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



// Header and footer pages.
// ------------------------
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
        'eventCategory': 'Domestic',
        'eventLabel': 'HeaderSearchBar',
        'eventValue': $(this).find("input[type='text']").val()
      });
    });
  }
});



// Domestic
// ------------------------
dit.tagging.domestic = (new function() {

  this.home = function() {
    dit.tagging.headerFooter.init();
    addTaggingForEuExitBanner();
    addTaggingForHeroBannerVideo();
    addTaggingForServiceTeasers();
    addTaggingForAdviceTeasers();
    addTaggingForExporterStories();
  }

  this.searchResults = function() {
    dit.tagging.headerFooter.init();
  }

  function addTaggingForEuExitBanner() {
    $(".eu-exit-banner a").on("click", function() {
      window.dataLayer.push({
        'eventAction': 'ContentLink',
        'eventCategory': 'EuExit',
        'eventLabel': 'EuExitBanner',
        'eventValue': $(this).text()
      });
    });
  }

  function addTaggingForHeroBannerVideo() {
    $("#hero-campaign-section a").on("click", function() {
      window.dataLayer.push({
        'eventAction': 'ContentLink',
        'eventCategory': 'Video',
        'eventLabel': 'HeroBannerVideoLink'
      });
    });
  }

  function addTaggingForServiceTeasers() {
    $("#services a").on("click", function() {
      window.dataLayer.push({
        'eventAction': 'Cta',
        'eventCategory': 'Service',
        'eventLabel': 'Link',
        'eventValue': $(this).find('h3').text()
      });
    });
  }

  function addTaggingForAdviceTeasers() {
    $("#resource-advice a").on("click", function() {
      window.dataLayer.push({
        'eventAction': 'Cta',
        'eventCategory': 'Advice',
        'eventLabel': 'Link',
        'eventValue': $(this).find('h3').text()
      });
    });
  }

  function addTaggingForExporterStories() {
    $("#carousel h3 a").on("click", function() {
      window.dataLayer.push({
        'eventAction': 'Cta',
        'eventCategory': 'ExporterStory',
        'eventLabel': 'Link',
        'eventValue': $(this).text()
      });
    });
  }
});


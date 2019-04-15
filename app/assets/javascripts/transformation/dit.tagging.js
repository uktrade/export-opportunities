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
        'eventCategory': 'General',
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
    addTaggingForSearch();
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

  function addTaggingForSearch() {
    $("#search-results-information .search").on("submit", function() {
      window.dataLayer.push({
        'eventAction': 'Search',
        'eventCategory': 'General',
        'eventLabel': 'SearchResults',
        'eventValue': $(this).find("input[type='text']").val()
      });
    });
  }
});


// Selling Online Overseas
// ------------------------
dit.tagging.soo = (new function() {

  this.home = function() {
    dit.tagging.headerFooter.init();
    addTaggingForStories();
    addTaggingForSearch();
    addTaggingForFeedbackForm();
  }

  this.results = function() {
    dit.tagging.headerFooter.init();
    addTaggingForSearch();
    addTaggingForFeedbackForm();
  }

  this.marketplace = function() {
    dit.tagging.headerFooter.init();
    addTaggingForApply();
    addTaggingForMarketLink();
    addTaggingForFeedbackForm();
  }

  function addTaggingForStories() {
    $(".more-stories a").on("click", function() {
      window.dataLayer.push({
        'eventAction': 'Cta',
        'eventCategory': 'ExporterStory',
        'eventLabel': 'Link',
        'eventValue': $(this).find("h3").text()
      });
    });
  }

  function addTaggingForSearch() {
    $("#results-form").on("submit", function() {
      window.dataLayer.push({
        'eventAction': 'Search',
        'eventCategory': 'Marketplace',
        'eventLabel': 'SearchForm',
        'eventValue': $(this).find("#search-product").val() + "|" + $(this).find("#search-country").val()
      });
    });

    $("button:contains('Start your search now')[data-scrollto]").on("click", function() {
      window.dataLayer.push({
        'eventAction': 'Cta',
        'eventCategory': 'Search',
        'eventLabel': 'Link',
        'eventValue': $(this).text()
      });
    });
  }

  function addTaggingForApply() {
    $("#apply-to-join").on("click", function() {
      window.dataLayer.push({
        'eventAction': 'Cta',
        'eventCategory': 'MarketApplication',
        'eventLabel': 'Link',
        'eventValue': $(this).attr("href").replace(/.*\?market=([\w\s]+)/, "$1")
      });
    });
    $("#bottom-apply-to-join").on("click", function() {
      window.dataLayer.push({
        'eventAction': 'Cta',
        'eventCategory': 'MarketApplication',
        'eventLabel': 'Link',
        'eventValue': $(this).attr("href").replace(/.*\?market=([\w\s]+)/, "$1")
      });
    });
  }

  function addTaggingForMarketLink() {
    $(".markets-group .link").on("click", function() {
      window.dataLayer.push({
        'eventAction': 'ContentLink',
        'eventCategory': 'Marketplace',
        'eventLabel': 'MarketDetailsLink',
        'eventValue': $(this).text()
      });
    });
  }


  function addTaggingForFeedbackForm() {
    $(".thumber-form button").on("click", function() {
      window.dataLayer.push({
        'eventAction': 'Cta',
        'eventCategory': 'Feedback',
        'eventLabel': 'ThumberButton',
        'eventValue': $(this).text()
      });
    });
  }
});


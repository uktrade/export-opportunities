// Specific Tagging Functionality.
// -------------------------------
// REQUIRES
// jQuery

dit.tagging.exopps = (new function() {

  this.init = function(page) {
    switch(page) {
      case 'LandingPage':
        addTaggingForSearch();
        addTaggingForFeaturedIndustries();
      break;

      case 'SearchResultsPage':
        // No event tagging implemented, yet.
        break;

      case 'OpportunityPage':
      case 'EnquiriesPage':
      case 'NotificationPage':
        // No event tagging implemented, yet.
        break;

      default: // nothing
    }
  }

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

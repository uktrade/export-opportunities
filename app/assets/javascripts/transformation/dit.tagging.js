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
        addTaggingForSearch();
        break;

      case 'OpportunityPage':
        addTaggingForOpportunityButton();
        break;

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
    $("#hero-banner, #auxiliary-search, #opportunity-search-results").each(function() {
      var id = $(this).attr("id");
      $(".search, .search-form", this).on("submit", function() {
        window.dataLayer.push({
          'event': 'gaEvent',
          'action': 'Search',
          'type': 'Opportunity',
          'element': dit.utils.camelcase(id.split("-")),
          'value': $(this).find("input[type='search']").val()
        });
      });
    });
  }

  function addTaggingForFeaturedIndustries() {
    $("#featured-industries a").on("click", function() {
      var sector = this.href.replace(/.*?sectors\[\]=([\w]+)/, "$1");
      window.dataLayer.push({
        'event': 'gaEvent',
        'action': 'Cta',
        'element': 'FeaturedIndustryTeaser',
        'value': sector
      });
    });
  }

  function addTaggingForOpportunityButton() {
    $(".bid .button").on("click", function() {
      window.dataLayer.push({
        'event': 'gaEvent',
        'action': 'Cta',
        'element': 'InterestInOpportunity',
        'value': $(this).attr("href").charAt(0) == "/" ? "DIT" : "ThirdParty"
      });
    });
  }
});

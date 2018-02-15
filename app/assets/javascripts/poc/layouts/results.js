// Layout: opportunities#results
//
//= require ../dit.class.selective_lookup
//= require ../dit.class.filter_select

dit.page.results = (new function () {
  var _results = this;
  var _cache = {
  }
  
  // Page init
  this.init = function() {
    enhanceIndustrySelector();

    cacheComponents();
    viewAdjustments(dit.responsive.mode());
    bindResponsiveListener();
    
    delete this.init; // Run once
  }
  
  
  /* Grab and store elements that are manipulated throughout
   * the lifetime of the page or, that are used across 
   * several functions
   **/
  function cacheComponents() {
    // e.g. _cache.teasers_site = $("[data-component='teaser-site']");
  }

  function viewAdjustments(view) {
    var alignHeights = dit.utils.alignHeights;
    switch(view) {
      case "desktop":
        break;
      case "tablet":
        break;
      case "mobile":
        break;
    }
  }
    
  /* Bind listener for the dit.responsive.reset event
   * to reset the view when triggered.
   **/
  function bindResponsiveListener() {
    $(document.body).on(dit.responsive.reset, function(e, mode) {
      viewAdjustments(mode);
    });
  }

  /* Find and enhance the search form Industory <select> field
   **/
  function enhanceIndustrySelector() {
    $("[data-component='filter-select']").each(function() {
      new dit.classes.FilterSelect($(this));
    });
  }


});

$(document).ready(function() {
  dit.page.results.init();
});


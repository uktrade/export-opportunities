// View: admin/opportunity (new/edit)
//
//= require transformation/dit.js

dit.admin.opportunity = (new function () {
  var _cache = {}

  this.init = function() {
    cacheComponents();
    adjustTargetUrlField();
    bindTargetUrlFieldController();

    delete this.init; // Run once
  }
  
  /* Grab and store elements that are manipulated throughout the
   * lifetime of the page or used across several functions.
   **/
  function cacheComponents() {
    _cache.$serviceProvider = $("[data-node='service-provider'] select");
    _cache.$targetUrl = $("[data-node='target-url']");
  }

  /* Listen for changes to the Service Provider
   * and adjust Opportunity Target URL field. 
   **/
  function bindTargetUrlFieldController() {
    _cache.$serviceProvider.on("change", adjustTargetUrlField);
  }

  /* Control visibility of Opportunity Target URL field
   **/
  function adjustTargetUrlField() {
    var serviceProviderName = _cache.$serviceProvider.children().eq(_cache.$serviceProvider.get(0).selectedIndex).text()
    if (serviceProviderName == "DFID") {
      _cache.$targetUrl.show();
    }
    else {
      _cache.$targetUrl.hide();
    }
  }
});

$(document).ready(function() {
  dit.admin.opportunity.init();
});

// View: admin/opportunity (new/edit)
//
// required dit.js
// required dit.utils.js
//= require transformation/dit.class.selective_lookup.js
//= require transformation/dit.class.data_provider.js
//= require transformation/dit.class.filter_multiple_select.js


dit.admin.opportunity = (new function () {
  var _cache = {}

  this.init = function() {
    cacheComponents();
    adjustTargetUrlField();
    bindFilterSelects();
    bindTargetUrlFieldController();

    delete this.init; // Run once
  }
  
  /* Grab and store elements that are manipulated throughout the
   * lifetime of the page or used across several functions.
   **/
  function cacheComponents() {
    _cache.$serviceProvider = $("[data-node='service-provider']");
    _cache.$targetUrlParent = $("[data-node='target-url']").parent();
    _cache.$companyInput = $("[data-node='countries']")
    _cache.$sectorInput = $("[data-node='sectors']")
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
    var serviceProviderName = _cache.$serviceProvider.val();
    if (serviceProviderName == "DFID") {
      _cache.$targetUrlParent.show();
    }
    else {
      _cache.$targetUrlParent.hide();
    }
  }

  /* Experiment... */
  /**/
  function bindFilterSelects() {
    new dit.classes.FilterMultipleSelect(_cache.$companyInput, {
      title: _cache.$companyInput.data("display"),
      unselected: _cache.$companyInput.data("unselected")
    });

    new dit.classes.FilterMultipleSelect(_cache.$sectorInput, {
      title: _cache.$sectorInput.data("display"),
      unselected: _cache.$sectorInput.data("unselected")
    });
  }
});

$(document).ready(function() {
  dit.admin.opportunity.init();
});

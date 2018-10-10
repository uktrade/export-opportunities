// View: admin/opportunity (new/edit)
//
// required dit.js
// required dit.utils.js
//= require transformation/dit.class.selective_lookup.js
//= require transformation/dit.class.data_provider.js
//= require transformation/dit.class.filter_multiple_select.js


dit.page.opportunity = (new function () {
  var _cache = {}

  this.init = function() {
    cacheComponents();
    setupTargetUrlField();
    setupFilterMultipleSelectFields();

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

  /* Add visual toggle to show/hide Target URL field, 
   * based on Service Provider field changes. 
   **/
  function setupTargetUrlField() {
    var $serviceProviderField = _cache.$serviceProvider;
    var $targetUrlField = _cache.$targetUrlParent;

    // Bind the event handling.
    $serviceProviderField.on("change", function() {
      // 252 == DFID
      if ($serviceProviderField.val() == 252) {
        $targetUrlField.show();
      }
      else {
        $targetUrlField.hide();
      }
    });

    // Trigger the event for initial view adjustment
    $serviceProviderField.trigger("change");
  }

  /* Turn regular <select> fields into enhanced FilterMultipleSelect
   * components.
  /**/
  function setupFilterMultipleSelectFields() {
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
  dit.page.opportunity.init();
});

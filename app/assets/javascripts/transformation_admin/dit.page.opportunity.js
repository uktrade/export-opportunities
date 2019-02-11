// View: admin/opportunity (new/edit)
//
// required dit.js
// required dit.utils.js
//= require transformation/dit.class.selective_lookup.js
//= require transformation/dit.class.cpv_code_lookup.js
//= require transformation/dit.class.data_provider.js
//= require transformation/dit.class.service.js
//= require transformation/dit.class.filter_multiple_select.js
//= require transformation/dit.class.expander.js


dit.page.opportunity = (new function () {
  var _cache = {}

  this.init = function() {
    cacheComponents();
    setupTargetUrlField();
    setupFilterMultipleSelectFields();
    setupExpanders();
    setupCpvLookup();

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
    _cache.$process = $(".process");
    _cache.$history = $(".history");
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
    if(_cache.$companyInput.length && _cache.$sectorInput.length) {
      new dit.classes.FilterMultipleSelect(_cache.$companyInput, {
        title: _cache.$companyInput.data("display"),
        unselected: _cache.$companyInput.data("unselected")
      });

      new dit.classes.FilterMultipleSelect(_cache.$sectorInput, {
        title: _cache.$sectorInput.data("display"),
        unselected: _cache.$sectorInput.data("unselected")
      });
    }
  }

  /* Add visual toggle to show/hide Target URL field, 
   * based on Service Provider field changes. 
   **/
  function setupExpanders() {
    var areas = [_cache.$process, _cache.$history]
    for(i=0; i<areas.length; ++i) {
      var $control = areas[i].find('h2');
      var $container = areas[i].find('.container');
      var $wrapper = $("<div></div>");
      $wrapper.append($container.children());
      $container.append($control);
      $container.append($wrapper);
      if($wrapper.length && $control.length) {
        new dit.classes.Expander($wrapper, { $control: $control, closed: false, blur: false });
      }
    }
  }

  /* Enhance CPV code entry field and create a service
   * to fetch data from CPV (??where??) API.
   * NOTE: For dummy development, just using the existing Companies House API
   **/
  function setupCpvLookup() {
    var $cpvInput = $("#opportunity_opportunity_cpv_ids");
    var lookup;
    if($cpvInput.length) {
      service = new dit.classes.Service(dit.constants.CPV_CODE_LOOKUP_URL);
      lookup = new dit.classes.CpvCodeLookup($cpvInput, service, {
         multiple: true
      });

/*
      lookup.bindContentEvents = function() {
        var instance = this;

        // First allow the normal functionality to run.
        dit.classes.CompaniesHouseNameLookup.prototype.bindContentEvents.call(instance);

        // Now add the customisations for ExOpps Enquiry form.
        instance._private.$list.on("click.CompaniesHouseNameLookup", function(event) {
          var companies = dit.data.getCompanyByName.data;
          var number = instance._private.$field.val();
          var postcode;
          for(var i=0; i<companies.length; ++i) {
            if(companies[i].company_number == number) {
              postcode = companies[i].address.postal_code;
              $("#enquiry_company_postcode").val(postcode);
              $("#enquiry_company_address").val(companies[i].address_snippet.replace(postcode, ""));
            }
          }
        });
      }
*/
    }
  }
});

$(document).ready(function() {
  dit.page.opportunity.init();
});

// Layout: enquiries
// action: enquiries#new
// action: enquiries#ceate
//
//= require transformation/dit.class.selective_lookup.js
//= require transformation/dit.class.service.js
//= require transformation/dit.class.companies_house_name_lookup.js

dit.page.enquiries = (new function () {
  var ENQUIRIESS = this;
  var SelectiveLookup = dit.classes.SelectiveLookup;
  var _cache = {
  }

  // Page init
  this.init = function() {
    cacheComponents();
    viewAdjustments(dit.responsive.mode());
    bindResponsiveListener();
    setupCompaniesHouseLookup();
    toggleDivFromCheckInput();

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

  /* Enhance Company entry fields and create a service
   * to fetch data from Companies House API.
   **/
  function setupCompaniesHouseLookup() {
    var $companyNameInput = $("#enquiry_company_name");
    var $companyNumberOutput = $("#enquiry_company_house_number");
    var lookup;
    if($companyNameInput.length) {
      dit.data.getCompanyByName = new dit.classes.Service(dit.constants.COMPANIES_HOUSE_SEARCH);
      lookup = new dit.classes.CompaniesHouseNameLookup($companyNameInput, {
        $after: $companyNameInput,
        $output: $companyNumberOutput
      });

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
    }
  }

  function toggleDivFromCheckInput() {
    var $parent = $('div.expandable-container'),
        $trigger = $parent.find('input[type=checkbox]'),
        $target =  $parent.find('div.expandable');

      if(!$trigger.prop('checked')) {
        $target.addClass('hidden');
      } else {
        $trigger.removeClass('hidden')
      }

    $trigger.on('change', function(){
        var $this = $(this);
        if(!$this.prop('checked')) {
            $target.addClass('hidden');
          } else {
            $target.removeClass('hidden');
        }
    });
  }

});


/* Initiate script */
$(document).ready(function() {
  dit.page.enquiries.init();
  dit.tagging.exopps.init("EnquiriesPage");
});


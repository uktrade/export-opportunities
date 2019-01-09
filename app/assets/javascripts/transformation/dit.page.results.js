// Layout: opportunities#results
//
//= require transformation/dit.class.selective_lookup
//= require transformation/dit.class.filter_select
//= require transformation/dit.class.simple_form_restrictor

dit.page.results = (new function () {
  var RESULTS = this;
  
  // Page init
  this.init = function() {
    enhanceResultFilters();
    bindAutoUpdateListener();
    addSearchFormRestriction();

    delete this.init; // Run once
  }

  /* Find and enhance the filter groups.
   * Note: We get the groups and labels outside the loop
   * to avoid issues with closures.
   **/
  function enhanceResultFilters() {
    RESULTS.expanders = [];
    $groups = $(".search-results-filters fieldset");
    $labels = $groups.find("legend");
    $groups.each(function(index) {
      RESULTS.expanders.push(new dit.classes.Expander($(this), {
        closed: false,
        $control: $labels.eq(index),
        blur: false,
        controlReplacementEnabled: false
      }));
    });
  }

  /* Auto-update results when sort value is changed.
   **/
  function bindAutoUpdateListener() {
    $("#search-sort").on("change", function() {
      this.form.submit();
    });
  }

  /* Prevent user trying to submit an empty opportunity search.
   **/
  function addSearchFormRestriction() {
    new dit.classes.SimpleFormRestrictor($(".search"));
  }

});

$(document).ready(function() {
  dit.page.results.init();
});


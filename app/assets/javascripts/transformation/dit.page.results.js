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
    addAccessibilityHelpers();
    setUpSort();

    delete this.init; // Run once
  }

  /* Find and enhance the filter groups.
   * Note: We get the groups and labels outside the loop
   * to avoid issues with closures.
   **/
  function enhanceResultFilters() {
    var $groups = $(".search-results-filters fieldset");
    RESULTS.expanders = [];

    $groups.each(function(index) {
      var $group = $(this);
      RESULTS.expanders.push(new dit.classes.Expander($group.find(".field"), {
        closed: false,
        $control: $group.find("legend"),
        blur: false,
        wrap: true
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

  function addAccessibilityHelpers() {
    $('.sort label', '#search-results-panel').append('<span class="verbose">Selecting an option will refresh the page.</span>');
    $('#search-sort').attr('aria-controls', 'opportunities-list');
  }

  function setUpSort(){
    $('.jsonly').show()
    $("#search-sort").change(function() {
      var selectedSort = $(this).children("option:selected").val();
      $('#hidden_sort_column_name').val(selectedSort)
      $('.submit').click()
    });
  }

});



$(document).ready(function() {
  dit.page.results.init();
  dit.tagging.exopps.init("SearchResultsPage");
});


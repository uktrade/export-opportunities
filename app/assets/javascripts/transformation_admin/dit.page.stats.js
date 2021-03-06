// View: admin/stats
//
// required dit.js
// required dit.utils.js
//= require transformation/dit.class.data_provider.js
//= require transformation/dit.class.filter_multiple_select.js
//= require transformation/dit.class.tabbed_area.js



dit.page.stats = (new function () {
  var _cache = {}

  this.init = function() {
    cacheComponents();
    setupFilterMultipleSelectFields();
    setupGranularityFields();

    delete this.init; // Run once
  }


  /* Grab and store elements that are manipulated throughout the
   * lifetime of the page or used across several functions.
   **/
  function cacheComponents() {
  }


  /* Turn regular <select> fields into enhanced FilterMultipleSelect
   * components.
  /**/
  function setupFilterMultipleSelectFields() {
    $("[data-node=countries], [data-node=providers], [data-node=regions]").each(function() {
      var $field = $(this);
      new dit.classes.FilterMultipleSelect($field, {
        title: $field.data("display"),
        unselected: $field.data("unselected")
      });
    });
  }


  /* Add tabbed viewing to granulatiry controls.
  /**/
  function setupGranularityFields() {
    var $tabs = $("input[name='granularity']");
    var $panels = $(".field-source, .field-regions, .field-countries, .field-providers");
    new dit.classes.TabbedArea($tabs, $panels, {
      $parent: $(".field-granularity")
    });
  }
});

$(document).ready(function() {
  dit.page.stats.init();
});

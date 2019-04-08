// Main/Global/All pages JS files for site
//
//= require transformation/third_party/jquery-3.3.1.min
//= require transformation/dit
//= require transformation/dit.utils
//= require transformation/dit.responsive
//= require transformation/dit.geolocation
//= require transformation/dit.tagging.all
//= require transformation/dit.class.expander
//= require transformation/dit.class.accordion
//= require transformation/dit.class.modal
//= require transformation/dit.class.select_tracker


dit.page.all = (new function () {
  var _cache = {}

  // Page init
  this.init = function() {
    dit.responsive.init({
      "desktop": "min-width: 768px",
      "tablet" : "max-width: 767px",
      "mobile" : "max-width: 480px"
    });

    cacheComponents();
    viewAdjustments(dit.responsive.mode());
    bindResponsiveListener();

    delete this.init; // Run once
  }

  /* Grab and store elements that are manipulated throughout
   * the lifetime of the page or, that are used across
   * several functions in this file.
   **/
  function cacheComponents() {
    // _cache.something = $("#something");
  }

  /* View adjustments to keep up with responsive adjustments.
   * Add functions calls to specific view modes.
   **/
  function viewAdjustments(view) {
    switch(view) {
      case "desktop":
        // e.g. do something only in Desktop view here.
        break;
      case "tablet":
        break;
      case "mobile":
        break;
    }
  }

  /* Use this to reverse any applied viewAdjustments
   * you may have done for specific view modes.
   **/
  function clearViewAdjustments() {
    // e.g. reset that thing done for desktop only.
  }

  /* Bind listener for the dit.responsive.reset event.
   * Triggers reset and view update functions again, passing
   * the relevant view mode to viewAdjustments function.
   **/
  function bindResponsiveListener() {
    $(document.body).on(dit.responsive.reset, function(e, mode) {
      clearViewAdjustments();
      viewAdjustments(mode);
    });
  }
});


$(document).ready(function() {
  dit.page.all.init();
  dit.tagging.all.init();
});

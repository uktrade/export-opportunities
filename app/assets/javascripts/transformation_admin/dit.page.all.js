// Main/Global/All pages JS files for site
//
//= require transformation/third_party/jquery-3.2.0.min
//= require transformation/dit
//= require transformation/dit.utils
//= require transformation/dit.responsive


dit.admin.all = (new function () {
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
   * several functions
   **/
  function cacheComponents() {
  }

  /* View adjustments to keep up with responsive adjustments.
   **/
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

  /* Reverse any applied viewAdjustments
   **/
  function clearViewAdjustments() {
  }

  /* Bind listener for the dit.responsive.reset event
   * to reset the view when triggered.
   **/
  function bindResponsiveListener() {
    $(document.body).on(dit.responsive.reset, function(e, mode) {
      clearViewAdjustments();
      viewAdjustments(mode);
    });
  }

});


$(document).ready(function() {
  dit.admin.all.init();
});

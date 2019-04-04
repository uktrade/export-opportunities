// Main/Global/All pages JS files for site
//
//= require transformation/third_party/jquery-3.3.1.min
//= require transformation/dit
//= require transformation/dit.utils
//= require transformation/dit.responsive
//= require transformation/dit.geolocation
//= require transformation/dit.tagging
//= require transformation/dit.class.expander
//= require transformation/dit.class.accordion
//= require transformation/dit.class.modal
//= require transformation/dit.class.select_tracker
//= require transformation/dit.component.language_selector
//= require transformation/dit.component.menu
//= require dit.components.cookie-notice


dit.page.all = (new function () {
  var _cache = {
    submenuItems: $(),
    submenuLinks: $()
  }

  // Page init
  this.init = function() {
    dit.responsive.init({
      "desktop": "min-width: 768px",
      "tablet" : "max-width: 767px",
      "mobile" : "max-width: 480px"
    });

    enhanceLanguageSelector();
    enhanceMenu();

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
    _cache.submenuItems = $("#menu .level-2 li");
    _cache.submenuLinks = $("#menu .level-2 a");
  }

  /* View adjustments to keep up with responsive adjustments.
   **/
  function viewAdjustments(view) {
    var alignHeights = dit.utils.alignHeights;
    switch(view) {
      case "desktop":
        alignHeights(_cache.submenuItems);
        alignHeights(_cache.submenuLinks);
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
    var clearHeights = dit.utils.clearHeights;
    clearHeights(_cache.submenuItems);
    clearHeights(_cache.submenuLinks);
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

  /* Find and enhance any Language Selector Dialog view
   **/
  function enhanceLanguageSelector() {
    var $dialog = $("[data-component='language-selector-dialog']");
    if($dialog.length) {
      dit.components.languageSelector.enhanceDialog($dialog, {
        $controlContainer: $("#personal-bar .container")
      });
    }
  }

  /* Activate (Expander) dropdown functionality on the menu
   **/
  function enhanceMenu() {
    dit.components.menu.init();
    $("#menu").addClass("enhanced");
  }
});


$(document).ready(function() {
  dit.page.all.init();
  dit.tagging.all.init();
});

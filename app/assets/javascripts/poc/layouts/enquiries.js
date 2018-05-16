// Layout: enquiries
// action: enquiries#new
// action: enquiries#ceate
//

//= require ./form.js

dit.page.enquiries = (new function () {
  var ENQUIRIESS = this;
  var _cache = {
  }
  
  // Page init
  this.init = function() {
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

});


/* Initiate script */
$(document).ready(function() {
  dit.page.enquiries.init();
});


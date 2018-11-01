// View: admin/opportunity#show
//
// required dit.js
// required dit.utils.js
//= require transformation/dit.class.expander.js


dit.page.opportunityShow = (new function () {
  var _cache = {}

  this.init = function() {
    cacheComponents();
    setupExpanders();

    delete this.init; // Run once
  }
  
  /* Grab and store elements that are manipulated throughout the
   * lifetime of the page or used across several functions.
   **/
  function cacheComponents() {
    _cache.$details = $(".details");
    _cache.$history = $(".history");
    _cache.$checks = $(".checks");
    _cache.$enquiries = $(".enquiries");
  }

  /* Add visual toggle to show/hide Target URL field, 
   * based on Service Provider field changes. 
   **/
  function setupExpanders() {
    var areas = [_cache.$details, _cache.$history, _cache.$checks, _cache.$enquiries]
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
});

$(document).ready(function() {
  dit.page.opportunityShow.init();
});

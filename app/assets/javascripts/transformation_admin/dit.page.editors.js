// View: admin/editors
//
// required dit.js
// required dit.utils.js


dit.page.editors = (new function () {
  var _cache = {}

  this.init = function() {
    cacheComponents();

    delete this.init; // Run once
  }
  
  /* Grab and store elements that are manipulated throughout the
   * lifetime of the page or used across several functions.
   **/
  function cacheComponents() {
  }
});

$(document).ready(function() {
  dit.page.editors.init();
});

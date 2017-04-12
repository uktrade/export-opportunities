'use strict';

var CORE_JS = (function ($) {
  // Detect request animation frame
  var totalSectorItems = 0,
      init = function () {
      $(domReady); // same as $(document).ready (function () {...});
    },

    // this runs only when we know the whole DOM is ready
    domReady = function () {
      if( $('.filters').length ) {
        OPPORTUNITIES.init();
      }
    };

  return {
    go : init
  };

})(jQuery);

CORE_JS.go();

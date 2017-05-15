//for requiring a script loaded asynchronously.

var ukti = window.ukti || {};

ukti.asyncLoad = (function($) {
  'use strict';

  var init = function (src, callback, relative) {
    var baseUrl = "/";
    var script = document.createElement('script');
    if (relative === true) {
      script.src = baseUrl + src;  
    } else {
      script.src = src; 
    }

    if(callback !== null){
        if (script.readyState) { // IE, incl. IE9
            script.onreadystatechange = function() {
                if (script.readyState == "loaded" || script.readyState == "complete") {
                    script.onreadystatechange = null;
                    callback();
                }
            };
        } else {
            script.onload = function() { // Other browsers
                callback();
            };
        }
    }
    document.getElementsByTagName('head')[0].appendChild(script);
  };

  return {
    init: init
  };

})();


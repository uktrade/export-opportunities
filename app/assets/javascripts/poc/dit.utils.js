// Utility Functions.
// ---------------------

// REQUIRES
// jQuery
// dit.js

dit.utils = (new function () {
  
  /* Attempt to generate a unique string
   * e.g. For HTML ID attribute.
   * @str = (String) Allow prefix string.
   **/
  this.generateUniqueStr = function (str) {
    return (str ? str : "") + ((new Date().getTime()) + "_" + Math.random().toString()).replace(/[^\w]*/mig, "");
  }
  
  /* Attempt to run a namespaced function from passed string.
   * e.g. dit.utils.executeNamespacedFunction("dit.utils.generateUniqueStr");
   * @namespace (String) Namespaced function like above example.
   **/
  this.executeNamespacedFunction = function (namespace) {
    var names = arguments.length ? namespace.split('.')  : null;
    var context = window;
    if (namespace) {
      while (names.length > 1) {
        context = context[names.shift()];
      }
      context[names.shift()]();
    }
  }
  
  /* Return max height measurement of passed elements
   * @$items (jQuery collection) elements to compare.
   **/
  this.maxHeight = function ($items, outer) {
    var max = 0;
    $items.each(function () {
      var $this = $(this);
      var height = outer ? $this.outerHeight(true) : $this.height();
      max = height > max ? height : max;
    });
    return max;
  }
  
  /* Align heights of elements in row where 
   * CSS fails or using this is easier.
   * $items = (String) jQuery selector to target elements.
   **/
  this.alignHeights = function ($items) {
    var collection = $();
    var max = 0;
    var lasttop;

    function align(items) {
      var max = dit.utils.maxHeight(items);
      items.height(max + "px");
    }

    $items.each(function () {
      var $this = $(this);
      var newtop = $this.position().top;
      if (newtop !== lasttop) {
        // Find max height
        align(collection);
        collection = $();
      }

      lasttop = newtop;
      collection = collection.add($this);
    });

    // Catch the last collection 
    // (or first/only if they're all the same)
    align(collection); 
  }
  
  
  /* Basically the reset to alignHeights because 
   * it clears the inline height setting.
   * $items = (String) jQuery selector to target elements.
   **/
  this.clearHeights = function ($items) {
    $items.each(function () {
      this.style.height = "";
    });
  }
  
  /* Take an array of images that support the load event, and runs the passed 
   * function only when each event has fired. Because the load event might have
   * already triggered before this function is called, we going to do a deep-clone
   * of the original image, add the load event to that clone, and then replace the
   * original image with the clone. The load event should fire as expected.
   *
   * @elements (Array) Collection of elements with capability of firing a load event.
   * @action (Function) The callback function to run. 
   * @params (Array) Optional params that can be passed to callback.
   **/
  this.whenImagesReady = function($images, action, params) {
    var loaded = 0;
    var parameters = arguments.length > 2 ? params : [];
    var all = $images.length;
      
    $images.each(function() {
      var $original = $(this);
      var $replacement = $original.clone(true, true);
      
      // Add a load event to keep track of what's in.
      $replacement.on("load.whenready", function() {
        if (++loaded == all) {
          action.apply(window, parameters);
        }
        
        // Remove event triggered to prevent re-clone issues.
        $(this).off("load.whenready"); 
      });
      
      // Replace original
      $original.css("display", "none");
      $original.before($replacement);
    });
    
    // No longer need the old ones
    $images.remove();
  }
});
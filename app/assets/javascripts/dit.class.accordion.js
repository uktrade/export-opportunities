/* Class will add a controller before the $target element.
 * The triggered event will toggle a class on the target element and controller.
 * the target element with collapse, or expand.
 *
 * Note: The COLLAPSED class is added when the Expander element is closed, so
 * you can add additional CSS for this state. Inline style, display:none is
 * added by the code (mainly only because IE8 doesn't support CSS transitions).
 *
 * REQUIRES:
 * jquery
 * dit.js
 * dit.utils.js
 * dit.classes.expander.js
 *
 **/

(function($, utils, classes) {
  
  function Accordion(items, open, close) {  
    if (arguments.length) {
      this.items = items;
      
      for (var i=0; i<items.length; ++i) {
        Accordion.enhance.call(this, items[i], open, close);
      }
    }
  }
  Accordion.enhance = function(target, open, close) {
    var items = this.items;
    var originalOpen = target[open];
    target[open] = function() {
      for(var i=0; i<items.length; ++i) {
        if(items[i] !== target) {
          items[i][close]();
        }
      }  
      originalOpen.call(target);
    }
  }
  
  classes.Accordion = Accordion;
})(jQuery, dit.utils, dit.classes);
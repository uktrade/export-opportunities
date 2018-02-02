/* Class: Select Tracker
 * ---------------------
 * Adds a label element to mirror the matched selected option
 * text of a <select> input, for enhanced display purpose.
 *
 * REQUIRES:
 * jquery
 * dit.js
 * dit.classes.js
 *
 **/

(function($, classes) {
  
  /* Constructor
   * @$select (jQuery node) Target input element
   **/
  classes.SelectTracker = SelectTracker;
  function SelectTracker($select) {
    var SELECT_TRACKER = this;
    var button, code, lang;
    
    if(arguments.length && $select.length) {
      this.$node = $(document.createElement("p"));
      this.$node.attr("aria-hidden", "true");
      this.$node.addClass("SelectTracker");
      this.$select = $select;
      this.$select.addClass("SelectTracker-Select");
      this.$select.after(this.$node);
      this.$select.on("change.SelectTracker", function() {
        SELECT_TRACKER.update();
      });
      
      // Initial value
      this.update();
    }
  }
  SelectTracker.prototype = {};
  SelectTracker.prototype.update = function() {
    this.$node.text(this.$select.find(":selected").text());
  }
  
})(jQuery, dit.classes);

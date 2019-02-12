/* Class: CpvCodeLookup
 * --------------------------------
 * Extends SelectiveLookup to perform specific requirements for
 * Cpv code search by text and, resulting form field population.
 *
 * REQUIRES:
 * jquery
 * dit.js
 * dit.utils.js
 * dit.class.selective-lookup.js
 *
 **/
(function($, utils, classes) {

  var SelectiveLookup = classes.SelectiveLookup;

  /* Main Class
   * @$input (jQuery node) Existing form input element to populate with cpv code
   **/
  classes.CpvCodeLookup = CpvCodeLookup;
  function CpvCodeLookup($input, service, options) {
    var instance = this;
    var opts = $.extend({
      addButtonCssCls: "", // Should you want to add something for CSS.
      datamapping: { text: "english_text", value: "code" }, // See notes in SelectiveLookup
      param: "format=json&description="
    }, options || {});
    

    if($input.length) {
      $input.addClass("CpvCodeLookup");
      $input.attr("placeholder", "Enter a CPV code or search by text to find one");

      // Inherit...
      SelectiveLookup.call(this,
                           $input,
                           service,
                           opts
                          );

      // Some inner variable requirement.
      this._private.param = opts.param;
    }
  }
  
  CpvCodeLookup.prototype = new SelectiveLookup;
  CpvCodeLookup.prototype.bindContentEvents = function() {
    var instance = this;
    instance._private.$list.off("click.SelectiveLookupContent");
    instance._private.$list.on("click.CpvCodeLookup", function(event) {
      var _p = instance._private;
      var $eventTarget = $(event.target);
      var value = $eventTarget.attr("data-value");
      var text = $eventTarget.text();
      _p.$input.val(value + " - " + text);
    });
  }
  
  CpvCodeLookup.prototype.param = function() {
    return this._private.param + this._private.$input.val();
  }

})(jQuery, dit.utils, dit.classes);

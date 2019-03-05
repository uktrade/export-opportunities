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
      name: "", // Pass in a custom field name if you $input.name not wanted.
      placeholder: "Find CPV code" // For altered visible form field.
    }, options || {});

    if($input.length) {
      $input.addClass("CpvCodeLookup");
      $input.attr("name", opts.name || $input.attr("name"));
      $input.attr("placeholder", opts.placeholder);
      if($input.val()) {
        $input.attr("readonly", true);
      }

      $input.on("keydown.CpvCodeLookup", function(event) {
        switch(event.which) {
          case 27: // Esc
          case 8: // Backspace
            $input.val("");
            $input.attr("readonly", false);
            break;
          default: // Nothing
        }
      });

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

  // Overwrite inherited.
  CpvCodeLookup.prototype.bindContentEvents = function() {
    var instance = this;
    instance._private.$list.off("click.SelectiveLookupContent");
    instance._private.$list.on("click.CpvCodeLookup", function(event) {
      var _p = instance._private;
      var $eventTarget = $(event.target);
      var value = $eventTarget.attr("data-value");
      var text = $eventTarget.text();
      _p.$input.val(value);
      _p.$input.attr("readonly", true);
    });
  }

  // Overwrite inherited.  
  CpvCodeLookup.prototype.param = function() {
    return this._private.param + this._private.$input.val();
  }

  // Overwrite inherited.
  // Note 1: Have not bothered with opts.datamapping because we can 
  //       simply change right here in this function.
  // Note 2: Includes some data cleanup which should really happen
  //         before the data response is received
  CpvCodeLookup.prototype.processWithDataMapping = function(data) {
    var text = (data["english_text"] + " " + data["description"]).replace(/\"/g, "");
    text = text.replace(/[-]+/, "-");
    return { value: data["code"] + ": " + text, text: text }
  }

})(jQuery, dit.utils, dit.classes);

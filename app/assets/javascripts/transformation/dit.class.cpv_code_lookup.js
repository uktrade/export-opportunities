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
    var id = $input.attr('id') || utils.generateUniqueStr("_");
    var $clear = $("<button class=\"CpvCodeLookupClear\">Clear value</button>");
    var opts = $.extend({
      addButtonCssCls: "", // Should you want to add something for CSS.
      name: "", // Pass in a custom field name if you $input.name not wanted.
      placeholder: "Find CPV code", // For altered visible form field.
      supportMultilineInputs: true
    }, options || {});

    if($input.length) {
      if(opts.supportMultilineInputs) {
        $input = CpvCodeLookup.convertToTextarea($input);
        CpvCodeLookup.setTextareaHeight($input)
      }

      $input.addClass("CpvCodeLookup");
      $input.attr("id", id);
      $input.attr("name", opts.name || $input.attr("name"));
      $input.attr("placeholder", opts.placeholder);

      $input.on("keydown.CpvCodeLookup", function(event, clearInput) {
        // Handle specific keys.
        switch(event.which) {
          case 27: // Esc
          case 8: // Backspace
            clearInput = true;
            break;
          default: // Nothing to do.
        }

        if(clearInput) {
          $input.val("");
          $input.focus();
          CpvCodeLookup.setTextareaHeight($input)
        }
      });

      // Add a clearing button to make the UI more obvious.
      $clear.attr("aria-controls", id);
      $input.after($clear);
      $clear.on("click.CpvCodeLookup", function(event) {
        event.preventDefault();
        $input.trigger("keydown.CpvCodeLookup", true);
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
  
  // Sometimes the populating value might be more than
  // one line in length so it might be preferable to
  // use a <textarea> element instead. Code will handle
  // whether it should try to display as a single line
  // input[type=text] element, or expaned to meet the
  // populating content length.
  CpvCodeLookup.convertToTextarea = function($field) {
    var $textarea = $field;
    if($field.get(0).nodeName.toLowerCase() != "textarea") {
      $textarea = $("<textarea></textarea>");
      $textarea.attr("name", $field.attr("name"));
      $textarea.val($field.val());
      $field.before($textarea);
      $field.remove();
      CpvCodeLookup.setTextareaHeight($textarea); // Has to go after $textarea has been added to get right CSS.
    }
    return $textarea;
  }

  // 1. Set a hidden <p> element.
  // 2. Populate with textarea value.
  // 3. Set the height of textarea to match <p>.
  // 4. Remove <p> to cleanup.
  CpvCodeLookup.setTextareaHeight = function($field) {
    var $p;
    if($field.get(0).nodeName.toLowerCase() == "textarea") {
      $p = $("<p></p>");
      $p.text($field.val() || "&nbps;"); // Require something to at least get a single line
      $p.css({
        position: "absolute",
        visibility: "hidden",
        width: $field.width()
      });

      $field.before($p);
      $field.height($p.height());
      $p.remove();
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
      CpvCodeLookup.setTextareaHeight(_p.$input);
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

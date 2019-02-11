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
  var errors = {
    // TODO: Create mechanism to get these from content.
    noInputOrSelection: "No input or selection."
  }

  /* Main Class
   * @$field (jQuery node) Existing form input element to populate with cpv code
   **/
  classes.CpvCodeLookup = CpvCodeLookup;
  function CpvCodeLookup($field, service, options) {
    var $input, $add, $multipleDisplay, $ul, $currentOutput;
    var instance = this;
    var $form = $field.parents("form");
    var opts = $.extend({
      title: "Selected codes", // Title for choices display area.
      $errors: $(), // Where do we display errors.
      addButtonCssCls: "", // Should you want to add something for CSS.
      multiple: false, // Adds activator to allow chosing/setting multiple codes.
      datamapping: { text: "english_text", value: "code" }, // See notes in SelectiveLookup
      param: "format=json&description="
    }, options || {});
    
    if($field.length) {
      // To minimise effort on changing form processing, we
      // keep the original form input element ($field) but
      // make it a type:hidden element. We then create a new
      // input:text element for user lookup entries.
      // If multiple codes are to be added, there is a
      // mechanism to allow for multiple additions to the
      // original form input element.
      $input = $('<input type="text" class="CpvCodeLookupInput" name="cpv_input_text">');
      $field.attr("id", ""); // Clear this because there might be multiple.
      $field.attr("type", "hidden");
      $field.after($input);

      // If it's going to be multiple entry.
      if(opts.multiple) {
        $add = $('<button class="CpvCodeLookupAdd" type="button">Add another code</button>');
        $add.addClass(opts.addButtonCssCls);
        CpvCodeLookup.addMultipleButtonEvent.call(this, $add);
        $input.after($add);

        // Create a visible output for multiple selected codes.
        $multipleDisplay = $('<div class="CpvCodeLookupFieldAndDisplay"></div>');
        $multipleDisplay.append($('<p class="CpvCodeLookupEmptyOutput">' + opts.title  + '</p>'));
        $ul = $('<ul></ul>');
        $currentOutput = $("<li></li>");
        $currentOutput.addClass("CpvCodeLookupEmptyOutput");
        $ul.append($currentOutput);
        $multipleDisplay.append($ul);
        $input.before($multipleDisplay);
        $multipleDisplay.append($input);
        $multipleDisplay.append($add);
      }

      // Inherit...
      SelectiveLookup.call(this,
                           $input,
                           service,
                           opts
                          );

      // If we are not told where, insert element for showing errors.
      if (opts.$errors.length < 1) {
        opts.$errors = $('<p class="error"></p>');
        $form.prepend(opts.$errors);
      }

      // Some inner variable requirement.
      this._private.$field = $field;
      this._private.$currentOutput = $currentOutput;
      this._private.$multipleDisplay = $multipleDisplay;
      this._private.$form = $form;
      this._private.$errors = opts.$errors;
      this._private.param = opts.param;
      this._private.fieldCount = 0;
      
      // Clear previously shown errors.
      this._private.$input.on("focus.CpvCodeLookup", function(e) {
        instance._private.$errors.empty();
      });
    }
  }

  CpvCodeLookup.addMultipleButtonEvent = function($button) {
    var instance = this;
    $button.on("click.CpvCodeLookup", function() {
      var _p = instance._private;
      var $anotherField, $anotherCurrentOutput;

      // TODO: Need to improve the empty value check.
      if(_p.$input.val() != "") {
        // Arrange a new input field.
        $anotherField = _p.$field.clone();
        $anotherField.val("");
        $anotherField.addClass("CpvCodeLookupEmptyOutput");
        _p.$field.before($anotherField);
        _p.$input.val("");
        _p.$field = $anotherField;

        // If we're in multiple display mode, we need
        // to arrange a new output element.
        if(_p.$currentOutput) {
          $anotherCurrentOutput = _p.$currentOutput.clone();
          $anotherCurrentOutput.addClass("CpvCodeLookupEmptyOutput");
          _p.$currentOutput.after($anotherCurrentOutput);
          _p.$currentOutput = $anotherCurrentOutput;
        }
      }
    });
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

      // Add choice values to form fields.
      // TODO: Adapt this to get a CPV code when data format is known.
      _p.$input.val(text);
      _p.$field.val(value);

      // Adjust the output if using multiple display
      if(_p.$currentOutput) {
        _p.$multipleDisplay.find(".CpvCodeLookupEmptyOutput").removeClass("CpvCodeLookupEmptyOutput");
        _p.$currentOutput.text(value + " - " + text);
      }
    });
  }
  
  CpvCodeLookup.prototype.param = function() {
    return this._private.param + this._private.$input.val();
  }

})(jQuery, dit.utils, dit.classes);

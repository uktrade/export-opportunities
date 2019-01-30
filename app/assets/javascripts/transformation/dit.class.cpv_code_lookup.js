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
    // TODO: Create mechanism to get these from BE/content. 
    noInputOrSelection: "No input or selection."
  }

  /* Main Class
   * @$field (jQuery node) Existing form input element to populate with cpv code
   **/
  classes.CpvCodeLookup = CpvCodeLookup;
  function CpvCodeLookup($field, service, options) {
    var instance = this;
    var $form = $field.parents("form");
    var $input;
    var opts = $.extend({
      //$after: $(), // (jQuery element) Specify an element to insert list after (gets appended to body if nothing passed).
      $errors: $(), // Where do we display errors.
      addButtonCssCls: "", // Should you want to add something for CSS.
      multiple: false, // Adds activator to allow chosing/setting multiple codes.
      param: "term"
    }, options || {}); 
    
    if($field.length) {
      // To minimise effort on changing form processing, we
      // keep the original form input element ($field) but
      // make it a type:hidden element. We then create a new
      // input:text element for user lookup entries.
      // If multiple codes are to be added, there is a
      // mechanism to allow for multiple additions to the
      // original form input element.
      // $field.attr("type", "hidden");
      $input = $('<input type="text" class="CpvCodeLookupInput" name="cpv_input_text">');
      $field.attr("readonly", "true");
      $field.addClass("CpvCodeLookupEmptyOutput"); // Allows for initial hidden state, if required.
      $field.after($input);

      // If it's going to be multiple entry.
      if(opts.multiple) {
        $add = $('<button class="CpvCodeLookupAdd" type="button">Add another code</button>');
        $add.addClass(opts.addButtonCssCls);
        CpvCodeLookup.addMultipleButtonEvent.call(this, $add);
        $input.after($add);
      }

      // Inherit...
      SelectiveLookup.call(this,
                           $input,
                           service
                          );

      // If we are not told where, insert element for showing errors.
      if (opts.$errors.length < 1) {
        opts.$errors = $('<p class="error"></p>');
        $form.prepend(opts.$errors);
      }

      // Some inner variable requirement.
      this._private.$field = $field;
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
      var $field = instance._private.$field;
      var $input = instance._private.$input;
      var $anotherField, id;
      // TODO: Need to improve the empty value check.
      if($input.val() != "") {
        id = $field.attr("id") + "_" + (++instance._private.fieldCount);
        $anotherField = $field.clone();
        $anotherField.val("");
        $anotherField.attr("id", id);
        $anotherField.addClass("CpvCodeLookupEmptyOutput");
        $field.before($anotherField);
        $input.val("");
        instance._private.$field = $anotherField;
      }
    });
  }
  
  CpvCodeLookup.prototype = new SelectiveLookup;
  CpvCodeLookup.prototype.bindContentEvents = function() {
    var instance = this;
    instance._private.$list.off("click.SelectiveLookupContent");
    instance._private.$list.on("click.CpvCodeLookup", function(event) {
      var $eventTarget = $(event.target);

      // TODO: Adapt this to get a CPV code when data format is known.
      if($eventTarget.attr("data-value")) {
        instance._private.$input.val($eventTarget.text());
        instance._private.$field.val($eventTarget.attr("data-value"));
        instance._private.$field.removeClass("CpvCodeLookupEmptyOutput");
      }
    });
  }
  
  CpvCodeLookup.prototype.param = function() {
    return this._private.param + "=" + this._private.$input.val();
  }
  
  CpvCodeLookup.prototype.setContent = function() {
    SelectiveLookup.prototype.setContent.call(this, {
      // TODO: Adapt when data format is known.
      text: "title",
      value: "company_number"
    });
  }

})(jQuery, dit.utils, dit.classes);

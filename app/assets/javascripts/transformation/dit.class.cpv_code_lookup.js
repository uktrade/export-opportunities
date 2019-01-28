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
   * @$input (jQuery node) Existing form element to populate with cpv code
   **/
  classes.CpvCodeLookup = CpvCodeLookup;
  function CpvCodeLookup($input, service, options) {
    var instance = this;
    var $form = $input.parents("form");
    var opts = $.extend({
      //$after: $(), // (jQuery element) Specify an element to insert list after (gets appended to body if nothing passed).
      $errors: $(), // Where do we display errors.
      $output: $input, // Use something else if preferred but shouldn't be necessary to change..
      param: "term"
    }, options || {}); 
    

    // To minimise effort on changing form processing, we
    // try to set the original form input element as the
    // opts.$output element (this can be changed but should
    // not matter). The original input is changed to a 
    // hidden form element. A new input element for the 
    // lookup text is created and added as a sibling to the
    // original one.
    $input.attr("type", "hidden");
    $input = $('<input type="text" name="cpv_input_text" placeholder="' + $input.attr("placeholder") + '">');
    opts.$output.attr("type", "hidden");
    opts.$output.before($input);
    

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
    this._private.$field = opts.$output;
    this._private.$form = $form;
    this._private.$errors = opts.$errors;
    this._private.param = opts.param;
  
    // Clear previously shown errors.
    this._private.$input.on("focus.CpvCodeLookup", function(e) {
      instance._private.$errors.empty();
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

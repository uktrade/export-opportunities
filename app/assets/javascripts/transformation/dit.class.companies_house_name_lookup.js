/* Class: CompaniesHouseNameLookup
 * --------------------------------
 * Extends SelectiveLookup to perform specific requirements for 
 * Companies House company search by name, and resulting form 
 * field population.
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
    noInputOrSelection: "Check that you entered the company name correctly and select the matching company name from the list."
  }

  /* Main Class
   * @$input (jQuery node) Target input element
   * @$output (jQuery node) Optional output element to populate with company number
   **/
  classes.CompaniesHouseNameLookup = CompaniesHouseNameLookup;
  function CompaniesHouseNameLookup($input, options) {
    var instance = this;
    var $form = $input.parents("form");
    var opts = $.extend({
      $after: $(), // (jQuery element) Specify an element to insert list after (gets appended to body if nothing passed).
      $errors: $(), // Where do we display errors.
      $output: $(), // Form field to receive the company number.
      datamapping: { text: "title", value: "company_number" }, // See notes in SelectiveLookup
      param: "term",
    }, options || {});
    
    // Inherit...
    SelectiveLookup.call(this,
      $input,
      dit.data.getCompanyByName,
      opts
    );

    // What captures the company number or use default.
    if (opts.$output.length < 1) {
      opts.$output= $('<input type="hidden" name="company_number">');
      $input.before(opts.$output);
    }
    
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
    this._private.$input.on("focus.CompaniesHouseNameLookup", function(e) {
      instance._private.$errors.empty();
    });
  }
  
  CompaniesHouseNameLookup.prototype = new SelectiveLookup;
  CompaniesHouseNameLookup.prototype.bindContentEvents = function() {
    var instance = this;
    instance._private.$list.off("click.SelectiveLookupContent");
    instance._private.$list.on("click.CompaniesHouseNameLookup", function(event) {
      var $eventTarget = $(event.target);
    
      // Try to set company number value.
      if($eventTarget.attr("data-value")) {
        instance._private.$input.val($eventTarget.text());
        instance._private.$field.val($eventTarget.attr("data-value"));
      }
    });
  }
  
  CompaniesHouseNameLookup.prototype.param = function() {
    return this._private.param + "=" + this._private.$input.val();
  }

})(jQuery, dit.utils, dit.classes);

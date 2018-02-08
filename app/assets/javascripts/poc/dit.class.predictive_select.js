/* Class: PredictiveSelect
 * --------------------------------
 * Extends SelectiveLookup to perform a predictive value lookup
 * using the combination of a <select> and <input[type=text]> elements.
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
    noInputOrSelection: "Check that you entered a Sector value from the selections provided"
  }

  /* Main Class
   * @$select (jQuery node) Input <select> element and source of data
   * @service (String) JSON ServiceData provider
   **/
  classes.PredictiveSelect = PredictiveSelect;
  function PredictiveSelect($select, service, options) {
    var instance = this;
    var $form = $select.parents("form");
    var $input = PredictiveSelect.createInput.call(this);
    var opts = $.extend({
      $errors: $(), // Where do we display errors.
    }, options || {}); 
    
    // Inherit...
    SelectiveLookup.call(this,
      $input,
      service, 
      { $after: $select }
    );

    // Add element that captures the user typed input to DOM.
    if ($select.length) {
      $select.before($input);
    }

    // If we are not told where, insert element for showing errors.
    if (opts.$errors.length < 1) {
      opts.$errors = $('<p class="error"></p>');
      $form.prepend(opts.$errors);
    }

    // Some inner variable requirement.
    this._private.$field = $select;
    this._private.$form = $form;
    this._private.$errors = opts.$errors;
  
    // Clear previously shown errors.
    this._private.$input.on("focus.PredictiveSelect", function(e) {
      instance._private.$errors.empty();
    });
  }
  
  PredictiveSelect.createInput = function() {
    var id = dit.utils.generateUniqueStr("PredictiveSelect_");
    var input = document.createElement("input");
    input.setAttribute("id", id);
    input.setAttribute("type", "text");
    return $(input);
  }
  
  PredictiveSelect.prototype = new SelectiveLookup;
  PredictiveSelect.prototype.bindContentEvents = function() {
    var instance = this;
    instance._private.$list.off("click.SelectiveLookupContent");
    instance._private.$list.on("click.PredictiveSelect", function(event) {
      var $eventTarget = $(event.target);
      console.log("something, something, something");
      /* Try to set company number value.
      if($eventTarget.attr("data-value")) {
        instance._private.$input.val($eventTarget.text());
        instance._private.$field.val($eventTarget.attr("data-value"));
      }
      */
    });
  }
  
  PredictiveSelect.prototype.search = function() {
    this._private.service.update(dit.data.getSector.response);
  }
  
  /*
  CompaniesHouseNameLookup.prototype.param = function() {
    return "term=" + this._private.$input.val();
  }
  
  PredictiveSelect.prototype.setContent = function() {
    SelectiveLookup.prototype.setContent.call(this, {
      text: "label",
      value: "company_number"
    });
  }
  */

})(jQuery, dit.utils, dit.classes);
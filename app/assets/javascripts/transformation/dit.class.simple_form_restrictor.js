/* Class: SimpleFormRestrictor
 * ----------------------------
 * Attempts to prevent user submitting a form without at least one field having a value.
 * Can show an error message on empty submit attempt, if configured. 
 *
 * Example usage: On a search form where no keywords have been entered.
 *
 * REQUIRES:
 * jquery
 * dit.js
 *
 **/
(function ($, classes) {

 /* Constructor.
  * $form (jQuery element) Form in question.
  * options (Object) Optional configurations. 
  **/ 
  classes.SimpleFormRestrictor = SimpleFormRestrictor;
  function SimpleFormRestrictor($form, options) {
    var restrictor = this;
    var config = $.extend({
      $fields: SimpleFormRestrictor.allFieldsFrom($form), // You can pass your own collection or use default
      errorCssClass: "error", // Added to form if detected to be empty.
      errorMessage: "" // Set an error message to show
    }, options || {});

    var $error;

    if($form.length && config.$fields.length) {
      $error = SimpleFormRestrictor.createErrorMessage(config.errorMessage);
      $form.on("submit", function() {
        var oneFieldHasValue = SimpleFormRestrictor.oneFieldHasValue(config.$fields);
        if(!oneFieldHasValue) {
          $form.addClass(config.errorCssClass);
          if($error.length) {
            $form.prepend($error);
          }
        }
        return oneFieldHasValue;
      });

      // Attempt to clear error on possible form alteration.
      config.$fields.on("focus", function() {
        $form.removeClass(config.errorCssClass);
        $error.remove();
      });
    }
  }

  /* Returns an element to display as error message.
   * message (String) Message to display when empty form submit prevented.
   * TODO: Add some Aria to make this message more accessible friendly.
   **/
  SimpleFormRestrictor.createErrorMessage = function(message) { 
    var el, text;
    if(message != "") {
      el = document.createElement("p");
      text = document.createTextNode(message);
      el.appendChild(text);
      el.className = "SimpleFormRestrictorError";
    }
    return $(el);
  }

  /* Returns all found fields from the passed form.
   * This can be overriden in configuration.
   * Put in a function to avoid polluting the constructor and to
   * allow more complex lookup functionality or easily change
   * if later found to be needing more.
   **/
  SimpleFormRestrictor.allFieldsFrom = function($form) { 
    return $("input, select, textarea", $form).not("[type='button']").not("[type='submit']");
  }

  /* Returns true if at least one field is detected to have a value.
   * $fields (jQuery collection) Fields to check.
   **/
  SimpleFormRestrictor.oneFieldHasValue = function($fields) {
    var hasValue = false;
    for(var i=0; i<$fields.length; ++i) {
      // Browser is returning val() of 'true' for unselected input[value='true'] so 
      // splitting out radios and checkboxes for validation of checked state.
      if($fields.eq(i).is("[type='radio']") || $fields.eq(i).is("[type='checkbox']")) {
        if($fields.eq(i).is(":checked")) {
          hasValue = true;
          break;
        }
      }
      else {
        if($fields.eq(i).val() != "") {
          hasValue = true;
          break;
        }
      }
    }
    return hasValue;
  }

  SimpleFormRestrictor.prototype = {}
  SimpleFormRestrictor.prototype.showError = function() {
  }

})(jQuery, dit.classes);

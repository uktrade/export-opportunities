/* Class: FilterSelect
 * --------------------------------
 * Extends SelectiveLookup to perform a predictive value lookup
 * using the combination of a <select> and <input[type=text]> elements.
 *
 * REQUIRES:
 * jquery
 * dit.js
 * dit.utils.js
 * dit.class.selective_lookup.js
 *
 **/
(function($, utils, classes) {

  var DataProvider = classes.DataProvider;
  var SelectiveLookup = classes.SelectiveLookup;
  var DATA_ATTRIBUTE_INITIAL_VALUE = "data-initial-value";

  /* Main Class
   * @$select (jQuery node) Input <select> element and source of data
   * @config (Object) Optional configurations
   **/
  classes.FilterSelect = FilterSelect;
  function FilterSelect($select, config) {
    var instance = this;
    var $input = FilterSelect.createUserInputField.call(instance, $select);
    var $field = FilterSelect.createHiddenInputField.call(instance, $select);
    var $parent = $select.parent();
    var opts = $.extend({
      $errors: $(), // TODO: Where/how do we display errors.
      allowCustomEntry: false // Allow user custom entry/value
    }, config || {}); 

    // Need to make sure we don't put things inside a label because
    // the default click handling will mess with our events
    if($parent.get(0).nodeName.toLowerCase() === "label") {
      $parent.attr("for", $input.attr("id"));
      $parent.after($select);
      $parent.addClass("enhanced"); // Allow for Post-JS adjustment
    }

    // Inherit...
    SelectiveLookup.call(instance,
      $input,
      new DataProvider(FilterSelect.optionsToDataArray($select.find("option")), "text"),
      { $after: $select, lookupOnCharacter: 0 }
    );

    // Add some more private stuff.
    instance._private.value = "";
    instance._private.$field = $field;
    instance._private.opts = opts;

    // Bind additional events and add element that 
    // captures the user typed input to DOM.
    FilterSelect.bindExtraInputEvents.call(instance, $input);
    $select.replaceWith($field);
    $field.before($input);
  }
  
  /* Create the input element (type=text) that replaces the <select>
   * $select (jQuery node) The target <select> element.
   **/
  FilterSelect.createUserInputField = function($select) {
    var id = dit.utils.generateUniqueStr("FilterSelect_");
    var input = document.createElement("input");
    var placeholder = $select.attr("placeholder");
    var firstOptionValue = $select.find("option").eq(0).text();
    input.setAttribute("id", id);
    input.setAttribute("type", "text");
    input.setAttribute("class", "FilterSelectInput");
    if(placeholder && placeholder.length) {
      input.setAttribute("placeholder", placeholder);
      input.setAttribute(DATA_ATTRIBUTE_INITIAL_VALUE, placeholder);
    }
    else {
      input.value = firstOptionValue;
      input.setAttribute(DATA_ATTRIBUTE_INITIAL_VALUE, firstOptionValue);
    }

    return $(input);
  }

  /* Create a hidden input element to store eventual user input for submit.
   * $select (jQuery node) The target <select> element.
   **/
  FilterSelect.createHiddenInputField = function($select) {
    var id = dit.utils.generateUniqueStr("FilterSelect_");
    var input = document.createElement("input");
    input.setAttribute("name", $select.attr("name"));
    input.setAttribute("id", id);
    input.setAttribute("type", "hidden");
    input.setAttribute("value", $select.val());
    input.setAttribute(DATA_ATTRIBUTE_INITIAL_VALUE, $select.val());
    return $(input);
  }

  /* Add some additional required events to work
   * a little more like a <select> element.
   **/
  FilterSelect.bindExtraInputEvents = function($input) {
    var filterSelect = this;
	
    // Set and open list.
    $input.on("click.FilterSelect keydown.FilterSelect", function(e) {
      e.stopPropagation(); // Prevents "click.SelectiveLookupCloseAll" listener activation.
      var $input = $(this);
      switch(e.which) {
        case 13: // Enter key (but we don't want to submit the form)
          e.preventDefault();
        case 1: // mouse click
        case 40: 
          if($input.attr("aria-expanded") !== "true") {
            filterSelect.setContent();
            filterSelect.bindContentEvents();
            filterSelect.open();
          }
          break;
        default: // Anything??
      }
    });

    // Update the hidden form field that replaced the original <select>
    // Make sure that entry on leaving user input field matches something
    // in the list or, use the original default value.
    $input.on("blur.FilterSelect", function() {
      var $this = $(this);
      var data = filterSelect._private.service.data;
      var filtered = filterSelect._private.service.filtered($this.val());
      var $field = filterSelect._private.$field;

      // If user entry field is empty, make sure hidden field is blank.
      if($input.val().replace(/\s/g, "").length <= 0) {
        $field.val($field.attr(DATA_ATTRIBUTE_INITIAL_VALUE));  
      }

      // If user can set any value, set field to equal input.
      if(filterSelect._private.opts.allowCustomEntry) {
        if($field.val() !== $input.attr("data-selected")) {
          $field.val($this.val());
        }
      }
      else {
        // If user entry doesn't match anything, blank input and field.
        if(filtered.length < 1) {
          $this.val("");
          $field.val($field.attr(DATA_ATTRIBUTE_INITIAL_VALUE));  
        }
      }
    });
  }

  /* Class utility function to build data array from the found options.
   * @$options (jQuery node) <options> found in <select>
   **/
  FilterSelect.optionsToDataArray = function($options) {
    var data = [];
    $options.each(function() {
      data.push({
        text: this.firstChild.nodeValue,
        value: this.value
      });
    });
    return data;
  }
  
  FilterSelect.prototype = new SelectiveLookup;

  /* What happens when something is selected from the list.
   **/
  FilterSelect.prototype.bindContentEvents = function() {
    var instance = this;
    instance._private.$list.off("click.SelectiveLookupContent");
    instance._private.$list.on("click.SelectiveLookupContent", function(event) {
      var $eventTarget = $(event.target);
      if($eventTarget.attr("data-value") !== undefined) {
        instance._private.$field.val($eventTarget.attr("data-value"));
        instance._private.$input.attr("data-selected", $eventTarget.attr("data-value"));
        if($eventTarget.attr("data-value") !== "") { // No results option
          instance._private.$input.val($eventTarget.text());
        }
      }
    });
  }

  /* Need to overwrite inherited to check whether we need
   * to reset the data first.
   **/
  FilterSelect.prototype.search = function() {
    var inputValue = this.param();

    // If the user deleted some input we need to reset first.
    if(inputValue.length < this._private.value.length) {
      this._private.service.reset();
    }

    this._private.value = inputValue;
    SelectiveLookup.prototype.search.call(this);
  }

  /* Overwrite inherited because we need to return
   * a different value format. 
   **/
  FilterSelect.prototype.param = function() {
    return this._private.$input.val();
  }


  /* Overwrite open so we always blank any previous entry first. 
   **/
  FilterSelect.prototype.open = function() {
    SelectiveLookup.prototype.open.call(this);
    this._private.$field.val("");
  }

})(jQuery, dit.utils, dit.classes);

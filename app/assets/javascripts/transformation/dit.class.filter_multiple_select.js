/* Class: FilterMultipleSelect
 * --------------------------------
 * Extends SelectiveLookup to perform a predictive value lookup
 * using the combination of a <select> and <input[type=text]> elements.
 * 
 * Like FilterSelect but also with enhanced display for multiple choice 
 * selection and ability to select/deselect all choices.
 *
 * REQUIRES:
 * jquery
 * dit.js
 * dit.utils.js
 * dit.class.data_provider.js
 *
 **/

(function($, utils, classes) {

  var DataProvider = classes.DataProvider;

  /* Main Class
   * @$select (jQuery node) Input <select> element and source of data
   * @config (Object) Optional configurations
   **/
  classes.FilterMultipleSelect = FilterMultipleSelect;
  function FilterMultipleSelect($select, config) {
    var instance = this;
    var optionsId = utils.generateUniqueStr("_");
    var options = FilterMultipleSelect.optionsToDataArray($select.find("option"));
    var $input = FilterMultipleSelect.createUserInputField($select, optionsId);
    var $list = FilterMultipleSelect.createListHolder(optionsId);
    var $toggle = FilterMultipleSelect.createToggleButton();
    var $optionsFrame = FilterMultipleSelect.createFrameFor("FilterMultipleSelectOptionsArea");
    var $displayFrame = FilterMultipleSelect.createFrameFor("FilterMultipleSelectDisplayArea");
    var $componentFrame = FilterMultipleSelect.createFrameFor("FilterMultipleSelectComponent");
    var $display = $(document.createElement("ul"));
    var $parent = $select.parent();
    var opts = $.extend({
      title: "", // Title for choices display area
      unselected: "" // Text for 'no selection' message in choices display area 
    }, config || {}); 

    // Need to make sure we don't put things inside a label because
    // the default click handling will mess with our events
    if($parent.get(0).nodeName.toLowerCase() === "label") {
      $parent.attr("for", $input.attr("id"));
      $parent.after($select);
      $parent.addClass("enhanced"); // Allow for Post-JS adjustment
    }

    // Some inner variable requirement.
    instance._private = {
      service: new DataProvider(options, "text"), // Provides data filtering.
      opts: opts,
      value: "",
      allOptionsSelected: false,
      optionsId: optionsId,
      $display: $display,
      $list: $list,
      $input: $input,
      $select: $select,
      $toggle: $toggle,
      timer: null
    }

    // Add events
    FilterMultipleSelect.addOptionIds.call(this, optionsId);
    FilterMultipleSelect.bindInputEvents.call(this, $input);
    FilterMultipleSelect.bindListEvents.call(this, $list);
    FilterMultipleSelect.bindButtonEvents.call(this, $toggle);


    // Position element as required in DOM
    if(opts.title) {
      $displayFrame.append($(document.createElement("p")).text(opts.title));
    }

    if(opts.unselected) {
      $display.attr("data-unselected", opts.unselected);
    }

    $select.before($input);
    $componentFrame.append($optionsFrame);
    $componentFrame.append($displayFrame);
    $componentFrame.insertBefore($select);
    $optionsFrame.append($input);
    $optionsFrame.append($list);
    $optionsFrame.append($toggle);
    $optionsFrame.append($select);
    $displayFrame.append($display);

    // Set up the initial display
    instance.resetOptions();
  }


  /* Class utility function to build data array from the found options.
   * @$options (jQuery node) <options> found in <select>
   **/
  FilterMultipleSelect.optionsToDataArray = function($options) {
    var data = [];
    $options.each(function() {
      data.push({
        text: this.firstChild.nodeValue,
        value: this.value
      });
    });
    return data;
  }

  /* Create the input element (type=text) that replaces the <select>
   * $select (jQuery node) The target <select> element.
   * owns (String) ID attribute value of list it searches on.
   **/
  FilterMultipleSelect.createUserInputField = function($select, owns) {
    var id = dit.utils.generateUniqueStr("FilterMultipleSelect_");
    var input = document.createElement("input");
    var placeholder = $select.attr("placeholder");
    var $label = $("label[for='" + $select.attr("id") + "']");
    input.setAttribute("id", id);
    input.setAttribute("type", "text");
    input.setAttribute("class", "FilterMultipleSelectInput");
    input.setAttribute("aria-autocomplete", "list");
    input.setAttribute("role", "combobox");
    input.setAttribute("aria-expanded", "true");
    input.setAttribute("aria-owns", owns);
    if(placeholder && placeholder.length) {
      input.setAttribute("placeholder", placeholder);
    }
    $select.attr("tabindex", -1);
    $label.attr("for", id);
    return $(input);
  }

  /* Create a UL element for the options.
   * @id (String) Used to connect element for Aria purposes.
   **/
  FilterMultipleSelect.createListHolder = function(id) {
    var ul = document.createElement("ul");
    ul.setAttribute("id", id);
    ul.setAttribute("class", "FilterMultipleSelectOptions");
    ul.setAttribute("role", "listbox");
    ul.setAttribute("tabindex", "-1");
    return $(ul);
  }

  /* Create a button to toggle between select/deselect all options..
   **/
  FilterMultipleSelect.createToggleButton = function() {
    var $button = $(document.createElement("button"));
    $button.className = "toggle";
    $button.text("Select all");
    return $button;
  }

  /* Create a frame with specified classname
   **/
  FilterMultipleSelect.createFrameFor = function(classname) {
    var div = document.createElement("div");
    div.className = classname;
    return $(div);
  }

  /* Run with context (this) of instance.
   * Add a unique id to each option.
   * Format is generated Parent UL id + option value, separated by underscore.
   * @optionsId (String) Pass the generated optionsId
   **/
  FilterMultipleSelect.addOptionIds = function(optionsId) {
    var $select = this._private.$select;
    var options = $select.get(0).options;
    for(var i=0; i < options.length; i++) {
      options[i].setAttribute("id", optionsId + "_" + options[i].getAttribute("value"));
    }
  }

  /* Run with context (this) of instance.
   * Sets the event handling for main $input (search) field.
   **/
  FilterMultipleSelect.bindInputEvents = function() {
    var instance = this;
    var $input = this._private.$input;

    // Turn of autocomplete because it interferes with results display.
    $input.attr("autocomplete", "off");

    // Add main lookup event with slight delay for breathing space.
    $input.on("input.FilterMultipleSelect", function() {
      this.value = this.value.trim();

      if(instance._private.timer) {
        clearTimeout(instance._private.timer);
      }
      
      instance._private.timer = setTimeout(function() {
        instance.search();
        instance.setContent();
      }, 300);
    });

    // Add some keyboard navigation on field.
    // Using keydown event because works better with Tab capture.
    $input.on("keydown.FilterMultipleSelect", function(e) {
      e.stopPropagation();
      switch(e.which) {
        case 9:  // Tab
        case 27: // Esc
        instance.resetOptions();
        break;

        case 40: // Arrow down
        if(!e.shiftKey) {
          e.preventDefault();
          instance._private.$list.find("li:first-child").focus();
        }
      }
    });

    // If user moves away from the input, we should reset options.
    $input.on("blur.FilterMultipleSelect", function(e) {
      var reset = true;
      if(e.relatedTarget && $(e.relatedTarget.nodeValue).parent() != instance._private.$list) {
        reset = false; // Do not reset if user activated and option
      }
      if(reset) {
        instance.resetOptions();
      }
    });

    // Always make sure the options are reset when focus 
    // is given to the input.
    $input.on("focus.FilterMultipleSelect", function(e) {
      instance.resetOptions();
    });

  }


  /* Run with context (this) of instance.
   * Add the event handling for $list elements (clickable options).
   **/
  FilterMultipleSelect.bindListEvents = function() {
    var instance = this;
    var $list = this._private.$list;

    // What events do when focus is on an option in the list
    $list.on("click.FilterMultipleSelect keydown.FilterMultipleSelect", "li", function(e) {
      var $current = $(e.target);
      switch(e.which) {

      // User moving to previous listed option.
      case 38: // Arrow up
        e.preventDefault();
        $current.prev("li").focus();
        break;

      // User moving to next listed option.
      case 40: // Arrow down
        e.preventDefault();
        $current.next("li").focus();
        break;

      // User moving away from listed options.
      case  9: // Tab
        instance.resetOptions();
        break;
      case 27: // Esc
        e.preventDefault();
        instance._private.$input.focus();
        break;

      // User selecting option with focus.
      case  1: // Mouse click
      case 13: // Enter
      case 32: // Space
        e.preventDefault();
        instance.selectOption(e.target);
      default: // Nothing
      }
    });

    // Arrow movement from list to input
    $list.on("keydown.FilterMultipleSelect", "li:first-child", function(e) {
      if(e.which === 38) {
        e.preventDefault();
        instance._private.$input.focus();
      }
    });
  }

  /* Run with context (this) of instance.
   * Add the events for select/deselect button.
   **/
  FilterMultipleSelect.bindButtonEvents = function($button) {
    var instance = this;
    $button.on("click", function(e) {
      e.preventDefault();
      if(instance._private.allOptionsSelected) {
        instance.deselectAll();
      }
      else {
        instance.selectAll();
      }
    });
  }
  

  FilterMultipleSelect.prototype = {};
  
  /* Uses the data set on associated service to build HTML
   * list elements. Since data keys are quite likely to vary
   * across services, you can configure a mapping object
   * to avoid the default/expected key names.
   **/
  FilterMultipleSelect.prototype.setContent = function() {
    var $selected = this._private.$select.find(":selected");
    var $list = this._private.$list;
    var data = this._private.service.data;
    $list.empty();
    if(data && data.length) {
      for(var i=0; i<data.length; ++i) {
        // Note: Only need to set a tabindex attribute to allow focus.
        // The value is not important here.
        $list.append($('<li role="option" data-value="' + data[i]['value'] + '" tabindex="-1"></li>').text(data[i]['text']));
      }
    }
    else {
      $list.append('<li class="none" role="option" data-value="" tabindex="-1">No results found</li>');
    }

    // Update state of list choices
    $list.find("li").removeClass("selected");
    $selected.each(function(i) {
      $list.find("[data-value='" + $(this).val() + "']").addClass("selected");
    });
  }

  /* Sets options and input view back to initial state.
   **/
  FilterMultipleSelect.prototype.resetOptions = function() {
    this._private.$input.val("");
    this.search();
    this.setContent();
    this.updateDisplay();
  }

  /* What happens when something is selected from the list.
   **/
  FilterMultipleSelect.prototype.selectOption = function(option) {
    var $option = $(option);
    var $field = $("#" + this._private.optionsId + "_" + $option.data("value"));
    if($field.prop("selected")) {
      $option.removeClass("selected");
      $field.prop("selected", false);
    }
    else {
      $option.addClass("selected");
      $field.prop("selected", true);
    }
    this.updateDisplay();
  }

  /* Selects all options not already checked.
   **/
  FilterMultipleSelect.prototype.selectAll = function() {
    var $list = this._private.$list;
    var $unselectedOptions = $list.find("li").not(".selected");
    $unselectedOptions.each(function() {
      var userAction = jQuery.Event("click");
      userAction.which = 1; // Mimic click
      $(this).trigger(userAction);
    });
    this.updateDisplay();
    this._private.$toggle.text("Deselect all");
    this._private.allOptionsSelected = true;
  }

  /* Deselects all checked options.
   **/
  FilterMultipleSelect.prototype.deselectAll = function() {
    var $list = this._private.$list;
    var $selectedOptions = $list.find("li.selected");
    $selectedOptions.each(function() {
      var userAction = jQuery.Event("click");
      userAction.which = 1; // Mimic click
      $(this).trigger(userAction);
    });
    this.updateDisplay();
    this._private.$toggle.text("Select all");
    this._private.allOptionsSelected = false;
  }

  /* Need to overwrite inherited to check whether we need
   * to reset the data first.
   **/
  FilterMultipleSelect.prototype.search = function() {
    var $input = this._private.$input;
    var inputValue = $input.val();

    // If the user deleted some input we need to reset data first.
    if(inputValue.length < this._private.value.length) {
      this._private.service.reset();
    }

    this._private.value = inputValue;
    this._private.service.update(inputValue);
  }


  /* Assess what is selected and output text values to the display.
   **/
  FilterMultipleSelect.prototype.updateDisplay = function() {
    var $display = this._private.$display;
    var $selected = this._private.$select.find(":selected");
    $display.empty();
    $selected.each(function() {
      $display.append($('<li></li>').text(this.text));
    });
  }

})(jQuery, dit.utils, dit.classes);

/* Class: SelectiveLookup
 * -----------------------
 * Intended to enhance the $target input element with data lookup.
 * Performs a data lookup and displays multiple choice results
 * to populate the input value with user choice.
 *
 * REQUIRES:
 * jquery
 * dit.js
 * dit.utils.js
 *
 **/
(function($, utils, classes) {

  /* Main Class
   * @$input (jQuery node) Target input element
   * @request (Function) Returns reference to the jqXHR requesting data
   * @content (Function) Returns content to populate the dropdown
   * @options (Object) Allow some configurations
   **/
  classes.SelectiveLookup = SelectiveLookup;
  function SelectiveLookup($input, service, options) {
    var instance = this;
    var popupId = utils.generateUniqueStr();

    // Configure options.
    var opts = $.extend({
      $after: $(), // (jQuery element) Specify an element to insert list after.
      lookupOnCharacter: 4 // (Integer) At what character input to trigger the request for data
    }, options || {});

    // Some inner variable requirement.
    instance._private = {
      active: false, // State management to isolate the listener.
      service: service, // Service that retrieves and stores the data
      $list: $('<ul class="SelectiveLookupDisplay" style="display:none;" id="' + popupId + '" role="listbox" tabindex="-1"></ul>'),
      $input: $input,
      timer: null
    }

    // Will not have arguments if being inherited for prototype
    if(arguments.length >= 2) {
    
      // Bind lookup event.
      $input.attr("autocomplete", "off"); // Because it interferes with results display.
      $input.on("focus.SelectiveLookup", function() { instance._private.active = true; });
      $input.on("blur.SelectiveLookup", function() { instance._private.active = false; });

      $input.on("input.SelectiveLookup", function() {
        // If first character is space, get rid of it. 
        if(this.value[0] === " ") {
          this.value = this.value.substring(1);
        }

        if(instance._private.timer) {
          clearTimeout(instance._private.timer);
        }
      
        if(this.value.length >= opts.lookupOnCharacter) {
          instance._private.timer = setTimeout(function() {
            instance.search()
          }, 500);
        }
      });
      
      /* Bind events to allow keyboard navigation of component.
       * Using keydown event because works better with Tab capture.
       * Supports following keys:
       * 9 = Tab
       * 13 = Enter
       * 27 = Esc
       * 38 = Up
       * 40 = Down
       **/
      $input.on("keydown.SelectiveLookup", function(e) {
        switch(e.which) {
        
          // Esc to close when on input
          case 9:
          case 27:
            instance.close();
            break;

          // Tab or arrow from input to list
          case 40:
            if(!e.shiftKey && instance._private.$input.attr("aria-expanded") === "true") {
              e.preventDefault();
              instance._private.$list.find("li:first-child").focus();
            }
        }
      });

      instance._private.$list.on("keydown.SelectiveLookup", "li", function(e) {
        var $current = $(e.target);
        switch(e.which) {

          // Arrow movement between list items
          case 38:
            e.preventDefault();
            $current.prev("li").focus();
            break;
          case 40:
            e.preventDefault();
            $current.next("li").focus();
            break;

          // Esc to close when on list item (re-focus on input)
          case 9:
          case 27:
            instance.close();
            break;

          // Enter key item selection
          case 13:
            e.preventDefault();
            $current.click();

          default: // Nothing
        }
      });

      // Arrow movement from list to input
      instance._private.$list.on("keydown.SelectiveLookup", "li:first-child", function(e) {
        if(e.which === 38) {
          e.preventDefault();
          $input.focus();
        }
      });

      // Bind service update listener
      instance._private.service.listener(function() {
        if(instance._private.active) {
          instance.setContent();
          instance.bindContentEvents();
          instance.open();
        }
      });

      // Add some accessibility support
      $input.attr("aria-autocomplete", "list");
      $input.attr("role", "combobox");
      $input.attr("aria-expanded", "false");
      $input.attr("aria-owns", popupId);

      // Add display element
      if(opts.$after.length) {
        opts.$after.after(instance._private.$list);
      }
      else {
        $(document.body).append(instance._private.$list);
      }

      // Register the instance
      SelectiveLookup.instances.push(this);

      // A little necessary visual calculating.
      $(window).on("resize", function() {
        instance.setSizeAndPosition();
      });
    }
  }

  SelectiveLookup.prototype = {};

  /* What happens when something is selected from the list.
   * Added to prototype to allow easy overwrite when inheriting.
   **/
  SelectiveLookup.prototype.bindContentEvents = function() {
    var instance = this;
    instance._private.$list.off("click.SelectiveLookupContent");
    instance._private.$list.on("click.SelectiveLookupContent", function(event) {
      var $eventTarget = $(event.target);
      if($eventTarget.attr("data-value") !== undefined) {
        instance._private.$input.val($eventTarget.attr("data-value"));
      }
    });
  }
  
  SelectiveLookup.prototype.close = function() {
    var $input = this._private.$input;
    if($input.attr("aria-expanded") === "true") {
      this._private.$list.css({ display: "none" });
      $input.attr("aria-expanded", "false");
      $input.focus();
    }
  }
  
  SelectiveLookup.prototype.search = function() {
    this._private.service.update(this.param());
  }
  
  SelectiveLookup.prototype.param = function() {
    // Set param in separate function to allow easy override.
    return this._private.$input.attr("name") + "=" + this._private.$input.val();
  }
  
  /* Uses the data set on associated service to build HTML
   * result output. Since data keys are quite likely to vary
   * across services, you can pass through a mappingn object
   * to avoid the default/expected key names.
   * @datamapping (Object) Allow change of required key name
   **/
  SelectiveLookup.prototype.setContent = function(datamapping) {
    var data = this._private.service.data;
    var $list = this._private.$list;
    var map = datamapping || { text: "text", value: "value" };
    $list.empty();
    if(data && data.length) {
      for(var i=0; i<data.length; ++i) {
        // Note:
        // Only need to set a tabindex attribute to allow focus.
        // The value is not important here.
        $list.append('<li role="option" data-value="' + data[i][map.value] + '" tabindex="-1">' + data[i][map.text] + '</li>');
      }
    }
    else {
      $list.append('<li role="option" data-value="" tabindex="-1">No results found</li>');
    }
  }
  
  SelectiveLookup.prototype.setSizeAndPosition = function() {
    var position = this._private.$input.offset();
    this._private.$list.css({
      left: parseInt(position.left) + "px",
      position: "absolute",
      top: (parseInt(position.top) + this._private.$input.outerHeight()) + "px",
      width: this._private.$input.outerWidth() + "px"
    });
  }
  
  SelectiveLookup.prototype.open = function() {
    this.setSizeAndPosition();
    this._private.$list.css({ display: "block" });
    this._private.$input.attr("aria-expanded", "true");
  }

  SelectiveLookup.instances = [];
  SelectiveLookup.closeAll = function() {
    for(var i=0; i<SelectiveLookup.instances.length; ++i) {
      SelectiveLookup.instances[i].close();
    }
  }
  
  // So that we close any open when another is activated
  $(document).ready(function() {
    $(document.body).on("click.SelectiveLookupCloseAll", SelectiveLookup.closeAll);
  });

})(jQuery, dit.utils, dit.classes);

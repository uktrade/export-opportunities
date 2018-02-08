/* Class: Expander
 * ----------------
 * Expand and collapse a target element by another specified, controlling element, 
 * or through an automatically added default controller.
 *
 * Note: The COLLAPSED class is added when the Expander element is closed, so
 * you can control CSS the open/close state, or other desired styling. 
 *
 * REQUIRES:
 * jquery
 * dit.js
 * dit.utils.js
 *
 **/
(function($, utils, classes) {
  var TYPE = "Expander";
  var COLLAPSED = "collapsed";
  var ACTIVE = "active";
  var OPEN = "open";
  var CLOSE = "close";
  var CLICK = "click." + TYPE;
  var BLUR = "blur." + TYPE;
  var FOCUS = "focus." + TYPE;
  var KEY = "keydown." + TYPE;
  var ONMOUSEOUT = "mouseout." + TYPE;
  var ONMOUSEOVER = "mouseover." + TYPE;

  /* Main Class
   * @$target (jQuery node) Target element that should open/close
   * @options (Object) Configuration switches. 
   **/
  classes.Expander = Expander;
  function Expander($target, options) {
    var EXPANDER = this;
    var id = utils.generateUniqueStr(TYPE + "_");
    var $wrapper, $control;

    this.config = $.extend({
      blur: true, // If enabled closes on blur.
      cleanup: function() {
        // Additional tasks that may be performed on destroy.
      },
      closed: true, // Whether the item has initial closed state.
      cls: "", // config.wrap ? put on wrapper : put on target.
      complete: function() {
        // You can pass a function to run on open+close
      },
      focus: false, // If enabled puts focus back on activating element target is closed.
      hover: false, // If enabled opens/closes on hover as well.
      text: "Expand", // Control button text.
      wrap: false,
      $control: null // Pass a node if you want to specify something.
    }, options);

    if (arguments.length && $target.length) {
      
      $control = this.config.$control || $(document.createElement("a"));
      if ($control.get(0).tagName.toLowerCase() === "a") {
        $control.attr("href", "#" + id);
      }
      
      // Figure out and setup the expanding element
      if(this.config.wrap) {
        $wrapper = $(document.createElement("div"));
        $control.after($wrapper);
        $wrapper.append($target);
        this.$node = $wrapper;
      }
      else {
        id = $target.attr("id") || id; // In case the existing element has its own
        this.$node = $target;
      }
      
      this.links = {
        $found: $("a", this.$node) || $(),
        counter: -1
      }

      // If we detected any links, enable arrow movement through them.
      this.links.$found.on(KEY, function(e) {
        e.which != 9 && e.preventDefault();
        Expander.move.call(EXPANDER, e);
      }).on(BLUR, function(){
        Expander.blur.call(EXPANDER);
      }).on(FOCUS, function() {
        Expander.focus.call(EXPANDER);
      });

      this.$node.before($control);
      this.$node.addClass(TYPE);
      this.$node.addClass(this.config.cls);
      this.$node.attr("id", id);

      // Finish setting up control
      this.$control = $control;
      $control.addClass(TYPE + "Control");
      $control.attr("aria-controls", id);
      $control.attr("aria-expanded", "false");
      $control.attr("aria-haspopup", "true");
      $control.attr("tabindex", 0);
      if($control.text() === "") {
        $control.html(this.config.text)
      }

      // Set initial state
      if (this.config.closed) {
        this.state = OPEN;
        this.close();
      }
      else {
        this.state = CLOSE;
        this.open();
      }
     
      // Bind events for user interaction
      Expander.bindEvents.call(this);
    }
  }
  
  /* Class utility function to bind required 
   * events upon instantiation. Needs to be run 
   * with context of the instantiated object.
   **/
  Expander.bindEvents = function() {
    var EXPANDER = this;
    
    Expander.AddKeyboardSupport.call(EXPANDER);
    
    if (EXPANDER.config.hover) {
      Expander.AddHoverSupport.call(EXPANDER);
    }
    else {
      Expander.AddClickSupport.call(EXPANDER);
    }
  }
  
  /* Add ability to control by keyboard
   **/
  Expander.AddKeyboardSupport = function() {
    var EXPANDER = this;
    
    EXPANDER.$control.on(KEY, function(event) {
      // keypress charCode=0, keyCode=13 = enter
      event.which != 9 && event.preventDefault();
      Expander.focus.call(EXPANDER);

      switch(event.which) {
        case 38: // Fall through.
        case 27: 
          EXPANDER.close();
          break;
        case 13: 
          EXPANDER.$control.trigger(CLICK);
          break;
        case 40:
          if(EXPANDER.state === OPEN) {
            // Move though any detected links.
            Expander.move.call(EXPANDER, event);
          }
          else {
            EXPANDER.open();
          }
          break;
        default: ; // Nothing yet.
      }
    });
  }

  /* Add Hover events (for desktop only)
   **/
  Expander.AddHoverSupport = function() {
    var EXPANDER = this;
    var $node = EXPANDER.$node;

    EXPANDER.$control.add($node).on(ONMOUSEOVER, function(event) {
      event.preventDefault();
      Expander.on.call(EXPANDER);
      EXPANDER.open();
    });
    
    EXPANDER.$control.add($node).on(ONMOUSEOUT, function() {
      Expander.off.call(EXPANDER);
    });
    
    EXPANDER.$control.on(CLICK, function(event) {
      event.preventDefault();
    });
  }
  
  /* Using click for desktop and mobile.
   **/
  Expander.AddClickSupport = function() {
    var EXPANDER = this;

    EXPANDER.$control.on(CLICK, function(event) {
      event.preventDefault();
      Expander.on.call(EXPANDER);
      EXPANDER.toggle();
    });
    
    // And now what happens on blur.
    if(EXPANDER.config.blur) {
      EXPANDER.$control.on(BLUR, function() {
        Expander.blur.call(EXPANDER);
      });
    }
  }

  Expander.on = function() {
    clearTimeout(this.closerequest);
  }
  
  Expander.off = function() {
    var self = this;
    this.closerequest = setTimeout(function() {
      self.close(true);
    }, 0.5);
  }

  Expander.focus = function() {
    Expander.on.call(this);
  }

  Expander.blur = function() {
    if(this.config.blur && this.state != CLOSE) {
      Expander.off.call(this);
    }
  }

  Expander.move = function(e) {
    var counter = this.links.counter;
    var $links = this.links.$found;
    if($links) {
      switch(e.which) {
        case 27: this.close();
          break;
        case 40:
          // Down.
          if(counter < ($links.length - 1)) {
            $links.eq(++counter).focus();
          }
          break;
        case 38:
          // Up.
          if(counter > 0) {
            $links.eq(--counter).focus();
          }
          else {
            counter--;
            this.close();
          }
          break;
        default: ; // Nothing yet.
      }
    }
    this.links.counter = counter;
  }

  Expander.prototype = new Object;
  Expander.prototype.toggle = function() {
    if(this.state != OPEN) {
      this.open();
    }
    else {
      this.close();
    }
  }

  Expander.prototype.open = function() {
    if(!this._locked && this.state != OPEN) {
      this._locked = true;
      this.state = OPEN;
      this.$control.addClass(ACTIVE);
      this.$node["removeClass"](COLLAPSED);
      this.$control.attr("aria-expanded", "true");
      this.links.$found.attr("tabindex", 0);
      this.config.complete.call(this);
      this._locked = false;
    }
  }

  Expander.prototype.close = function() {
    var focus = this.config.focus;
    if(!this._locked && this.state != CLOSE) {
      this._locked = true;
      this.state = CLOSE;
      this.$control.removeClass(ACTIVE);
      this.$node["addClass"](COLLAPSED);
      this.config.complete.call(this);
      this.$control.attr("aria-expanded", "false");
      this.links.$found.attr("tabindex", -1);
      if(focus) {
        this.$control.focus();
      }
      this.links.counter = -1; // Reset.
      this._locked = false;
    }
  }

  Expander.prototype.destroy = function() {
    var events = CLICK + " " + BLUR + " " + FOCUS + " " + KEY + " " + ONMOUSEOUT + " " + ONMOUSEOVER;
    if(this.config.wrap) {
      this.$node.replaceWith(this.$node.contents());
    }
    else {
      this.$node.removeClass(this.config.cls);
      this.$node.removeClass(COLLAPSED);
      this.$node.removeClass(TYPE);
    }
    
    if(this.config.$control) {
      this.$control.off(events);
      this.$control.removeClass(this.config.cls + "Control");
      this.$control.removeAttr("tabindex");
      this.$control.removeAttr("aria-controls");
      this.$control.removeAttr("aria-expanded");
      this.$control.removeAttr("aria-haspopup");
    }
    else {
      this.$control.remove();
    }

    this.links.$found.off(events);
    this.links.$found.removeAttr("tabindex");
    this.config.cleanup();
  }
  
})(jQuery, dit.utils, dit.classes);

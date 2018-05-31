/* Class: Carousel
 * -----------------------
 * Class will turn passed node (and specified items) into a Carousel
 *
 * REQUIRES:
 * jquery
 * dit.js
 * dit.utils.js
 *
 **/
(function ($, utils, classes) {
  var ACTIVE = "active";
  var CSS_CLASS_CAROUSEL = "Carousel";
  var HIDDEN = "hidden"; 
  var NEXT = "next";
  var PREVIOUS = "previous";
  var ACCESS_HIDDEN = "aria-hidden";
  var PAUSE = "pause";
  var MOUSEOVER = "mouseover.carousel";
  var MOUSEOUT = "mouseout.carousel";

  /* Constructor.
   * @$items (jQuery Object) Collection of elements to become carousel items.
   * @options (Object) Passed configuration. 
   *  e.g {
   *    items: (String) Selector for jQuery lookup of child items.
   *     button: (Bool) Include next/previous buttons.
   *    ariaHidden: (Bool) Hide Carousel from Screen readers. 
   *  }
   **/
  classes.Carousel = Carousel;
  function Carousel($items, options) {
    var carousel = this;
    var $node, $buttons, $controls, id;
    var $images = $items.find("img");
    this.moving = false;

    this.config = $.extend({
      ariaHidden: false, // Hide content (e.g. Screen Readers)
      auto: 0, // Auto play time in milliseconds (anything above 0 removes buttons and initiates)
      buttons: false, // Add Prev/Next?
      controls: false, // Add pause and slide buttons?
      duration: 400, // Animation length.
      pauseOnHover: true, // Pretty obvious - Mouseover stops, Mouseout starts. 
      wrapper: $() // If a jQuery object is passed, it gets used as $node (useful if items are list elements - pass the UL)
    }, options);

    this.controller = {
      current: 0,
      movement: "",
      next: 0,
      total: $items.length
    };

    if ($items.length > 1) {
      $node = Carousel.createWrapper.call(this);
      $items.parent().append($node);
      $items.addClass("item");
      id = $node.attr("id");
      this.$node = $node;
      
      $items.css("display", ""); // Counter any Carousel destroy display setting.
      if (this.config.pauseOnHover && this.config.auto) {
        Carousel.bindPauseEvents.call(this);
      }

      if (this.config.buttons && !this.config.auto) {
        $buttons = Carousel.generateContainer("buttons");
        $buttons.append(Carousel.generateButton.call(this, NEXT, id));
        $buttons.append(Carousel.generateButton.call(this, PREVIOUS, id));
        $node.append($buttons);
      }

      if (this.config.controls) {
        $controls = Carousel.generateContainer("controls");
        if(this.config.auto) {
          $controls.append(Carousel.generateButton.call(this, PAUSE, id));
        }
        $controls.append(Carousel.generateIndicators.call(this, $items, id));
        $node.append($controls);
      }

      if (this.config.ariaHidden) {
        $node.attr(ACCESS_HIDDEN, "true");
      }

      if (this.config.auto) {
        Carousel.automate.call(this);
      }
      
      if ($images.length) {
        utils.whenImagesReady($images, Carousel.setRequiredInlineStyles, [$items, $node]);
      }
      else {
        Carousel.setRequiredInlineStyles($items, $node);
      }
      
      this.$items = $items;
      this.$buttons = $buttons;
      this.$controls = $controls;
      Carousel.initialState.call(this);
    }
  }

  Carousel.setRequiredInlineStyles = function($items, $node) {
    $items.height(utils.maxHeight($items, true) + "px");
    $items.slice(0, -1).css("visibility", "hidden"); // Hide those that should not be visible yet.
    $node.prepend($items.eq(-1)); // Add one so we can get correct height with CSS involvement.
    $node.height($node.height()); // Get and set the height inline before we make them position:absolute
    $node.prepend($items.slice(0, -1));
    
    $node.css({
      overflow: "hidden",
      position: "relative"
    });
    
    $items.css({
      position: "absolute",
      top: 0,
      width: "100%"
    });
    
    $items.slice(0, -1).css("visibility", "visible"); // Make them visible again.
  }

  Carousel.createWrapper = function() {
    var $node = this.config.wrapper.length ? this.config.wrapper : $("<div></div>");
    var id = $node.attr("id") || utils.generateUniqueStr("carousel_");
    $node.attr("id", id);
    $node.addClass(CSS_CLASS_CAROUSEL);
    return $node;
  }

  Carousel.initialState = function() {
    this.$items.css("left", "100%");
    this.$items.eq(0).css("left", "0");
    Carousel.updateIndicators.call(this);
  }
  
  Carousel.bindPauseEvents = function() {
    var carousel  = this;
    this.$node.on(MOUSEOVER, function() {
      if(!carousel.onpause) {
        carousel.pause();
      }
    });

    this.$node.on(MOUSEOUT, function() {
      // TODO: Something better than lookup required.
      var $pause = $("." + PAUSE, carousel.$controls);
      if($pause.hasClass(ACTIVE)) {
        carousel.pause();
      }
    });
  }

  Carousel.generateContainer = function (str) {
    var container = document.createElement("div");
    container.setAttribute("class", str);
    return $(container);
  };

  Carousel.generateButton = function(movement, id) {
    var carousel = this;
    var button = document.createElement("button");
    button.setAttribute("class", movement);
    button.setAttribute("aria-controls", id);
    button.appendChild(document.createTextNode(movement));
    return $(button).on("click", function() {
      carousel[movement](this);
    });
  };

  Carousel.generateIndicators = function($items, id) {
    var carousel = this;
    var $container = Carousel.generateContainer("indicators");
    var $buttons = $();
    $items.each(function(i) {
      var $button = Carousel.generateButton.call(carousel, "slide");
      this.setAttribute("id", (this.id ? this.id : (id + "_" + i)));
      $button.addClass("indicator");
      $button.attr("aria-controls", this.id);
      $button.attr("data-indicator", i);
      $button.text($button.text() + " " + (i + 1)); // +1 to avoid zero.
      $buttons = $buttons.add($button);
    });
    carousel.$indicators = $buttons;
    return $container.append($buttons);
  };

  Carousel.previous = function (num) {
    return num - 1 < 0 ? this.$items.length - 1 : num - 1;
  };

  Carousel.next = function (num) {
    return num + 1 >= this.$items.length ? 0 : num + 1;
  };

  Carousel.updateIndicators = function() {
    var $buttons = this.$indicators;
    if($buttons && $buttons.length) {
      $buttons.removeClass(ACTIVE);
      $buttons.eq(this.controller.current).addClass(ACTIVE);
    }
  }

  Carousel.updateNext = function (movement) {
    this.controller.movement = movement;
    this.controller.next = Carousel[movement].call(this, this.controller.next);
  };

  Carousel.updateCurrent = function () {
    this.controller.current = this.controller.next;
  };

  Carousel.move = function () {
    var self = this;
    var queued = this.controller.movement === NEXT ? "100%" : "-100%";
    var leaving = this.controller.movement === NEXT ? "-100%" : "100%";

    this.$items.eq(this.controller.next).css("left", queued);
    this.$items.eq(this.controller.next).animate({
      left: 0 },{
      duration: self.config.duration
    });

    this.$items.eq(this.controller.current).animate({
      left: leaving },{
      duration: self.config.duration,
      complete: function() {
        self.moving = false;
      }
    });

    Carousel.updateCurrent.call(self);
    Carousel.updateIndicators.call(this);
  };

  Carousel.automate = function() {
    var self = this;
    this.autoInterval = setInterval(function() {
      if (!self.moving) {
        self.next();
      }
    }, this.config.auto);
  };

  Carousel.prototype.pause = function() {
    // TODO: Implement proper (non-lookup) alternative.
    var $pause = $("." + PAUSE, this.$controls);
    var carousel = this;
  
    // First get rid of any waiting previous pause action.
    clearTimeout(carousel.pauseTimer);

    // Then access whether to restart or pause.
    if(this.autoInterval || carousel.onpause) {
      this.autoInterval = clearInterval(this.autoInterval);
      $pause.addClass(ACTIVE);
    }
    else {
      Carousel.automate.call(this);
      $pause.removeClass(ACTIVE);
    }

    $pause.blur();

    // Wait until duration so animation should have stopped.
    carousel.pauseTimer = setTimeout(function() {
      if(carousel.onpause) {
        carousel.onpause.call(carousel);
        carousel.onpause = null; // Clear it.
      }
    }, carousel.config.duration);
  }

  Carousel.prototype.slide = function(el) {
    if(!this.config.controls) return; // Hacky! Only allow when controls present.
    var carousel = this;
    var $buttons = this.$indicators;
    var $button = el ? $(el) : $buttons.eq(0);
    var to = Number($button.attr("data-indicator"));
    if(!isNaN(to) && to != carousel.controller.current) {
      carousel.onpause = function() {
        var movement = to > carousel.controller.current ? NEXT : PREVIOUS;
        if(!carousel.moving) {
          while(to != carousel.controller.next) {
            Carousel.updateNext.call(this, movement);
          }
          Carousel.move.call(this);
        }
      };
    }
    carousel.pause();
  }

  Carousel.prototype.next = function () {
    if (!this.moving) {
      this.moving = true;
      Carousel.updateNext.call(this, NEXT);
      Carousel.move.call(this);
    }
  };

  Carousel.prototype.previous = function () {
    if (!this.moving) {
      this.moving = true;
      Carousel.updateNext.call(this, PREVIOUS);
      Carousel.move.call(this);
    }
  };

  /* Tear down the Carousel functionality.
   * Useful on responsive layouts that may only
   * include carousel at certain dimensions.
   **/
  Carousel.prototype.destroy = function () {
    var node =  this.$node.get(0);
    
    // Put the breaks on.
    this.pause();

    // Clear any timers. 
    clearTimeout(this.pauseTimer);
    clearInterval(this.autoInterval);

    // Stop anything still moving.
    this.$items.stop(true, true);
    this.$items.each(function(i) {
       // Reset any position or display stuff.
      this.style.height = "";
      this.style.position = "";
      this.style.top = "";
      this.style.width = "";
      this.style.left = "";

      // To avoid unsightly full exposure before rebuild
      // we hide all but one of the items. 
      if(i != 1) {
        this.style.display = "none";
      }
    });

    if(this.$buttons && this.$buttons.length) {
      this.$buttons.remove();
    }

    if(this.$controls && this.$controls.length) {
      this.$controls.remove();
    }

    this.$node
      .off(MOUSEOVER + " " + MOUSEOUT)
      .removeAttr(ACCESS_HIDDEN)
      .removeClass(CSS_CLASS_CAROUSEL);
      
    // Reset (inline styles)
    node.style = {};

    // If we created a wrapper element, we need to remove it
    // and avoid duplications on rebuild.
    if(this.config.wrapper.length < 1) {
      this.$node.after(this.$node.children());
      this.$node.remove();
    }
  };

})(jQuery, dit.utils, dit.classes);


/* Class: Modal
 * -------------------------
 * Create an area to use as popup/modal/lightbox effect. 
 * 
 * REQUIRES:
 * jquery
 * dit.js
 * dit.responsive.js
 *
 **/

(function($, utils, classes) {
  
  var ARIA_EXPANDED = "aria-expanded";
  var CSS_CLASS_CLOSE_BUTTON = "close";
  var CSS_CLASS_CONTAINER = "Modal-Container"
  var CSS_CLASS_CONTENT = "content";
  var CSS_CLASS_OPEN = "open";
  var CSS_CLASS_OVERLAY = "Modal-Overlay";

  /* Constructor
   * @options (Object) Allow some configurations
   **/
  classes.Modal = Modal;
  function Modal($container, options) {
    var modal = this;
    var config = $.extend({
      $activators: $(), // (optional) Element(s) to control the Modal
      closeOnBuild: true, // Whether intial Modal view is open or closed
      overlay: true  // Whether it has an overlay or not
    }, options || {});

    // If no arguments, likely just being inherited
    if (arguments.length) {
      // Create the required elements
      if(config.overlay) {
        this.$overlay = Modal.createOverlay();
        Modal.bindResponsiveOverlaySizeListener.call(this);
      }
    
      this.$closeButton = Modal.createCloseButton();
      this.$content = Modal.createContent();
      this.$container = Modal.enhanceModalContainer($container);
    
      // Add elements to DOM
      Modal.appendElements.call(this, config.overlay);
    
      // Add events
      Modal.bindCloseEvents.call(this);
      Modal.bindActivators.call(this, config.$activators);
    
      // Initial state
      if (config.closeOnBuild) {
        this.close();
      }
      else {
        this.open();
      }
    }
  }
  
  Modal.createOverlay = function() {
    var $overlay = $(document.createElement("div"));
    $overlay.addClass(CSS_CLASS_OVERLAY);
    return $overlay;
  }

  Modal.createCloseButton = function() {
    var $button = $(document.createElement("button"));
    $button.text("Close");
    $button.addClass(CSS_CLASS_CLOSE_BUTTON);
    return $button;
  }
  
  Modal.createContent = function() {
    var $content = $(document.createElement("div"));
    $content.addClass(CSS_CLASS_CONTENT);
    return $content;
  }

  Modal.enhanceModalContainer = function($container) {
    $container.addClass(CSS_CLASS_CONTAINER);
    return $container;
  }
  
  Modal.appendElements = function(overlay) {
    this.$container.append(this.$closeButton);
    this.$container.append(this.$content);
    
    if (overlay) {
      $(document.body).append(this.$overlay);
    }
    $(document.body).append(this.$container);
  }
  
  Modal.bindCloseEvents = function() {
    var self = this;
    self.$closeButton.on("click", function(e) {
      e.preventDefault();
      self.close();
    });
    
    if (self.$overlay && self.$overlay.length) {
      self.$overlay.on("click", function() {
        self.close();
      });
    }
  }
  
  Modal.bindActivators = function($activators) {
    var self = this;
    $activators.on("click", function(e) {
      e.preventDefault();
      self.open();
    });
  }

  Modal.bindResponsiveOverlaySizeListener = function() {
    var self = this;
    // Resets the overlay height (once) on scroll because document
    // height changes with responsive resizing and the browser
    // needs a delay to redraw elements. Alternative was to have
    // a rubbish setTimeout with arbitrary delay. 
    $(document.body).on(dit.responsive.reset, function(e, mode) {
      $(window).off("scroll.ModalOverlayResizer");
      $(window).one("scroll.ModalOverlayResizer", function() {
        Modal.setOverlayHeight(self.$overlay);
      });
    });
  }
  
  Modal.setOverlayHeight = function($overlay) {
    $overlay.get(0).style.height = ""; // Clear it first
    $overlay.height($(document).height());
  }
  
  Modal.prototype = {};
  Modal.prototype.close = function() {
    var self = this;
    self.$container.fadeOut(50, function () {
      self.$container.attr(ARIA_EXPANDED, false);
      self.$container.removeClass(CSS_CLASS_OPEN);
    });
    
    if (self.$overlay && self.$overlay.length) {
      self.$overlay.fadeOut(150);
    }
  }
  
  Modal.prototype.open = function() {
    var self = this;
    self.$container.css("top", window.scrollY + "px");
    self.$container.addClass(CSS_CLASS_OPEN);
    self.$container.fadeIn(250, function () {
      self.$container.attr(ARIA_EXPANDED, true);
    });
    
    if (self.$overlay && self.$overlay.length) {
      Modal.setOverlayHeight(self.$overlay);
      self.$overlay.fadeIn(0);
    }
  }
  
  Modal.prototype.setContent = function(content) {
    var self = this;
    self.$content.empty();
    self.$content.append(content);
  }
  
  
})(jQuery, dit.utils, dit.classes);

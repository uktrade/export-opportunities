var ukti = window.ukti || {};

ukti.Revealer = (function() {
  'use strict';

  function Revealer() {
    this.buttons = document.querySelectorAll("[data-great-ds-reveal-button]");
    this.overlay = new ukti.Overlay();
    this.activeTarget = null;
    this.init();
  }

  Revealer.prototype.init = function() {
    var self = this;
    
    this.buttons.forEach(function(button) {
      button.addEventListener("click", function(e) {
        e.stopPropagation();
        self.toggleReveal(button);
      });
    });

    document.addEventListener("click", function(e) { self.handleOutsideClick(e); });
    document.addEventListener("keydown", function(e) { self.handleEscapeKey(e); });
    document.addEventListener("focusout", function(e) { self.handleFocusOut(e); });
  };

  Revealer.prototype.toggleReveal = function(button) {
    var targetId = button.getAttribute("aria-controls");
    var target = document.getElementById(targetId);

    if (target) {
      var isHidden = target.getAttribute("aria-hidden") !== "false";
      target.setAttribute("aria-hidden", isHidden ? "false" : "true");
      target.style.display = isHidden ? "block" : "none";
      button.setAttribute("aria-expanded", isHidden ? "true" : "false");
      
      if (isHidden) {
        target.classList.add("is-active");
        button.classList.add("is-active");
      } else {
        target.classList.remove("is-active");
        button.classList.remove("is-active");
      }

      if (button.hasAttribute("data-great-ds-reveal-modal")) {
        if (isHidden) {
          this.overlay.show();
        } else {
          this.overlay.hide();
        }
        this.activeTarget = isHidden ? target : null;
      }
    }
  };

  Revealer.prototype.handleOutsideClick = function(event) {
    if (event.target.closest && event.target.closest("[data-great-ds-reveal-button]")) {
      return;
    }

    var self = this;
    var activeButtons = document.querySelectorAll(
      '[data-great-ds-reveal-button][aria-expanded="true"]'
    );
    
    activeButtons.forEach(function(button) {
      var buttonController = button.getAttribute("aria-controls");
      var targetElement = document.getElementById(buttonController);

      if (
        targetElement &&
        !targetElement.contains(event.target) &&
        !button.contains(event.target)
      ) {
        self.toggleReveal(button);
      }
    });
  };

  Revealer.prototype.handleEscapeKey = function(event) {
    if (event.key === "Escape") {
      this.hideAll();
    }
  };

  Revealer.prototype.handleFocusOut = function(event) {
    if (this.activeTarget && !this.activeTarget.contains(event.relatedTarget)) {
      this.hideAll();
    }
  };

  Revealer.prototype.hideAll = function() {
    var self = this;
    
    this.buttons.forEach(function(button) {
      var targetId = button.getAttribute("aria-controls");
      var target = document.getElementById(targetId);
      if (target && target.getAttribute("aria-hidden") === "false") {
        self.toggleReveal(button);
      }
    });
    
    this.overlay.hide();
    this.activeTarget = null;
  };

  return Revealer;
})();

document.addEventListener("DOMContentLoaded", function() {
  new ukti.Revealer();
});

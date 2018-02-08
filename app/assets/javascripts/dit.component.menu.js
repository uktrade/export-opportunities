
// Menu Component Functionality.
//
// Requires...
// dit.js
// dit.class.expander.js
// dit.classes.accordion.js

dit.components.menu = (new function() {

  // Constants
  var MENU_ACTIVATOR_ID = "menu-activator";
  var MENU_ACTIVATOR_TEXT = "Menu";
  var SELECTOR_LIST_HEADER = "#menu .list-header";
  var SELECTOR_MENU = "#menu";
  var SELECTOR_MENU_LISTS = "#menu ul[aria-labelledby]";

  // Private
  var _self = this;
  var _expanders = [];
  var _accordion = [];

  // Immediately invoked function and declaration.
  // Because non-JS view is to show all, we might see a brief glimpse of the
  // open menu before JS has kicked in to add dropdown functionality. This
  // will hide the menu when JS is on, and deactivate itself when the JS
  // enhancement functionality is ready.
  dropdownViewInhibitor(true);
  function dropdownViewInhibitor(activate) {
    var rule = SELECTOR_MENU + " .level-2 { display: none; }";
    var style;
    if (arguments.length && activate) {
      style = document.createElement("style");
      style.setAttribute("type", "text/css");
      style.setAttribute("id", "menu-dropdown-view-inhibitor");
      style.appendChild(document.createTextNode(rule));
      document.head.appendChild(style);
    }
    else {
      document.head.removeChild(document.getElementById("menu-dropdown-view-inhibitor"));
    }
  };

  /* Add expanding functionality to target elements for desktop.
  **/
  function setupDesktopExpanders() {
    $(SELECTOR_MENU_LISTS).each(function() {
      var $this = $(this);
      // Add to _expanders support reset()
      _expanders.push(new dit.classes.Expander($this, {
        hover: true,
        wrap: true,
        $control: $("#" + $this.attr("aria-labelledby"))
      }));
    });
  }

  /* Add expanding functionality to target elements for tablet.
  **/
  function setupTabletExpanders() {
    setupOpenByButton();
    setupAccordionMenus();
  }

  /* Add expanding functionality to target elements for mobile.
  * Note: Just calls the tablet setup because it is the same.
  **/
  function setupMobileExpanders() {
    setupTabletExpanders();
  }

  /* Figures out what responsive view is in play
  * and attempts to setup the appropriate functionality.
  **/
  function setupResponsiveView() {
    var mode = dit.responsive.mode();
    this.mode = mode;
    switch(mode) {
      case "desktop":
      setupDesktopExpanders();
      break;
      case "tablet":
      setupTabletExpanders();
      break;
      case "mobile":
      setupMobileExpanders();
      break;
      default: console.log("Could not determine responsive mode"); // Do nothing.
    }
  }

  /* Adds button for opening all menu lists (e.g. common mobile view)
  **/
  function createMenuActivator() {
    var $button = $("<button></button>");
    var $icon = $("<span></span>");
    $button.text(MENU_ACTIVATOR_TEXT);
    $button.attr("tabindex", "0");
    $button.attr("id", MENU_ACTIVATOR_ID);
    $button.append($icon.clone());
    return $button;
  }

  /* Bind listener for the dit.responsive.reset event
  * to reset the view when triggered.
  **/
  function bindResponsiveListener() {
    $(document.body).on(dit.responsive.reset, function(e, mode) {
      if(mode !== dit.components.menu.mode) {
        dit.components.menu.reset();
      }
    });
  }

  /* Hacky workaround.
  * List Headers are HTML anchors, mainly to get keyboard
  * tabbing working properly. This causes issues when in
  * tablet/mobile view, however. This function is trying
  * to prevent list-headers acting like focusable anchors.
  **/
  function fixTabletTabbingIssue() {
    var $listHeaders = $(SELECTOR_LIST_HEADER);
    $listHeaders.attr("tabindex", "-1");
    $listHeaders.off("blur");
    $listHeaders.on("click.workaround", function(e) {
      e.preventDefault();
    });
  }

  /* Open and close the entire menu by a single button
  **/
  function setupOpenByButton() {
    var $control = createMenuActivator();
    var $menu = $(SELECTOR_MENU);
    $menu.before($control);
    $menu.each(function() {
      _expanders.push(new dit.classes.Expander($(this), {
        blur: false,
        $control: $control,
        complete: fixTabletTabbingIssue,
        cleanup: function() {
          $control.remove();
        }
      }));
    });
  }

  /* Accordion effect for individual menu dropdowns
  **/
  function setupAccordionMenus() {
    var expanders = [];
    $(SELECTOR_MENU_LISTS).each(function() {
      var $this = $(this);
      expanders.push(new dit.classes.Expander($this, {
        $control: $("#" + $this.attr("aria-labelledby"))
      }));
    });

    // Make array of expanders into an accordion.
    new dit.classes.Accordion(expanders, "open", "close");

    // Add to _expanders for reset() support.
    _expanders.push.apply(_expanders, expanders);
  }


  // Public
  this.mode = "";

  this.init = function() {
    bindResponsiveListener();
    setupResponsiveView();
    dropdownViewInhibitor(false); // Turn it off because we're ready.
  }

  this.reset = function() {
    // Clear anything that is there...
    $(SELECTOR_LIST_HEADER).off("click.workaround");
    while(_expanders.length) {
      _expanders.pop().destroy();
    }

    // ...and now start again.
    setupResponsiveView();
  }

});


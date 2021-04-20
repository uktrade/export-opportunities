
var dit = dit || {};

dit.classes = dit.classes || {};
dit.components = dit.components || {};
dit.constants = dit.constants || {};

dit.components.greatHeader = (new function() {
  var GREAT_HEADER = '#great-header';
  var HEADER_NAV = '#great-header-nav';
  var COLLAPSED_CLASS = 'collapsed';
  var MENU_HEADING = '.js-link-heading';
  var COLLAPSIBLE_MENUS = '.js-collapsible-menu';
  var MENU_CONTROL_CLASSNAME = 'js-menu-control';
  var MOBILE_MENU_BUTTON_ID = 'js-mobile-button';
  var LANGUAGE_SELECTOR = '#language-selector-activator';
  var EXTRA_LINKS = '#great-header-extra-links';
  var NAV_LIST = '#great-header-nav-list';

  var expanders = [];
  var self = this;

  self.config = {
    HEADER_NAV: HEADER_NAV,
    MENU_HEADING: MENU_HEADING,
    MENU_CONTROL_CLASSNAME: MENU_CONTROL_CLASSNAME,
  };

  function setupResponsiveView() {
    self.mode = dit.responsive.mode();
    switch(self.mode) {
      case 'desktop': setupDesktopHeader(); break;
      case 'tablet': setupMobileHeader(); break;
      case 'mobile': setupMobileHeader(); break;
      default: console.log('Could not determine responsive mode');
    }
  }

  function setupDesktopHeader() {
    var _expanders = [];
    self.config.mode = self.mode;
    self.config.hover = true;
    self.config.blur = true;

    $(COLLAPSIBLE_MENUS).each(function() {
      _expanders.push(new dit.classes.Dropdown($(this), self.config));
    });

    expanders.push.apply(expanders, _expanders);
  }

  function setupMobileHeader() {
    var $control = $('<button></button>');
    var $icon = $('<span></span>');

    $control.text('Menu');
    $control.attr('tabindex', '0');
    $control.attr('id', MOBILE_MENU_BUTTON_ID);
    $control.attr('class', MOBILE_MENU_BUTTON_ID);
    $control.attr('aria-controls', HEADER_NAV);
    $control.append($icon.clone());

    var $menu = $(HEADER_NAV);
    $menu.before($control);
    $menu.addClass(COLLAPSED_CLASS);
    $(GREAT_HEADER).addClass('menu-collapsed');

    var _expanders = [];

    _expanders.push(new dit.classes.Dropdown($menu, {
      $control: $control,
      blur: false,
      hover: false,
      mode: self.mode,
      cleanup: function() {
        // remove the menu button
        $control.remove();
        // remove classes
        $(GREAT_HEADER).removeClass('menu-collapsed');
        $(GREAT_HEADER).removeClass('menu-expanded');
      },
      onOpened: function() {
        $(GREAT_HEADER).removeClass('menu-collapsed');
        $(GREAT_HEADER).addClass('menu-expanded');
      },
      onClosed: function() {
        $(GREAT_HEADER).removeClass('menu-expanded');
        $(GREAT_HEADER).addClass('menu-collapsed');
      }
    }));

    expanders.push.apply(expanders, _expanders);
  }

  // listen for resize event and change mode if different
  function setupResponsiveListener() {
    $(document.body).on(dit.responsive.reset, function(e, newMode) {
      if (newMode !== self.mode) dit.components.greatHeader.reset();
    });
  }

  // destroy, set up again in correct mode
  this.reset = function() {
    while (expanders.length) expanders.pop().destroy();
    setupResponsiveView();
  }

  this.init = function() {
    dit.responsive.init({
      'desktop': 'min-width: 769px',
      'tablet' : 'max-width: 768px',
      'mobile' : 'max-width: 640px'
    });

    setupResponsiveListener();
    setupResponsiveView();
    delete this.init; // Run once
  }
});

$(document).ready(function() {
  $('body').addClass('js-enabled');
  dit.components.greatHeader.init();
});

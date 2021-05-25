
var dit = dit || {};
dit = dit || {};
dit.classes = dit.classes || {};
dit.constants = dit.constants || {};

// keycodes
dit.constants.key = {
  SPACE: 32,
  ENTER: 13,
  LEFT: 37,
  UP: 38,
  RIGHT: 39,
  DOWN: 40,
  ESC: 27,
  TAB: 9,
};

(function($, classes) {
  classes.Dropdown = Dropdown;

  function Dropdown($target, config) {
    var self = this;

    var TYPE = 'Dropdown';

    // events
    self.events = {
      CLICK: 'click.' + TYPE,
      BLUR: 'blur.' + TYPE,
      FOCUS: 'focus.' + TYPE,
      KEYDOWN: 'keydown.' + TYPE,
      ONMOUSEOUT: 'mouseout.' + TYPE,
      ONMOUSEOVER: 'mouseover.' + TYPE,
    }

    self.$target = $target;

    // overrideable config with defaults
    self.config = $.extend({
      blur: false,
      hover: false,
      closed: true,
      cleanup: function() {},
      complete: function() {},
      onOpened: function() {},
      onClosed: function() {},
      $control: null, // used for mobile view
      buttonText: 'Menu', // used for mobile view
    }, config);

    self.cleanup = self.config.cleanup;
    self.complete = self.config.complete;

    // setup
    if (arguments.length && $target.length) {

      // setup button control for mobile
      if (self.config.$control) {
        self.$control = self.config.$control;
        self.$control.attr('aria-controls', self.config.HEADER_NAV);
      }
      else {
        var $control = $target.parent().find(self.config.MENU_HEADING);
        var $button = $('<button></button>');
        $button.addClass(self.config.MENU_CONTROL_CLASSNAME);
        $control.wrap($button);
        self.$control = $target.parent().find('button');
        // assume collapsible menus have unique IDs
        self.$control.attr('aria-controls', self.$target.attr('id'));
      }

      self.$control.attr('aria-haspopup', 'true');
      self.$control.attr('aria-expanded', 'false');
      self.$control.attr('tabindex', 0);

      // give mobile menu button/control text
      if (self.$control.text() === '') {
        self.$control.html(this.config.buttonText);
      }

      self.$target.addClass(TYPE);
      self.$control.addClass(TYPE + 'Control');

      // find links
      self.links = {
        $found: self.$target.find('a') || $(),
        counter: -1,
      }

      // keyboard support for links
      self.links.$found.on(self.events.KEYDOWN, function(e) {
        Dropdown.moveLinkFocus.call(self, e);
      }).on(self.events.FOCUS, function(e) {
        Dropdown.focus.call(self);
      }).on(self.events.BLUR, function(e){
        if (self.config.blur) Dropdown.blur.call(self);
      });

      // set initial state
      if (self.config.closed) {
        self.state = 'open';
        self.close();
      } else {
        self.state = 'closed';
        self.open();
      }

      Dropdown.bindEvents.call(this);
    }
  }

  // setup events
  Dropdown.bindEvents = function() {
    Dropdown.openWithKeyboard.call(this);
    if (this.config.hover) Dropdown.openWithHover.call(this);
    else Dropdown.openWithClick.call(this);
  }

  // open by keyboard
  Dropdown.openWithKeyboard = function() {
    var self = this;

    self.$control.on(self.events.KEYDOWN, function(e) {
      // allow tabbing through menu headings without opening them
      if (e.which == dit.constants.key.TAB) {
        if (e.shiftKey) {
          self.close();
        }
        return;
      }

      switch (e.which) {
        case dit.constants.key.UP:
        case dit.constants.key.ESC:
          e.preventDefault();
          self.close();
          break;
        case dit.constants.key.ENTER:
        case dit.constants.key.SPACE:
        case dit.constants.key.DOWN:
          e.preventDefault();
          if (self.state === 'open') Dropdown.moveFocusToLinks.call(self, e);
          else self.open();
          break;
        default: ;
      }
    });
  }

  // move focus from control to links
  Dropdown.moveFocusToLinks = function(e) {
    var self = this;

    var counter = this.links.counter;
    var $links = this.links.$found;

    if ($links) {
      switch (e.which) {
        case dit.constants.key.ESC:
          this.close();
          this.$control.focus();
          break;
        case dit.constants.key.DOWN:
          if (counter < ($links.length - 1)) {
            $links.eq(++counter).focus();
          }
          break;
        case dit.constants.key.UP:
          if (counter > 0) $links.eq(--counter).focus();
          else {
            counter--;
            this.close();
            this.focus();
          }
          break;
        default: ;
      }
    }
    this.links.counter = counter;
  }

  // move focus between links
  Dropdown.moveLinkFocus = function(e) {
    var self = this;

    var counter = this.links.counter;
    var $links = this.links.$found;

    if ($links) {
      switch(e.which) {
        case dit.constants.key.ESC:
          this.close();
          this.$control.focus();
          break;
        case dit.constants.key.DOWN:
          e.preventDefault();
          if (counter < ($links.length - 1)) $links.eq(++counter).focus();
          else {
            $links.eq(0).focus();
            counter = 0;
          }
          break;
        case dit.constants.key.UP:
          e.preventDefault();
          if (counter > 0) $links.eq(--counter).focus();
          else {
            counter--;
            this.close();
            this.$control.focus();
          }
          break;
        default: ;
      }
    }
    this.links.counter = counter;
  }

  // desktop only
  Dropdown.openWithHover = function() {
    var self = this;

    self.$control.add(self.$target).on(self.events.ONMOUSEOVER, function(e) {
      Dropdown.on.call(self);
      self.open();
    });

    self.$control.add(self.$target).on(self.events.ONMOUSEOUT, function() {
      Dropdown.off.call(self);
    });

    self.$control.on(self.events.CLICK, function(e) {
      e.preventDefault();
    });
  }

  Dropdown.openWithClick = function() {
    var self = this;

    self.$control.on(self.events.CLICK, function(e) {
      e.preventDefault();
      Dropdown.on.call(self);
      self.toggle();
    });

    self.$control.on(self.events.BLUR, function() {
      if (self.config.blur) Dropdown.blur.call(self);
    });
  }

  Dropdown.on = function() {
    clearTimeout(this.closerequest);
  }

  Dropdown.off = function() {
    var self = this;
    self.closerequest = setTimeout(function() {
      self.close(true);
    }, 500);
  }

  Dropdown.focus = function() {
    Dropdown.on.call(this);
  }

  Dropdown.blur = function() {
    // disable blur on mobile/tablet
    if (this.config.mode != 'desktop') return;
    if (this.state === 'open') {
      Dropdown.off.call(this);
    }
  }

  // used for click
  Dropdown.prototype.toggle = function() {
    if (this.state != 'open') this.open();
    else this.close();
  }

  Dropdown.prototype.open = function() {
    if (!this._locked && this.state != 'open') {
      this._locked = true;
      this.state = 'open';
      this.$control
        .removeClass('collapsed').addClass('expanded');
      this.$target
        .removeClass('collapsed').addClass('expanded');
      this.$target.attr('aria-expanded', 'true');
      this.$control.attr('aria-expanded', 'true');
      this.links.$found.attr('tabindex', 0);
      this.config.complete.call(this);
      this.config.onOpened.call(this);
      this._locked = false;
    }
  }

  Dropdown.prototype.close = function() {
    if (!this._locked && this.state != 'closed') {
      this._locked = true;
      this.state = 'closed';
      this.$control
        .removeClass('expanded').addClass('collapsed');
      this.$target
        .removeClass('expanded').addClass('collapsed');
      this.$target.attr('aria-expanded', 'false');
      this.$control.attr('aria-expanded', 'false');
      this.config.complete();
      this.config.onClosed.call(this);
      this.links.$found.attr('tabindex', -1);
      this.links.counter = -1; // reset
      this._locked = false;
    }
  }

  Dropdown.prototype.destroy = function() {
    var events = this.events.CLICK + ' ' + this.events.BLUR + ' ' + this.events.FOCUS + ' ' + this.events.KEYDOWN + ' ' + this.events.ONMOUSEOUT + ' ' + this.events.ONMOUSEOVER;

    this.$target.removeClass('collapsed');

    // not mobile view
    if (!this.config.$control) {
      this.$control.off(events);
      this.$control.add(this.$target).off(events);
      this.$control.removeAttr('tabindex');
      this.$control.removeAttr('aria-controls');
      this.$control.removeAttr('aria-hidden');
      this.$control.removeAttr('aria-haspopup');
      this.$control.find('span').unwrap();
    }
    else this.$control.remove();

    this.links.$found.off(events);
    this.links.$found.removeAttr('tabindex');
    this.config.cleanup();
  }
})(jQuery, dit.classes);

/* Class: Tabbed Area
 * -----------------------
 * Class will turn passed node (and specified items) into a Tabbed panel area
 *
 * REQUIRES:
 * jquery
 * dit.js
 * dit.utils.js
 *
 **/

(function($, utils, classes) {

  var CLASS_COMPONENT = "TabbedArea";
  var CLASS_TAB = "TabbedAreaTab";
  var CLASS_PANEL = "TabbedAreaPanel";
  var CLASS_SELECTED = "selected";

  /* Constructor.
   * @$panels (jQuery Object) Collection of elements to become tabbed area panels.
   * @config (Object) Passed configuration.
   *  e.g {
   *    automate: true,
   *    labels: ".titles"
   *  }
   **/
  classes.TabbedArea = TabbedArea;
  function TabbedArea($tabs, $panels, config) {
    var tabbedArea = this;
    var $node;

    // Externally configurable options.
    var options = $.extend({}, {
      start : 0, // initial selected tab.
      $parent: $() // Tabs get placed in the component wrapping $node.
                   // If markup needs to keep tabs wrapped by a single parent element,
                   // specify the parent element around tabs and to maintain your structure.
    }, config);

    if($tabs.length > 0 && $tabs.length == $panels.length) {

      $node = $("<div></div>");
      $node.addClass(CLASS_COMPONENT);

      // Setup tabs and panels
      //
      // 1. Insert component wrapping node.
      // 2. Add each panel element to wrapping node.
      if(config.$parent.length) {
        config.$parent.before($node);
        $node.append(config.$parent);
      }
      else {
        $tabs.eq(0).before($node);
        $node.append($tabs);
      }

      $tabs.each(function(i) {
        var $tab = $(this);
        var $panel = $panels.eq(i);
        $panel.addClass(CLASS_PANEL);
        $tab.addClass(CLASS_TAB);
        $tab.data("number", i);

        $node.append($panel);
      });

      // Add event handlers
      $tabs.on("click", function() {
        tabbedArea.update($(this).data("number"));
      });

      // Add initial selected classes
      $tabs.eq(options.start).addClass(CLASS_SELECTED);
      $panels.eq(options.start).addClass(CLASS_SELECTED);

      // Make sure heights work if panels are position:absolute
      $node.css("padding-bottom", utils.maxHeight($panels, true));

      this.$node = $node;
      this.$tabs = $tabs;
      this.$panels = $panels;
      this.selected = options.start;
    }
  }

  TabbedArea.prototype = {};
  TabbedArea.prototype.update = function(selected) {
    this.$tabs.eq(this.selected).removeClass(CLASS_SELECTED);
    this.$panels.eq(this.selected).removeClass(CLASS_SELECTED);
    this.$tabs.eq(selected).addClass(CLASS_SELECTED);
    this.$panels.eq(selected).addClass(CLASS_SELECTED);
    this.selected = selected;
  }

  TabbedArea.prototype.destroy = function() {
    this.$tabs.removeClass(CLASS_TAB);
    this.$tabs.removeClass(CLASS_SELECTED);
    this.$panels.removeClass(CLASS_PANEL);
    this.$panels.removeClass(CLASS_SELECTED);
    this.$node.removeClass(CLASS_COMPONENT);
    this.$node.style.paddingBottom = "";
  }

})(jQuery, dit.utils, dit.classes);

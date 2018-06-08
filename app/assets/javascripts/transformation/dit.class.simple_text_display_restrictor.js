/* Class: SimpleTextDisplayRestrictor
 * ----------------------------------
 * Limits the view of (non-HTML) text content, adding a 'Read more' type of link which, 
 * when clicked, will replace the clipped text, added elipsis, and link, with the original
 * full text. The link is not a toggle but a non-reversable reveal.
 *
 *
 * REQUIRES:
 * jquery
 * dit.js
 * dit.utils.js
 * dit.classes.js
 *
 **/
(function($, utils, classes) {

  var EFFECT = "SimpleTextDisplayRestrictor";

  /* Main Class
   * @$target (jQuery node) Input or TextArea element and source of data
   * @limit (Number) Integer word limit
   * @options (Object) Optional configurations
   **/
  classes.SimpleTextDisplayRestrictor = SimpleTextDisplayRestrictor;
  function SimpleTextDisplayRestrictor($target, limit, options) {
    var text = $target.text().trim().replace(/\s+/mig, " ");
    var words = text.split(" ");
    var id = utils.generateUniqueStr(EFFECT + "_");
    var config = $.extend({
      label: "Read more", // Control button text.
    }, options);

    var $control;

    if (arguments.length > 1 && $target.length && words.length > limit) {
      $target.text(words.slice(0, limit).join(" ") + "... ");
      $target.attr("id", $target.attr("id") || id); // Make sure has an ID
      $control = SimpleTextDisplayRestrictor.createControl.call(this, id, config.label);
      $control.data("fulltext", text);
      $target.attr("aria-live", "assertive");
      $target.append($control);
    }

    this.$target = $target;
  }

  SimpleTextDisplayRestrictor.createControl = function(id, text) {
    var $control = $(document.createElement("button"));
    $control.addClass(EFFECT);
    $control.attr("aria-controls", id);
    $control.text(text);
    $control.one("click", function() {
      var fulltext = $control.data("fulltext");
      var $parent = $control.parent();
      $parent.empty();
      $parent.text(fulltext);
    });
    return $control;
  }

})(jQuery, dit.utils, dit.classes);

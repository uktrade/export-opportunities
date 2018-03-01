/* Class: RestrictedInput
 * --------------------------------
 * Adds an input limit message after an Input or Textarea field, that
 * counts down remaining characters until the maximum is reached.
 *
 * REQUIRES:
 * jquery
 * dit.js
 * dit.utils.js
 *
 **/
(function($, utils, classes) {

  /* Main Class
   * @$target (jQuery node) Input or TextArea element and source of data
   * @options (Object) Optional configurations
   **/
  classes.RestrictedInput = RestrictedInput;
  function RestrictedInput($target, options) {
    var opts = $.extend({
      max: 80,
      message: "characters remaining"
    }, options);

    var $remaining = $(document.createElement("span"));
    var $message = $(document.createElement("p"));
    
    $target.bind("keyup", function() {
      var remaining = opts.max - this.value.length;
      if(remaining <= 0) {
        this.value = this.value.substr(0, opts.max);
      }

      $remaining.text(opts.max - this.value.length);
    });

    $remaining.text(opts.max);
    $message.text(" " + opts.message);
    $message.prepend($remaining);
    $target.after($message);

  }

})(jQuery, dit.utils, dit.classes);

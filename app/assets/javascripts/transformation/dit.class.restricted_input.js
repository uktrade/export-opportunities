/* Class: RestrictedInput
 * --------------------------------
 * Adds an input limit message after an Input or Textarea field, that
 * counts down remaining characters until the maximum is reached.
 * Maximum character limit is specified by the maxlength attribute.
 *
 * USES:
 * jquery...min.js
 * dit.js
 *
 **/
(function($, classes) {

  /* Main Class
   * @$target (jQuery node) Input or TextArea element and source of data
   * @options (Object) Optional configurations
   **/
  classes.RestrictedInput = RestrictedInput;
  function RestrictedInput($target) {
    var $remaining = $(document.createElement("span"));
    var $message = $(document.createElement("p"));
    var text = "characters remaining";
    var max = 0;

    if($target.length) {
      max = $target.attr("maxlength");

      $target.on("input", function() {
        var remaining = max - this.value.length;
        if(remaining <= 0) {
          this.value = this.value.substr(0, max);
        }
        $remaining.text(max - this.value.length);
      });

      $remaining.text(max - $target.val().length);
      $message.addClass("RestrictedInputCount");
      $message.text(" " + text);
      $message.prepend($remaining);
      $target.after($message);
    }
  }
})(jQuery, dit.classes);

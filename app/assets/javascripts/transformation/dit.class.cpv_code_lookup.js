/* Class: CpvCodeLookup
 * --------------------------------
 * Extends SelectiveLookup to perform specific requirements for
 * Cpv code search by text and, resulting form field population.
 *
 * REQUIRES:
 * jquery
 * dit.js
 * dit.utils.js
 * dit.class.selective-lookup.js
 *
 **/
(function($, utils, classes) {

  var SelectiveLookup = classes.SelectiveLookup;

  /* Main Class
   * @$input (jQuery node) Existing form input element to populate with cpv code
   **/
  classes.CpvCodeLookup = CpvCodeLookup;
  function CpvCodeLookup($input, service, options) {
    var instance = this;
    var id = $input.attr('id') || utils.generateUniqueStr("_");
    var $clear = $("<button class=\"CpvCodeLookupClear\">Clear value</button>");
    var opts = $.extend({
      addButtonCssCls: "", // Should you want to add something for CSS.
      name: "", // Pass in a custom field name if you $input.name not wanted.
      placeholder: "Find CPV code", // For altered visible form field.
      supportMultilineInputs: true
    }, options || {});

    if($input.length) {
      if(opts.supportMultilineInputs) {
        $input = CpvCodeLookup.convertToTextarea($input);
        CpvCodeLookup.setTextareaHeight($input)
      }

      $input.addClass("CpvCodeLookup");
      $input.attr("id", id);
      $input.attr("name", opts.name || $input.attr("name"));
      $input.attr("placeholder", opts.placeholder);

      $input.on("keydown.CpvCodeLookup", function(event, clearInput) {
        // Handle specific keys.
        switch(event.which) {
          case 27: // Esc
          case 8: // Backspace
            clearInput = true;
            break;
          default: // Nothing to do.
        }

        if(clearInput) {
          $input.val("");
          $input.focus();
          CpvCodeLookup.setTextareaHeight($input)
        }
      });

      // Add a clearing button to make the UI more obvious.
      $clear.attr("aria-controls", id);
      $input.after($clear);
      $clear.on("click.CpvCodeLookup", function(event) {
        event.preventDefault();
        $input.trigger("keydown.CpvCodeLookup", true);
      });

      // Inherit...
      SelectiveLookup.call(this, $input, service, opts);
      this._private.$list.addClass("CpvCodeLookupDisplay");

      // Some inner variable requirement.
      this._private.param = opts.param;
    }
  }
  
  /* Sometimes the populating value might be more than
   * one line in length so it might be preferable to
   * use a <textarea> element instead. Code will handle
   * whether it should try to display as a single line
   * input[type=text] element, or expaned to meet the
   * populating content length.
   * $field (jQuery element) HTML form input to convert to textarea
   **/
  CpvCodeLookup.convertToTextarea = function($field) {
    var $textarea = $field;
    if($field.get(0).nodeName.toLowerCase() != "textarea") {
      $textarea = $("<textarea></textarea>");
      $textarea.attr("name", $field.attr("name"));
      $textarea.val($field.val());
      $field.before($textarea);
      $field.remove();
      CpvCodeLookup.setTextareaHeight($textarea); // Has to go after $textarea has been added to get right CSS.
    }
    return $textarea;
  }

  /* Calculate how much height we need to set on a textarea
   * 1. Set a hidden <p> element.
   * 2. Populate with textarea value.
   * 3. Set the height of textarea to match <p>.
   * 4. Remove <p> to cleanup.
   *
   * $field (jQuery element) HTML textarea to affect
   **/
  CpvCodeLookup.setTextareaHeight = function($field) {
    var $p;
    if($field.get(0).nodeName.toLowerCase() == "textarea") {
      $p = $("<p></p>");
      $p.text($field.val() || "&nbps;"); // Require something to at least get a single line
      $p.css({
        position: "absolute",
        visibility: "hidden",
        width: $field.width()
      });

      $field.before($p);
      $field.height($p.height());
      $p.remove();
    }
  }

  /* Testing saw this data:
   * code: "021099900080"
   * description: "Edible flours and meals of meat or meat offal"
   * english_text: "Edible flours and meals of meat or meat offal..."
   *
   * This caused output with duplicated text, so createDescriptionText()
   * will run things through duplicatedText() to improve things. 
   *
   * We also saw this data (but could not easily fix it):
   * code: "160290510080"
   * description: "Containing meat or meat offal of domestic swine"
   * english_text: "Prepared or preserved meat or meat offal containing meat or offal of domestic swine"
   *
   * This causes lengthy output of...
   * 160290510080: Containing meat or meat offal of domestic swine - Prepared or preserved meat or meat offal containing meat or offal of domestic swine
   *
   * ...but we're stuck with it due to extra 'meat' word in description causing a match failure.
   *
   * @str1 (String) data['description']
   * @str2 (String) data['english_text']
   **/
  CpvCodeLookup.createDescriptionText = function(str1, str2) {
    var descriptions = [];
    var str1HasDuplicateText;
    var str2HasDuplicateText;
    str1 = CpvCodeLookup.cleanString(str1);
    str2 = CpvCodeLookup.cleanString(str2);

    // If str1 and str2 are the same, just add str1
    if(str1 == str2) {
      descriptions.push(str1);
    }
    else {
      // Add str1 if does not duplicate anything in str2
      if(!CpvCodeLookup.duplicatedText(str2, str1)) {
        descriptions.push(str1);
      }

      // Add str2 if does not duplicate anything in str1
      if(!CpvCodeLookup.duplicatedText(str1, str2)) {
        descriptions.push(str2);
      }
    }

    return descriptions.join(" - ");
  }

  /* Return cleaned data string (from CPV information).
   * - Strips out double-quote marks (which seem to break the JSON handling).
   * - Reduces multiple hyphens to a single.
   * - Trims strings.
   * - Trims leading hyphens.
   * - Set to lower case.
   * - Initialize first character.
   **/
  CpvCodeLookup.cleanString = function(str) {
    str = str.replace(/\"/g, "");
    str = str.replace(/[-]+/, "-");
    str = str.replace(/[\s-]*(.*)[\s]*/, "$1");
    str = str.toLowerCase();
    str = str.charAt(0).toUpperCase() + str.slice(1);
    return str;
  }

  /* Checks to see if one string is found in another.
   * Handles exact matches only, not similar strings.
   * Return true if str2 is found in str1.
   *
   * e.g.
   *
   * str1 = "This is a string with some text"
   * str2 = "String with some text"
   * Returns true
   *
   * str1 = "This is a string with some text"
   * str2 = "String with some random text"
   * Returns false
   *
   * @str1 (String) String that is searched.
   * @str2 (String) String to search for in str1.
   **/
  CpvCodeLookup.duplicatedText = function(str1, str2) {
    // First a little custom clean up after noticing some strings
    // were only different by inclusion of parenthesis.
    str1 = str1.replace(/[\(\)]/, "");
    str2 = str2.replace(/[\(\)]/, "");

    // Is str2 found in str1
    return str1.toLowerCase().indexOf(str2.toLowerCase()) >= 0;
  }

  /* Testing saw data like this:
   * code               = "220430100080"
   * description        = "In fermentation or with fermentation arrested..."
   * english_text       = "Grape must"
   * parent_description = "Grape must"
   * This resulted in display output like this:
   *
   * Grape must
   * 220430100080 Grape must - In fermentation or with fermentation arrested...
   *
   * So we want to try and avoid parent text duplication in this situation.
   *
   * @description (String) Prepared description from createDescriptionText()
   * @text (String) the value of parent_description from data.
   **/
  CpvCodeLookup.parentDescription = function(description, text) {
    var parentDescription = "";
    text = CpvCodeLookup.cleanString(text);
    if(!CpvCodeLookup.duplicatedText(description, text)) {
      parentDescription = "<span>" + text + "</span>"; // Not elegant but should work.
    }
    return parentDescription;
  }

  CpvCodeLookup.prototype = new SelectiveLookup;

  // Overwrite inherited.
  CpvCodeLookup.prototype.bindContentEvents = function() {
    var instance = this;
    instance._private.$list.off("click.SelectiveLookupContent");
    instance._private.$list.on("click.CpvCodeLookup", "li", function(event) {
      var _p = instance._private;
      var $this = $(this);
      var value = $this.attr("data-value");
      var text = $this.text();
      _p.$input.val(value);
      CpvCodeLookup.setTextareaHeight(_p.$input);
    });
  }

  // Overwrite inherited.
  CpvCodeLookup.prototype.param = function() {
    return this._private.param + this._private.$input.val();
  }

  /* Overwrite inherited.
   * Note: Have not bothered with opts.datamapping because we can
   *       simply change right here in this function. Code here is
   *       heavily tied in with data from the specific service.
   *       Be prepared to change it if data format changes.
   *
   * data (Object) Retreived json data converted to object form.
   **/
  CpvCodeLookup.prototype.processWithDataMapping = function(data) {
    var description = CpvCodeLookup.createDescriptionText(data["english_text"], data["description"]);
    var parentDescription = CpvCodeLookup.parentDescription(description, data["parent_description"]);
    var code = data["code"];
    return {
      value: code + ": " + description,
      text: parentDescription + code + ": " + description
    }
  }

})(jQuery, dit.utils, dit.classes);

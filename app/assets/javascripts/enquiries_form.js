(function() {
  "use strict";

  function renderResults(data) {
    $("#ch_search-results ul").empty();
    if (data.length < 1) {
      handleNoResult();
    }
    for(var i = 0; i < data.length; i++) {
      var item = data[i];
      $("#ch_search-results ul").show();
      var html = $('<li class="companieshouse-result"><a href="#"' +
        'data-number="' + item.number + '" data-postcode="' + item.postcode +
        '" class="companieshouse-resultlink">' + item.name + '</a> ' +
        '<a href="https://beta.companieshouse.gov.uk/company/' + item.number +
        '" class="companieshouse-extlink" target="_blank" title="Opens in a new window" rel="external"' +
        '><small>(View on Companies House website)</small>' +
        '</a></li>');
        html.appendTo($("#ch_search-results ul"));
    }
    bindResultsEvents();
  }

  function handleNoResult(data) {
    $("#ch_search-results ul").show();
    var html = $('<li class="companieshouse-result">No results found. <br>If you don\'t have a Companies House Number, choose the <strong>\"I don\'t have a Companies House Number\"</strong> option below and enter the company address.</li>');
        html.appendTo($("#ch_search-results ul"));
  }

  function bindResultsEvents() {
    $("a.companieshouse-resultlink").bind('click', function(event) {
      $("#enquiry_company_name").val($(event.target).text());
      $("#enquiry_company_house_number").val($(event.target).attr("data-number"));
      $("#enquiry_company_postcode").val($(event.target).attr("data-postcode"));

      $("#ch_search-results ul").hide();
      $("#no-companies-house-number-fields").show();
      $("#company_house_number").show();
      event.preventDefault();
      event.stopPropagation();
    });
  }

  function noCHnumberSetup() {
    $("#no-companies-house-number-fields").hide();
    $("#companies-house-section").append($('<label for="no-companies-house-number" class="no-companies-house-number">' +
      '<input type="checkbox" id="no-companies-house-number" />' +
      'I don\'t have a Companies House Number</label>'));

    $("#no-companies-house-number").bind('click', function() {
      var checkbox = $(this);
      if (checkbox.is(':checked')) {
        checkbox.attr('disabled', true);
        $("#no-companies-house-number-fields").show();
        $("#company_house_number").hide();
        $("#enquiry_company_house_number").prop('val', '');

        $("#ch_search").fadeOut();
        $("#ch_search-results:visible .companies-house-list").slideUp(
          400,
          function () {
            checkbox.attr('disabled', false);
          }
        );
      } else {
        $("#company_house_number").show();
        $("#no-companies-house-number-fields").hide();
        $("#ch_search").show();
        $(".companies-house-list").show();
      }
    });
  }

  /* Class: RestrictedInput
   * --------------------------------
   * Adds an input limit message after an Input or Textarea field, that
   * counts down remaining characters until the maximum is reached.
   * Maximum character limit is specified by the maxlength attribute.
   **/
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

      $remaining.text(max);
      $message.text(" " + text);
      $message.prepend($remaining);
      $target.after($message);
    }
  }

  $('document').ready(function() {
    new RestrictedInput($("#enquiry_company_explanation"));

    // Only when Companies House search field present
    if ($("#ch_search").length) {
      noCHnumberSetup();

      $("#enquiry_company_name").bind('keypress', function(event) {
        var key = event.which || event.keyCode;
        if (key == 13) {
          $("#ch_search").click();
          event.stopPropagation();
          event.preventDefault();
        }
      });

      $("#ch_search").bind('click', function(event) {
        $("#enquiry_company_name").addClass('isLoading');
        $.get({
          url: "/company_details",
          data: {
            search: $("#enquiry_company_name").val(),
          },
          success: function(data) { renderResults(data); },
          complete: function () {
            $("#enquiry_company_name").removeClass('isLoading');
          }
        });
        event.preventDefault();
        event.stopPropagation();
      });
    }
  });

  $('#new_enquiry').bind('ajax:aborted:required', function() {
    // jquery-ujs will fire this event when a form with "required" attrs
    // that are blank tries to submit, because if that happens it means
    // the browser doesn't support the "required" attr.

    // We can validate everything on the server side so we return false
    // here to allow the form to submit.
    return false;
  });

  // Hack to force Safari to submit, to get around browser incompatibility
  // with the HTML5 Validation API. -TM
  var isSafari = navigator.vendor && navigator.vendor.indexOf('Apple') > -1 &&
               navigator.userAgent && !navigator.userAgent.match('CriOS');

  if (isSafari) {
    $("form#new_enquiry input[type='submit']").bind('click', function(event) {
      this.form.submit();
    });
  }
})();

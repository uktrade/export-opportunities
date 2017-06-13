
var ukti = window.ukti || {};

ukti.enquiryResponse = (function($) {
  'use strict';

  var initTextEditor = function () {
    CKEDITOR.replace('enquiry_response_email_body');
  };

  var loadTextEditorScript = function () {
    if (ukti.config.ckeditorPath) {
        ukti.asyncLoad.init(ukti.config.ckeditorPath, initTextEditor);
    }
  };

  var init = function ($form) {
    loadTextEditorScript();
  };

  return {
    init: init
  };

})();
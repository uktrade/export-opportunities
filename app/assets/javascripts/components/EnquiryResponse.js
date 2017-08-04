
var ukti = window.ukti || {};

ukti.enquiryResponse = (function($) {
  'use strict';

  var initTextEditor = function () {
    CKEDITOR.replace( 'enquiry_response_email_body');
  };

  var initUploadWidget = function () {
    var els = document.querySelectorAll('.uploadWidget'), i;
    for (i = 0; i < els.length; ++i) {
      ukti.UploadWidget.init(els[i]);
    }
  }

  var loadTextEditorScript = function () {
    if (ukti.config.ckeditorPath) {
        ukti.asyncLoad.init(ukti.config.ckeditorPath, initTextEditor);
    }
  };

  var init = function ($form) {
    loadTextEditorScript();
    initUploadWidget();
  };

  return {
    init: init
  };

})();
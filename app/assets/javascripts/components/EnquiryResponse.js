
var ukti = window.ukti || {};

ukti.enquiryResponse = (function($) {
  'use strict';

  var initTextEditor = function () {
    CKEDITOR.on('instanceReady', function(evt) {
      var editor = evt.editor;
      console.log('The editor named ' + editor.name + ' is now ready');
      editor.on('focus', function(e) {
        console.log('The editor named ' + e.editor.name + ' is now focused');
      });
      editor.on('blur', function(e) {
        console.log('The editor named ' + e.editor.name + ' is now blurred');
      });
    });
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
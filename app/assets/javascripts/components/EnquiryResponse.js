/* globals CKEDITOR */
var ukti = window.ukti || {};

ukti.enquiryResponse = (function($) {
  'use strict';

  var focusOutlineClassname = 'focus-outline';

  var initTextEditor = function () {
    CKEDITOR.timestamp = Math.random();
    CKEDITOR.on('instanceReady', function(evt) {
      var editor = evt.editor;
      editor.on('focus', function(event) {
        event.editor.container.$.classList.add(focusOutlineClassname);
      });
      editor.on('blur', function(event) {
        event.editor.container.$.classList.remove(focusOutlineClassname);
      });
    });
    CKEDITOR.replace( 'enquiry_response_email_body');
  };

  var initToggleFieldEdit = function () {
    var els = document.querySelectorAll('.js-toggle-field-edit'), i;
    for (i = 0; i < els.length; ++i) {
      ukti.ToggleFieldEdit.init(els[i]);
    }
  };

  var initUploadWidget = function () {
    var els = document.querySelectorAll('.uploadWidget'), i;
    for (i = 0; i < els.length; ++i) {
      ukti.UploadWidget.init(els[i]);
    }
  };

  var loadTextEditorScript = function () {
    if (ukti.config.ckeditorPath) {
      ukti.asyncLoad.init(ukti.config.ckeditorPath, initTextEditor);
    }
  };

  var init = function ($form) {
    loadTextEditorScript();
    initToggleFieldEdit();
    initUploadWidget();
  };

  return {
    init: init
  };

})();
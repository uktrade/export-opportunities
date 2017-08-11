/* globals CKEDITOR */
var ukti = window.ukti || {};

ukti.EnquiryResponse = (function($) {
  'use strict';

  var baseEl,
      focusOutlineClassname = 'focus-outline';

  var tabsCallback = function (tab) {
    if (!tab) {
      return;
    }
    if (tab[0].htmlFor === 'response_type_4' || tab[0].htmlFor === 'response_type_5') {
      document.getElementById('custom-response').classList.add('hidden');
      document.getElementById('signature').classList.add('hidden');
      document.getElementById('attachments').classList.add('hidden');
      updateSubmitButton('Send');
    } else {
      document.getElementById('custom-response').classList.remove('hidden');
      document.getElementById('signature').classList.remove('hidden');
      document.getElementById('attachments').classList.remove('hidden');
      updateSubmitButton('Preview');
    }
  };

  var updateSubmitButton = function (text) {
    var button = baseEl.querySelector('input[type=submit]');
    button.value = text;
  };

  var initTabs = function () {
    var el = document.querySelector('.js-tabs');
    ukti.Tabs.init(el, tabsCallback);
  };

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

  var init = function (form) {
    baseEl = form;
    initTabs();
    loadTextEditorScript();
    initToggleFieldEdit();
    initUploadWidget();
  };

  return {
    init: init
  };

})();
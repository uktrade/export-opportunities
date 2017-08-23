/* globals CKEDITOR */
var ukti = window.ukti || {};

ukti.EnquiryResponse = (function($) {
  'use strict';

  var baseEl,
      focusOutlineClassname = 'focus-outline';

  var config = {
    errorMessages : {
      'comment': 'You need at least 30 characters in your reply.',
      'signature': 'You must enter a signature.'
    }
  };

  var tabsCallback = function (tab) {
    if (!tab) {
      return;
    }
    if (tab[0].htmlFor === 'response_type_4' || tab[0].htmlFor === 'response_type_5') {
      document.getElementById('custom-response').classList.add('hidden');
      document.getElementById('signature').classList.add('hidden');
      document.getElementById('attachments').classList.add('hidden');
      updateSubmitButton('Send');
    } else if (tab[0].htmlFor === 'response_type_3') {
      document.getElementById('custom-response').classList.remove('hidden');
      document.getElementById('signature').classList.add('hidden');
      document.getElementById('attachments').classList.add('hidden');
      updateSubmitButton('Preview');
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
    CKEDITOR.stylesSet.add('mystyles', [
        // Block-level styles
        { name: 'Heading 1', element: 'h1'},
        { name: 'Heading 2', element: 'h2'},
        { name: 'Heading 3', element: 'h3'},
        { name: 'Introduction', element: 'p', attributes: { 'class': 'introduction'} },

        // Inline styles
        { name: 'Link button', element: 'a', attributes: { 'class': 'button' } },
        { name: 'List', element: 'ul', attributes: { 'class': 'list list-bullet' } },

        // Object styles
        { name: 'Stretch', element: 'img', attributes: { 'class': 'stretch' } },
    ]);
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

  var formSubmitHandler = function (event) {
    debugger;
    var errors = [];
    if ( isSignatureRequired() && isSignatureInvalid() ) {
      ukti.Forms.addErrorToField(baseEl.elements['enquiry_response[signature]'], config.errorMessages.signature);
      errors.push(config.errorMessages.signature);
    }

    if ( isCommentRequired() && isCommentInvalid() ) {
      ukti.Forms.addErrorToField(baseEl.elements['enquiry_response[email_body]'], config.errorMessages.comment);
      errors.push(config.errorMessages.comment);
    }

    if (errors.length) {
      event.preventDefault();
      // add summary
      return false;
    }
    else {
      return true;
    }
  };

  var isSignatureRequired = function () {
    var response_type = baseEl.elements['enquiry_response[response_type]'].value;
    return (response_type === "1" || response_type === "2");
  };

  var isSignatureInvalid = function () {
    var value = baseEl.elements['enquiry_response[signature]'].value;
    return ukti.Utilities.isValueEmpty(value);
  };

  var isCommentRequired = function () {
    var response_type = baseEl.elements['enquiry_response[response_type]'].value;
    return (response_type === "1" || response_type === "2" || response_type === "3");
  };

  var isCommentInvalid = function () {
    var value = baseEl.elements['enquiry_response[email_body]'].value;
    return ukti.Utilities.isValueEmpty(value);
  };

  var initValidation = function () {
    baseEl.addEventListener('submit', formSubmitHandler);
  };

  var init = function (form) {
    baseEl = form;
    initTabs();
    loadTextEditorScript();
    initToggleFieldEdit();
    initUploadWidget();
    initValidation();
    ukti.Forms.clearErrorsFromFields();
  };

  return {
    init: init
  };

})();
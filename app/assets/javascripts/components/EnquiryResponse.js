
var ukti = window.ukti || {};

ukti.enquiryResponse = (function($) {
  'use strict';

  var initTextEditor = function () {
    window.tinymce.dom.Event.domLoaded = true;
    tinymce.init({
      mode : 'exact',
      document_base_url: '/js/tinymce',
      strict_loading_mode : true,
      selector: '.js-text-editor',
      height: 500,
      menubar: false,
      toolbar: 'undo redo | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image',
      content_css: 'http://www.tinymce.com/css/codepen.min.css',
      branding: false
    });
  };
  var initTextEditor2 = function () {
    CKEDITOR.replace( 'enquiry_response_email_body');
  };

  var loadTextEditorScript = function () {
    if (ukti.config.tinyMcePath) {
        ukti.asyncLoad.init(ukti.config.tinyMcePath, initTextEditor);
    }
  };

  var loadTextEditorScript2 = function () {
    if (ukti.config.ckeditorPath) {
        ukti.asyncLoad.init(ukti.config.ckeditorPath, initTextEditor2);
    }
  };

  var init = function ($form) {
    loadTextEditorScript2();
  };

  return {
    init: init
  };

})();
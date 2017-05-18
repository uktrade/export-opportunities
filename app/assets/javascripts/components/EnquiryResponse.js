
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
    window.CKEDITOR_BASEPATH = '/ckeditor/';
    CKEDITOR.replace( 'enquiry_response_email_body', {
      height: 260,
      /* Default CKEditor styles are included as well to avoid copying default styles. */
      contentsCss: [ 'http://cdn.ckeditor.com/4.6.2/full-all/contents.css', 'http://sdk.ckeditor.com/samples/assets/css/classic.css' ]
    });
  };

  var loadTextEditorScript = function () {
    if (ukti.config.tinyMcePath) {
        ukti.asyncLoad.init(ukti.config.tinyMcePath, initTextEditor);
    }
  };

  var loadTextEditorScript2 = function () {
    if (ukti.config.textEditorScriptPath) {
        ukti.asyncLoad.init(ukti.config.textEditorScriptPath, initTextEditor2);
    }
  };

  var init = function ($form) {
    loadTextEditorScript();
    //initTextEditor();
  };

  return {
    init: init
  };

})();
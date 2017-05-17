
var ukti = window.ukti || {};

ukti.enquiryResponse = (function($) {
  'use strict';

  var initTextEditor = function () {
    //window.tinymce.dom.Event.domLoaded = true;
    tinymce.init({
      selector: '.js-text-editor',
      height: 500,
      menubar: false,
      toolbar: 'undo redo | insert | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image',
      content_css: 'http://www.tinymce.com/css/codepen.min.css'
    });
  };

  var loadTextEditorScript = function () {
    if (ukti.config.tinyMcePath) {
      ukti.asyncLoad.init(ukti.config.tinyMcePath, initTextEditor);
    }
  };

  var init = function ($form) {
    loadTextEditorScript();
  };

  return {
    init: init
  };

})();

var ukti = window.ukti || {};

ukti.enquiryResponse = (function($) {
  'use strict';

  var augmentTextField = function (form) {
  	

  	window.tinymce.dom.Event.domLoaded = true;
	tinymce.init({
	  selector: 'textarea',
	  height: 500,
	  menubar: false,
	  plugins: [
	    'advlist autolink lists link image charmap print preview anchor',
	    'searchreplace visualblocks code fullscreen',
	    'insertdatetime media table contextmenu paste code'
	  ],
	  toolbar: 'undo redo | insert | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image',
	  content_css: 'http://www.tinymce.com/css/codepen.min.css'
	});
  };

  var init = function ($form) {
	//ukti.asyncLoad('tinymce', 'cb');
  };

  return {
    init: init
  };

})();
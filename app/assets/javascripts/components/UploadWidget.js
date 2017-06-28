var ukti = window.ukti || {};

ukti.UploadWidget = (function($) {
  'use strict';

  var changeHandler = function(event) {
    updateLabel(event);
  };

  var updateLabel = function (event) {
  	var input = event.currentTarget,
			  label = input.nextElementSibling,
		 labelVal = label.innerHTML,
		 fileName = '';
		if( input.files && input.files.length > 1 ) {
			fileName = ( input.getAttribute( 'data-multiple-caption' ) || '' ).replace( '{count}', input.files.length );
		}
		else {
			fileName = input.value.split( '\\' ).pop();
		}

		if( fileName ) {
			label.querySelector( 'span' ).innerHTML = fileName;
		}
		else {
			label.innerHTML = labelVal;	
		}
  };

  var attachBehaviour = function () {
		var inputs = document.querySelectorAll( '.inputfile' );
		Array.prototype.forEach.call( inputs, function( input ) {
			input.addEventListener( 'change', changeHandler);
		});
  };

  var init = function () {
    attachBehaviour();
  };

  return {
    init: init
  };

})();


var ukti = window.ukti || {};

ukti.UploadWidget = (function($) {
  'use strict';
  var baseEl;
  var fileListStore = [];

  var changeHandler = function(event) {
  	fileListStore = event.currentTarget.files;
    updateLabel(event);
    updateFileList();
  };

  var updateLabel = function (event) {
  	var input = event.currentTarget,
			  label = input.nextElementSibling,
		 labelVal = label.innerHTML,
		 fileName = '';

		if( fileListStore.length > 1 ) {
			fileName = ( input.getAttribute( 'data-multiple-caption' ) || '' ).replace( '{count}', fileListStore.length );
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

  var updateFileList = function () {
		var list = baseEl.querySelector('.fileList');
		if(!list) {
			return;
		}
		while (list.hasChildNodes()) {
			list.removeChild(list.firstChild);
		}

		for (var x = 0; x < fileListStore.length; x++) {
			var li = document.createElement('li');
			li.innerHTML = 'File ' + (x + 1) + ':  ' + fileListStore[x].name;
			list.appendChild(li);
		}
  }

  var resetLabel = function () {

  }

  var resetFileList = function () {
  	
  }

  var attachBehaviour = function () {
		var inputs = baseEl.querySelectorAll( '.inputfile' );
		Array.prototype.forEach.call( inputs, function( input ) {
			input.addEventListener( 'change', changeHandler);
		});
  };

  var init = function (el) {
  	baseEl = el;
    attachBehaviour();
  };

  return {
    init: init
  };

})();


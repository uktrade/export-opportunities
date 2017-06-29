var ukti = window.ukti || {};

ukti.UploadWidget = (function($) {
  'use strict';
  var baseEl;
  var inputEl;
  var clearButtonEl;
  var fileListStore = [];
  var maxFiles = 5;
  var error = {
  	name: 'filelistsize',
  	message: 'Too many filez'
  }

  var changeHandler = function(event) {
  	fileListStore = event.currentTarget.files;
  	if( fileListStore.length > 5 ) {
  		showError(error);
  		return
  	}
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

  var clearFileList = function (event) {
  	event.preventDefault();
  	debugger;
  	inputEl
    var backupElem = inputEl.cloneNode(true);
// Your tinkering with the original
	inputEl.parentNode.replaceChild(backupElem, inputEl);
  	//inputEl.reset();
  	backupElem
  }

  var attachBehaviour = function () {
	inputEl.addEventListener( 'change', changeHandler);
	clearButtonEl.addEventListener("click", clearFileList);
  };

  var addListenerToInput = function (el) {
	el.addEventListener( 'change', changeHandler);
  };

  var removeListenerFromInput = function (el) {
	el.addEventListener( 'change', changeHandler);
  };

  var showError = function () {
	var message = '<span class="error-message" id="error-message-' + error.name + '">' + error.message + '</span>';

    if (fnOptions.announce) {
      message.attr('role', 'alert')
    }

	var formGroup = $(target).closest('.form-group')
	formGroup.addClass('form-group-error')

    // Link the form field to the error message with an aria attribute
	target.attr('aria-describedby', 'error-message-' + error.name)
  }

  var init = function (el) {
  	baseEl = el;
  	inputEl = baseEl.querySelector( '.inputfile' );
  	clearButtonEl = baseEl.querySelector('.js-clearFileList');
    attachBehaviour();
  };

  return {
    init: init
  };

})($);


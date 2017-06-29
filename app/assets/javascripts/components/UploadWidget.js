var ukti = window.ukti || {};

ukti.UploadWidget = (function($) {
  'use strict';
  var baseEl;
  var inputEl;
  var clearButtonEl;
  var fileListStore = [];
  var maxFiles = 1;
  var error = {
  	name: 'filelistsize',
  	message: 'Too many filez'
  }

  var changeHandler = function(event) {
  	fileListStore = event.target.files;
	if (fileListStore.length === 0 ) {
		resetAll(event);
		return;
	}
  	if( fileListStore.length > maxFiles ) {
  		showError(error);
  		return;
  	}
    updateLabel(event);
    updateFileList();
  };

  var updateLabel = function (event) {
  	var input = event.target,
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

  var resetAll = function () {
	var input = event.target,
		label = input.nextElementSibling,
		 list = baseEl.querySelector('.fileList');
  	resetLabel(label);
  	resetList(list);
  }

  var resetLabel = function (label) {
	var text = label.getAttribute( 'data-default-text' );
	label.querySelector( 'span' ).innerHTML = text;
  }

  var resetList = function (list) {
	var text = list.getAttribute( 'data-default-item' );
	while (list.hasChildNodes()) {
		list.removeChild(list.firstChild);
	}
	var li = document.createElement('li');
	li.innerHTML = text;
	list.appendChild(li);
  }

  var clearFileQueue = function (event) {
  	event.preventDefault();
  	inputEl = baseEl.querySelector( '.inputfile' );
  	inputEl.value = "";
  	var changeEvent = document.createEvent("UIEvents");
	changeEvent.initUIEvent("change", true, true);
  	inputEl.dispatchEvent(changeEvent);
  }

  var attachBehaviour = function () {
	baseEl.addEventListener( 'change', changeHandler);
	clearButtonEl.addEventListener("click", clearFileQueue);
  };

  var returnErrorNode = function () {
	var errorNode = document.createElement('span');
	errorNode.className = 'error-message'
	errorNode.id = 'error-message-' + error.name;
	errorNode.innerHTML = error.message;
	//role="alert"
	return errorNode;
  }

  var showError = function () {
  	inputEl = baseEl.querySelector( '.inputfile' );
  	var parentNode = inputEl.parentNode;
	/* add error class */
	var formGroup = event.target.closest('.form-group');
	formGroup.classList.add('form-group-error');
	/* inject error message  */
	var errorNode = returnErrorNode();
	parentNode.insertBefore(errorNode, inputEl);
  }

  var clearError = function () {
  	// .error-message remove
	var formGroup = event.target.closest('.form-group');
	formGroup.classList.remove('form-group-error');
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


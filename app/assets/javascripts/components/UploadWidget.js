var ukti = window.ukti || {};

ukti.UploadWidget = (function($) {
  'use strict';

  var baseEl,
      fileInputEl,
      fileListEl,
      labelEl,
      fileListStore = [];

  var dummyError = {
    responseText: '{ "id":"5d6s6d5sd6sd", "filename":"filename.pdf", "base_url":"http://localhits/"}'
  };

  var cacheElements = function () {
    fileInputEl = baseEl.querySelector( '.inputfile' );
    fileListEl = baseEl.querySelector( '.fileList' );
    labelEl = baseEl.querySelector( 'label' );
  };

  var changeHandler = function(event) {
    /* TODO - check if file selected */
  	uploadFile();
  };

  var addLoadingClass = function(event) {
    labelEl.classList.add('isLoading');
  };

  var removeLoadingClass = function(event) {
    labelEl.classList.remove('isLoading');
  };

  var handleFileListClick = function (event) {
    if(event.target.tagName.toLowerCase() === 'a') {
      event.preventDefault();
      var index = event.target.href;
      removeFromFileStore(index);
      renderFileList();
    }
  };

  var renderFileList = function () {
		if(!fileListEl || fileListStore.length < 0) {
			return;
		}

		while (fileListEl.hasChildNodes()) {
			fileListEl.removeChild(fileListEl.firstChild);
		}

		for (var x = 0; x < fileListStore.length; x++) {
			var li = document.createElement('li');
			li.innerHTML = 'File ' + (x + 1) + ':  ' + fileListStore[x].filename;
      var link = returnRemoveFileLink();
      li.appendChild(link);
			fileListEl.appendChild(li);
		}
  };

  var returnRemoveFileLink = function () {
    var index = fileListStore.length + 1;
    var link = document.createElement('a');
    link.href = index;
    link.innerHTML = 'Remove';
    return link;
  };

  var updateFileStore = function (item) {
    fileListStore.push(item);
  };

  var removeFromFileStore = function (index) {
    var zeroBasedIndex = index - 1;
    fileListStore.splice(zeroBasedIndex, 1);
  };

  var handleUploadFileSuccess = function (response) {
    var item = JSON.parse(response.target.responseText);
    updateFileStore(item);
    renderFileList();
    removeLoadingClass();
  };

  var handleUploadFileError = function () {
    removeLoadingClass();
  };

  var uploadFile = function () {
  	var fileSelect = baseEl.querySelector( '.inputfile' );
		// Get the selected files from the input.
		var files = fileSelect.files;
		// Create a new FormData object.
		var formData = new FormData();
		// Loop through each of the selected files.
		for (var i = 0; i < files.length; i++) {
		  var file = files[i];
		  // Check the file type.
		  if (!file.type.match('image.*')) {
		    //continue;
		  }
		  // Add the file to the request.
		  formData.append('photos[]', file, file.name);
		}
  	formData.append('name', 'value'); 

  	var request = new XMLHttpRequest();
		request.onerror = handleUploadFileError(dummyError);
    request.onload = handleUploadFileSuccess;
		request.open('POST', '/api/document', true);
		request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
		request.send(formData);
    addLoadingClass();
  };

  var attachBehaviour = function () {
		var inputs = baseEl.querySelectorAll( '.inputfile' );
		Array.prototype.forEach.call( inputs, function( input ) {
			input.addEventListener( 'change', changeHandler);
		});
    fileListEl.addEventListener("click", handleFileListClick, true);
  };

  var init = function (el) {
  	baseEl = el;
    cacheElements();
    attachBehaviour();
  };

  return {
    init: init
  };

})();


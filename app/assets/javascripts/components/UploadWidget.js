var ukti = window.ukti || {};



ukti.UploadWidget = (function($) {
  'use strict';
  var baseEl;
  var fileInputField;
  var fileListStore = [];

  var dummySuccess = {
    responseText: '{ "id":"5d6s6d5sd6sd", "filename":"filename.pdf", "base_url":"http://localhits/"}'
  };

  var changeHandler = function(event) {
  	uploadFile();
  };

  var renderFileList = function () {
		var list = baseEl.querySelector('.fileList');
		if(!list || fileListStore.length < 0) {
			return;
		}

		while (list.hasChildNodes()) {
			list.removeChild(list.firstChild);
		}

		for (var x = 0; x < fileListStore.length; x++) {
			var li = document.createElement('li');
			li.innerHTML = 'File ' + (x + 1) + ':  ' + fileListStore[x].filename;
      var link = returnRemoveFileLink();
      li.appendChild(link);
			list.appendChild(li);
		}
  };

  var returnRemoveFileLink = function () {
    var link = document.createElement('a');
    link.href = '#';
    link.innerHTML = 'Remove';
    return link;
  };

  var resetFileList = function () {
  	
  };

  var addToFileList = function () {

  };

  var removeFromFileList = function (event) {
    debugger;
  };

  var updateFileStore = function (item) {
    fileListStore.push(item);
  };

  var removeFromFileStore = function (index) {
    fileListStore.push(item);
  };

  var handleUploadFileSuccess = function (response) {
    var response = JSON.parse(response.responseText);
    updateFileStore(response);
    renderFileList();
  };

  var handleUploadFileError = function (response) {
    var response = JSON.parse(response.responseText);
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
		request.onerror = handleUploadFileError(dummySuccess);
    request.onload = handleUploadFileSuccess(dummySuccess);
		request.open('GET', '/api/document', true);
		request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
		request.send(formData);
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


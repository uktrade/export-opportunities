var ukti = window.ukti || {};

ukti.UploadWidget = (function($) {
  'use strict';
  var baseEl;
  var fileInputField;
  var fileListStore = [];

  var changeHandler = function(event) {
  	uploadFile();
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
  };

  var resetFileList = function () {
  	
  };

  var addToFileList = function () {

  };

  var removeFromFileList = function () {

  };

  var handleUploadFile = function () {

  };

  var handleUploadFileSuccess = function () {
  	
  };

  var handleUploadFileError = function () {
  	
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
  	debugger;

  	var request = new XMLHttpRequest();
		request.onreadystatechange = function (oEvent) {  
	    if (request.readyState === 4) {  
        if (request.status === 200) {  
          console.log(request.responseText);  
        } else {  
          console.log("Error", request.statusText);  
        }  
	    }  
		};
		request.open('POST', '/admin/opportunities', true);
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


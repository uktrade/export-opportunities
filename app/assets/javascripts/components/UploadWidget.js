var ukti = window.ukti || {};

ukti.UploadWidget = (function() {
  'use strict';

  var config = {
    maxFiles : 5,
    maxFileSize : 24000000, // in bytes
    allowedFileTypes : ['application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/pdf', 'application/vnd.ms-powerpoint', 'application/vnd.openxmlformats-officedocument.presentationml.presentation', 'image/jpeg', 'image/png'],
    errorMessages : {
      'filetype' : 'Error. Wrong file type. Your file should be doc, docx, pdf, ppt, pptx, jpg or png',
      'filesize' : 'File exceeds max size. Your file can have a maximum size of 25MB',
      'general' : 'Something has gone wrong. Please try again or contact exportingisgreat@trade.gsi.gov.uk'
    }
  };

  var baseEl,
      fileInputEl,
      hiddenInputEl,
      fileListEl,
      labelEl,
      fileListStore = [],
      formGroupEl,
      errorEl,
      errors = [];

  var cacheElements = function () {
    fileInputEl = baseEl.querySelector( '.inputfile' );
    fileListEl = baseEl.querySelector( '.fileList' );
    hiddenInputEl = baseEl.querySelector( '.fileListStore' );
    labelEl = baseEl.querySelector( 'label' );
    formGroupEl = ukti.Utilities.closestByClass(baseEl, 'form-group');
    errorEl = formGroupEl.querySelector( '.error-message' );
  };

  var changeHandler = function(event) {
    if (event.target.files.length < 1) {
      return;
    }
    var file = event.target.files[0];
    if (isFileValid(file)) {
      uploadFile();
    }
  };

  var isFileValid = function(file) {
    if(config.allowedFileTypes.indexOf(file.type) < 0) {
      errors.push(config.errorMessages.filetype);
    }
    if(file.size > config.maxFileSize) {
      errors.push(config.errorMessages.filesize);
    }
    if (errors.length) {
        displayErrors();  
        return false;
      }
      else {
        clearErrors();
        return true;
      }
  };

  var displayErrors = function () {
    if (!errorEl) {
      return;
    }
    var html = '';
    formGroupEl.classList.add('form-group-error');
    for (var i = 0; i < errors.length; i++) {
        html += errors[i];
    }
    errorEl.innerHTML = html;
    errors.length = 0;
  };

  var clearErrors = function () {
    formGroupEl.classList.remove('form-group-error');
    errorEl.innerHTML = '';
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
      var index = event.target.getAttribute('href');
      removeFromFileStore(index);
      renderFileList();
    }
  };

  var renderFileList = function () {
		if(!fileListEl || fileListStore.length < 0) {
			return;
		}

    if (fileListStore.length === config.maxFiles) {
      handleMaxFilesReach();
    } else {
      showAddFileButton();
    }

		while (fileListEl.hasChildNodes()) {
			fileListEl.removeChild(fileListEl.firstChild);
		}

		for (var x = 0; x < fileListStore.length; x++) {
			var li = document.createElement('li');
      var span = document.createElement('span');
      span.className = 'form-control';
			span.innerHTML = 'File ' + (x + 1) + ':  ' + fileListStore[x].result.id.original_filename;
      li.appendChild(span);
      var link = returnRemoveFileLink(x + 1);
      li.appendChild(link);
			fileListEl.appendChild(li);
		}
  };

  var returnRemoveFileLink = function () {
    var index = fileListStore.length;
    var link = document.createElement('a');
    link.href = index;
    link.innerHTML = 'Remove';
    return link;
  };

  var updateFileStore = function (item) {
    fileListStore.push(item);
  };

  var handleMaxFilesReach = function () {
    hideAddFileButton();
  };

  var hideAddFileButton = function () {
    labelEl.classList.add('hidden');
  };

  var showAddFileButton = function () {
    labelEl.classList.remove('hidden');
  };

  var updateHiddenField = function (item) {
    if(hiddenInputEl) {
      hiddenInputEl.value = JSON.stringify(fileListStore);
    }
  };

  var removeFromFileStore = function (index) {
    var zeroBasedIndex = index - 1;
    fileListStore.splice(zeroBasedIndex, 1);
  };

  var handleUploadFileSuccess = function (response) {
    // TO-DO handle 500s
    if (response.target.status === 404) {
      return handleUploadFileError();
    }
    setTimeout(function() {
      var item = JSON.parse(response.target.responseText);
      updateFileStore(item);
      updateHiddenField();
      renderFileList();
      removeLoadingClass();
    }.bind(this), 2000);
  };

  var handleUploadFileError = function () {
    errors.push(config.errorMessages.general);
    displayErrors();
    removeLoadingClass();
  };

  var uploadFile = function () {
  	var fileSelect = baseEl.querySelector( '.inputfile' );
    var userId = baseEl.querySelector('input[name="enquiry_response[user_id]"]').value;
    var enquiryId = baseEl.querySelector('input[name="enquiry_response[enquiry_id]"]').value;
		// Get the selected files from the input.
		var files = fileSelect.files;
		// Create a new FormData object.
		var formData = new FormData();
		// Loop through each of the selected files.
		for (var i = 0; i < files.length; i++) {
		  var file = files[i];
		  // Add the file to the request.
		  formData.append('enquiry_response[file_blob]', file, file.name);
      formData.append('enquiry_response[original_filename]', file.name);
		}

  	formData.append('enquiry_response[user_id]', userId); 
    formData.append('enquiry_response[enquiry_id]', enquiryId);
    
  	var request = new XMLHttpRequest();
		request.onerror = handleUploadFileError;
    request.onload = handleUploadFileSuccess;
		request.open('POST', '/api/document', true);
		//request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
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


var ukti = window.ukti || {};

<<<<<<< HEAD


ukti.UploadWidget = (function($) {
=======
ukti.UploadWidget = (function() {
>>>>>>> a281d76... (fetaure) maintaining state of tabs =when clciking edit to go back
  'use strict';
  var baseEl;
<<<<<<< HEAD
  var fileInputField;
  var fileListStore = [];

<<<<<<< HEAD
<<<<<<< HEAD
  var dummySuccess = {
    responseText: '{ "id":"5d6s6d5sd6sd", "filename":"filename.pdf", "base_url":"http://localhits/"}'
  };

=======
=======
  var config = {
    maxFiles : 5,
    maxFileSize : 24000000, // in bytes
    allowedFileTypes : ['txt', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/pdf', 'application/vnd.ms-powerpoint', 'application/vnd.openxmlformats-officedocument.presentationml.presentation', 'image/jpeg', 'image/png'],
    errorMessages : {
      'filetype' : 'Error. Wrong file type. Your file should be doc, docx, pdf, ppt, pptx, jpg or png.',
      'filesize' : 'File exceeds max size. Your file can have a maximum size of 25Mb.',
      'general' : 'Something has gone wrong. Please try again. If the problem persists, contact us.'
    }
  };

>>>>>>> 9dcebec... (feature) file validation pre upload
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

<<<<<<< HEAD
>>>>>>> cdf0a1c... (feature) adding snippets
=======
  var setup = function () {
    if(hiddenInputEl && !ukti.Utilities.isValueEmpty(hiddenInputEl.value)) {
      fileListStore = JSON.parse(hiddenInputEl.value);
      renderFileList();
    }
  };

<<<<<<< HEAD
>>>>>>> c70f561... (feature) some changes
  var changeHandler = function(event) {
<<<<<<< HEAD
<<<<<<< HEAD
  	uploadFile();
=======
  var fileListStore = [];
=======
    if (event.target.files.length > 0) {
=======
    if (event.target.files.length < 1) {
=======
  var supportsFormData = function () {
    return !! window.FormData;
  };

  var handleNoSupport = function () {
    var el = ukti.Forms.returnFormGroup(baseEl);
    ukti.Utilities.removeEl(el);
  };

  var changeHandler = function(event) {
    if (event.target.files && event.target.files.length < 1) {
>>>>>>> 83de420... (fix) hiding file upload on IE9 as there is no support for this FormData
      return;
    }
    var file = event.target.files[0];
<<<<<<< HEAD
    debugger;
    if (checkFile(file)) {
>>>>>>> 9dcebec... (feature) file validation pre upload
=======
    if (isFileValid(file)) {
>>>>>>> 7104f2e... (feature) more file validation errors
      uploadFile();
    }
  };
>>>>>>> 8a9a34f... (feature) getting preview page up there

<<<<<<< HEAD
<<<<<<< HEAD
  var changeHandler = function(event) {
  	fileListStore = event.currentTarget.files;
    updateLabel(event);
    updateFileList();
=======
  var checkFile = function(file) {
    var valid = true;
=======
  var isFileValid = function(file) {
>>>>>>> 7104f2e... (feature) more file validation errors
    if(config.allowedFileTypes.indexOf(file.type) < 0) {
      errors.push(config.errorMessages.filetype);
    }
    if(file.size > config.maxFileSize) {
      errors.push(config.errorMessages.filesize);
    }
    if (errors.length) {
        ukti.Forms.addErrorsToField(baseEl, errors);
        errors.length = 0;
        return false;
      }
      else {
        ukti.Forms.clearErrorFromField(baseEl);
        return true;
      }
  };

  var addLoadingClass = function(event) {
    labelEl.classList.add('isLoading');
>>>>>>> 9dcebec... (feature) file validation pre upload
  };

  var updateLabel = function (event) {
  	var input = event.currentTarget,
			  label = input.nextElementSibling,
		 labelVal = label.innerHTML,
		 fileName = '';

<<<<<<< HEAD
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
>>>>>>> 3d9e728... (fix) multiple attachments, using carrierwave
=======
  var handleFileListClick = function (event) {
    if(event.target.tagName.toLowerCase() === 'a') {
      event.preventDefault();
      var index = event.target.getAttribute('href');
      removeFromFileStore(index);
      updateHiddenField();
      renderFileList();
    }
>>>>>>> 13799ba... (feature) showinf file name in attachments list
  };

  var renderFileList = function () {
		var list = baseEl.querySelector('.fileList');
		if(!list || fileListStore.length < 0) {
			return;
		}

<<<<<<< HEAD
<<<<<<< HEAD
		while (list.hasChildNodes()) {
			list.removeChild(list.firstChild);
=======
=======
    ukti.Forms.clearErrorFromField(baseEl);

>>>>>>> b839fe0... (feature) clearing errors where appropriate and putting document back into preview
    if (fileListStore.length === config.maxFiles) {
      handleMaxFilesReach();
    } else {
      enableField();
    }

		while (fileListEl.hasChildNodes()) {
			fileListEl.removeChild(fileListEl.firstChild);
>>>>>>> 7104f2e... (feature) more file validation errors
		}

		for (var x = 0; x < fileListStore.length; x++) {
			var li = document.createElement('li');
      var span = document.createElement('span');
      span.className = 'form-control';
			span.innerHTML = 'File ' + (x + 1) + ':  ' + fileListStore[x].result.id.original_filename;
      li.appendChild(span);
      var link = returnRemoveFileLink(x + 1);
      li.appendChild(link);
			list.appendChild(li);
		}
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
  };

<<<<<<< HEAD
  var returnRemoveFileLink = function () {
<<<<<<< HEAD
=======
    var index = fileListStore.length;
>>>>>>> 13799ba... (feature) showinf file name in attachments list
=======
  var returnRemoveFileLink = function (index) {
>>>>>>> c3d4ee8... (feature) download expired message and various tweaks
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

  var handleMaxFilesReach = function () {
    disableField();
  };

  var disableField = function () {
    fileInputEl.setAttribute('disabled', 'disabled');
    fileInputEl.setAttribute('aria-disabled', 'true');
  };

  var enableField = function () {
    fileInputEl.removeAttribute('disabled');
    fileInputEl.removeAttribute('aria-disabled');
  };

  var updateHiddenField = function (item) {
    if( hiddenInputEl ) {
      hiddenInputEl.value = fileListStore.length ? JSON.stringify(fileListStore) : '';
    }
  };

  var removeFromFileStore = function (index) {
    fileListStore.push(item);
  };

  var handleUploadFileSuccess = function (response) {
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
    var response = JSON.parse(response.responseText);
    updateFileStore(response);
    renderFileList();
=======
=======
    // TO-DO handle 500s
    if (response.target.status === 404) {
      return handleUploadFileError();
    }
>>>>>>> 7104f2e... (feature) more file validation errors
    setTimeout(function() {
      var item = JSON.parse(response.target.responseText);
      updateFileStore(item);
      updateHiddenField();
      renderFileList();
      removeLoadingClass();
    }.bind(this), 2000);
>>>>>>> 8a9a34f... (feature) getting preview page up there
  };
=======
=======
>>>>>>> 3d9e728... (fix) multiple attachments, using carrierwave
  }
=======
  };
>>>>>>> 717075f... PTU comms in stable

  var resetLabel = function () {

  };

  var resetFileList = function () {
  	
<<<<<<< HEAD
  }
<<<<<<< HEAD
>>>>>>> b466330... (fix) multiple attachments, using carrierwave

<<<<<<< HEAD
  var handleUploadFileError = function (response) {
    var response = JSON.parse(response.responseText);
=======
  var handleUploadFileError = function () {
=======
    var item = JSON.parse(response.responseText);
    updateFileStore(item);
    updateHiddenField();
    renderFileList();
    removeLoadingClass();
  };

  var handleUploadFileError = function (xhr, status) {
>>>>>>> a59a4db... (feature) adding client side validation to signature field
    errors.push(config.errorMessages.general);
    ukti.Forms.addErrorsToField(baseEl, errors);
    removeLoadingClass();
>>>>>>> 7104f2e... (feature) more file validation errors
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
    
<<<<<<< HEAD
  	var request = new XMLHttpRequest();
<<<<<<< HEAD
		request.onerror = handleUploadFileError(dummySuccess);
    request.onload = handleUploadFileSuccess(dummySuccess);
		request.open('GET', '/api/document', true);
=======
		request.onerror = handleUploadFileError;
    request.onload = handleUploadFileSuccess;
		request.open('POST', '/api/document', true);
<<<<<<< HEAD
>>>>>>> 7104f2e... (feature) more file validation errors
		request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
=======
		//request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
>>>>>>> f256312... (feature) ajax request headers change for file upload
		request.send(formData);
  }
=======
>>>>>>> 3d9e728... (fix) multiple attachments, using carrierwave
=======
=======
  	var request = new XMLHttpRequest(); 
		request.onerror = handleUploadFileError;
    request.open('POST', '/api/document', true);
		request.onreadystatechange = function () {
      if ( request.readyState === 4 ) {
        if ( request.status == 200 ) { 
          handleUploadFileSuccess(request); 
        } else { 
          handleUploadFileError(request, request.status); 
        } 
      }
    };
    /* check for polyfill use */
    if (formData.fake) {
      request.setRequestHeader("Content-Type", "multipart/form-data; boundary="+ formData.boundary);
      request.sendAsBinary(formData.toString());
    } else {
      request.send(formData);
    }
    addLoadingClass();
>>>>>>> a59a4db... (feature) adding client side validation to signature field
  };
>>>>>>> 717075f... PTU comms in stable

  var attachBehaviour = function () {
		var inputs = baseEl.querySelectorAll( '.inputfile' );
		Array.prototype.forEach.call( inputs, function( input ) {
			input.addEventListener( 'change', changeHandler);
		});
  };

  var init = function (el) {
  	baseEl = el;
<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
    if (!supportsFormData()) {
      handleNoSupport();
      return;
    }
>>>>>>> 83de420... (fix) hiding file upload on IE9 as there is no support for this FormData
    cacheElements();
    setup();
>>>>>>> c70f561... (feature) some changes
    attachBehaviour();
  };

  return {
    init: init
  };

})();


var ukti = window.ukti || {};

ukti.UploadWidget = (function($) {
  'use strict';

  var config = {
    maxFiles : 1,
    maxFileSize : 24000,
    allowedFileTypes : ['application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/pdf', 'application/vnd.ms-powerpoint', 'application/vnd.openxmlformats-officedocument.presentationml.presentation', 'image/jpeg', 'image/png'],
    errorMessages : {
      'filetype' : 'Error. Wrong file type. Your file should be doc, docx, pdf, ppt, pptx, jpg or png',
      'filesize' : 'File exceeds max size. Your file should be a maximum size of 25MB',
      'general' : 'Something has gone wrong. Please try again or (hyperlink) contact us'
    }
  };

  var baseEl,
      fileInputEl,
      hiddenInputEl,
      fileListEl,
      labelEl,
      fileListStore = [],
      errors = [];

  var dummyError = {
    responseText: '{ "id":"5d6s6d5sd6sd", "filename":"filename.pdf", "base_url":"http://localhits/"}'
  };

  var cacheElements = function () {
    fileInputEl = baseEl.querySelector( '.inputfile' );
    fileListEl = baseEl.querySelector( '.fileList' );
    hiddenInputEl = baseEl.querySelector( '.fileListStore' );
    labelEl = baseEl.querySelector( 'label' );
  };

  var changeHandler = function(event) {
    if (event.target.files.length < 1) {
      return;
    }
    var file = event.target.files[0];
    debugger;
    if (checkFile(file)) {
      uploadFile();
    }
  };

  var checkFile = function(file) {
    var valid = true;
    if(config.allowedFileTypes.indexOf(file.type) < 0) {
      valid = false;
    }
    if(file.size > config.maxFileSize) {
      valid = false;
    }
    return valid;
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
      var span = document.createElement('span');
      span.className = 'form-control';
			span.innerHTML = 'File ' + (x + 1) + ':  ' + fileListStore[x].original_filename;
      li.appendChild(span);
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
    if (fileListStore.length > config.maxFiles) {
      return handleFileStoreMaximum();
    }
    fileListStore.push(item);
  };

  var handleFileStoreMaxReach = function () {
    hideAddFileButton();
  };

  var hideAddFileButton = function () {

  };

  var showAddFileButton = function () {
    
  };

  var updateHiddenField = function (item) {
    if(hiddenInputEl) {
      hiddenInputEl.value = JSON.stringify(fileListStore);
    }
    //$.cookie('attachments-data', JSON.stringify(fileListStore));
  };

  var tempSolutionAttachments = function () {
    var attachments = JSON.parse($.cookie('attachments-data'));
  };

  var removeFromFileStore = function (index) {
    var zeroBasedIndex = index - 1;
    fileListStore.splice(zeroBasedIndex, 1);
  };

  var handleUploadFileSuccess = function (response) {
    setTimeout(function() {
      var item = JSON.parse(response.target.responseText);
      updateFileStore(item);
      updateHiddenField();
      renderFileList();
      removeLoadingClass();
    }.bind(this), 2000);
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
		  // // Check the file type.
		  // if (!file.type.match('image.*')) {
		  //   //continue;
		  // }
		  // Add the file to the request.
		  formData.append('file_blob', file, file.name);
		}
  	formData.append('user_id', 'sdfsdf'); 
    formData.append('enquiry_id', 'sdfsdf');
    formData.append('original_filename', 'sdfsdf');
    
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

})($);


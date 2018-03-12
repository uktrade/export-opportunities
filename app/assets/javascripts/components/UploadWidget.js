var ukti = window.ukti || {};

ukti.UploadWidget = (function() {
    'use strict';

    var config = {
      maxFiles : 5,
      maxFileSize : 24000000, // in bytes
      allowedFileTypes : ['application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'application/zip', 'application/pdf', 'application/vnd.ms-powerpoint', 'application/vnd.openxmlformats-officedocument.presentationml.presentation', 'image/jpeg', 'image/png'],
      errorMessages : {
        'filetype' : 'Error. Wrong file type. Your file should be doc, docx, xls, xlsx, pdf, ppt, pptx, jpg or png.',
        'filesize' : 'Error. File exceeds max size. Your file can have a maximum size of 25Mb.',
        'virus' : 'Error. Virus detected in this file. Contact your IT department.',
        'general' : 'Something has gone wrong. Please try again. If the problem persists, contact us.'
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

    var setup = function () {
      if( hiddenInputEl && !ukti.Utilities.isValueEmpty(hiddenInputEl.value) ) {
        fileListStore = JSON.parse(hiddenInputEl.value);
        renderFileList();
      }
    };

    var supportsFormData = function () {
      return !! window.FormData;
    };

    var handleNoSupport = function () {
      var el = ukti.Forms.returnFormGroup(baseEl);
      ukti.Utilities.removeEl(el);
    };

    var changeHandler = function(event) {
      if (event.target.files && event.target.files.length < 1) {
        return;
      }
      var file = event.target.files[0];
      if (isFileValid(file)) {
        uploadFile();
      }
    };

    var isFileValid = function(file) {
      if (config.allowedFileTypes.indexOf(file.type) < 0) {
          errors.push(config.errorMessages.filetype);
      }
      if (file.size > config.maxFileSize) {
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
    };

    var removeLoadingClass = function(event) {
      labelEl.classList.remove('isLoading');
    };

    var handleFileListClick = function (event) {
      if(event.target.tagName.toLowerCase() === 'a') {
        event.preventDefault();
        var index = event.target.getAttribute('href');
        removeFromFileStore(index);
        updateHiddenField();
        renderFileList();
      }
    };

    var renderFileList = function () {
      if(!fileListEl || fileListStore.length < 0) {
        return;
      }

      ukti.Forms.clearErrorFromField(baseEl);

      if (fileListStore.length === config.maxFiles) {
        handleMaxFilesReach();
      } else {
        enableField();
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

    var returnRemoveFileLink = function (index) {
      var link = document.createElement('a');
      link.href = index;
      link.innerHTML = 'Remove';
      return link;
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
      if ( hiddenInputEl ) {
        hiddenInputEl.value = fileListStore.length ? JSON.stringify(fileListStore) : '';
      }
    };

    var removeFromFileStore = function (index) {
      var zeroBasedIndex = index - 1;
      fileListStore.splice(zeroBasedIndex, 1);
    };

    var handleUploadFileSuccess = function (response) {
      var response = JSON.parse(response.responseText);
      if ( response.result && response.result.errors ) {
        handleUploadFileError(response.result.errors.type);
        return;
      }
      updateFileStore(response);
      updateHiddenField();
      renderFileList();
      removeLoadingClass();
    };

    var handleUploadFileError = function (error) {
      if(error === 'virus found') {
        errors.push(config.errorMessages.virus);
      } else {
        errors.push(config.errorMessages.general);
      }
      ukti.Forms.addErrorsToField(baseEl, errors);
      errors.length = 0;
      removeLoadingClass();
    };

    var uploadFile = function () {
      var fileSelect = baseEl.querySelector( '.inputfile' );
      var userId = baseEl.querySelector('input[name="enquiry_response[user_id]"]').value;
      var enquiryId = document.querySelector('input[name="enquiry_response[enquiry_id]"]').value;
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
      request.open('POST', '/api/document', true);
      request.onreadystatechange = function () {
        if ( request.readyState === 4 ) {
          if ( request.status == 200 ) {
            handleUploadFileSuccess(request);
          } else {
            handleUploadFileError(config.errorMessages.general);
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
      if (!supportsFormData()) {
        handleNoSupport();
        return;
      }
      cacheElements();
      setup();
      attachBehaviour();
    };

    return {
      init: init
    };
})();

var ukti = window.ukti || {};
// Modernizr.input.multiple
ukti.UploadWidget = (function() {
  'use strict';
  var baseEl;
  var fileListStore = [];
  var maxFiles = 5;
  var error = {
    name: 'filelistsize',
    message: 'Too many filez'
  };

  /**
   * Handle change event
   */
  var changeHandler = function(event) {
    fileListStore = event.target.files;
    console.log(fileListStore.length);
    if (fileListStore.length === 0 ) {
      resetAll(event);
      return;
    }
    if( fileListStore.length > maxFiles ) {
      showError(event);
      return;
    }
    clearError();
    updateLabel(event);
    updateFileList();
  };
  /**
   * Update "2 files selected"
   */
  var updateLabel = function (event) {
    var input = event.target,
        label = input.nextElementSibling,
  defaultText = label.getAttribute('data-multiple-caption');

    if( fileListStore.length > 0 ) {
      label.querySelector( 'span' ).innerHTML = 'Choose other files';
    } else {
      label.querySelector( 'span' ).innerHTML = defaultText;
    }
  };

  /**
   * Update "_ files selected"
   */
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
    addClearButton(list);
  };

  /**
   * Add a clear button
   */
  var addClearButton = function (list) {
    removeClearButton();
    var button = returnClearButtonNode();
    list.parentNode.insertBefore(button, list.nextSibling);
  };

  /**
   * Remove clear button
   */
  var removeClearButton = function (list) {
    var button = baseEl.querySelector('.js-clearFileList');
    if (button) {
      button.parentNode.removeChild(button);
    }
  };

  /**
   * Remove clear button node
   */
  var returnClearButtonNode = function () {
    var node = document.createElement('a');
    node.className = 'bold-xsmall js-clearFileList';
    node.href = '#';
    node.innerHTML = 'Remove files';
    return node;
  };

  /**
   * Reset everything
   */
  var resetAll = function (event) {
    var input = event.target,
      label = input.nextElementSibling,
       list = baseEl.querySelector('.fileList');
      clearError();
      resetLabel(label);
      resetList(list);
      removeClearButton();
  };

  /**
   * Clear field label
   */
  var resetLabel = function (label) {
    var text = label.getAttribute( 'data-default-text' );
    label.querySelector( 'span' ).innerHTML = text;
  };

  /**
   * Clear file list
   */
  var resetList = function (list) {
    var text = list.getAttribute( 'data-default-item' );
    while (list.hasChildNodes()) {
      list.removeChild(list.firstChild);
    }
    var li = document.createElement('li');
    li.innerHTML = text;
    list.appendChild(li);
  };

  /**
   * Clear file queue
   */
  var clearFileQueue = function (event) {
    if (event.target.className.indexOf('js-clearFileList') > -1) {
      event.preventDefault();
      var inputEl = baseEl.querySelector( '.inputfile' );
      var changeEvent = document.createEvent("UIEvents");
      inputEl.value = "";
      var backupElem = inputEl.cloneNode(true);
      inputEl.parentNode.replaceChild(backupElem, inputEl);
      changeEvent.initUIEvent("change", true, true, window, 1);
      backupElem.dispatchEvent(changeEvent);
    }
  };

  /**
   * Return error node
   */
  var returnErrorNode = function () {
    var errorNode = document.createElement('span');
    errorNode.className = 'error-message';
    errorNode.id = 'error-message-' + error.name;
    errorNode.role = 'alert';
    errorNode.innerHTML = error.message;
    return errorNode;
  };

  /**
   * Show error
   */
  var showError = function () {
    /* clear any existing error state  */
    clearError();
    /* find elements */
    var inputEl = baseEl.querySelector( '.inputfile' );
    var parentNode = inputEl.parentNode;
    var formGroup = baseEl.closest('.form-group');
    /* add error class */
    formGroup.classList.add('form-group-error');
    /* inject error message  */
    var errorNode = returnErrorNode();
    parentNode.insertBefore(errorNode, inputEl);
  };

  /**
   * Clear error
   */
  var clearError = function () {
    var message = baseEl.querySelector( '.error-message' );
    if (message) {
      message.parentNode.removeChild(message);
    }
    var formGroup = baseEl.closest('.form-group');
    formGroup.classList.remove('form-group-error');
  };

  /**
   * Add event listeners
   */
  var attachBehaviour = function () {
    /* IE9 doesn't support input multiple so don't add events */
    baseEl.addEventListener( 'change', changeHandler);
    baseEl.addEventListener( 'click', clearFileQueue);
  };

  var init = function (el) {
    baseEl = el;
    attachBehaviour();
  };

  return {
    init: init
  };

})();


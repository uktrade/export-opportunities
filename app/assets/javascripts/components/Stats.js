/* globals $ */

var ukti = window.ukti || {};

ukti.ShowHide = (function() {
  'use strict';

  var _hiddenClass = 'js-hidden';
  var _hiddenControls = [];

  var hideBlock = function (el) {
    if (el) {
      el.classList.add(_hiddenClass);
    }
  };

  var showBlock = function (el) {
    clearControls();
    if (el) {
      el.classList.remove(_hiddenClass);
    }
  };

  var clearControls = function () {
    for ( var i = 0; i < _hiddenControls.length; i++ ) {
      hideBlock(_hiddenControls[i]);
    }
  }

  var clickHandler = function (event) {
    var id = $(event.currentTarget).data('target');
    var el = $('#' + id)[0];
    showBlock(el);
  }

  var setInitialVisibility = function () {
    var controls = document.querySelectorAll('div[data-target]');
    for ( var i = 0; i < controls.length; i++ ) {
      var input = controls[i].getElementsByTagName('input')[0];
      if (input.checked) {
        controls[i].click();
      }
    }
  }

  var saveHiddenControls = function (el) {
    var id = $(el).data('target');
    var el = $('#' + id)[0];
    _hiddenControls.push(el);
  }

  var attachBehaviour = function (form) {
    var controls = document.querySelectorAll('div[data-target]');
    for ( var i = 0; i < controls.length; i++ ) {
      var id = $(controls[i]).data('target');
      var el = $('#' + id)[0];
      _hiddenControls.push(el);
      var input = controls[i].getElementsByTagName('input')[0];
      controls[i].addEventListener('click', clickHandler);
    }
  };

  var init = function (form) {
    attachBehaviour(form);
    setInitialVisibility();
  };

  return {
    init: init
  };

})();

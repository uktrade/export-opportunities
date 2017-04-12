/* globals $ */

var ukti = window.ukti || {};

ukti.CharacterCounter = (function($) {
  'use strict';

  var init = function ($input, limit) {
    var formatRemaining = '%1 characters remaining';
    var formatOverLimit = ' characters over the limit';
    $input.characterCounter({
      limit: limit,
      counterFormat: formatRemaining,
      counterCssClass: 'characterCounter',
      counterExceededCssClass: 'characterCounter--exceeded',
      onExceed: function(count){
        this.counterFormat = (count - this.limit) + formatOverLimit;
      },
      onDeceed: function(){
        this.counterFormat = formatRemaining;
      }
    });
  };

  return {
    init: init
  };

})($);
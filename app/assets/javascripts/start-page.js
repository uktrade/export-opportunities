'use strict';

$('document').ready(function() {
	$( ".select-custom" ).select2({
		theme: "flat",
		escapeMarkup: function(markup) {
		  return markup;
		},
		templateResult: function(result) {
			return '<svg class="icon icon-check"><use xlink:href="#icon-ditcheckmark" /></svg>' + result.text;
    }
	});
});
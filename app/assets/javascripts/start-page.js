'use strict';

var filtersEl = document.querySelectorAll('.js-filters')[0];
if(filtersEl) {
	ukti.SearchFilters.init(filtersEl);
}

if ($( ".select-custom" ).length) {
	$( ".select-custom" ).select2({
		theme: "flat",
		escapeMarkup: function(markup) {
		  return markup;
		},
		templateResult: function(result) {
			return '<svg class="icon icon-check"><use xlink:href="#icon-ditcheckmark" /></svg>' + result.text;
    }
	});	
}
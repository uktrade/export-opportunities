'use strict';

var filtersEl = document.querySelectorAll('.js-filters')[0];
if(filtersEl) {
	ukti.SearchFilters.init(filtersEl);
}

if ($('.select-custom').length) {

	$('.select-custom').select2({
		theme: 'flat',
		selectOnClose: true,
		escapeMarkup: function(markup) {
		  return markup;
		},
		templateResult: function(result) {
			return '<svg class="icon icon-check"><use xlink:href="#icon-ditcheckmark" /></svg>' + result.text;
    }
	});

	/* prevent dropdown from opening when deselecting tag */
	$('.select-custom').on('select2:unselecting', function(e) {
	    $(this).on('select2:opening', function(e) {
	        e.preventDefault();
	    });

	});

	$('.select-custom').on('select2:unselect', function(e) {
	     var sel = $(this);
	     setTimeout(function() {
	       sel.off('select2:opening');
	     }, 1);
	});
}
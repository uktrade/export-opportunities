'use strict';

var filtersEl = document.querySelectorAll('.js-filters')[0];
if(filtersEl) {
	ukti.SearchFilters.init(filtersEl);
}

var orderEl = document.querySelectorAll('.js-order')[0];
if(orderEl) {
	ukti.ResultsOrder.init(orderEl);
}

var selectCustom = $('.select-custom');
if (selectCustom.length) {

	selectCustom.select2({
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
	selectCustom.on('select2:unselecting', function(e) {
	    $(this).on('select2:opening', function(e) {
	        e.preventDefault();
	    });
	});

	selectCustom.on('select2:unselect', function(e) {
	     var sel = $(this);
	     setTimeout(function() {
	       sel.off('select2:opening');
	     }, 1);
	});

	/* WORKAROUND FOR THE BUG https://github.com/select2/select2/issues/3817 */
	selectCustom.each(function() {
	    var $this = $(this);
	    //$this.parent().find('.select2-search--inline').width('100%');
	    //$this.parent().find('.select2-search__field').width('100%');
	});
}
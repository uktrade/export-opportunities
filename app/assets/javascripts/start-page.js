/* global $ */

var ukti = window.ukti || {};

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
		escapeMarkup: function(markup) {
		  return markup;
		},
		templateResult: function(result) {
			return '<svg class="icon icon-check"><use xlink:href="#icon-ditcheckmark" /></svg>' + result.text;
    	}
	});

	/* prevent dropdown from opening when deselecting tag */
	/* and clear label when deselecting - particularly with backspace */
	selectCustom.on('select2:unselect', function() {
		$el = $(this);
		$el.data('unselecting', true);
		setTimeout(function() {
			$el.parent().find('.select2-search__field').val('');
		}, 0);
	});

	selectCustom.on('select2:opening', function(e) {
		$el = $(this);
		if ( $el.data('unselecting') ) {
        	$el.removeData('unselecting');
        	e.preventDefault();
		}
	});
/* category action label */
/* search open-countries / select-countries-albania / 
	/* add event tracking for certain events */
	selectCustom.on("change", function(e) {
				console.log(e);
        // most used event, fired to the original element when the value changes
          console.log("change val=" + e);
        })
        .on("select2:open", function(e) {
          console.log("opening");
					console.log(e.currentTarget.id);
        })
        .on("select2:select", function(e) {
        	console.log(e.currentTarget.id);
        	console.log(e.currentTarget.value);
          console.log("selecting val=" + e.val + " choice=");
        })
        .on("select2:unselect", function(e) {
          console.log("removed val=" + e.val + " choice=" + e);
        })
}

/* scroll to results if they exist on page */
document.addEventListener('DOMContentLoaded', function() {
	var hasSearchResults = window.location.search.indexOf('?') > -1;
	if (hasSearchResults) {
		ukti.ScrollTo.init('#opportunities-subscribe-form');	
	}
}, false);
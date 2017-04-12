'use strict';

var OPPORTUNITIES = (function ($) {

  // Append 'has-js' class to html element so filter styling works as written
  document.documentElement.className += " has-js";

  // Detect request animation frame
  var $pager = $('#pager');

    init = function () {

      $(".order_relevance").hide();

      if( $('.search-form').length ) {
          $("input[name='sort_order']").on('change', function() { updateOpportunities() });
          $('.main').on('submit', '.search-form', searchSubmitHandler);
      }

      if( $('.filters').length ) {

        if( Modernizr.mq('screen and (max-width: 37.4375em)') ) {
            closeFilterPanel();
        }

        $('.filters').on('click', '.filters__link', filtersClickHandler);
        $('.filters').on('click', '.filters__title', toggleFilterPanel);
      }

      $('#pager').on('click', 'a', paginationClickHandler);
    },

    partnersFilters = function () {
      if( $('.filters').length ) {
        $('.filters').on('click', '.filters__title', toggleFilterPanel);
      }
    },

    openFilterPanel = function() {
      $('.filters__title').removeClass('filters__title--closed');
      $('.filters__panel').removeClass('filters__panel--closed');
    },

    closeFilterPanel = function() {
      $('.filters__title').addClass('filters__title--closed');
      $('.filters__panel').addClass('filters__panel--closed');
    },

    toggleFilterPanel = function(e) {
      e.preventDefault();

      $(this).toggleClass('filters__title--closed');
      $(this).parents('.filters__panel').toggleClass('filters__panel--closed');
    },

    /**
     * Search & filtering
     */

    searchSubmitHandler = function(e) {
        $(".order_relevance").show();
        $('input[name=sort_order][value=relevance]').prop('checked', 'checked');


        e.preventDefault();

        updateOpportunities();
    },

    updateActiveFilters = function($panel) {
      var count = $panel.find('.filters__link--active').size();

      if( count > 0 ) {
        $panel.find('.filters__status').text('(' + count + ' selected)');
      } else {
        $panel.find('.filters__status').text('');
      }
    },

    filtersClickHandler = function(e) {
        if (e.metaKey || e.ctrlKey) return;
        e.preventDefault();

        var $this = $(this),
            data = $this.data(),
            tax = data.tax,
            term = data.term,
            $panel = $this.parents('.filters__panel');

        $this.toggleClass('filters__link--active');

        updateOpportunities();
        updateActiveFilters($panel);
    },

    paginationClickHandler = function(e) {
      if (e.metaKey || e.ctrlKey) return;
      e.preventDefault();

      var $this = $(this),
          pageNum = $this.text();

      $pager.find('li').removeClass('active');
      $this.parent().addClass('active');

      updateOpportunities(pageNum, scrollToTop);
    },

    scrollToTop = function(){
      window.scrollTo(0, $(".opportunity").offset().top);
    },

    getSearchState = function() {
      var sectors = new Array();
      var countries = new Array();
      var types = new Array();
      var values = new Array();
      var sort_order = $("input[name='sort_order']:checked").val();

      var search_term = $('#searchinput').val();

      $('.filters__link--active[data-tax=sectors]').each(function(_, i) { sectors.push($(i).attr('data-term')) });
      $('.filters__link--active[data-tax=countries]').each(function(_, i) { countries.push($(i).attr('data-term')) });
      $('.filters__link--active[data-tax=types]').each(function(_, i) { types.push($(i).attr('data-term')) });
      $('.filters__link--active[data-tax=values]').each(function(_, i) { values.push($(i).attr('data-term')) });

        return {
        sectors: sectors,
        countries: countries,
        types: types,
        values: values,
        s: search_term,
        sort: sort_order,
      };
    },

    updateOpportunities = function(paged, callback) {
      var paged = typeof paged !== 'undefined' ? paged : 1;

      var payload = getSearchState();
      payload.paged = paged;

        $.get(
        '/opportunities.js',
        payload
      ).done(function() {
        $('#pager').on('click', 'a', paginationClickHandler);
        if (typeof callback === 'function') {
          callback();
        }
      });
    }

    return {
        init : init,
        partnersFilters : partnersFilters,
        getSearchState : getSearchState
    };

})(jQuery);

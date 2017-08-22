var ukti = window.ukti || {};

ukti.Tabs = (function($) {
  'use strict';

  var baseEl,
  		tabsList,
      tabPanels,
      callback;

  var cacheElements = function (selector) {
 		tabsList = baseEl.find("ul:first").attr({
			"class": "tabsList",
    });
    tabPanels = baseEl.find('.js-tab-panel');
  };

  var setup = function () {
    $(tabsList).find("> li").each(
      function(index){
        if ($(this).hasClass( 'active' )) {
          $(tabPanels).eq(index).attr("aria-hidden", "false");
        } else {
          $(tabPanels).eq(index).attr("aria-hidden", "true").hide();
        }
    });
  };

  var handleTabClick = function (event) {
    var tabPanel,
        tab = $(event.currentTarget);
    // Prevent default click event if an A tag
    //event.preventDefault();
    // Change state of previously selected tabList item
    $(tabsList).find("> li.active").removeClass('active').find("> input").attr("aria-expanded", "false");
    // Hide previously selected tabPanel
    $(baseEl).find(".js-tab-panel:visible").attr("aria-hidden", "true").hide();
    // Show newly selected tabPanel
    tabPanel = $(baseEl).find(".js-tab-panel").eq(tab.parent().index());
    tabPanel.attr("aria-hidden", "false").show();
    // Set state of newly selected tab list item
    tab.attr('aria-selected', "true").parent().addClass('active');

    if (callback) {
      callback(tab);
    }
    // Set focus?
    //tabPanel.children().first().attr("tabindex", -1).focus();
  };

	var addListeners = function () {
		$(tabsList).find("li > label").each(
      function(index){
        var tab = $(this);
        tab.click(handleTabClick);
    });
  };

  var init = function (el, cb) {
    baseEl = $(el);
    callback = cb;
		cacheElements();
    setup();
		addListeners();
  };

  return {
    init: init
  };

})($);



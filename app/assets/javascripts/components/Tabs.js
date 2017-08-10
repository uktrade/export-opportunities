var ukti = window.ukti || {};

ukti.Tabs = (function($) {
  'use strict';

  var tabs,
  		tabsList,
      tabPanels,
      callback;

  var cacheElements = function (selector) {
    tabs = $(".js-tabs");
 		tabsList = tabs.find("ul:first").attr({
			"class": "tabsList",
    });
    tabPanels = tabs.find('.js-tab-panel');
  };

  var setup = function () {
    tabPanels.attr({
        "aria-hidden": "true"
    }).hide();
    tabsList.find("li > a").each(
      function(index) {
        var tab = $(this);
        var tabId = "tab-" + tab.attr("href").slice(1);
        addAriaToControls(tab, tabId);
        addAriaToTabPanels(index, tabId);
    });
  };

  var addAriaToControls = function (tab, tabId) {
    tab.attr({
        "id": tabId,
        "aria-selected": "false",
    }).parent().attr("role", "presentation");
  };

  var addAriaToTabPanels  = function (index, tabId) {
		$(tabPanels).eq(index).attr("aria-labelledby", tabId);
  };

  var handleTabClick = function (event) {
    var tabPanel,
        tab = $(event.currentTarget);
    // Prevent default click event
    event.preventDefault();
    // Change state of previously selected tabList item
    $(tabsList).find("> li.active").removeClass('active').find("> a").attr("aria-selected", "false");
    // Hide previously selected tabPanel
    $(tabs).find(".js-tab-panel:visible").attr("aria-hidden", "true").hide();
    // Show newly selected tabPanel
    tabPanel = $(tabs).find(".js-tab-panel").eq(tab.parent().index());
    tabPanel.attr("aria-hidden", "false").show();
    // Set state of newly selected tab list item
    tab.attr('aria-selected', "true").parent().addClass('active');
    callback(tab);
    // Set focus?
    //tabPanel.children().first().attr("tabindex", -1).focus();
  };

	var addListeners = function () {
		$(tabsList).find("li > a").each(
      function(index){
        var tab = $(this);
        tab.click(handleTabClick);
    });
  };

  var init = function (cb) {
    callback = cb;
		cacheElements();
    setup();
		addListeners();
  };

  return {
    init: init
  };

})($);



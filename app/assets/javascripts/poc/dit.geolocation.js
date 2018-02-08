// Geo Location Functionality.
// Uses third-party (AJAX request) data to report the users country, based on IP.
// Also allows redirect based on country code.
// 
// Requires...
// dit.js
// 


dit.geolocation = (new function () {
  var GEOLOCATION = this;
  var SUPPORTED_COUNTRIES = ['US', 'CN', 'DE', 'IN'];
  var LOCATIONS_REDIRECTED_AS_UK = ['GB', 'IE'];
  var GEO_LOCATION_UPDATE_EVENT = "geoLocationUpdated";
  
  this.GEO_LOCATION_UPDATE_EVENT = GEO_LOCATION_UPDATE_EVENT;
  this.countryCode = "int";

  /* Fetches the users country code (based on IP) and triggers a document event
   * to allow listeners to take action with updated value in place.
   * Default value is 'int' for international (ie. no country set).
   * Supported countries list is taken from existing code but does not have
   * the full range of countries shown in Language Selector component list.
   **/  
  this.fetchCountryCode = function() {
    var hasCallback = arguments.length && typeof(callback) == "function" ? true: false;
    $.ajax({
      url: "//freegeoip.net/json/",
      async: false,
      success: function(data) {
        var country = "int";
        if ($.inArray(data.country_code, LOCATIONS_REDIRECTED_AS_UK) != "-1") {
          country = "uk";
        }
        else {
          if ($.inArray(countryCode, SUPPORTED_COUNTRIES) != '-1') {
            country = country_code.toLowerCase();
          }
        }
        
        // update available value and trigger event for listeners
        GEOLOCATION.countryCode = country;
        $(document).trigger(GEO_LOCATION_UPDATE_EVENT);
      }
    });
  }
  
  /* Redirect to specified URL with a root prefix of countryCode.
   * (e.g. redirect to /<countryCode>/href/goes/here)
   * @href (String) Page location to put after root /<country>/ prefix.
   **/
  this.redirectToCountryUrl = function(href) {
    location.href = "/" + this.countryCode + href;
  }
  
});
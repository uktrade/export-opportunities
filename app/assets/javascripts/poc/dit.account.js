// Controls the Anonymous and Authenticated view states
// ----------------------------------------------------
// Not entirely defined how this will currently work so
// basing on assumptions. Expected that templates using
// this code will include something like:
//
// <script>
// {% if sso_is_logged_in %}
//   dit.account.setUserGreeting({{ user.email_address }});
//   dit.account.setAuthenticationState(1);
// {% endif %}
// </script>
//
// You can also add custom JS that reads, for example, a
// cookie value and then adjust the Authentication state.
// The initial state is always set to be anonymous.
//
// Requires
// jQuery
// dit.js

dit.account = (new function () {
  var authenticationState = 0; // Default anonymous
  var _cache = {
    anonymous: $(),
    authenticated: $(),
    greeting: $()
  }
  
  // Initial site init
  this.init = function() {
    var $header = $("#header-bar");
    _cache.account_links = $(".account-links", $header);
    _cache.anonymous = $(".anonymous", $header);
    _cache.authenticated = $(".authenticated", $header);
    _cache.greeting = $(".greeting", $header);
    
    // Add the greeting element
    _cache.account_links.after(_cache.greeting);
  }
  
  this.setAuthenticationState = function(state) {
    authenticationState = state;
    updateAccountViewState(state);
  }
  
  this.getAuthenticationState = function() {
    return authenticationState;
  }
  
  this.setUserGreeting = function(identifier) {
    // Don't like having 'Hi ' hardcoded here. 
    // We could improve by passing this in. 
    var text = arguments.length ? "Hi " + identifier : "";
    if (_cache.greeting.length) {
      _cache.greeting.text(text);
    }
  }
  
  function updateAccountViewState(state) {
    switch(state) {
      case 1: // Authenticated
        _cache.anonymous.hide();
        _cache.authenticated.show();
        _cache.greeting.show();
        break;
      default: // Anonymous
        _cache.anonymous.show();
        _cache.authenticated.hide();
        _cache.greeting.hide();
    }
  }
});

$(document).ready(function() {
  dit.account.init();
});
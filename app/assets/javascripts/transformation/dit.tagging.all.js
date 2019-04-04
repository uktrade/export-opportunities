// Site-wide GA360 Tagging Functions.
// ----------------------------------
//
// REQUIRES
// jQuery


dit.tagging.all = (new function() {

  // Event Tagging will be applied upon
  // calling this function.
  this.init = function() {
    addTaggingForLogin();
  }

  function addTaggingForLogin() {
    $("#header-sign-in-link").on("click", function() {
      window.dataLayer.push({
        eventName: 'clicking on top right sign in SSO link',
        eventID: 'landing_sso_signin'
      });
    });

    $("#header-register-link").on("click", function() {
      window.dataLayer.push({
        eventName: 'clicking on top right register SSO link',
        eventID: 'langing_sso_register'
      });
    });
  }
});



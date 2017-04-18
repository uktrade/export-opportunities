(function ($) {
    var cookies,
    ssoSignIn = $('#sso-signin'),
    ssoSignOut = $('#sso-signout'),
    ssoCookieName = "sso_display_logged_in";

    ssoSignOut.hide();
    ssoSignIn.ready(setupSsoLink);

    function setupSsoLink(event) {
        var cookieValue = readCookie(ssoCookieName);
        if (cookieValue == "true") {
            ssoSignIn.hide();
            ssoSignOut.show();
        }
    }

    function readCookie(name){
        if(cookies){ return cookies[name]; }

        var c = document.cookie.split('; ');
        cookies = {};

        for(var i=c.length-1; i>=0; i--){
           var C = c[i].split('=');
           cookies[C[0]] = C[1];
        }

        return cookies[name];
    }

})(jQuery);

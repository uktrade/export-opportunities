/* Class: Service
 * -------------------------
 * Data service provider. 
 * E.g. Fetch and update JSON request/response.
 * 
 * REQUIRES:
 * jquery
 * dit.js
 *
 **/
(function ($, classes) {

 /* Constructor.
  * @url (String) From where to fetch data.
  * @options (Object) AJAX configurations. 
  **/ 
  classes.Service = Service;
  function Service(url, options) {
    var service = this;
    var config = $.extend({
      url: url,
      dataType: "json",
      method: "GET",
      success: function(response) {
        service.json = response;
        service.data = JSON.parse(response);
      }
    }, options || {});

    var listeners = [];
    var request; // Reference to active update request

    service.json = {}; // What we get back from an update

    /* Gets a fresh response
     * @params (String) Specify params for GET or data for POST
     **/
    service.update = function(params) {
      if(request) request.abort(); // Cancels a currently active request
      config.data = params || "";
      request = $.ajax(config);
      request.done(function() {
        // Activate each listener task
        for(var i=0; i<listeners.length; ++i) {
          listeners[i]();
        }
      })
    }

    /* Specify data processing task after response
     * @task (Function) Do something after service.json has been updated
     **/
    service.listener = function(task) {
      listeners.push(task);
    }
  }
})(jQuery, dit.classes);

/* Class: DataProvider
 * -------------------------
 * Gives the ability to filter on data source using a passed string value.
 * Also provides a simplistic callback feature after data has been filtered.
 *
 * REQUIRES:
 * jquery
 * dit.js
 *
 * Compatibility with dit.class.service:
 *
 * These functions were added to provide compatibility with dit.class.service
 * as the original component using DataFilter was inheriting from a class that
 * itself used a service instance.
 *
 * prototype.listener
 * prototype.filtered
 **/
(function ($, classes) {

  /* Constructor.
   * @data (Array) Array of key/value pairs.
   * @key (String) Data key for value to match against.
   * @callback (Funciton) Optional function to run after filtering.
   **/
  classes.DataProvider = DataProvider;
  function DataProvider(data, key) {
    var unfilteredData = data;
    this.data = data;
    this.key = key;
    this.callback = function() {};

    // Some inner variable requirement.
    this._private = {
      key: key
    }

    // Allow ability to reset back to original data
    this.reset = function() {
      this.data = unfilteredData;
    }
  }

  /* Public for Service compatibility.
   * A Service instance provides listener functionality but we're
   * keeping things simple and allowing one task to run when ready.
   **/
  DataProvider.prototype.listener = function(task) {
    this.callback = task;
  }

  /* Public for Service compatibility.
   * Filter the known data to return only key/value pairs that
   * match (against value) the passed string value.
   * @str (String) Value to filter (match) against data.
   **/
  DataProvider.prototype.filtered = function(str) {
    var filtered = [];
    var re = new RegExp(str, "gi");
    for(var i=0; i < this.data.length; ++i) {
      if(this.data[i][this.key].search(re) >= 0) {
        filtered.push(this.data[i]);
      }
    }
    return filtered;
  }

  /* Update the filtered data and run any callback.
   * @str (String) Checks for existence in data.
   **/
  DataProvider.prototype.update = function(str) {
    this.data = this.filtered(str);
    this.callback();
  }

})(jQuery, dit.classes);

/* global $ */

/* initiate sticky content */
document.addEventListener('DOMContentLoaded', function() {
  /* sticky nav */
  var stickyEl = document.getElementById('sticky-panel');
  var suggestionsEl = document.getElementById('suggestions');

  if (stickyEl) {
    var waypoint = new Waypoint({
      element: stickyEl,
      handler: function(direction) {
        if (direction == 'down') {
          this.element.style.left = this.element.offsetLeft;
          this.element.classList.add('stuck');
        } else {
          this.element.classList.remove('stuck');
          this.element.style.left = '';
        }
    },
      offset: 20 
    });
  }

  if (suggestionsEl) {
    var waypoint = new Waypoint({
      element: suggestionsEl,
      handler: function(direction) {
        if (direction == 'down') {
          stickyEl.style.left = this.element.offsetLeft;
          stickyEl.classList.add('sticky-surpassed');
        } else {
          stickyEl.classList.remove('stuck');
          stickyEl.element.style.left = '';
        }
    },
      offset: 20 
    });
  }

  // offset: function() {
  //     //return $('.sticky').outerHeight();
  // }

  /* equal height elements */
  ukti.EqualHeight.init('.tile-equal');

}, false);

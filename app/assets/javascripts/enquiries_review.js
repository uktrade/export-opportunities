/* global $ */

/* initiate sticky content */
document.addEventListener('DOMContentLoaded', function() {
  var waypoint = new Waypoint({
    element: document.getElementById('sticky-panel'),
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
}, false);
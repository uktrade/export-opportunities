/* global $ */
document.addEventListener('DOMContentLoaded', function() {
    /* Init accordions */
    if ('addEventListener' in document && document.querySelectorAll) {
      var accordions = document.querySelectorAll('.accordion')
      for (var i = accordions.length - 1; i >= 0; i--) {
        new Accordion(accordions[i])
      };
    }
    /* Init equal height elements */
    ukti.EqualHeight.init('.tile-equal');
}, false);
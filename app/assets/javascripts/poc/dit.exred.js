// ExRed Project-specific Code
//
// Requires
// jQuery
// dit.js
// dit.responsive.js
// dit.components.menu.js
// dit.components.feedback

dit.exred = (new function () {
  
  // Initial site init
  this.init = function() {
    dit.responsive.init({
      "desktop": "min-width: 768px",
      "tablet" : "max-width: 767px",
      "mobile" : "max-width: 480px"
    });
    
    dit.components.menu.init();
    dit.components.feedback.init();
    
    delete this.init; // Run once
  }
});

$(document).ready(function() {
  dit.exred.init();
});
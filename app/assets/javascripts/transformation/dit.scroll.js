// Scroll Related Functions.
// Requires main dit.js file

dit.scroll = (new function () {
  this.scrollPosition = 0;
  
  this.disable = function () {
    this.scrollPosition = window.scrollY,
    $(document.body).css({
        overflow: "hidden"
    });
    
    $(document).trigger("scrollingdisabled");
  }
  
  this.enable = function () {
    $(document.body).css({
      overflow: "auto"
    });
    
    window.scrollTo(0, this.scrollPosition);
    $(document).trigger("scrollingenabled");
  }
});
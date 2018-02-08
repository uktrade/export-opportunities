// Selective fixes targeting IE8 Functionality.
// --------------------------------------------
// 
// Requires...
// dit.js
// 

dit.ie8support = new (function() {
  
  this.swapSvgImagesForPng = function() {
    $("img").each(function() {
      var pngSrc = this.src.replace(".svg", ".png");
      if (this.src !== pngSrc) {
        this.src = pngSrc;
      }
    });
  }
  
  this.heroImageBgsBackToImgs = function() {
    $(".hero-section").each(function() {
      var $section = $(this);
      var background = $section.css("background-image");
      var $image;
      if (background) {
        $image = imageElementFromImageBackground(background, function() {
          this.css("left", String(($section.width() - this.width()) / 2) + "px");
        });

        $section.css("background-image", "url(/static/images/pixel.gif)"); // remove
        $section.prepend($image);
      }
    });
  }
  
  this.navigationRibbonSvgBgsToPngImgs = function() {
    $(".navigation-ribbon li").each(function() {
      var $this = $(this);
      var background = $this.css("background-image");
      var $image;
      if (background) {
        $image = imageElementFromImageBackground(background);
        $image.attr("src", $image.attr("src").replace(".svg", ".png"));
        $this.prepend($image);
      }
    });
  }
  
  this.countryFlagSvgBgsToPngImgs = function() {
    $(".language-selector-dialog .countries a").each(function() {
      var $this = $(this);
      var background = $this.css("background-image");
      var $image;
      if (background) {
        $image = imageElementFromImageBackground(background);
        $image.attr("src", $image.attr("src").replace(".svg", ".png"));
        $this.after($image);
      }
    });
  }
  
  
  function imageElementFromImageBackground(bgImageCss, onload) {
    var $image = $('<img alt="" class="background-image" />');
    if (arguments.length > 1) {
      // Arbitrary delay to give the CSS time to do its thing first.
      window.setTimeout(function() {
        onload.call($image);
      }, 500);
    }
    $image.attr("src", bgImageCss.replace(/^url\(\"(.*?)\"\)$/, "$1"));
    return $image;
  }
  
});

$(document).ready(function() {
  dit.ie8support.swapSvgImagesForPng();
  dit.ie8support.heroImageBgsBackToImgs();
  dit.ie8support.navigationRibbonSvgBgsToPngImgs();
  dit.ie8support.countryFlagSvgBgsToPngImgs();
});

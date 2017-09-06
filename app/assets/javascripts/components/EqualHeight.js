
var ukti = window.ukti || {};

ukti.EqualHeight = (function() {

  var init = function (className) {
    var findClass = document.getElementsByClassName(className);
    var tallest = 0; 
    // Loop over matching divs
    for(var i = 0; i < findClass.length; i++) {
      var ele = findClass[i];
      var eleHeight = ele.offsetHeight;
      tallest = (eleHeight > tallest ? eleHeight : tallest);
    }
    for(var j = 0; j < findClass.length; j++) {
      findClass[j].style.height = tallest + 'px';
    }
  };

  return {
    init: init
  };

})();
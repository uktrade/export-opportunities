$('document').ready(function() {
  if ($('.dit').length) {

    var toggleButton = $('.header-nav-toggle'),
    menu = $('.header-nav');

    toggleButton.click({ button: toggleButton, menu: menu }, toggle);

    function toggle (event){
      event.preventDefault();
      $(event.data.button).toggleClass('header-nav-toggle--open');
      $(event.data.menu).toggleClass( "open");
    }

  } else {

    var toggleButton = $('.navigation-main-button'),
        menu = $('.navigation-toggle');

    toggleButton.click({ button: toggleButton, menu: menu }, toggle);

    function toggle (event){
      event.preventDefault();
      $(event.data.button).toggleClass('navigation-main-button--open');
      $(event.data.menu).toggleClass('navigation-toggle--open');
    }

  };
});

var menu = (function ($) {
    var toggleButton = $('.navigation-main-button'),
        menu = $('.navigation-toggle');

    toggleButton.click({ button: toggleButton, menu: menu }, toggle);

    function toggle (event){
        event.preventDefault();
        $(event.data.button).toggleClass('navigation-main-button--open');
        $(event.data.menu).toggleClass( "navigation-toggle--open");
    }

    return {
        toggle: toggle
    };

})(jQuery);

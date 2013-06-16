(function($) {
    "use strict";
    $.fn.showLinkLocation = function() {

        return this.filter("a").append(function() {
            return " (" + this.href + ")";
        });

    };

}(jQuery));

(function($){
                    if (!window.requestAnimationFrame) {
                window.requestAnimationFrame = (window.webkitRequestAnimationFrame ||
window.mozRequestAnimationFrame ||
window.oRequestAnimationFrame ||
window.msRequestAnimationFrame ||
function (callback) {
return window.setTimeout(callback, 1000/60);
});
}
    $.fn.item = function(){
        var item = $(this).tmplItem().data;
        return($.isFunction(item.reload) ? item.reload() : null);
    };

    $.fn.forItem = function(item){
        return this.filter(function(){
            var compare = $(this).tmplItem().data;
            if (item.eql && item.eql(compare) || item === compare)
                return true;
        });
    };

    $.fn.autolink = function () {
        return this.each( function(){
            var re = /((http|https|ftp):\/\/[\w?=&.\/-;#~%-]+(?![\w\s?&.\/;#~%"=-]*>))/g;
            $(this).html( $(this).html().replace(re, '<a href="$1">$1</a> ') );
        });
    };

    $.fn.mailto = function () {
        return this.each( function() {
            var re = /(([a-z0-9*._+]){1,}\@(([a-z0-9]+[-]?){1,}[a-z0-9]+\.){1,}([a-z]{2,4}|museum)(?![\w\s?&.\/;#~%"=-]*>))/g
            $(this).html( $(this).html().replace( re, '<a href="mailto:$1">$1</a>' ) );
        });
    };

    	// ======================= imagesLoaded Plugin ===============================
	// https://github.com/desandro/imagesloaded

	// $('#my-container').imagesLoaded(myFunction)
	// execute a callback when all images have loaded.
	// needed because .load() doesn't work on cached images

	// callback function gets image collection as argument
	//  this is the container

	// original: mit license. paul irish. 2010.
	// contributors: Oren Solomianik, David DeSandro, Yiannis Chatzikonstantinou

	$.fn.imagesLoaded 		= function( callback ) {
	var $images = this.find('img'),
		len 	= $images.length,
		_this 	= this,
		blank 	= 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw==';

	function triggerCallback() {
		callback.call( _this, $images );
	}

	function imgLoaded() {
		if ( --len <= 0 && this.src !== blank ){
			setTimeout( triggerCallback );
			$images.unbind( 'load error', imgLoaded );
		}
	}

	if ( !len ) {
		triggerCallback();
	}

	$images.bind( 'load error',  imgLoaded ).each( function() {
		// cached images don't fire load sometimes, so we reset src.
		if (this.complete || this.complete === undefined){
			var src = this.src;
			// webkit hack from http://groups.google.com/group/jquery-dev/browse_thread/thread/eee6ab7b2da50e1f
			// data uri bypasses webkit log warning (thx doug jones)
			this.src = blank;
			this.src = src;
		}
	});

	return this;
	};

})(jQuery);
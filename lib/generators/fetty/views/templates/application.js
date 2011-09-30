
// jQuery Input Hints plugin
jQuery.fn.inputHints=function() {
    // show the display text
    $(this).each(function(i) {
        $(this).val($(this).attr('title'))
            .addClass('hint');
    });

    // hook up the blur & focus
    return $(this).focus(function() {
        if ($(this).val() == $(this).attr('title'))
            $(this).val('')
                .removeClass('hint');
    }).blur(function() {
        if ($(this).val() == '')
            $(this).val($(this).attr('title'))
                .addClass('hint');
    });
};

$(function() {
    
	// add hints on input text search
	$('input[title]').inputHints();
	// closable link for message
	$('.closelink').click(function() {
		$('div.flash').fadeOut(500, function() {
			$('div.flash').hide();
		});
	});	
  
  
	if (history && history.pushState) {
	  // handle index sort and pagination using ajax
	  $("#index_table th a, #index_table .pagination a").live("click", function(e) {
	    $.getScript(this.href);
	    history.pushState(null, document.title, this.href);
	    e.preventDefault();
	  });
	  // handle index input search keyup using ajax
	  $("#index_search input").keyup(function(e) {
	    $.get($("#index_search").attr("action"), $("#index_search").serialize(), null, "script");
	    history.replaceState(null, document.title, $("#index_search").attr("action") + "?" + $("#index_search").serialize());
	    e.preventDefault();
	  });
	  //bind window for postate
		$(window).bind("popstate", function() {
			$.getScript(location.href);
		});
	}
  
});

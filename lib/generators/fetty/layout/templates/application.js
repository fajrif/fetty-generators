// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

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
  // handle index sort and pagination using ajax
  $("#index_table th a, #index_table .pagination a").live("click", function() {
    $.getScript(this.href);
    return false;
  });
  // handle index input search keyup using ajax
  $("#index_search input").keyup(function() {
    $.get($("#index_search").attr("action"), $("#index_search").serialize(), null, "script");
    return false;
  });
});

$(document).ready(function() {
  $('input[title]').inputHints();
  $('.closelink').click(function() {
		$('div.flash').fadeOut(500, function() {
			$('div.flash').hide();
		});
	});	
});
$(function() {
	// Check all the checkboxes when the head one is selected
	$(".checkall").live("click", function() {
	    $("input[type='checkbox']").attr('checked', $(this).is(':checked'));   
	});
	
	// handle pagination through ajax
	$("#tabs-messages .pagination a").live("click", function(e) {
		$.getScript(this.href);
		history.pushState(null, document.title, this.href);
		e.preventDefault();
	});
	
	//bind window for postate
	$(window).bind("popstate", function() {
		$.getScript(location.href);
	});
		
});

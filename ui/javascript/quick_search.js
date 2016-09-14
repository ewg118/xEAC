/************************************
QUICKSEARCH
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
populates hidden query parameter in results page quick search
************************************/
$(function () {
	$('#qs_button') .click(function () {
		var search_text = $('#qs_text') .attr('value');
		var query = $('#qs_query').attr('value');
		if (search_text != null && search_text != '') {
			if (query == '*:*') {
				$('#qs_query') .attr('value', 'text:' + search_text);
			} else {
				$('#qs_query') .attr('value', query + ' AND text:' + search_text);
			}
		} else {
			$('#qs_query') .attr('value', '*:*');
		}
	});
});
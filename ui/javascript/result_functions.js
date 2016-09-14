$(document).ready(function () {

	$('.sortForm_categories') .change(function () {
		var field = $(this).val();
		var sort_order = $('.sortForm_order').val();
		setValue(field, sort_order);
	});
	$('.sortForm_order') .change(function () {
		var field = $('.sortForm_categories').val();
		var sort_order = $(this).val();
		setValue(field, sort_order);
	});
	
	function setValue(field, sort_order) {
		var category;
		if (field.indexOf('_') > 0 || field == 'timestamp') {
			category = field;
		} else {
			if (sort_order == 'asc') {
				switch (field) {
					case 'year':
					category = field + '_minint';
					break;
					default:
					category = field + '_min';
				}
			} else if (sort_order == 'desc') {
				switch (field) {
					case 'year':
					category = field + '_maxint';
					break;
					default:
					category = field + '_max';
				}
			}
		}
		if (field != 'null') {
			$('.sort_button') .removeAttr('disabled');
			$('.sort_param') .attr('value', category + ' ' + sort_order);
		} else {
			$('.sort_button') .attr('disabled', 'disabled');
		}
	}
	
	$('#qs_form').submit(function () {
		assembleQuery();
	});
	
	function assembleQuery() {
		var search_text = $('#qs_text') .val();
		var query = $('#qs_query').val();
		if (search_text != null && search_text != '') {
			if (query == '*:*' || query.length == 0) {
				$('#qs_query') .attr('value', 'text:' + search_text);
			} else {
				$('#qs_query') .attr('value', query + ' AND text:' + search_text);
			}
		} else {
			$('#qs_query') .attr('value', '*:*');
		}
	}
});
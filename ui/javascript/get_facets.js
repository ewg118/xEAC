/************************************
GET FACET TERMS IN RESULTS PAGE
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: This utilizes ajax to populate the list of terms in the facet category in the results page.
If the list is populated and then hidden, when it is re-activated, it fades in rather than executing the ajax call again.
************************************/
$(document).ready(function () {
	var popupStatus = 0;
	var path = '../';
	var langStr = getURLParameter('lang');
	if (langStr == 'null') {
		var lang = '';
	} else {
		var lang = langStr;
	}
	//dateLabel();
	
	$("#backgroundPopup").click(function () {
		disablePopup();
	});
	
	
	$('.multiselect').multiselect({
		buttonWidth: '250px',
		enableFiltering: true,
		maxHeight: 250,
		buttonText: function (options, select) {
			if (options.length == 0) {
				return select.attr('title') + ' <b class="caret"></b>';
			} else if (options.length > 2) {
				return select.attr('title') + ': ' + options.length + ' selected <b class="caret"></b>';
			} else {
				var selected = '';
				options.each(function () {
					selected += $(this).text() + ', ';
				});
				return select.attr('title') + ': ' + selected.substr(0, selected.length - 2) + ' <b class="caret"></b>';
			}
		}
	});
	
	//on open
	$('button.multiselect').on('click', function () {
		var q = getQuery();
		var id = $(this).parent('div').prev('select').attr('id');
		var category = id.split('-select')[0];
		$.get(path + 'get_facets/', {
			q: q, category: category, sort: 'index', lang: lang
		},
		function (data) {
			$('#ajax-temp').html(data);
			$('#' + id) .html('');
			$('#ajax-temp option').each(function () {
				$(this).clone().appendTo('#' + id);
			});
			$("#" + id).multiselect('rebuild');
		});
	});
	
	$('#search_button') .click(function () {
		var q = getQuery();
		window.location = './?q=' + q;
		return false;
	});
	
	/***************************/
	//@Author: Adrian "yEnS" Mato Gondelle
	//@website: www.yensdesign.com
	//@email: yensamg@gmail.com
	//@license: Feel free to use it, but keep this credits please!
	/***************************/
	
	//disabling popup with jQuery magic!
	function disablePopup() {
		//disables popup only if it is enabled
		if (popupStatus == 1) {
			$("#backgroundPopup").fadeOut("fast");
			$('#century_sint-list') .parent('div').attr('style', 'width: 192px;');
			popupStatus = 0;
		}
	}
	
	function getURLParameter(name) {
		return decodeURI(
		(RegExp(name + '=' + '(.+?)(&|$)').exec(location.search) ||[, null])[1]);
	}
});
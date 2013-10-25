/************************************
GET FACET TERMS IN RESULTS PAGE
Written by Ethan Gruber, gruber@numismatics.org
Library: jQuery
Description: This utilizes ajax to populate the list of terms in the facet category in the results page.  
If the list is populated and then hidden, when it is re-activated, it fades in rather than executing the ajax call again.
************************************/
$(document).ready(function() {
	var popupStatus = 0;
	var pipeline = $('#pipeline').text();
	if (pipeline == 'maps' || pipeline == 'results') {
		var path = '../';
	} else if (pipeline == 'maps_fullscreen') {
		var path = '../../';
	}
	var langStr = getURLParameter('lang');
	if (langStr == 'null'){
		var lang = '';
	} else {
		var lang = langStr;
	}
	dateLabel();
	
	//hover over remove facet link
	$(".remove_filter").hover(
		function () {
			$(this).parent().addClass("ui-state-hover");
		},
		function () {
			$(this).parent().removeClass("ui-state-hover");
		}
	);
	$("#clear_all").hover(
		function () {
			$(this).parent().addClass("ui-state-hover");
		},
		function () {
			$(this).parent().removeClass("ui-state-hover");
		}
	);
	
	$("#backgroundPopup").click(function() {
		disablePopup();
	});
	
	//enable multiselect
	$(".multiselect").multiselect({
		//selectedList: 3,
		minWidth: 'auto',
		header: '<a class="ui-multiselect-none" href="#"><span class="ui-icon ui-icon-closethick"/><span>Uncheck all</span></a>',
		create: function () {
			var title = $(this).attr('title');
			var array_of_checked_values = $(this).multiselect("getChecked").map(function () {
				return this.value;
			}).get();
			var length = array_of_checked_values.length;
			//fix spacing
			if (length > 3) {
				$(this).next('button').children('span:nth-child(2)').text(title + ': ' + length + ' selected');
			} else if (length > 0 && length <= 3) {
				$(this).next('button').children('span:nth-child(2)').text(title + ': ' + array_of_checked_values.join(', '));
			} else if (length == 0) {
				$(this).next('button').children('span:nth-child(2)').text(title);
			}
		},
		beforeopen: function () {
			var id = $(this) .attr('id');
			var q = getQuery();
			var category = id.split('-select')[0];			
			$.get(path + 'get_facets/', {
				q: q, category: category, sort: 'index', limit: - 1, lang: lang, pipeline: pipeline
			},
			function (data) {
				$('#ajax-temp').html(data);
				$('#' + id) .html('');
				$('#ajax-temp option').each(function(){
					$(this).clone().appendTo('#' + id);
				});
					$("#" + id).multiselect('refresh');
				});
		},
		//close menu: restore button title if no checkboxes are selected
		close: function () {
			var title = $(this).attr('title');
			var id = $(this) .attr('id');
			var array_of_checked_values = $(this).multiselect("getChecked").map(function () {
				return this.value;
			}).get();
			if (array_of_checked_values.length == 0) {
				$(this).next('button').children('span:nth-child(2)').text(title);
			}
		},
		click: function () {
			var title = $(this).attr('title');
			var id = $(this) .attr('id');
			var array_of_checked_values = $(this).multiselect("getChecked").map(function () {
				return this.value;
			}).get();
			var length = array_of_checked_values.length;
			if (length > 3) {
				$(this).next('button').children('span:nth-child(2)').text(title + ': ' + length + ' selected');
			} else if (length > 0 && length <= 3) {
				var label = title + ': ' + array_of_checked_values.join(', ');
				$(this).next('button').children('span:nth-child(2)').text(label);
			} else if (length == 0) {
				var q = getQuery();
				if (q.length > 0) {
					var category = id.split('-select')[0];
					$.get(path + 'get_facets/', {
						q: q, category: category, sort: 'index', limit: - 1, lang: lang, pipeline: pipeline
					},
					function (data) {
						$('#ajax-temp').html(data);
						$('#' + id) .html('');
						$('#ajax-temp option').each(function(){
							$(this).clone().appendTo('#' + id);
						});
						$("#" + id).multiselect('refresh');
					});
				}
			}
		},
		uncheckAll: function () {
			var id = $(this) .attr('id');
			var q = getQuery();
			if (q.length > 0) {
				var category = id.split('-select')[0];
				var mincount = $(this).attr('mincount');
				$.get(path + 'get_facets/', {
					q: q, category: category, sort: 'index', limit: - 1, lang: lang, pipeline: pipeline
				},
				function (data) {
					$('#ajax-temp').html(data);
					$('#' + id) .html('');
					$('#ajax-temp option').each(function(){
						$(this).clone().appendTo('#' + id);
					});
					$("#" + id).multiselect('refresh');
				});
			}
		}
	}).multiselectfilter();
	
	//handle expandable dates
	$('#century_sint_link').hover(function () {
    		$(this) .attr('class', 'ui-multiselect ui-widget ui-state-default ui-corner-all ui-state-focus');
	}, 
	function () {
		$(this) .attr('class', 'ui-multiselect ui-widget ui-state-default ui-corner-all');
	});
	
	$('.century-close') .click(function(){
		disablePopup();
	});
	
	$('#century_sint_link').click(function () {
		if (popupStatus == 0) {
			$("#backgroundPopup").fadeIn("fast");
			popupStatus = 1;
		
		}
		var list_id = $(this) .attr('id').split('_link')[0] + '-list';
		$('#' + list_id).parent('div').attr('style', 'width: 192px;display:block;');
	});
	
	$('.expand_century').click(function(){
		var century = $(this).attr('century');
		var q = $(this).attr('q'); 
		var expand_image = $(this).children('img').attr('src');
		//hide list if it is expanded
		if (expand_image.indexOf('minus') > 0){
			$(this).children('img').attr('src', expand_image.replace('minus','plus'));
			$('#century_' + century + '_list') .hide();
		} else{
			$(this).children('img').attr('src', expand_image.replace('plus','minus'));
			//perform ajax load on first click of expand button
			if ($(this).parent('li').children('ul').html().indexOf('<li') < 0){				
				$.get(path + 'get_decades/', {
					q: q, century: century, pipeline: pipeline
					}, function (data) {
						$('#decades-temp').html(data);
						$('#decades-temp li').each(function(){
							$(this).clone().appendTo('#century_' + century + '_list');
						});
					}
				);
			}
			$('#century_' + century + '_list') .show();			
		}
	});
	
	//check parent century box when a decade box is checked
	$('.decade_checkbox').livequery('click', function(event){
		if ($(this) .is(':checked')) {
			//alert('test');
			$(this) .parent('li').parent('ul').parent('li') .children('input') .attr('checked', true);			
		}
		//set label
		dateLabel();
	});
	//uncheck child decades when century is unchecked
	$('.century_checkbox').livequery('click', function(event){
		if ($(this).not(':checked')) {
			$(this).parent('li').children('ul').children('li').children('.decade_checkbox').attr('checked',false);
		}
		//set label
		dateLabel();
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
	        (RegExp(name + '=' + '(.+?)(&|$)').exec(location.search)||[,null])[1]
	    );
	}
});
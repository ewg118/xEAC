$(document).ready(function () {
	var id = $('#id').text();	
	$('.toggle-button').click(function () {
		var div_id = $(this).attr('id').split('-')[1] + '-div';
		if ($(this).children('span').hasClass('glyphicon-triangle-bottom')) {
			$(this).children('span').removeClass('glyphicon-triangle-bottom');
			$(this).children('span').addClass('glyphicon-triangle-right');
		} else {
			$(this).children('span').removeClass('glyphicon-triangle-right');
			$(this).children('span').addClass('glyphicon-triangle-bottom');
		}
		$('#' + div_id).toggle('fast');
		return false;
	});
	
	if ($('#mappable').text()=='true'){
		initialize_timemap(id);
	}
});

function initialize_timemap(id) {
	var url = $('#url').text() + "api/get?id=" + id + "&format=json&model=timemap&mode=static";
	var datasets = new Array();
	
	//first dataset
	datasets.push({
		id: 'dist',
		title: "Distribution",
		type: "json",
		options: {
			url: url
		}
	});
	
	var tm;
	tm = TimeMap.init({
		mapId: "map", // Id of map div element (required)
		timelineId: "timeline", // Id of timeline div element (required)
		options: {
			mapType: "physical",
			eventIconPath: "../ui/images/timemap/"
		},
		datasets: datasets,
		bandIntervals:[
		Timeline.DateTime.YEAR,
		Timeline.DateTime.DECADE]
	});
}
$(document).ready(function () {
	var id = $('#id').text();	
	initialize_timemap(id);
	/*$('#toggle_names').click(function () {
		$('#names').toggle('show');
		return false;
	});*/
});

function initialize_timemap(id) {
	var url = "../api/get?id=" + id + "&format=json";
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
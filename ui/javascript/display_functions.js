$(document).ready(function () {
	var id = $('#id').text();	
	$('#toggle_names').click(function () {
		$('#names').toggle('show');
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
			eventIconPath: "http://numismatics.org/authorities/ui/images/timemap/"
		},
		datasets: datasets,
		bandIntervals:[
		Timeline.DateTime.YEAR,
		Timeline.DateTime.DECADE]
	});
}
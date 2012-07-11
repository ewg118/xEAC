function initialize_timemap(id) {
	var tm;
	tm = TimeMap.init({
		mapId: "map", // Id of map div element (required)
		timelineId: "timeline", // Id of timeline div element (required)
		options: {
			eventIconPath: "../images/timemap/"
		},
		datasets:[ {
			title: "Title",
			theme: "red",
			type: "kml", // Data to be loaded in KML - must be a local URL
			options: {
				url: id + ".kml" // KML file to load
			}
		}],
		bandIntervals:[
		Timeline.DateTime.DECADE,
		Timeline.DateTime.CENTURY]
	});
}
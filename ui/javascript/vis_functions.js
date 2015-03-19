$(document).ready(function () {
	var nodes = $.getJSON('../api/nodes?id=' + $('#id').text()).done(function (nodes) {
		getEdges(nodes);
	});
});

function getEdges(nodes) {
	var edges = $.getJSON('../api/edges?id=' + $('#id').text()).done(function (edges) {
		var data = {
			nodes: nodes,
			edges: edges
		};
		draw(data);
	});
}

function draw(data) {
	// create a network
	var container = document.getElementById('network');
	
	var options = {
	};
	var network = new vis.Network(container, data, options);
}
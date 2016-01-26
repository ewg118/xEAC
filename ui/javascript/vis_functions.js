
$(document).ready(function () {
	var nodes, edges, network;
	
	//load nodes and edges asynchronously
	nodesObj = JSON.parse($.ajax({
		type: "GET",
		url: '../api/nodes?id=' + $('#id').text(),
		async: false
	}).responseText);
	edgesObj = JSON.parse($.ajax({
		type: "GET",
		url: '../api/edges?id=' + $('#id').text(),
		async: false
	}).responseText);
	
	nodes = new vis.DataSet(nodesObj);
	edges = new vis.DataSet(edgesObj);
	var data = {
		nodes: nodes,
		edges: edges
	}
	
	//draw graph
	draw(data);
	
	function draw(data) {
		// create a network
		var container = document.getElementById('network');
		
		var options = {
			interaction: {
				hover: true
			}
		};
		network = new vis.Network(container, data, options);
		
		//expand node on click
		network.on("selectNode", function (params) {
			var id = params.nodes[0];
			expandNodes(data, id);
			expandEdges(data, id);
			network.stabilize();
		});
	}
	
	function expandNodes(data, id) {
		nodesObj = JSON.parse($.ajax({
			type: "GET",
			url: '../api/nodes?id=' + id,
			async: false
		}).responseText);
		
		//iterate through each new node in the response, and only add new nodes
		$.each (nodesObj, function (i, node) {
			var nodeExists = validateNode(data, node.id);
			//alert(nodeExists);
			if (nodeExists == false) {
				try {
					nodes.add({
						id: node.id,
						label: node.label,
						title: node.title
					});
				}
				catch (err) {
					alert(err);
				}
			}
		});
	}
	
	function expandEdges(data, id) {
		edgesObj = JSON.parse($.ajax({
			type: "GET",
			url: '../api/edges?id=' + id,
			async: false
		}).responseText);
		
		//iterate through each new node in the response, and only add new nodes
		$.each (edgesObj, function (i, edge) {
			var edgeExists = validateEdge(data, edge.from, edge.to);
			if (edgeExists == false) {
				try {
					edges.add({
						from: edge.from,
						to: edge.to,
						label: edge.label
					});
				}
				catch (err) {
					alert(err);
				}
			}
		});
	}
	
	function validateNode(data, id) {
		var exists = false;
		var nodes = data.nodes._data;
		$.each(nodes, function (i, node) {
			if (node.id == id) {
				exists = true;
			}
		});
		return exists;
	}
	
	function validateEdge(data, from, to) {
		var exists = false;
		var edges = data.edges._data;
		$.each(edges, function (i, edge) {
			if (edge.from == from && edge.to == to) {
				exists = true;
			}
		});
		return exists;
	}
	
	/*function addEdge() {
	try {
	edges.add({
	from: 'newell',
	to: 'noe',
	label: 'xeac:correspondedWith'
	});
	}
	catch (err) {
	alert(err);
	}
	}*/
});
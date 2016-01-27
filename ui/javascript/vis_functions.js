

$(document).ready(function () {
	var url = $('#url').text();
	var nodes, edges, network;
	
	//load nodes and edges asynchronously
	nodesObj = JSON.parse($.ajax({
		type: "GET",
		url: url + 'api/nodes?id=' + $('#id').text(),
		async: false
	}).responseText);
	edgesObj = JSON.parse($.ajax({
		type: "GET",
		url: url + 'api/edges?id=' + $('#id').text(),
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
			var clickable;
			var nodes = data.nodes._data;
			$.each(nodes, function (i, node) {
				if (node.id == id) {
					clickable = node.clickable;
				}
			});
			
			if (clickable == true) {
				expandNodes(data, id);
				expandEdges(data, id);
				network.stabilize();
			}
		});
	}
	
	
	function expandNodes(data, id) {
		nodesObj = JSON.parse($.ajax({
			type: "GET",
			url: url + 'api/nodes?id=' + id,
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
						title: node.title,
						clickable: node.clickable,
						shape: node.shape,
						color: node.color,
						value: node.value
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
			url: url + 'api/edges?id=' + id,
			async: false
		}).responseText);
		
		//iterate through each new node in the response, and only add new nodes
		$.each (edgesObj, function (i, edge) {
			var edgeExists = validateEdge(data, edge.from, edge.to, edge.label, edge.id);
			if (edgeExists == false) {
				try {
					edges.add({
						id: edge.id,
						from: edge.from,
						to: edge.to,
						label: edge.label,
						color: edge.color,
						arrows: 'to'
					});
				}
				catch (err) {
					alert(err);
				}
			} else {
				try {
					edges.update({
						id: edge.id,
						arrows: 'to, from'
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
	
	function validateEdge(data, from, to, label, id) {
		var exists = false;
		var edges = data.edges._data;
		$.each(edges, function (i, edge) {
			//ignore adding edges to self-click
			if (id == edge.id && label == edge.label) {
				exists = true;
			}
		});
		return exists;
	}
});

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
		
		var options = {interaction:{hover:true}};
		network = new vis.Network(container, data, options);
		
		//expand node on click
		/*network.on("selectNode", function (params) {
			addEdge();
		});	*/	
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
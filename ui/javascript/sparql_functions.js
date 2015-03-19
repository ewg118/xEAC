$(document).ready(function () {
	var editor = CodeMirror.fromTextArea(document.getElementById("code"), {
		mode: "application/x-sparql-query",
		matchBrackets: true
	});
});
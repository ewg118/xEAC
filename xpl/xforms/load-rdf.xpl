<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">
	
	<p:param type="input" name="file"/>
	<p:param type="output" name="data"/>
	
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#file"/>		
		<p:output name="data" ref="data"/>
	</p:processor>
</p:pipeline>


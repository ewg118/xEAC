<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: http://code.google.com/p/eaditor/
	Apache License 2.0: http://code.google.com/p/eaditor/
	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>	
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="config.xpl"/>		
		<p:output name="data" id="config"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">		
		<p:input name="data" href="aggregate('content', #data, #config)"/>		
		<p:input name="config" href="../ui/xslt/eac-to-kml.xsl"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
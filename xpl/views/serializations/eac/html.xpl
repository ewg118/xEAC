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
	
	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>				
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../../../models/config.xpl"/>		
		<p:output name="data" id="config"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">		
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:template match="/">
					<xsl:variable name="sparql_endpoint" select="/config/sparql/query"/>
					<sparql>
						<xsl:value-of select="matches($sparql_endpoint, 'https?://')"/>
					</sparql>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="sparql_url"/>
	</p:processor>
	
	<p:choose href="#sparql_url">
		<p:when test="/sparql = true()">
			<p:processor name="oxf:unsafe-xslt">				
				<p:input name="data" href="#config"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">						
						<!-- config variables -->
						<xsl:variable name="sparql_endpoint" select="/config/sparql/query"/>
						
						<xsl:variable name="service">
							<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri('ASK { ?s ?p ?o }'), '&amp;output=xml')"/>
						</xsl:variable>
						
						<xsl:template match="/">
							<config>
								<url>
									<xsl:value-of select="$service"/>
								</url>
								<content-type>application/sparql-results+xml</content-type>								
								<encoding>utf-8</encoding>
							</config>
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="url-generator-config"/>
			</p:processor>		
			
			<p:processor name="oxf:url-generator">
				<p:input name="config" href="#url-generator-config"/>
				<p:output name="data" id="url-data"/>
			</p:processor>
			
			<p:processor name="oxf:exception-catcher">
				<p:input name="data" href="#url-data"/>
				<p:output name="data" id="url-data-checked"/>
			</p:processor>
			
			<p:choose href="#url-data-checked">
				<p:when test="/exceptions">
					<p:processor name="oxf:identity">
						<p:input name="data" >
							<sparql>false</sparql>
						</p:input>
						<p:output name="data" id="sparql-enabled"/>
					</p:processor>	
					
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="request" href="#request"/>		
						<p:input name="data" href="aggregate('content', #data, #config, #sparql-enabled)"/>
						<p:input name="config" href="../../../../ui/xslt/serializations/eac/html.xsl"/>
						<p:output name="data" id="model"/>
					</p:processor>
				</p:when>
				<p:otherwise>
					<p:processor name="oxf:identity">
						<p:input name="data" >
							<sparql>true</sparql>
						</p:input>
						<p:output name="data" id="sparql-enabled"/>
					</p:processor>
					
					<!-- execute related resources and annotations SPARQL queries -->
					<p:processor name="oxf:pipeline">
						<p:input name="config" href="../../../models/sparql/relatedResources.xpl"/>		
						<p:output name="data" id="relatedResources"/>
					</p:processor>
					
					<p:processor name="oxf:pipeline">
						<p:input name="config" href="../../../models/sparql/annotations.xpl"/>		
						<p:output name="data" id="annotations"/>
					</p:processor>
					
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="request" href="#request"/>		
						<p:input name="data" href="aggregate('content', #data, #config, #sparql-enabled, #relatedResources, #annotations)"/>
						<p:input name="config" href="../../../../ui/xslt/serializations/eac/html.xsl"/>
						<p:output name="data" id="model"/>
					</p:processor>
				</p:otherwise>
			</p:choose>
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:identity">
				<p:input name="data" >
					<sparql>false</sparql>
				</p:input>
				<p:output name="data" id="sparql-enabled"/>
			</p:processor>
			
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="request" href="#request"/>		
				<p:input name="data" href="aggregate('content', #data, #config, #sparql-enabled)"/>
				<p:input name="config" href="../../../../ui/xslt/serializations/eac/html.xsl"/>
				<p:output name="data" id="model"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
	
	<!--<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>		
		<p:input name="data" href="aggregate('content', #data, #config, #sparql-enabled)"/>
		<p:input name="config" href="../../../../ui/xslt/serializations/eac/html.xsl"/>
		<p:output name="data" id="model"/>
	</p:processor>-->
	
	<p:processor name="oxf:html-serializer">
		<p:input name="data" href="#model"/>
		<p:input name="config">
			<config>
				<version>5.0</version>
				<indent>true</indent>
				<content-type>text/html</content-type>
				<encoding>utf-8</encoding>
				<indent-amount>4</indent-amount>
			</config>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
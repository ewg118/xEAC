<?xml version="1.0" encoding="UTF-8"?>
<!--
	XPL handling SPARQL queries from Fuseki	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

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
		<p:input name="config" href="../config.xpl"/>		
		<p:output name="data" id="config"/>
	</p:processor>

	<!-- generator config for URL generator -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:variable name="uri" select="concat(/config/uri_space, doc('input:request')/request/parameters/parameter[name='id']/value)"/>				

				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="/config/sparql/query"/>
				
				<xsl:variable name="query">
					<![CDATA[PREFIX rdf:	<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX arch:	<http://purl.org/archival/vocab/arch#>
PREFIX bio:	<http://purl.org/vocab/bio/0.1/>
PREFIX crm:	<http://erlangen-crm.org/current/>
PREFIX dcterms:	<http://purl.org/dc/terms/>
PREFIX edm:	<http://www.europeana.eu/schemas/edm/>
PREFIX foaf:	<http://xmlns.com/foaf/0.1/>
PREFIX org:	<http://www.w3.org/ns/org#>
PREFIX rel:	<http://purl.org/vocab/relationship/>
PREFIX skos:	<http://www.w3.org/2004/02/skos/core#>
PREFIX xeac:	<https://github.com/ewg118/xEAC#>
PREFIX xsd:	<http://www.w3.org/2001/XMLSchema#>

SELECT ?sourceName ?type ?target ?name ?class WHERE {
<URI> foaf:name ?sourceName ;
       bio:relationship ?rel .
  ?rel xeac:relationshipType ?type ;
       bio:participant ?target .
  ?target foaf:name ?name ;
          a ?class
       
}]]>
				</xsl:variable>

				<xsl:variable name="service">
					<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri(replace($query, 'URI', $uri)), '&amp;output=xml')"/>					
				</xsl:variable>

				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="$service"/>
						</url>
						<content-type>application/xml</content-type>
						<encoding>utf-8</encoding>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="url-generator-config"/>
	</p:processor>

	<!-- get the data from fuseki -->
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#url-generator-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>

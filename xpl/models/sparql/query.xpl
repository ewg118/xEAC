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
		<p:input name="data" href="#data"/>
		<p:input name="config-xml" href="#config"/>
		<p:input name="request" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:param name="query" select="doc('input:request')/request/parameters/parameter[name='query']/value"/>
				<xsl:variable name="content-type" select="/content-type"/>
				<xsl:variable name="output">
					<xsl:choose>
						<xsl:when test="$content-type='text/csv'">csv</xsl:when>
						<xsl:when test="$content-type='text/plain' or $content-type='text/turtle'">text</xsl:when>
						<xsl:when test="contains($content-type, 'json')">json</xsl:when>
						<xsl:otherwise>xml</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="doc('input:config-xml')/config/sparql/query"/>
				
				<xsl:variable name="service">
					<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri($query), '&amp;output=', $output)"/>
				</xsl:variable>
				
				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="$service"/>
						</url>
						<content-type>
							<xsl:choose>
								<xsl:when test="$content-type='text/turtle'">text/turtle</xsl:when>
								<xsl:when test="$content-type='text/csv'">text/csv</xsl:when>
								<xsl:when test="$content-type='text/plain'">text/plain</xsl:when>
								<xsl:when test="contains($content-type, 'json')">application/json</xsl:when>
								<xsl:otherwise>application/xml</xsl:otherwise>
							</xsl:choose>
						</content-type>
						<xsl:if test="contains($content-type, 'json') or $content-type='text/turtle'">
							<mode>text</mode>
						</xsl:if>
						<encoding>utf-8</encoding>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<!--<p:output name="data" ref="data"/>-->
		<p:output name="data" id="url-generator-config"/>
	</p:processor>
	
	<!-- get the data from fuseki -->
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#url-generator-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>

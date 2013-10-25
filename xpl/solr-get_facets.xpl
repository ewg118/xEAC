<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: http://code.google.com/p/eaditor/
	Apache License 2.0: http://code.google.com/p/eaditor/
	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>
	
	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request/parameters</include>
			</config>
		</p:input>
		<p:output name="data" id="params"/>
	</p:processor>
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="config.xpl"/>		
		<p:output name="data" id="config"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="params" href="#params"/>
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">				
				<!-- url params -->
				<xsl:param name="q" select="doc('input:params')/request/parameters/parameter[name='q']/value"/>
				<xsl:param name="lang" select="doc('input:params')/request/parameters/parameter[name='lang']/value"/>
				<xsl:param name="category" select="doc('input:params')/request/parameters/parameter[name='category']/value"/>
				<xsl:param name="pipeline" select="doc('input:params')/request/parameters/parameter[name='pipeline']/value"/>
				<xsl:param name="sort" select="doc('input:params')/request/parameters/parameter[name='sort']/value"/>
				
				<!-- config variables -->
				<xsl:variable name="solr-url" select="concat(/config/solr_published, 'select/')"/>				
								
				<xsl:variable name="service">
					<xsl:choose>
						<xsl:when test="$pipeline='results'">
							<xsl:value-of select="concat($solr-url, '?q=', encode-for-uri($q), '&amp;facet.field=', $category, '&amp;facet.sort=', $sort, '&amp;rows=0')"/>
						</xsl:when>
						<xsl:when test="$pipeline='maps'">
							<xsl:value-of select="concat($solr-url, '?q=', encode-for-uri(concat($q, ' AND georef:*')), '&amp;facet.field=', $category, '&amp;facet.sort=', $sort, '&amp;rows=0')"/>
						</xsl:when>			
					</xsl:choose>
				</xsl:variable>
				
				<xsl:template match="/">
					<xsl:copy-of select="document($service)/response"/>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>


</p:config>

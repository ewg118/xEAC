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
		<p:input name="config" href="../config.xpl"/>
		<p:output name="data" id="config"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="params" href="#params"/>
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<!-- url params -->
				<xsl:param name="q" select="doc('input:params')/request/parameters/parameter[name='q']/value"/>
				<xsl:param name="start" select="if (number(doc('input:params')/request/parameters/parameter[name='start']/value)) then
					doc('input:params')/request/parameters/parameter[name='start']/value else 0" as="xs:integer"/>
				<xsl:param name="sort" select="doc('input:params')/request/parameters/parameter[name='sort']/value"/>

				<xsl:param name="rows" as="xs:integer">100</xsl:param>

				<!-- config variables -->
				<xsl:variable name="solr-url" select="concat(/config/solr_published, 'select/')"/>
				<xsl:variable name="service">
					<xsl:choose>
						<xsl:when test="string($q)">
							<xsl:choose>
								<xsl:when test="string($sort)">
									<xsl:value-of select="concat($solr-url, '?q=', encode-for-uri($q), '&amp;sort=', encode-for-uri($sort), '&amp;start=',$start, '&amp;rows=100')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat($solr-url, '?q=', encode-for-uri($q), '&amp;sort=timestamp%20desc&amp;start=',$start, '&amp;rows=100')"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="string($sort)">
									<xsl:value-of select="concat($solr-url, '?q=*:*&amp;sort=', encode-for-uri($sort), '&amp;start=',$start, '&amp;rows=100')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat($solr-url, '?q=*:*&amp;sort=timestamp%20desc&amp;start=',$start, '&amp;rows=100')"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>

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
		<p:output name="data" id="generator-config"/>
	</p:processor>

	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#generator-config"/>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>

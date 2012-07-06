<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="xs" version="2.0">
	<xsl:output method="xml" encoding="UTF-8"/>
	<!-- change eXist URL if running on a server other than localhost -->
	<xsl:variable name="exist-url" select="/exist-url"/>
	<!-- load config.xml from eXist into a variable which is later processed with exsl:node-set -->
	<xsl:variable name="config" select="document(concat($exist-url, 'xeac/config.xml'))"/>
	<xsl:variable name="solr-url" select="concat(exsl:node-set($config)/config/solr_published, 'select/')"/>
	
	<xsl:param name="q">
		<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
	</xsl:param>
	<xsl:param name="category">
		<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='category']/value"/>
	</xsl:param>
	<xsl:param name="sort">
		<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='sort']/value"/>
	</xsl:param>
	<xsl:param name="limit" as="xs:integer">
		<xsl:value-of select="doc('input:request')/request/parameters/parameter[name='limit']/value"/>
	</xsl:param>
	<xsl:variable name="service">
		<xsl:value-of select="concat($solr-url, '?q=', encode-for-uri($q), '&amp;facet.field=', $category, '&amp;facet.sort=', $sort, '&amp;rows=0&amp;facet.limit=-1')"/>
	</xsl:variable>
	<xsl:param name="tokenized_q" select="tokenize($q, ' AND ')"/>
	
	<xsl:template match="/">
		<html>
			<head>
				<title>test</title>
			</head>
			<body>
				<select>
					<xsl:apply-templates select="document($service)/descendant::lst[@name='facet_fields']/lst[@name=$category]"/>
				</select>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="lst[@name=$category]">
		<xsl:for-each select="int">
			<xsl:variable name="matching_term">
				<xsl:value-of select="concat($category, ':&#x022;', @name, '&#x022;')"/>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="contains($q, $matching_term)">
					<option value="{@name}" selected="selected">
						<xsl:value-of select="@name"/>
					</option>
				</xsl:when>
				<xsl:otherwise>
					<option value="{@name}">
						<xsl:value-of select="@name"/>
					</option>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>

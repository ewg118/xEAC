<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#" exclude-result-prefixes="#all"
	version="2.0">


	<xsl:template match="/">
		<xsl:text>[</xsl:text>
		<!-- source -->
		<xsl:variable name="source">
			<xsl:text>{"id": 1, "label" : "</xsl:text>
			<xsl:value-of select="descendant::res:result[1]/res:binding[@name='sourceName']/res:literal"/>
			<xsl:text>", "shape": "ellipse" },</xsl:text>			
		</xsl:variable>
		<xsl:value-of select="normalize-space($source)"/>
		<xsl:apply-templates select="descendant::res:result"/>
		<xsl:text>]</xsl:text>
	</xsl:template>

	<xsl:template match="res:result">
		<xsl:variable name="line">
			<xsl:text>{"id": </xsl:text>
			<xsl:value-of select="position() + 1"/>
			<xsl:text>, "label": "</xsl:text>
			<xsl:value-of select="res:binding[@name='name']/res:literal"/>
			<xsl:text>", "shape": "box" }</xsl:text>
			<xsl:if test="not(position()=last())">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:variable>

		<xsl:value-of select="normalize-space($line)"/>
	</xsl:template>
</xsl:stylesheet>

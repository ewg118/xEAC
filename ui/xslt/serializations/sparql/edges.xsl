<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#" exclude-result-prefixes="#all"
	version="2.0">
	
	<xsl:variable name="namespaces" as="item()*">
		<namespaces>
			<xsl:for-each select="//config/descendant::localTypeDeclaration">
				<namespace prefix="{abbreviation}" uri="{citation/@href}"/>
			</xsl:for-each>
		</namespaces>
	</xsl:variable>


	<xsl:template match="/">
		<xsl:text>[</xsl:text>
		<xsl:apply-templates select="descendant::res:result"/>
		<xsl:text>]</xsl:text>
	</xsl:template>

	<xsl:template match="res:result">
		<xsl:variable name="uri" select="res:binding[@name='type']/res:uri"/>
		
		<xsl:variable name="line">
			<xsl:text>{"from": 1, "to": </xsl:text>
			<xsl:value-of select="position() + 1"/>
			<xsl:text>, "label": "</xsl:text>
			<xsl:value-of select="replace($uri, $namespaces//namespace[contains($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))"/>
			<xsl:text>", "style": "line", "width": 2 }</xsl:text>
			<xsl:if test="not(position()=last())">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:variable>

		<xsl:value-of select="normalize-space($line)"/>
	</xsl:template>
</xsl:stylesheet>

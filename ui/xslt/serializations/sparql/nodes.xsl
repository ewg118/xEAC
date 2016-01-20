<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#" exclude-result-prefixes="#all"
	version="2.0">

	<xsl:param name="id" select="doc('input:request')/request/parameters/parameter[name='id']/value"/>

	<xsl:template match="/">
		<xsl:variable name="structure" as="element()*">
			<structure>
				<id>
					<xsl:value-of select="$id"/>
				</id>
				<label>
					<xsl:value-of select="if (contains(descendant::res:result[1]/res:binding[@name='sourceName']/res:literal, ',')) then
						substring-before(descendant::res:result[1]/res:binding[@name='sourceName']/res:literal, ',') else descendant::res:result[1]/res:binding[@name='sourceName']/res:literal"/>
				</label>
				<title>
					<xsl:value-of select="descendant::res:result[1]/res:binding[@name='sourceName']/res:literal"/>
				</title>
				<shape>ellipse</shape>
			</structure>
		</xsl:variable>
		<xsl:variable name="line">
			<xsl:text>{</xsl:text>
			<xsl:apply-templates select="$structure/*" mode="json"/>
			<xsl:text>}</xsl:text>
		</xsl:variable>


		<xsl:text>[</xsl:text>
		<!-- source -->
		<xsl:value-of select="normalize-space($line)"/>
		<xsl:text>,</xsl:text>
		<xsl:apply-templates select="descendant::res:result"/>
		<xsl:text>]</xsl:text>
	</xsl:template>

	<xsl:template match="res:result">
		<xsl:variable name="structure" as="element()*">
			<structure>
				<id>
					<xsl:choose>
						<xsl:when test="res:binding[@name='target']/res:bnode">
							<xsl:value-of select="replace(replace(lower-case(res:binding[@name='name']/res:literal), '[^a-z]', ''), '^1', '')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="tokenize(res:binding[@name='target']/res:uri, '/')[last()]"/>
						</xsl:otherwise>
					</xsl:choose>
				</id>
				<label>
					<xsl:value-of select="if (contains(res:binding[@name='name']/res:literal, ',')) then substring-before(res:binding[@name='name']/res:literal, ',') else
						res:binding[@name='name']/res:literal"/>
				</label>
				<title>
					<xsl:value-of select="res:binding[@name='name']/res:literal"/>
				</title>
				<shape>box</shape>
				<color>
					<xsl:choose>
						<xsl:when test="res:binding[@name='class']/res:uri = 'http://xmlns.com/foaf/0.1/Person'">#97C2FC</xsl:when>
						<xsl:when test="res:binding[@name='class']/res:uri = 'http://www.w3.org/ns/org#Organization'">#FB7E81</xsl:when>
						<xsl:when test="res:binding[@name='class']/res:uri = 'http://purl.org/archival/vocab/arch#'">#FB7E81</xsl:when>
					</xsl:choose>
				</color>
			</structure>
		</xsl:variable>

		<xsl:variable name="line">
			<xsl:text>{</xsl:text>
			<xsl:apply-templates select="$structure/*" mode="json"/>
			<xsl:text>}</xsl:text>
			<xsl:if test="not(position()=last())">
				<xsl:text>,</xsl:text>
			</xsl:if>
		</xsl:variable>

		<xsl:value-of select="normalize-space($line)"/>
	</xsl:template>

	<xsl:template match="*" mode="json">
		<xsl:text>"</xsl:text>
		<xsl:value-of select="name()"/>
		<xsl:text>":</xsl:text>
		<xsl:choose>
			<xsl:when test="child::*">
				<xsl:text>{</xsl:text>
				<xsl:apply-templates select="child::*" mode="json"/>
				<xsl:text>}</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>"</xsl:text>
				<xsl:value-of select="."/>
				<xsl:text>"</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="not(position()=last())">
			<xsl:text>,</xsl:text>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>

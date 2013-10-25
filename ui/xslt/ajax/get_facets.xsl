<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
	<xsl:output method="xml" encoding="UTF-8"/>
	<xsl:param name="q" select="doc('input:request')/request/parameters/parameter[name='q']/value"/>
	<xsl:param name="lang" select="doc('input:request')/request/parameters/parameter[name='lang']/value"/>
	<xsl:param name="category" select="doc('input:request')/request/parameters/parameter[name='category']/value"/>
	<xsl:param name="pipeline" select="doc('input:request')/request/parameters/parameter[name='pipeline']/value"/>
	<xsl:param name="sort" select="doc('input:request')/request/parameters/parameter[name='sort']/value"/>
	
	<xsl:param name="tokenized_q" select="tokenize($q, ' AND ')"/>
	
	<xsl:template match="/">
		<html>
			<head>
				<title>test</title>
			</head>
			<body>				
				<select>
					<xsl:apply-templates select="descendant::lst[@name='facet_fields']/lst[@name=$category]"/>
				</select>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="lst[@name=$category]">
		<xsl:choose>
			<xsl:when test="count(int) = 0">
				<option disabled="disabled">No options available</option>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="int">
					<xsl:variable name="matching_term">
						<xsl:value-of select="concat($category, ':&#x022;', normalize-space(@name), '&#x022;')"/>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="contains($q, $matching_term)">
							<option value="{normalize-space(@name)}" selected="selected">
								<xsl:value-of select="normalize-space(@name)"/>
							</option>
						</xsl:when>
						<xsl:otherwise>
							<option value="{normalize-space(@name)}">
								<xsl:value-of select="normalize-space(@name)"/>
							</option>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>

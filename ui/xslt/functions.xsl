<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xeac="https://github.com/ewg118/xEAC" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="#all" version="2.0">
	<!-- ********************************** FUNCTIONS ************************************ -->
	<!-- create a human readable date -->
	<xsl:function name="xeac:normalizeDate">
		<xsl:param name="date"/>
		
		<xsl:if test="substring($date, 1, 1) != '-' and number(substring($date, 1, 4)) &lt; 500">
			<xsl:text>A.D. </xsl:text>
		</xsl:if>
		
		<xsl:choose>
			<xsl:when test="$date castable as xs:date">
				<xsl:value-of select="format-date($date, '[D] [MNn] [Y]')"/>
			</xsl:when>
			<xsl:when test="$date castable as xs:gYearMonth">
				<xsl:variable name="normalized" select="xs:date(concat($date, '-01'))"/>
				<xsl:value-of select="format-date($normalized, '[MNn] [Y]')"/>
			</xsl:when>
			<xsl:when test="$date castable as xs:gYear or $date castable as xs:integer">
				<xsl:value-of select="abs(number($date))"/>
			</xsl:when>
		</xsl:choose>
		
		<xsl:if test="substring($date, 1, 1) = '-'">
			<xsl:text> B.C.</xsl:text>
		</xsl:if>
	</xsl:function>
	
	<xsl:function name="xeac:normalize_century">
		<xsl:param name="name"/>
		<xsl:variable name="cleaned" select="number(translate($name, '\', ''))"/>
		<xsl:variable name="century" select="abs($cleaned)"/>
		<xsl:variable name="suffix">
			<xsl:choose>
				<xsl:when test="$century mod 10 = 1 and $century != 11">
					<xsl:text>st</xsl:text>
				</xsl:when>
				<xsl:when test="$century mod 10 = 2 and $century != 12">
					<xsl:text>nd</xsl:text>
				</xsl:when>
				<xsl:when test="$century mod 10 = 3 and $century != 13">
					<xsl:text>rd</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>th</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:value-of select="concat($century, $suffix)"/>
		<xsl:if test="$cleaned &lt; 0">
			<xsl:text> B.C.</xsl:text>
		</xsl:if>
	</xsl:function>

	<xsl:function name="xeac:normalize_fields">
		<xsl:param name="field"/>
		<xsl:choose>
			<xsl:when test="$field = 'timestamp'">Date Record Modified</xsl:when>
			<xsl:when test="$field = 'fulltext'">Keyword</xsl:when>
			<xsl:when test="contains($field, '_uri')">
				<xsl:variable name="name" select="substring-before($field, '_uri')"/>
				<xsl:value-of select="concat(upper-case(substring($name, 1, 1)), substring($name, 2))"/>
				<xsl:text> URI</xsl:text>
			</xsl:when>
			<xsl:when test="contains($field, '_facet')">
				<xsl:variable name="name" select="substring-before($field, '_facet')"/>
				<xsl:value-of select="concat(upper-case(substring($name, 1, 1)), substring($name, 2))"/>
			</xsl:when>
			<xsl:when test="contains($field, '_text')">
				<xsl:variable name="name" select="substring-before($field, '_text')"/>
				<xsl:value-of select="concat(upper-case(substring($name, 1, 1)), substring($name, 2))"/>
			</xsl:when>
			<xsl:when test="contains($field, '_min') or contains($field, '_max')">
				<xsl:variable name="name" select="substring-before($field, '_m')"/>
				<xsl:value-of select="xeac:normalize_fields($name)"/>
			</xsl:when>
			<xsl:when test="contains($field, '_display')">
				<xsl:variable name="name" select="substring-before($field, '_display')"/>
				<xsl:value-of select="concat(upper-case(substring($name, 1, 1)), substring($name, 2))"/>
			</xsl:when>
			<xsl:when test="not(contains($field, '_'))">
				<xsl:value-of select="concat(upper-case(substring($field, 1, 1)), substring($field, 2))"/>
			</xsl:when>
			<xsl:otherwise>Undefined Category</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="xeac:normalize_property">
		<xsl:param name="uri"/>

		<xsl:variable name="namespaces" as="item()*">
			<namespaces>
				<namespace prefix="ecrm" uri="http://erlangen-crm.org/current/"/>
				<namespace prefix="dcterms" uri="http://purl.org/dc/terms/"/>
				<namespace prefix="foaf" uri="http://xmlns.com/foaf/0.1/"/>
				<namespace prefix="geo" uri="http://www.w3.org/2003/01/geo/wgs84_pos#"/>
				<namespace prefix="rdfs" uri="http://www.w3.org/2000/01/rdf-schema#"/>
				<namespace prefix="skos" uri="http://www.w3.org/2004/02/skos/core#"/>
				<namespace prefix="xsd" uri="http://www.w3.org/2001/XMLSchema#"/>
			</namespaces>
		</xsl:variable>

		<xsl:value-of select="replace($uri, $namespaces//namespace[contains($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))"/>

	</xsl:function>

	<!-- ********************************** TEMPLATES ************************************ -->

	<xsl:template name="multifields">
		<xsl:param name="field"/>
		<xsl:param name="position"/>
		<xsl:param name="fragments"/>
		<xsl:param name="count"/>

		<xsl:if test="substring-before($fragments[$position], ':') != $field">
			<xsl:text>true</xsl:text>
		</xsl:if>
		<xsl:if test="$position &lt; $count and substring-before($fragments[$position], ':') = $field">
			<xsl:call-template name="multifields">
				<xsl:with-param name="position" select="$position + 1"/>
				<xsl:with-param name="fragments" select="$fragments"/>
				<xsl:with-param name="field" select="$field"/>
				<xsl:with-param name="count" select="$count"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>

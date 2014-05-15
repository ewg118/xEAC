<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/2005/Atom" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
	version="2.0">
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

	<!-- config variable -->
	<xsl:variable name="url" select="/content/config/url"/>

	<!-- request params -->
	<xsl:param name="q" select="doc('input:params')/request/parameters/parameter[name='q']/value"/>
	<xsl:param name="start" select="doc('input:params')/request/parameters/parameter[name='start']/value"/>
	<xsl:variable name="start_var" as="xs:integer">
		<xsl:choose>
			<xsl:when test="number($start)">
				<xsl:value-of select="$start"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:param name="rows" as="xs:integer">100</xsl:param>

	<xsl:template match="/">
		<xsl:variable name="numFound">
			<xsl:value-of select="number(//result[@name='response']/@numFound)"/>
		</xsl:variable>
		<xsl:variable name="last" select="number(concat(substring($numFound, 1, string-length($numFound) - 2), '00'))"/>
		<xsl:variable name="next" select="$start_var + 100"/>


		<feed xmlns="http://www.w3.org/2005/Atom" xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/">
			<title>
				<xsl:value-of select="/content/config/title"/>
			</title>
			<link href="{$url}feed/?q={$q}" rel="self"/>
			<id>Feed ID</id>

			<xsl:if test="$numFound &gt; $next">
				<link rel="next" href="{$url}feed/?q={$q}&amp;start={$next}"/>
			</xsl:if>
			<link rel="last" href="{$url}feed/?q={$q}&amp;start={$last}"/>

			<author>
				<name>
					<xsl:value-of select="/content/config/title"/>
				</name>
			</author>
			<opensearch:totalResults>
				<xsl:value-of select="$numFound"/>
			</opensearch:totalResults>
			<opensearch:startIndex>
				<xsl:value-of select="$start_var"/>
			</opensearch:startIndex>
			<opensearch:itemsPerPage>
				<xsl:value-of select="$rows"/>
			</opensearch:itemsPerPage>
			<opensearch:Query role="request" searchTerms="{if (string($q)) then $q else '*:*'}" startPage="{($start_var div 100) + 1}"/>
			<xsl:apply-templates select="descendant::doc"/>
		</feed>

	</xsl:template>

	<xsl:template match="doc">
		<entry>
			<title>
				<xsl:value-of select="str[@name='name_display']"/>
			</title>
			<link href="{$url}id/{str[@name='id']}"/>
			<link rel="alternate xml" type="text/xml" href="{$url}id/{str[@name='id']}.xml"/>
			<id>
				<xsl:value-of select="str[@name='id']"/>
			</id>
			<updated>
				<xsl:value-of select="date[@name='timestamp']"/>
			</updated>
		</entry>
	</xsl:template>
</xsl:stylesheet>

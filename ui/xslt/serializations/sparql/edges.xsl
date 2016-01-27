<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:foo="my.foo.org" exclude-result-prefixes="#all"
	version="2.0">

	<xsl:param name="from" select="doc('input:request')/request/parameters/parameter[name='id']/value"/>

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
		<xsl:variable name="to">
			<xsl:choose>
				<xsl:when test="res:binding[@name='target']/res:bnode">
					<xsl:value-of select="replace(replace(lower-case(res:binding[@name='name']/res:literal), '[^a-z]', ''), '^1', '')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="tokenize(res:binding[@name='target']/res:uri, '/')[last()]"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="id">
			<xsl:for-each select="tokenize(replace(replace(concat($from, $to),'(.)','$1\\n'),'\\n$',''),'\\n')">
				<xsl:sort order="ascending"/>
				<xsl:value-of select="."/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="label" select="replace($uri, $namespaces//namespace[contains($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))"/>
	
		<xsl:variable name="structure" as="element()*">
			<structure>
				<id>
					<xsl:value-of select="foo:checksum(concat($id, $label))"/>
				</id>
				<from>
					<xsl:value-of select="$from"/>
				</from>
				<to>
					<xsl:value-of select="$to"/>
				</to>
				<label>
					<xsl:value-of select="$label"/>
				</label>
				<arrows>to</arrows>
				<!--<style>line</style>-->
				<width>1</width>
				<!--<color>
					<xsl:choose>
						<xsl:when test="res:binding[@name='class']/res:uri = 'http://xmlns.com/foaf/0.1/Person'">#97C2FC</xsl:when>
						<xsl:when test="res:binding[@name='class']/res:uri = 'http://www.w3.org/ns/org#Organization'">#FB7E81</xsl:when>
						<xsl:when test="res:binding[@name='class']/res:uri = 'http://purl.org/archival/vocab/arch#'">#FB7E81</xsl:when>
					</xsl:choose>
				</color>-->
				<!--<font>
					<align>top</align>
				</font>-->
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
	
	<!-- functions from stackoverflow: http://stackoverflow.com/questions/6753343/using-xsl-to-make-a-hash-of-xml-file -->
	<xsl:function name="foo:checksum" as="xs:integer">
		<xsl:param name="str" as="xs:string"/>
		<xsl:variable name="codepoints" select="string-to-codepoints($str)"/>
		<xsl:value-of select="foo:fletcher16($codepoints, count($codepoints), 1, 0, 0)"/>
	</xsl:function>
	
	<!-- can I change some xs:integers to xs:int and help performance? -->
	<xsl:function name="foo:fletcher16">
		<xsl:param name="str" as="xs:integer*"/>
		<xsl:param name="len" as="xs:integer" />
		<xsl:param name="index" as="xs:integer" />
		<xsl:param name="sum1" as="xs:integer" />
		<xsl:param name="sum2" as="xs:integer"/>
		<xsl:choose>
			<xsl:when test="$index gt $len">
				<xsl:sequence select="$sum2 * 256 + $sum1"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="newSum1" as="xs:integer"
					select="($sum1 + $str[$index]) mod 255"/>
				<xsl:sequence select="foo:fletcher16($str, $len, $index + 1, $newSum1,
					($sum2 + $newSum1) mod 255)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
</xsl:stylesheet>

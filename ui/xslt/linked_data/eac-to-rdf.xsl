<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:foaf="http://xmlns.com/foaf/spec/#" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:arch="http://purl.org/archival/vocab/arch#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:eac="urn:isbn:1-931666-33-4" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="eac xlink" version="2.0">

	<xsl:variable name="url" select="/content/config/url"/>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/eac:eac-cpf"/>
	</xsl:template>

	<xsl:template match="eac:eac-cpf">
		<xsl:variable name="id" select="eac:control/eac:recordId"/>
		<rdf:RDF>
			<xsl:choose>
				<xsl:when test="descendant::eac:entityType='person'">
					<foaf:Person rdf:about="{$url}id/{$id}">
						<xsl:call-template name="rdf-body"/>
					</foaf:Person>
				</xsl:when>
				<xsl:when test="descendant::eac:entityType='corporateBody'">
					<foaf:Organization rdf:about="{$url}id/{$id}">
						<xsl:call-template name="rdf-body"/>
					</foaf:Organization>
				</xsl:when>
				<xsl:when test="descendant::eac:entityType='family'">
					<arch:Family rdf:about="{$url}id/{$id}">
						<xsl:call-template name="rdf-body"/>
					</arch:Family>
				</xsl:when>
			</xsl:choose>
		</rdf:RDF>
	</xsl:template>

	<xsl:template name="rdf-body">
		<!-- labels -->
		<xsl:for-each select="descendant::eac:nameEntry">
			<xsl:element name="{if (string(eac:preferredForm)) then 'skos:prefLabel' else 'skos:altLabel'}" namespace="http://www.w3.org/2004/02/skos/core#">
				<xsl:if test="string(@xml:lang)">
					<xsl:attribute name="xml:lang" select="@xml:lang"/>
				</xsl:if>
				<xsl:value-of select="eac:part"/>
			</xsl:element>
		</xsl:for-each>

		<!-- related links -->
		<xsl:for-each select="eac:control/eac:otherRecordId">
			<xsl:choose>
				<xsl:when test=". castable as xs:anyURI and contains(., 'http://')">
					<skos:related rdf:resource="{.}"/>
				</xsl:when>
				<xsl:when test=". castable as xs:anyURI and not(contains(., 'http://'))">
					<skos:related rdf:resource="{concat($url, 'id/', .)}"/>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>

		<!-- relations -->
		<!-- only process relations with an xlink:arcrole from a defined namespace -->
		<xsl:apply-templates
			select="descendant::eac:cpfRelation[contains(@xlink:arcrole, ':') and string(@xlink:href)]|descendant::eac:resourceReslation[contains(@xlink:arcrole, ':') and string(@xlink:href)]"/>

		<xsl:apply-templates select="descendant::eac:abstract"/>
	</xsl:template>

	<xsl:template match="eac:cpfRelation|eac:resourceRelation">
		<xsl:variable name="uri" select="if (contains(@xlink:href, 'http://')) then . else concat($url, 'id/', @xlink:href)"/>
		<xsl:variable name="prefix" select="substring-before(@xlink:arcrole, ':')"/>
		<xsl:variable name="namespace" select="ancestor::eac:eac-cpf/eac:control/eac:localTypeDeclaration[eac:abbreviation=$prefix]/eac:citation/@xlink:href"/>

		<xsl:element name="{@xlink:arcrole}" namespace="{$namespace}">
			<xsl:attribute name="rdf:resource" select="$uri"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="eac:abstract">
		<dcterms:abstract>
			<xsl:value-of select="."/>
		</dcterms:abstract>
	</xsl:template>
</xsl:stylesheet>

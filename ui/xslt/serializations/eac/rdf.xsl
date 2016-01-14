<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:arch="http://purl.org/archival/vocab/arch#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:eac="urn:isbn:1-931666-33-4" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:crm="http://erlangen-crm.org/current/"
	xmlns:org="http://www.w3.org/ns/org#" xmlns:lawd="http://lawd.info/ontology/" xmlns:snap="http://onto.snapdrgn.net/snap#" xmlns:bio="http://purl.org/vocab/bio/0.1/"
	xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:edm="http://www.europeana.eu/schemas/edm/" exclude-result-prefixes="eac xlink xs" version="2.0">
	<xsl:include href="rdf-templates.xsl"/>

	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="namespaces" as="node()*">
		<namespaces>
			<xsl:for-each select="descendant::eac:localTypeDeclaration[eac:citation[@xlink:role='semantic']][not(contains(eac:abbreviation, ':'))]">
				<namespace prefix="{eac:abbreviation}" uri="{eac:citation/@xlink:href}"/>
			</xsl:for-each>
		</namespaces>
	</xsl:variable>

	<xsl:template match="/">
		<rdf:RDF>
			<xsl:for-each select="distinct-values($namespaces//@uri)">
				<xsl:variable name="uri" select="."/>
				<xsl:variable name="prefix" select="$namespaces//namespace[@uri=$uri][1]/@prefix"/>
				<xsl:namespace name="{$prefix}" select="$uri"/>
			</xsl:for-each>
			<xsl:apply-templates select="/content/descendant::eac:eac-cpf" mode="default"/>

		</rdf:RDF>
	</xsl:template>
</xsl:stylesheet>

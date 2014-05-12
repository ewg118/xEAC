<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:foaf="http://xmlns.com/foaf/spec/#" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:arch="http://purl.org/archival/vocab/arch#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:eac="urn:isbn:1-931666-33-4" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="eac xlink" version="2.0">
	<xsl:include href="rdf-templates.xsl"/>
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="id" select="/content/eac:eac-cpf/eac:control/eac:recordId"/>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/eac:eac-cpf" mode="default"/>
	</xsl:template>
</xsl:stylesheet>

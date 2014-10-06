<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:eac="urn:isbn:1-931666-33-4" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all"
	version="2.0">
	<xsl:include href="rdf-templates.xsl"/>
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="id" select="/content/eac:eac-cpf/eac:control/eac:recordId"/>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/eac:eac-cpf" mode="default"/>
	</xsl:template>
</xsl:stylesheet>

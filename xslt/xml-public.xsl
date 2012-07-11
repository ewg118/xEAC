<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber [gruber at numismatics dot org]
	EADitor: http://code.google.com/p/eaditor/
	Apache License 2.0: http://code.google.com/p/eaditor/
	Modified: June 2011
	Function: Identity transform for the xml pipeline in EADitor.  Internal components are suppressed unless they have external
	descendants, in which case only the unittitles are displayed 
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:eac="urn:isbn:1-931666-33-4" version="2.0">
	<xsl:output encoding="utf-8" indent="yes" method="xml"/>
	<xsl:strip-space elements="*"/>
	
	<!-- change eXist URL if running on a server other than localhost -->
	<xsl:variable name="exist-url" select="/exist-url"/>

	<xsl:template match="/">
		<xsl:variable name="basename" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
		<xsl:variable name="id">
			<xsl:choose>
				<xsl:when test="substring($basename, string-length($basename) - 3) = '.kml'">
					<xsl:value-of select="substring-before($basename, '.kml')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$basename"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!--<xml><xsl:value-of select="$id"/></xml>-->
		<xsl:copy-of select="document(concat($exist-url, 'xeac/records/', $id, '.xml'))/eac:eac-cpf"/>		
	</xsl:template>
</xsl:stylesheet>

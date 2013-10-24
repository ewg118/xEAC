<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber [gruber at numismatics dot org]	
	Apache License 2.0: http://code.google.com/p/eaditor/
	Modified: July 2012
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:eac="urn:isbn:1-931666-33-4" version="2.0">
	<xsl:output encoding="utf-8" indent="yes" method="xml"/>
	<xsl:strip-space elements="*"/>
	
	<!-- change eXist URL if running on a server other than localhost -->
	<xsl:variable name="exist-url" select="/exist-url"/>

	<xsl:template match="/">
		<xsl:variable name="id" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
		
		<!--<xml><xsl:value-of select="$id"/></xml>-->
		<xsl:copy-of select="document(concat($exist-url, 'xeac/kml/', $id))/*"/>		
	</xsl:template>
</xsl:stylesheet>

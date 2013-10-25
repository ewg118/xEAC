<?xml version="1.0" encoding="UTF-8"?>
<!--
	Copyright (C) 2010 Ethan Gruber
	EADitor: http://code.google.com/p/eaditor/
	Apache License 2.0: http://code.google.com/p/eaditor/
	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
	xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>
	
	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request/request-url</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>
	
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="../exist-url.xml"/>		
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:eac="urn:isbn:1-931666-33-4">
				<xsl:template match="/">
					<xsl:variable name="basename" select="tokenize(doc('input:request')/request/request-url, '/')[last()]"/>
					<xsl:variable name="id">
						<xsl:choose>
							<xsl:when test="substring($basename, string-length($basename) - 3) = '.kml'">
								<xsl:value-of select="substring-before($basename, '.kml')"/>
							</xsl:when>
							<xsl:when test="substring($basename, string-length($basename) - 3) = '.xml'">
								<xsl:value-of select="substring-before($basename, '.xml')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$basename"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:copy-of select="document(concat(/exist-url, 'xeac/records/', $id, '.xml'))/eac:eac-cpf"/>		
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" ref="data"/>
	</p:processor>
</p:config>
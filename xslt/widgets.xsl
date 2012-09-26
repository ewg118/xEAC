<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xeac="https://github.com/ewg118/xEAC"
	xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="#all" version="2.0">
	<xsl:template name="xeac:getOcreCoins">
		<xsl:param name="name"/>
		<xsl:variable name="ocre-url">http://numismatics.org/ocre/</xsl:variable>
		<xsl:variable name="feed" select="document(concat($ocre-url, 'feed/?q=authority_text:', encode-for-uri($name), '+AND+imagesavailable:true'))/atom:feed"/>

		<xsl:if test="count(exsl:node-set($feed)//atom:entry) &gt; 0">
			<div class="ui-corner-all xeac-widget" style="border:1px solid gray">
				<h3>Online Coins of the Roman Empire</h3>
				<xsl:for-each select="exsl:node-set($feed)//atom:entry[position() &lt;= 5]">
					<xsl:variable name="href" select="atom:link[not(@rel)]/@href"/>
					<xsl:variable name="row">
						<xsl:choose>
							<xsl:when test="position() mod 2 = 1">odd-row</xsl:when>
							<xsl:otherwise>even-row</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<div class="{$row}">
						
						<h4>
							<a href="{$href}" target="_blank">
								<xsl:value-of select="atom:title"/>
							</a>
						</h4>
						<xsl:for-each select="atom:link[@type='image/jpg']">
							<a href="{$href}" target="_blank">
								<img src="{@href}" alt="image" style="max-height:100px;max-width:200px;"/>
							</a>
						</xsl:for-each>
					</div>
				</xsl:for-each>
				<a href="{$ocre-url}results?q=authority_text:&#x022;{$name}&#x022;" target="_blank">More...</a>
			</div>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:datetime="http://exslt.org/dates-and-times" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:eac="urn:isbn:1-931666-33-4" version="2.0">
	<xsl:output method="xml" encoding="UTF-8"/>

	<xsl:template match="/">
		<add>
			<xsl:apply-templates select="eac:eac-cpf"/>
		</add>
	</xsl:template>

	<xsl:template match="eac:eac-cpf">
		<doc>
			<field name="id">
				<xsl:value-of select="eac:control/eac:recordId"/>
			</field>
			<field name="timestamp">
				<xsl:variable name="timestamp" select="datetime:dateTime()"/>
				<xsl:choose>
					<xsl:when test="contains($timestamp, 'Z')">
						<xsl:value-of select="$timestamp"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($timestamp, 'Z')"/>
					</xsl:otherwise>
				</xsl:choose>
			</field>
			<field name="entityType_facet">
				<xsl:value-of select="eac:cpfDescription/eac:identity/eac:entityType"/>
			</field>
			<field name="entityType_display">
				<xsl:value-of select="eac:cpfDescription/eac:identity/eac:entityType"/>
			</field>
			<xsl:for-each select="eac:cpfDescription/eac:identity/eac:nameEntry">
				<xsl:if test="position() = 1">
					<field name="name_display">
						<xsl:value-of select="eac:part"/>
					</field>
					<field name="name_facet">
						<xsl:value-of select="eac:part"/>
					</field>
				</xsl:if>
				<field name="name_text">
					<xsl:value-of select="eac:part"/>
				</field>
			</xsl:for-each>

			<!-- terms as facets -->
			<xsl:for-each
				select="descendant::eac:localDescription|descendant::eac:legalStatus|descendant::eac:function|descendant::eac:occupation|descendant::eac:mandate|descendant::eac:generalContext">
				<xsl:if test="string(eac:term)">
					<field name="{if (string(@localType)) then @localType else local-name()}_facet">
						<xsl:value-of select="normalize-space(eac:term)"/>
					</field>
					<field name="{if (string(@localType)) then @localType else local-name()}_text">
						<xsl:value-of select="normalize-space(eac:term)"/>
					</field>
				</xsl:if>
			</xsl:for-each>
			
			<!-- placeEntry as facet -->
			<xsl:for-each select="descendant::eac:placeEntry[string(normalize-space(.))]">
				<field name="{if (string(@localType)) then @localType else local-name()}_facet">
					<xsl:value-of select="normalize-space(.)"/>
				</field>
				<field name="{if (string(@localType)) then @localType else local-name()}_text">
					<xsl:value-of select="normalize-space(.)"/>
				</field>
			</xsl:for-each>
			<field name="fulltext">
				<xsl:for-each select="descendant-or-self::node()">
					<xsl:value-of select="text()"/>
					<xsl:text> </xsl:text>					
				</xsl:for-each>
			</field>
		</doc>
	</xsl:template>


</xsl:stylesheet>

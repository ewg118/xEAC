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
			<field name="recordId">
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
			<xsl:apply-templates select="eac:cpfDescription"/>

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
			<xsl:for-each select="descendant::eac:resourceRelation[@xlink:role='portrait']">
				<field name="thumb_image">
					<xsl:value-of select="@xlink:href"/>
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
	
	<xsl:template match="eac:cpfDescription">
		<xsl:apply-templates select="eac:identity"/>
		<xsl:apply-templates select="eac:relations"/>
		<xsl:apply-templates select="eac:description"/>
	</xsl:template>
	
	<xsl:template match="eac:description">
		<xsl:apply-templates select="eac:existDates/*"/>		
	</xsl:template>
	
	<xsl:template match="eac:identity">
		<field name="entityType_facet">
			<xsl:value-of select="eac:entityType"/>
		</field>
		<field name="entityType_display">
			<xsl:value-of select="eac:entityType"/>
		</field>
		
		<xsl:for-each select="eac:nameEntry">
			<field name="name_text">
				<xsl:value-of select="eac:part"/>
			</field>
		</xsl:for-each>
		<xsl:choose>
			<xsl:when test="eac:nameEntry[eac:preferredForm='WIKIPEDIA']">
				<field name="name_display">
					<xsl:value-of select="eac:nameEntry[eac:preferredForm='WIKIPEDIA']/eac:part"/>
				</field>
				<field name="name_facet">
					<xsl:value-of select="eac:nameEntry[eac:preferredForm='WIKIPEDIA']/eac:part"/>
				</field>
			</xsl:when>
			<xsl:otherwise>
				<field name="name_display">
					<xsl:value-of select="eac:nameEntry[1]/eac:part"/>
				</field>
				<field name="name_facet">
					<xsl:value-of select="eac:nameEntry[1]/eac:part"/>
				</field>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- relations not yet posted to Solr -->
	<xsl:template match="eac:relations"/>
	
	<xsl:template match="eac:existDates/*">
		<field name="existDates_display">
			<xsl:choose>
				<xsl:when test="local-name() = 'date'">
					<xsl:value-of select="."/>
				</xsl:when>
				<xsl:when test="local-name()='dateRange'">
					<xsl:value-of select="eac:fromDate"/>
					<xsl:text> - </xsl:text>
					<xsl:value-of select="eac:toDate"/>
				</xsl:when>
			</xsl:choose>
		</field>
	</xsl:template>

</xsl:stylesheet>

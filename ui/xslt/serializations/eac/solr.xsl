<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:eac="urn:isbn:1-931666-33-4" version="2.0">
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
				<xsl:variable name="modified" select="descendant::eac:maintenanceEvent[last()]/eac:eventDateTime/@standardDateTime"/>

				<xsl:choose>
					<xsl:when test="string($modified)">
						<!-- if the timezone modifier is already the last character of the @standardDateTime-->
						<xsl:value-of select="format-dateTime(xs:dateTime($modified), '[Y0001]-[M01]-[D01]T[h01]:[m01]:[s01]Z')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[h01]:[m01]:[s01]Z')"/>
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
			<xsl:choose>
				<xsl:when test="descendant::eac:resourceRelation[@xlink:arcrole='foaf:thumbnail']">
					<field name="thumb_image">
						<xsl:value-of select="descendant::eac:resourceRelation[@xlink:arcrole='foaf:thumbnail'][1]/@xlink:href"/>
					</field>
				</xsl:when>
				<xsl:when test="descendant::eac:resourceRelation[@xlink:arcrole='foaf:depiction']">
					<field name="thumb_image">
						<xsl:value-of select="descendant::eac:resourceRelation[@xlink:arcrole='foaf:depiction'][1]/@xlink:href"/>
					</field>
				</xsl:when>
			</xsl:choose>
			<field name="text">
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
		<xsl:if test="eac:biogHist/eac:abstract">
			<field name="abstract_display">
				<xsl:value-of select="eac:biogHist/eac:abstract"/>
			</field>
		</xsl:if>
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

<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:eac="urn:isbn:1-931666-33-4" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:spatial="http://geovocab.org/spatial#" exclude-result-prefixes="#all" version="2.0">

	<xsl:param name="id" select="doc('input:request')/request/parameters/parameter[name='id']/value"/>
	<xsl:param name="format" select="doc('input:request')/request/parameters/parameter[name='format']/value"/>

	<xsl:variable name="geonames-url">
		<xsl:text>http://api.geonames.org</xsl:text>
	</xsl:variable>
	<xsl:variable name="geonames_api_key" select="/content/config/geonames_api_key"/>

	<xsl:variable name="rdf" as="node()*">
		<rdf:RDF>
			<!-- look up only mints -->
			<xsl:for-each select="distinct-values(descendant::eac:placeEntry[contains(@vocabularySource, 'nomisma.org')]/@vocabularySource)">
				<xsl:variable name="rdf_url" select="concat('http://www.w3.org/2012/pyRdfa/extract?format=xml&amp;uri=', encode-for-uri(.))"/>
				<xsl:copy-of select="document($rdf_url)/rdf:RDF/*[not(local-name()='Description')]"/>
			</xsl:for-each>
			<xsl:for-each select="distinct-values(descendant::eac:placeEntry[contains(@vocabularySource, 'pleiades.stoa.org')]/@vocabularySource)">
				<xsl:variable name="rdf_url" select="concat(., '/rdf')"/>
				<xsl:copy-of select="document($rdf_url)/rdf:RDF/spatial:Feature"/>
			</xsl:for-each>
		</rdf:RDF>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="$format='json'">
				<xsl:call-template name="timemap"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="timemap">
		<xsl:variable name="response">
			<xsl:text>[</xsl:text>
			<xsl:for-each select="descendant::eac:date[string(@standardDate)]|descendant::eac:dateRange[string(eac:fromDate/@standardDate) or string(eac:toDate/@standardDate)]|descendant::eac:placeEntry[string(@vocabularySource)][not(preceding-sibling::eac:date|preceding-sibling::eac:dateRange|following-sibling::eac:date|following-sibling::eac:dateRange)]">
				<xsl:call-template name="getJson">
					<xsl:with-param name="href">
						<xsl:choose>
							<xsl:when test="local-name()='placeEntry'">
								<xsl:value-of select="@vocabularySource"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="parent::node()/eac:placeEntry/@vocabularySource"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:if test="not(position()=last())">
					<xsl:text>,</xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:text>]</xsl:text>
		</xsl:variable>
		<xsl:value-of select="normalize-space($response)"/>
	</xsl:template>

	<xsl:template name="getJson">
		<xsl:param name="href"/>
		
		<xsl:variable name="name">
			<xsl:choose>
				<xsl:when test="parent::eac:existDates">Dates of Existence</xsl:when>
				<xsl:when test="ancestor::eac:useDates">
					<xsl:text>Known as </xsl:text>
					<xsl:value-of select="ancestor::eac:nameEntry/eac:part"/>
				</xsl:when>
				<xsl:when test="parent::node()/eac:event">
					<xsl:value-of select="parent::node()/eac:event"/>
				</xsl:when>
				<xsl:when test="parent::node()/eac:term">
					<xsl:value-of select="parent::node()/eac:term"/>
				</xsl:when>
				<xsl:when test="parent::node()/eac:placeRole">
					<xsl:value-of select="parent::node()/eac:placeRole"/>
				</xsl:when>
				<xsl:when test="parent::node()/eac:placeEntry">
					<xsl:value-of select="parent::node()/eac:placeEntry"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="description">
			<xsl:choose>
				<xsl:when test="local-name()='placeEntry'">
					<xsl:value-of select="."/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="local-name() = 'date'">
							<xsl:value-of select="."/>
						</xsl:when>
						<xsl:when test="local-name()='dateRange'">
							<xsl:value-of select="eac:fromDate"/>
							<xsl:text>-</xsl:text>
							<xsl:value-of select="eac:toDate"/>
						</xsl:when>
					</xsl:choose>
					<xsl:if test="string(parent::node()/eac:placeEntry)">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="parent::node()/eac:placeEntry"/>
						<xsl:text>.</xsl:text>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
			
		</xsl:variable>
		<xsl:variable name="start">
			<xsl:choose>
				<xsl:when test="local-name() = 'date'">					
					<xsl:value-of select="parent::node()/eac:date/@standardDate"/>
				</xsl:when>
				<xsl:when test="local-name()='dateRange'">					
					<xsl:value-of select="eac:fromDate/@standardDate"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="end">
			<xsl:if test="local-name()='dateRange'">				
				<xsl:value-of select="eac:toDate/@standardDate"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="theme">red</xsl:variable>
		
		<xsl:variable name="coordinates">
			<xsl:call-template name="get-point">
				<xsl:with-param name="href" select="$href"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- output --> { <xsl:if test="string($coordinates) and not($coordinates='NULL')">"point": {"lon": <xsl:value-of select="tokenize($coordinates, '\|')[1]"/>, "lat": <xsl:value-of
				select="tokenize($coordinates, '\|')[2]"/>},</xsl:if> "title": "<xsl:value-of select="normalize-space(replace($name, '&#x022;', ''))"/>", <xsl:if test="string($start)">"start": "<xsl:value-of select="$start"/>",</xsl:if>
		<xsl:if test="string($end)">"end": "<xsl:value-of select="$end"/>",</xsl:if> "options": { "theme": "<xsl:value-of select="$theme"/>"<xsl:if test="string($description)">, "description":
			"<xsl:value-of select="normalize-space(replace($description, '&#x022;', ''))"/>"</xsl:if><xsl:if test="string($href)">, "href": "<xsl:value-of select="$href"/>"</xsl:if> } } </xsl:template>

	<xsl:template name="get-point">
		<xsl:param name="href"/>

		<xsl:choose>
			<xsl:when test="contains($href, 'geonames')">
				<xsl:variable name="geonameId" select="tokenize($href, '/')[4]"/>
				<xsl:variable name="geonames_data" as="item()*">
					<xsl:copy-of select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))/*"/>
				</xsl:variable>				
				<xsl:variable name="coordinates" select="concat($geonames_data//lng, '|', $geonames_data//lat)"/>
				<xsl:value-of select="$coordinates"/>
			</xsl:when>
			<xsl:when test="contains($href, 'nomisma')">
				<xsl:if test="string($rdf//*[@rdf:about=$href]/descendant::geo:lat) and string($rdf//*[@rdf:about=$href]/descendant::geo:long)">
					<xsl:variable name="lat" select="$rdf//*[@rdf:about=$href]/descendant::geo:lat"/>
					<xsl:variable name="long" select="$rdf//*[@rdf:about=$href]/descendant::geo:long"/>
					<xsl:value-of select="concat($long, '|', $lat)"/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="contains($href, 'pleiades')">
				<xsl:choose>
					<xsl:when
						test="number($rdf//spatial:Feature[@rdf:about=concat($href, '#this')]/descendant::geo:lat) and number($rdf//spatial:Feature[@rdf:about=concat($href, '#this')]/descendant::geo:long)">
						<xsl:value-of
							select="concat($rdf//spatial:Feature[@rdf:about=concat($href, '#this')]/descendant::geo:long, '|', $rdf//spatial:Feature[@rdf:about=concat($href, '#this')]/descendant::geo:lat)"
						/>
					</xsl:when>
					<xsl:when test="$rdf//*[@rdf:about=concat($href, '#this')]/following-sibling::osgeo:AbstractGeometry">
						<xsl:variable name="area" select="$rdf//*[@rdf:about=concat($href, '#this')]/following-sibling::osgeo:AbstractGeometry[1]/osgeo:asGeoJSON"/>
						<xsl:value-of select="translate(replace(replace(substring-after($area, '['), ',\s', ','), '\],', ' '), '[]}', '')"/>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
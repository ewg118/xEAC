<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" xmlns:gml="http://www.opengis.net/gml/" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:eac="urn:isbn:1-931666-33-4" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs gml exsl skos rdf xlink eac" xmlns="http://earth.google.com/kml/2.0" version="2.0">

	<xsl:param name="exist-url" select="//exist-url"/>
	<xsl:variable name="config" select="document(concat($exist-url, 'xeac/config.xml'))"/>
	<xsl:variable name="geonames-url">
		<xsl:text>http://api.geonames.org</xsl:text>
	</xsl:variable>
	<xsl:variable name="geonames_api_key" select="exsl:node-set($config)/config/geonames_api_key"/>

	<xsl:variable name="rdf">
		<rdf:RDF>
			<!-- look up only mints -->
			<xsl:for-each select="distinct-values(descendant::eac:placeEntry[contains(@vocabularySource, 'nomisma.org')]/@vocabularySource)">
				<xsl:variable name="rdf_url" select="concat('http://www.w3.org/2012/pyRdfa/extract?format=xml&amp;uri=', encode-for-uri(.))"/>
				<xsl:copy-of select="document($rdf_url)/rdf:RDF/*[not(local-name()='Description')]"/>
			</xsl:for-each>
		</rdf:RDF>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/eac:eac-cpf"/>
	</xsl:template>

	<xsl:template match="eac:eac-cpf">
		<kml xmlns="http://earth.google.com/kml/2.0">
			<Document>
				<!--<Style xmlns="" id="place">
					<IconStyle>
						<scale>1</scale>
						<hotSpot x="0.5" y="0.5" xunits="fraction" yunits="fraction"/>
						<Icon>
							<href>http://maps.google.com/mapfiles/kml/paddle/red-circle.png</href>
						</Icon>
					</IconStyle>
				</Style>-->
				<xsl:apply-templates select="descendant::eac:placeEntry[string(@vocabularySource)]"/>
			</Document>
		</kml>
	</xsl:template>

	<xsl:template match="eac:placeEntry">
		<xsl:variable name="href" select="@vocabularySource"/>

		<xsl:variable name="description">
			<xsl:choose>
				<xsl:when test="parent::node()/eac:event">
					<xsl:value-of select="parent::node()/eac:event"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>


		<Placemark>
			<name>
				<xsl:value-of select="."/>
			</name>
			<xsl:if test="string($description)">
				<description>
					<xsl:value-of select="$description"/>
				</description>
			</xsl:if>

			<xsl:choose>
				<xsl:when test="parent::node()/eac:date[@standardDate]">
					<TimeStamp>
						<when>
							<xsl:value-of select="parent::node()/eac:date/@standardDate"/>
						</when>
					</TimeStamp>
				</xsl:when>
				<xsl:when test="parent::node()/eac:dateRange[eac:fromDate[@standardDate]] or parent::node()/eac:dateRange[eac:toDate[@standardDate]]">
					<TimeSpan>
						<xsl:if test="parent::node()/eac:dateRange[eac:fromDate[@standardDate]]">
							<begin>
								<xsl:value-of select="parent::node()/eac:dateRange/eac:fromDate/@standardDate"/>
							</begin>
						</xsl:if>
						<xsl:if test="parent::node()/eac:dateRange[eac:toDate[@standardDate]]">
							<end>
								<xsl:value-of select="parent::node()/eac:dateRange/eac:toDate/@standardDate"/>
							</end>
						</xsl:if>
					</TimeSpan>
				</xsl:when>
			</xsl:choose>
			<!--<styleUrl>#place</styleUrl>-->
			<xsl:choose>
				<xsl:when test="contains($href, 'geonames')">
					<xsl:variable name="geonameId" select="substring-before(substring-after($href, 'geonames.org/'), '/')"/>
					<xsl:variable name="geonames_data" select="document(concat($geonames-url, '/get?geonameId=', $geonameId, '&amp;username=', $geonames_api_key, '&amp;style=full'))"/>
					<xsl:variable name="coordinates" select="concat(exsl:node-set($geonames_data)//lng, ',', exsl:node-set($geonames_data)//lat)"/>
					<Point>
						<coordinates>
							<xsl:value-of select="$coordinates"/>
						</coordinates>
					</Point>
				</xsl:when>
				<xsl:when test="contains($href, 'nomisma')">
					<xsl:variable name="coordinates" select="exsl:node-set($rdf)/rdf:RDF/*[@rdf:about=$href]/descendant::gml:pos"/>
					<xsl:if test="string($coordinates)">
						<xsl:variable name="lat" select="substring-before($coordinates, ' ')"/>
						<xsl:variable name="lon" select="substring-after($coordinates, ' ')"/>
						<Point>
							<coordinates>
								<xsl:value-of select="concat($lon, ',', $lat)"/>
							</coordinates>
						</Point>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
		</Placemark>
	</xsl:template>
</xsl:stylesheet>

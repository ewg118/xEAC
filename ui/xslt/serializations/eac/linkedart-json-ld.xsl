<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date: August 2020
	Function: Transform Nomisma RDF into Linked Art JSON-LD. Query broader concepts -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:eac="urn:isbn:1-931666-33-4" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xeac="https://github.com/ewg118/xEAC" xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../json/json-metamodel.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<!--<xsl:variable name="conceptURI" select="/content/rdf:RDF/*[1]/@rdf:about"/>-->

	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="recordURI">
		<xsl:choose>
			<xsl:when test="string(/content/config/uri_space)">
				<xsl:value-of select="concat(/content/config/uri_space, /content/eac:eac-cpf/eac:control/eac:recordId)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($url, 'id/', /content/eac:eac-cpf/eac:control/eac:recordId)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="type" select="/content/eac:eac-cpf/eac:cpfDescription/eac:identity/eac:entityType"/>

	<!-- get dynasty/organization and skos:broader RDF -->
	<!--<xsl:variable name="rdf" as="element()*">
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
			xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#"
			xmlns:nomisma="http://nomisma.org/" xmlns:nmo="http://nomisma.org/ontology#">
			<xsl:variable name="id-param">
				<xsl:for-each
					select="
						distinct-values(descendant::org:memberOf/@rdf:resource | descendant::org:organization/@rdf:resource | descendant::skos:broader/@rdf:resource)">
					<xsl:value-of select="substring-after(., 'id/')"/>
					<xsl:if test="not(position() = last())">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="rdf_url" select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($id-param))"/>
			<xsl:copy-of select="document($rdf_url)/rdf:RDF/*"/>
		</rdf:RDF>
	</xsl:variable>-->

	<xsl:template match="/">
		<xsl:variable name="model" as="element()*">
			<_object>
				<xsl:apply-templates select="/content/eac:eac-cpf"/>
			</_object>
		</xsl:variable>

		<xsl:apply-templates select="$model"/>
	</xsl:template>

	<xsl:template match="eac:eac-cpf">
		<__context>https://linked.art/ns/v1/linked-art.json</__context>
		<id>
			<xsl:value-of select="$recordURI"/>
		</id>
		<type>
			<xsl:value-of select="
					if ($type = 'person') then
						'Person'
					else
						'Group'"/>
		</type>
		<_label>
			<xsl:value-of select="descendant::eac:nameEntry[1]/eac:part"/>
		</_label>

		<identified_by>
			<_array>
				<_object>
					<type>Name</type>
					<content>
						<xsl:value-of select="descendant::eac:nameEntry[1]/eac:part"/>
					</content>
					<classified_as>
						<_array>
							<_object>
								<id>http://vocab.getty.edu/aat/300404670</id>
								<type>Type</type>
								<_label>Primary Name</_label>
							</_object>
						</_array>
					</classified_as>
				</_object>
			</_array>
		</identified_by>

		<xsl:apply-templates select="eac:cpfDescription"/>
	</xsl:template>

	<xsl:template match="eac:cpfDescription">
		<xsl:apply-templates select="eac:identity | eac:description | eac:relations"/>
	</xsl:template>

	<xsl:template match="eac:identity">
		<xsl:if test="eac:entityId[@localType = 'skos:exactMatch']">
			<exact_match>
				<_array>
					<xsl:apply-templates select="eac:entityId[@localType = 'skos:exactMatch']"/>
				</_array>
			</exact_match>
		</xsl:if>
	</xsl:template>

	<xsl:template match="eac:description">
		<xsl:apply-templates select="eac:existDates[@localType = 'xeac:life']"/>

		<xsl:if test="eac:biogHist/eac:abstract">
			<referred_to_by>
				<_array>
					<xsl:apply-templates select="eac:biogHist/eac:abstract"/>
				</_array>
			</referred_to_by>
		</xsl:if>
	</xsl:template>

	<!-- definitions as brief text statements -->
	<xsl:template match="eac:abstract">
		<_object>
			<type>LinguisticObject</type>
			<content>
				<xsl:value-of select="normalize-space(.)"/>
			</content>
			<classified_as>
				<_array>
					<_object>
						<type>Type</type>
						<xsl:choose>
							<xsl:when test="$type = 'person'">
								<id>http://vocab.getty.edu/aat/300435422</id>
								<_label>Biography Statement</_label>
							</xsl:when>
							<xsl:otherwise>
								<id>http://vocab.getty.edu/aat/300411780</id>
								<_label>Description</_label>
							</xsl:otherwise>
						</xsl:choose>

						<classified_as>
							<_array>
								<_object>
									<id>http://vocab.getty.edu/aat/300418049</id>
									<type>Type</type>
									<_label>Brief Text</_label>
								</_object>
							</_array>
						</classified_as>
					</_object>
				</_array>
			</classified_as>
		</_object>
	</xsl:template>

	<xsl:template match="eac:relations">		
		<xsl:if test="eac:cpfRelation[string(@xlink:href) and @xlink:arcrole = 'org:memberOf']">
			<member_of>
				<_array>
					<xsl:apply-templates select="eac:cpfRelation[@xlink:href and @xlink:arcrole = 'org:memberOf']"/>
				</_array>
			</member_of>
		</xsl:if>
		<xsl:if test="eac:cpfRelation[string(@xlink:href) and @xlink:arcrole = 'org:hasMember']">
			<member>
				<_array>
					<xsl:apply-templates select="eac:cpfRelation[@xlink:href and @xlink:arcrole = 'org:hasMember']"/>
				</_array>
			</member>
		</xsl:if>		
	</xsl:template>

	<xsl:template match="eac:cpfRelation">
		<_object>
			<type>
				<xsl:choose>
					<xsl:when test="@xlink:arcrole = 'org:memberOf'">Group</xsl:when>
					<xsl:when test="@xlink:arcrole = 'org:hasMember'">Person</xsl:when>
				</xsl:choose>
			</type>
			<id>
				<xsl:choose>
					<xsl:when test="matches(@xlink:href, '^https?://')">
						<xsl:value-of select="@xlink:href"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="string(/content/config/uri_space)">
								<xsl:value-of select="concat(/content/config/uri_space, @xlink:href)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat($url, 'id/', @xlink:href)"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</id>
			<_label>
				<xsl:value-of select="normalize-space(.)"/>
			</_label>
			
			<!-- commenting out classification for now since the organizations don't have types in EAC-CPF -->
			<!--<xsl:if test="not(@xlink:role = 'foaf:Person')">
				<classified_as>
					<_array>
						<_object>
							<type>Type</type>
							<xsl:choose>
								<xsl:when test="@xlink:role = 'org:Organization' or @xlink:role = 'foaf:Organization'">
									<id>http://vocab.getty.edu/aat/300387047</id>
									<_label>political entities</_label>
								</xsl:when>
								<xsl:otherwise>
									<id>http://vocab.getty.edu/aat/300055474</id>
									<_label>families (kinship groups)</_label>
								</xsl:otherwise>
							</xsl:choose>
						</_object>
					</_array>
				</classified_as>
			</xsl:if>-->			
		</_object>
	</xsl:template>

	<!-- matching terms as an array of URIs -->
	<xsl:template match="eac:entityId[@localType = 'skos:exactMatch']">
		<_>
			<xsl:value-of select="."/>
		</_>
	</xsl:template>

	<!-- create associated born/died formed_by/dissolved_by properties -->
	<xsl:template match="eac:existDates[@localType = 'xeac:life']">
		<xsl:choose>
			<xsl:when test="eac:date[@standardDate or @standardDateTime]">
				<xsl:apply-templates select="eac:date"/>
			</xsl:when>
			<xsl:when test="eac:dateRange/eac:fromDate[@standardDate or @standardDateTime] and eac:dateRange/eac:toDate[@standardDate or @standardDateTime]">
				<xsl:apply-templates select="eac:dateRange/eac:fromDate | eac:dateRange/eac:toDate"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="eac:date">
		<!-- unlikely to see, but a person or organization with a single date of existence -->

		<xsl:call-template name="render_date">
			<xsl:with-param name="date" select="
					if (@standardDate) then
						@standardDate
					else
						@standardDateTime"/>
			<xsl:with-param name="range">begin</xsl:with-param>
			<xsl:with-param name="element">
				<xsl:choose>
					<xsl:when test="$type = 'person'">born</xsl:when>
					<xsl:otherwise>formed_by</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>

		<xsl:call-template name="render_date">
			<xsl:with-param name="date" select="
					if (@standardDate) then
						@standardDate
					else
						@standardDateTime"/>
			<xsl:with-param name="range">end</xsl:with-param>
			<xsl:with-param name="element">
				<xsl:choose>
					<xsl:when test="$type = 'person'">died</xsl:when>
					<xsl:otherwise>dissolved_by</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="eac:fromDate">
		<xsl:call-template name="render_date">
			<xsl:with-param name="date" select="
					if (@standardDate) then
						@standardDate
					else
						@standardDateTime"/>
			<xsl:with-param name="range">begin</xsl:with-param>
			<xsl:with-param name="element">
				<xsl:choose>
					<xsl:when test="$type = 'person'">born</xsl:when>
					<xsl:otherwise>formed_by</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="eac:toDate">
		<xsl:call-template name="render_date">
			<xsl:with-param name="date" select="
					if (@standardDate) then
						@standardDate
					else
						@standardDateTime"/>
			<xsl:with-param name="range">end</xsl:with-param>
			<xsl:with-param name="element">
				<xsl:choose>
					<xsl:when test="$type = 'person'">died</xsl:when>
					<xsl:otherwise>dissolved_by</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="render_date">
		<xsl:param name="element"/>
		<xsl:param name="date"/>
		<xsl:param name="range"/>

		<xsl:element name="{$element}">
			<_object>
				<type>
					<xsl:choose>
						<xsl:when test="$element = 'born'">Birth</xsl:when>
						<xsl:when test="$element = 'died'">Death</xsl:when>
						<xsl:when test="$element = 'formed_by'">Formed By</xsl:when>
						<xsl:when test="$element = 'dissolved_by'">Dissolution</xsl:when>
					</xsl:choose>
				</type>
				<_label>
					<xsl:choose>
						<xsl:when test="$range = 'begin'">Start Date</xsl:when>
						<xsl:when test="$range = 'end'">End Date</xsl:when>
					</xsl:choose>
				</_label>
				<timespan>
					<_object>
						<type>TimeSpan</type>
						<begin_of_the_begin>
							<xsl:value-of select="xeac:expandDate($date)"/>
						</begin_of_the_begin>
						<end_of_the_end>
							<xsl:value-of select="xeac:expandDate($date)"/>
						</end_of_the_end>
					</_object>
				</timespan>
			</_object>
		</xsl:element>
	</xsl:template>

</xsl:stylesheet>

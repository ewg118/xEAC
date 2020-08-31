<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date: August 2020
	Function: Transform Nomisma RDF into Linked Art JSON-LD. Query broader concepts -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:eac="urn:isbn:1-931666-33-4"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xeac="https://github.com/ewg118/xEAC"
	xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:xs="http://www.w3.org/2001/XMLSchema"
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
			<xsl:value-of select="if ($type = 'person') then 'Person' else 'Group'"/>
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

		<!-- birth and death events for a Person -->
		<!--<xsl:if test="$type = 'person'">
			
			<xsl:if test="bio:birth">
				<xsl:variable name="uri" select="bio:birth/@rdf:resource"/>
				<xsl:apply-templates select="/content/rdf:RDF/*[@rdf:about = $uri]"/>
			</xsl:if>
			<xsl:if test="bio:death">
				<xsl:variable name="uri" select="bio:death/@rdf:resource"/>
				<xsl:apply-templates select="/content/rdf:RDF/*[@rdf:about = $uri]"/>
			</xsl:if>
		</xsl:if>-->

		<!-- creation and dissolution for Groups -->
		<!--<xsl:if test="$type = 'foaf:Organization' or $type = 'foaf:Group' or $type = 'rdac:Family'">
			<xsl:if test="/content/rdf:RDF/org:Membership[nmo:hasStartDate]">
				<xsl:variable name="dates">
					<xsl:for-each select="//nmo:hasStartDate">
						<xsl:sort data-type="number" order="ascending"/>

						<xsl:value-of select="."/>
					</xsl:for-each>
				</xsl:variable>

				<formed_by>
					<_object>
						<type>Formation</type>
						<_label>Start Date</_label>
						<timespan>
							<_object>
								<type>TimeSpan</type>
								<begin_of_the_begin>
									<xsl:value-of select="xeac:expandDatetoDateTime($dates[1], 'begin')"/>
								</begin_of_the_begin>
								<end_of_the_end>
									<xsl:value-of select="xeac:expandDatetoDateTime($dates[1], 'end')"/>
								</end_of_the_end>
							</_object>
						</timespan>
					</_object>
				</formed_by>
			</xsl:if>

			<xsl:if test="/content/rdf:RDF/org:Membership[nmo:hasEndDate]">
				<xsl:variable name="dates">
					<xsl:for-each select="//nmo:hasEndDate">
						<xsl:sort data-type="number" order="ascending"/>

						<xsl:value-of select="."/>
					</xsl:for-each>
				</xsl:variable>

				<dissolved_by>
					<_object>
						<type>Dissolution</type>
						<_label>End Date</_label>
						<timespan>
							<_object>
								<type>TimeSpan</type>
								<begin_of_the_begin>
									<xsl:value-of select="xeac:expandDatetoDateTime($dates[last()], 'begin')"/>
								</begin_of_the_begin>
								<end_of_the_end>
									<xsl:value-of select="xeac:expandDatetoDateTime($dates[last()], 'end')"/>
								</end_of_the_end>
							</_object>
						</timespan>
					</_object>
				</dissolved_by>
			</xsl:if>
		</xsl:if>-->

		<!--<xsl:if test="/content/rdf:RDF/org:Membership[org:organization] or org:memberOf">
			<member_of>
				<_array>
					<xsl:apply-templates select="//org:Membership[org:organization] | org:memberOf"/>
				</_array>
			</member_of>
		</xsl:if>-->
	</xsl:template>
	
	<xsl:template match="eac:cpfDescription">
		<xsl:apply-templates select="eac:identity | eac:description"/>
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
		
	

	<!-- groups and dynasties -->
	<!--<xsl:template match="org:Membership">
		<xsl:if test="not(org:organization/@rdf:resource = preceding::org:Membership/org:organization/@rdf:resource)">
			<xsl:variable name="uri" select="org:organization/@rdf:resource"/>

			<xsl:apply-templates select="$rdf//*[@rdf:about = $uri]" mode="membership"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="org:memberOf">
		<xsl:variable name="uri" select="@rdf:resource"/>

		<xsl:apply-templates select="$rdf//*[@rdf:about = $uri]" mode="membership"/>
	</xsl:template>-->

	<!--<xsl:template match="*" mode="membership">
		<_object>
			<type>Group</type>
			<id>
				<xsl:value-of select="@rdf:about"/>
			</id>
			<_label>
				<xsl:value-of select="skos:prefLabel[@xml:lang = 'en']"/>
			</_label>
			<classified_as>
				<_array>
					<_object>
						<type>Type</type>
						<xsl:choose>
							<xsl:when test="self::foaf:Organization">
								<id>http://vocab.getty.edu/aat/300387047</id>
								<_label>political entities</_label>
							</xsl:when>
							<xsl:when test="self::foaf:Group">
								<id>http://vocab.getty.edu/aat/300387353</id>
								<_label>groups of political entities</_label>
							</xsl:when>
							<xsl:when test="self::rdac:Family">
								<id>http://vocab.getty.edu/aat/300386176</id>
								<_label>dynasties</_label>
							</xsl:when>
						</xsl:choose>
					</_object>
				</_array>
			</classified_as>
		</_object>
	</xsl:template>-->

	

	<!-- matching terms as an array of URIs -->
	<xsl:template match="eac:entityId[@localType = 'skos:exactMatch']">
		<_>
			<xsl:value-of select="."/>
		</_>
	</xsl:template>

	<!-- geographic coordinates -->
	

	<!-- birth and death for people -->
	<!--<xsl:template match="bio:Birth | bio:Death">
		<xsl:element name="{if (self::bio:Birth) then 'born' else 'died'}">
			<_object>
				<id>
					<xsl:value-of select="@rdf:about"/>
				</id>
				<type>Death</type>
				<timespan>
					<_object>
						<type>TimeSpan</type>
						<begin_of_the_begin>
							<xsl:value-of select="nomisma:expandDatetoDateTime(dcterms:date, 'begin')"/>
						</begin_of_the_begin>
						<end_of_the_end>
							<xsl:value-of select="nomisma:expandDatetoDateTime(dcterms:date, 'end')"/>
						</end_of_the_end>
					</_object>
				</timespan>
			</_object>
		</xsl:element>
	</xsl:template>-->

</xsl:stylesheet>

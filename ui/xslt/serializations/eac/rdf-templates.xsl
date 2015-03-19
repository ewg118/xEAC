<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:arch="http://purl.org/archival/vocab/arch#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:eac="urn:isbn:1-931666-33-4" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:crm="http://erlangen-crm.org/current/"
	xmlns:org="http://www.w3.org/ns/org#" xmlns:lawd="http://lawd.info/ontology/" xmlns:snap="http://onto.snapdrgn.net/snap#" xmlns:bio="http://purl.org/vocab/bio/0.1/"
	xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:edm="http://www.europeana.eu/schemas/edm/" exclude-result-prefixes="eac xlink xs" version="2.0">



	<xsl:template match="eac:eac-cpf" mode="default">
		<xsl:variable name="recordURI">
			<xsl:choose>
				<xsl:when test="string(/content/config/uri_space)">
					<xsl:value-of select="concat(/content/config/uri_space, eac:control/eac:recordId)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($url, 'id/', eac:control/eac:recordId)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>


		<xsl:call-template name="concept">
			<xsl:with-param name="recordURI" select="$recordURI"/>
		</xsl:call-template>
		<xsl:call-template name="thing">
			<xsl:with-param name="recordURI" select="$recordURI"/>
		</xsl:call-template>

		<xsl:apply-templates select="descendant::eac:existDates[@localType='xeac:life']" mode="bio-objects">
			<xsl:with-param name="recordURI" select="$recordURI"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="descendant::eac:cpfRelation[substring-before(@xlink:arcrole, ':') = descendant::eac:localTypeDeclaration/eac:abbreviation]" mode="bio-predicates">
			<xsl:with-param name="recordURI" select="$recordURI"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template name="concept">
		<xsl:param name="recordURI"/>

		<skos:Concept rdf:about="{$recordURI}#concept">
			<foaf:focus rdf:resource="{$recordURI}"/>
			<xsl:call-template name="concept-body"/>
		</skos:Concept>
	</xsl:template>

	<xsl:template name="thing">
		<xsl:param name="recordURI"/>

		<xsl:choose>
			<xsl:when test="descendant::eac:entityType='person'">
				<foaf:Person rdf:about="{$recordURI}">
					<xsl:call-template name="thing-body">
						<xsl:with-param name="recordURI" select="$recordURI"/>
					</xsl:call-template>
				</foaf:Person>
			</xsl:when>
			<xsl:when test="descendant::eac:entityType='corporateBody'">
				<org:Organization rdf:about="{$recordURI}">
					<xsl:call-template name="thing-body">
						<xsl:with-param name="recordURI" select="$recordURI"/>
					</xsl:call-template>
				</org:Organization>
			</xsl:when>
			<xsl:when test="descendant::eac:entityType='family'">
				<arch:Family rdf:about="{$recordURI}">
					<xsl:call-template name="thing-body">
						<xsl:with-param name="recordURI" select="$recordURI"/>
					</xsl:call-template>
				</arch:Family>
			</xsl:when>
		</xsl:choose>
		<!--<xsl:apply-templates select="self::node()" mode="crm"/>-->
	</xsl:template>

	<!-- ***** SKOS:CONCEPT TEMPLATES ***** -->
	<xsl:template name="concept-body">
		<!-- labels -->
		<xsl:for-each select="descendant::eac:nameEntry">
			<xsl:element name="{if (string(eac:preferredForm)) then 'skos:prefLabel' else 'skos:altLabel'}" namespace="http://www.w3.org/2004/02/skos/core#">
				<xsl:if test="string(@xml:lang)">
					<xsl:attribute name="xml:lang" select="@xml:lang"/>
				</xsl:if>
				<xsl:value-of select="eac:part"/>
			</xsl:element>
		</xsl:for-each>

		<!-- related links -->
		<xsl:apply-templates select="descendant::eac:entityId[contains(@localType, ':')]" mode="concept"/>
		<xsl:apply-templates select="descendant::eac:abstract" mode="concept"/>

		<!-- thumbnail -->
		<xsl:apply-templates select="descendant::eac:resourceRelation[@xlink:arcrole='foaf:thumbnail'][@xlink:href]"/>
	</xsl:template>

	<xsl:template match="eac:abstract" mode="concept">
		<dcterms:abstract>
			<xsl:value-of select="."/>
		</dcterms:abstract>
	</xsl:template>

	<xsl:template match="eac:entityId|eac:otherRecordId" mode="concept">
		<xsl:variable name="localType" select="@localType"/>

		<xsl:variable name="otherURI">
			<xsl:choose>
				<xsl:when test=". castable as xs:anyURI and contains(., 'http://')">
					<xsl:value-of select="."/>
				</xsl:when>
				<xsl:when test=". castable as xs:anyURI and not(contains(., 'http://'))">
					<xsl:choose>
						<xsl:when test="string(/content/config/uri_space)">
							<xsl:value-of select="concat(/content/config/uri_space, .)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($url, 'id/', .)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="prefix" select="substring-before($localType, ':')"/>
		<xsl:variable name="namespace" select="ancestor::eac:eac-cpf/eac:control/eac:localTypeDeclaration[eac:abbreviation=$prefix]/eac:citation/@xlink:href"/>

		<xsl:element name="{$localType}" namespace="{$namespace}">
			<xsl:attribute name="rdf:resource" select="$otherURI"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="eac:resourceRelation[@xlink:arcrole='foaf:thumbnail']">
		<foaf:thumbnail rdf:resource="{@xlink:href}"/>
	</xsl:template>

	<!-- ***** BIOGRAPHICAL TEMPLATES FOR THING ***** -->

	<xsl:template name="thing-body">
		<xsl:param name="recordURI"/>
		
		<!-- default name is foaf:name -->
		<foaf:name>
			<xsl:value-of select="descendant::eac:nameEntry[1]/eac:part"/>
		</foaf:name>
		<xsl:apply-templates select="descendant::eac:existDates[@localType='xeac:life']" mode="bio-predicates">
			<xsl:with-param name="recordURI" select="$recordURI"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="descendant::eac:cpfRelation[substring-before(@xlink:arcrole, ':') = //eac:localTypeDeclaration/eac:abbreviation]" mode="bio"/>
	</xsl:template>

	<!-- predicates/properties which appear in the Agent Object -->
	<xsl:template match="eac:existDates[@localType='xeac:life']" mode="bio-predicates">
		<xsl:param name="recordURI"/>

		<bio:birth rdf:resource="{$recordURI}#birth"/>
		<bio:death rdf:resource="{$recordURI}#death"/>
	</xsl:template>

	<!-- objects -->
	<xsl:template match="eac:existDates[@localType='xeac:life']" mode="bio-objects">
		<xsl:param name="recordURI"/>
		
		<xsl:choose>
			<xsl:when test="eac:dateRange">
				<xsl:apply-templates select="eac:dateRange/eac:fromDate[@standardDate]" mode="bio">
					<xsl:with-param name="type">Birth</xsl:with-param>
					<xsl:with-param name="recordURI" select="$recordURI"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="eac:dateRange/eac:toDate[@standardDate]" mode="bio">
					<xsl:with-param name="type">Death</xsl:with-param>
					<xsl:with-param name="recordURI" select="$recordURI"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="eac:date[@standardDate]">
				<xsl:apply-templates select="eac:date[@standardDate]" mode="bio">
					<xsl:with-param name="type">Birth</xsl:with-param>
					<xsl:with-param name="recordURI" select="$recordURI"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="eac:date[@standardDate]" mode="bio">
					<xsl:with-param name="type">Death</xsl:with-param>
					<xsl:with-param name="recordURI" select="$recordURI"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="eac:date|eac:fromDate|eac:toDate" mode="bio">
		<xsl:param name="type"/>
		<xsl:param name="recordURI"/>

		<xsl:element name="bio:{$type}" namespace="http://purl.org/vocab/bio/0.1/">
			<xsl:attribute name="rdf:about" select="concat($recordURI, '#', lower-case($type))"/>
			<bio:date>
				<xsl:call-template name="normalizeDate">
					<xsl:with-param name="standardDate" select="@standardDate"/>
				</xsl:call-template>
			</bio:date>
		</xsl:element>
	</xsl:template>

	<xsl:template match="eac:cpfRelation" mode="bio">
		<bio:relationship>
			<bio:Relationship>
				<xsl:variable name="prefix" select="substring-before(@xlink:arcrole, ':')"/>
				<xsl:variable name="namespace" select="ancestor::eac:eac-cpf/eac:control/eac:localTypeDeclaration[eac:abbreviation=$prefix]/eac:citation/@xlink:href"/>

				<!-- insert relationship property -->
				<xsl:element name="{@xlink:arcrole}" namespace="{$namespace}">
					<xsl:choose>
						<xsl:when test="@xlink:href">
							<xsl:variable name="uri">
								<xsl:choose>
									<xsl:when test="@xlink:href castable as xs:anyURI and contains(@xlink:href, 'http://')">
										<xsl:value-of select="@xlink:href"/>
									</xsl:when>
									<xsl:when test="@xlink:href castable as xs:anyURI and not(contains(@xlink:href, 'http://'))">
										<xsl:choose>
											<xsl:when test="string(/content/config/uri_space)">
												<xsl:value-of select="concat(/content/config/uri_space,@xlink:href)"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="concat($url, 'id/',@xlink:href)"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
								</xsl:choose>
							</xsl:variable>

							<xsl:attribute name="rdf:resource" select="$uri"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="normalize-space(eac:relationEntry)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>

				<!-- dates: only date and dateRange are current handled -->
				<xsl:choose>
					<xsl:when test="eac:date[@standardDate]">
						<bio:date>
							<xsl:call-template name="normalizeDate">
								<xsl:with-param name="standardDate" select="@standardDate"/>
							</xsl:call-template>
						</bio:date>
					</xsl:when>
					<xsl:when test="eac:dateRange[eac:fromDate[@standardDate] and eac:toDate[@standardDate]]">
						<bio:date>
							<edm:TimeSpan>
								<edm:begin>
									<xsl:call-template name="normalizeDate">
										<xsl:with-param name="standardDate" select="eac:dateRange/eac:fromDate/@standardDate"/>
									</xsl:call-template>
								</edm:begin>
								<edm:end>
									<xsl:call-template name="normalizeDate">
										<xsl:with-param name="standardDate" select="eac:dateRange/eac:toDate/@standardDate"/>
									</xsl:call-template>
								</edm:end>
							</edm:TimeSpan>
						</bio:date>
					</xsl:when>
				</xsl:choose>

				<!-- handle placeEntry if there is an xlink:href -->
				<xsl:if test="eac:placeEntry[@vocabularySource]">
					<bio:place rdf:resource="{eac:placeEntry/@vocabularySource}"/>
				</xsl:if>
			</bio:Relationship>
		</bio:relationship>
	</xsl:template>

	<xsl:template name="normalizeDate">
		<xsl:param name="standardDate"/>

		<xsl:attribute name="rdf:datatype">
			<xsl:choose>
				<xsl:when test="$standardDate castable as xs:date">
					<xsl:text>http://www.w3.org/2001/XMLSchema#date</xsl:text>
				</xsl:when>
				<xsl:when test="$standardDate castable as xs:gYearMonth">
					<xsl:text>http://www.w3.org/2001/XMLSchema#gYearMonth</xsl:text>
				</xsl:when>
				<xsl:when test="$standardDate castable as xs:gYear">
					<xsl:text>http://www.w3.org/2001/XMLSchema#gYear</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:attribute>
		<xsl:value-of select="$standardDate"/>
	</xsl:template>

	<!-- ***** CIDOC CRM ***** -->
	<xsl:template match="eac:eac-cpf" mode="crm">
		<xsl:variable name="recordURI">
			<xsl:choose>
				<xsl:when test="string(/content/config/uri_space)">
					<xsl:value-of select="concat(/content/config/uri_space, eac:control/eac:recordId)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($url, 'id/', eac:control/eac:recordId)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>


		<xsl:variable name="entityType" select="descendant::eac:entityType"/>

		<xsl:element name="{if ($entityType='person') then 'crm:E21_Person' else 'crm:E74_Group'}" namespace="http://erlangen-crm.org/current/">
			<xsl:attribute name="rdf:about" select="$recordURI"/>
			<!--<xsl:for-each select="descendant::eac:nameEntry">
				<crm:P131_is_identified_by>					
					<crm:E82_Actor_Appellation>
						<rdfs:label>
							<xsl:if test="@xml:lang">
								<xsl:attribute name="xml:lang" select="@xml:lang"/>
							</xsl:if>
							<xsl:value-of select="eac:part"/>
						</rdfs:label>
					</crm:E82_Actor_Appellation>
				</crm:P131_is_identified_by>
			</xsl:for-each>-->
			<xsl:apply-templates select="eac:cpfDescription/eac:description/eac:existDates[@localType='xeac:life']" mode="crm"/>
		</xsl:element>

		<!-- relations -->
		<!-- only process relations with an xlink:arcrole from a defined namespace -->
		<xsl:apply-templates select="descendant::eac:cpfRelation[contains(@xlink:arcrole, ':') and string(@xlink:href)]" mode="snap"/>
	</xsl:template>

	<xsl:template match="eac:existDates[@localType='xeac:life']" mode="crm">
		<xsl:apply-templates select="eac:dateRange/eac:fromDate|eac:dateRange/eac:toDate" mode="crm"/>
	</xsl:template>

	<xsl:template match="eac:fromDate|eac:toDate" mode="crm">
		<xsl:element name="{if(local-name()='fromDate') then 'crm:P92i_was_brought_into_existence_by' else 'crm:P93_took_out_of_existence'}" namespace="http://erlangen-crm.org/current/">
			<xsl:element name="{if(local-name()='fromDate') then 'crm:E63_Beginning_of_Existence' else 'crm:E64_End_of_Existence'}" namespace="http://erlangen-crm.org/current/">
				<crm:P4_has_time-span>
					<crm:E52_Time-Span>
						<rdfs:label>
							<xsl:value-of select="."/>
						</rdfs:label>
						<xsl:choose>
							<xsl:when test="@standardDate">
								<xsl:call-template name="generate-date">
									<xsl:with-param name="type">standardDate</xsl:with-param>
									<xsl:with-param name="date" select="@standardDate"/>
									<xsl:with-param name="parent" select="local-name()"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:when test="@notBefore or @notAfter">
								<xsl:choose>
									<xsl:when test="@notBefore">
										<xsl:call-template name="generate-date">
											<xsl:with-param name="type">notBefore</xsl:with-param>
											<xsl:with-param name="date" select="@standardDate"/>
											<xsl:with-param name="parent" select="local-name()"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:when test="@notAfter">
										<xsl:call-template name="generate-date">
											<xsl:with-param name="type">notAfter</xsl:with-param>
											<xsl:with-param name="date" select="@standardDate"/>
											<xsl:with-param name="parent" select="local-name()"/>
										</xsl:call-template>
									</xsl:when>
								</xsl:choose>
							</xsl:when>
						</xsl:choose>
					</crm:E52_Time-Span>
				</crm:P4_has_time-span>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template name="generate-date">
		<xsl:param name="parent"/>
		<xsl:param name="date"/>
		<xsl:param name="type"/>

		<xsl:variable name="element">
			<xsl:text>crm:P82a_</xsl:text>
			<xsl:text>TYPE</xsl:text>
			<xsl:text>_of_the_</xsl:text>
			<xsl:value-of select="if ($parent='fromDate') then 'begin' else 'end'"/>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$type='standardDate'">
				<xsl:element name="{replace($element, 'TYPE', 'begin')}">
					<xsl:call-template name="date-datatype">
						<xsl:with-param name="date" select="$date"/>
					</xsl:call-template>
					<xsl:value-of select="$date"/>
				</xsl:element>
				<xsl:element name="{replace($element, 'TYPE', 'end')}">
					<xsl:call-template name="date-datatype">
						<xsl:with-param name="date" select="$date"/>
					</xsl:call-template>
					<xsl:value-of select="$date"/>
				</xsl:element>
			</xsl:when>
			<xsl:when test="$type='notBefore'">
				<xsl:element name="{replace($element, 'TYPE', 'begin')}">
					<xsl:call-template name="date-datatype">
						<xsl:with-param name="date" select="$date"/>
					</xsl:call-template>
					<xsl:value-of select="$date"/>
				</xsl:element>
			</xsl:when>
			<xsl:when test="$type='notAfter'">
				<xsl:element name="{replace($element, 'TYPE', 'end')}">
					<xsl:call-template name="date-datatype">
						<xsl:with-param name="date" select="$date"/>
					</xsl:call-template>
					<xsl:value-of select="$date"/>
				</xsl:element>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="date-datatype">
		<xsl:param name="date"/>
		<xsl:attribute name="rdf:datatype">
			<xsl:choose>
				<xsl:when test="$date castable as xs:gYear">http://www.w3.org/2001/XMLSchema#gYear</xsl:when>
				<xsl:when test="$date castable as xs:gYearMonth">http://www.w3.org/2001/XMLSchema#gYearMonth</xsl:when>
				<xsl:when test="$date castable as xs:date">http://www.w3.org/2001/XMLSchema#date</xsl:when>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>

	<!-- *************** SNAP RDF ***************** -->
	<xsl:template match="eac:eac-cpf" mode="snap">
		<xsl:variable name="recordURI">
			<xsl:choose>
				<xsl:when test="string(/content/config/uri_space)">
					<xsl:value-of select="concat(/content/config/uri_space, eac:control/eac:recordId)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($url, 'id/', eac:control/eac:recordId)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<rdf:RDF>
			<lawd:Person rdf:about="{$recordURI}">
				<dcterms:publisher rdf:resource="{$url}"/>
				<!--<lawd:hasName rdf:resource="{$recordURI}#name"/>-->
				<xsl:for-each select="descendant::eac:nameEntry">
					<foaf:name>
						<xsl:if test="@xml:lang">
							<xsl:attribute name="xml:lang" select="@xml:lang"/>
						</xsl:if>
						<xsl:value-of select="eac:part"/>
					</foaf:name>
				</xsl:for-each>
				<xsl:apply-templates select="descendant::eac:existDates/*"/>
				<xsl:for-each select="descendant::eac:source">
					<lawd:hasAttestation rdf:resource="{$recordURI}#attestation{position()}"/>
				</xsl:for-each>
				<xsl:for-each select="eac:control/eac:otherRecordId[. castable as xs:anyURI and contains(., 'http://')]">
					<dcterms:identifier rdf:resource="{.}"/>
				</xsl:for-each>

				<xsl:apply-templates select="descendant::eac:cpfRelation[contains(@xlink:arcrole, ':') and string(@xlink:href)]" mode="snap"/>
			</lawd:Person>

			<!--<lawd:PersonalName rdf:about="{$recordURI}#name">
				<dcterms:publisher rdf:resource="{$url}"/>
				<xsl:for-each select="descendant::eac:nameEntry[eac:preferredForm]">
					<lawd:primaryForm>
						<xsl:if test="@xml:lang">
							<xsl:attribute name="xml:lang" select="@xml:lang"/>
						</xsl:if>
						<xsl:value-of select="eac:part"/>
					</lawd:primaryForm>
				</xsl:for-each>
			</lawd:PersonalName>-->

			<xsl:for-each select="descendant::eac:source">
				<lawd:Attestation rdf:about="{$recordURI}#attestation{position()}">
					<lawd:hasCitation rdf:resource="{@xlink:href}"/>
				</lawd:Attestation>
			</xsl:for-each>
		</rdf:RDF>
	</xsl:template>

	<xsl:template match="eac:cpfRelation" mode="snap">
		<xsl:variable name="uri">
			<xsl:choose>
				<xsl:when test="contains(@xlink:href, 'http://')">
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
		</xsl:variable>
		<xsl:variable name="prefix" select="substring-before(@xlink:arcrole, ':')"/>

		<snap:Bond>
			<rdf:type rdf:resource="{concat(ancestor::eac:eac-cpf/eac:control/eac:localTypeDeclaration[eac:abbreviation=$prefix]/eac:citation/@xlink:href, substring-after(@xlink:arcrole, ':'))}"/>
		</snap:Bond>
		<!--
		<xsl:variable name="namespace" select="ancestor::eac:eac-cpf/eac:control/eac:localTypeDeclaration[eac:abbreviation=$prefix]/eac:citation/@xlink:href"/>
		<xsl:element name="{@xlink:arcrole}" namespace="{$namespace}">
			<xsl:attribute name="rdf:resource" select="$uri"/>
		</xsl:element>-->
	</xsl:template>

	<xsl:template match="eac:existDates/*">
		<dcterms:date>
			<xsl:choose>
				<xsl:when test="local-name() = 'date'">
					<xsl:value-of select="@standardDate"/>
				</xsl:when>
				<xsl:when test="local-name()='dateRange'">
					<xsl:value-of select="eac:fromDate/@standardDate"/>
					<xsl:text>/</xsl:text>
					<xsl:value-of select="eac:toDate/@standardDate"/>
				</xsl:when>
			</xsl:choose>
		</dcterms:date>
	</xsl:template>

</xsl:stylesheet>

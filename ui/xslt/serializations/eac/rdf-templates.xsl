<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:arch="http://purl.org/archival/vocab/arch#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:eac="urn:isbn:1-931666-33-4" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:ecrm="http://erlangen-crm.org/current/" xmlns:lawd="http://snapdrgn.net"
	xmlns:bio="http://purl.org/vocab/bio/0.1/" xmlns:owl="http://www.w3.org/2002/07/owl#" exclude-result-prefixes="eac xlink xs" version="2.0">

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

	<!-- ***** DEFAULT TEMPLATES: used for $id.rdf ***** -->
	<xsl:template match="eac:eac-cpf" mode="default">

		<rdf:RDF>
			<xsl:choose>
				<xsl:when test="descendant::eac:entityType='person'">
					<foaf:Person rdf:about="{$recordURI}">
						<xsl:call-template name="rdf-body"/>
					</foaf:Person>
				</xsl:when>
				<xsl:when test="descendant::eac:entityType='corporateBody'">
					<foaf:Organization rdf:about="{$recordURI}">
						<xsl:call-template name="rdf-body"/>
					</foaf:Organization>
				</xsl:when>
				<xsl:when test="descendant::eac:entityType='family'">
					<arch:Family rdf:about="{$recordURI}">
						<xsl:call-template name="rdf-body"/>
					</arch:Family>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="descendant::eac:existDates[@localType='xeac:life']/eac:dateRange">
					<xsl:apply-templates select="eac:dateRange/eac:fromDate[@standardDate]" mode="default">
						<xsl:with-param name="type">Birth</xsl:with-param>
					</xsl:apply-templates>
					<xsl:apply-templates select="eac:dateRange/eac:fromDate[@standardDate]" mode="default">
						<xsl:with-param name="type">Death</xsl:with-param>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="descendant::eac:existDates[@localType='xeac:life']/eac:date[@standardDate]">
					<xsl:apply-templates select="eac:date[@standardDate]" mode="default">
						<xsl:with-param name="type">Birth</xsl:with-param>
					</xsl:apply-templates>
					<xsl:apply-templates select="eac:date[@standardDate]" mode="default">
						<xsl:with-param name="type">Death</xsl:with-param>
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</rdf:RDF>
	</xsl:template>

	<xsl:template name="rdf-body">
		<!-- labels -->
		<xsl:for-each select="descendant::eac:nameEntry">
			<xsl:element name="{if (string(eac:preferredForm)) then 'skos:prefLabel' else 'skos:altLabel'}" namespace="http://www.w3.org/2004/02/skos/core#">
				<xsl:if test="string(@xml:lang)">
					<xsl:attribute name="xml:lang" select="@xml:lang"/>
				</xsl:if>
				<xsl:value-of select="eac:part"/>
			</xsl:element>
		</xsl:for-each>

		<!-- exist dates -->
		<xsl:apply-templates select="descendant::eac:existDates[@localType='xeac:life']" mode="default"/>

		<!-- related links -->
		<xsl:apply-templates select="eac:control/eac:otherRecordId" mode="default"/>

		<!-- relations -->
		<!-- only process relations with an xlink:arcrole from a defined namespace -->
		<xsl:apply-templates
			select="descendant::eac:cpfRelation[contains(@xlink:arcrole, ':') and string(@xlink:href)]|descendant::eac:resourceRelation[contains(@xlink:arcrole, ':') and string(@xlink:href)]"
			mode="default"/>

		<xsl:apply-templates select="descendant::eac:abstract" mode="default"/>
	</xsl:template>

	<xsl:template match="eac:cpfRelation|eac:resourceRelation" mode="default">
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
		<xsl:variable name="namespace" select="ancestor::eac:eac-cpf/eac:control/eac:localTypeDeclaration[eac:abbreviation=$prefix]/eac:citation/@xlink:href"/>
		<xsl:element name="{@xlink:arcrole}" namespace="{$namespace}">
			<xsl:attribute name="rdf:resource" select="$uri"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="eac:abstract" mode="default">
		<dcterms:abstract>
			<xsl:value-of select="."/>
		</dcterms:abstract>
	</xsl:template>

	<xsl:template match="eac:otherRecordId" mode="default">
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

		<xsl:choose>
			<!-- exploit the semantic property contained in the localType, if it contains a matching localTypeDeclaration -->
			<xsl:when test="parent::eac:control/eac:localTypeDeclaration/eac:abbreviation=$localType">
				<xsl:variable name="property" select="substring-after($localType, ':')"/>
				<xsl:variable name="namespace" select="substring-before(parent::eac:control/eac:localTypeDeclaration[eac:abbreviation=$localType][1]/eac:citation/@xlink:href, $property)"/>

				<xsl:element name="{$localType}" namespace="{$namespace}">
					<xsl:attribute name="rdf:resource" select="$otherURI"/>
				</xsl:element>
			</xsl:when>
			<!-- otherwise use skos:relatedMatch for other record IDs that link externally, skos:related for internally linked records -->
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test=". castable as xs:anyURI and contains(., 'http://')">
						<skos:relatedMatch rdf:resource="{$otherURI}"/>
					</xsl:when>
					<xsl:when test=". castable as xs:anyURI and not(contains(., 'http://'))">
						<skos:related rdf:resource="{$otherURI}"/>
					</xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="eac:existDates[@localType='xeac:life']" mode="default">
		<xsl:choose>
			<xsl:when test="eac:dateRange">
				<bio:birth rdf:resource="{$recordURI}#birth"/>
				<bio:death rdf:resource="{$recordURI}#death"/>
			</xsl:when>
			<xsl:when test="eac:date[@standardDate]">
				<bio:birth rdf:resource="{$recordURI}#birth"/>
				<bio:death rdf:resource="{$recordURI}#death"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="eac:date|eac:fromDate|eac:toDate" mode="default">
		<xsl:param name="type"/>
		
		<xsl:element name="bio:{$type}" namespace="http://purl.org/vocab/bio/0.1/">
			<xsl:attribute name="rdf:about" select="concat($recordURI, '#', lower-case($type))"/>
			<dcterms:date>
				<xsl:attribute name="rdf:datatype">
					<xsl:choose>
						<xsl:when test="@standardDate castable as xs:date">
							<xsl:text>http://www.w3.org/2001/XMLSchema#date</xsl:text>
						</xsl:when>
						<xsl:when test="@standardDate castable as xs:gYearMonth">
							<xsl:text>http://www.w3.org/2001/XMLSchema#gYearMonth</xsl:text>
						</xsl:when>
						<xsl:when test="@standardDate castable as xs:gYear">
							<xsl:text>http://www.w3.org/2001/XMLSchema#gYear</xsl:text>
						</xsl:when>
					</xsl:choose>
				</xsl:attribute>
				<xsl:value-of select="@standardDate"/>
			</dcterms:date>
		</xsl:element>
		
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

		<rdf:RDF>
			<xsl:element name="{if ($entityType='person') then 'ecrm:E21_Person' else 'ecrm:E74_Group'}" namespace="http://erlangen-crm.org/current/">
				<xsl:attribute name="rdf:about" select="$recordURI"/>
				<xsl:for-each select="descendant::eac:nameEntry">
					<ecrm:P131_is_identified_by>
						<xsl:if test="@xml:lang">
							<xsl:attribute name="xml:lang" select="@xml:lang"/>
						</xsl:if>
						<ecrm:E82_Actor_Appellation>
							<rdf:value>
								<xsl:value-of select="eac:part"/>
							</rdf:value>
						</ecrm:E82_Actor_Appellation>
					</ecrm:P131_is_identified_by>
				</xsl:for-each>
				<xsl:apply-templates select="eac:cpfDescription/eac:description/eac:existDates" mode="crm"/>
			</xsl:element>
		</rdf:RDF>
	</xsl:template>

	<xsl:template match="eac:existDates" mode="crm">
		<xsl:apply-templates select="eac:dateRange/eac:fromDate|eac:dateRange/eac:toDate" mode="crm"/>
	</xsl:template>

	<xsl:template match="eac:fromDate|eac:toDate" mode="crm">
		<xsl:element name="{if(local-name()='fromDate') then 'ecrm:P92i_was_brought_into_existence_by' else 'ecrm:P93_took_out_of_existence'}" namespace="http://erlangen-crm.org/current/">
			<xsl:element name="{if(local-name()='fromDate') then 'ecrm:E63_Beginning_of_Existence' else 'ecrm:E64_End_of_Existence'}" namespace="http://erlangen-crm.org/current/">
				<ecrm:P4_has_time-span>
					<ecrm:E52_Time-Span>
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
					</ecrm:E52_Time-Span>
				</ecrm:P4_has_time-span>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template name="generate-date">
		<xsl:param name="parent"/>
		<xsl:param name="date"/>
		<xsl:param name="type"/>

		<xsl:variable name="element">
			<xsl:text>ecrm:P82a_</xsl:text>
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

				<xsl:apply-templates
					select="descendant::eac:cpfRelation[contains(@xlink:arcrole, ':') and string(@xlink:href)]|descendant::eac:resourceReslation[contains(@xlink:arcrole, ':') and string(@xlink:href)]"
					mode="default"/>
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

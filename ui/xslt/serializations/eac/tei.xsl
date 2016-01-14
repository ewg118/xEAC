<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:eac="urn:isbn:1-931666-33-4" exclude-result-prefixes="xs xlink eac tei" version="2.0">
	<xsl:output method="xml" encoding="UTF-8"/>

	<xsl:variable name="id" select="/content/eac:eac-cpf/eac:control/eac:recordId"/>
	<xsl:variable name="url" select="/content/config/url"/>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/eac:eac-cpf"/>
	</xsl:template>

	<xsl:template match="eac:eac-cpf">
		<TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.tei-c.org/ns/1.0 http://www.tei-c.org/release/xml/tei/custom/schema/xsd/tei_all.xsd">
			<teiHeader>
				<fileDesc>
					<titleStmt>
						<title>
							<xsl:value-of select="/content/config/title"/>
						</title>
						<author>
							<xsl:value-of select="descendant::eac:maintenanceAgency/eac:agencyName"/>
						</author>
					</titleStmt>
					<editionStmt>
						<edition>
							<date when="{descendant::eac:maintenanceEvent[last()]/eac:eventDateTime/@standardDateTime}">
								<xsl:value-of select="descendant::eac:maintenanceEvent[last()]/eac:eventDateTime/@standardDateTime"/>
							</date>
						</edition>
					</editionStmt>
					<publicationStmt>
						<authority>
							<xsl:value-of select="descendant::eac:maintenanceAgency/eac:agencyName"/>
						</authority>
					</publicationStmt>
					<sourceDesc>
						<p>Derived dynamically from EAC-CPF in xEAC.</p>
					</sourceDesc>
				</fileDesc>
			</teiHeader>
			<text>
				<body>
					<xsl:apply-templates select="eac:cpfDescription"/>
				</body>
			</text>
		</TEI>
	</xsl:template>

	<xsl:template match="eac:cpfDescription">
		<xsl:apply-templates select="eac:identity"/>
	</xsl:template>

	<xsl:template match="eac:identity">
		<xsl:variable name="elements" as="item()*">
			<elements>
				<xsl:choose>
					<xsl:when test="eac:entityType='person'">
						<l1>listPerson</l1>
						<l2>person</l2>
						<l3>persName</l3>
					</xsl:when>
					<xsl:when test="eac:entityType='family'">
						<l1>listOrg</l1>
						<l2>org</l2>
						<l3>name</l3>
					</xsl:when>
					<xsl:when test="eac:entityType='corporateBody'">
						<l1>listOrg</l1>
						<l2>org</l2>
						<l3>orgName</l3>
					</xsl:when>
				</xsl:choose>
			</elements>
		</xsl:variable>


		<xsl:element name="{$elements//l1}" namespace="http://www.tei-c.org/ns/1.0">
			<xsl:element name="{$elements//l2}" namespace="http://www.tei-c.org/ns/1.0">
				<xsl:attribute name="xml:id" select="$id"/>

				<!-- name -->
				<xsl:for-each select="eac:nameEntry">
					<xsl:element name="{$elements//l3}" namespace="http://www.tei-c.org/ns/1.0">
						<xsl:if test="@xml:lang">
							<xsl:attribute name="xml:lang" select="@xml:lang"/>
						</xsl:if>
						<xsl:if test="child::*[contains(name(), 'Form')]">
							<xsl:attribute name="type" select="child::*[contains(name(), 'Form')]/local-name()"/>
						</xsl:if>
						<xsl:if test="$elements//l3='name'">
							<xsl:attribute name="ref">arch:Family</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="eac:part"/>
					</xsl:element>
				</xsl:for-each>
				<!-- description -->
				<xsl:apply-templates select="ancestor::eac:cpfDescription/eac:description"/>
			</xsl:element>
			<!-- relations -->
			<xsl:apply-templates select="ancestor::eac:cpfDescription/eac:relations"/>
		</xsl:element>
	</xsl:template>

	<!-- *************** DESCRIPTION ******************* -->
	<xsl:template match="eac:description" xmlns="http://www.tei-c.org/ns/1.0">
		<xsl:apply-templates select="eac:existDates"/>
		<xsl:if test="eac:biogHist/eac:abstract or eac:biogHist/eac:p">
			<note type="bio">
				<xsl:apply-templates select="eac:biogHist/eac:abstract"/>
				<xsl:apply-templates select="eac:biogHist/eac:p"/>
			</note>
		</xsl:if>

		<!-- create listEvent -->
		<xsl:if test="descendant::eac:date or descendant::eac:dateRange">
			<listEvent>
				<xsl:apply-templates select="descendant::eac:date[@standardDate]|eac:description/descendant::eac:dateRange[eac:fromDate[@standardDate]]"
					mode="listEvent">
					<xsl:sort
						select="if(local-name()='date') then if (substring(@standardDate, 1, 1) = '-') then (number(tokenize(@standardDate, '-')[2]) * -1) else tokenize(@standardDate, '-')[1] else  if (substring(eac:fromDate/@standardDate, 1, 1) = '-') then (number(tokenize(eac:fromDate/@standardDate, '-')[2]) * -1) else tokenize(eac:fromDate/@standardDate, '-')[1]"/>
					<xsl:sort
						select="if(local-name()='date') then if (substring(@standardDate, 1, 1) = '-') then number(tokenize(@standardDate, '-')[3]) else tokenize(@standardDate, '-')[2] else  if (substring(eac:fromDate/@standardDate, 1, 1) = '-') then number(tokenize(eac:fromDate/@standardDate, '-')[3]) else tokenize(eac:fromDate/@standardDate, '-')[2]"/>
					<xsl:sort
						select="if(local-name()='date') then if (substring(@standardDate, 1, 1) = '-') then number(tokenize(@standardDate, '-')[4]) else tokenize(@standardDate, '-')[3] else  if (substring(eac:fromDate/@standardDate, 1, 1) = '-') then number(tokenize(eac:fromDate/@standardDate, '-')[4]) else tokenize(eac:fromDate/@standardDate, '-')[3]"
					/>
				</xsl:apply-templates>
			</listEvent>
		</xsl:if>
	</xsl:template>

	<xsl:template match="eac:date|eac:dateRange" mode="listEvent" xmlns="http://www.tei-c.org/ns/1.0">
		<xsl:if test="not(parent::eac:existDates)">
			<event>
				<!-- handle date attributes -->
				<xsl:choose>
					<xsl:when test="local-name()='date'">
						<xsl:if test="@standardDate">
							<xsl:attribute name="when" select="@standardDate"/>
						</xsl:if>
						<xsl:if test="@notAfter">
							<xsl:attribute name="notAfter" select="@notAfter"/>
						</xsl:if>
						<xsl:if test="@notBefore">
							<xsl:attribute name="notBefore" select="@notBefore"/>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="eac:fromDate/@standardDate">
							<xsl:attribute name="from" select="eac:fromDate/@standardDate"/>
						</xsl:if>
						<xsl:if test="eac:toDate/@standardDate">
							<xsl:attribute name="to" select="eac:toDate/@standardDate"/>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
				<desc>
					<xsl:call-template name="process-date"/>
					<xsl:call-template name="chron-description"/>
				</desc>
			</event>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="process-date" xmlns="http://www.tei-c.org/ns/1.0">
		<date>
			<!-- handle date attributes -->
			<xsl:choose>
				<xsl:when test="local-name()='date'">
					<xsl:if test="@standardDate">
						<xsl:attribute name="when" select="@standardDate"/>
					</xsl:if>
					<xsl:if test="@notAfter">
						<xsl:attribute name="notAfter" select="@notAfter"/>
					</xsl:if>
					<xsl:if test="@notBefore">
						<xsl:attribute name="notBefore" select="@notBefore"/>
					</xsl:if>
					<xsl:value-of select="."/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="eac:fromDate/@standardDate">
						<xsl:attribute name="from" select="eac:fromDate/@standardDate"/>
					</xsl:if>
					<xsl:if test="eac:toDate/@standardDate">
						<xsl:attribute name="to" select="eac:toDate/@standardDate"/>
					</xsl:if>
					<xsl:value-of select="eac:fromDate"/>
					<xsl:text> - </xsl:text>
					<xsl:value-of select="eac:toDate"/>
				</xsl:otherwise>
			</xsl:choose>
		</date>
	</xsl:template>

	<xsl:template name="chron-description" xmlns="http://www.tei-c.org/ns/1.0">
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
				<xsl:apply-templates select="parent::node()/eac:placeEntry"/>
			</xsl:when>
		</xsl:choose>
		<xsl:if test="string(parent::node()/eac:placeEntry) and not(parent::eac:place)">
			<xsl:text>, </xsl:text>
			<xsl:apply-templates select="parent::node()/eac:placeEntry"/>
			<xsl:text>.</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="eac:abstract" xmlns="http://www.tei-c.org/ns/1.0">
		<ab>
			<xsl:value-of select="."/>
		</ab>
	</xsl:template>

	<xsl:template match="eac:p" xmlns="http://www.tei-c.org/ns/1.0">
		<p>
			<xsl:value-of select="."/>
		</p>
	</xsl:template>

	<xsl:template match="eac:existDates" xmlns="http://www.tei-c.org/ns/1.0">
		<xsl:choose>
			<xsl:when test="eac:date">
				<xsl:apply-templates select="eac:date" mode="existDates"/>
			</xsl:when>
			<xsl:when test="eac:dateRange">
				<xsl:apply-templates select="eac:dateRange/eac:fromDate" mode="existDates"/>
				<xsl:apply-templates select="eac:dateRange/eac:toDate" mode="existDates"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="existDates">
		<xsl:variable name="element">
			<xsl:choose>
				<xsl:when test="local-name()='date'">event</xsl:when>
				<xsl:when test="local-name()='fromDate'">birth</xsl:when>
				<xsl:when test="local-name()='toDate'">death</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:element name="{$element}" xmlns="http://www.tei-c.org/ns/1.0">
			<xsl:if test="@standardDate">
				<xsl:attribute name="when" select="@standardDate"/>
			</xsl:if>
			<xsl:if test="@notAfter">
				<xsl:attribute name="notAfter" select="@notAfter"/>
			</xsl:if>
			<xsl:if test="@notBefore">
				<xsl:attribute name="notBefore" select="@notBefore"/>
			</xsl:if>
			<xsl:value-of select="."/>
		</xsl:element>
	</xsl:template>

	<!-- *************** RELATIONS ******************* -->
	<xsl:template match="eac:relations">
		<xsl:apply-templates select="eac:cpfRelation"/>
	</xsl:template>

	<xsl:template match="eac:cpfRelation" xmlns="http://www.tei-c.org/ns/1.0">
		<xsl:variable name="ref">
			<xsl:choose>
				<xsl:when test="contains(@xlink:arcrole, ':')">
					<xsl:variable name="prefix" select="substring-before(@xlink:arcrole, ':')"/>
					<xsl:value-of
						select="concat(ancestor::eac:eac-cpf/eac:control/eac:localTypeDeclaration[eac:abbreviation=$prefix]/eac:citation/@xlink:href, substring-after(@xlink:arcrole, ':'))"
					/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@xlink:arcrole"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="active">
			<xsl:choose>
				<xsl:when test="string(//config/uri_space)">
					<xsl:value-of select="concat(//config/uri_space, $id)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($url, 'id/', $id)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="passive">
			<xsl:choose>
				<xsl:when test="contains(@xlink:href, 'http://')">
					<xsl:value-of select="@xlink:href"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="string(//config/uri_space)">
							<xsl:value-of select="concat(//config/uri_space, @xlink:href)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($url, 'id/', @xlink:href)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<relation ref="{$ref}" active="{$active}" passive="{$passive}">
			<desc>
				<xsl:element name="{if (contains(@xlink:role, 'Person')) then 'persName' else if (contains(@xlink:role, 'Family')) then 'name' else 'orgName'}" namespace="http://www.tei-c.org/ns/1.0">
					<xsl:if test="@xlink:role">
						<xsl:attribute name="ref" select="@xlink:role"/>
					</xsl:if>
					<xsl:value-of select="eac:relationEntry"/>
				</xsl:element>
				<xsl:apply-templates select="descendant::eac:date|descendant::eac:dateRange" mode="single-date"/>
				<xsl:apply-templates select="eac:placeEntry"/>
				<xsl:apply-templates select="eac:descriptiveNote/eac:p"/>
			</desc>
		</relation>
	</xsl:template>
	
	<xsl:template match="eac:date|eac:dateRange" mode="single-date" xmlns="http://www.tei-c.org/ns/1.0">
		<xsl:call-template name="process-date"/>
	</xsl:template>
	
	<xsl:template match="eac:placeEntry" xmlns="http://www.tei-c.org/ns/1.0">
		<placeName>
			<xsl:if test="string(@vocabularySource)">
				<xsl:attribute name="ref" select="@vocabularySource"/>
			</xsl:if>
			<xsl:value-of select="."/>
		</placeName>
	</xsl:template>

</xsl:stylesheet>

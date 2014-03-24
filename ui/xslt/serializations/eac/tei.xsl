<?xml version="1.0" encoding="UTF-8"?>
<?cocoon-disable-caching?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:eac="urn:isbn:1-931666-33-4" version="2.0">
	<xsl:output method="xml" encoding="UTF-8"/>
	
	<xsl:variable name="id" select="/content/eac:eac-cpf/eac:control/eac:recordId"/>

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
		<!--<xsl:apply-templates select="eac:relations"/>
		<xsl:apply-templates select="eac:description"/>-->
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
						<l1>listFamily</l1>
						<l2>family</l2>
						<l3>famName</l3>
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
				<xsl:for-each select="eac:nameEntry">
					<xsl:element name="{$elements//l3}" namespace="http://www.tei-c.org/ns/1.0">
						<xsl:if test="@xml:lang">
							<xsl:attribute name="xml:lang" select="@xml:lang"/>
						</xsl:if>
						<xsl:if test="child::*[contains(name(), 'Form')]">
							<xsl:attribute name="type" select="child::*[contains(name(), 'Form')]/local-name()"/>
						</xsl:if>
						
						<xsl:value-of select="eac:part"/>
					</xsl:element>
				</xsl:for-each>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="eac:description">
		<xsl:apply-templates select="eac:existDates/*"/>
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

<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:eac="urn:isbn:1-931666-33-4" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xeac="https://github.com/ewg118/xEAC"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../widgets.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<xsl:param name="mode">
		<xsl:choose>
			<xsl:when test="contains(doc('input:request')/request/request-url, 'admin/')">private</xsl:when>
			<xsl:otherwise>public</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:variable name="display_path">
		<xsl:choose>
			<xsl:when test="$mode='private'">
				<xsl:text>../../</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>../</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="url" select="/content/config/url"/>

	<xsl:variable name="id" select="//eac:eac-cpf/eac:control/eac:recordId"/>

	<xsl:variable name="namespaces" as="item()*">
		<namespaces>
			<namespace prefix="dcterms">http://purl.org/dc/terms/</namespace>
			<namespace prefix="foaf">http://xmlns.com/foaf/0.1/</namespace>
			<namespace prefix="geo">http://www.w3.org/2003/01/geo/wgs84_pos#</namespace>
			<namespace prefix="owl">http://www.w3.org/2002/07/owl#</namespace>
			<namespace prefix="rdfs">http://www.w3.org/2000/01/rdf-schema#</namespace>
			<namespace prefix="rdfa">http://www.w3.org/ns/rdfa#</namespace>
			<namespace prefix="rdf">http://www.w3.org/1999/02/22-rdf-syntax-ns#</namespace>
			<namespace prefix="skos">http://www.w3.org/2004/02/skos/core#</namespace>
		</namespaces>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:apply-templates select="/content/eac:eac-cpf"/>
	</xsl:template>

	<xsl:template match="eac:eac-cpf">
		<html lang="en">
			<!-- dynamically generate prefix attribute -->
			<xsl:attribute name="prefix">
				<xsl:for-each select="$namespaces//namespace">
					<xsl:value-of select="@prefix"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
				<xsl:for-each select="descendant::eac:localTypeDeclaration[eac:citation[@xlink:role='semantic']]">
					<xsl:value-of select="eac:abbreviation"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="eac:citation/@xlink:href"/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:attribute>
			<head>
				<title>
					<xsl:value-of select="/content/config/title"/>
					<xsl:text>: </xsl:text>
					<xsl:choose>
						<xsl:when test="eac:cpfDescription/eac:identity/eac:nameEntry[eac:preferredForm='WIKIPEDIA']">
							<xsl:value-of select="eac:cpfDescription/eac:identity/eac:nameEntry[eac:preferredForm='WIKIPEDIA']/eac:part"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="eac:cpfDescription/eac:identity/eac:nameEntry[1]/eac:part"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text> (</xsl:text>
					<xsl:value-of select="$id"/>
					<xsl:text>)</xsl:text>
				</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
				<link rel="stylesheet" href="{$url}ui/css/style.css"/>
				<script type="text/javascript" src="{$url}ui/javascript/display_functions.js"/>
				<!-- mapping -->
				<xsl:if test="descendant::eac:placeEntry[string(@vocabularySource)]">
					<script src="http://www.openlayers.org/api/OpenLayers.js" type="text/javascript"/>
					<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.2&amp;sensor=false"/>
					<script type="text/javascript" src="{$url}ui/javascript/mxn.js"/>
					<script type="text/javascript" src="{$url}ui/javascript/timeline-2.3.0.js"/>
					<script type="text/javascript" src="{$url}ui/javascript/timemap_full.pack.js"/>
					<script type="text/javascript" src="{$url}ui/javascript/param.js"/>
					<script type="text/javascript" src="{$url}ui/javascript/loaders/kml.js"/>
				</xsl:if>
				<xsl:if test="string(/content/config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="/content/config/google_analytics"/>
					</script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="display"/>
				<xsl:call-template name="footer"/>
				<div style="display:none">
					<span id="id">
						<xsl:value-of select="//eac:recordId"/>
					</span>
					<span id="mappable">
						<xsl:choose>
							<xsl:when test="descendant::eac:placeEntry[string(@vocabularySource)]">true</xsl:when>
							<xsl:otherwise>false</xsl:otherwise>
						</xsl:choose>
					</span>
					<span id="url">
						<xsl:value-of select="$url"/>
					</span>
					<xsl:call-template name="control-fields"/>
				</div>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="display">
		<xsl:variable name="typeof">
			<xsl:choose>
				<xsl:when test="descendant::eac:entityType='person'">foaf:Person</xsl:when>
				<xsl:when test="descendant::eac:entityType='corporateBody'">foaf:Organization</xsl:when>
				<xsl:when test="descendant::eac:entityType='family'">arch:Family</xsl:when>
			</xsl:choose>
		</xsl:variable>


		<div class="container-fluid" typeof="{$typeof}" about="{//eac:recordId}">
			<div class="row">
				<div class="col-md-12">
					<h1>
						<xsl:choose>
							<xsl:when test="eac:cpfDescription/eac:identity/eac:nameEntry[eac:preferredForm='WIKIPEDIA']">
								<xsl:value-of select="eac:cpfDescription/eac:identity/eac:nameEntry[eac:preferredForm='WIKIPEDIA']/eac:part"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="eac:cpfDescription/eac:identity/eac:nameEntry[1]/eac:part"/>
							</xsl:otherwise>
						</xsl:choose>
					</h1>
					<a href="#" id="toggle_names">hide/show names</a>
					<xsl:if test="eac:cpfDescription/eac:identity/eac:nameEntry[child::node()='WIKIPEDIA']">
						<div id="wiki-names">
							<xsl:for-each select="eac:cpfDescription/eac:identity/eac:nameEntry[*[local-name() != 'preferredForm']='WIKIPEDIA']">
								<xsl:value-of select="eac:part"/>
								<xsl:if test="not(position()=last())">
									<xsl:text> / </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</div>
					</xsl:if>

					<div id="names" style="display:none">
						<xsl:for-each select="//eac:conventionDeclaration">
							<xsl:variable name="abbreviation" select="eac:abbreviation"/>
							<h2>
								<xsl:value-of select="eac:citation"/>
							</h2>
							<dl class="dl-horizontal">
								<xsl:for-each select="//eac:nameEntry[child::node()=$abbreviation]">
									<dt>
										<xsl:choose>
											<xsl:when test="eac:authorizedForm">
												<xsl:text>authorized form</xsl:text>
											</xsl:when>
											<xsl:when test="eac:preferredForm">
												<xsl:text>preferred form</xsl:text>
											</xsl:when>
											<xsl:when test="eac:alternativeForm">
												<xsl:text>alternative form</xsl:text>
											</xsl:when>
										</xsl:choose>
									</dt>
									<dd>
										<span>
											<xsl:choose>
												<xsl:when test="eac:preferredForm">
													<xsl:attribute name="property">skos:prefLabel</xsl:attribute>
												</xsl:when>
												<xsl:when test="eac:alternativeForm">
													<xsl:attribute name="property">skos:altLabel</xsl:attribute>
												</xsl:when>
											</xsl:choose>
											<xsl:if test="string(@xml:lang)">
												<xsl:attribute name="xml:lang" select="@xml:lang"/>
											</xsl:if>
											<xsl:value-of select="eac:part"/>
										</span>
										<xsl:if test="@xml:lang">
											<xsl:text> (</xsl:text>
											<xsl:value-of select="@xml:lang"/>
											<xsl:text>)</xsl:text>
										</xsl:if>
										<xsl:if test="eac:useDates">
											<xsl:text>, dates of use: </xsl:text>
											<xsl:choose>
												<xsl:when test="eac:useDates/eac:date">
													<xsl:value-of select="eac:useDates/eac:date"/>
												</xsl:when>
												<xsl:when test="eac:useDates/eac:dateRange">
													<xsl:value-of select="eac:useDates/eac:dateRange/eac:fromDate"/>
													<xsl:text>-</xsl:text>
													<xsl:value-of select="eac:useDates/eac:dateRange/eac:toDate"/>
												</xsl:when>
											</xsl:choose>
										</xsl:if>
									</dd>
								</xsl:for-each>
							</dl>
						</xsl:for-each>
					</div>
				</div>
			</div>
			<div class="row">
				<div class="col-md-9">
					<xsl:call-template name="body"/>
				</div>
				<div class="col-md-3">
					<xsl:call-template name="side-bar"/>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="body">
		<xsl:if test="descendant::eac:placeEntry[string(@vocabularySource)]">
			<div id="timemap">
				<div id="mapcontainer">
					<div id="map"/>
				</div>
				<div id="timelinecontainer">
					<div id="timeline"/>
				</div>
			</div>
		</xsl:if>
		<xsl:apply-templates select="eac:cpfDescription"/>
	</xsl:template>

	<xsl:template name="side-bar">
		<xsl:choose>
			<xsl:when test="descendant::eac:resourceRelation[@xlink:arcrole='foaf:thumbnail']">
				<p class="text-center">
					<img src="{descendant::eac:resourceRelation[@xlink:arcrole='foaf:thumbnail']/@xlink:href}" alt="Portrait" style="max-width:100%;"/>
				</p>			
			</xsl:when>
			<xsl:when test="descendant::eac:resourceRelation[@xlink:arcrole='foaf:depiction']">
				<p class="text-center">
					<img src="{descendant::eac:resourceRelation[@xlink:arcrole='foaf:depiction']/@xlink:href}" alt="Portrait" style="max-width:100%;"/>
				</p>			
			</xsl:when>
		</xsl:choose>
		
		
		<h3>Export</h3>
		<ul>
			<li>
				<a href="{$id}.xml">EAC-CPF</a>
			</li>
			<li>
				<a href="{$id}.tei">TEI</a>
			</li>
			<li>RDF/XML <ul>
					<li><a href="{$id}.rdf">Default</a></li>
					<li><a href="{$url}api/get?id={$id}&amp;model=cidoc-crm">CIDOC CRM</a></li>
					<li><a href="{$url}api/get?id={$id}&amp;model=snap">SNAP</a></li>
				</ul></li>
			<li>
				<a href="{$id}.kml">KML</a>
			</li>
		</ul>
		<!-- display otherRecordIds, create links when applicable -->
		<xsl:if test="count(eac:control/eac:otherRecordId) &gt; 0">
			<h3>Associated Identifiers</h3>
			<ul>
				<xsl:for-each select="eac:control/eac:otherRecordId">
					<li>
						<xsl:choose>
							<xsl:when test="contains(., 'http://')">
								<a href="{.}" rel="skos:related">
									<xsl:value-of select="."/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="."/>
							</xsl:otherwise>
						</xsl:choose>
					</li>
				</xsl:for-each>
			</ul>
		</xsl:if>

		<!-- if there is an otherRecordId with a nomisma ID, construction nomisma SPARQL -->
		<xsl:for-each select="descendant::eac:otherRecordId[contains(., 'nomisma.org')]">
			<xsl:call-template name="xeac:queryNomisma">
				<xsl:with-param name="uri" select="."/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="eac:cpfDescription">
		<xsl:apply-templates select="eac:description"/>
		<xsl:if test="eac:relations or string(//config/sparql/query)">
			<xsl:call-template name="relations"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="eac:description">
		<div id="description">
			<h2>Description</h2>
			<xsl:apply-templates select="eac:existDates"/>
			<xsl:apply-templates select="eac:biogHist"/>
		</div>
		<xsl:if test="descendant::eac:date[not(parent::eac:existDates)] or descendant::eac:dateRange[not(parent::eac:existDates)]">
			<div id="chron">
				<h3>Chronology</h3>
				<ul>
					<xsl:apply-templates select="descendant::eac:date[@standardDate]|descendant::eac:dateRange[eac:fromDate[@standardDate]]" mode="chronList">
						<xsl:sort
							select="if(local-name()='date') then if (substring(@standardDate, 1, 1) = '-') then (number(tokenize(@standardDate, '-')[2]) * -1) else tokenize(@standardDate, '-')[1] else  if (substring(eac:fromDate/@standardDate, 1, 1) = '-') then (number(tokenize(eac:fromDate/@standardDate, '-')[2]) * -1) else tokenize(eac:fromDate/@standardDate, '-')[1]"/>
						<xsl:sort
							select="if(local-name()='date') then if (substring(@standardDate, 1, 1) = '-') then number(tokenize(@standardDate, '-')[3]) else tokenize(@standardDate, '-')[2] else  if (substring(eac:fromDate/@standardDate, 1, 1) = '-') then number(tokenize(eac:fromDate/@standardDate, '-')[3]) else tokenize(eac:fromDate/@standardDate, '-')[2]"/>
						<xsl:sort
							select="if(local-name()='date') then if (substring(@standardDate, 1, 1) = '-') then number(tokenize(@standardDate, '-')[4]) else tokenize(@standardDate, '-')[3] else  if (substring(eac:fromDate/@standardDate, 1, 1) = '-') then number(tokenize(eac:fromDate/@standardDate, '-')[4]) else tokenize(eac:fromDate/@standardDate, '-')[3]"
						/>
					</xsl:apply-templates>
				</ul>
			</div>
		</xsl:if>
		
		<xsl:if test="descendant::eac:function[not(descendant::*/@standardDate)]|descendant::eac:languageUsed[not(descendant::*/@standardDate)]|descendant::eac:legalStatus[not(descendant::*/@standardDate)]|descendant::eac:localDescription[not(descendant::*/@standardDate)]|descendant::eac:mandate[not(descendant::*/@standardDate)]|descendant::eac:occupation[not(descendant::*/@standardDate)]|descendant::eac:place[not(descendant::*/@standardDate)]">
			<div id="terms">
				<h3>Terms</h3>
				<dl class="dl-horizontal">
					<xsl:apply-templates select="descendant::eac:function[not(descendant::*/@standardDate)]|descendant::eac:languageUsed[not(descendant::*/@standardDate)]|descendant::eac:legalStatus[not(descendant::*/@standardDate)]|descendant::eac:localDescription[not(descendant::*/@standardDate)]|descendant::eac:mandate[not(descendant::*/@standardDate)]|descendant::eac:occupation[not(descendant::*/@standardDate)]|descendant::eac:place[not(descendant::*/@standardDate)]">
						<xsl:sort select="local-name()"/>
						<xsl:sort select="eac:term or eac:placeEntry"/>
					</xsl:apply-templates>
				</dl>
			</div>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="eac:function|eac:languageUsed|eac:legalStatus|eac:localDescription|eac:mandate|eac:occupation|eac:place">
		<dt>
			<xsl:value-of select="local-name()"/>
		</dt>
		<dd>
			<xsl:choose>
				<xsl:when test="eac:term">
					<a
						href="{$url}results/?q={if (string(@localType)) then @localType else local-name()}_facet:&#x022;{eac:term}&#x022;">
						<xsl:value-of select="eac:term"/>
					</a>
					<xsl:if test="string(eac:term/@vocabularySource)">
						<a href="{eac:term/@vocabularySource}" style="margin-left:5px;">
							<img src="{$url}ui/images/external.png" alt="External link"/>
						</a>
					</xsl:if>
					<xsl:if test="string(eac:placeEntry)">
						<xsl:text>, </xsl:text>
						<a href="{$url}results/?q=placeEntry_facet:&#x022;{eac:placeEntry}&#x022;">
							<xsl:value-of select="eac:placeEntry"/>
						</a>
						<xsl:if test="string(eac:placeEntry/@vocabularySource)">
							<a href="{eac:placeEntry/@vocabularySource}" style="margin-left:5px;">
								<img src="{$url}ui/images/external.png" alt="External link"/>
							</a>
						</xsl:if>
					</xsl:if>
				</xsl:when>
				<xsl:when test="eac:placeEntry">
					<a href="{$url}results/?q=placeEntry_facet:&#x022;{eac:placeEntry}&#x022;">
						<xsl:value-of select="eac:placeEntry"/>
					</a>
					<xsl:if test="string(eac:placeEntry/@vocabularySource)">
						<a href="{eac:placeEntry/@vocabularySource}" style="margin-left:5px;">
							<img src="{$url}ui/images/external.png" alt="External link"/>
						</a>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
			
		</dd>
	</xsl:template>

	<xsl:template match="eac:existDates">
		<h3>
			<xsl:text>Exist Dates</xsl:text>
			<xsl:if test="contains(@localType, 'xeac:')">
				<xsl:text> </xsl:text>
				<small>
					<xsl:value-of select="@localType"/>
				</small>
			</xsl:if>
		</h3>
		<p>
			<xsl:value-of select="string-join(descendant::*[not(child::*)], ' - ')"/>
		</p>
	</xsl:template>

	<xsl:template match="eac:biogHist">
		<h3>Biographical or Historical Note</h3>

		<xsl:if test="eac:abstract">
			<dl class="dl-horizontal">
				<xsl:apply-templates select="eac:abstract"/>
			</dl>
		</xsl:if>
		<xsl:if test="eac:citation">
			<dl class="dl-horizontal">
				<xsl:apply-templates select="eac:citation"/>
			</dl>
		</xsl:if>
		<xsl:apply-templates select="eac:p"/>
	</xsl:template>

	<xsl:template match="eac:abstract|eac:citation">
		<dt>
			<xsl:value-of select="local-name()"/>
		</dt>
		<dd>
			<xsl:if test="local-name()='abstract'">
				<xsl:attribute name="property">dcterms:abstract</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="."/>
		</dd>
	</xsl:template>

	<xsl:template match="eac:p">
		<p>
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<xsl:template match="eac:date|eac:dateRange" mode="chronList">
		<li>
			<b><xsl:choose>
					<xsl:when test="local-name()='date'">
						<xsl:value-of select="."/>
					</xsl:when>
					<xsl:when test="local-name()='dateRange'">
						<xsl:value-of select="eac:fromDate"/>
						<xsl:text> - </xsl:text>
						<xsl:value-of select="eac:toDate"/>
					</xsl:when>
				</xsl:choose>: </b>
			<xsl:call-template name="chron-description"/>
		</li>
	</xsl:template>

	<xsl:template name="chron-description">
		<xsl:choose>
			<xsl:when test="parent::eac:existDates">Dates of Existence</xsl:when>
			<xsl:when test="ancestor::eac:useDates">
				<xsl:text>Known as </xsl:text>
				<xsl:value-of select="ancestor::eac:nameEntry/eac:part"/>
			</xsl:when>
			<xsl:when test="parent::node()/eac:event">
				<xsl:value-of select="parent::node()/eac:event"/>
			</xsl:when>
			<xsl:when test="parent::node()/parent::node()/eac:event">
				<xsl:value-of select="parent::node()/parent::node()/eac:event"/>
			</xsl:when>
			<xsl:when test="parent::node()/eac:term">
				<a
					href="{$url}results/?q={if (string(parent::node()/@localType)) then parent::node()/@localType else parent::node()/local-name()}_facet:&#x022;{parent::node()/eac:term}&#x022;">
					<xsl:value-of select="parent::node()/eac:term"/>
				</a>
				<xsl:if test="string(parent::node()/eac:term/@vocabularySource)">
					<a href="{parent::node()/eac:term/@vocabularySource}" style="margin-left:5px;">
						<img src="{$url}ui/images/external.png" alt="External link"/>
					</a>
				</xsl:if>
			</xsl:when>
			<xsl:when test="parent::node()/parent::node()/eac:term">
				<a
					href="{$url}results/?q={if (string(parent::node()/parent::node()/@localType)) then parent::node()/parent::node()/@localType else parent::node()/parent::node()/local-name()}_facet:&#x022;{parent::node()/parent::node()/eac:term}&#x022;">
					<xsl:value-of select="parent::node()/parent::node()/eac:term"/>
				</a>
				<xsl:if test="string(parent::node()/parent::node()/eac:term/@vocabularySource)">
					<a href="{parent::node()/parent::node()/eac:term/@vocabularySource}" style="margin-left:5px;">
						<img src="{$url}ui/images/external.png" alt="External link"/>
					</a>
				</xsl:if>
			</xsl:when>
			<xsl:when test="parent::node()/eac:placeRole">
				<xsl:value-of select="parent::node()/eac:placeRole"/>
			</xsl:when>
			<xsl:when test="parent::node()/eac:placeEntry">
				<a href="{$url}results/?q={if (string(parent::node()/@localType)) then parent::node()/@localType else 'placeEntry'}_facet:&#x022;{parent::node()/eac:placeEntry}&#x022;">
					<xsl:value-of select="parent::node()/eac:placeEntry"/>
				</a>
				<xsl:if test="string(parent::node()/eac:placeEntry/@vocabularySource)">
					<a href="{parent::node()/eac:placeEntry/@vocabularySource}" style="margin-left:5px;">
						<img src="{$url}ui/images/external.png" alt="External link"/>
					</a>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
		<xsl:if test="string(parent::node()/eac:placeEntry) and not(parent::eac:place)">
			<xsl:text>, </xsl:text>
			<a href="{$url}results/?q=placeEntry_facet:&#x022;{parent::node()/eac:placeEntry}&#x022;">
				<xsl:value-of select="parent::node()/eac:placeEntry"/>
			</a>
			<xsl:if test="string(parent::node()/eac:placeEntry/@vocabularySource)">
				<a href="{parent::node()/eac:placeEntry/@vocabularySource}" style="margin-left:5px;">
					<img src="{$url}ui/images/external.png" alt="External link"/>
				</a>
			</xsl:if>
			<xsl:text>.</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template name="relations">
		<div id="relations">
			<h2>Relations</h2>
			<xsl:if test="count(eac:relations/eac:cpfRelation) &gt; 0">
				<h3>Related Corporate, Personal, and Family Names</h3>
				<dl class="dl-horizontal">
					<xsl:apply-templates select="eac:relations/eac:cpfRelation">
						<xsl:sort select="@xlink:arcrole"/>
						<xsl:sort select="eac:relationEntry"/>
					</xsl:apply-templates>
				</dl>
			</xsl:if>
			<xsl:choose>
				<!-- get related resources when there is a SPARQL query endpoint -->
				<xsl:when test="string(//config/sparql/query)">
					<xsl:call-template name="xeac:relatedResources">
						<xsl:with-param name="uri">
							<xsl:choose>
								<xsl:when test="string(//config/uri_space)">
									<xsl:value-of select="concat(//config/uri_space, $id)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat($url, 'id/', $id)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
						<xsl:with-param name="endpoint" select="//config/sparql/query"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="count(eac:relations/eac:resourceRelation) &gt; 0">
					<h3>Related Resources</h3>
					<dl class="dl-horizontal">
						<xsl:apply-templates select="eac:relations/eac:resourceRelation[not(@xlink:role='portrait')]"/>
					</dl>
				</xsl:when>
			</xsl:choose>

		</div>
	</xsl:template>

	<xsl:template match="eac:cpfRelation|eac:resourceRelation">
		<dt>
			<xsl:value-of select="@xlink:arcrole"/>
		</dt>
		<dd>
			<xsl:choose>
				<xsl:when test="local-name()='cpfRelation'">
					<xsl:choose>
						<!-- create clickable links to internal documents -->
						<xsl:when test="string(@xlink:href) and not(contains(@xlink:href, 'http://'))">
							<xsl:variable name="recordURI">
								<xsl:choose>
									<xsl:when test="string(/content/config/uri_space)">
										<xsl:value-of select="concat(/content/config/uri_space, @xlink:href)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="@xlink:href"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							
							<a href="{$recordURI}">
								<xsl:if test="@xlink:arcrole">
									<xsl:attribute name="rel" select="@xlink:arcrole"/>
								</xsl:if>
								<xsl:value-of select="eac:relationEntry"/>
							</a>
						</xsl:when>
						<xsl:when test="contains(@xlink:href, 'http://')">
							<xsl:value-of select="eac:relationEntry"/>
							<!-- create external link to resources outside of xEAC -->
							<a href="{@xlink:href}" style="margin-left:5px;">
								<xsl:if test="@xlink:arcrole">
									<xsl:attribute name="rel" select="@xlink:arcrole"/>
								</xsl:if>
								<img src="{$url}ui/images/external.png" alt="External link"/>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<span>
								<xsl:if test="@xlink:arcrole">
									<xsl:attribute name="property" select="@xlink:arcrole"/>
								</xsl:if>
								<xsl:value-of select="eac:relationEntry"/>
							</span>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="local-name()='resourceRelation'">
					<a href="{@xlink:href}">
						<xsl:if test="@xlink:arcrole">
							<xsl:attribute name="rel" select="@xlink:arcrole"/>
						</xsl:if>
						<xsl:value-of select="eac:relationEntry"/>
					</a>
				</xsl:when>
			</xsl:choose>
		</dd>
	</xsl:template>

	<!--<xsl:template name="regularize-name">
		<xsl:param name="name"/>
		<xsl:choose>
			<xsl:when test="$name = 'daogrp'">
				<xsl:text>Image</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'repository'">
				<xsl:text>Repository</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'origination'">
				<xsl:text>Creator</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'extent'">
				<xsl:text>Extent</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'dimensions'">
				<xsl:text>Dimensions</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'genreform'">
				<xsl:text>Genre/Format</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'physfacet'">
				<xsl:text>Physical Facet</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'physloc'">
				<xsl:text>Location</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'unitid'">
				<xsl:text>Identification</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'langmaterial'">
				<xsl:text>Language</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'abstract'">
				<xsl:text>Abstract</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'materialspec'">
				<xsl:text>Technical</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'container'">
				<xsl:text>Container</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'bioghist'">
				<xsl:text>Biographical/Historical Commentary</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'scopecontent'">
				<xsl:text>Scope and Content</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'controlaccess'">
				<xsl:text>Controlled Access Headings</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'arrangement'">
				<xsl:text>Arrangement</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'accessrestrict'">
				<xsl:text>Access Restriction</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'userestrict'">
				<xsl:text>Use Restriction</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'prefercite'">
				<xsl:text>Preferred Citation</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'acqinfo'">
				<xsl:text>Acquisition Information</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'altformavail'">
				<xsl:text>Alternate Form Available</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'accruals'">
				<xsl:text>Accruals</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'appraisal'">
				<xsl:text>Appraisal</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'custodhist'">
				<xsl:text>Custodial History</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'processinfo'">
				<xsl:text>Processing Information</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'originalsloc'">
				<xsl:text>Location of Originals</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'phystech'">
				<xsl:text>Physical Characteristics</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'odd'">
				<xsl:text>Other Descriptive Data</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'note'">
				<xsl:text>Note</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'descgrp'">
				<xsl:text>Descriptive Group</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'bibliography'">
				<xsl:text>Bibliography</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'relatedmaterial'">
				<xsl:text>Related Material</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'separatedmaterial'">
				<xsl:text>Separated Material</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'otherfindaid'">
				<xsl:text>Other Finding Aid</xsl:text>
			</xsl:when>
			<xsl:when test="$name = 'fileplan'">
				<xsl:text>Fileplan</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Other Name</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>-->
</xsl:stylesheet>

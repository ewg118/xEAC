<?xml version="1.0" encoding="UTF-8"?>

<!-- Author: Ethan Gruber
	Date: January 2016
	Function: This includes templates for constructing the EAC-CPF to HTML5 document structure. 
	It includes xsl stylesheets for SPARQL or other linked data lookup widgets (html-widges.xsl) and EAC-CPF element templates (html-templates.xsl)
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:eac="urn:isbn:1-931666-33-4"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xeac="https://github.com/ewg118/xEAC"
	xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<!-- include the html-widgets templates for transformation SPARQL results and other linked data lookup mechanisms into HTML. If querying to an internal SPARQL endpoint, then the view XPL should be modified to include the SPARQL response in the model for the XSLT tranformation -->
	<xsl:include href="html-widgets.xsl"/>

	<!-- EAC-CPF templates contained here: -->
	<xsl:include href="html-templates.xsl"/>

	<!-- parameters and variables -->
	<xsl:param name="mode"
		select="if (contains(doc('input:request')/request/request-url, 'admin/')) then 'private' else 'public'"/>
	<xsl:variable name="display_path" select="if ($mode='private') then '../../' else '../'"/>
	<xsl:variable name="sparql" select="/content/sparql" as="xs:boolean"/>
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="id" select="/content/eac:eac-cpf/eac:control/eac:recordId"/>

	<xsl:variable name="namespaces" as="item()*">
		<namespaces>
			<namespace prefix="bio">http://purl.org/vocab/bio/0.1/</namespace>
			<namespace prefix="dcterms">http://purl.org/dc/terms/</namespace>
			<namespace prefix="foaf">http://xmlns.com/foaf/0.1/</namespace>
			<namespace prefix="geo">http://www.w3.org/2003/01/geo/wgs84_pos#</namespace>
			<namespace prefix="org">http://www.w3.org/ns/org#</namespace>
			<namespace prefix="owl">http://www.w3.org/2002/07/owl#</namespace>
			<namespace prefix="rdf">http://www.w3.org/1999/02/22-rdf-syntax-ns#</namespace>
			<namespace prefix="skos">http://www.w3.org/2004/02/skos/core#</namespace>
		</namespaces>
	</xsl:variable>

	<xsl:variable name="class">
		<xsl:choose>
			<xsl:when test="descendant::eac:entityType='person'">foaf:Person</xsl:when>
			<xsl:when test="descendant::eac:entityType='corporateBody'">org:Organization</xsl:when>
			<xsl:when test="descendant::eac:entityType='family'">arch:Family</xsl:when>
		</xsl:choose>
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
				<xsl:for-each
					select="descendant::eac:localTypeDeclaration[eac:citation[@xlink:role='semantic']]">
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
						<xsl:when
							test="eac:cpfDescription/eac:identity/eac:nameEntry[eac:preferredForm='WIKIPEDIA']">
							<xsl:value-of
								select="eac:cpfDescription/eac:identity/eac:nameEntry[eac:preferredForm='WIKIPEDIA']/eac:part"
							/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of
								select="eac:cpfDescription/eac:identity/eac:nameEntry[1]/eac:part"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text> (</xsl:text>
					<xsl:value-of select="$id"/>
					<xsl:text>)</xsl:text>
				</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet"
					href="http://netdna.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"/>
				<link rel="stylesheet" href="{$url}ui/css/style.css"/>
				<script type="text/javascript" src="{$url}ui/javascript/display_functions.js"/>
				<!-- other content types -->
				<link rel="alternate" type="application/xml" href="{$url}id/{$id}.xml"/>
				<link rel="alternate" type="application/rdf+xml" href="{$url}id/{$id}.rdf"/>
				<link rel="alternate" type="text/turtle" href="{$url}id/{$id}.ttl"/>
				<link rel="alternate" type="application/json" href="{$url}id/{$id}.jsonld"/>
				<link rel="alternate" type="application/tei+xml" href="{$url}id/{$id}.tei"/>
				<link rel="alternate" type="application/vnd.google-earth.kml+xml"
					href="{$url}id/{$id}.kml"/>

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

				<!-- semantic relations -->
				<xsl:if
					test="$sparql = true() and descendant::eac:cpfRelation[@xlink:arcrole and @xlink:role]">
					<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/vis/4.12.0/vis.min.js"/>
					<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/vis/4.12.0/vis.min.css"/>
					<script type="text/javascript" src="{$url}ui/javascript/vis_functions.js"/>
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

				<!-- hidden variables used within Javascript -->
				<div style="display:none">
					<span id="id">
						<xsl:value-of select="$id"/>
					</span>
					<span id="mappable">
						<xsl:choose>
							<xsl:when test="descendant::eac:placeEntry[string(@vocabularySource)]"
								>true</xsl:when>
							<xsl:otherwise>false</xsl:otherwise>
						</xsl:choose>
					</span>
					<span id="url">
						<xsl:value-of select="$url"/>
					</span>
					<span id="class">
						<xsl:value-of select="$class"/>
					</span>
					<xsl:call-template name="control-fields"/>
				</div>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="display">
		<div class="container-fluid" id="top">
			<xsl:call-template name="doc-header"/>
			<xsl:call-template name="cpfDescription-vis-structure"/>
			<xsl:if test="$sparql = true()">
				<xsl:call-template name="resources"/>
			</xsl:if>
			<xsl:if test="eac:cpfDescription/eac:identity/eac:entityId[matches(., 'https?://')]">
				<xsl:call-template name="matches"/>
			</xsl:if>
			<xsl:call-template name="export"/>
		</div>
	</xsl:template>

	<xsl:template name="doc-header">
		<!-- create a boolean variable to determine whether there is a resourceRelation with a foaf:depiction or foaf:thumbnail -->
		<xsl:variable name="portrait" select="boolean(descendant::eac:resourceRelation[starts-with(@xlink:arcrole, 'foaf:')])"/>
		
		<div class="row" typeof="skos:Concept" about="{$id}#concept">
			<a href="{$id}" rel="foaf:focus" style="display:none"/>
			
			<!-- {if ($portrait = true()) then '8' else '12'} col-lg-{if ($portrait = true()) then '10' else '12'} -->
			<div class="col-md-12">
				
				<h1>
					<xsl:choose>
						<xsl:when
							test="eac:cpfDescription/eac:identity/eac:nameEntry[eac:preferredForm='WIKIPEDIA']">
							<xsl:value-of
								select="eac:cpfDescription/eac:identity/eac:nameEntry[eac:preferredForm='WIKIPEDIA']/eac:part"
							/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of
								select="eac:cpfDescription/eac:identity/eac:nameEntry[1]/eac:part"/>
						</xsl:otherwise>
					</xsl:choose>
				</h1>

				<!-- toggle name entries on and off -->
				<div>
					<h4>
						<a href="#" id="toggle-names" class="toggle-button">Toggle Names <span
								class="glyphicon glyphicon-triangle-right"/></a>
					</h4>
					<div id="names-div" style="display:none">
						<xsl:if
							test="eac:cpfDescription/eac:identity/eac:nameEntry[child::node()='WIKIPEDIA']">
							<h4> Wiki<xsl:if
									test="eac:cpfDescription/eac:identity/eac:nameEntry[child::node()='WIKIPEDIA']">
									<h4> Wikipedia </h4>
									<div id="wiki-names">
										<xsl:for-each
											select="eac:cpfDescription/eac:identity/eac:nameEntry[*[local-name() != 'preferredForm']='WIKIPEDIA']">
											<xsl:value-of select="eac:part"/>
											<xsl:if test="not(position()=last())">
												<xsl:text> / </xsl:text>
											</xsl:if>
										</xsl:for-each>
									</div>
								</xsl:if>pedia </h4>
							<div id="wiki-names">
								<xsl:for-each
									select="eac:cpfDescription/eac:identity/eac:nameEntry[*[local-name() != 'preferredForm']='WIKIPEDIA']">
									<xsl:value-of select="eac:part"/>
									<xsl:if test="not(position()=last())">
										<xsl:text> / </xsl:text>
									</xsl:if>
								</xsl:for-each>
							</div>
						</xsl:if>

						<xsl:for-each select="//eac:conventionDeclaration">
							<xsl:variable name="abbreviation" select="eac:abbreviation"/>
							<h4>
								<xsl:value-of select="eac:citation"/>
							</h4>
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
												<xsl:attribute name="property"
												>skos:prefLabel</xsl:attribute>
												</xsl:when>
												<xsl:when test="eac:alternativeForm">
												<xsl:attribute name="property"
												>skos:altLabel</xsl:attribute>
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
												<xsl:value-of
												select="eac:useDates/eac:dateRange/eac:fromDate"/>
												<xsl:text>-</xsl:text>
												<xsl:value-of
												select="eac:useDates/eac:dateRange/eac:toDate"/>
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
			<!--<xsl:if test="$portrait = true()">
				<xsl:call-template name="portrait"/>
			</xsl:if>-->
		</div>
		<hr/>
	</xsl:template>

	<xsl:template name="cpfDescription-vis-structure">
		<div class="row" typeof="{$class}" about="{$id}">
			<div
				class="col-md-{if (descendant::eac:placeEntry[string(@vocabularySource)] or (string(//config/sparql/query) and descendant::eac:cpfRelation[@xlink:arcrole and @xlink:role])) then
				'6' else '12'}">

				<!-- Navigation -->
				<div>
					<ul class="list-inline">
						<li>
							<strong>Jump to section: </strong>
						</li>
						<xsl:if test="descendant::eac:relations">
							<li>
								<a href="#relations">Relations</a>
							</li>
						</xsl:if>
						<xsl:if test="/content/res:sparql[1][descendant::res:result]">
							<li>
								<a href="#associated-content">Related Resources</a>
							</li>
						</xsl:if>
						<xsl:if test="/content/res:sparql[2][descendant::res:result]">
							<li>
								<a href="#associated-content">Annotations</a>
							</li>
						</xsl:if>
						<xsl:if
							test="eac:cpfDescription/eac:identity/eac:entityId[matches(., 'https?://')]">
							<li>
								<a href="#matches">Associated Identifiers</a>
							</li>
						</xsl:if>

						<li>
							<a href="#export">Export</a>
						</li>
					</ul>
				</div>

				<!-- Description -->
				<xsl:apply-templates select="eac:cpfDescription"/>
			</div>

			<!-- optional visualization div -->
			<xsl:if
				test="descendant::eac:placeEntry[string(@vocabularySource)] or ($sparql = true() and descendant::eac:cpfRelation[@xlink:arcrole and @xlink:role])">
				<div class="col-md-6">
					<div id="visualizations">
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
						<xsl:if
							test="descendant::eac:placeEntry[string(@vocabularySource)] or ($sparql = true() and descendant::eac:cpfRelation[@xlink:arcrole and @xlink:role])">
							<br/>
						</xsl:if>
						<xsl:if
							test="$sparql = true() and descendant::eac:cpfRelation[@xlink:arcrole and @xlink:role]">
							<div id="network"/>
							<br/>
						</xsl:if>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<xsl:template name="matches">
		<div id="matches" class="row" typeof="skos:Concept" about="{$id}#concept">
			<div class="col-md-12">
				<h2>Associated Identifiers <small><a href="#top" title="Return to top"><span
					class="glyphicon glyphicon-arrow-up"/></a></small></h2>
				<ul class="list-unstyled">
					<xsl:apply-templates
						select="eac:cpfDescription/eac:identity/eac:entityId[matches(., 'https?://')]"
					/>
				</ul>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="export">
		<div id="export" class="row">
			<div class="col-md-12">
				<h2>Export <small><a href="#top" title="Return to top"><span
								class="glyphicon glyphicon-arrow-up"/></a></small></h2>
			</div>
			<div class="col-md-4">
				<ul class="list-inline">
					<li>
						<a href="{$id}.xml">EAC-CPF</a>
					</li>
					<li>
						<a href="{$id}.tei">TEI</a>
					</li>
					<li>
						<a href="{$id}.rdf">RDF/XML</a>
					</li>
					<li>
						<a href="{$id}.ttl">Turtle</a>
					</li>
					<li>
						<a href="{$id}.jsonld">JSON-LD</a>
					</li>
					<li>
						<a href="{$id}.kml">KML</a>
					</li>
				</ul>
				<h4>Alternative RDF</h4>
				<ul class="list-inline">
					<li>
						<a href="{$url}api/get?id={$id}&amp;model=cidoc-crm">CIDOC CRM</a>
					</li>
					<li>
						<a href="{$url}api/get?id={$id}&amp;model=snap">SNAP</a>
					</li>
				</ul>
			</div>
			<div class="col-md-8">
				<p>Content negotiation supports the following types: <code>text/html</code>,
						<code>application/xml</code>, <code>application/tei+xml</code>,
						<code>application/vnd.google-earth.kml+xml</code>,
						<code>application/rdf+xml</code>, <code>application/json</code>,
						<code>text/turtle</code></p>
			</div>
		</div>
	</xsl:template>

	<!-- template for displaying portrait image -->
	<xsl:template name="portrait">
		<div class="col-md-4 col-lg-2">
			<xsl:choose>
				<xsl:when test="descendant::eac:resourceRelation[@xlink:arcrole='foaf:thumbnail']">
					<div class="text-center">
						<img
							src="{descendant::eac:resourceRelation[@xlink:arcrole='foaf:thumbnail']/@xlink:href}"
							alt="Portrait" style="max-width:100%;" property="foaf:thumbnail"/>
					</div>
				</xsl:when>
				<xsl:when test="descendant::eac:resourceRelation[@xlink:arcrole='foaf:depiction']">
					<div class="text-center">
						<img
							src="{descendant::eac:resourceRelation[@xlink:arcrole='foaf:depiction']/@xlink:href}"
							alt="Portrait" style="max-width:100%;" property="foaf:depiction"/>
					</div>
				</xsl:when>
			</xsl:choose>
		</div>
	</xsl:template>

	<xsl:template match="eac:description">
		<div id="description" class="eac-section">
			<h2>Description</h2>
			<xsl:apply-templates select="eac:existDates"/>
			<xsl:apply-templates select="eac:biogHist"/>
			<xsl:if
				test="descendant::eac:date[not(parent::eac:existDates)] or descendant::eac:dateRange[not(parent::eac:existDates)]">
				<div id="chron">
					<h3>Chronology</h3>
					<ul>
						<xsl:apply-templates
							select="descendant::eac:date[@standardDate][not(parent::eac:existDates)]|descendant::eac:dateRange[eac:fromDate[@standardDate]][not(parent::eac:existDates)]"
							mode="chronList">
							<xsl:sort
								select="if(local-name()='date') then if (substring(@standardDate, 1, 1) = '-') then (number(tokenize(@standardDate, '-')[2]) * -1) else tokenize(@standardDate,
								'-')[1] else  if (substring(eac:fromDate/@standardDate, 1, 1) = '-') then (number(tokenize(eac:fromDate/@standardDate, '-')[2]) * -1) else
								tokenize(eac:fromDate/@standardDate, '-')[1]"/>
							<xsl:sort
								select="if(local-name()='date') then if (substring(@standardDate, 1, 1) = '-') then number(tokenize(@standardDate, '-')[3]) else tokenize(@standardDate, '-')[2] else
								if (substring(eac:fromDate/@standardDate, 1, 1) = '-') then number(tokenize(eac:fromDate/@standardDate, '-')[3]) else tokenize(eac:fromDate/@standardDate, '-')[2]"/>
							<xsl:sort
								select="if(local-name()='date') then if (substring(@standardDate, 1, 1) = '-') then number(tokenize(@standardDate, '-')[4]) else tokenize(@standardDate, '-')[3] else
								if (substring(eac:fromDate/@standardDate, 1, 1) = '-') then number(tokenize(eac:fromDate/@standardDate, '-')[4]) else tokenize(eac:fromDate/@standardDate, '-')[3]"
							/>
						</xsl:apply-templates>
					</ul>
				</div>
			</xsl:if>
			<xsl:if
				test="descendant::eac:function[not(descendant::*/@standardDate)]|descendant::eac:languageUsed[not(descendant::*/@standardDate)]|descendant::eac:legalStatus[not(descendant::*/@standardDate)]|descendant::eac:localDescription[not(descendant::*/@standardDate)]|descendant::eac:mandate[not(descendant::*/@standardDate)]|descendant::eac:occupation[not(descendant::*/@standardDate)]|descendant::eac:place[not(descendant::*/@standardDate)]">
				<div id="terms">
					<h3>Terms</h3>
					<dl class="dl-horizontal">
						<xsl:apply-templates
							select="descendant::eac:function[not(descendant::*/@standardDate)]|descendant::eac:languageUsed[not(descendant::*/@standardDate)]|descendant::eac:legalStatus[not(descendant::*/@standardDate)]|descendant::eac:localDescription[not(descendant::*/@standardDate)]|descendant::eac:mandate[not(descendant::*/@standardDate)]|descendant::eac:occupation[not(descendant::*/@standardDate)]|descendant::eac:place[not(descendant::*/@standardDate)]">
							<xsl:sort select="local-name()"/>
							<xsl:sort select="eac:term or eac:placeEntry"/>
						</xsl:apply-templates>
					</dl>
				</div>
			</xsl:if>
			<hr/>
		</div>
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
					href="{$url}results/?q={if (string(parent::node()/parent::node()/@localType)) then parent::node()/parent::node()/@localType else
					parent::node()/parent::node()/local-name()}_facet:&#x022;{parent::node()/parent::node()/eac:term}&#x022;">
					<xsl:value-of select="parent::node()/parent::node()/eac:term"/>
				</a>
				<xsl:if test="string(parent::node()/parent::node()/eac:term/@vocabularySource)">
					<a href="{parent::node()/parent::node()/eac:term/@vocabularySource}"
						style="margin-left:5px;">
						<img src="{$url}ui/images/external.png" alt="External link"/>
					</a>
				</xsl:if>
			</xsl:when>
			<xsl:when test="parent::node()/eac:placeRole">
				<xsl:value-of select="parent::node()/eac:placeRole"/>
			</xsl:when>
			<xsl:when test="parent::node()/eac:placeEntry">
				<a
					href="{$url}results/?q={if (string(parent::node()/@localType)) then parent::node()/@localType else 'placeEntry'}_facet:&#x022;{parent::node()/eac:placeEntry}&#x022;">
					<xsl:value-of select="parent::node()/eac:placeEntry"/>
				</a>
				<xsl:if test="string(parent::node()/eac:placeEntry/@vocabularySource)">
					<a href="{parent::node()/eac:placeEntry/@vocabularySource}"
						style="margin-left:5px;">
						<img src="{$url}ui/images/external.png" alt="External link"/>
					</a>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
		<xsl:if test="string(parent::node()/eac:placeEntry) and not(parent::eac:place)">
			<xsl:text>, </xsl:text>
			<a
				href="{$url}results/?q=placeEntry_facet:&#x022;{parent::node()/eac:placeEntry}&#x022;">
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
		<div id="relations" class="eac-section">
			<h2>Relations <small><a href="#top" title="Return to top"><span
							class="glyphicon glyphicon-arrow-up"/></a></small></h2>
			<xsl:if test="count(eac:relations/eac:cpfRelation) &gt; 0">
				<h3>Related Corporate, Personal, and Family Names</h3>
				<dl class="dl-horizontal">
					<xsl:apply-templates select="eac:relations/eac:cpfRelation">
						<xsl:sort select="@xlink:arcrole"/>
						<xsl:sort select="eac:relationEntry"/>
					</xsl:apply-templates>
				</dl>
			</xsl:if>
			<xsl:if test="count(eac:relations/eac:resourceRelation) &gt; 0">
				<h3>Related Resources</h3>
				<dl class="dl-horizontal">
					<xsl:apply-templates
						select="eac:relations/eac:resourceRelation[not(@xlink:role='portrait')]"/>
				</dl>
			</xsl:if>
			<hr/>
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
						<xsl:when
							test="string(@xlink:href) and not(contains(@xlink:href, 'http://'))">
							<xsl:variable name="recordURI">
								<xsl:choose>
									<xsl:when test="string(/content/config/uri_space)">
										<xsl:value-of
											select="concat(/content/config/uri_space, @xlink:href)"
										/>
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
</xsl:stylesheet>

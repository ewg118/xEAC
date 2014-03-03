<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:eac="urn:isbn:1-931666-33-4" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xeac="https://github.com/ewg118/xEAC"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="templates.xsl"/>
	<xsl:include href="widgets.xsl"/>

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

	<xsl:template match="/">
		<xsl:apply-templates select="/content/eac:eac-cpf"/>
	</xsl:template>

	<xsl:template match="eac:eac-cpf">
		<html xml:lang="en">
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
				</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
				<link rel="stylesheet" href="{$display_path}ui/css/style.css"/>

				<!-- mapping -->				
				<script src="http://www.openlayers.org/api/OpenLayers.js" type="text/javascript"/>
				<script type="text/javascript" src="http://maps.google.com/maps/api/js?v=3.2&amp;sensor=false"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/mxn.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/timeline-2.3.0.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/timemap_full.pack.js"/>				
				<script type="text/javascript" src="{$display_path}ui/javascript/param.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/loaders/kml.js"/>		
				<script type="text/javascript" src="{$display_path}ui/javascript/display_functions.js"/>				
				<xsl:copy-of select="/content/config/google_analytics/*"/>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="display"/>
				<xsl:call-template name="footer"/>
				<div style="display:none">
					<span id="id">
						<xsl:value-of select="//eac:recordId"/>
					</span>
					<xsl:call-template name="control-fields"/>
				</div>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="display">
		<div class="container-fluid">
			<div class="row">
				<div class="col-md-12">
					<xsl:call-template name="icons"/>
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
							<ul>
								<xsl:for-each select="//eac:nameEntry[child::node()=$abbreviation]">
									<li>
										<xsl:value-of select="eac:part"/>
										<xsl:if test="@xml:lang">
											<xsl:text> (</xsl:text>
											<xsl:value-of select="@xml:lang"/>
											<xsl:text>)</xsl:text>
										</xsl:if>
										<xsl:choose>
											<xsl:when test="eac:authorizedForm">
												<xsl:text> (authorized form)</xsl:text>
											</xsl:when>
											<xsl:when test="eac:preferredForm">
												<xsl:text> (preferred form)</xsl:text>
											</xsl:when>
											<xsl:when test="eac:alternativeForm">
												<xsl:text> (alternative form)</xsl:text>
											</xsl:when>
										</xsl:choose>
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
									</li>
								</xsl:for-each>
							</ul>
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
			<!--<div id="mapcontainer"/>-->
			
		</xsl:if>


		<xsl:apply-templates select="eac:cpfDescription"/>
	</xsl:template>

	<xsl:template name="side-bar">
		<xsl:if test="descendant::eac:resourceRelation[@xlink:role='portrait']">
			<img src="{descendant::eac:resourceRelation[@xlink:role='portrait']/@xlink:href}" alt="Portrait" style="max-width:240px;"/>
		</xsl:if>

		<!-- display otherRecordIds, create links when applicable -->
		<xsl:if test="count(eac:control/eac:otherRecordId) &gt; 0">
			<h3>Associated Identifiers</h3>
			<ul>
				<xsl:for-each select="eac:control/eac:otherRecordId">
					<li>
						<xsl:choose>
							<xsl:when test="contains(., 'http://')">
								<a href="{.}">
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
		<xsl:apply-templates select="eac:relations"/>
	</xsl:template>

	<xsl:template match="eac:description">
		<div id="description">
			<h2>Description</h2>
			<xsl:apply-templates select="eac:biogHist"/>
		</div>
		<xsl:if test="descendant::eac:date or descendant::eac:dateRange">
			<div id="chron">
				<h2>Chronology</h2>
				<ul>
					<xsl:apply-templates select="descendant::eac:date[@standardDate]|eac:description/descendant::eac:dateRange[eac:fromDate[@standardDate]]">
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
	</xsl:template>

	<xsl:template match="eac:biogHist">
		<h3>Biographical or Historical Note</h3>
		<xsl:apply-templates select="eac:abstract|eac:citation|eac:outline|eac:list"/>
		<xsl:apply-templates select="eac:p"/>
	</xsl:template>

	<xsl:template match="eac:abstract|eac:citation|eac:outline|eac:list">
		<dt>
			<xsl:value-of select="local-name()"/>
		</dt>
		<dd>
			<xsl:value-of select="."/>
		</dd>
	</xsl:template>

	<xsl:template match="eac:p">
		<p>
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<xsl:template match="eac:date|eac:dateRange">
		<xsl:if test="not(parent::eac:existDates)">
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
		</xsl:if>

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
			<xsl:when test="parent::node()/eac:term">
				<a
					href="{$display_path}results/?q={if (string(parent::node()/@localType)) then parent::node()/@localType else parent::node()/local-name()}_facet:&#x022;{parent::node()/eac:term}&#x022;">
					<xsl:value-of select="parent::node()/eac:term"/>
				</a>
			</xsl:when>
			<xsl:when test="parent::node()/eac:placeRole">
				<xsl:value-of select="parent::node()/eac:placeRole"/>
			</xsl:when>
			<xsl:when test="parent::node()/eac:placeEntry">
				<a href="{$display_path}results/?q={if (string(parent::node()/@localType)) then parent::node()/@localType else 'placeEntry'}_facet:&#x022;{parent::node()/eac:placeEntry}&#x022;">
					<xsl:value-of select="parent::node()/eac:placeEntry"/>
				</a>
				<xsl:if test="string(parent::node()/eac:placeEntry/@vocabularySource)">
					<a href="{parent::node()/eac:placeEntry/@vocabularySource}" style="margin-left:5px;">
						<img src="{$display_path}ui/images/external.png" alt="External link"/>
					</a>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
		<xsl:if test="string(parent::node()/eac:placeEntry) and not(parent::eac:place)">
			<xsl:text>, </xsl:text>
			<a href="{$display_path}results/?q=placeEntry_facet:&#x022;{parent::node()/eac:placeEntry}&#x022;">
				<xsl:value-of select="parent::node()/eac:placeEntry"/>
			</a>
			<xsl:if test="string(parent::node()/eac:placeEntry/@vocabularySource)">
				<a href="{parent::node()/eac:placeEntry/@vocabularySource}" style="margin-left:5px;">
					<img src="{$display_path}ui/images/external.png" alt="External link"/>
				</a>
			</xsl:if>
			<xsl:text>.</xsl:text>
		</xsl:if>
	</xsl:template>


	<xsl:template match="eac:relations">
		<div id="relations">
			<h2>Relations</h2>
			<xsl:if test="count(eac:cpfRelation) &gt; 0">
				<h3>Related Corporate, Personal, and Family Names</h3>
				<ul>
					<xsl:apply-templates select="eac:cpfRelation">
						<xsl:sort select="@xlink:arcrole"/>
					</xsl:apply-templates>
				</ul>
			</xsl:if>
			<xsl:if test="count(eac:resourceRelation) &gt; 0">
				<h3>Related Resources</h3>
				<ul>
					<xsl:apply-templates select="eac:resourceRelation[not(@xlink:role='portrait')]"/>
				</ul>
			</xsl:if>
		</div>
	</xsl:template>

	<xsl:template match="eac:cpfRelation|eac:resourceRelation">
		<li>
			<xsl:if test="@xlink:arcrole">
				<i>
					<xsl:value-of select="@xlink:arcrole"/>
					<xsl:text> </xsl:text>
				</i>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="local-name()='cpfRelation'">
					<xsl:choose>
						<!-- create clickable links to internal documents -->
						<xsl:when test="string(@xlink:href) and not(contains(@xlink:href, 'http://'))">
							<a href="{@xlink:href}">
								<xsl:if test="local-name()='resourceRelation'">
									<xsl:attribute name="target">_blank</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="eac:relationEntry"/>
							</a>
						</xsl:when>
						<xsl:when test="contains(@xlink:href, 'http://')">
							<xsl:value-of select="eac:relationEntry"/>
							<!-- create external link to resources outside of xEAC -->
							<a href="{@xlink:href}" style="margin-left:5px;">
								<img src="{$display_path}ui/images/external.png" alt="External link"/>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="eac:relationEntry"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="local-name()='resourceRelation'">
					<a href="{@xlink:href}" target="_blank">
						<xsl:value-of select="eac:relationEntry"/>
					</a>
				</xsl:when>
			</xsl:choose>
		</li>
	</xsl:template>

	<xsl:template name="icons">
		<div class="submenu">
			<span class="icon">
				<a href="id/{//eac:eac-cpf/eac:control/eac:recordId}.kml">KML</a>
			</span>
			<span class="icon">
				<a href="id/{//eac:eac-cpf/eac:control/eac:recordId}.rdf">RDF/XML</a>
			</span>
			<span class="icon">
				<a href="id/{//eac:eac-cpf/eac:control/eac:recordId}.xml">EAC-CPF/XML</a>
			</span>
			<span class="icon">
				<!-- AddThis Button BEGIN -->
				<div class="addthis_toolbox addthis_default_style ">
					<a class="addthis_button_preferred_1"/>
					<a class="addthis_button_preferred_2"/>
					<a class="addthis_button_preferred_3"/>
					<a class="addthis_button_preferred_4"/>
					<a class="addthis_button_compact"/>
					<a class="addthis_counter addthis_bubble_style"/>
				</div>
				<script type="text/javascript" src="http://s7.addthis.com/js/250/addthis_widget.js#pubid=xa-4dd29d0e2f66557f"/>
				<!-- AddThis Button END -->
			</span>
		</div>
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

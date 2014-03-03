<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:eac="urn:isbn:1-931666-33-4" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xeac="https://github.com/ewg118/xEAC"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">

	<xsl:template name="header">
		<div class="navbar navbar-default navbar-static-top" role="navigation">
			<div class="container-fluid">
				<div class="navbar-header">
					<button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
						<span class="sr-only">Toggle navigation</span>
						<span class="icon-bar"/>
						<span class="icon-bar"/>
						<span class="icon-bar"/>
					</button>
					<a class="navbar-brand" href="{$display_path}./">
						<xsl:value-of select="//config/title"/>
					</a>
				</div>
				<div class="navbar-collapse collapse">
					<ul class="nav navbar-nav">
						<li>
							<a href="{$display_path}results/">Browse</a>
						</li>
					</ul>
					<div class="col-sm-3 col-md-3 pull-right">
						<form class="navbar-form" role="search" action="{$display_path}results/" method="GET">
							<div class="input-group">
								<input type="text" class="form-control" placeholder="Search" name="q" id="srch-term"/>
								<div class="input-group-btn">
									<button class="btn btn-default" type="submit">
										<i class="glyphicon glyphicon-search"/>
									</button>
								</div>
							</div>
						</form>
					</div>
				</div>
			</div>
		</div>

	</xsl:template>

	<xsl:template name="footer">
		<xsl:copy-of select="//config/footer/*"/>
	</xsl:template>

	<xsl:template name="control-fields">
		<!-- ************* CONTROL FIELDS *************** -->
		<!-- hidden values within the document, requiring EAC-CPF processing, which affect Javascript functionality -->
		<!-- algorithm for determining whether default baselayer for this entity should be imperium or OSM (imperial for a @standardDate less than A.D. 500)
		the assumption is that that pre A.D. 500 people are from Greco-Roman Europe and the Near East.  You may wish to enhance these conditionals. 
		javascript/mxn.openlayers.core.js should be modified to accommodate changes to #baseLayer.-->
		<span id="baselayer">
			<xsl:choose>
				<xsl:when test="descendant::eac:existDates">
					<xsl:variable name="date" select="descendant::eac:existDates/descendant::*[@standardDate][last()]/@standardDate"/>
					<xsl:choose>
						<xsl:when test="$date castable as xs:gYear">
							<xsl:choose>
								<xsl:when test="number($date) &lt; 500">imperium</xsl:when>
								<xsl:otherwise>osm</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="$date castable as xs:gYearMonth or $date castable as xs:date">
							<xsl:variable name="year" select="if(substring($date, 1, 1)='-') then substring($date, 1, 5) else substring($date, 1, 4)"/>
							<xsl:choose>
								<xsl:when test="number($year) &lt; 500">imperium</xsl:when>
								<xsl:otherwise>osm</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>osm</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>osm</xsl:otherwise>
			</xsl:choose>
		</span>
	</xsl:template>

</xsl:stylesheet>

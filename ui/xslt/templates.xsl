<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:eac="urn:isbn:1-931666-33-4" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xeac="https://github.com/ewg118/xEAC"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">

	<xsl:template name="header">
		<div id="hd">
			<div id="banner">
				<xsl:if test="string(//config/banner_text)">
					<div class="banner_text">
						<xsl:value-of select="//config/banner_text"/>
					</div>
				</xsl:if>
				<!--<xsl:if test="string(/content/config/banner_image/@xlink:href)">
					<img src="{$display_path}images/{/content/config/banner_image/@xlink:href}" alt="banner image"/>
				</xsl:if>-->
			</div>
			<ul role="menubar" id="menu">
				<li role="presentation">
					<a href="{$display_path}.">Home</a>
				</li>

				<li role="presentation">
					<a href="{$display_path}results/?q=*:*">Browse</a>
				</li>
			</ul>
		</div>

	</xsl:template>

	<xsl:template name="footer">
		<div id="ft">
			<a href="https://github.com/ewg118/xEAC">xEAC</a> ©2013 Ethan Gruber. <a href="http://www.apache.org/licenses/LICENSE-2.0.html">License.</a>
		</div>
	</xsl:template>

	<xsl:template name="control-fields">
		<!-- ************* CONTROL FIELDS *************** -->
		<!-- hidden values within the document, requiring EAC-CPF processing, which affect Javascript functionality -->
		<!-- algorithm for determining whether default baselayer for this entity should be imperium or OSM (imperial for a @standardDate less than A.D. 500)
		the assumption is that that pre A.D. 500 people are from Greco-Roman Europe and the Near East.  You may wish to enhance these conditionals. 
		javascript/mxn.openlayers.core.js should be modified to accommodate changes to #baseLayer.-->
		<span id="baseLayer" style="display:none">
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

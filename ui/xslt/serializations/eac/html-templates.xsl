<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Date: January 2016
	Function: This XSLT stylesheet contains templates for EAC-CPF elements -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:eac="urn:isbn:1-931666-33-4"
	xmlns:xeac="https://github.com/ewg118/xEAC" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="#all" version="2.0">

	<xsl:template match="eac:cpfDescription">
		<xsl:apply-templates select="eac:description"/>
		<xsl:if test="eac:relations">
			<xsl:call-template name="relations"/>
		</xsl:if>
	</xsl:template>

	<xsl:template
		match="eac:function|eac:languageUsed|eac:legalStatus|eac:localDescription|eac:mandate|eac:occupation|eac:place">
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

	<xsl:template match="eac:entityId">
		<li>
			<code>
				<a href="{.}" title="{.}">
					<xsl:if test="@localType">
						<xsl:attribute name="rel" select="@localType"/>
					</xsl:if>
					<xsl:value-of select="."/>
				</a>
			</code>
		</li>
	</xsl:template>
</xsl:stylesheet>

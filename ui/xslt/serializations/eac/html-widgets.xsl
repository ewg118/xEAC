<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:eac="urn:isbn:1-931666-33-4"
	xmlns:xeac="https://github.com/ewg118/xEAC" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="#all" version="2.0">

	<xsl:template name="resources">
		<xsl:if test="/content/res:sparql[descendant::res:result]">
			<div class="row" id="associated-content">
				<div class="col-md-12">
					<div class="eac-section">
						<h2>Associated Content</h2>
						<xsl:apply-templates select="/content/res:sparql[1][descendant::res:result]"
							mode="relatedResources"/>
						<xsl:apply-templates select="/content/res:sparql[2][descendant::res:result]"
							mode="annotations"/>
						<hr/>
					</div>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- **************** RELATED RESOURCES **************** -->
	<xsl:template match="res:sparql" mode="relatedResources">
		<xsl:variable name="objects"
			select="distinct-values(descendant::res:result/res:binding[@name='uri']/res:uri)"/>
		<xsl:variable name="results" as="element()*">
			<xsl:copy-of select="res:results"/>
		</xsl:variable>

		<div>
			<h3>Related Resources <small><a href="#top"><span class="glyphicon glyphicon-arrow-up"
						/></a></small></h3>
			<xsl:for-each select="$objects">
				<xsl:variable name="uri" select="."/>
				<xsl:variable name="roles"
					select="$results/res:result[res:binding[@name='uri']/res:uri = $uri]/res:binding[@name='role']/res:uri"/>
				<xsl:apply-templates
					select="$results/res:result[res:binding[@name='uri']/res:uri = $uri][1]"
					mode="relatedResources">
					<xsl:with-param name="roles" select="$roles"/>
					<xsl:with-param name="position" select="position()"/>
				</xsl:apply-templates>
			</xsl:for-each>
		</div>
	</xsl:template>

	<xsl:template match="res:result" mode="relatedResources">
		<xsl:param name="roles"/>
		<xsl:param name="position"/>

		<div class="row" style="padding-top:5px; padding-bottom:5px">
			<div class="col-md-8">
				<h4>
					<xsl:value-of select="$position"/>
					<xsl:text>. </xsl:text>
					<a href="{res:binding[@name='uri']/res:uri}">
						<xsl:value-of select="res:binding[@name='title']/res:literal"/>
					</a>
				</h4>
				<dl class="dl-horizontal">
					<dt>Relation</dt>
					<dd>
						<xsl:for-each select="$roles">
							<a href="{.}">
								<xsl:value-of select="xeac:normalize_property(.)"/>
							</a>
							<xsl:if test="not(position()=last())">
								<xsl:text>, </xsl:text>
							</xsl:if>
						</xsl:for-each>

					</dd>
					<xsl:if test="res:binding[@name='abstract']/res:literal">
						<dt>Abstract</dt>
						<dd>
							<xsl:value-of select="res:binding[@name='abstract']/res:literal"/>
						</dd>
					</xsl:if>
				</dl>
			</div>
			<div class="col-md-4 text-right">
				<xsl:if test="res:binding[@name='thumbnail']/res:uri">
					<a href="{res:binding[@name='uri']/res:uri}">
						<img src="{res:binding[@name='thumbnail']/res:uri}" style="max-height:100px" alt="thumbnail"/>
					</a>
				</xsl:if>
			</div>
		</div>
	</xsl:template>

	<!-- **************** OPEN ANNOTATIONS (E.G., LINKS FROM A TEI FILE **************** -->
	<xsl:template match="res:sparql" mode="annotations">
		<xsl:variable name="sources"
			select="distinct-values(descendant::res:result/res:binding[@name='source']/res:uri)"/>
		<xsl:variable name="results" as="element()*">
			<xsl:copy-of select="res:results"/>
		</xsl:variable>

		<div>
			<h3>Annotations <small><a href="#top" title="Return to top"><span class="glyphicon glyphicon-arrow-up"
			/></a></small></h3>
			<xsl:for-each select="$sources">
				<xsl:variable name="uri" select="."/>


				<div class="row">
					<div class="col-md-12">
						<h4>
							<xsl:value-of select="position()"/>
							<xsl:text>. </xsl:text>
							<a href="{$uri}">
								<xsl:value-of
									select="$results/res:result[res:binding[@name='source']/res:uri = $uri][1]/res:binding[@name='bookTitle']/res:literal"
								/>
							</a>
						</h4>
					</div>
				</div>

				<xsl:apply-templates
					select="$results/res:result[res:binding[@name='source']/res:uri = $uri]"
					mode="annotations"/>
			</xsl:for-each>
		</div>
	</xsl:template>

	<xsl:template match="res:result" mode="annotations">
		<a href="{res:binding[@name='target']/res:uri}">
			<xsl:value-of select="res:binding[@name='title']/res:literal"/>
		</a>
		<xsl:if test="not(position()=last())">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>

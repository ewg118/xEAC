<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xeac="https://github.com/ewg118/xEAC" exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>
	
	<xsl:variable name="display_path"/>
	<xsl:variable name="url" select="//config/url"/>

	<xsl:param name="query" select="doc('input:request')/request/parameters/parameter[name = 'query']/value"/>

	<xsl:variable name="namespaces" as="item()*">
		<namespaces>
			<namespace prefix="rdf" uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#"/>
			<namespace prefix="arch" uri="http://purl.org/archival/vocab/arch#"/>
			<namespace prefix="bio" uri="http://purl.org/vocab/bio/0.1/"/>
			<namespace prefix="crm" uri="http://erlangen-crm.org/current/"/>
			<namespace prefix="dcterms" uri="http://purl.org/dc/terms/"/>
			<namespace prefix="edm" uri="http://www.europeana.eu/schemas/edm/"/>
			<namespace prefix="foaf" uri="http://xmlns.com/foaf/0.1/"/>
			<namespace prefix="oa" uri="http://www.w3.org/ns/oa#"/>
			<namespace prefix="org" uri="http://www.w3.org/ns/org#"/>
			<namespace prefix="rel" uri="http://purl.org/vocab/relationship/"/>
			<namespace prefix="skos" uri="http://www.w3.org/2004/02/skos/core#"/>
			<namespace prefix="xeac" uri="https://github.com/ewg118/xEAC#"/>
			<namespace prefix="xsd" uri="http://www.w3.org/2001/XMLSchema#"/>
		</namespaces>
	</xsl:variable>

	<xsl:template match="/">
		<html lang="en">
			<head>
				<title><xsl:value-of select="//config/title"/>: SPARQL Results</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<!-- bootstrap -->
				<script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/result_functions.js"/>
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
				<link rel="stylesheet" href="{$display_path}ui/css/style.css"/>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="body"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="body">
		<div class="container-fluid content">
			<div class="row">
				<div class="col-md-12">
					<xsl:choose>
						<xsl:when test="descendant::res:sparql">
							<xsl:apply-templates select="descendant::res:sparql"/>
						</xsl:when>
						<xsl:when test="descendant::rdf:RDF">
							<xsl:apply-templates select="descendant::rdf:RDF"/>
						</xsl:when>
					</xsl:choose>
				</div>
			</div>
		</div>
	</xsl:template>

	<!-- SPARQL DESCRIBE/CONSTRUCT response -->
	<xsl:template match="rdf:RDF">
		<h1>Results</h1>

		<!-- display links to download -->
		<ul class="list-inline">
			<li>
				<strong>Download: </strong>
			</li>
			<li>
				<a href="./query?query={encode-for-uri($query)}&amp;output=xml">RDF/XML</a>
			</li>
			<li>
				<a href="./query?query={encode-for-uri($query)}&amp;output=text">Turtle</a>
			</li>
			<li>
				<a href="./query?query={encode-for-uri($query)}&amp;output=json">JSON-LD</a>
			</li>
		</ul>

		<xsl:choose>
			<xsl:when test="count(*) &gt; 0">
				<table class="table table-striped">
					<tbody>
						<xsl:for-each select="*">
							<tr>
								<td>
									<xsl:apply-templates select="." mode="suburi"/>
								</td>
							</tr>
						</xsl:for-each>

					</tbody>
				</table>
			</xsl:when>
			<xsl:otherwise>
				<p>Your query did not yield results.</p>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- SPARQL SELECT response -->
	<xsl:template match="res:sparql">
		<!-- evaluate the type of response to handle ASK and SELECT -->
		<xsl:choose>
			<xsl:when test="res:results">
				<h1>Results</h1>

				<!-- display links to download -->
				<ul class="list-inline">
					<li>
						<strong>Download: </strong>
					</li>
					<li>
						<a href="./query?query={encode-for-uri($query)}&amp;output=csv">CSV</a>
					</li>
				</ul>

				<xsl:choose>
					<xsl:when test="count(descendant::res:result) &gt; 0">
						<table class="table table-striped">
							<thead>
								<tr>
									<xsl:for-each select="res:head/res:variable">
										<th>
											<xsl:value-of select="@name"/>
										</th>
									</xsl:for-each>
								</tr>
							</thead>
							<tbody>
								<xsl:apply-templates select="descendant::res:result"/>
							</tbody>
						</table>
					</xsl:when>
					<xsl:otherwise>
						<p>Your query did not yield results.</p>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:when>
			<xsl:when test="res:boolean">
				<h1>Response</h1>
				<p> The response to your query is <strong><xsl:value-of select="res:boolean"/></strong>.</p>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="res:result">
		<xsl:variable name="result" as="element()*">
			<xsl:copy-of select="."/>
		</xsl:variable>

		<tr>
			<xsl:for-each select="ancestor::res:sparql/res:head/res:variable">
				<xsl:variable name="name" select="@name"/>

				<xsl:choose>
					<xsl:when test="$result/res:binding[@name = $name]">
						<xsl:apply-templates select="$result/res:binding[@name = $name]"/>
					</xsl:when>
					<xsl:otherwise>
						<td/>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:for-each>

		</tr>
	</xsl:template>

	<xsl:template match="res:binding">
		<td>
			<xsl:choose>
				<xsl:when test="res:uri">
					<xsl:variable name="uri" select="res:uri"/>
					<a href="{res:uri}">
						<xsl:choose>
							<xsl:when test="$namespaces//namespace[contains($uri, @uri)]">
								<xsl:value-of
									select="replace($uri, $namespaces//namespace[contains($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))"
								/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$uri"/>
							</xsl:otherwise>
						</xsl:choose>
					</a>
				</xsl:when>
				<xsl:when test="res:bnode">
					<xsl:text>_:</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="res:literal"/>
					<xsl:if test="res:literal/@xml:lang">
						<i> (<xsl:value-of select="res:literal/@xml:lang"/>)</i>
					</xsl:if>
					<xsl:if test="res:literal/@datatype">
						<xsl:variable name="datatype" select="res:literal/@datatype"/>
						<xsl:variable name="uri"
							select="
								if (contains($datatype, 'xs:')) then
									replace($datatype, 'xs:', 'http://www.w3.org/2001/XMLSchema#')
								else
									if (contains($datatype, 'xsd:')) then
										replace($datatype, 'xsd:', 'http://www.w3.org/2001/XMLSchema#')
									else
										$datatype"/>

						<i> (<a href="{$uri}">
								<xsl:value-of
									select="replace($uri, $namespaces//namespace[contains($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))"
								/></a>)</i>

					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</td>
	</xsl:template>

	<xsl:template match="*" mode="suburi">
		<xsl:variable name="about" select="@rdf:about"/>

		<div rel="{name()}">
			<xsl:if test="string($about)">
				<xsl:attribute name="resource" select="$about"/>
			</xsl:if>

			<h3>
				<xsl:choose>
					<xsl:when test="string($about)">
						<a href="{$about}">
							<xsl:value-of select="$about"/>
						</a>
						<small>
							<xsl:text> (</xsl:text>
							<xsl:value-of select="name()"/>
							<xsl:text>)</xsl:text>
						</small>
					</xsl:when>
					<xsl:otherwise> [_:] <small>
							<xsl:text> (</xsl:text>
							<xsl:value-of select="name()"/>
							<xsl:text>)</xsl:text>
						</small>
					</xsl:otherwise>
				</xsl:choose>
			</h3>


			<dl class="dl-horizontal">
				<xsl:apply-templates select="*" mode="list-item">
					<xsl:sort select="name()"/>
					<xsl:sort select="@rdf:resource"/>
				</xsl:apply-templates>
			</dl>
		</div>
	</xsl:template>

	<xsl:template match="*" mode="list-item">
		<xsl:variable name="name" select="name()"/>
		<dt>
			<a href="{concat($namespaces//namespace[@prefix=substring-before($name, ':')]/@uri, substring-after($name, ':'))}">
				<xsl:value-of select="name()"/>
			</a>
		</dt>
		<dd>
			<xsl:choose>
				<xsl:when test="string(.)">
					<xsl:choose>
						<xsl:when test="name() = 'osgeo:asGeoJSON' and string-length(.) &gt; 100">
							<div id="geoJSON-fragment">
								<xsl:value-of select="substring(., 1, 100)"/>
								<xsl:text>...</xsl:text>
								<a href="#" class="toggle-geoJSON">[more]</a>
							</div>
							<div id="geoJSON-full" style="display:none">
								<span property="{name()}" xml:lang="{@xml:lang}">
									<xsl:value-of select="."/>
								</span>
								<a href="#" class="toggle-geoJSON">[less]</a>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<span property="{name()}">
								<xsl:if test="@xml:lang">
									<xsl:attribute name="xml:lang" select="@xml:lang"/>
								</xsl:if>
								<xsl:if test="@rdf:datatype">
									<xsl:attribute name="datatype" select="@rdf:datatype"/>
								</xsl:if>

								<xsl:choose>
									<xsl:when test="contains(@rdf:datatype, '#gYear')">
										<xsl:value-of select="xeac:normalizeDate(.)"/>
									</xsl:when>
									<xsl:when test="contains(@rdf:datatype, '#gYearMonth')">
										<xsl:value-of select="xeac:normalizeDate(.)"/>
									</xsl:when>
									<xsl:when test="contains(@rdf:datatype, '#date')">
										<xsl:value-of select="xeac:normalizeDate(.)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="."/>
									</xsl:otherwise>
								</xsl:choose>
							</span>
							<xsl:if test="string(@xml:lang)">
								<span class="lang">
									<xsl:value-of select="concat(' (', @xml:lang, ')')"/>
								</span>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="string(@rdf:resource)">
					<span>
						<a href="{@rdf:resource}" rel="{name()}" title="{@rdf:resource}">
							<xsl:choose>
								<xsl:when test="name() = 'rdf:type'">
									<xsl:variable name="uri" select="@rdf:resource"/>
									<xsl:value-of
										select="replace($uri, $namespaces//namespace[contains($uri, @uri)]/@uri, concat($namespaces//namespace[contains($uri, @uri)]/@prefix, ':'))"
									/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="@rdf:resource"/>
								</xsl:otherwise>
							</xsl:choose>
						</a>
					</span>
				</xsl:when>
				<xsl:when test="*">
					<xsl:apply-templates select="*" mode="suburi"/>
				</xsl:when>
			</xsl:choose>
		</dd>
	</xsl:template>

</xsl:stylesheet>

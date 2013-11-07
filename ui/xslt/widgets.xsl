<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:res="http://www.w3.org/2005/sparql-results#" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xeac="https://github.com/ewg118/xEAC" exclude-result-prefixes="#all" version="2.0">

	<xsl:template name="xeac:queryNomisma">
		<xsl:param name="uri"/>

		<xsl:variable name="endpoint">http://nomisma.org/query</xsl:variable>

		<xsl:variable name="query">
			<![CDATA[ 
			PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
			PREFIX dcterms:  <http://purl.org/dc/terms/>
			PREFIX nm:       <http://nomisma.org/id/>			
			SELECT DISTINCT ?object ?title ?identifier ?publisher ?obvThumb ?revThumb WHERE {
			{?type ?p <URI>.
			?object nm:type_series_item ?type.
			?object a nm:coin.
			?object dcterms:publisher ?publisher.
			?object dcterms:title ?title.
			?object nm:obverseThumbnail ?obvThumb.
			?object nm:reverseThumbnail ?revThumb.
			OPTIONAL { ?object dcterms:identifier ?identifier }}
			UNION {?object ?p <URI>.
			?object a nm:coin.
			?object dcterms:title ?title.
			?object dcterms:publisher ?publisher.
			?object nm:obverseThumbnail ?obvThumb.
			?object nm:reverseThumbnail ?revThumb.
			OPTIONAL { ?object dcterms:identifier ?identifier }}
			} LIMIT 5]]>
		</xsl:variable>
		<xsl:variable name="service" select="concat($endpoint, '?query=', encode-for-uri(normalize-space(replace($query, 'URI', $uri))), '&amp;output=xml')"/>

		<xsl:apply-templates select="document($service)/res:sparql" mode="queryNomisma"/>
	</xsl:template>

	<xsl:template match="res:sparql" mode="queryNomisma">
		<xsl:if test="count(descendant::res:result) &gt; 0">
			<div class="objects">
				<h2>Related objects in Nomisma</h2>

				<!-- choose between between Metis (preferred) or internal links -->
				<xsl:apply-templates select="descendant::res:result" mode="queryNomisma"/>
			</div>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="res:result" mode="queryNomisma">
		<div class="g_doc">
			<a href="{res:binding[@name='object']/res:uri}" title="{concat(res:binding[@name='publisher']/res:literal, ': ', res:binding[@name='identifier']/res:literal)}">
				<img class="gi" src="{res:binding[@name='revThumb']/res:uri}"/>
				<img class="gi" src="{res:binding[@name='obvThumb']/res:uri}"/>	
			</a>			
		</div>
	</xsl:template>
</xsl:stylesheet>

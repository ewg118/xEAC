<?xml version="1.0" encoding="UTF-8"?>
<!-- Author: Ethan Gruber
	Function: Evaluate Accept HTTP header and perform the correct content negotiation -->
<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>
	<p:param type="output" name="data"/>

	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>
	
	<!-- read request header for content-type -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#request"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xeac="https://github.com/ewg118/xEAC">
				<xsl:output indent="yes"/>
				
				<xsl:variable name="content-type" select="//header[name[.='accept']]/value"/>
				
				<xsl:template match="/">
					<content-type>
						<xsl:variable name="pieces" select="tokenize($content-type, ';')"/>
						
						<!-- normalize space in fragments in order to support better parsing for content negotiation -->
						<xsl:variable name="accept-fragments" as="item()*">
							<nodes>
								<xsl:for-each select="$pieces">
									<node>
										<xsl:value-of select="normalize-space(.)"/>
									</node>
								</xsl:for-each>
							</nodes>
						</xsl:variable>
						
						<xsl:choose>
							<xsl:when test="count($accept-fragments/node) &gt; 1">
								
								<!-- validate profiles, only linked.art profile for JSON-LD is supported at the moment -->
								<xsl:choose>
									<xsl:when test="$accept-fragments/node[starts-with(., 'profile=')]">
										<!-- parse the profile URI -->
										<xsl:variable name="profile" select="replace(substring-after($accept-fragments/node[starts-with(., 'profile=')][1], '='), '&#x022;', '')"/>
										
										<xsl:choose>
											<!-- only allow the linked.art profile if the content-type is validated to JSON-LD -->
											<xsl:when test="xeac:resolve-content-type($accept-fragments/node[1]) = 'json-ld'">												
												<xsl:choose>
													<xsl:when test="$profile = 'https://linked.art/ns/v1/linked-art.json'">linked-art</xsl:when>
													<xsl:otherwise>json-ld</xsl:otherwise>
												</xsl:choose>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="xeac:resolve-content-type($accept-fragments/node[1])"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="xeac:resolve-content-type($accept-fragments/node[1])"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<!--<xsl:choose>
									<xsl:when test="$accept-profile = '&lt;https://linked.art/ns/v1/linked-art.json&gt;'">linked-art</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="xeac:resolve-content-type($content-type)"/>
									</xsl:otherwise>
								</xsl:choose>-->
								
								<xsl:value-of select="xeac:resolve-content-type($content-type)"/>
							</xsl:otherwise>
						</xsl:choose>
					</content-type>
				</xsl:template>
				
				<xsl:function name="xeac:resolve-content-type">
					<xsl:param name="content-type"/>
					
					<xsl:choose>
						<xsl:when test="$content-type='application/ld+json'">json-ld</xsl:when>
						<xsl:when test="$content-type='application/vnd.google-earth.kml+xml'">kml</xsl:when>
						<xsl:when test="$content-type='application/xml' or $content-type='text/xml'">xml</xsl:when>
						<xsl:when test="$content-type='application/rdf+xml'">rdfxml</xsl:when>
						<xsl:when test="$content-type='application/tei+xml'">tei</xsl:when>
						<xsl:when test="$content-type='text/turtle'">turtle</xsl:when>
						<xsl:when test="contains($content-type, 'text/html') or $content-type='*/*' or not(string($content-type))">html</xsl:when>
						<xsl:otherwise>error</xsl:otherwise>
					</xsl:choose>
				</xsl:function>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="conneg-config"/>
	</p:processor>
	
	<p:choose href="#conneg-config">
		<p:when test="content-type='xml'">
			<p:processor name="oxf:identity">
				<p:input name="data" href="#data"/>
				<p:output name="data" ref="data"/>				
			</p:processor>
		</p:when>		
		<p:when test="content-type='json-ld'">
			<p:processor name="oxf:pipeline">
				<p:input name="config" href="../views/serializations/rdf/json-ld.xpl"/>	
				<p:input name="data" href="#data"/>				
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="content-type='turtle'">
			<p:processor name="oxf:pipeline">
				<p:input name="config" href="../views/serializations/rdf/ttl.xpl"/>
				<p:input name="data" href="#data"/>				
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="content-type='linked-art'">
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#data"/>
				<p:input name="config" href="../views/serializations/eac/linkedart-json-ld.xpl"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="content-type='kml'">
			<p:processor name="oxf:pipeline">
				<p:input name="config" href="../views/serializations/eac/kml.xpl"/>
				<p:input name="data" href="#data"/>		
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="content-type='rdfxml'">
			<p:processor name="oxf:pipeline">
				<p:input name="config" href="../views/serializations/eac/rdf.xpl"/>
				<p:input name="data" href="#data"/>		
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="content-type='tei'">
			<p:processor name="oxf:pipeline">
				<p:input name="config" href="../views/serializations/eac/tei.xpl"/>
				<p:input name="data" href="#data"/>		
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="content-type='html'">
			<p:processor name="oxf:pipeline">
				<p:input name="config" href="../views/serializations/eac/html.xpl"/>
				<p:input name="data" href="#data"/>		
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#data"/>
				<p:input name="config" href="406-not-acceptable.xpl"/>		
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:otherwise>
	</p:choose>
</p:pipeline>

<?xml version="1.0" encoding="UTF-8"?>
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
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
				<xsl:output indent="yes"/>
				<xsl:param name="output" select="/request/parameters/parameter[name='output']/value"/>
				<xsl:param name="query" select="/request/parameters/parameter[name='query']/value"/>
				<xsl:variable name="content-type">
					<xsl:choose>
						<xsl:when test="matches($query, 'construct', 'i') or matches($query, 'describe', 'i')">
							<xsl:choose>
								<xsl:when test="string($output)">
									<xsl:choose>
										<xsl:when test="$output='text'">text/turtle</xsl:when>
										<xsl:when test="$output='json'">application/ld+json</xsl:when>
										<xsl:when test="$output='xml'">application/rdf+xml</xsl:when>
										<xsl:when test="$output='html'">text/html</xsl:when>
										<xsl:otherwise>error</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:when test="string(//header[name[.='accept']]/value)">
									<xsl:variable name="content-type" select="//header[name[.='accept']]/value"/>
									
									<xsl:choose>
										<xsl:when test="$content-type='application/json' or $content-type='application/ld+json'">application/ld+json</xsl:when>
										<xsl:when test="$content-type='application/rdf+xml'">application/rdf+xml</xsl:when>
										<xsl:when test="$content-type='text/turtle'">text/turtle</xsl:when>
										<xsl:when test="contains($content-type, 'text/html') or $content-type='*/*'">text/html</xsl:when>
										<xsl:otherwise>error</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="string($output)">
									<xsl:choose>
										<xsl:when test="$output='text'">text/plain</xsl:when>
										<xsl:when test="$output='csv'">text/csv</xsl:when>
										<xsl:when test="$output='json'">application/sparql-results+json</xsl:when>
										<xsl:when test="$output='xml'">application/sparql-results+xml</xsl:when>
										<xsl:when test="$output='html'">text/html</xsl:when>
										<xsl:otherwise>error</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:when test="string(//header[name[.='accept']]/value)">
									<xsl:variable name="content-type" select="//header[name[.='accept']]/value"/>
									
									<xsl:choose>
										<xsl:when test="$content-type='application/sparql-results+json'">application/sparql-results+json</xsl:when>
										<xsl:when test="$content-type='application/sparql-results+xml'">application/sparql-results+xml</xsl:when>
										<xsl:when test="$content-type='text/csv'">text/csv</xsl:when>
										<xsl:when test="$content-type='text/plain'">text/plain</xsl:when>
										<xsl:when test="contains($content-type, 'text/html') or $content-type='*/*'">text/html</xsl:when>
										<xsl:otherwise>error</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<xsl:template match="/">
					<content-type>
						<xsl:value-of select="$content-type"/>
					</content-type>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<!--<p:output name="data" ref="data"/>-->
		
		<p:output name="data" id="content-type"/>
	</p:processor>
	
	<!-- initiate SPARQL query -->
	<p:processor name="oxf:pipeline">
		<p:input name="data" href="#content-type"/>
		<p:input name="config" href="../models/sparql/query.xpl"/>
		<p:output name="data" id="url-data"/>
	</p:processor>
	
	<p:processor name="oxf:exception-catcher">
		<p:input name="data" href="#url-data"/>
		<p:output name="data" id="url-data-checked"/>
	</p:processor>
	
	<p:choose href="#url-data-checked">
		<p:when test="/exceptions">
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#url-data-checked"/>
				<p:input name="config" href="error.xpl"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:when test="//*/@status-code != '200'">
			<p:processor name="oxf:pipeline">
				<p:input name="data" href="#url-data"/>
				<p:input name="config" href="error.xpl"/>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<!-- Just return the document -->
			<p:processor name="oxf:identity">
				<p:input name="data" href="#url-data-checked"/>
				<p:output name="data" id="model"/>
			</p:processor>
			
			<p:choose href="#content-type">
				<p:when test="content-type= 'application/sparql-results+xml'">
					<p:processor name="oxf:xml-converter">
						<p:input name="data" href="#model"/>
						<p:input name="config">
							<config>
								<content-type>application/sparql-results+xml</content-type>
								<encoding>utf-8</encoding>
								<version>1.0</version>
								<indent>true</indent>
								<indent-amount>4</indent-amount>
							</config>
						</p:input>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<p:when test="content-type= 'application/rdf+xml'">
					<p:processor name="oxf:xml-converter">
						<p:input name="data" href="#model"/>
						<p:input name="config">
							<config>
								<content-type>application/rdf+xml</content-type>
								<encoding>utf-8</encoding>
								<version>1.0</version>
								<indent>true</indent>
								<indent-amount>4</indent-amount>
							</config>
						</p:input>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<p:when test="content-type= 'application/sparql-results+json'">
					<p:processor name="oxf:text-converter">
						<p:input name="data" href="#model"/>
						<p:input name="config">
							<config>
								<content-type>application/sparql-results+json</content-type>
								<encoding>utf-8</encoding>
							</config>
						</p:input>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<p:when test="content-type= 'application/ld+json'">
					<p:processor name="oxf:text-converter">
						<p:input name="data" href="#model"/>
						<p:input name="config">
							<config>
								<content-type>application/ld+json</content-type>
								<encoding>utf-8</encoding>
							</config>
						</p:input>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<p:when test="content-type='text/plain'">
					<p:processor name="oxf:text-converter">
						<p:input name="data" href="#model"/>
						<p:input name="config">
							<config>
								<encoding>utf-8</encoding>
							</config>
						</p:input>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<p:when test="content-type='text/turtle'">
					<p:processor name="oxf:text-converter">
						<p:input name="data" href="#model"/>
						<p:input name="config">
							<config>
								<content-type>text/turtle</content-type>
								<encoding>utf-8</encoding>
							</config>
						</p:input>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<p:when test="content-type='text/csv'">
					<p:processor name="oxf:text-converter">
						<p:input name="data" href="#model"/>
						<p:input name="config">
							<config>
								<content-type>text/csv</content-type>
								<encoding>utf-8</encoding>
							</config>
						</p:input>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<p:when test="content-type='text/html'">
					<p:processor name="oxf:pipeline">
						<p:input name="data" href="#model"/>
						<p:input name="config" href="../views/serializations/sparql/html.xpl"/>
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
		</p:otherwise>
	</p:choose>
</p:pipeline>

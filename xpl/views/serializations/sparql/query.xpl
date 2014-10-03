<?xml version="1.0" encoding="UTF-8"?>
<!--
	XPL handling SPARQL queries from Fuseki	
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

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
	
	<p:processor name="oxf:pipeline">
		<p:input name="config" href="../../../models/config.xpl"/>		
		<p:output name="data" id="config"/>
	</p:processor>

	<!-- generator config for URL generator -->
	<p:processor name="oxf:unsafe-xslt">
		<p:input name="request" href="#request"/>
		<p:input name="data" href="#config"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<!-- url params -->
				<xsl:param name="query" select="doc('input:request')/request/parameters/parameter[name='query']/value"/>
				<xsl:param name="output" select="doc('input:request')/request/parameters/parameter[name='output']/value"/>
					
				<xsl:variable name="output-normalized">
					<xsl:choose>
						<xsl:when test="$output='text' or $output='csv' or $output='json'">
							<xsl:value-of select="$output"/>
						</xsl:when>
						<xsl:otherwise>xml</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<!-- config variables -->
				<xsl:variable name="sparql_endpoint" select="/config/sparql/query"/>

				<xsl:variable name="service">
					<xsl:value-of select="concat($sparql_endpoint, '?query=', encode-for-uri($query), '&amp;output=', $output-normalized)"/>
				</xsl:variable>

				<xsl:template match="/">
					<config>
						<url>
							<xsl:value-of select="$service"/>
						</url>
						<content-type>
							<xsl:choose>
								<xsl:when test="$output='text' or $output='csv'">text/plain</xsl:when>
								<xsl:when test="$output='json'">application/sparql-results+json</xsl:when>
								<xsl:otherwise>application/xml</xsl:otherwise>
							</xsl:choose>
						</content-type>
						<xsl:if test="$output='json'">
							<mode>text</mode>
						</xsl:if>
						<encoding>utf-8</encoding>
					</config>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="url-generator-config"/>
	</p:processor>

	<!-- get the data from fuseki -->
	<p:processor name="oxf:url-generator">
		<p:input name="config" href="#url-generator-config"/>
		<p:output name="data" id="url-data"/>
	</p:processor>
	
	<p:processor name="oxf:exception-catcher">
		<p:input name="data" href="#url-data"/>
		<p:output name="data" id="url-data-checked"/>
	</p:processor>
	
	<!-- Check whether we had an exception -->
	<p:choose href="#url-data-checked">
		<p:when test="/exceptions">
			<!-- Extract the message -->
			<p:processor name="oxf:xslt">
				<p:input name="data" href="aggregate('content', #config, #url-data-checked)"/>
				<p:input name="config" href="../../../../ui/xslt/exception.xsl"/>
				<p:output name="data" id="model"/>
			</p:processor>
			
			<p:processor name="oxf:html-converter">
				<p:input name="data" href="#model"/>
				<p:input name="config">
					<config>
						<version>5.0</version>
						<indent>true</indent>
						<content-type>text/html</content-type>
						<encoding>utf-8</encoding>
						<indent-amount>4</indent-amount>
					</config>
				</p:input>
				<p:output name="data" ref="data"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<!-- generate the serializer config -->
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="#request"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema">
						<xsl:param name="output" select="/request/parameters/parameter[name='output']/value"/>
						
						<xsl:template match="/">
							<mode>
								<xsl:choose>
									<xsl:when test="$output='text'">text</xsl:when>
									<xsl:when test="$output='csv'">csv</xsl:when>
									<xsl:when test="$output='json'">json</xsl:when>
									<xsl:when test="$output='html'">html</xsl:when>
									<xsl:otherwise>xml</xsl:otherwise>
								</xsl:choose>
							</mode>
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="parser-config"/>
			</p:processor>
			
			<!-- Just return the document -->
			<p:processor name="oxf:identity">
				<p:input name="data" href="#url-data-checked"/>
				<p:output name="data" id="model"/>
			</p:processor>
			
			<!-- serialize it -->
			<p:choose href="#parser-config">
				<p:when test="mode='html'">
					<p:processor name="oxf:unsafe-xslt">
						<p:input name="request" href="#request"/>
						<p:input name="data" href="aggregate('content', #model, #config)"/>
						<p:input name="config" href="../../../../ui/xslt/serializations/sparql/html.xsl"/>
						<p:output name="data" id="sparql-to-html"/>
					</p:processor>
					
					<p:processor name="oxf:html-converter">
						<p:input name="data" href="#sparql-to-html"/>
						<p:input name="config">
							<config>
								<version>5.0</version>
								<indent>true</indent>
								<content-type>text/html</content-type>
								<encoding>utf-8</encoding>
								<indent-amount>4</indent-amount>
							</config>
						</p:input>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
				<p:when test="mode='text'">
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
				<p:when test="mode='csv'">
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
				<p:when test="mode='json'">
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
				<p:when test="mode='xml'">
					<p:processor name="oxf:xml-converter">
						<p:input name="data" href="#model"/>
						<p:input name="config">
							<config>
								<content-type>application/xml</content-type>
								<encoding>utf-8</encoding>
								<version>1.0</version>
								<indent>true</indent>
								<indent-amount>4</indent-amount>
							</config>
						</p:input>
						<p:output name="data" ref="data"/>
					</p:processor>
				</p:when>
			</p:choose>
		</p:otherwise>
	</p:choose>
</p:config>

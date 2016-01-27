<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline xmlns:p="http://www.orbeon.com/oxf/pipeline" xmlns:oxf="http://www.orbeon.com/oxf/processors">

	<p:param type="input" name="data"/>

	<p:processor name="oxf:request">
		<p:input name="config">
			<config>
				<include>/request</include>
			</config>
		</p:input>
		<p:output name="data" id="request"/>
	</p:processor>

	<p:processor name="oxf:unsafe-xslt">
		<p:input name="data" href="#data"/>
		<p:input name="config">
			<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  xmlns:xs="http://www.w3.org/2001/XMLSchema">
				<xsl:output indent="yes"/>
				<xsl:template match="/">
					<xsl:variable name="status-code" select="/*/@status-code"/>

					<xsl:choose>
						<xsl:when test="$status-code castable as xs:integer">
							<code>
								<xsl:value-of select="$status-code"/>
							</code>
						</xsl:when>
						<xsl:otherwise>
							<code>503</code>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:template>
			</xsl:stylesheet>
		</p:input>
		<p:output name="data" id="code"/>
	</p:processor>

	<!-- generate HTML fragment to be returned -->

	<p:choose href="#code">
		<p:when test="/code='503'">
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="#code"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
						<xsl:output indent="yes"/>
						<xsl:template match="/">
							<html xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema">
								<head>
									<title>503</title>
								</head>
								<body>
									<h1>503: Service Unavailable</h1>
									<p>The SPARQL endpoint is currently down or there is an error in the configuration file (e.g., bad endpoint URL).</p>
								</body>
							</html>
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="html"/>
			</p:processor>

			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="#data"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
						<xsl:output indent="yes"/>
						<xsl:template match="/">
							<config>
								<status-code>503</status-code>
								<content-type>text/html</content-type>
							</config>
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="header"/>
			</p:processor>
		</p:when>
		<p:otherwise>
			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="#data"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
						<xsl:output indent="yes"/>
						<xsl:template match="/">
							<xsl:variable name="status-code" select="/*/@status-code"/>
							<html xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema">
								<head>
									<title>
										<xsl:value-of select="$status-code"/>
									</title>
								</head>
								<body>
									<xsl:value-of select="."/>
								</body>
							</html>
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="html"/>
			</p:processor>

			<p:processor name="oxf:unsafe-xslt">
				<p:input name="data" href="#data"/>
				<p:input name="config">
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
						<xsl:output indent="yes"/>
						<xsl:template match="/">
							<xsl:variable name="status-code" select="/*/@status-code"/>
							<config>
								<status-code>
									<xsl:value-of select="$status-code"/>
								</status-code>
								<content-type>text/html</content-type>
							</config>
						</xsl:template>
					</xsl:stylesheet>
				</p:input>
				<p:output name="data" id="header"/>
			</p:processor>
		</p:otherwise>
	</p:choose>

	<!-- generate config for http-serializer -->
	<p:processor name="oxf:http-serializer">
		<p:input name="data" href="#html"/>
		<p:input name="config" href="#header"/>
	</p:processor>
</p:pipeline>

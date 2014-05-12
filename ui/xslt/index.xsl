<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="#all" version="2.0">	
	<xsl:include href="templates.xsl"/>
	<xsl:variable name="display_path"/>

	<xsl:template match="/">
		<html xml:lang="en" lang="en" prefix="dcterms: http://purl.org/dc/terms/
			xeac: https://github.com/ewg118/xEAC">
			<head>
				<title property="dcterms:title">
					<xsl:value-of select="/config/title"/>
				</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script type="text/javascript" src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
				<link rel="stylesheet" href="{$display_path}ui/css/style.css"/>
				<link rel="xeac:atom" type="application/atom+xml" href="{concat(/config/url, 'feed/')}"/>
				
				<xsl:if test="string(/config/google_analytics)">
					<script type="text/javascript">
						<xsl:value-of select="/config/google_analytics"/>
					</script>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="index"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="index">
		<div class="container-fluid">
			<div class="row">
				<div class="col-md-8">
					<xsl:copy-of select="/config/index/*"/>
				</div>
				<div class="col-md-4">
					<div class="highlight">
						<h3>Export Options</h3>
						<a href="feed/">
							<img src="{$display_path}ui/images/atom-large.png" title="Atom" alt="Atom"/>
						</a>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>



</xsl:stylesheet>

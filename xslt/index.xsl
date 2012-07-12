<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common" version="2.0">
	<xsl:output doctype-public="-//W3C//DTD HTML 4.01//EN" method="html" encoding="UTF-8"/>
	<xsl:include href="templates.xsl"/>

	<xsl:variable name="exist-url" select="/exist-url"/>
	<xsl:variable name="config" select="document(concat($exist-url, 'xeac/config.xml'))"/>
	<xsl:variable name="ui-theme" select="exsl:node-set($config)/config/theme/jquery_ui_theme"/>
	<xsl:variable name="display_path"/>

	<xsl:template match="/">
		<html xml:lang="en" lang="en">
			<head>
				<title>
					<xsl:value-of select="exsl:node-set($config)/config/title"/>					
				</title>
				<link rel="shortcut icon" href="{$display_path}images/favicon.png" type="image/png"/>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.2r1/build/grids/grids-min.css"/>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.2r1/build/reset-fonts-grids/reset-fonts-grids.css"/>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.2r1/build/base/base-min.css"/>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.2r1/build/fonts/fonts-min.css"/>
				<!-- Core + Skin CSS -->
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.2r1/build/menu/assets/skins/sam/menu.css"/>
				
				<!-- EADitor styling -->
				<link rel="stylesheet" href="{$display_path}css/style.css"/>
				<link rel="stylesheet" href="{$display_path}css/themes/{$ui-theme}.css"/>
				
				<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js" type="text/javascript"/>
				<script type="text/javascript" src="{$display_path}javascript/jquery-ui-1.8.12.custom.min.js"/>
				<script type="text/javascript" src="{$display_path}javascript/menu.js"/>
			</head>
			<body class="yui-skin-sam">
				<div id="doc4" class="yui-t5">
					<!-- header -->
					<xsl:call-template name="header-public"/>
					<div id="bd">
						Index
					</div>
					
					
					<!-- footer -->
					<xsl:call-template name="footer-public"/>
				</div>
				<xsl:copy-of select="exsl:node-set($config)/config/google_analytics/*"/>
			</body>
		</html>
	</xsl:template>





</xsl:stylesheet>

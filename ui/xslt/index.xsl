<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common" version="2.0">
	<xsl:output doctype-public="-//W3C//DTD HTML 4.01//EN" method="html" encoding="UTF-8"/>
	<xsl:include href="templates.xsl"/>

	<xsl:variable name="ui-theme" select="/config/theme/jquery_ui_theme"/>
	<xsl:variable name="display_path"/>

	<xsl:template match="/">
		<html xml:lang="en" lang="en">
			<head>
				<title>
					<xsl:value-of select="/config/title"/>					
				</title>
				<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/3.8.0/build/cssgrids/grids-min.css"/>
				<!-- xEAC styling -->
				<link rel="stylesheet" href="{$display_path}ui/css/style.css"/>
				<link rel="stylesheet" href="{$display_path}ui/css/themes/{$ui-theme}.css"/>
				
				<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js"/>
				<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.23/jquery-ui.min.js"/>
				
				<!-- menu -->
				<script type="text/javascript" src="{$display_path}ui/javascript/ui/jquery.ui.core.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/ui/jquery.ui.widget.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/ui/jquery.ui.position.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/ui/jquery.ui.button.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/ui/jquery.ui.menu.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/ui/jquery.ui.menubar.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/menu.js"/>
				<xsl:copy-of select="/config/google_analytics/*"/>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="index"/>
				<xsl:call-template name="footer"/>				
			</body>
		</html>
	</xsl:template>

	<xsl:template name="index">
		<div class="yui3-g">
			<div class="yui3-u-1">
				<div class="content">
					<p>index content</p>
				</div>
			</div>
		</div>
	</xsl:template>



</xsl:stylesheet>

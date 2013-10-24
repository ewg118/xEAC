<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" xmlns:exsl="http://exslt.org/common" version="2.0">

	<xsl:template name="header-public">
		<div id="hd">
			<div id="banner">
				<xsl:if test="string(exsl:node-set($config)/config/banner_text)">
					<div class="banner_text">
						<xsl:value-of select="exsl:node-set($config)/config/banner_text"/>
					</div>
				</xsl:if>
				<!--<xsl:if test="string(exsl:node-set($config)/config/banner_image/@xlink:href)">
					<img src="{$display_path}images/{exsl:node-set($config)/config/banner_image/@xlink:href}" alt="banner image"/>
				</xsl:if>-->
			</div>
			<ul role="menubar" id="menu" class="menubar ui-menubar ui-widget-header ui-helper-clearfix">
				<li role="presentation" class="ui-menubar-item">
					<a aria-haspopup="true" role="menuitem" class="ui-button ui-widget ui-button-text-only ui-menubar-link" tabindex="-1" href="{$display_path}.">
						<span class="ui-button-text">Home</span>
					</a>
				</li>

				<li role="presentation" class="ui-menubar-item">
					<a aria-haspopup="true" role="menuitem" class="ui-button ui-widget ui-button-text-only ui-menubar-link" tabindex="-1" href="{$display_path}results/?q=*:*">
						<span class="ui-button-text">Browse</span>
					</a>
				</li>
				<!--<li role="presentation" class="ui-menubar-item">
					<a aria-haspopup="true" role="menuitem" class="ui-button ui-widget ui-button-text-only ui-menubar-link" tabindex="-1" href="{$display_path}search/">
						<span class="ui-button-text">Search</span>
					</a>
				</li>-->				
				<!--<li role="presentation" class="ui-menubar-item">
					<a aria-haspopup="true" role="menuitem" class="ui-button ui-widget ui-button-text-only ui-menubar-link" tabindex="-1" href="{$display_path}admin/">
						<span class="ui-button-text">Admin</span>
					</a>
				</li>-->
			</ul>
		</div>
	</xsl:template>

	<xsl:template name="footer-public">
		<div id="ft">Footer</div>
	</xsl:template>

</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
	exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../../templates.xsl"/>
	<xsl:variable name="display_path"/>
	<xsl:variable name="url" select="//config/url"/>

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
		<div class="container-fluid">
			<div class="row">
				<div class="col-md-12">
					<h1>Results</h1>
					<table class="table table-striped">
						<thead>
							<tr>
								<xsl:for-each select="//res:result[1]/res:binding">
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
				</div>
			</div>
		</div>
	</xsl:template>
	
	<xsl:template match="res:result">
		<tr>
			<xsl:apply-templates select="res:binding"/>
		</tr>
	</xsl:template>
	
	<xsl:template match="res:binding">
		<td>
			<xsl:choose>
				<xsl:when test="res:uri">
					<a href="{res:uri}"><xsl:value-of select="res:uri"/></a>
				</xsl:when>
				<xsl:when test="res:bnode">
					<emph>_:</emph>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="res:literal"/>
					<xsl:if test="@xml:lang">
						<i> (<xsl:value-of select="@xml:lang"/>)</i>
					</xsl:if>
					<xsl:if test="@datatype">
						<i> (<xsl:value-of select="@datatype"/>)</i>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</td>
	</xsl:template>

</xsl:stylesheet>

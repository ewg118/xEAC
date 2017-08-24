<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xeac xs" version="2.0"
	xmlns:xeac="https://github.com/ewg118/xEAC">
	<xsl:include href="../../templates.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="display_path">../</xsl:variable>
	<xsl:variable name="pipeline">results</xsl:variable>

	<!-- URL parameters -->
	<xsl:param name="q">
		<xsl:choose>
			<xsl:when test="string(doc('input:params')/request/parameters/parameter[name='q']/value)">
				<xsl:value-of select="doc('input:params')/request/parameters/parameter[name='q']/value"/>
			</xsl:when>
			<xsl:otherwise>*:*</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="lang" select="doc('input:params')/request/parameters/parameter[name='lang']/value"/>
	<xsl:variable name="tokenized_q" select="tokenize($q, ' AND ')"/>
	<xsl:param name="sort">
		<xsl:if test="string(doc('input:params')/request/parameters/parameter[name='sort']/value)">
			<xsl:value-of select="doc('input:params')/request/parameters/parameter[name='sort']/value"/>
		</xsl:if>
	</xsl:param>
	<xsl:param name="rows">20</xsl:param>
	<xsl:param name="start">
		<xsl:choose>
			<xsl:when test="string(doc('input:params')/request/parameters/parameter[name='start']/value)">
				<xsl:value-of select="doc('input:params')/request/parameters/parameter[name='start']/value"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:variable name="numFound" select="//result[@name='response']/@numFound" as="xs:integer"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>
					<xsl:value-of select="/content/config/title"/>
					<xsl:text>: Search Results</xsl:text>
				</title>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"/>
				<!-- bootstrap -->
				<link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css"/>
				<script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"/>
				<link rel="stylesheet" href="{$display_path}ui/css/style.css"/>

				<!-- page js/style -->

				<script type="text/javascript" src="{$display_path}ui/javascript/result_functions.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/get_facets.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/facet_functions.js"/>
				<script type="text/javascript" src="{$display_path}ui/javascript/bootstrap-multiselect.js"/>
				<link rel="stylesheet" href="{$display_path}ui/css/bootstrap-multiselect.css" type="text/css"/>
				<xsl:if test="string(/content/config/google_analytics)">
					<script type="text/javascript"><xsl:value-of select="/content/config/google_analytics"/></script>
				</xsl:if>
				<xsl:copy-of select="/content/config/google_analytics/*"/>
			</head>
			<body>
				<xsl:call-template name="header"/>
				<xsl:call-template name="results"/>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>


	<xsl:template name="results">
		<xsl:apply-templates select="/content/response"/>
	</xsl:template>

	<xsl:template match="response">
		<div id="backgroundPopup"/>
		<div class="container-fluid">
			<div class="row">
				<div class="col-md-3">
					<xsl:if test="//result[@name='response']/@numFound &gt; 0">
						<div class="data_options">
							<h3>Data Options</h3>
							<a href="{$display_path}feed/?q=*:*">
								<img alt="Atom" title="Atom" src="{$display_path}ui/images/atom-medium.png"/>
							</a>
							<!--<xsl:if test="count(//lst[@name='georef']/int) &gt; 0">
								<a href="{$display_path}query.kml?q={$q}">
									<img src="{$display_path}ui/images/googleearth.png" alt="KML" title="KML: Limit, 500 objects"/>
								</a>
							</xsl:if>-->
						</div>
						<h3>Refine Results</h3>
						<xsl:call-template name="quick_search"/>
						<xsl:apply-templates select="descendant::lst[@name='facet_fields']"/>
					</xsl:if>
				</div>
				<div class="col-md-9">
					<!--<xsl:if test="count(//lst[@name='georef']/int) &gt; 0">
						<div style="display:none">
							<div id="resultMap"/>
						</div>
					</xsl:if>-->
					<xsl:choose>
						<xsl:when test="//result[@name='response']/@numFound &gt; 0">
							<!--<xsl:call-template name="sort"/>-->
							<xsl:if test="$q != '*:*'">
								<xsl:call-template name="remove_facets"/>
							</xsl:if>
							<xsl:call-template name="paging"/>
							<xsl:apply-templates select="descendant::doc"/>
							<xsl:call-template name="paging"/>
						</xsl:when>
						<xsl:otherwise>
							<h2> No results found. <a href="{$display_path}results/?q=*:*">Start over.</a></h2>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>

		</div>
		<span id="pipeline" style="display:none">
			<xsl:value-of select="$pipeline"/>
		</span>
		<select id="ajax-temp" style="display:none"/>
	</xsl:template>

	<xsl:template match="doc">
		<xsl:variable name="recordURI">
			<xsl:choose>
				<xsl:when test="string(//config/uri_space)">
					<xsl:value-of select="concat(//config/uri_space, str[@name='id'])"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($display_path, 'id/', str[@name='id'])"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<div class="row result-doc">
			<div class="col-md-8">
				<h3>
					<a href="{$recordURI}">
						<xsl:value-of select="str[@name='name_display']"/>
					</a>
				</h3>
				<dl class="dl-horizontal">
					<xsl:if test="str[@name='existDates_display']">
						<dt>Exist Dates</dt>
						<dd>
							<xsl:value-of select="str[@name='existDates_display']"/>
						</dd>
					</xsl:if>
					<xsl:if test="str[@name='abstract_display']">
						<dt>Abstract</dt>
						<dd>
							<xsl:value-of select="str[@name='abstract_display']"/>
						</dd>
					</xsl:if>
				</dl>

			</div>
			<div class="col-md-4 right">
				<xsl:if test="count(arr[@name='thumb_image']/str) &gt; 0">
					<a href="{$recordURI}">
						<img src="{arr[@name='thumb_image']/str[1]}" alt="Thumbnail" style="max-height:120px;max-width:180px;"/>
					</a>
				</xsl:if>
			</div>
		</div>

	</xsl:template>

	<xsl:template name="paging">
		<xsl:variable name="start_var" as="xs:integer">
			<xsl:choose>
				<xsl:when test="string($start)">
					<xsl:value-of select="$start"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="next">
			<xsl:value-of select="$start_var+$rows"/>
		</xsl:variable>

		<xsl:variable name="previous">
			<xsl:choose>
				<xsl:when test="$start_var &gt;= $rows">
					<xsl:value-of select="$start_var - $rows"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="current" select="$start_var div $rows + 1"/>
		<xsl:variable name="total" select="ceiling($numFound div $rows)"/>

		<div class="paging_div row">
			<div class="col-md-6">
				<xsl:variable name="startRecord" select="$start_var + 1"/>
				<xsl:variable name="endRecord">
					<xsl:choose>
						<xsl:when test="$numFound &gt; ($start_var + $rows)">
							<xsl:value-of select="$start_var + $rows"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$numFound"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<span>
					<b>
						<xsl:value-of select="$startRecord"/>
					</b>
					<xsl:text> to </xsl:text>
					<b>
						<xsl:value-of select="$endRecord"/>
					</b>
					<text> of </text>
					<b>
						<xsl:value-of select="$numFound"/>
					</b>
					<xsl:text> total results.</xsl:text>
				</span>
			</div>



			<!-- paging functionality -->
			<div class="col-md-6 page-nos">
				<div class="btn-toolbar" role="toolbar">
					<div class="btn-group" style="float:right">
						<xsl:choose>
							<xsl:when test="$start_var &gt;= $rows">
								<a class="btn btn-default" title="First" href="./?q={encode-for-uri($q)}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-fast-backward"/>
								</a>
								<a class="btn btn-default" title="Previous" href="./?q={encode-for-uri($q)}&amp;start={$previous}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-backward"/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<a class="btn btn-default disabled" title="First" href="./?q={encode-for-uri($q)}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-fast-backward"/>
								</a>
								<a class="btn btn-default disabled" title="Previous" href="./?q={encode-for-uri($q)}&amp;start={$previous}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-backward"/>
								</a>
							</xsl:otherwise>
						</xsl:choose>
						<!-- current page -->
						<button type="button" class="btn btn-default disabled">
							<b>
								<xsl:value-of select="$current"/>
							</b>
						</button>
						<!-- next page -->
						<xsl:choose>
							<xsl:when test="$numFound - $start_var &gt; $rows">
								<a class="btn btn-default" title="Next" href="./?q={encode-for-uri($q)}&amp;start={$next}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-forward"/>
								</a>
								<a class="btn btn-default" href="./?q={encode-for-uri($q)}&amp;start={($total * $rows) - $rows}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-fast-forward"/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<a class="btn btn-default disabled" title="Next" href="./?q={encode-for-uri($q)}&amp;start={$next}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-forward"/>
								</a>
								<a class="btn btn-default disabled" href="./?q={encode-for-uri($q)}&amp;start={($total * $rows) - $rows}{if (string($sort)) then concat('&amp;sort=', $sort) else ''}">
									<span class="glyphicon glyphicon-fast-forward"/>
								</a>
							</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="sort">
		<xsl:variable name="sort_categories_string">
			<xsl:text>agency_facet,genreform_facet,language_facet,timestamp,unittitle_display,year_sint</xsl:text>
		</xsl:variable>
		<xsl:variable name="sort_categories" select="tokenize(normalize-space($sort_categories_string), ',')"/>

		<div class="sort_div">
			<form class="sortForm" action="{$display_path}results/">
				<select class="sortForm_categories">
					<option value="null">Select from list...</option>
					<xsl:for-each select="$sort_categories">
						<xsl:choose>
							<xsl:when test="contains($sort, .)">
								<option value="{.}" selected="selected">
									<xsl:value-of select="xeac:normalize_fields(.)"/>
								</option>
							</xsl:when>
							<xsl:otherwise>
								<option value="{.}">
									<xsl:value-of select="xeac:normalize_fields(.)"/>
								</option>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</select>
				<select class="sortForm_order">
					<xsl:choose>
						<xsl:when test="contains($sort, 'asc')">
							<option value="asc" selected="selected">Ascending</option>
						</xsl:when>
						<xsl:otherwise>
							<option value="asc">Ascending</option>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="contains($sort, 'desc')">
							<option value="desc" selected="selected">Descending</option>
						</xsl:when>
						<xsl:otherwise>
							<option value="desc">Descending</option>
						</xsl:otherwise>
					</xsl:choose>
				</select>
				<input type="hidden" name="q" value="{$q}"/>
				<input type="hidden" name="sort" value="" class="sort_param"/>
				<xsl:choose>
					<xsl:when test="string($sort)">
						<input id="sort_button" type="submit" value="Sort Results"/>
					</xsl:when>
					<xsl:otherwise>
						<input id="sort_button" type="submit" value="Sort Results"/>
					</xsl:otherwise>
				</xsl:choose>
			</form>
		</div>
	</xsl:template>

	<xsl:template name="quick_search">
		<div class="quick_search">
			<form role="form" action="." method="GET" id="qs_form">
				<input type="hidden" name="q" id="qs_query" value="{$q}"/>
				<xsl:if test="string($lang)">
					<input type="hidden" name="lang" value="{$lang}"/>
				</xsl:if>
				<input type="text" class="form-control" id="qs_text" placeholder="Search"/>
				<button class="btn btn-default" type="submit">
					<i class="glyphicon glyphicon-search"/>
				</button>
			</form>
		</div>
	</xsl:template>

	<xsl:template match="lst[@name='facet_fields']">
		<xsl:for-each select="lst[not(@name='georef')][descendant::int]">
			<xsl:variable name="val" select="@name"/>
			<xsl:variable name="new_query">
				<xsl:for-each select="$tokenized_q[not(contains(., $val))]">
					<xsl:value-of select="."/>
					<xsl:if test="position() != last()">
						<xsl:text> AND </xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			<xsl:variable name="title">
				<xsl:value-of select="xeac:normalize_fields(@name)"/>
			</xsl:variable>
			<xsl:variable name="select_new_query">
				<xsl:choose>
					<xsl:when test="string($new_query)">
						<xsl:value-of select="$new_query"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>*:*</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<select id="{@name}-select" title="{$title}" q="{$q}" new_query="{if (contains($q, @name)) then $select_new_query else ''}" class="multiselect" multiple="multiple">
				<xsl:if test="contains($q, @name)">
					<xsl:copy-of select="document(concat($url, 'get_facets/?q=', encode-for-uri($q), '&amp;category=', @name, '&amp;sort=index&amp;limit=-1'))//option"/>
				</xsl:if>
			</select>
		</xsl:for-each>
		<form action="." id="facet_form">
			<input type="hidden" name="q" id="facet_form_query" value="{if (string($q)) then $q else '*:*'}"/>
			<br/>
			<div class="submit_div">
				<input type="submit" value="Refine Search" id="search_button" class="btn btn-default"/>
			</div>
		</form>
	</xsl:template>

	<xsl:template name="remove_facets">
		<div class="remove_facets">
			<h2>Filters</h2>
			<!--<xsl:choose>
				<xsl:when test="$q = '*:*'">
					<h1>All Terms <xsl:if test="count(//lst[@name='georef']/int) &gt; 0">
							<a href="#resultMap" id="map_results">Map Results</a>
						</xsl:if>
					</h1>
				</xsl:when>
				<xsl:otherwise>
					<h1>Filters <xsl:if test="count(//lst[@name='georef']/int) &gt; 0">
							<a href="#resultMap" id="map_results">Map Results</a>
						</xsl:if>
					</h1>
				</xsl:otherwise>
			</xsl:choose>-->

			<xsl:for-each select="$tokenized_q">
				<xsl:variable name="val" select="."/>
				<xsl:variable name="new_query">
					<xsl:for-each select="$tokenized_q[not($val = .)]">
						<xsl:value-of select="."/>
						<xsl:if test="position() != last()">
							<xsl:text> AND </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>

				<!--<xsl:value-of select="."/>-->
				<xsl:choose>
					<xsl:when test="not(. = '*:*') and not(substring(., 1, 1) = '(')">
						<xsl:variable name="field" select="substring-before(., ':')"/>
						<xsl:variable name="name">
							<xsl:choose>
								<xsl:when test="string($field)">
									<xsl:value-of select="xeac:normalize_fields($field)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="xeac:normalize_fields('text')"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="term">
							<xsl:choose>
								<xsl:when test="string(substring-before(., ':'))">
									<xsl:value-of select="replace(substring-after(., ':'), '&#x022;', '')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="replace(., '&#x022;', '')"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>

						<div class="stacked_term bg-info row">
							<!-- establish orientation based on language parameter -->
							<div class="col-md-10">
								<span>
									<b><xsl:value-of select="$name"/>: </b>
									<xsl:choose>
										<xsl:when test="$field='century_num'">
											<!--<xsl:value-of select="numishare:normalize_century($term)"/>-->
										</xsl:when>
										<xsl:when test="contains($field, '_hier')">
											<xsl:variable name="tokens" select="tokenize(substring($term, 2, string-length($term)-2), '\+')"/>
											<xsl:for-each select="$tokens[position() &gt; 1]">
												<xsl:sort/>
												<xsl:value-of select="normalize-space(substring-after(., '|'))"/>
												<xsl:if test="not(position()=last())">
													<xsl:text>--</xsl:text>
												</xsl:if>
											</xsl:for-each>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="$term"/>
										</xsl:otherwise>
									</xsl:choose>
								</span>
							</div>
							<div class="col-md-2 right">
								<a href="{$display_path}results/?q={if (string($new_query)) then encode-for-uri($new_query) else '*:*'}{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
									<span class="glyphicon glyphicon-remove"/>
								</a>
							</div>
						</div>

					</xsl:when>
					<!-- if the token contains a parenthisis, then it was probably sent from the search widget and the token must be broken down further to remove other facets -->
					<xsl:when test="substring(., 1, 1) = '('">
						<xsl:variable name="tokenized-fragments" select="tokenize(., ' OR ')"/>

						<div class="stacked_term bg-info row">
							<div class="col-md-10">
								<span>
									<xsl:for-each select="$tokenized-fragments">
										<xsl:variable name="field" select="substring-before(translate(., '()', ''), ':')"/>
										<xsl:variable name="after-colon" select="substring-after(., ':')"/>

										<xsl:variable name="value">
											<xsl:choose>
												<xsl:when test="substring($after-colon, 1, 1) = '&#x022;'">
													<xsl:analyze-string select="$after-colon" regex="&#x022;([^&#x022;]+)&#x022;">
														<xsl:matching-substring>
															<xsl:value-of select="concat('&#x022;', regex-group(1), '&#x022;')"/>
														</xsl:matching-substring>
													</xsl:analyze-string>
												</xsl:when>
												<xsl:when test="substring($after-colon, 1, 1) = '('">
													<xsl:analyze-string select="$after-colon" regex="\(([^\)]+)\)">
														<xsl:matching-substring>
															<xsl:value-of select="concat('(', regex-group(1), ')')"/>
														</xsl:matching-substring>
													</xsl:analyze-string>
												</xsl:when>
												<xsl:otherwise>
													<xsl:analyze-string select="$after-colon" regex="([0-9]+)">
														<xsl:matching-substring>
															<xsl:value-of select="regex-group(1)"/>
														</xsl:matching-substring>
													</xsl:analyze-string>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:variable>

										<xsl:variable name="q_string" select="concat($field, ':', $value)"/>

										<!--<xsl:variable name="value" select="."/>-->
										<xsl:variable name="new_multicategory">
											<xsl:for-each select="$tokenized-fragments[not(contains(.,$q_string))]">
												<xsl:variable name="other_field" select="substring-before(translate(., '()', ''), ':')"/>
												<xsl:variable name="after-colon" select="substring-after(., ':')"/>

												<xsl:variable name="other_value">
													<xsl:choose>
														<xsl:when test="substring($after-colon, 1, 1) = '&#x022;'">
															<xsl:analyze-string select="$after-colon" regex="&#x022;([^&#x022;]+)&#x022;">
																<xsl:matching-substring>
																	<xsl:value-of select="concat('&#x022;', regex-group(1), '&#x022;')"/>
																</xsl:matching-substring>
															</xsl:analyze-string>
														</xsl:when>
														<xsl:when test="substring($after-colon, 1, 1) = '('">
															<xsl:analyze-string select="$after-colon" regex="\(([^\)]+)\)">
																<xsl:matching-substring>
																	<xsl:value-of select="concat('(', regex-group(1), ')')"/>
																</xsl:matching-substring>
															</xsl:analyze-string>
														</xsl:when>
														<xsl:otherwise>
															<xsl:analyze-string select="$after-colon" regex="([0-9]+)">
																<xsl:matching-substring>
																	<xsl:value-of select="regex-group(1)"/>
																</xsl:matching-substring>
															</xsl:analyze-string>
														</xsl:otherwise>
													</xsl:choose>
												</xsl:variable>
												<xsl:value-of select="concat($other_field, ':', encode-for-uri($other_value))"/>
												<xsl:if test="position() != last()">
													<xsl:text> OR </xsl:text>
												</xsl:if>
											</xsl:for-each>
										</xsl:variable>
										<xsl:variable name="multicategory_query">
											<xsl:choose>
												<xsl:when test="contains($new_multicategory, ' OR ')">
													<xsl:value-of select="concat('(', $new_multicategory, ')')"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="$new_multicategory"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:variable>


										<b>
											<xsl:value-of select="xeac:normalize_fields($field)"/>
											<xsl:text>: </xsl:text>
										</b>

										<xsl:choose>
											<xsl:when test="$field='century_num'">
												<!--<xsl:value-of select="numishare:normalize_century($value)"/>-->
											</xsl:when>
											<xsl:when test="contains($field, '_hier')">
												<xsl:variable name="tokens" select="tokenize(substring($value, 2, string-length($value)-2), '\+')"/>
												<xsl:for-each select="$tokens[position() &gt; 1]">
													<xsl:sort/>
													<xsl:value-of select="normalize-space(replace(substring-after(., '|'), '&#x022;', ''))"/>
													<xsl:if test="not(position()=last())">
														<xsl:text>--</xsl:text>
													</xsl:if>
												</xsl:for-each>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="$value"/>
											</xsl:otherwise>
										</xsl:choose>

										<!-- concatenate the query with the multicategory removed with the new multicategory, or if the multicategory is empty, display just the $new_query -->
										<a
											href="{$display_path}results/?q={if (string($multicategory_query) and string($new_query)) then concat($new_query, ' AND ', $multicategory_query) else if (string($multicategory_query) and not(string($new_query))) then $multicategory_query else $new_query}{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
											<span class="glyphicon glyphicon-remove"/>
										</a>

										<xsl:if test="position() != last()">
											<xsl:text> OR </xsl:text>
										</xsl:if>
									</xsl:for-each>
								</span>
							</div>
							<div class="col-md-2 right">
								<a href="{$display_path}results/?q={if (string($new_query)) then encode-for-uri($new_query) else '*:*'}{if (string($lang)) then concat('&amp;lang=', $lang) else ''}">
									<span class="glyphicon glyphicon-remove"/>
								</a>
							</div>
						</div>
					</xsl:when>
					<xsl:when test="not(contains(., ':'))">
						<div class="stacked_term bg-info row">
							<div class="col-md-12">
								<span>
									<b>Keyword: </b>
									<xsl:value-of select="."/>
								</span>
							</div>
						</div>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>

			<!-- remove sort term -->
			<xsl:if test="string($sort)">
				<xsl:variable name="field" select="substring-before($sort, ' ')"/>
				<xsl:variable name="name">
					<xsl:value-of select="xeac:normalize_fields($field)"/>
				</xsl:variable>

				<xsl:variable name="order">
					<xsl:choose>
						<xsl:when test="substring-after($sort, ' ') = 'asc'">Acending</xsl:when>
						<xsl:when test="substring-after($sort, ' ') = 'desc'">Descending</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<div class="stacked_term bg-info row">
					<div class="col-md-10">
						<span>
							<b>Sort Category: </b>
							<xsl:value-of select="$name"/>
							<xsl:text>, </xsl:text>
							<xsl:value-of select="$order"/>
						</span>
					</div>
					<div class="col-md-2">
						<a class="remove_filter" href="?q={$q}">
							<span class="glyphicon glyphicon-remove"/>
						</a>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="string($tokenized_q[2])">
				<div class="stacked_term bg-info row">
					<div class="col-md-12">
						<a id="clear_all" href="{$display_path}/results/"><span class="glyphicon glyphicon-remove"/>Clear All Terms</a>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>
</xsl:stylesheet>

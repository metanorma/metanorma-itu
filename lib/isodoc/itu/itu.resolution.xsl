<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:itu="https://www.metanorma.org/ns/itu" xmlns:mathml="http://www.w3.org/1998/Math/MathML" xmlns:xalan="http://xml.apache.org/xalan" xmlns:fox="http://xmlgraphics.apache.org/fop/extensions" xmlns:java="http://xml.apache.org/xalan/java" exclude-result-prefixes="java" version="1.0">

	<xsl:output method="xml" encoding="UTF-8" indent="no"/>

	<xsl:param name="svg_images"/>
	<xsl:variable name="images" select="document($svg_images)"/>
	
	
	
	<xsl:key name="kfn" match="itu:p/itu:fn" use="@reference"/>
	
	
	
	<xsl:variable name="debug">false</xsl:variable>
	<xsl:variable name="pageWidth" select="'210mm'"/>
	<xsl:variable name="pageHeight" select="'297mm'"/>
	
	<!-- Rec. ITU-T G.650.1 (03/2018) -->
	<xsl:variable name="footerprefix" select="'Rec. '"/>
	<xsl:variable name="docname">		
		<xsl:value-of select="substring-before(/itu:itu-standard/itu:bibdata/itu:docidentifier, ' ')"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="substring-after(/itu:itu-standard/itu:bibdata/itu:docidentifier, ' ')"/>
		<xsl:text> </xsl:text>
	</xsl:variable>
	<xsl:variable name="docdate">
		<xsl:call-template name="formatDate">
			<xsl:with-param name="date" select="/itu:itu-standard/itu:bibdata/itu:date[@type = 'published']/itu:on"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="doctype">
		<xsl:call-template name="capitalize">
			<xsl:with-param name="str" select="/itu:itu-standard/itu:bibdata/itu:ext/itu:doctype"/>
		</xsl:call-template>		
	</xsl:variable>
	
	
	<!-- Example:
		<item level="1" id="Foreword" display="true">Foreword</item>
		<item id="term-script" display="false">3.2</item>
	-->
	<xsl:variable name="contents">
		<contents>
			<!-- <xsl:apply-templates select="/itu:itu-standard/itu:preface/node()" mode="contents"/> -->
			<xsl:apply-templates select="/itu:itu-standard/itu:sections/itu:clause[1]" mode="contents"/> <!-- @id = 'scope' -->
				
			<!-- Normative references -->
			<xsl:apply-templates select="/itu:itu-standard/itu:bibliography/itu:references[1]" mode="contents"/> <!-- @id = 'references' -->
			
			<xsl:apply-templates select="/itu:itu-standard/itu:sections/*[position() != 1]" mode="contents"/> <!-- @id != 'scope' -->
				
			<xsl:apply-templates select="/itu:itu-standard/itu:annex" mode="contents"/>
			
			<!-- Bibliography -->
			<xsl:apply-templates select="/itu:itu-standard/itu:bibliography/itu:references[position() != 1]" mode="contents"/> <!-- @id = 'bibliography' -->
			
			<xsl:apply-templates select="//itu:table" mode="contents"/>
			
		</contents>
	</xsl:variable>

	<xsl:variable name="lang">
		<xsl:call-template name="getLang"/>
	</xsl:variable>
	
	<xsl:template match="/">
		<xsl:call-template name="namespaceCheck"/>
		<fo:root font-family="Times New Roman, STIX2Math" font-size="12pt" xml:lang="{$lang}">
			<fo:layout-master-set>
				<!-- cover page -->
				<fo:simple-page-master master-name="cover-page" page-width="{$pageWidth}" page-height="{$pageHeight}">
					<fo:region-body margin-top="19.2mm" margin-bottom="5mm" margin-left="19.2mm" margin-right="19.2mm"/>
					<fo:region-before region-name="cover-page-header" extent="19.2mm" display-align="center"/>
					<fo:region-after/>
					<fo:region-start region-name="cover-left-region" extent="19.2mm"/>
					<fo:region-end region-name="cover-right-region" extent="19.2mm"/>
				</fo:simple-page-master>
				<!-- contents pages -->
				<!-- odd pages Preface -->
				<fo:simple-page-master master-name="odd-preface" page-width="{$pageWidth}" page-height="{$pageHeight}">
					<fo:region-body margin-top="19.2mm" margin-bottom="19.2mm" margin-left="19.2mm" margin-right="19.2mm"/>
					<fo:region-before region-name="header-odd" extent="19.2mm" display-align="center"/>
					<fo:region-after region-name="footer-odd" extent="19.2mm"/>
					<fo:region-start region-name="left-region" extent="19.2mm"/>
					<fo:region-end region-name="right-region" extent="19.2mm"/>
				</fo:simple-page-master>
				<!-- even pages Preface -->
				<fo:simple-page-master master-name="even-preface" page-width="{$pageWidth}" page-height="{$pageHeight}">
					<fo:region-body margin-top="19.2mm" margin-bottom="19.2mm" margin-left="19.2mm" margin-right="19.2mm"/>
					<fo:region-before region-name="header-even" extent="19.2mm" display-align="center"/>
					<fo:region-after region-name="footer-even" extent="19.2mm"/>
					<fo:region-start region-name="left-region" extent="19.2mm"/>
					<fo:region-end region-name="right-region" extent="19.2mm"/>
				</fo:simple-page-master>
				<fo:page-sequence-master master-name="document-preface">
					<fo:repeatable-page-master-alternatives>
						<fo:conditional-page-master-reference odd-or-even="even" master-reference="even-preface"/>
						<fo:conditional-page-master-reference odd-or-even="odd" master-reference="odd-preface"/>
					</fo:repeatable-page-master-alternatives>
				</fo:page-sequence-master>
				<!-- odd pages Body -->
				<fo:simple-page-master master-name="odd" page-width="{$pageWidth}" page-height="{$pageHeight}">
					<fo:region-body margin-top="20mm" margin-bottom="20mm" margin-left="20mm" margin-right="20mm"/>
					<fo:region-before region-name="header-odd" extent="20mm" display-align="center"/>
					<fo:region-after region-name="footer-odd" extent="20mm"/>
					<fo:region-start region-name="left-region" extent="20mm"/>
					<fo:region-end region-name="right-region" extent="20mm"/>
				</fo:simple-page-master>
				<!-- even pages Body -->
				<fo:simple-page-master master-name="even" page-width="{$pageWidth}" page-height="{$pageHeight}">
					<fo:region-body margin-top="20mm" margin-bottom="20mm" margin-left="20mm" margin-right="20mm"/>
					<fo:region-before region-name="header-even" extent="20mm" display-align="center"/>
					<fo:region-after region-name="footer-even" extent="20mm"/>
					<fo:region-start region-name="left-region" extent="20mm"/>
					<fo:region-end region-name="right-region" extent="20mm"/>
				</fo:simple-page-master>
				<fo:page-sequence-master master-name="document">
					<fo:repeatable-page-master-alternatives>
						<fo:conditional-page-master-reference odd-or-even="even" master-reference="even"/>
						<fo:conditional-page-master-reference odd-or-even="odd" master-reference="odd"/>
					</fo:repeatable-page-master-alternatives>
				</fo:page-sequence-master>
			</fo:layout-master-set>

			<xsl:call-template name="addPDFUAmeta"/>
			
			<!-- cover page -->
			<fo:page-sequence master-reference="cover-page">
				<fo:flow flow-name="xsl-region-body">
				
					<fo:block-container absolute-position="fixed" left="148mm" top="265mm">
						<fo:block>
							<fo:external-graphic src="{concat('data:image/png;base64,', normalize-space($Image-Logo))}" width="42.6mm" content-height="17.7mm" content-width="scale-to-fit" scaling="uniform" fox:alt-text="Image {@alt}"/>
						</fo:block>
					</fo:block-container>
				
					<fo:block-container absolute-position="fixed" left="-7mm" top="0">
						<fo:block>
							<fo:external-graphic src="{concat('data:image/png;base64,', normalize-space($Image-Fond-Rec))}" width="43.6mm" content-height="299.2mm" content-width="scale-to-fit" scaling="uniform" fox:alt-text="Image {@alt}"/>
						</fo:block>
					</fo:block-container>
					<fo:block-container font-family="Arial">
						<fo:table width="100%" table-layout="fixed"> <!-- 175.4mm-->
							<fo:table-column column-width="25.2mm"/>
							<fo:table-column column-width="44.4mm"/>
							<fo:table-column column-width="35.8mm"/>
							<fo:table-column column-width="67mm"/>
							<fo:table-body>
								<fo:table-row height="37.5mm"> <!-- 42.5mm -->
									<fo:table-cell>
										<fo:block> </fo:block>
									</fo:table-cell>
									<fo:table-cell number-columns-spanned="3">
										<fo:block font-family="Arial" font-size="13pt" font-weight="bold" color="gray"> <!--  margin-top="16pt" letter-spacing="4pt", Helvetica for letter-spacing working -->
											<fo:block><xsl:value-of select="$linebreak"/></fo:block>
											<xsl:call-template name="addLetterSpacing">
												<xsl:with-param name="text" select="/itu:itu-standard/itu:bibdata/itu:contributor[itu:role/@type='author']/itu:organization/itu:name"/>
											</xsl:call-template>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
								<fo:table-row>
									<fo:table-cell>
										<fo:block> </fo:block>
									</fo:table-cell>
									<fo:table-cell padding-top="2mm" padding-bottom="-1mm">
										<fo:block font-family="Arial" font-size="36pt" font-weight="bold" margin-top="6pt" letter-spacing="2pt"> <!-- Helvetica for letter-spacing working -->
											<xsl:value-of select="substring-before(/itu:itu-standard/itu:bibdata/itu:docidentifier, ' ')"/>
										</fo:block>
									</fo:table-cell>
									<fo:table-cell padding-top="1mm" number-columns-spanned="2" padding-bottom="-1mm">
										<fo:block font-size="30pt" font-weight="bold" text-align="right" margin-top="12pt" padding="0mm">
											<xsl:value-of select="substring-after(/itu:itu-standard/itu:bibdata/itu:docidentifier, ' ')"/>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
								<fo:table-row height="17.2mm">
									<fo:table-cell>
										<fo:block> </fo:block>
									</fo:table-cell>
									<fo:table-cell font-size="10pt" number-columns-spanned="2" padding-top="1mm">
										<fo:block>
											<xsl:text>TELECOMMUNICATION</xsl:text>
										</fo:block>
										<fo:block>
											<xsl:text>STANDARDIZATION SECTOR</xsl:text>
										</fo:block>
										<fo:block>
											<xsl:text>OF ITU</xsl:text>
										</fo:block>
									</fo:table-cell>
									<fo:table-cell text-align="right">
										<xsl:if test="/itu:itu-standard/itu:bibdata/itu:ext/itu:structuredidentifier/itu:annexid">
											<fo:block font-size="18pt" font-weight="bold">
											<xsl:variable name="title-annex">
													<xsl:call-template name="getTitle">
														<xsl:with-param name="name" select="'title-annex'"/>
													</xsl:call-template>
												</xsl:variable>
												<xsl:value-of select="$title-annex"/><xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:structuredidentifier/itu:annexid"/>
											</fo:block>
										</xsl:if>
										<fo:block font-size="14pt">
											<xsl:call-template name="formatDate">
												<xsl:with-param name="date" select="/itu:itu-standard/itu:bibdata/itu:date[@type = 'published']/itu:on"/>
											</xsl:call-template>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
								<fo:table-row height="64mm"> <!-- 59mm -->
									<fo:table-cell>
										<fo:block> </fo:block>
									</fo:table-cell>
									<fo:table-cell font-size="16pt" number-columns-spanned="3" border-bottom="0.5mm solid black" padding-right="2mm" display-align="after">
										<fo:block padding-bottom="7mm">
											<fo:block text-transform="uppercase">
												<xsl:if test="normalize-space(/itu:itu-standard/itu:bibdata/itu:series[@type = 'main']) != ''">
													<xsl:variable name="title">
														<xsl:text>Series </xsl:text>
														<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:series[@type = 'main']"/>
													</xsl:variable>
													<xsl:value-of select="$title"/>												
												</xsl:if>
											</fo:block>
											<xsl:if test="/itu:itu-standard/itu:bibdata/itu:series">
												<fo:block margin-top="6pt">
													<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:series[@type = 'secondary']"/>
													<xsl:if test="normalize-space(/itu:itu-standard/itu:bibdata/itu:series[@type = 'tertiary']) != ''">
														<xsl:text> — </xsl:text>
														<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:series[@type = 'tertiary']"/>
													</xsl:if>
												</fo:block>
											</xsl:if>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
								<fo:table-row height="40mm">
									<fo:table-cell>
										<fo:block> </fo:block>
									</fo:table-cell>
									<fo:table-cell font-size="18pt" number-columns-spanned="3">
										<fo:block padding-right="2mm" margin-top="6pt">
											<xsl:if test="not(/itu:itu-standard/itu:bibdata/itu:title[@type = 'annex' and @language = 'en'])">
												<xsl:attribute name="font-weight">bold</xsl:attribute>
											</xsl:if>
											<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:title[@type = 'main' and @language = 'en']"/>
										</fo:block>
										<xsl:for-each select="/itu:itu-standard/itu:bibdata/itu:title[@type = 'annex' and @language = 'en']">
											<fo:block font-weight="bold">
												<xsl:value-of select="."/>
											</fo:block>
										</xsl:for-each>
									</fo:table-cell>
								</fo:table-row>
								<fo:table-row height="40mm">
									<fo:table-cell>
										<fo:block> </fo:block>
									</fo:table-cell>
									<fo:table-cell number-columns-spanned="3">
										<xsl:choose>
											<xsl:when test="/itu:itu-standard/itu:boilerplate/itu:legal-statement/itu:clause[@id='draft-warning']">
												<xsl:attribute name="border">0.7mm solid black</xsl:attribute>
												<fo:block padding-top="3mm" margin-left="1mm" margin-right="1mm">
													<xsl:apply-templates select="/itu:itu-standard/itu:boilerplate/itu:legal-statement/itu:clause[@id='draft-warning']" mode="caution"/>
												</fo:block>
											</xsl:when>
											<xsl:otherwise>
												<fo:block> </fo:block>
											</xsl:otherwise>
										</xsl:choose>
									</fo:table-cell>
								</fo:table-row>
								<fo:table-row height="25mm">
									<fo:table-cell>
										<fo:block> </fo:block>
									</fo:table-cell>
									<fo:table-cell number-columns-spanned="3">
										<fo:block font-size="16pt" margin-top="3pt">
											<xsl:value-of select="$doctype"/>
											<xsl:text>  </xsl:text>
											<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:contributor/itu:organization/itu:abbreviation"/>
											<xsl:text>-</xsl:text>
											<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:structuredidentifier/itu:bureau"/>
											<xsl:text>  </xsl:text>
											<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:structuredidentifier/itu:docnumber"/>
											<xsl:if test="/itu:itu-standard/itu:bibdata/itu:ext/itu:structuredidentifier/itu:annexid">
												<xsl:variable name="title-annex">
													<xsl:call-template name="getTitle">
														<xsl:with-param name="name" select="'title-annex'"/>
													</xsl:call-template>
												</xsl:variable>
												<xsl:text> — </xsl:text><xsl:value-of select="$title-annex"/><xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:structuredidentifier/itu:annexid"/>
											</xsl:if>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</fo:table-body>
						</fo:table>
					</fo:block-container>
				</fo:flow>
			</fo:page-sequence>
			
			
			<fo:page-sequence master-reference="document-preface" initial-page-number="1" format="i" force-page-count="no-force">
				<xsl:call-template name="insertHeaderFooter"/>
				<fo:flow flow-name="xsl-region-body">
					<fo:block-container font-size="14pt" font-weight="bold">
						<fo:block>
							<xsl:value-of select="$doctype"/>
							<xsl:text> </xsl:text>
							<xsl:value-of select="$docname"/>
						</fo:block>
						<fo:block text-align="center" margin-top="15pt" margin-bottom="15pt">
							<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:title[@type = 'main' and @language = 'en']"/>
						</fo:block>
					</fo:block-container>
					<!-- Summary, History ... -->
					<xsl:call-template name="processPrefaceSectionsDefault"/>
					
					<!-- Keywords -->
					<xsl:if test="/itu:itu-standard/itu:bibdata/itu:keyword">
						<fo:block font-size="12pt">
							<xsl:value-of select="$linebreak"/>
							<xsl:value-of select="$linebreak"/>
						</fo:block>
						<fo:block font-weight="bold" margin-top="18pt" margin-bottom="18pt">
							<xsl:variable name="title-keywords">
								<xsl:call-template name="getTitle">
									<xsl:with-param name="name" select="'title-keywords'"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:value-of select="$title-keywords"/>
						</fo:block>
						<fo:block>
							<xsl:call-template name="insertKeywords"/>
						</fo:block>
					</xsl:if>
					
					<fo:block break-after="page"/>
					
					<!-- FOREWORD -->
					<fo:block font-size="11pt" text-align="justify">
						<xsl:apply-templates select="/itu:itu-standard/itu:boilerplate/itu:legal-statement"/>
						<xsl:apply-templates select="/itu:itu-standard/itu:boilerplate/itu:license-statement"/>
						<xsl:apply-templates select="/itu:itu-standard/itu:boilerplate/itu:copyright-statement"/>
					</fo:block>
					
					<xsl:if test="$debug = 'true'">
						<xsl:text disable-output-escaping="yes">&lt;!--</xsl:text>
							DEBUG
							contents=<xsl:copy-of select="xalan:nodeset($contents)"/>
						<xsl:text disable-output-escaping="yes">--&gt;</xsl:text>
					</xsl:if>
					
					<xsl:if test="xalan:nodeset($contents)//item">
						<fo:block break-after="page"/>
						<fo:block-container>
							<xsl:variable name="title-toc">
								<xsl:call-template name="getTitle">
									<xsl:with-param name="name" select="'title-toc'"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:variable name="title-page">
								<xsl:call-template name="getTitle">
									<xsl:with-param name="name" select="'title-page'"/>
								</xsl:call-template>
							</xsl:variable>
							<fo:block margin-top="6pt" text-align="center" font-weight="bold"><xsl:value-of select="$title-toc"/></fo:block>
							<fo:block margin-top="6pt" text-align="right" font-weight="bold"><xsl:value-of select="$title-page"/></fo:block>
							
								<xsl:for-each select="xalan:nodeset($contents)//item">									
									<fo:block>
										<xsl:if test="@level = 1">
											<xsl:attribute name="margin-top">6pt</xsl:attribute>
										</xsl:if>
										<xsl:if test="@level = 2">
											<xsl:attribute name="margin-top">4pt</xsl:attribute>
											<!-- <xsl:attribute name="margin-left">12mm</xsl:attribute> -->
										</xsl:if>
										<fo:list-block provisional-label-separation="3mm">
											<xsl:attribute name="provisional-distance-between-starts">
												<xsl:choose>
													<xsl:when test="@section != ''">
														<xsl:if test="@level = 1">
															<xsl:choose>
																<xsl:when test="string-length(@section) &gt; 10">27mm</xsl:when>
																<xsl:when test="string-length(@section) &gt; 5">22mm</xsl:when>
																<!-- <xsl:when test="@type = 'annex'">20mm</xsl:when> -->
																<xsl:otherwise>12mm</xsl:otherwise>
															</xsl:choose>
														</xsl:if>
														<xsl:if test="@level = 2">26mm</xsl:if>
													</xsl:when> <!--   -->
													<xsl:otherwise>0mm</xsl:otherwise>
												</xsl:choose>
											</xsl:attribute>
											<fo:list-item>
												<fo:list-item-label end-indent="label-end()">
													<xsl:if test="@level =2">
														<xsl:attribute name="start-indent">12mm</xsl:attribute>
													</xsl:if>
													<fo:block>
														<xsl:if test="@section">															
															<xsl:value-of select="@section"/>
														</xsl:if>
													</fo:block>
												</fo:list-item-label>
													<fo:list-item-body start-indent="body-start()">
														<fo:block text-align-last="justify">															
															<fo:basic-link internal-destination="{@id}" fox:alt-text="text()">
																<xsl:apply-templates/>
																<fo:inline keep-together.within-line="always">
																	<fo:leader leader-pattern="dots"/>
																	<fo:page-number-citation ref-id="{@id}"/>
																</fo:inline>
															</fo:basic-link>
														</fo:block>
													</fo:list-item-body>
											</fo:list-item>
										</fo:list-block>
									</fo:block>									
								</xsl:for-each>
						</fo:block-container>
					</xsl:if>
					
				</fo:flow>
			</fo:page-sequence>
			
			<!-- BODY -->
			<fo:page-sequence master-reference="document" initial-page-number="1" force-page-count="no-force">
				
				<fo:static-content flow-name="xsl-footnote-separator">
					<fo:block>
						<fo:leader leader-pattern="rule" leader-length="30%"/>
					</fo:block>
				</fo:static-content>
				<xsl:call-template name="insertHeaderFooter"/>
				
				<fo:flow flow-name="xsl-region-body">
				
					<fo:block-container font-size="14pt" font-weight="bold">
						<fo:block>
							<xsl:value-of select="$doctype"/>
							<xsl:text> </xsl:text>
							<xsl:value-of select="$docname"/>
						</fo:block>
						<fo:block text-align="center" margin-top="15pt" margin-bottom="15pt">
							<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:title[@type = 'main' and @language = 'en']"/>
						</fo:block>
					</fo:block-container>
				
					
					<!-- Clause(s) -->
					<fo:block>
						<!-- Scope -->
						<xsl:apply-templates select="/itu:itu-standard/itu:sections/itu:clause[1]"/> <!-- @id = 'scope' -->
							
						<!-- Normative references -->						
						<xsl:apply-templates select="/itu:itu-standard/itu:bibliography/itu:references[1]"/> <!-- @id = 'references' -->
							
						<xsl:apply-templates select="/itu:itu-standard/itu:sections/*[position() != 1]"/> <!-- @id != 'scope' -->
							
						<xsl:apply-templates select="/itu:itu-standard/itu:annex"/>
						
						<!-- Bibliography -->
						<xsl:apply-templates select="/itu:itu-standard/itu:bibliography/itu:references[position() != 1]"/> <!-- @id = 'bibliography' -->
					</fo:block>
					
				</fo:flow>
			</fo:page-sequence>
			
			
		</fo:root>
	</xsl:template> 

	<xsl:template match="node()">		
		<xsl:apply-templates/>			
	</xsl:template>
	
	<!-- ============================= -->
	<!-- CONTENTS                                       -->
	<!-- ============================= -->
	<xsl:template match="node()" mode="contents">
		<xsl:apply-templates mode="contents"/>			
	</xsl:template>
	
	<!-- element with title -->
	<xsl:template match="*[itu:title]" mode="contents">
		<xsl:variable name="level">
			<xsl:call-template name="getLevel">
				<xsl:with-param name="depth" select="itu:title/@depth"/>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="section">
			<xsl:call-template name="getSection"/>
		</xsl:variable>
		
		<xsl:variable name="type">
			<xsl:value-of select="local-name()"/>
		</xsl:variable>
			
		<xsl:variable name="display">
			<xsl:choose>
				<xsl:when test="ancestor-or-self::itu:bibitem">false</xsl:when>
				<xsl:when test="ancestor-or-self::itu:term">false</xsl:when>
				<xsl:when test="$level &gt;= 3">false</xsl:when>
				<xsl:when test="$section = '' and $type = 'clause' and $level &gt;= 2">false</xsl:when>
				<xsl:otherwise>true</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="$display = 'true'">		
			
			<xsl:variable name="title">
				<xsl:call-template name="getName"/>
			</xsl:variable>
			
			<item level="{$level}" section="{$section}" type="{$type}">
				<xsl:call-template name="setId"/>
				<xsl:apply-templates select="xalan:nodeset($title)" mode="contents_item"/>
			</item>
			<xsl:apply-templates mode="contents"/>
		</xsl:if>	
		
	</xsl:template>

	<xsl:template match="itu:strong" mode="contents_item" priority="2">
		<xsl:apply-templates mode="contents_item"/>
	</xsl:template>
	
	<xsl:template match="itu:br" mode="contents_item" priority="2">
		<fo:inline> </fo:inline>
	</xsl:template>
	

	
	<xsl:template match="itu:bibitem" mode="contents"/>

	<xsl:template match="itu:references" mode="contents">
		<xsl:apply-templates mode="contents"/>			
	</xsl:template>



	<xsl:template name="getListItemFormat">
		<xsl:variable name="level">
			<xsl:variable name="numtmp">
				<xsl:number level="multiple" count="itu:ol"/>
			</xsl:variable>
			<!-- level example: 1.1 
				calculate counts of '.' in numtmp value - level of nested lists
			-->
			<xsl:value-of select="string-length($numtmp) - string-length(translate($numtmp, '.', '')) + 1"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="local-name(..) = 'ul' and itu:ul and local-name(../../..) != 'ul'">•</xsl:when> <!-- dash &#x2014; -->
			<xsl:when test="local-name(..) = 'ul'">–</xsl:when> <!-- dash &#x2014; -->
			<xsl:otherwise>
				<!-- for Ordered Lists -->
				<xsl:choose>
					<xsl:when test="../@type = 'arabic'">
						<xsl:number format="a)"/>
					</xsl:when>
					<xsl:when test="../@class = 'steps'">
						<xsl:number format="1)"/>
					</xsl:when>
					<xsl:when test="$level = 1">
						<xsl:number format="a)"/>
					</xsl:when>
					<xsl:when test="$level = 2">
						<xsl:number format="i)"/>
					</xsl:when>
					<xsl:otherwise>
						<!-- <xsl:number format="1.)"/> -->
						<!-- https://github.com/metanorma/mn-native-pdf/issues/156 -->
						<xsl:number format="1)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<!-- ============================= -->
	<!-- ============================= -->

	
	<!-- ============================= -->
	<!-- PREFACE (Summary, History, ...)          -->
	<!-- ============================= -->
	
	<!-- Summary -->
	<xsl:template match="itu:itu-standard/itu:preface/itu:abstract[@id = '_summary']" priority="3">
		<fo:block font-size="12pt">
			<xsl:value-of select="$linebreak"/>
			<xsl:value-of select="$linebreak"/>
		</fo:block>
		<fo:block font-weight="bold" margin-top="18pt" margin-bottom="18pt">			
			<xsl:variable name="title-summary">
				<xsl:call-template name="getTitle">
					<xsl:with-param name="name" select="'title-summary'"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:value-of select="$title-summary"/>
		</fo:block>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="itu:preface/itu:clause" priority="3">
		<fo:block font-size="12pt">
			<xsl:value-of select="$linebreak"/>
			<xsl:value-of select="$linebreak"/>
		</fo:block>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="itu:preface//itu:title" priority="3">
		<fo:block font-weight="bold" margin-top="18pt" margin-bottom="18pt">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	<!-- ============================= -->
	<!-- ============================= -->
	
	
	<!-- ============================= -->
	<!-- PARAGRAPHS                                    -->
	<!-- ============================= -->	
	<xsl:template match="itu:p | itu:sections/itu:p">
		<fo:block margin-top="6pt">
			<xsl:attribute name="text-align">
				<xsl:choose>
					<xsl:when test="@align"><xsl:value-of select="@align"/></xsl:when>
					<xsl:when test="ancestor::*[1][local-name() = 'td']/@align">
						<xsl:value-of select="ancestor::*[1][local-name() = 'td']/@align"/>
					</xsl:when>
					<xsl:when test="ancestor::*[1][local-name() = 'th']/@align">
						<xsl:value-of select="ancestor::*[1][local-name() = 'th']/@align"/>
					</xsl:when>
					<xsl:otherwise>justify</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates/>				
		</fo:block>
	</xsl:template>

<!-- 	<xsl:template match="itu:note">
		<fo:block id="{@id}">
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>
	
	<xsl:template match="itu:note/itu:p" name="note">		
		<fo:block font-size="11pt" space-before="4pt" text-align="justify">
			<xsl:if test="ancestor::itu:figure">
				<xsl:attribute name="keep-with-previous">always</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="../itu:name" mode="presentation"/>			
			<xsl:apply-templates />
		</fo:block>
	</xsl:template> -->
	
	
	<!-- ============================= -->
	<!-- ============================= -->
	
	
	<!-- ============================= -->
	<!-- Bibliography -->
	<!-- ============================= -->
	
	<!-- Example: [ITU-T A.23]	ITU-T A.23, Recommendation ITU-T A.23, Annex A (2014), Guide for ITU-T and ISO/IEC JTC 1 cooperation. -->
	<xsl:template match="itu:bibitem">
		<fo:block id="{@id}" margin-top="6pt" margin-left="14mm" text-indent="-14mm">
		
			<xsl:choose>
				<xsl:when test="itu:docidentifier[@type = 'metanorma']">
					<xsl:value-of select="itu:docidentifier[@type = 'metanorma']"/>
					<xsl:text> </xsl:text>
					<xsl:if test="itu:docidentifier[not(@type) or not(@type = 'metanorma')]">
						<xsl:value-of select="itu:docidentifier[not(@type) or not(@type = 'metanorma')]"/>
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<fo:inline padding-right="5mm">
						<xsl:text>[</xsl:text>
							<xsl:value-of select="itu:docidentifier"/>
						<xsl:text>] </xsl:text>
					</fo:inline>
					<xsl:value-of select="itu:docidentifier"/>
					<xsl:if test="itu:title">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
			
			<xsl:if test="itu:title">
				<fo:inline font-style="italic">
						<xsl:choose>
							<xsl:when test="itu:title[@type = 'main' and @language = 'en']">
								<xsl:value-of select="itu:title[@type = 'main' and @language = 'en']"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="itu:title"/>
							</xsl:otherwise>
						</xsl:choose>
					</fo:inline>
				</xsl:if>
				<xsl:if test="itu:formattedref and not(itu:docidentifier[@type = 'metanorma'])">, </xsl:if>
				<xsl:apply-templates select="itu:formattedref"/>
			</fo:block>
	</xsl:template>
	<xsl:template match="itu:bibitem/itu:docidentifier"/>
	
	<xsl:template match="itu:bibitem/itu:title"/>
	
	<xsl:template match="itu:formattedref">
		<xsl:apply-templates/>
	</xsl:template>
	
	
	<!-- ============================= -->
	<!-- ============================= -->
	
	

	<xsl:template match="itu:clause[@id='draft-warning']/itu:title" mode="caution">
		<fo:block font-size="16pt" font-family="Times New Roman" font-style="italic" font-weight="bold" text-align="center">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="itu:clause[@id='draft-warning']/itu:p" mode="caution">
		<fo:block font-size="12pt" font-family="Times New Roman" text-align="justify">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<!-- ====== -->
	<!-- title      -->
	<!-- ====== -->	
	<xsl:template match="itu:annex/itu:title">
		<fo:block font-size="14pt" font-weight="bold" text-align="center" margin-bottom="18pt">			
			<fo:block><xsl:apply-templates/></fo:block>
			<fo:block font-size="12pt" font-weight="normal" margin-top="6pt">
				<xsl:choose>
					<xsl:when test="parent::*[@obligation = 'informative']">
						<xsl:text>(This appendix does not form an integral part of this Recommendation.)</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>(This annex forms an integral part of this Recommendation.)</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</fo:block>
		</fo:block>
	</xsl:template>
	
	<!-- Bibliography -->
	<xsl:template match="itu:references[not(@normative='true')]/itu:title">
		<fo:block font-size="14pt" font-weight="bold" text-align="center" margin-bottom="18pt">
				<xsl:apply-templates/>
			</fo:block>
	</xsl:template>
	
	<xsl:template match="itu:title">
		
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		
		<xsl:variable name="font-size">
			<xsl:choose>
				<xsl:when test="$level = 2">12pt</xsl:when>
				<xsl:when test="$level &gt;= 3">12pt</xsl:when>
				<xsl:otherwise>12pt</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="space-before">
			<xsl:choose>
					<xsl:when test="$level = '' or $level = 1">18pt</xsl:when>
					<xsl:when test="$level = 2">12pt</xsl:when>
					<xsl:otherwise>6pt</xsl:otherwise>
				</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="space-after">
			<xsl:choose>
				<xsl:when test="$level = 2">6pt</xsl:when>
				<xsl:otherwise>6pt</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<fo:block font-size="{$font-size}" font-weight="bold" space-before="{$space-before}" space-after="{$space-after}" keep-with-next="always">			
			<xsl:apply-templates/>
		</fo:block>
			
	</xsl:template>
	
	
	<xsl:template match="itu:legal-statement//itu:title | itu:license-statement//itu:title">
		<fo:block text-align="center" margin-top="6pt">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<!-- ====== -->
	<!-- ====== -->
	
	<xsl:template match="itu:legal-statement//itu:p | itu:license-statement//itu:p">
		<fo:block margin-top="6pt">
			<xsl:apply-templates/>
		</fo:block>
		<xsl:if test="not(following-sibling::itu:p)"> <!-- last para -->
			<fo:block margin-top="6pt"> </fo:block>
			<fo:block margin-top="6pt"> </fo:block>
			<fo:block margin-top="6pt"> </fo:block>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="itu:copyright-statement//itu:p">
		<fo:block>
			<xsl:if test="not(preceding-sibling::itu:p)"> <!-- first para -->
				<xsl:attribute name="text-align">center</xsl:attribute>
				<xsl:attribute name="margin-top">6pt</xsl:attribute>
				<xsl:attribute name="margin-bottom">14pt</xsl:attribute>
				<xsl:attribute name="keep-with-next">always</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	
	<xsl:template match="itu:preferred">		
		<!-- DEBUG need -->
		<fo:block space-before="6pt" text-align="justify">
			<fo:inline padding-right="5mm" font-weight="bold">				
				<xsl:variable name="level">
					<xsl:call-template name="getLevel"/>
				</xsl:variable>
				<!-- level=<xsl:value-of select="$level"/> -->
				<xsl:attribute name="padding-right">
					<xsl:choose>
						<xsl:when test="$level = 4">2mm</xsl:when>
						<xsl:when test="$level = 3">4mm</xsl:when>
						<xsl:otherwise>5mm</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:apply-templates select="ancestor::itu:term/itu:name" mode="presentation"/>
			</fo:inline>
			<fo:inline font-weight="bold">
				<xsl:apply-templates/>
			</fo:inline>
			<xsl:if test="../itu:termsource/itu:origin">
				<xsl:variable name="citeas" select="../itu:termsource/itu:origin/@citeas"/>
				<xsl:choose>
					<xsl:when test="contains($citeas, '[')">
						<xsl:text> </xsl:text><xsl:value-of select="$citeas"/> <!--  disable-output-escaping="yes" -->
					</xsl:when>
					<xsl:otherwise>
						<xsl:text> [</xsl:text><xsl:value-of select="$citeas"/><xsl:text>]</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:text>: </xsl:text>
			<xsl:apply-templates select="following-sibling::itu:definition/node()" mode="process"/>			
		</fo:block>
		<!-- <xsl:if test="following-sibling::itu:table">
			<fo:block space-after="18pt">&#xA0;</fo:block>
		</xsl:if> -->
	</xsl:template>
	
	<xsl:template match="itu:definition/itu:p" priority="2"/>
	<xsl:template match="itu:definition/itu:formula" priority="2"/>
	
	<xsl:template match="itu:definition/itu:p" mode="process" priority="2">
		<xsl:choose>
			<xsl:when test="position() = 1">
				<fo:inline>
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:block margin-top="6pt" text-align="justify">
					<xsl:apply-templates/>						
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:variable name="p_fn">
		<xsl:for-each select="//itu:p/itu:fn[generate-id(.)=generate-id(key('kfn',@reference)[1])]">
			<!-- copy unique fn -->
			<fn gen_id="{generate-id(.)}">
				<xsl:copy-of select="@*"/>
				<xsl:copy-of select="node()"/>
			</fn>
		</xsl:for-each>
	</xsl:variable>
	
	<xsl:template match="itu:p/itu:fn" priority="2">
		<xsl:variable name="gen_id" select="generate-id(.)"/>
		<xsl:variable name="reference" select="@reference"/>
		<xsl:variable name="number">
			<!-- <xsl:number level="any" count="itu:p/itu:fn"/> -->
			<xsl:value-of select="count(xalan:nodeset($p_fn)//fn[@reference = $reference]/preceding-sibling::fn) + 1"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="xalan:nodeset($p_fn)//fn[@gen_id = $gen_id]">
				<fo:footnote>
					<fo:inline font-size="60%" keep-with-previous.within-line="always" vertical-align="super">
						<fo:basic-link internal-destination="footnote_{@reference}_{$number}" fox:alt-text="footnote {@reference} {$number}">
							<!-- <xsl:value-of select="@reference"/> -->
							<xsl:value-of select="$number + count(//itu:bibitem/itu:note)"/>
						</fo:basic-link>
					</fo:inline>
					<fo:footnote-body>
						<fo:block font-size="11pt" margin-bottom="12pt">
							<fo:inline id="footnote_{@reference}_{$number}" font-size="85%" padding-right="2mm" keep-with-next.within-line="always" baseline-shift="30%">
								<xsl:value-of select="$number + count(//itu:bibitem/itu:note)"/>
							</fo:inline>
							<xsl:for-each select="itu:p">
									<xsl:apply-templates/>
							</xsl:for-each>
						</fo:block>
					</fo:footnote-body>
				</fo:footnote>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline font-size="60%" keep-with-previous.within-line="always" vertical-align="super">
					<fo:basic-link internal-destination="footnote_{@reference}_{$number}" fox:alt-text="footnote {@reference} {$number}">
						<xsl:value-of select="$number + count(//itu:bibitem/itu:note)"/>
					</fo:basic-link>
				</fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<xsl:template match="*[local-name()='tt']" priority="2">
		<xsl:variable name="element-name">
			<xsl:choose>
				<xsl:when test="ancestor::itu:dd">fo:inline</xsl:when>
				<xsl:when test="normalize-space(ancestor::itu:p[1]//text()[not(parent::itu:tt)]) != ''">fo:inline</xsl:when>
				<xsl:otherwise>fo:block</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="{$element-name}">
			<xsl:attribute name="font-family">Courier</xsl:attribute>
			<xsl:attribute name="font-size">10pt</xsl:attribute>
			<xsl:if test="local-name(..) != 'dt' and not(ancestor::itu:dd)">
				<xsl:attribute name="text-align">center</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

		
	
	<!-- Examples:
	[b-ASM]	b-ASM, http://www.eecs.umich.edu/gasm/ (accessed 20 March 2018).
	[b-Börger & Stärk]	b-Börger & Stärk, Börger, E., and Stärk, R. S. (2003), Abstract State Machines: A Method for High-Level System Design and Analysis, Springer-Verlag.
	-->
	<xsl:template match="itu:annex//itu:bibitem">
		<fo:block margin-top="6pt" margin-left="10mm" text-indent="-10mm">
			<fo:inline id="{@id}" padding-right="5mm">[<xsl:value-of select="itu:docidentifier"/>]</fo:inline>
			<xsl:text> </xsl:text>
			<xsl:apply-templates select="itu:docidentifier" mode="content"/>
			<xsl:if test="node()[local-name(.) != current()/itu:docidentifier]">, </xsl:if>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="itu:docidentifier" mode="content">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="itu:docidentifier"/>
	
	
	<xsl:template match="itu:ul | itu:ol | itu:sections/itu:ul | itu:sections/itu:ol">
		<xsl:if test="preceding-sibling::*[1][local-name() = 'title']">
			<fo:block padding-top="-8pt" font-size="1pt"> </fo:block>
		</xsl:if>
		<fo:list-block>
			<xsl:apply-templates/>
		</fo:list-block>
		<xsl:apply-templates select="./itu:note" mode="process"/>
	</xsl:template>
	
	<xsl:template match="itu:ul//itu:note |  itu:ol//itu:note" priority="2"/>
	<xsl:template match="itu:ul//itu:note  | itu:ol//itu:note" mode="process">
		<fo:block id="{@id}">
			<xsl:apply-templates select="../itu:name" mode="presentation"/>
			<xsl:apply-templates mode="process"/>
		</fo:block>
	</xsl:template>
	<xsl:template match="itu:ul//itu:note/itu:name  | itu:ol//itu:note/itu:name" mode="process"/>
	<xsl:template match="itu:ul//itu:note/itu:p  | itu:ol//itu:note/itu:p" mode="process">		
		<fo:block font-size="11pt" margin-top="4pt">			
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="itu:li">
		<fo:list-item id="{@id}">
			<fo:list-item-label end-indent="label-end()">
				<fo:block>
					<xsl:call-template name="getListItemFormat"/>
				</fo:block>
			</fo:list-item-label>
			<fo:list-item-body start-indent="body-start()">
				<fo:block-container>
					<xsl:if test="../preceding-sibling::*[1][local-name() = 'title']">
						<xsl:attribute name="margin-left">18mm</xsl:attribute>
					</xsl:if>
					<xsl:if test="local-name(..) = 'ul'">
						<xsl:attribute name="margin-left">7mm</xsl:attribute><!-- 15mm -->
						<xsl:if test="ancestor::itu:table">
							<xsl:attribute name="margin-left">4.5mm</xsl:attribute>
						</xsl:if>
						<!-- <xsl:if test="count(ancestor::itu:ol) + count(ancestor::itu:ul) &gt; 1">
							<xsl:attribute name="margin-left">7mm</xsl:attribute>
						</xsl:if> -->
					</xsl:if>
					<fo:block-container margin-left="0mm">
						<fo:block>
							<xsl:apply-templates/>
							<xsl:apply-templates select=".//itu:note" mode="process"/>
						</fo:block>
					</fo:block-container>
				</fo:block-container>
			</fo:list-item-body>
		</fo:list-item>
	</xsl:template>
	
	<xsl:template match="itu:li//itu:p[not(parent::itu:dd)]">
		<fo:block margin-bottom="0pt"> <!-- margin-bottom="6pt" -->
			<!-- <xsl:if test="local-name(ancestor::itu:li[1]/..) = 'ul'">
				<xsl:attribute name="margin-bottom">0pt</xsl:attribute>
			</xsl:if> -->
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="itu:link" priority="2">
		<fo:inline color="blue">
			<xsl:if test="local-name(..) = 'formattedref' or ancestor::itu:preface">
				<xsl:attribute name="text-decoration">underline</xsl:attribute>
				<!-- <xsl:attribute name="font-family">Arial</xsl:attribute>
				<xsl:attribute name="font-size">8pt</xsl:attribute> -->
			</xsl:if>
			<xsl:call-template name="link"/>
		</fo:inline>
	</xsl:template>
	

<!-- 	
	<xsl:template match="itu:annex/itu:clause">
		<xsl:apply-templates />
	</xsl:template> -->
	
	<!-- Clause without title -->
<!-- 	<xsl:template match="itu:clause[not(itu:title)]">
		
		<xsl:variable name="section">
			<xsl:for-each select="*[1]">
				<xsl:call-template name="getSection">
					<xsl:with-param name="sectionNum" select="$sectionNum"/>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:variable>
		<fo:block space-before="12pt" space-after="18pt" font-weight="bold">
			<fo:inline id="{@id}"><xsl:value-of select="$section"/></fo:inline>
		</fo:block>
		<xsl:apply-templates />			
	</xsl:template> -->

	
	<xsl:template match="itu:formula/itu:stem">
		<fo:table table-layout="fixed" width="100%">
			<fo:table-column column-width="95%"/>
			<fo:table-column column-width="5%"/>
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell display-align="center">
						<fo:block text-align="center" margin-left="0mm">
							<xsl:apply-templates/>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell display-align="center">
						<fo:block text-align="right" margin-left="0mm">							
							<xsl:apply-templates select="../itu:name" mode="presentation"/>							
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
	</xsl:template>
	
	
	<xsl:template match="itu:formula" mode="process">
		<xsl:call-template name="formula"/>			
	</xsl:template>
	
	<xsl:template match="mathml:math" priority="2">
		<fo:inline font-family="STIX2Math" font-size="11pt">
			<fo:instream-foreign-object fox:alt-text="Math"> 
				<xsl:copy-of select="."/>
			</fo:instream-foreign-object>
		</fo:inline>
	</xsl:template>
	
	
	<xsl:template match="itu:references[@normative='true']">
		<fo:block id="{@id}">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
		
	<xsl:template match="itu:references[not(@normative='true')]">
		<fo:block break-after="page"/>
		<fo:block id="{@id}">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	
		
	<xsl:template name="insertHeaderFooter">
		<fo:static-content flow-name="footer-even" font-family="Times New Roman" font-size="11pt">
			<fo:block-container height="19mm" display-align="after">
				<fo:table table-layout="fixed" width="100%" display-align="after">
					<fo:table-column column-width="10%"/>
					<fo:table-column column-width="90%"/>
					<fo:table-body>
						<fo:table-row>
							<fo:table-cell text-align="left" padding-bottom="8mm">
								<fo:block><fo:page-number/></fo:block>
							</fo:table-cell>
							<fo:table-cell font-weight="bold" text-align="left" padding-bottom="8mm">
								<fo:block>
									<xsl:value-of select="concat($footerprefix, $docname, ' ', $docdate)"/>
								</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table>
			</fo:block-container>
		</fo:static-content>
		<fo:static-content flow-name="footer-odd" font-family="Times New Roman" font-size="11pt">
			<fo:block-container height="19mm" display-align="after">
				<fo:table table-layout="fixed" width="100%" display-align="after">
					<fo:table-column column-width="90%"/>
					<fo:table-column column-width="10%"/>
					<fo:table-body>
						<fo:table-row>
							<fo:table-cell font-weight="bold" text-align="right" padding-bottom="8mm">
								<fo:block>
									<xsl:value-of select="concat($footerprefix, $docname, ' ', $docdate)"/>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell text-align="right" padding-bottom="8mm" padding-right="2mm">
								<fo:block><fo:page-number/></fo:block>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table>
			</fo:block-container>
		</fo:static-content>
	</xsl:template>

	
	<xsl:variable name="Image-Fond-Rec">
		<xsl:text>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</xsl:text>
	</xsl:variable>
	
	<xsl:variable name="Image-Logo">
		<xsl:text>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</xsl:text>
	</xsl:variable>
	
	<!-- convert YYYY-MM-DD to (MM/YYYY) -->
	<xsl:template name="formatDate">
		<xsl:param name="date"/>
		<xsl:variable name="year" select="substring($date, 1, 4)"/>
		<xsl:variable name="month" select="substring($date, 6, 2)"/>
		<xsl:if test="$month != '' and $year != ''">
			<xsl:text>(</xsl:text><xsl:value-of select="$month"/>/<xsl:value-of select="$year"/><xsl:text>)</xsl:text>
		</xsl:if>
	</xsl:template>
	

	<xsl:template name="addLetterSpacing">
		<xsl:param name="text"/>
		<xsl:if test="string-length($text) &gt; 0">
			<xsl:variable name="char" select="substring($text, 1, 1)"/>
			<xsl:value-of select="$char"/><fo:inline font-size="15pt"><xsl:value-of select="' '"/></fo:inline>
			<xsl:call-template name="addLetterSpacing">
				<xsl:with-param name="text" select="substring($text, 2)"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
<xsl:variable name="titles" select="xalan:nodeset($titles_)"/><xsl:variable name="titles_">
				
		<title-annex lang="en">Annex </title-annex>
		<title-annex lang="fr">Annexe </title-annex>
		
			<title-annex lang="zh">Annex </title-annex>
		
		
				
		<title-edition lang="en">
			
				<xsl:text>Edition </xsl:text>
			
			
		</title-edition>
		

		<title-toc lang="en">
			
			
				<xsl:text>Table of Contents</xsl:text>
			
			
		</title-toc>
		<title-toc lang="fr">Sommaire</title-toc>
		
			<title-toc lang="zh">Contents</title-toc>
		
		
		
		<title-page lang="en">Page</title-page>
		<title-page lang="fr">Page</title-page>
		
		<title-key lang="en">Key</title-key>
		<title-key lang="fr">Légende</title-key>
			
		<title-where lang="en">where</title-where>
		<title-where lang="fr">où</title-where>
					
		<title-descriptors lang="en">Descriptors</title-descriptors>
		
		<title-part lang="en">
			
			
		</title-part>
		<title-part lang="fr">
			
			
		</title-part>		
		<title-part lang="zh">第 # 部分:</title-part>
		
		<title-modified lang="en">modified</title-modified>
		<title-modified lang="fr">modifiée</title-modified>
		
			<title-modified lang="zh">modified</title-modified>
		
		
		
		<title-source lang="en">SOURCE</title-source>
		
		<title-keywords lang="en">Keywords</title-keywords>
		
		<title-deprecated lang="en">DEPRECATED</title-deprecated>
		<title-deprecated lang="fr">DEPRECATED</title-deprecated>
				
		<title-list-tables lang="en">List of Tables</title-list-tables>
		
		<title-list-figures lang="en">List of Figures</title-list-figures>
		
		<title-list-recommendations lang="en">List of Recommendations</title-list-recommendations>
		
		<title-acknowledgements lang="en">Acknowledgements</title-acknowledgements>
		
		<title-abstract lang="en">Abstract</title-abstract>
		
		<title-summary lang="en">Summary</title-summary>
		
		<title-in lang="en">in </title-in>
		
		<title-partly-supercedes lang="en">Partly Supercedes </title-partly-supercedes>
		<title-partly-supercedes lang="zh">部分代替 </title-partly-supercedes>
		
		<title-completion-date lang="en">Completion date for this manuscript</title-completion-date>
		<title-completion-date lang="zh">本稿完成日期</title-completion-date>
		
		<title-issuance-date lang="en">Issuance Date: #</title-issuance-date>
		<title-issuance-date lang="zh"># 发布</title-issuance-date>
		
		<title-implementation-date lang="en">Implementation Date: #</title-implementation-date>
		<title-implementation-date lang="zh"># 实施</title-implementation-date>

		<title-obligation-normative lang="en">normative</title-obligation-normative>
		<title-obligation-normative lang="zh">规范性附录</title-obligation-normative>
		
		<title-caution lang="en">CAUTION</title-caution>
		<title-caution lang="zh">注意</title-caution>
			
		<title-warning lang="en">WARNING</title-warning>
		<title-warning lang="zh">警告</title-warning>
		
		<title-amendment lang="en">AMENDMENT</title-amendment>
	</xsl:variable><xsl:variable name="tab_zh">　</xsl:variable><xsl:template name="getTitle">
		<xsl:param name="name"/>
		<xsl:variable name="lang">
			<xsl:call-template name="getLang"/>
		</xsl:variable>
		<xsl:variable name="title_" select="$titles/*[local-name() = $name][@lang = $lang]"/>
		<xsl:choose>
			<xsl:when test="normalize-space($title_) != ''">
				<xsl:value-of select="$title_"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$titles/*[local-name() = $name][@lang = 'en']"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable><xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable><xsl:variable name="en_chars" select="concat($lower,$upper,',.`1234567890-=~!@#$%^*()_+[]{}\|?/')"/><xsl:variable name="linebreak" select="'&#8232;'"/><xsl:attribute-set name="link-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="sourcecode-style">
		<xsl:attribute name="white-space">pre</xsl:attribute>
		<xsl:attribute name="wrap-option">wrap</xsl:attribute>
		
		
		
		
		
			<xsl:attribute name="font-family">Courier</xsl:attribute>
			<xsl:attribute name="font-size">10pt</xsl:attribute>
			<xsl:attribute name="margin-top">6pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
		
				
		
		
	</xsl:attribute-set><xsl:attribute-set name="permission-style">
		
	</xsl:attribute-set><xsl:attribute-set name="permission-name-style">
		
	</xsl:attribute-set><xsl:attribute-set name="permission-label-style">
		
	</xsl:attribute-set><xsl:attribute-set name="requirement-style">
		
	</xsl:attribute-set><xsl:attribute-set name="requirement-name-style">
		
	</xsl:attribute-set><xsl:attribute-set name="requirement-label-style">
		
	</xsl:attribute-set><xsl:attribute-set name="requirement-subject-style">
	</xsl:attribute-set><xsl:attribute-set name="requirement-inherit-style">
	</xsl:attribute-set><xsl:attribute-set name="recommendation-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="recommendation-name-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="recommendation-label-style">
		
	</xsl:attribute-set><xsl:attribute-set name="termexample-style">
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="example-style">
		
		
		
		
		
			<xsl:attribute name="font-size">10pt</xsl:attribute>
			<xsl:attribute name="margin-top">12pt</xsl:attribute>			
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="example-body-style">
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="example-name-style">
		
		
		
		
		
		
			<xsl:attribute name="font-weight">bold</xsl:attribute>
		
		
		
		
		
		
		
		
				
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="example-p-style">
		
		
		
		
		
			<xsl:attribute name="font-size">10pt</xsl:attribute>
			<xsl:attribute name="margin-top">12pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="termexample-name-style">
		
		
		
				
	</xsl:attribute-set><xsl:attribute-set name="table-name-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
		
			<xsl:attribute name="font-weight">bold</xsl:attribute>
			<xsl:attribute name="text-align">center</xsl:attribute>
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
		
		
		
		
				
		
		
		
				
		
		
	</xsl:attribute-set><xsl:attribute-set name="appendix-style">
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="appendix-example-style">
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="xref-style">
		
		
			<xsl:attribute name="color">blue</xsl:attribute>
			<xsl:attribute name="text-decoration">underline</xsl:attribute>
				
	</xsl:attribute-set><xsl:attribute-set name="eref-style">
		
		
			<xsl:attribute name="color">blue</xsl:attribute>
			<xsl:attribute name="text-decoration">underline</xsl:attribute>
		
		
	</xsl:attribute-set><xsl:attribute-set name="note-style">
		
		
		
				
		
		
		
			<xsl:attribute name="font-size">11pt</xsl:attribute>
			<xsl:attribute name="space-before">4pt</xsl:attribute>
			<xsl:attribute name="text-align">justify</xsl:attribute>		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="note-name-style">
		
		
		
		
		
		
		
		
		
				
		
	</xsl:attribute-set><xsl:attribute-set name="note-p-style">
		
		
		
				
		
		
					
			<xsl:attribute name="space-before">4pt</xsl:attribute>			
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="termnote-style">
		
		
		
					
			<xsl:attribute name="margin-top">4pt</xsl:attribute>			
		
		
	</xsl:attribute-set><xsl:attribute-set name="quote-style">		
		
		
		
		
		
			<xsl:attribute name="margin-top">6pt</xsl:attribute>
			<xsl:attribute name="margin-left">12mm</xsl:attribute>
			<xsl:attribute name="margin-right">12mm</xsl:attribute>
		
		
	</xsl:attribute-set><xsl:attribute-set name="quote-source-style">		
		
		
			<xsl:attribute name="text-align">right</xsl:attribute>			
				
				
	</xsl:attribute-set><xsl:attribute-set name="termsource-style">
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="origin-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="term-style">
		
	</xsl:attribute-set><xsl:attribute-set name="figure-name-style">
				
		
		
		
		
		
					
			<xsl:attribute name="font-weight">bold</xsl:attribute>
			<xsl:attribute name="text-align">center</xsl:attribute>
			<xsl:attribute name="margin-top">6pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
			<xsl:attribute name="keep-with-previous">always</xsl:attribute>
		
		
		
		
		
		
		
		
		
			
	</xsl:attribute-set><xsl:attribute-set name="formula-style">
		
			<xsl:attribute name="margin-top">6pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>			
		
	</xsl:attribute-set><xsl:attribute-set name="image-style">
		<xsl:attribute name="text-align">center</xsl:attribute>
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="figure-pseudocode-p-style">
		
			<xsl:attribute name="font-size">10pt</xsl:attribute>
			<xsl:attribute name="margin-top">6pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
		
	</xsl:attribute-set><xsl:attribute-set name="image-graphic-style">
		
		
		
		
			<xsl:attribute name="width">75%</xsl:attribute>
			<xsl:attribute name="content-height">100%</xsl:attribute>
			<xsl:attribute name="content-width">scale-to-fit</xsl:attribute>
			<xsl:attribute name="scaling">uniform</xsl:attribute>			
				

	</xsl:attribute-set><xsl:attribute-set name="tt-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="sourcecode-name-style">
		<xsl:attribute name="font-size">11pt</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="text-align">center</xsl:attribute>
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="domain-style">
				
	</xsl:attribute-set><xsl:attribute-set name="admitted-style">
		
	
	</xsl:attribute-set><xsl:attribute-set name="deprecates-style">
		
	</xsl:attribute-set><xsl:attribute-set name="definition-style">
		
		
	</xsl:attribute-set><xsl:template name="processPrefaceSectionsDefault_Contents">
		<xsl:apply-templates select="/*/*[local-name()='preface']/*[local-name()='abstract']" mode="contents"/>
		<xsl:apply-templates select="/*/*[local-name()='preface']/*[local-name()='foreword']" mode="contents"/>
		<xsl:apply-templates select="/*/*[local-name()='preface']/*[local-name()='introduction']" mode="contents"/>
		<xsl:apply-templates select="/*/*[local-name()='preface']/*[local-name() != 'abstract' and local-name() != 'foreword' and local-name() != 'introduction' and local-name() != 'acknowledgements']" mode="contents"/>
		<xsl:apply-templates select="/*/*[local-name()='preface']/*[local-name()='acknowledgements']" mode="contents"/>
	</xsl:template><xsl:template name="processMainSectionsDefault_Contents">
		<xsl:apply-templates select="/*/*[local-name()='sections']/*[local-name()='clause'][@type='scope']" mode="contents"/>			
		
		<!-- Normative references  -->
		<xsl:apply-templates select="/*/*[local-name()='bibliography']/*[local-name()='references'][@normative='true']" mode="contents"/>	
		<!-- Terms and definitions -->
		<xsl:apply-templates select="/*/*[local-name()='sections']/*[local-name()='terms'] |                        /*/*[local-name()='sections']/*[local-name()='clause'][.//*[local-name()='terms']] |                       /*/*[local-name()='sections']/*[local-name()='definitions'] |                        /*/*[local-name()='sections']/*[local-name()='clause'][.//*[local-name()='definitions']]" mode="contents"/>		
		<!-- Another main sections -->
		<xsl:apply-templates select="/*/*[local-name()='sections']/*[local-name() != 'terms' and                                                local-name() != 'definitions' and                                                not(@type='scope') and                                               not(local-name() = 'clause' and .//*[local-name()='terms']) and                                               not(local-name() = 'clause' and .//*[local-name()='definitions'])]" mode="contents"/>
		<xsl:apply-templates select="/*/*[local-name()='annex']" mode="contents"/>		
		<!-- Bibliography -->
		<xsl:apply-templates select="/*/*[local-name()='bibliography']/*[local-name()='references'][not(@normative='true')]" mode="contents"/>
	</xsl:template><xsl:template name="processPrefaceSectionsDefault">
		<xsl:apply-templates select="/*/*[local-name()='preface']/*[local-name()='abstract']"/>
		<xsl:apply-templates select="/*/*[local-name()='preface']/*[local-name()='foreword']"/>
		<xsl:apply-templates select="/*/*[local-name()='preface']/*[local-name()='introduction']"/>
		<xsl:apply-templates select="/*/*[local-name()='preface']/*[local-name() != 'abstract' and local-name() != 'foreword' and local-name() != 'introduction' and local-name() != 'acknowledgements']"/>
		<xsl:apply-templates select="/*/*[local-name()='preface']/*[local-name()='acknowledgements']"/>
	</xsl:template><xsl:template name="processMainSectionsDefault">			
		<xsl:apply-templates select="/*/*[local-name()='sections']/*[local-name()='clause'][@type='scope']"/>
		
		<!-- Normative references  -->
		<xsl:apply-templates select="/*/*[local-name()='bibliography']/*[local-name()='references'][@normative='true']"/>
		<!-- Terms and definitions -->
		<xsl:apply-templates select="/*/*[local-name()='sections']/*[local-name()='terms'] |                        /*/*[local-name()='sections']/*[local-name()='clause'][.//*[local-name()='terms']] |                       /*/*[local-name()='sections']/*[local-name()='definitions'] |                        /*/*[local-name()='sections']/*[local-name()='clause'][.//*[local-name()='definitions']]"/>
		<!-- Another main sections -->
		<xsl:apply-templates select="/*/*[local-name()='sections']/*[local-name() != 'terms' and                                                local-name() != 'definitions' and                                                not(@type='scope') and                                               not(local-name() = 'clause' and .//*[local-name()='terms']) and                                               not(local-name() = 'clause' and .//*[local-name()='definitions'])]"/>
		<xsl:apply-templates select="/*/*[local-name()='annex']"/>
		<!-- Bibliography -->
		<xsl:apply-templates select="/*/*[local-name()='bibliography']/*[local-name()='references'][not(@normative='true')]"/>
	</xsl:template><xsl:template match="text()">
		<xsl:value-of select="."/>
	</xsl:template><xsl:template match="*[local-name()='br']">
		<xsl:value-of select="$linebreak"/>
	</xsl:template><xsl:template match="*[local-name()='td']//text() | *[local-name()='th']//text() | *[local-name()='dt']//text() | *[local-name()='dd']//text()" priority="1">
		<!-- <xsl:call-template name="add-zero-spaces"/> -->
		<xsl:call-template name="add-zero-spaces-java"/>
	</xsl:template><xsl:template match="*[local-name()='table']">
	
		<xsl:variable name="simple-table">	
			<xsl:call-template name="getSimpleTable"/>			
		</xsl:variable>
	
		
			<fo:block space-before="18pt"> </fo:block>				
		
		
		
		
			<xsl:apply-templates select="*[local-name()='name']" mode="presentation"/>
		
				
		
			<xsl:call-template name="fn_name_display"/>
		
			
		
		<xsl:variable name="cols-count" select="count(xalan:nodeset($simple-table)//tr[1]/td)"/>
		
		<!-- <xsl:variable name="cols-count">
			<xsl:choose>
				<xsl:when test="*[local-name()='thead']">
					<xsl:call-template name="calculate-columns-numbers">
						<xsl:with-param name="table-row" select="*[local-name()='thead']/*[local-name()='tr'][1]"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="calculate-columns-numbers">
						<xsl:with-param name="table-row" select="*[local-name()='tbody']/*[local-name()='tr'][1]"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable> -->
		<!-- cols-count=<xsl:copy-of select="$cols-count"/> -->
		<!-- cols-count2=<xsl:copy-of select="$cols-count2"/> -->
		
		
		
		<xsl:variable name="colwidths">
			<xsl:call-template name="calculate-column-widths">
				<xsl:with-param name="cols-count" select="$cols-count"/>
				<xsl:with-param name="table" select="$simple-table"/>
			</xsl:call-template>
		</xsl:variable>
		
		<!-- <xsl:variable name="colwidths2">
			<xsl:call-template name="calculate-column-widths">
				<xsl:with-param name="cols-count" select="$cols-count"/>
			</xsl:call-template>
		</xsl:variable> -->
		
		<!-- cols-count=<xsl:copy-of select="$cols-count"/>
		colwidthsNew=<xsl:copy-of select="$colwidths"/>
		colwidthsOld=<xsl:copy-of select="$colwidths2"/>z -->
		
		<xsl:variable name="margin-left">
			<xsl:choose>
				<xsl:when test="sum(xalan:nodeset($colwidths)//column) &gt; 75">15</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<fo:block-container margin-left="-{$margin-left}mm" margin-right="-{$margin-left}mm">			
			
				<xsl:attribute name="space-after">6pt</xsl:attribute>
			
			
			
			
			
				<xsl:attribute name="margin-left">0mm</xsl:attribute>
				<xsl:attribute name="margin-right">0mm</xsl:attribute>
				<xsl:attribute name="space-after">18pt</xsl:attribute>
			
			
			
			
			
			<fo:table id="{@id}" table-layout="fixed" width="100%" margin-left="{$margin-left}mm" margin-right="{$margin-left}mm" table-omit-footer-at-break="true">
				
				
				
					<xsl:attribute name="margin-left">0mm</xsl:attribute>
					<xsl:attribute name="margin-right">0mm</xsl:attribute>
				
				
				
				
				
				
				
					<xsl:attribute name="font-size">10pt</xsl:attribute>
				
				
				
				
				<xsl:for-each select="xalan:nodeset($colwidths)//column">
					<xsl:choose>
						<xsl:when test=". = 1 or . = 0">
							<fo:table-column column-width="proportional-column-width(2)"/>
						</xsl:when>
						<xsl:otherwise>
							<fo:table-column column-width="proportional-column-width({.})"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
				
				<xsl:choose>
					<xsl:when test="not(*[local-name()='tbody']) and *[local-name()='thead']">
						<xsl:apply-templates select="*[local-name()='thead']" mode="process_tbody"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates/>
					</xsl:otherwise>
				</xsl:choose>
				
			</fo:table>
			
			
			
			
			
		</fo:block-container>
	</xsl:template><xsl:template match="*[local-name()='table']/*[local-name() = 'name']"/><xsl:template match="*[local-name()='table']/*[local-name() = 'name']" mode="presentation">
		<xsl:if test="normalize-space() != ''">
			<fo:block xsl:use-attribute-sets="table-name-style">
				<xsl:apply-templates/>
			</fo:block>			
		</xsl:if>
	</xsl:template><xsl:template name="calculate-columns-numbers">
		<xsl:param name="table-row"/>
		<xsl:variable name="columns-count" select="count($table-row/*)"/>
		<xsl:variable name="sum-colspans" select="sum($table-row/*/@colspan)"/>
		<xsl:variable name="columns-with-colspan" select="count($table-row/*[@colspan])"/>
		<xsl:value-of select="$columns-count + $sum-colspans - $columns-with-colspan"/>
	</xsl:template><xsl:template name="calculate-column-widths">
		<xsl:param name="table"/>
		<xsl:param name="cols-count"/>
		<xsl:param name="curr-col" select="1"/>
		<xsl:param name="width" select="0"/>
		
		<xsl:if test="$curr-col &lt;= $cols-count">
			<xsl:variable name="widths">
				<xsl:choose>
					<xsl:when test="not($table)"><!-- this branch is not using in production, for debug only -->
						<xsl:for-each select="*[local-name()='thead']//*[local-name()='tr']">
							<xsl:variable name="words">
								<xsl:call-template name="tokenize">
									<xsl:with-param name="text" select="translate(*[local-name()='th'][$curr-col],'- —:', '    ')"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:variable name="max_length">
								<xsl:call-template name="max_length">
									<xsl:with-param name="words" select="xalan:nodeset($words)"/>
								</xsl:call-template>
							</xsl:variable>
							<width>
								<xsl:value-of select="$max_length"/>
							</width>
						</xsl:for-each>
						<xsl:for-each select="*[local-name()='tbody']//*[local-name()='tr']">
							<xsl:variable name="words">
								<xsl:call-template name="tokenize">
									<xsl:with-param name="text" select="translate(*[local-name()='td'][$curr-col],'- —:', '    ')"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:variable name="max_length">
								<xsl:call-template name="max_length">
									<xsl:with-param name="words" select="xalan:nodeset($words)"/>
								</xsl:call-template>
							</xsl:variable>
							<width>
								<xsl:value-of select="$max_length"/>
							</width>
							
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="xalan:nodeset($table)//tr">
							<xsl:variable name="td_text">
								<xsl:apply-templates select="td[$curr-col]" mode="td_text"/>
							</xsl:variable>
							<xsl:variable name="words">
								<xsl:variable name="string_with_added_zerospaces">
									<xsl:call-template name="add-zero-spaces-java">
										<xsl:with-param name="text" select="$td_text"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:call-template name="tokenize">
									<!-- <xsl:with-param name="text" select="translate(td[$curr-col],'- —:', '    ')"/> -->
									<!-- 2009 thinspace -->
									<!-- <xsl:with-param name="text" select="translate(normalize-space($td_text),'- —:', '    ')"/> -->
									<xsl:with-param name="text" select="normalize-space(translate($string_with_added_zerospaces, '​', ' '))"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:variable name="max_length">
								<xsl:call-template name="max_length">
									<xsl:with-param name="words" select="xalan:nodeset($words)"/>
								</xsl:call-template>
							</xsl:variable>
							<width>
								<xsl:variable name="divider">
									<xsl:choose>
										<xsl:when test="td[$curr-col]/@divide">
											<xsl:value-of select="td[$curr-col]/@divide"/>
										</xsl:when>
										<xsl:otherwise>1</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<xsl:value-of select="$max_length div $divider"/>
							</width>
							
						</xsl:for-each>
					
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			
			<column>
				<xsl:for-each select="xalan:nodeset($widths)//width">
					<xsl:sort select="." data-type="number" order="descending"/>
					<xsl:if test="position()=1">
							<xsl:value-of select="."/>
					</xsl:if>
				</xsl:for-each>
			</column>
			<xsl:call-template name="calculate-column-widths">
				<xsl:with-param name="cols-count" select="$cols-count"/>
				<xsl:with-param name="curr-col" select="$curr-col +1"/>
				<xsl:with-param name="table" select="$table"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template><xsl:template match="text()" mode="td_text">
		<xsl:variable name="zero-space">​</xsl:variable>
		<xsl:value-of select="translate(., $zero-space, ' ')"/><xsl:text> </xsl:text>
	</xsl:template><xsl:template match="*[local-name()='termsource']" mode="td_text">
		<xsl:value-of select="*[local-name()='origin']/@citeas"/>
	</xsl:template><xsl:template match="*[local-name()='link']" mode="td_text">
		<xsl:value-of select="@target"/>
	</xsl:template><xsl:template match="*[local-name()='table2']"/><xsl:template match="*[local-name()='thead']"/><xsl:template match="*[local-name()='thead']" mode="process">
		<xsl:param name="cols-count"/>
		<!-- font-weight="bold" -->
		<fo:table-header>			
			
			<xsl:apply-templates/>
		</fo:table-header>
	</xsl:template><xsl:template match="*[local-name()='thead']" mode="process_tbody">		
		<fo:table-body>
			<xsl:apply-templates/>
		</fo:table-body>
	</xsl:template><xsl:template match="*[local-name()='tfoot']"/><xsl:template match="*[local-name()='tfoot']" mode="process">
		<xsl:apply-templates/>
	</xsl:template><xsl:template name="insertTableFooter">
		<xsl:param name="cols-count"/>
		<xsl:variable name="isNoteOrFnExist" select="../*[local-name()='note'] or ..//*[local-name()='fn'][local-name(..) != 'name']"/>
		<xsl:if test="../*[local-name()='tfoot'] or           $isNoteOrFnExist = 'true'">
		
			<fo:table-footer>
			
				<xsl:apply-templates select="../*[local-name()='tfoot']" mode="process"/>
				
				<!-- if there are note(s) or fn(s) then create footer row -->
				<xsl:if test="$isNoteOrFnExist = 'true'">
				
					
				
					<fo:table-row>
						<fo:table-cell border="solid black 1pt" padding-left="1mm" padding-right="1mm" padding-top="1mm" number-columns-spanned="{$cols-count}">
							
							
							
								<xsl:if test="ancestor::*[local-name()='preface']">
									<xsl:attribute name="border">solid black 0pt</xsl:attribute>
								</xsl:if>
							
							<!-- fn will be processed inside 'note' processing -->
							
							
							<!-- except gb -->
							
								<xsl:apply-templates select="../*[local-name()='note']" mode="process"/>
							
							
							<!-- horizontal row separator -->
							
							
							<!-- fn processing -->
							<xsl:call-template name="fn_display"/>
							
						</fo:table-cell>
					</fo:table-row>
					
				</xsl:if>
			</fo:table-footer>
		
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name()='tbody']">
		
		<xsl:variable name="cols-count">
			<xsl:choose>
				<xsl:when test="../*[local-name()='thead']">					
					<xsl:call-template name="calculate-columns-numbers">
						<xsl:with-param name="table-row" select="../*[local-name()='thead']/*[local-name()='tr'][1]"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>					
					<xsl:call-template name="calculate-columns-numbers">
						<xsl:with-param name="table-row" select="./*[local-name()='tr'][1]"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:apply-templates select="../*[local-name()='thead']" mode="process">
			<xsl:with-param name="cols-count" select="$cols-count"/>
		</xsl:apply-templates>
		
		<xsl:call-template name="insertTableFooter">
			<xsl:with-param name="cols-count" select="$cols-count"/>
		</xsl:call-template>
		
		<fo:table-body>
			<xsl:apply-templates/>
			<!-- <xsl:apply-templates select="../*[local-name()='tfoot']" mode="process"/> -->
		
		</fo:table-body>
		
	</xsl:template><xsl:template match="*[local-name()='tr']">
		<xsl:variable name="parent-name" select="local-name(..)"/>
		<!-- <xsl:variable name="namespace" select="substring-before(name(/*), '-')"/> -->
		<fo:table-row min-height="4mm">
				<xsl:if test="$parent-name = 'thead'">
					<xsl:attribute name="font-weight">bold</xsl:attribute>
					
					
					
					
					
				</xsl:if>
				<xsl:if test="$parent-name = 'tfoot'">
					
					
				</xsl:if>
				
				
			<xsl:apply-templates/>
		</fo:table-row>
	</xsl:template><xsl:template match="*[local-name()='th']">
		<fo:table-cell text-align="{@align}" font-weight="bold" border="solid black 1pt" padding-left="1mm" display-align="center">
			<xsl:attribute name="text-align">
				<xsl:choose>
					<xsl:when test="@align">
						<xsl:value-of select="@align"/>
					</xsl:when>
					<xsl:otherwise>center</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			
			
			
				<xsl:if test="ancestor::*[local-name()='preface']">
					<xsl:attribute name="border">solid black 0pt</xsl:attribute>
				</xsl:if>
			
			
			
			
			
			
			
			<xsl:if test="@colspan">
				<xsl:attribute name="number-columns-spanned">
					<xsl:value-of select="@colspan"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@rowspan">
				<xsl:attribute name="number-rows-spanned">
					<xsl:value-of select="@rowspan"/>
				</xsl:attribute>
			</xsl:if>
			<fo:block>
				<xsl:apply-templates/>
			</fo:block>
		</fo:table-cell>
	</xsl:template><xsl:template match="*[local-name()='td']">
		<fo:table-cell text-align="{@align}" display-align="center" border="solid black 1pt" padding-left="1mm">
			<xsl:attribute name="text-align">
				<xsl:choose>
					<xsl:when test="@align">
						<xsl:value-of select="@align"/>
					</xsl:when>
					<xsl:otherwise>left</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			
			
				<xsl:if test="ancestor::*[local-name()='preface']">
					<xsl:attribute name="border">solid black 0pt</xsl:attribute>
				</xsl:if>
				<xsl:attribute name="display-align">before</xsl:attribute>
			
			
						
			
			
			
			
			
			<xsl:if test="@colspan">
				<xsl:attribute name="number-columns-spanned">
					<xsl:value-of select="@colspan"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@rowspan">
				<xsl:attribute name="number-rows-spanned">
					<xsl:value-of select="@rowspan"/>
				</xsl:attribute>
			</xsl:if>
			<fo:block>
								
				<xsl:apply-templates/>
			</fo:block>			
		</fo:table-cell>
	</xsl:template><xsl:template match="*[local-name()='table']/*[local-name()='note']" priority="2"/><xsl:template match="*[local-name()='table']/*[local-name()='note']" mode="process">
		
		
			<fo:block font-size="10pt" margin-bottom="12pt">
				
				
				
				
				<fo:inline padding-right="2mm">
					
					
					
				
					<xsl:apply-templates select="*[local-name() = 'name']" mode="presentation"/>
						
				</fo:inline>
				<xsl:apply-templates mode="process"/>
			</fo:block>
		
	</xsl:template><xsl:template match="*[local-name()='table']/*[local-name()='note']/*[local-name()='name']" mode="process"/><xsl:template match="*[local-name()='table']/*[local-name()='note']/*[local-name()='p']" mode="process">
		<xsl:apply-templates/>
	</xsl:template><xsl:template name="fn_display">
		<xsl:variable name="references">
			<xsl:for-each select="..//*[local-name()='fn'][local-name(..) != 'name']">
				<fn reference="{@reference}" id="{@reference}_{ancestor::*[@id][1]/@id}">
					
						<xsl:if test="ancestor::*[local-name()='preface']">
							<xsl:attribute name="preface">true</xsl:attribute>
						</xsl:if>
					
					
					<xsl:apply-templates/>
				</fn>
			</xsl:for-each>
		</xsl:variable>
		<xsl:for-each select="xalan:nodeset($references)//fn">
			<xsl:variable name="reference" select="@reference"/>
			<xsl:if test="not(preceding-sibling::*[@reference = $reference])"> <!-- only unique reference puts in note-->
				<fo:block margin-bottom="12pt">
					
					
					
					
						<xsl:attribute name="margin-bottom">2pt</xsl:attribute>
						<xsl:attribute name="line-height-shift-adjustment">disregard-shifts</xsl:attribute>
						<xsl:attribute name="text-indent">-5mm</xsl:attribute>
						<xsl:attribute name="start-indent">5mm</xsl:attribute>
					
					<fo:inline font-size="80%" padding-right="5mm" id="{@id}">
						
							<xsl:attribute name="vertical-align">super</xsl:attribute>
						
						
						
						
						
							<xsl:attribute name="padding-right">3mm</xsl:attribute>
							<xsl:attribute name="font-size">70%</xsl:attribute>
						
						
						<xsl:value-of select="@reference"/>
						
							<!-- <xsl:if test="@preface = 'true'"> -->
								<xsl:text>)</xsl:text>
							<!-- </xsl:if> -->
						
					</fo:inline>
					<fo:inline>
						
						<xsl:apply-templates/>
					</fo:inline>
				</fo:block>
			</xsl:if>
		</xsl:for-each>
	</xsl:template><xsl:template name="fn_name_display">
		<!-- <xsl:variable name="references">
			<xsl:for-each select="*[local-name()='name']//*[local-name()='fn']">
				<fn reference="{@reference}" id="{@reference}_{ancestor::*[@id][1]/@id}">
					<xsl:apply-templates />
				</fn>
			</xsl:for-each>
		</xsl:variable>
		$references=<xsl:copy-of select="$references"/> -->
		<xsl:for-each select="*[local-name()='name']//*[local-name()='fn']">
			<xsl:variable name="reference" select="@reference"/>
			<fo:block id="{@reference}_{ancestor::*[@id][1]/@id}"><xsl:value-of select="@reference"/></fo:block>
			<fo:block margin-bottom="12pt">
				<xsl:apply-templates/>
			</fo:block>
		</xsl:for-each>
	</xsl:template><xsl:template name="fn_display_figure">
		<xsl:variable name="key_iso">
			 <!-- and (not(@class) or @class !='pseudocode') -->
		</xsl:variable>
		<xsl:variable name="references">
			<xsl:for-each select=".//*[local-name()='fn'][not(parent::*[local-name()='name'])]">
				<fn reference="{@reference}" id="{@reference}_{ancestor::*[@id][1]/@id}">
					<xsl:apply-templates/>
				</fn>
			</xsl:for-each>
		</xsl:variable>
		
		<!-- current hierarchy is 'figure' element -->
		<xsl:variable name="following_dl_colwidths">
			<xsl:if test="*[local-name() = 'dl']"><!-- if there is a 'dl', then set the same columns width as for 'dl' -->
				<xsl:variable name="html-table">
					<xsl:variable name="ns" select="substring-before(name(/*), '-')"/>
					<xsl:element name="{$ns}:table">
						<xsl:for-each select="*[local-name() = 'dl'][1]">
							<tbody>
								<xsl:apply-templates mode="dl"/>
							</tbody>
						</xsl:for-each>
					</xsl:element>
				</xsl:variable>
				
				<xsl:call-template name="calculate-column-widths">
					<xsl:with-param name="cols-count" select="2"/>
					<xsl:with-param name="table" select="$html-table"/>
				</xsl:call-template>
				
			</xsl:if>
		</xsl:variable>
		
		
		<xsl:variable name="maxlength_dt">
			<xsl:for-each select="*[local-name() = 'dl'][1]">
				<xsl:call-template name="getMaxLength_dt"/>			
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:if test="xalan:nodeset($references)//fn">
			<fo:block>
				<fo:table width="95%" table-layout="fixed">
					<xsl:if test="normalize-space($key_iso) = 'true'">
						<xsl:attribute name="font-size">10pt</xsl:attribute>
						
					</xsl:if>
					<xsl:choose>
						<!-- if there 'dl', then set same columns width -->
						<xsl:when test="xalan:nodeset($following_dl_colwidths)//column">
							<xsl:call-template name="setColumnWidth_dl">
								<xsl:with-param name="colwidths" select="$following_dl_colwidths"/>								
								<xsl:with-param name="maxlength_dt" select="$maxlength_dt"/>								
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<fo:table-column column-width="15%"/>
							<fo:table-column column-width="85%"/>
						</xsl:otherwise>
					</xsl:choose>
					<fo:table-body>
						<xsl:for-each select="xalan:nodeset($references)//fn">
							<xsl:variable name="reference" select="@reference"/>
							<xsl:if test="not(preceding-sibling::*[@reference = $reference])"> <!-- only unique reference puts in note-->
								<fo:table-row>
									<fo:table-cell>
										<fo:block>
											<fo:inline font-size="80%" padding-right="5mm" vertical-align="super" id="{@id}">
												
												<xsl:value-of select="@reference"/>
											</fo:inline>
										</fo:block>
									</fo:table-cell>
									<fo:table-cell>
										<fo:block text-align="justify" margin-bottom="12pt">
											
											<xsl:if test="normalize-space($key_iso) = 'true'">
												<xsl:attribute name="margin-bottom">0</xsl:attribute>
											</xsl:if>
											
											<xsl:apply-templates/>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</xsl:if>
						</xsl:for-each>
					</fo:table-body>
				</fo:table>
			</fo:block>
		</xsl:if>
		
	</xsl:template><xsl:template match="*[local-name()='fn']">
		<!-- <xsl:variable name="namespace" select="substring-before(name(/*), '-')"/> -->
		<fo:inline font-size="80%" keep-with-previous.within-line="always">
			
			
			
				<xsl:attribute name="vertical-align">super</xsl:attribute>
				<xsl:attribute name="color">blue</xsl:attribute>
			
			
			<fo:basic-link internal-destination="{@reference}_{ancestor::*[@id][1]/@id}" fox:alt-text="{@reference}"> <!-- @reference   | ancestor::*[local-name()='clause'][1]/@id-->
				
				<xsl:value-of select="@reference"/>
			</fo:basic-link>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='fn']/*[local-name()='p']">
		<fo:inline>
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='dl']">
		<xsl:variable name="parent" select="local-name(..)"/>
		
		<xsl:variable name="key_iso">
			 <!-- and  (not(../@class) or ../@class !='pseudocode') -->
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$parent = 'formula' and count(*[local-name()='dt']) = 1"> <!-- only one component -->
				
				
					<fo:block margin-bottom="12pt" text-align="left">
						
						<xsl:variable name="title-where">
							<xsl:call-template name="getTitle">
								<xsl:with-param name="name" select="'title-where'"/>
							</xsl:call-template>
						</xsl:variable>
						<xsl:value-of select="$title-where"/><xsl:text> </xsl:text>
						<xsl:apply-templates select="*[local-name()='dt']/*"/>
						<xsl:text/>
						<xsl:apply-templates select="*[local-name()='dd']/*" mode="inline"/>
					</fo:block>
				
			</xsl:when>
			<xsl:when test="$parent = 'formula'"> <!-- a few components -->
				<fo:block margin-bottom="12pt" text-align="left">
					
					
					
						<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
					
					
					<xsl:variable name="title-where">
						<xsl:call-template name="getTitle">
							<xsl:with-param name="name" select="'title-where'"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:value-of select="$title-where"/>:
				</fo:block>
			</xsl:when>
			<xsl:when test="$parent = 'figure' and  (not(../@class) or ../@class !='pseudocode')">
				<fo:block font-weight="bold" text-align="left" margin-bottom="12pt" keep-with-next="always">
					
					
					
					<xsl:variable name="title-key">
						<xsl:call-template name="getTitle">
							<xsl:with-param name="name" select="'title-key'"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:value-of select="$title-key"/>
				</fo:block>
			</xsl:when>
		</xsl:choose>
		
		<!-- a few components -->
		<xsl:if test="not($parent = 'formula' and count(*[local-name()='dt']) = 1)">
			<fo:block>
				
				
					<xsl:if test="$parent = 'figure' or $parent = 'formula'">
						<xsl:attribute name="margin-left">7.4mm</xsl:attribute>
					</xsl:if>
					<xsl:if test="$parent = 'li'">
						<!-- <xsl:attribute name="margin-left">-4mm</xsl:attribute> -->						
					</xsl:if>					
				
				
				
				<fo:block>
					
					
					
					
					<fo:table width="95%" table-layout="fixed">
						
						<xsl:choose>
							<xsl:when test="normalize-space($key_iso) = 'true' and $parent = 'formula'">
								<!-- <xsl:attribute name="font-size">11pt</xsl:attribute> -->
							</xsl:when>
							<xsl:when test="normalize-space($key_iso) = 'true'">
								<xsl:attribute name="font-size">10pt</xsl:attribute>
								
							</xsl:when>
						</xsl:choose>
						<!-- create virtual html table for dl/[dt and dd] -->
						<xsl:variable name="html-table">
							<xsl:variable name="ns" select="substring-before(name(/*), '-')"/>
							<xsl:element name="{$ns}:table">
								<tbody>
									<xsl:apply-templates mode="dl"/>
								</tbody>
							</xsl:element>
						</xsl:variable>
						<!-- html-table<xsl:copy-of select="$html-table"/> -->
						<xsl:variable name="colwidths">
							<xsl:call-template name="calculate-column-widths">
								<xsl:with-param name="cols-count" select="2"/>
								<xsl:with-param name="table" select="$html-table"/>
							</xsl:call-template>
						</xsl:variable>
						<!-- colwidths=<xsl:value-of select="$colwidths"/> -->
						<xsl:variable name="maxlength_dt">							
							<xsl:call-template name="getMaxLength_dt"/>							
						</xsl:variable>
						<xsl:call-template name="setColumnWidth_dl">
							<xsl:with-param name="colwidths" select="$colwidths"/>							
							<xsl:with-param name="maxlength_dt" select="$maxlength_dt"/>
						</xsl:call-template>
						<fo:table-body>
							<xsl:apply-templates>
								<xsl:with-param name="key_iso" select="normalize-space($key_iso)"/>
							</xsl:apply-templates>
						</fo:table-body>
					</fo:table>
				</fo:block>
			</fo:block>
		</xsl:if>
	</xsl:template><xsl:template name="setColumnWidth_dl">
		<xsl:param name="colwidths"/>		
		<xsl:param name="maxlength_dt"/>
		<xsl:choose>
			<xsl:when test="ancestor::*[local-name()='dl']"><!-- second level, i.e. inlined table -->
				<fo:table-column column-width="50%"/>
				<fo:table-column column-width="50%"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="normalize-space($maxlength_dt) != '' and number($maxlength_dt) &lt;= 2"> <!-- if dt contains short text like t90, a, etc -->
						<fo:table-column column-width="5%"/>
						<fo:table-column column-width="95%"/>
					</xsl:when>
					<xsl:when test="normalize-space($maxlength_dt) != '' and number($maxlength_dt) &lt;= 5"> <!-- if dt contains short text like t90, a, etc -->
						<fo:table-column column-width="10%"/>
						<fo:table-column column-width="90%"/>
					</xsl:when>
					<!-- <xsl:when test="xalan:nodeset($colwidths)/column[1] div xalan:nodeset($colwidths)/column[2] &gt; 1.7">
						<fo:table-column column-width="60%"/>
						<fo:table-column column-width="40%"/>
					</xsl:when> -->
					<xsl:when test="xalan:nodeset($colwidths)/column[1] div xalan:nodeset($colwidths)/column[2] &gt; 1.3">
						<fo:table-column column-width="50%"/>
						<fo:table-column column-width="50%"/>
					</xsl:when>
					<xsl:when test="xalan:nodeset($colwidths)/column[1] div xalan:nodeset($colwidths)/column[2] &gt; 0.5">
						<fo:table-column column-width="40%"/>
						<fo:table-column column-width="60%"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="xalan:nodeset($colwidths)//column">
							<xsl:choose>
								<xsl:when test=". = 1 or . = 0">
									<fo:table-column column-width="proportional-column-width(2)"/>
								</xsl:when>
								<xsl:otherwise>
									<fo:table-column column-width="proportional-column-width({.})"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
				<!-- <fo:table-column column-width="15%"/>
				<fo:table-column column-width="85%"/> -->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="getMaxLength_dt">
		<xsl:for-each select="*[local-name()='dt']">
			<xsl:sort select="string-length(normalize-space(.))" data-type="number" order="descending"/>
			<xsl:if test="position() = 1">
				<xsl:value-of select="string-length(normalize-space(.))"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template><xsl:template match="*[local-name()='dl']/*[local-name()='note']" priority="2">
		<xsl:param name="key_iso"/>
		
		<!-- <tr>
			<td>NOTE</td>
			<td>
				<xsl:apply-templates />
			</td>
		</tr>
		 -->
		<fo:table-row>
			<fo:table-cell>
				<fo:block margin-top="6pt">
					<xsl:if test="normalize-space($key_iso) = 'true'">
						<xsl:attribute name="margin-top">0</xsl:attribute>
					</xsl:if>
					<xsl:apply-templates select="*[local-name() = 'name']" mode="presentation"/>
				</fo:block>
			</fo:table-cell>
			<fo:table-cell>
				<fo:block>
					<xsl:apply-templates/>
				</fo:block>
			</fo:table-cell>
		</fo:table-row>
	</xsl:template><xsl:template match="*[local-name()='dt']" mode="dl">
		<tr>
			<td>
				<xsl:apply-templates/>
			</td>
			<td>
				
				
					<xsl:apply-templates select="following-sibling::*[local-name()='dd'][1]" mode="process"/>
				
			</td>
		</tr>
		
	</xsl:template><xsl:template match="*[local-name()='dt']">
		<xsl:param name="key_iso"/>
		
		<fo:table-row>
			<fo:table-cell>
				
					<xsl:if test="ancestor::*[1][local-name() = 'dl']/preceding-sibling::*[1][local-name() = 'formula']">						
						<xsl:attribute name="padding-right">3mm</xsl:attribute>
					</xsl:if>
				
				<fo:block margin-top="6pt">
					
					
					<xsl:if test="normalize-space($key_iso) = 'true'">
						<xsl:attribute name="margin-top">0</xsl:attribute>
						
					</xsl:if>
					
					
					
					
						<xsl:if test="ancestor::*[1][local-name() = 'dl']/preceding-sibling::*[1][local-name() = 'formula']">
							<xsl:attribute name="text-align">right</xsl:attribute>							
						</xsl:if>
					
					
					<xsl:apply-templates/>
					<!-- <xsl:if test="$namespace = 'gb'">
						<xsl:if test="ancestor::*[local-name()='formula']">
							<xsl:text>—</xsl:text>
						</xsl:if>
					</xsl:if> -->
				</fo:block>
			</fo:table-cell>
			<fo:table-cell>
				<fo:block>
					
						<xsl:attribute name="text-align">justify</xsl:attribute>
					
					
					
						<xsl:apply-templates select="following-sibling::*[local-name()='dd'][1]" mode="process"/>
					
				</fo:block>
			</fo:table-cell>
		</fo:table-row>
		
	</xsl:template><xsl:template match="*[local-name()='dd']" mode="dl"/><xsl:template match="*[local-name()='dd']" mode="dl_process">
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name()='dd']"/><xsl:template match="*[local-name()='dd']" mode="process">
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name()='dd']/*[local-name()='p']" mode="inline">
		<fo:inline><xsl:text> </xsl:text><xsl:apply-templates/></fo:inline>
	</xsl:template><xsl:template match="*[local-name()='em']">
		<fo:inline font-style="italic">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='strong'] | *[local-name()='b']">
		<fo:inline font-weight="bold">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='sup']">
		<fo:inline font-size="80%" vertical-align="super">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='sub']">
		<fo:inline font-size="80%" vertical-align="sub">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='tt']">
		<fo:inline xsl:use-attribute-sets="tt-style">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='del']">
		<fo:inline font-size="10pt" color="red" text-decoration="line-through">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="text()[ancestor::*[local-name()='smallcap']]">
		<xsl:variable name="text" select="normalize-space(.)"/>
		<fo:inline font-size="75%">
				<xsl:if test="string-length($text) &gt; 0">
					<xsl:call-template name="recursiveSmallCaps">
						<xsl:with-param name="text" select="$text"/>
					</xsl:call-template>
				</xsl:if>
			</fo:inline> 
	</xsl:template><xsl:template name="recursiveSmallCaps">
    <xsl:param name="text"/>
    <xsl:variable name="char" select="substring($text,1,1)"/>
    <!-- <xsl:variable name="upperCase" select="translate($char, $lower, $upper)"/> -->
		<xsl:variable name="upperCase" select="java:toUpperCase(java:java.lang.String.new($char))"/>
    <xsl:choose>
      <xsl:when test="$char=$upperCase">
        <fo:inline font-size="{100 div 0.75}%">
          <xsl:value-of select="$upperCase"/>
        </fo:inline>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$upperCase"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="string-length($text) &gt; 1">
      <xsl:call-template name="recursiveSmallCaps">
        <xsl:with-param name="text" select="substring($text,2)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template><xsl:template name="tokenize">
		<xsl:param name="text"/>
		<xsl:param name="separator" select="' '"/>
		<xsl:choose>
			<xsl:when test="not(contains($text, $separator))">
				<word>
					<xsl:variable name="str_no_en_chars" select="normalize-space(translate($text, $en_chars, ''))"/>
					<xsl:variable name="len_str_no_en_chars" select="string-length($str_no_en_chars)"/>
					<xsl:variable name="len_str_tmp" select="string-length(normalize-space($text))"/>
					<xsl:variable name="len_str">
						<xsl:choose>
							<xsl:when test="normalize-space(translate($text, $upper, '')) = ''"> <!-- english word in CAPITAL letters -->
								<xsl:value-of select="$len_str_tmp * 1.5"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$len_str_tmp"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable> 
					
					<!-- <xsl:if test="$len_str_no_en_chars div $len_str &gt; 0.8">
						<xsl:message>
							div=<xsl:value-of select="$len_str_no_en_chars div $len_str"/>
							len_str=<xsl:value-of select="$len_str"/>
							len_str_no_en_chars=<xsl:value-of select="$len_str_no_en_chars"/>
						</xsl:message>
					</xsl:if> -->
					<!-- <len_str_no_en_chars><xsl:value-of select="$len_str_no_en_chars"/></len_str_no_en_chars>
					<len_str><xsl:value-of select="$len_str"/></len_str> -->
					<xsl:choose>
						<xsl:when test="$len_str_no_en_chars div $len_str &gt; 0.8"> <!-- means non-english string -->
							<xsl:value-of select="$len_str - $len_str_no_en_chars"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$len_str"/>
						</xsl:otherwise>
					</xsl:choose>
				</word>
			</xsl:when>
			<xsl:otherwise>
				<word>
					<xsl:value-of select="string-length(normalize-space(substring-before($text, $separator)))"/>
				</word>
				<xsl:call-template name="tokenize">
					<xsl:with-param name="text" select="substring-after($text, $separator)"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="max_length">
		<xsl:param name="words"/>
		<xsl:for-each select="$words//word">
				<xsl:sort select="." data-type="number" order="descending"/>
				<xsl:if test="position()=1">
						<xsl:value-of select="."/>
				</xsl:if>
		</xsl:for-each>
	</xsl:template><xsl:template name="add-zero-spaces-java">
		<xsl:param name="text" select="."/>
		<!-- add zero-width space (#x200B) after characters: dash, dot, colon, equal, underscore, em dash, thin space  -->
		<xsl:value-of select="java:replaceAll(java:java.lang.String.new($text),'(-|\.|:|=|_|—| )','$1​')"/>
	</xsl:template><xsl:template name="add-zero-spaces">
		<xsl:param name="text" select="."/>
		<xsl:variable name="zero-space-after-chars">-</xsl:variable>
		<xsl:variable name="zero-space-after-dot">.</xsl:variable>
		<xsl:variable name="zero-space-after-colon">:</xsl:variable>
		<xsl:variable name="zero-space-after-equal">=</xsl:variable>
		<xsl:variable name="zero-space-after-underscore">_</xsl:variable>
		<xsl:variable name="zero-space">​</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains($text, $zero-space-after-chars)">
				<xsl:value-of select="substring-before($text, $zero-space-after-chars)"/>
				<xsl:value-of select="$zero-space-after-chars"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-chars)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($text, $zero-space-after-dot)">
				<xsl:value-of select="substring-before($text, $zero-space-after-dot)"/>
				<xsl:value-of select="$zero-space-after-dot"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-dot)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($text, $zero-space-after-colon)">
				<xsl:value-of select="substring-before($text, $zero-space-after-colon)"/>
				<xsl:value-of select="$zero-space-after-colon"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-colon)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($text, $zero-space-after-equal)">
				<xsl:value-of select="substring-before($text, $zero-space-after-equal)"/>
				<xsl:value-of select="$zero-space-after-equal"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-equal)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($text, $zero-space-after-underscore)">
				<xsl:value-of select="substring-before($text, $zero-space-after-underscore)"/>
				<xsl:value-of select="$zero-space-after-underscore"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-underscore)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="add-zero-spaces-equal">
		<xsl:param name="text" select="."/>
		<xsl:variable name="zero-space-after-equals">==========</xsl:variable>
		<xsl:variable name="zero-space-after-equal">=</xsl:variable>
		<xsl:variable name="zero-space">​</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains($text, $zero-space-after-equals)">
				<xsl:value-of select="substring-before($text, $zero-space-after-equals)"/>
				<xsl:value-of select="$zero-space-after-equals"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces-equal">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-equals)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($text, $zero-space-after-equal)">
				<xsl:value-of select="substring-before($text, $zero-space-after-equal)"/>
				<xsl:value-of select="$zero-space-after-equal"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces-equal">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-equal)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="getSimpleTable">
		<xsl:variable name="simple-table">
		
			<!-- Step 1. colspan processing -->
			<xsl:variable name="simple-table-colspan">
				<tbody>
					<xsl:apply-templates mode="simple-table-colspan"/>
				</tbody>
			</xsl:variable>
			
			<!-- Step 2. rowspan processing -->
			<xsl:variable name="simple-table-rowspan">
				<xsl:apply-templates select="xalan:nodeset($simple-table-colspan)" mode="simple-table-rowspan"/>
			</xsl:variable>
			
			<xsl:copy-of select="xalan:nodeset($simple-table-rowspan)"/>
					
			<!-- <xsl:choose>
				<xsl:when test="current()//*[local-name()='th'][@colspan] or current()//*[local-name()='td'][@colspan] ">
					
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="current()"/>
				</xsl:otherwise>
			</xsl:choose> -->
		</xsl:variable>
		<xsl:copy-of select="$simple-table"/>
	</xsl:template><xsl:template match="*[local-name()='thead'] | *[local-name()='tbody']" mode="simple-table-colspan">
		<xsl:apply-templates mode="simple-table-colspan"/>
	</xsl:template><xsl:template match="*[local-name()='fn']" mode="simple-table-colspan"/><xsl:template match="*[local-name()='th'] | *[local-name()='td']" mode="simple-table-colspan">
		<xsl:choose>
			<xsl:when test="@colspan">
				<xsl:variable name="td">
					<xsl:element name="td">
						<xsl:attribute name="divide"><xsl:value-of select="@colspan"/></xsl:attribute>
						<xsl:apply-templates select="@*" mode="simple-table-colspan"/>
						<xsl:apply-templates mode="simple-table-colspan"/>
					</xsl:element>
				</xsl:variable>
				<xsl:call-template name="repeatNode">
					<xsl:with-param name="count" select="@colspan"/>
					<xsl:with-param name="node" select="$td"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="td">
					<xsl:apply-templates select="@*" mode="simple-table-colspan"/>
					<xsl:apply-templates mode="simple-table-colspan"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="@colspan" mode="simple-table-colspan"/><xsl:template match="*[local-name()='tr']" mode="simple-table-colspan">
		<xsl:element name="tr">
			<xsl:apply-templates select="@*" mode="simple-table-colspan"/>
			<xsl:apply-templates mode="simple-table-colspan"/>
		</xsl:element>
	</xsl:template><xsl:template match="@*|node()" mode="simple-table-colspan">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="simple-table-colspan"/>
		</xsl:copy>
	</xsl:template><xsl:template name="repeatNode">
		<xsl:param name="count"/>
		<xsl:param name="node"/>
		
		<xsl:if test="$count &gt; 0">
			<xsl:call-template name="repeatNode">
				<xsl:with-param name="count" select="$count - 1"/>
				<xsl:with-param name="node" select="$node"/>
			</xsl:call-template>
			<xsl:copy-of select="$node"/>
		</xsl:if>
	</xsl:template><xsl:template match="@*|node()" mode="simple-table-rowspan">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="simple-table-rowspan"/>
		</xsl:copy>
	</xsl:template><xsl:template match="tbody" mode="simple-table-rowspan">
		<xsl:copy>
				<xsl:copy-of select="tr[1]"/>
				<xsl:apply-templates select="tr[2]" mode="simple-table-rowspan">
						<xsl:with-param name="previousRow" select="tr[1]"/>
				</xsl:apply-templates>
		</xsl:copy>
	</xsl:template><xsl:template match="tr" mode="simple-table-rowspan">
		<xsl:param name="previousRow"/>
		<xsl:variable name="currentRow" select="."/>
	
		<xsl:variable name="normalizedTDs">
				<xsl:for-each select="xalan:nodeset($previousRow)//td">
						<xsl:choose>
								<xsl:when test="@rowspan &gt; 1">
										<xsl:copy>
												<xsl:attribute name="rowspan">
														<xsl:value-of select="@rowspan - 1"/>
												</xsl:attribute>
												<xsl:copy-of select="@*[not(name() = 'rowspan')]"/>
												<xsl:copy-of select="node()"/>
										</xsl:copy>
								</xsl:when>
								<xsl:otherwise>
										<xsl:copy-of select="$currentRow/td[1 + count(current()/preceding-sibling::td[not(@rowspan) or (@rowspan = 1)])]"/>
								</xsl:otherwise>
						</xsl:choose>
				</xsl:for-each>
		</xsl:variable>

		<xsl:variable name="newRow">
				<xsl:copy>
						<xsl:copy-of select="$currentRow/@*"/>
						<xsl:copy-of select="xalan:nodeset($normalizedTDs)"/>
				</xsl:copy>
		</xsl:variable>
		<xsl:copy-of select="$newRow"/>

		<xsl:apply-templates select="following-sibling::tr[1]" mode="simple-table-rowspan">
				<xsl:with-param name="previousRow" select="$newRow"/>
		</xsl:apply-templates>
	</xsl:template><xsl:template name="getLang">
		<xsl:variable name="language" select="//*[local-name()='bibdata']//*[local-name()='language']"/>
		<xsl:choose>
			<xsl:when test="$language = 'English'">en</xsl:when>
			<xsl:otherwise><xsl:value-of select="$language"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="capitalizeWords">
		<xsl:param name="str"/>
		<xsl:variable name="str2" select="translate($str, '-', ' ')"/>
		<xsl:choose>
			<xsl:when test="contains($str2, ' ')">
				<xsl:variable name="substr" select="substring-before($str2, ' ')"/>
				<!-- <xsl:value-of select="translate(substring($substr, 1, 1), $lower, $upper)"/>
				<xsl:value-of select="substring($substr, 2)"/> -->
				<xsl:call-template name="capitalize">
					<xsl:with-param name="str" select="$substr"/>
				</xsl:call-template>
				<xsl:text> </xsl:text>
				<xsl:call-template name="capitalizeWords">
					<xsl:with-param name="str" select="substring-after($str2, ' ')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- <xsl:value-of select="translate(substring($str2, 1, 1), $lower, $upper)"/>
				<xsl:value-of select="substring($str2, 2)"/> -->
				<xsl:call-template name="capitalize">
					<xsl:with-param name="str" select="$str2"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="capitalize">
		<xsl:param name="str"/>
		<xsl:value-of select="java:toUpperCase(java:java.lang.String.new(substring($str, 1, 1)))"/>
		<xsl:value-of select="substring($str, 2)"/>		
	</xsl:template><xsl:template match="mathml:math">
		<fo:inline font-family="STIX2Math">
			<fo:instream-foreign-object fox:alt-text="Math"> 
				<xsl:copy-of select="."/>
			</fo:instream-foreign-object>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='localityStack']"/><xsl:template match="*[local-name()='link']" name="link">
		<xsl:variable name="target">
			<xsl:choose>
				<xsl:when test="starts-with(normalize-space(@target), 'mailto:')">
					<xsl:value-of select="normalize-space(substring-after(@target, 'mailto:'))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(@target)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<fo:inline xsl:use-attribute-sets="link-style">
			<xsl:choose>
				<xsl:when test="$target = ''">
					<xsl:apply-templates/>
				</xsl:when>
				<xsl:otherwise>
					<fo:basic-link external-destination="{@target}" fox:alt-text="{@target}">
						<xsl:choose>
							<xsl:when test="normalize-space(.) = ''">
								<xsl:value-of select="$target"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates/>
							</xsl:otherwise>
						</xsl:choose>
					</fo:basic-link>
				</xsl:otherwise>
			</xsl:choose>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='bookmark']">
		<fo:inline id="{@id}"/>
	</xsl:template><xsl:template match="*[local-name()='appendix']">
		<fo:block id="{@id}" xsl:use-attribute-sets="appendix-style">
			<xsl:apply-templates select="*[local-name()='title']" mode="process"/>
		</fo:block>
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name()='appendix']/*[local-name()='title']"/><xsl:template match="*[local-name()='appendix']/*[local-name()='title']" mode="process">
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template><xsl:template match="*[local-name()='appendix']//*[local-name()='example']" priority="2">
		<fo:block id="{@id}" xsl:use-attribute-sets="appendix-example-style">			
			<xsl:apply-templates select="*[local-name()='name']" mode="presentation"/>
		</fo:block>
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name() = 'callout']">		
		<fo:basic-link internal-destination="{@target}" fox:alt-text="{@target}">&lt;<xsl:apply-templates/>&gt;</fo:basic-link>
	</xsl:template><xsl:template match="*[local-name() = 'annotation']">
		<xsl:variable name="annotation-id" select="@id"/>
		<xsl:variable name="callout" select="//*[@target = $annotation-id]/text()"/>		
		<fo:block id="{$annotation-id}" white-space="nowrap">			
			<fo:inline>				
				<xsl:apply-templates>
					<xsl:with-param name="callout" select="concat('&lt;', $callout, '&gt; ')"/>
				</xsl:apply-templates>
			</fo:inline>
		</fo:block>		
	</xsl:template><xsl:template match="*[local-name() = 'annotation']/*[local-name() = 'p']">
		<xsl:param name="callout"/>
		<fo:inline id="{@id}">
			<!-- for first p in annotation, put <x> -->
			<xsl:if test="not(preceding-sibling::*[local-name() = 'p'])"><xsl:value-of select="$callout"/></xsl:if>
			<xsl:apply-templates/>
		</fo:inline>		
	</xsl:template><xsl:template match="*[local-name() = 'modification']">
		<xsl:variable name="title-modified">
			<xsl:call-template name="getTitle">
				<xsl:with-param name="name" select="'title-modified'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$lang = 'zh'"><xsl:text>、</xsl:text><xsl:value-of select="$title-modified"/><xsl:text>—</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>, </xsl:text><xsl:value-of select="$title-modified"/><xsl:text> — </xsl:text></xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name() = 'xref']">
		<fo:basic-link internal-destination="{@target}" fox:alt-text="{@target}" xsl:use-attribute-sets="xref-style">
						
			<xsl:apply-templates/>
		</fo:basic-link>
	</xsl:template><xsl:template match="*[local-name() = 'formula']" name="formula">
		<fo:block id="{@id}" xsl:use-attribute-sets="formula-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'formula']/*[local-name() = 'dt']/*[local-name() = 'stem']">
		<fo:inline>
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'admitted']/*[local-name() = 'stem']">
		<fo:inline>
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'formula']/*[local-name() = 'name']"/><xsl:template match="*[local-name() = 'formula']/*[local-name() = 'name']" mode="presentation">
		<xsl:if test="normalize-space() != ''">
			<xsl:text>(</xsl:text><xsl:apply-templates/><xsl:text>)</xsl:text>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'note']" name="note">
	
		<fo:block-container id="{@id}" xsl:use-attribute-sets="note-style">
			
			
			
			
			<fo:block-container margin-left="0mm">
				
				
				
				
				
				

				
					<fo:block>
						
							<xsl:if test="ancestor::itu:figure">
								<xsl:attribute name="keep-with-previous">always</xsl:attribute>
							</xsl:if>
						
						
						
						
						<fo:inline xsl:use-attribute-sets="note-name-style">
							<xsl:apply-templates select="*[local-name() = 'name']" mode="presentation"/>
						</fo:inline>
						<xsl:apply-templates/>
					</fo:block>
				
				
			</fo:block-container>
		</fo:block-container>
		
	</xsl:template><xsl:template match="*[local-name() = 'note']/*[local-name() = 'p']">
		<xsl:variable name="num"><xsl:number/></xsl:variable>
		<xsl:choose>
			<xsl:when test="$num = 1">
				<fo:inline xsl:use-attribute-sets="note-p-style">
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:block xsl:use-attribute-sets="note-p-style">						
					<xsl:apply-templates/>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="*[local-name() = 'termnote']">
		<fo:block id="{@id}" xsl:use-attribute-sets="termnote-style">			
			<xsl:apply-templates select="*[local-name() = 'name']" mode="presentation"/>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'note']/*[local-name() = 'name'] |               *[local-name() = 'termnote']/*[local-name() = 'name']"/><xsl:template match="*[local-name() = 'note']/*[local-name() = 'name']" mode="presentation">
		<xsl:param name="sfx"/>
		<xsl:variable name="suffix">
			<xsl:choose>
				<xsl:when test="$sfx != ''">
					<xsl:value-of select="$sfx"/>					
				</xsl:when>
				<xsl:otherwise>
					
									
						<xsl:text> – </xsl:text>
					
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="normalize-space() != ''">
			<xsl:apply-templates/>
			<xsl:value-of select="$suffix"/>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'termnote']/*[local-name() = 'name']" mode="presentation">
		<xsl:param name="sfx"/>
		<xsl:variable name="suffix">
			<xsl:choose>
				<xsl:when test="$sfx != ''">
					<xsl:value-of select="$sfx"/>					
				</xsl:when>
				<xsl:otherwise>
					
									
						<xsl:text> – </xsl:text>
					
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="normalize-space() != ''">
			<xsl:apply-templates/>
			<xsl:value-of select="$suffix"/>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'termnote']/*[local-name() = 'p']">
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'terms']">
		<fo:block id="{@id}">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'term']">
		<fo:block id="{@id}" xsl:use-attribute-sets="term-style">
			
			
			
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'term']/*[local-name() = 'name']"/><xsl:template match="*[local-name() = 'term']/*[local-name() = 'name']" mode="presentation">
		<xsl:if test="normalize-space() != ''">
			<fo:inline>
				<xsl:apply-templates/>
				<!-- <xsl:if test="$namespace = 'gb' or $namespace = 'ogc'">
					<xsl:text>.</xsl:text>
				</xsl:if> -->
			</fo:inline>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'figure']">
		<fo:block-container id="{@id}">
			<fo:block>
				<xsl:apply-templates/>
			</fo:block>
			<xsl:call-template name="fn_display_figure"/>
			<xsl:for-each select="*[local-name() = 'note']">
				<xsl:call-template name="note"/>
			</xsl:for-each>
			<xsl:apply-templates select="*[local-name() = 'name']" mode="presentation"/>
		</fo:block-container>
	</xsl:template><xsl:template match="*[local-name() = 'figure'][@class = 'pseudocode']">
		<fo:block id="{@id}">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'figure'][@class = 'pseudocode']//*[local-name() = 'p']">
		<fo:block xsl:use-attribute-sets="figure-pseudocode-p-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'image']">
		<fo:block xsl:use-attribute-sets="image-style">
			
			
			<xsl:variable name="src">
				<xsl:choose>
					<xsl:when test="@mimetype = 'image/svg+xml' and $images/images/image[@id = current()/@id]">
						<xsl:value-of select="$images/images/image[@id = current()/@id]/@src"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@src"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<fo:external-graphic src="{$src}" fox:alt-text="Image {@alt}" xsl:use-attribute-sets="image-graphic-style"/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'figure']/*[local-name() = 'name']"/><xsl:template match="*[local-name() = 'figure']/*[local-name() = 'name'] |                *[local-name() = 'table']/*[local-name() = 'name'] |               *[local-name() = 'permission']/*[local-name() = 'name'] |               *[local-name() = 'recommendation']/*[local-name() = 'name'] |               *[local-name() = 'requirement']/*[local-name() = 'name']" mode="contents">
		<xsl:apply-templates mode="contents"/>
		<xsl:text> </xsl:text>
	</xsl:template><xsl:template match="text()" mode="contents">
		<xsl:value-of select="."/>
	</xsl:template><xsl:template match="*[local-name() = 'figure']/*[local-name() = 'name'] |         *[local-name() = 'image']/*[local-name() = 'name']" mode="presentation">
		<xsl:if test="normalize-space() != ''">			
			<fo:block xsl:use-attribute-sets="figure-name-style">
								
				<xsl:apply-templates/>
			</fo:block>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'figure']/*[local-name() = 'fn']" priority="2"/><xsl:template match="*[local-name() = 'figure']/*[local-name() = 'note']"/><xsl:template match="*[local-name() = 'title']" mode="contents_item">
		<xsl:apply-templates mode="contents_item"/>
		<!-- <xsl:text> </xsl:text> -->
	</xsl:template><xsl:template name="getSection">
		<xsl:value-of select="*[local-name() = 'title']/*[local-name() = 'tab'][1]/preceding-sibling::node()"/>
	</xsl:template><xsl:template name="getName">
		<xsl:choose>
			<xsl:when test="*[local-name() = 'title']/*[local-name() = 'tab']">
				<xsl:copy-of select="*[local-name() = 'title']/*[local-name() = 'tab'][1]/following-sibling::node()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="*[local-name() = 'title']/node()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="insertTitleAsListItem">
		<xsl:param name="provisional-distance-between-starts" select="'9.5mm'"/>
		<xsl:variable name="section">						
			<xsl:for-each select="..">
				<xsl:call-template name="getSection"/>
			</xsl:for-each>
		</xsl:variable>							
		<fo:list-block provisional-distance-between-starts="{$provisional-distance-between-starts}">						
			<fo:list-item>
				<fo:list-item-label end-indent="label-end()">
					<fo:block>
						<xsl:value-of select="$section"/>
					</fo:block>
				</fo:list-item-label>
				<fo:list-item-body start-indent="body-start()">
					<fo:block>						
						<xsl:choose>
							<xsl:when test="*[local-name() = 'tab']">
								<xsl:apply-templates select="*[local-name() = 'tab'][1]/following-sibling::node()"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates/>
							</xsl:otherwise>
						</xsl:choose>
					</fo:block>
				</fo:list-item-body>
			</fo:list-item>
		</fo:list-block>
	</xsl:template><xsl:template name="extractTitle">
		<xsl:choose>
				<xsl:when test="*[local-name() = 'tab']">
					<xsl:apply-templates select="*[local-name() = 'tab'][1]/following-sibling::node()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
	</xsl:template><xsl:template match="*[local-name() = 'fn']" mode="contents"/><xsl:template match="*[local-name() = 'fn']" mode="contents_item"/><xsl:template match="*[local-name() = 'tab']" mode="contents_item">
		<xsl:text> </xsl:text>
	</xsl:template><xsl:template match="*[local-name() = 'strong']" mode="contents_item">
		<xsl:copy>
			<xsl:apply-templates mode="contents_item"/>
		</xsl:copy>		
	</xsl:template><xsl:template match="*[local-name() = 'br']" mode="contents_item">
		<xsl:text> </xsl:text>
	</xsl:template><xsl:template match="*[local-name()='sourcecode']" name="sourcecode">
		<fo:block xsl:use-attribute-sets="sourcecode-style">			
			<xsl:apply-templates/>			
		</fo:block>
		<xsl:apply-templates select="*[local-name()='name']" mode="presentation"/>
	</xsl:template><xsl:template match="*[local-name()='sourcecode']/text()">
		<xsl:variable name="text">
			<xsl:call-template name="add-zero-spaces-equal"/>
		</xsl:variable>
		<xsl:call-template name="add-zero-spaces">
			<xsl:with-param name="text" select="$text"/>
		</xsl:call-template>
	</xsl:template><xsl:template match="*[local-name() = 'sourcecode']/*[local-name() = 'name']"/><xsl:template match="*[local-name() = 'sourcecode']/*[local-name() = 'name']" mode="presentation">
		<xsl:if test="normalize-space() != ''">		
			<fo:block xsl:use-attribute-sets="sourcecode-name-style">
				
				<xsl:apply-templates/>
			</fo:block>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'permission']">
		<fo:block id="{@id}" xsl:use-attribute-sets="permission-style">			
			<xsl:apply-templates select="*[local-name()='name']" mode="presentation"/>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'permission']/*[local-name() = 'name']"/><xsl:template match="*[local-name() = 'permission']/*[local-name() = 'name']" mode="presentation">
		<xsl:if test="normalize-space() != ''">
			<fo:block xsl:use-attribute-sets="permission-name-style">
				<xsl:apply-templates/>
				
			</fo:block>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'permission']/*[local-name() = 'label']">
		<fo:block xsl:use-attribute-sets="permission-label-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'requirement']">
		<fo:block id="{@id}" xsl:use-attribute-sets="requirement-style">			
			<xsl:apply-templates select="*[local-name()='name']" mode="presentation"/>
			<xsl:apply-templates select="*[local-name()='label']" mode="presentation"/>
			<xsl:apply-templates select="@obligation" mode="presentation"/>
			<xsl:apply-templates select="*[local-name()='subject']" mode="presentation"/>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'requirement']/*[local-name() = 'name']"/><xsl:template match="*[local-name() = 'requirement']/*[local-name() = 'name']" mode="presentation">
		<xsl:if test="normalize-space() != ''">
			<fo:block xsl:use-attribute-sets="requirement-name-style">
				
				<xsl:apply-templates/>
				
			</fo:block>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'requirement']/*[local-name() = 'label']"/><xsl:template match="*[local-name() = 'requirement']/*[local-name() = 'label']" mode="presentation">
		<fo:block xsl:use-attribute-sets="requirement-label-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'requirement']/@obligation" mode="presentation">
			<fo:block>
				<fo:inline padding-right="3mm">Obligation</fo:inline><xsl:value-of select="."/>
			</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'requirement']/*[local-name() = 'subject']"/><xsl:template match="*[local-name() = 'requirement']/*[local-name() = 'subject']" mode="presentation">
		<fo:block xsl:use-attribute-sets="requirement-subject-style">
			<xsl:text>Target Type </xsl:text><xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'requirement']/*[local-name() = 'inherit']">
		<fo:block xsl:use-attribute-sets="requirement-inherit-style">
			<xsl:text>Dependency </xsl:text><xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'recommendation']">
		<fo:block id="{@id}" xsl:use-attribute-sets="recommendation-style">			
			<xsl:apply-templates select="*[local-name()='name']" mode="presentation"/>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'recommendation']/*[local-name() = 'name']"/><xsl:template match="*[local-name() = 'recommendation']/*[local-name() = 'name']" mode="presentation">
		<xsl:if test="normalize-space() != ''">
			<fo:block xsl:use-attribute-sets="recommendation-name-style">
				<xsl:apply-templates/>
				
			</fo:block>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'recommendation']/*[local-name() = 'label']">
		<fo:block xsl:use-attribute-sets="recommendation-label-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'table'][@class = 'recommendation' or @class='requirement' or @class='permission']">
		<fo:block-container margin-left="0mm" margin-right="0mm" margin-bottom="12pt">
			<fo:block-container margin-left="0mm" margin-right="0mm">
				<fo:table id="{@id}" table-layout="fixed" width="100%" border="0pt solid black">					
					<xsl:variable name="simple-table">	
						<xsl:call-template name="getSimpleTable"/>			
					</xsl:variable>					
					<xsl:variable name="cols-count" select="count(xalan:nodeset($simple-table)//tr[1]/td)"/>
					<xsl:if test="$cols-count = 2 and not(ancestor::*[local-name()='table'])">
						<fo:table-column column-width="35mm"/>
						<fo:table-column column-width="115mm"/>
					</xsl:if>
					<xsl:apply-templates mode="requirement"/>
				</fo:table>
				<!-- fn processing -->
				<xsl:if test=".//*[local-name() = 'fn']">
					<xsl:for-each select="*[local-name() = 'tbody']">
						<fo:block font-size="90%" border-bottom="1.pt solid black">
							<xsl:call-template name="fn_display"/>
						</fo:block>
					</xsl:for-each>
				</xsl:if>
			</fo:block-container>
		</fo:block-container>
	</xsl:template><xsl:template match="*[local-name()='thead']" mode="requirement">		
		<fo:table-header>			
			<xsl:apply-templates mode="requirement"/>
		</fo:table-header>
	</xsl:template><xsl:template match="*[local-name()='tbody']" mode="requirement">		
		<fo:table-body>
			<xsl:apply-templates mode="requirement"/>
		</fo:table-body>
	</xsl:template><xsl:template match="*[local-name()='tr']" mode="requirement">
		<fo:table-row>			
			<xsl:apply-templates mode="requirement"/>
		</fo:table-row>
	</xsl:template><xsl:template match="*[local-name()='th']" mode="requirement">
		<fo:table-cell text-align="{@align}">
			<xsl:attribute name="text-align">
				<xsl:choose>
					<xsl:when test="@align">
						<xsl:value-of select="@align"/>
					</xsl:when>
					<xsl:otherwise>center</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:if test="@colspan">
				<xsl:attribute name="number-columns-spanned">
					<xsl:value-of select="@colspan"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@rowspan">
				<xsl:attribute name="number-rows-spanned">
					<xsl:value-of select="@rowspan"/>
				</xsl:attribute>
			</xsl:if>
			
			<xsl:if test="ancestor::*[local-name()='table']/@type = 'recommend'">
				<xsl:attribute name="padding-top">0.5mm</xsl:attribute>
				<xsl:attribute name="background-color">rgb(165, 165, 165)</xsl:attribute>				
			</xsl:if>
			<xsl:if test="ancestor::*[local-name()='table']/@type = 'recommendtest'">
				<xsl:attribute name="padding-top">0.5mm</xsl:attribute>
				<xsl:attribute name="background-color">rgb(201, 201, 201)</xsl:attribute>				
			</xsl:if>
			
			<fo:block>
				<xsl:apply-templates/>
			</fo:block>
		</fo:table-cell>
	</xsl:template><xsl:template match="*[local-name()='td']" mode="requirement">
		<fo:table-cell text-align="{@align}">
			<xsl:attribute name="text-align">
				<xsl:choose>
					<xsl:when test="@align">
						<xsl:value-of select="@align"/>
					</xsl:when>
					<xsl:otherwise>left</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:if test="@colspan">
				<xsl:attribute name="number-columns-spanned">
					<xsl:value-of select="@colspan"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@rowspan">
				<xsl:attribute name="number-rows-spanned">
					<xsl:value-of select="@rowspan"/>
				</xsl:attribute>
			</xsl:if>
			
			<xsl:if test="ancestor::*[local-name()='table']/@type = 'recommend'">
				<xsl:attribute name="padding-left">0.5mm</xsl:attribute>
				<xsl:attribute name="padding-top">0.5mm</xsl:attribute>
				<xsl:if test="parent::*[local-name()='tr']/preceding-sibling::*[local-name()='tr'] and not(*[local-name()='table'])"> <!-- 2nd line and below -->
					<xsl:attribute name="background-color">rgb(201, 201, 201)</xsl:attribute>					
				</xsl:if>
			</xsl:if>
			
			<fo:block>			
				<xsl:apply-templates/>
			</fo:block>			
		</fo:table-cell>
	</xsl:template><xsl:template match="*[local-name() = 'p'][@class='RecommendationTitle' or @class = 'RecommendationTestTitle']" priority="2">
		<fo:block font-size="11pt" font-weight="bold" text-align="center" margin-bottom="4pt">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'p'][ancestor::*[local-name() = 'table'][@class = 'recommendation' or @class='requirement' or @class='permission']]">
		<fo:block margin-bottom="10pt">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'termexample']">
		<fo:block id="{@id}" xsl:use-attribute-sets="termexample-style">			
			<xsl:apply-templates select="*[local-name()='name']" mode="presentation"/>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'termexample']/*[local-name() = 'name']"/><xsl:template match="*[local-name() = 'termexample']/*[local-name() = 'name']" mode="presentation">
		<xsl:if test="normalize-space() != ''">
			<fo:inline xsl:use-attribute-sets="termexample-name-style">
				<xsl:apply-templates/>
			</fo:inline>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'termexample']/*[local-name() = 'p']">
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'example']">
		<fo:block id="{@id}" xsl:use-attribute-sets="example-style">
			
			<xsl:apply-templates select="*[local-name()='name']" mode="presentation"/>
			
			<xsl:variable name="element">
				block
				
			</xsl:variable>
			
			<xsl:choose>
				<xsl:when test="normalize-space($element) = 'block'">
					<fo:block xsl:use-attribute-sets="example-body-style">
						<xsl:apply-templates/>
					</fo:block>
				</xsl:when>
				<xsl:otherwise>
					<fo:inline>
						<xsl:apply-templates/>
					</fo:inline>
				</xsl:otherwise>
			</xsl:choose>
			
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'example']/*[local-name() = 'name']"/><xsl:template match="*[local-name() = 'example']/*[local-name() = 'name']" mode="presentation">

		<xsl:variable name="element">
			block
			
		</xsl:variable>		
		<xsl:choose>
			<xsl:when test="ancestor::*[local-name() = 'appendix']">
				<fo:inline>
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:when>
			<xsl:when test="normalize-space($element) = 'block'">
				<fo:block xsl:use-attribute-sets="example-name-style">
					<xsl:apply-templates/>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline xsl:use-attribute-sets="example-name-style">
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template><xsl:template match="*[local-name() = 'example']/*[local-name() = 'p']">		
		<fo:block xsl:use-attribute-sets="example-p-style">
			
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'termsource']">
		<fo:block xsl:use-attribute-sets="termsource-style">
			<!-- Example: [SOURCE: ISO 5127:2017, 3.1.6.02] -->			
			<xsl:variable name="termsource_text">
				<xsl:apply-templates/>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="starts-with(normalize-space($termsource_text), '[')">
					<xsl:apply-templates/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>[</xsl:text>
					<xsl:apply-templates/>
					<xsl:text>]</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'termsource']/text()">
		<xsl:if test="normalize-space() != ''">
			<xsl:value-of select="."/>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'origin']">
		<fo:basic-link internal-destination="{@bibitemid}" fox:alt-text="{@citeas}">
			
			<fo:inline xsl:use-attribute-sets="origin-style">
				<xsl:apply-templates/>
			</fo:inline>
			</fo:basic-link>
	</xsl:template><xsl:template match="*[local-name() = 'modification']/*[local-name() = 'p']">
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'modification']/text()">
		<xsl:if test="normalize-space() != ''">
			<xsl:value-of select="."/>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'quote']">
		
		<fo:block xsl:use-attribute-sets="quote-style">
			<xsl:apply-templates select=".//*[local-name() = 'p']"/>
		</fo:block>
		<xsl:if test="*[local-name() = 'author'] or *[local-name() = 'source']">
			<fo:block xsl:use-attribute-sets="quote-source-style">
				<!-- — ISO, ISO 7301:2011, Clause 1 -->
				<xsl:apply-templates select="*[local-name() = 'author']"/>
				<xsl:apply-templates select="*[local-name() = 'source']"/>				
			</fo:block>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'source']">
		<xsl:if test="../*[local-name() = 'author']">
			<xsl:text>, </xsl:text>
		</xsl:if>
		<fo:basic-link internal-destination="{@bibitemid}" fox:alt-text="{@citeas}">
			<xsl:apply-templates/>
		</fo:basic-link>
	</xsl:template><xsl:template match="*[local-name() = 'author']">
		<xsl:text>— </xsl:text>
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name() = 'eref']">
		<fo:inline xsl:use-attribute-sets="eref-style">
			<xsl:if test="@type = 'footnote'">
				
					<xsl:attribute name="keep-together.within-line">always</xsl:attribute>
					<xsl:attribute name="font-size">80%</xsl:attribute>
					<xsl:attribute name="keep-with-previous.within-line">always</xsl:attribute>
					<xsl:attribute name="vertical-align">super</xsl:attribute>
									
				
			</xsl:if>	
		
			<fo:basic-link internal-destination="{@bibitemid}" fox:alt-text="{@citeas}">
					
				<xsl:if test="@type = 'inline'">
					
					
				</xsl:if>
			
			
				<xsl:apply-templates/>
			</fo:basic-link>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'tab']">
		<!-- zero-space char -->
		<xsl:variable name="depth">
			<xsl:call-template name="getLevel">
				<xsl:with-param name="depth" select="../@depth"/>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="padding">
			
			
			
			
			
			
			
				<xsl:choose>
					<xsl:when test="$depth = 5">7</xsl:when>
					<xsl:when test="$depth = 4">10</xsl:when>
					<xsl:when test="$depth = 3">6</xsl:when>
					<xsl:when test="$depth = 2">9</xsl:when>
					<xsl:otherwise>12</xsl:otherwise>
				</xsl:choose>
			
			
			
			
			
			
			
			
			
			
			
		</xsl:variable>
		
		<xsl:variable name="padding-right">
			<xsl:choose>
				<xsl:when test="normalize-space($padding) = ''">0</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space($padding)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="language" select="//*[local-name()='bibdata']//*[local-name()='language']"/>
		
		<xsl:choose>
			<xsl:when test="$language = 'zh'">
				<fo:inline><xsl:value-of select="$tab_zh"/></fo:inline>
			</xsl:when>
			<xsl:when test="../../@inline-header = 'true'">
				<fo:inline font-size="90%">
					<xsl:call-template name="insertNonBreakSpaces">
						<xsl:with-param name="count" select="$padding-right"/>
					</xsl:call-template>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline padding-right="{$padding-right}mm">​</fo:inline>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template><xsl:template name="insertNonBreakSpaces">
		<xsl:param name="count"/>
		<xsl:if test="$count &gt; 0">
			<xsl:text> </xsl:text>
			<xsl:call-template name="insertNonBreakSpaces">
				<xsl:with-param name="count" select="$count - 1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'domain']">
		<fo:inline xsl:use-attribute-sets="domain-style">&lt;<xsl:apply-templates/>&gt;</fo:inline>
		<xsl:text> </xsl:text>
	</xsl:template><xsl:template match="*[local-name() = 'admitted']">
		<fo:block xsl:use-attribute-sets="admitted-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'deprecates']">
		<xsl:variable name="title-deprecated">
			<xsl:call-template name="getTitle">
				<xsl:with-param name="name" select="'title-deprecated'"/>
			</xsl:call-template>
		</xsl:variable>
		<fo:block xsl:use-attribute-sets="deprecates-style">
			<xsl:value-of select="$title-deprecated"/>: <xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'definition']">
		<fo:block xsl:use-attribute-sets="definition-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'definition'][preceding-sibling::*[local-name() = 'domain']]">
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name() = 'definition'][preceding-sibling::*[local-name() = 'domain']]/*[local-name() = 'p']">
		<fo:inline> <xsl:apply-templates/></fo:inline>
		<fo:block> </fo:block>
	</xsl:template><xsl:template match="/*/*[local-name() = 'sections']/*" priority="2">
		
		<fo:block>
			<xsl:call-template name="setId"/>
			
			
			
			
						
			
						
			
			
			
			<xsl:apply-templates/>
		</fo:block>
		
		
		
	</xsl:template><xsl:template match="/*/*[local-name() = 'preface']/*" priority="2">
		<fo:block break-after="page"/>
		<fo:block>
			<xsl:call-template name="setId"/>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'clause']">
		<fo:block>
			<xsl:call-template name="setId"/>			
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'definitions']">
		<fo:block id="{@id}">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="/*/*[local-name() = 'bibliography']/*[local-name() = 'references'][@normative='true']">
		
		<fo:block id="{@id}">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'annex']">
		<fo:block break-after="page"/>
		<fo:block id="{@id}">
			
		</fo:block>
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name() = 'review']">
		<!-- comment 2019-11-29 -->
		<!-- <fo:block font-weight="bold">Review:</fo:block>
		<xsl:apply-templates /> -->
	</xsl:template><xsl:template match="*[local-name() = 'name']/text()">
		<!-- 0xA0 to space replacement -->
		<xsl:value-of select="java:replaceAll(java:java.lang.String.new(.),' ',' ')"/>
	</xsl:template><xsl:template match="*[local-name() = 'errata']">
		<!-- <row>
					<date>05-07-2013</date>
					<type>Editorial</type>
					<change>Changed CA-9 Priority Code from P1 to P2 in <xref target="tabled2"/>.</change>
					<pages>D-3</pages>
				</row>
		-->
		<fo:table table-layout="fixed" width="100%" font-size="10pt" border="1pt solid black">
			<fo:table-column column-width="20mm"/>
			<fo:table-column column-width="23mm"/>
			<fo:table-column column-width="107mm"/>
			<fo:table-column column-width="15mm"/>
			<fo:table-body>
				<fo:table-row font-family="Arial" text-align="center" font-weight="bold" background-color="black" color="white">
					<fo:table-cell border="1pt solid black"><fo:block>Date</fo:block></fo:table-cell>
					<fo:table-cell border="1pt solid black"><fo:block>Type</fo:block></fo:table-cell>
					<fo:table-cell border="1pt solid black"><fo:block>Change</fo:block></fo:table-cell>
					<fo:table-cell border="1pt solid black"><fo:block>Pages</fo:block></fo:table-cell>
				</fo:table-row>
				<xsl:apply-templates/>
			</fo:table-body>
		</fo:table>
	</xsl:template><xsl:template match="*[local-name() = 'errata']/*[local-name() = 'row']">
		<fo:table-row>
			<xsl:apply-templates/>
		</fo:table-row>
	</xsl:template><xsl:template match="*[local-name() = 'errata']/*[local-name() = 'row']/*">
		<fo:table-cell border="1pt solid black" padding-left="1mm" padding-top="0.5mm">
			<fo:block><xsl:apply-templates/></fo:block>
		</fo:table-cell>
	</xsl:template><xsl:template name="convertDate">
		<xsl:param name="date"/>
		<xsl:param name="format" select="'short'"/>
		<xsl:variable name="year" select="substring($date, 1, 4)"/>
		<xsl:variable name="month" select="substring($date, 6, 2)"/>
		<xsl:variable name="day" select="substring($date, 9, 2)"/>
		<xsl:variable name="monthStr">
			<xsl:choose>
				<xsl:when test="$month = '01'">January</xsl:when>
				<xsl:when test="$month = '02'">February</xsl:when>
				<xsl:when test="$month = '03'">March</xsl:when>
				<xsl:when test="$month = '04'">April</xsl:when>
				<xsl:when test="$month = '05'">May</xsl:when>
				<xsl:when test="$month = '06'">June</xsl:when>
				<xsl:when test="$month = '07'">July</xsl:when>
				<xsl:when test="$month = '08'">August</xsl:when>
				<xsl:when test="$month = '09'">September</xsl:when>
				<xsl:when test="$month = '10'">October</xsl:when>
				<xsl:when test="$month = '11'">November</xsl:when>
				<xsl:when test="$month = '12'">December</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="result">
			<xsl:choose>
				<xsl:when test="$format = 'short' or $day = ''">
					<xsl:value-of select="normalize-space(concat($monthStr, ' ', $year))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(concat($monthStr, ' ', $day, ', ' , $year))"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$result"/>
	</xsl:template><xsl:template name="insertKeywords">
		<xsl:param name="sorting" select="'true'"/>
		<xsl:param name="charAtEnd" select="'.'"/>
		<xsl:param name="charDelim" select="', '"/>
		<xsl:choose>
			<xsl:when test="$sorting = 'true' or $sorting = 'yes'">
				<xsl:for-each select="/*/*[local-name() = 'bibdata']//*[local-name() = 'keyword']">
					<xsl:sort data-type="text" order="ascending"/>
					<xsl:call-template name="insertKeyword">
						<xsl:with-param name="charAtEnd" select="$charAtEnd"/>
						<xsl:with-param name="charDelim" select="$charDelim"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="/*/*[local-name() = 'bibdata']//*[local-name() = 'keyword']">
					<xsl:call-template name="insertKeyword">
						<xsl:with-param name="charAtEnd" select="$charAtEnd"/>
						<xsl:with-param name="charDelim" select="$charDelim"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="insertKeyword">
		<xsl:param name="charAtEnd"/>
		<xsl:param name="charDelim"/>
		<xsl:apply-templates/>
		<xsl:choose>
			<xsl:when test="position() != last()"><xsl:value-of select="$charDelim"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$charAtEnd"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="addPDFUAmeta">
		<fo:declarations>
			<pdf:catalog xmlns:pdf="http://xmlgraphics.apache.org/fop/extensions/pdf">
					<pdf:dictionary type="normal" key="ViewerPreferences">
						<pdf:boolean key="DisplayDocTitle">true</pdf:boolean>
					</pdf:dictionary>
				</pdf:catalog>
			<x:xmpmeta xmlns:x="adobe:ns:meta/">
				<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
					<rdf:Description xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:pdf="http://ns.adobe.com/pdf/1.3/" rdf:about="">
					<!-- Dublin Core properties go here -->
						<dc:title>
							<xsl:variable name="title">
								
								
								
								
									<xsl:value-of select="/*/*[local-name() = 'bibdata']/*[local-name() = 'title'][@type='main']"/>
																
							</xsl:variable>
							<xsl:choose>
								<xsl:when test="normalize-space($title) != ''">
									<xsl:value-of select="$title"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text> </xsl:text>
								</xsl:otherwise>
							</xsl:choose>							
						</dc:title>
						<dc:creator>
							
								<xsl:value-of select="/*/*[local-name() = 'bibdata']/*[local-name() = 'contributor'][*[local-name() = 'role']/@type='author']/*[local-name() = 'organization']/*[local-name() = 'name']"/>
							
							
						</dc:creator>
						<dc:description>
							<xsl:variable name="abstract">
								
								
								
								
									<xsl:copy-of select="/*/*[local-name() = 'bibdata']/*[local-name() = 'abstract']//text()"/>									
								
							</xsl:variable>
							<xsl:value-of select="normalize-space($abstract)"/>
						</dc:description>
						<pdf:Keywords>
							<xsl:call-template name="insertKeywords"/>
						</pdf:Keywords>
					</rdf:Description>
					<rdf:Description xmlns:xmp="http://ns.adobe.com/xap/1.0/" rdf:about="">
						<!-- XMP properties go here -->
						<xmp:CreatorTool/>
					</rdf:Description>
				</rdf:RDF>
			</x:xmpmeta>
		</fo:declarations>
	</xsl:template><xsl:template name="getId">
		<xsl:choose>
			<xsl:when test="../@id">
				<xsl:value-of select="../@id"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- <xsl:value-of select="concat(local-name(..), '_', text())"/> -->
				<xsl:value-of select="concat(generate-id(..), '_', text())"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="getLevel">
		<xsl:param name="depth"/>
		<xsl:choose>
			<xsl:when test="normalize-space(@depth) != ''">
				<xsl:value-of select="@depth"/>
			</xsl:when>
			<xsl:when test="normalize-space($depth) != ''">
				<xsl:value-of select="$depth"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="level_total" select="count(ancestor::*)"/>
				<xsl:variable name="level">
					<xsl:choose>
						<xsl:when test="parent::*[local-name() = 'preface']">
							<xsl:value-of select="$level_total - 1"/>
						</xsl:when>
						<xsl:when test="ancestor::*[local-name() = 'preface']">
							<xsl:value-of select="$level_total - 2"/>
						</xsl:when>
						<!-- <xsl:when test="parent::*[local-name() = 'sections']">
							<xsl:value-of select="$level_total - 1"/>
						</xsl:when> -->
						<xsl:when test="ancestor::*[local-name() = 'sections']">
							<xsl:value-of select="$level_total - 1"/>
						</xsl:when>
						<xsl:when test="ancestor::*[local-name() = 'bibliography']">
							<xsl:value-of select="$level_total - 1"/>
						</xsl:when>
						<xsl:when test="parent::*[local-name() = 'annex']">
							<xsl:value-of select="$level_total - 1"/>
						</xsl:when>
						<xsl:when test="ancestor::*[local-name() = 'annex']">
							<xsl:value-of select="$level_total"/>
						</xsl:when>
						<xsl:when test="local-name() = 'annex'">1</xsl:when>
						<xsl:when test="local-name(ancestor::*[1]) = 'annex'">1</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$level_total - 1"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:value-of select="$level"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="split">
		<xsl:param name="pText" select="."/>
		<xsl:param name="sep" select="','"/>
		<xsl:if test="string-length($pText) &gt;0">
		<item>
			<xsl:value-of select="normalize-space(substring-before(concat($pText, ','), $sep))"/>
		</item>
		<xsl:call-template name="split">
			<xsl:with-param name="pText" select="substring-after($pText, $sep)"/>
			<xsl:with-param name="sep" select="$sep"/>
		</xsl:call-template>
		</xsl:if>
	</xsl:template><xsl:template name="getDocumentId">		
		<xsl:call-template name="getLang"/><xsl:value-of select="//*[local-name() = 'p'][1]/@id"/>
	</xsl:template><xsl:template name="namespaceCheck">
		<xsl:variable name="documentNS" select="namespace-uri(/*)"/>
		<xsl:variable name="XSLNS">			
			
			
			
				<xsl:value-of select="document('')//*/namespace::itu"/>
			
			
			
			
			
			
			
			
						
			
			
		</xsl:variable>
		<xsl:if test="$documentNS != $XSLNS">
			<xsl:message>[WARNING]: Document namespace: '<xsl:value-of select="$documentNS"/>' doesn't equal to xslt namespace '<xsl:value-of select="$XSLNS"/>'</xsl:message>
		</xsl:if>
	</xsl:template><xsl:template name="getLanguage">
		<xsl:param name="lang"/>		
		<xsl:variable name="language" select="java:toLowerCase(java:java.lang.String.new($lang))"/>
		<xsl:choose>
			<xsl:when test="$language = 'en'">English</xsl:when>
			<xsl:when test="$language = 'fr'">French</xsl:when>
			<xsl:when test="$language = 'de'">Deutsch</xsl:when>
			<xsl:when test="$language = 'cn'">Chinese</xsl:when>
			<xsl:otherwise><xsl:value-of select="$language"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="setId">
		<xsl:attribute name="id">
			<xsl:choose>
				<xsl:when test="@id">
					<xsl:value-of select="@id"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="generate-id()"/>
				</xsl:otherwise>
			</xsl:choose>					
		</xsl:attribute>
	</xsl:template></xsl:stylesheet>
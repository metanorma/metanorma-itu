<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:itu="https://open.ribose.com/standards/itu" xmlns:mathml="http://www.w3.org/1998/Math/MathML" xmlns:xalan="http://xml.apache.org/xalan" xmlns:fox="http://xmlgraphics.apache.org/fop/extensions" version="1.0">

	<xsl:output method="xml" encoding="UTF-8" indent="no"/>

	
	
	
	
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
		<xsl:value-of select="translate(substring(/itu:itu-standard/itu:bibdata/itu:ext/itu:doctype,1,1),$lower,$upper)"/>
		<xsl:value-of select="substring(/itu:itu-standard/itu:bibdata/itu:ext/itu:doctype,2)"/>
	</xsl:variable>
	
	
	<!-- Example:
		<item level="1" id="Foreword" display="true">Foreword</item>
		<item id="term-script" display="false">3.2</item>
	-->
	<xsl:variable name="contents">
		<contents>
			<!-- <xsl:apply-templates select="/itu:itu-standard/itu:preface/node()" mode="contents"/> -->
			<xsl:apply-templates select="/itu:itu-standard/itu:sections/itu:clause[1]" mode="contents"> <!-- @id = 'scope' -->
				<xsl:with-param name="sectionNum" select="'1'"/>
			</xsl:apply-templates>
			<xsl:variable name="numskew" select="count(/itu:itu-standard/itu:bibliography/itu:references[1])"/>
			<xsl:apply-templates select="/itu:itu-standard/itu:bibliography/itu:references[1]" mode="contents"> <!-- @id = 'references' -->
				<xsl:with-param name="sectionNum" select="1 + number($numskew)"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="/itu:itu-standard/itu:sections/*[position() != 1]" mode="contents"> <!-- @id != 'scope' -->
				<xsl:with-param name="sectionNumSkew" select="number($numskew)"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="/itu:itu-standard/itu:annex" mode="contents"/>
			<xsl:apply-templates select="/itu:itu-standard/itu:bibliography/itu:references[position() != 1]" mode="contents"/> <!-- @id = 'bibliography' -->
			
			<xsl:apply-templates select="//itu3" mode="contents"/>
			
			<xsl:apply-templates select="//itu:table" mode="contents"/>
			
		</contents>
	</xsl:variable>

	<xsl:variable name="lang">
		<xsl:call-template name="getLang"/>
	</xsl:variable>
	
	<xsl:template match="/">
		<fo:root font-family="Times New Roman, Cambria Math" font-size="12pt" xml:lang="{$lang}">
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
							<dc:title><xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:title[@type='main']"/></dc:title>
							<dc:creator><xsl:value-of select="/itu:iso-standard/itu:bibdata/itu:contributor[itu:role/@type='author']/itu:organization/itu:name"/></dc:creator>
							<dc:description>
								<xsl:variable name="abstract">
									<xsl:copy-of select="/itu:itu-standard/itu:bibdata/itu:abstract//text()"/>
								</xsl:variable>
								<xsl:value-of select="normalize-space($abstract)"/>
							</dc:description>
							<pdf:Keywords>
								<xsl:for-each select="/itu:itu-standard/itu:bibdata//itu:keyword">
								<xsl:sort data-type="text" order="ascending"/>
								<xsl:apply-templates/>
								<xsl:choose>
									<xsl:when test="position() != last()">, </xsl:when>
									<xsl:otherwise>.</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
							</pdf:Keywords>
						</rdf:Description>
						<rdf:Description xmlns:xmp="http://ns.adobe.com/xap/1.0/" rdf:about="">
							<!-- XMP properties go here -->
							<xmp:CreatorTool/>
						</rdf:Description>
					</rdf:RDF>
				</x:xmpmeta>
			</fo:declarations>
			
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
								<fo:table-row height="42.5mm">
									<fo:table-cell>
										<fo:block> </fo:block>
									</fo:table-cell>
									<fo:table-cell number-columns-spanned="3">
										<fo:block font-family="Arial" font-size="13pt" font-weight="bold" color="gray" margin-top="16pt"> <!-- letter-spacing="4pt", Helvetica for letter-spacing working -->
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
												<xsl:text>Annex </xsl:text><xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:structuredidentifier/itu:annexid"/>
											</fo:block>
										</xsl:if>
										<fo:block font-size="14pt">
											<xsl:call-template name="formatDate">
												<xsl:with-param name="date" select="/itu:itu-standard/itu:bibdata/itu:date[@type = 'published']/itu:on"/>
											</xsl:call-template>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
								<fo:table-row height="59mm">
									<fo:table-cell>
										<fo:block> </fo:block>
									</fo:table-cell>
									<fo:table-cell font-size="16pt" number-columns-spanned="3" border-bottom="0.5mm solid black" padding-right="2mm">
										<fo:block>
											<xsl:if test="normalize-space(/itu:itu-standard/itu:bibdata/itu:series[@type = 'main']) != ''">
												<xsl:variable name="title">
													<xsl:text>Series </xsl:text>
													<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:series[@type = 'main']"/>
												</xsl:variable>
												<xsl:value-of select="translate($title, $lower, $upper)"/>
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
												<xsl:text> — Annex </xsl:text><xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:structuredidentifier/itu:annexid"/>
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
					<xsl:apply-templates select="/itu:itu-standard/itu:preface/node()"/>
					
					<!-- Keywords -->
					<xsl:if test="/itu:itu-standard/itu:bibdata/itu:keyword">
						<fo:block font-size="12pt">
							<xsl:value-of select="$linebreak"/>
							<xsl:value-of select="$linebreak"/>
						</fo:block>
						<fo:block font-weight="bold" margin-top="18pt" margin-bottom="18pt">
							<xsl:text>Keywords</xsl:text>
						</fo:block>
						<fo:block>
							<xsl:for-each select="/itu:itu-standard/itu:bibdata//itu:keyword">
								<xsl:sort data-type="text" order="ascending"/>
								<xsl:apply-templates/>
								<xsl:choose>
									<xsl:when test="position() != last()">, </xsl:when>
									<xsl:otherwise>.</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</fo:block>
					</xsl:if>
					
					<fo:block break-after="page"/>
					
					<!-- FOREWORD -->
					<fo:block font-size="11pt" text-align="justify">
						<xsl:apply-templates select="/itu:itu-standard/itu:boilerplate/itu:legal-statement"/>
						<xsl:apply-templates select="/itu:itu-standard/itu:boilerplate/itu:license-statement"/>
						<xsl:apply-templates select="/itu:itu-standard/itu:boilerplate/itu:copyright-statement"/>
					</fo:block>
					
					<xsl:text disable-output-escaping="yes">&lt;!--</xsl:text>
						DEBUG
						contents=<xsl:copy-of select="xalan:nodeset($contents)"/>
					<xsl:text disable-output-escaping="yes">--&gt;</xsl:text>
					
					<xsl:if test="xalan:nodeset($contents)//item">
						<fo:block break-after="page"/>
						<fo:block-container>
							<fo:block margin-top="6pt" text-align="center" font-weight="bold">Table of Contents</fo:block>
							<fo:block margin-top="6pt" text-align="right" font-weight="bold">Page</fo:block>
							
								<xsl:for-each select="xalan:nodeset($contents)//item">
									<xsl:if test="@display = 'true'">
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
														<xsl:when test="@section != '' and not(@display-section = 'false')">
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
															<xsl:if test="@section and not(@display-section = 'false')"> <!--   -->
																<xsl:if test="@type = 'annex'">
																	<xsl:attribute name="font-weight">bold</xsl:attribute>
																</xsl:if>
																<xsl:value-of select="@section"/>
															</xsl:if>
														</fo:block>
													</fo:list-item-label>
														<fo:list-item-body start-indent="body-start()">
															<fo:block text-align-last="justify" margin-left="12mm" text-indent="-12mm">
																<xsl:if test="@type = 'annex'">
																	<xsl:attribute name="font-weight">bold</xsl:attribute>
																</xsl:if>
																<fo:basic-link internal-destination="{@id}" fox:alt-text="text()">
																	<xsl:value-of select="text()"/>
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
									</xsl:if>
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
						<xsl:apply-templates select="/itu:itu-standard/itu:sections/itu:clause[1]"> <!-- @id = 'scope' -->
							<xsl:with-param name="sectionNum" select="'1'"/>
						</xsl:apply-templates>
						<!-- References -->
						<xsl:variable name="numskew" select="count(/itu:itu-standard/itu:bibliography/itu:references[1])"/>
						<xsl:apply-templates select="/itu:itu-standard/itu:bibliography/itu:references[1]"> <!-- @id = 'references' -->
							<xsl:with-param name="sectionNum" select="1 + number($numskew)"/>
						</xsl:apply-templates>
						
						<xsl:apply-templates select="/itu:itu-standard/itu:sections/*[position() != 1]"> <!-- @id != 'scope' -->
							<xsl:with-param name="sectionNumSkew" select="number($numskew)"/>
						</xsl:apply-templates>
						
						<xsl:apply-templates select="/itu:itu-standard/itu:annex"/>
						
						<!-- Bibliography -->
						<xsl:apply-templates select="/itu:itu-standard/itu:bibliography/itu:references[position() != 1]"/> <!-- @id = 'bibliography' -->
					</fo:block>
					
				</fo:flow>
			</fo:page-sequence>
			
			
		</fo:root>
	</xsl:template> 

	<!-- for pass the paremeter 'sectionNum' over templates, like 'tunnel' parameter in XSLT 2.0 -->
	<xsl:template match="node()">
		<xsl:param name="sectionNum"/>
		<xsl:param name="sectionNumSkew"/>
		<xsl:apply-templates>
			<xsl:with-param name="sectionNum" select="$sectionNum"/>
			<xsl:with-param name="sectionNumSkew" select="$sectionNumSkew"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- ============================= -->
	<!-- CONTENTS                                       -->
	<!-- ============================= -->
	<xsl:template match="node()" mode="contents">
		<xsl:param name="sectionNum"/>
		<xsl:param name="sectionNumSkew"/>
		<xsl:apply-templates mode="contents">
			<xsl:with-param name="sectionNum" select="$sectionNum"/>
			<xsl:with-param name="sectionNumSkew" select="$sectionNumSkew"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- <xsl:template match="itu:itu-standard/itu:preface/*" mode="contents">
		<xsl:apply-templates mode="contents"/>
	</xsl:template> -->
	
	<!-- calculate main section number (1,2,3) and pass it deep into templates -->
	<!-- it's necessary, because there is itu:bibliography/itu:references from other section, but numbering should be sequental -->
	<xsl:template match="itu:itu-standard/itu:sections/*" mode="contents">
		<xsl:param name="sectionNum"/>
		<xsl:param name="sectionNumSkew" select="-1"/>
		<xsl:variable name="sectionNum_">
			<xsl:choose>
				<xsl:when test="$sectionNum"><xsl:value-of select="$sectionNum"/></xsl:when>
				<xsl:when test="$sectionNumSkew != -1">
					<xsl:variable name="number"><xsl:number count="*"/></xsl:variable> <!-- itu:sections/itu:clause | itu:sections/itu:terms | ??? -->
					<xsl:value-of select="$number + $sectionNumSkew"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<!-- <xsl:message>
			DEBUG sectionNum=<xsl:value-of select="$sectionNum_"/>
		</xsl:message> -->
		<xsl:apply-templates mode="contents">
			<xsl:with-param name="sectionNum" select="$sectionNum_"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- Any node with title element - clause, definition, annex,... -->
	<xsl:template match="itu:title | itu:preferred" mode="contents">
		<xsl:param name="sectionNum"/>
		<!-- sectionNum=<xsl:value-of select="$sectionNum"/> -->
		<xsl:variable name="id">
			<xsl:choose>
				<xsl:when test="../@id">
					<xsl:value-of select="../@id"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="text()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		
		<!-- <xsl:message>
			level=<xsl:value-of select="$level"/>=<xsl:value-of select="."/>
		</xsl:message> -->
		
		<xsl:variable name="section">
			<xsl:call-template name="getSection">
				<xsl:with-param name="sectionNum" select="$sectionNum"/>
			</xsl:call-template>
		</xsl:variable>
			
		<xsl:variable name="display">
			<xsl:choose>
				<!-- <xsl:when test="ancestor::itu:annex">true</xsl:when> -->
				<xsl:when test="$level &lt;= 2">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="type">
			<xsl:value-of select="local-name(..)"/>
		</xsl:variable>
		
		<item id="{$id}" level="{$level}" section="{$section}" display="{$display}" type="{$type}">
			<xsl:value-of select="."/>
		</item>
		
		<xsl:apply-templates mode="contents">
			<xsl:with-param name="sectionNum" select="$sectionNum"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="itu:clause[not(itu:title)]" mode="contents">
		<xsl:param name="sectionNum"/>
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		<xsl:variable name="section">
			<xsl:for-each select="*[1]">
				<xsl:call-template name="getSection">
					<xsl:with-param name="sectionNum" select="$sectionNum"/>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:variable>
		<item id="{@id}" level="{$level}" section="{$section}" display="false" type="clause">
			<xsl:value-of select="."/>
		</item>
		<xsl:apply-templates mode="contents">
			<xsl:with-param name="sectionNum" select="$sectionNum"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="itu:bibitem" mode="contents"/>

	<xsl:template match="itu:references" mode="contents">
		<xsl:param name="sectionNum"/>
		<xsl:apply-templates mode="contents">
			<xsl:with-param name="sectionNum" select="$sectionNum"/>
		</xsl:apply-templates>
	</xsl:template>

	
	<xsl:template match="itu:figure" mode="contents">
		<xsl:param name="sectionNum"/>
		<item level="" id="{@id}" display="false" type="figure">
			<xsl:variable name="title">Figure </xsl:variable>
			<xsl:attribute name="section">
				<xsl:call-template name="getSection">
					<xsl:with-param name="sectionNum" select="$sectionNum"/>
				</xsl:call-template>
				<!-- <xsl:text>Figure </xsl:text>
				<xsl:call-template name="getItemNumber">
					<xsl:with-param name="brackets" select="'false'"/>
				</xsl:call-template> -->
			</xsl:attribute>
			<xsl:value-of select="$title"/>
			<xsl:call-template name="getItemNumber">
				<xsl:with-param name="brackets" select="'false'"/>
			</xsl:call-template>
		</item>
		<xsl:apply-templates mode="contents">
			<xsl:with-param name="sectionNum" select="$sectionNum"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="itu:table" mode="contents">
		<xsl:param name="sectionNum"/>
		<item level="" id="{@id}" display="false" type="table">
			<xsl:variable name="title">Table </xsl:variable>
			<xsl:attribute name="section">
				<xsl:call-template name="getSection">
					<xsl:with-param name="sectionNum" select="$sectionNum"/>
				</xsl:call-template>
				<!-- <xsl:text>Table </xsl:text>
				<xsl:call-template name="getItemNumber"/> -->
			</xsl:attribute>
			<xsl:value-of select="$title"/>
			<xsl:call-template name="getItemNumber">
				<xsl:with-param name="brackets" select="'false'"/>
			</xsl:call-template>
		</item>
		<xsl:apply-templates mode="contents">
			<xsl:with-param name="sectionNum" select="$sectionNum"/>
		</xsl:apply-templates>
	</xsl:template>
	
	
	<xsl:template match="itu:formula" mode="contents">
		<xsl:param name="sectionNum"/>
		<item level="" id="{@id}" display="false" type="formula">
			<xsl:variable name="title">
				<xsl:choose>
					<xsl:when test="@inequality = 'true'">Inequality </xsl:when>
					<xsl:otherwise>Equation </xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:attribute name="section">
				<xsl:call-template name="getSection">
					<xsl:with-param name="sectionNum" select="$sectionNum"/>
				</xsl:call-template>
				<!-- <xsl:value-of select="$title"/>
				<xsl:call-template name="getItemNumber"/> -->
			</xsl:attribute>
			<xsl:variable name="parent-element" select="local-name(..)"/>
			<xsl:attribute name="parent">
				<xsl:choose>
					<xsl:when test="$parent-element = 'clause'">Clause</xsl:when>
					<xsl:otherwise/>
				</xsl:choose>
			</xsl:attribute>
			<xsl:value-of select="$title"/>
			<xsl:call-template name="getItemNumber"/>
		</item>
		<xsl:apply-templates mode="contents">
			<xsl:with-param name="sectionNum" select="$sectionNum"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template name="getItemNumber">
		<xsl:param name="brackets" select="'true'"/>
		<xsl:variable name="name" select="local-name()"/>
		<xsl:choose>
			<xsl:when test="@unnumbered = 'true'"/>
			<xsl:when test="count(//itu:annex) = 1 and ancestor::*[local-name()='annex'] and /itu:itu-standard/itu:bibdata/itu:ext/itu:structuredidentifier/itu:annexid">
				<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:structuredidentifier/itu:annexid"/>
				<xsl:number format="-1" level="any" count="itu:annex//*[local-name()=$name]"/>
			</xsl:when>
			<xsl:when test="ancestor::itu:annex[@obligation = 'informative']">
				<xsl:variable name="annex-id" select="ancestor::itu:annex/@id"/>
				<!-- Annex -->
				<xsl:if test="$brackets = 'true'">
					<xsl:text>(</xsl:text>
				</xsl:if>
				<xsl:number format="I-" count="itu:annex[@obligation = 'informative']"/>
				<xsl:number format="1" level="any" count="*[local-name()=$name][(not(@unnumbered) or @unnumbered != 'true') and ancestor::itu:annex[@id = $annex-id]]"/>
				<xsl:if test="$brackets = 'true'">
					<xsl:text>)</xsl:text>
				</xsl:if>
			</xsl:when>
			<!-- Appendix -->
			<xsl:when test="ancestor::itu:annex[not(@obligation) or @obligation != 'informative']">
				<xsl:variable name="annex-id" select="ancestor::itu:annex/@id"/>
				<xsl:if test="$brackets = 'true'">
					<xsl:text>(</xsl:text>
				</xsl:if>
				<xsl:number format="A-" count="itu:annex[not(@obligation) or @obligation != 'informative']"/>
				<xsl:number format="1" level="any" count="*[local-name()=$name][(not(@unnumbered) or @unnumbered != 'true') and ancestor::itu:annex[@id = $annex-id]]"/>
				<xsl:if test="$brackets = 'true'">
					<xsl:text>)</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:when test="ancestor::*[local-name()=$name]"> <!-- figure in figure for example -->
					<xsl:if test="$brackets = 'true'">
						<xsl:text>(</xsl:text>
					</xsl:if>
					<xsl:for-each select="parent::*[1]">
						<xsl:number format="1" level="any" count="*[local-name()=$name][not(parent::*[local-name()=$name])]"/> <!-- itu:figure[not(parent::itu:figure)] -->
					</xsl:for-each>
					<xsl:number format="-a" count="*[local-name()=$name]"/>
					<xsl:if test="$brackets = 'true'">
						<xsl:text>)</xsl:text>
					</xsl:if>
				</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$brackets = 'true'">
					<xsl:text>(</xsl:text>
				</xsl:if>
				<!-- <xsl:number format="1" level="any" count="itu:figure[not(parent::itu:figure)]"/> -->
				<xsl:number format="1" level="any" count="*[local-name()=$name][not(@unnumbered) or @unnumbered != 'true'][not(parent::*[local-name()=$name])]"/>
				<xsl:if test="$brackets = 'true'">
					<xsl:text>)</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
		
		
	<xsl:template match="itu:example" mode="contents">
		<xsl:param name="sectionNum"/>
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		<xsl:variable name="section">
			<xsl:call-template name="getSection">
				<xsl:with-param name="sectionNum" select="$sectionNum"/>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="parent-element" select="local-name(..)"/>
		<item level="" id="{@id}" display="false" type="example" section="{$section}">
			<xsl:attribute name="parent">
				<xsl:choose>
					<xsl:when test="$parent-element = 'clause'">Clause</xsl:when>
					<xsl:otherwise/>
				</xsl:choose>
			</xsl:attribute>
		</item>
		<xsl:apply-templates mode="contents">
			<xsl:with-param name="sectionNum" select="$sectionNum"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- terms - term -  termnote  -->
	<xsl:template match="itu:termnote" mode="contents">
		<xsl:param name="sectionNum"/>
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		<xsl:variable name="section">
			<xsl:call-template name="getSection">
				<xsl:with-param name="sectionNum" select="$sectionNum"/>
			</xsl:call-template>
		</xsl:variable>
		<item level="" id="{@id}" display="false" type="note" section="{$section}">
			<xsl:number/>
		</item>
		<xsl:apply-templates mode="contents">
			<xsl:with-param name="sectionNum" select="$sectionNum"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="itu:termnote" mode="contents">
		<xsl:param name="sectionNum"/>
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		<xsl:variable name="section">
			<xsl:call-template name="getSection">
				<xsl:with-param name="sectionNum" select="$sectionNum"/>
			</xsl:call-template>
		</xsl:variable>
		<item level="" id="{@id}" display="false" type="note" section="{$section}">
			<xsl:number/>
		</item>
		<xsl:apply-templates mode="contents">
			<xsl:with-param name="sectionNum" select="$sectionNum"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="itu:note" mode="contents">
		<xsl:param name="sectionNum"/>
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		<xsl:variable name="section">
			<xsl:for-each select="ancestor::itu:clause[1]/*[1]">
				<xsl:call-template name="getSection">
					<xsl:with-param name="sectionNum" select="$sectionNum"/>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:variable>
		<item level="" id="{@id}" display="false" type="note" section="{$section}">
			<xsl:number/>
		</item>
		<xsl:apply-templates mode="contents">
			<xsl:with-param name="sectionNum" select="$sectionNum"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- ============================= -->
	<!-- ============================= -->

	
	<!-- ============================= -->
	<!-- PREFACE (Summary, History, ...)          -->
	<!-- ============================= -->
	
	<!-- Summary -->
	<xsl:template match="itu:itu-standard/itu:preface/itu:abstract[@id = '_summary']">
		<fo:block font-size="12pt">
			<xsl:value-of select="$linebreak"/>
			<xsl:value-of select="$linebreak"/>
		</fo:block>
		<fo:block font-weight="bold" margin-top="18pt" margin-bottom="18pt">
			<xsl:text>Summary</xsl:text>
		</fo:block>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="itu:preface/itu:clause">
		<fo:block font-size="12pt">
			<xsl:value-of select="$linebreak"/>
			<xsl:value-of select="$linebreak"/>
		</fo:block>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="itu:preface//itu:title">
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
					<xsl:otherwise>justify</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="itu:note">
		<fo:block id="{@id}">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="itu:note/itu:p" name="note">
		<xsl:variable name="id" select="ancestor::*[local-name() = 'clause'][1]/@id"/>
		<fo:block font-size="11pt" space-before="4pt" text-align="justify">
			<xsl:text>NOTE </xsl:text>
			<!-- <xsl:if test="../following-sibling::itu:note or ../preceding-sibling::itu:note"> -->
			<xsl:if test="count(//itu:note[ancestor::*[@id = $id] and not (ancestor::itu:table)]) &gt; 1">
				<xsl:number count="itu:note[ancestor::*[@id = $id] and not (ancestor::itu:table)]" level="any"/>
			</xsl:if>
				<!-- <xsl:number count="itu:note"/> --><xsl:text> </xsl:text>
			<!-- </xsl:if> -->
			<xsl:text>– </xsl:text>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	
	<!-- ============================= -->
	<!-- ============================= -->
	
	
	<!-- ============================= -->
	<!-- Bibliography -->
	<!-- ============================= -->
	
	<!-- Example: [ITU-T A.23]	ITU-T A.23, Recommendation ITU-T A.23, Annex A (2014), Guide for ITU-T and ISO/IEC JTC 1 cooperation. -->
	<xsl:template match="itu:bibitem">
		<fo:block id="{@id}" margin-top="6pt" margin-left="14mm" text-indent="-14mm">
			<fo:inline padding-right="5mm">[<xsl:value-of select="itu:docidentifier"/>]</fo:inline><xsl:value-of select="itu:docidentifier"/>
				<xsl:if test="itu:title">
				<fo:inline font-style="italic">
						<xsl:text>, </xsl:text>
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
				<xsl:apply-templates select="itu:formattedref"/>
			</fo:block>
	</xsl:template>
	<xsl:template match="itu:bibitem/itu:docidentifier"/>
	
	<xsl:template match="itu:bibitem/itu:title"/>
	
	<xsl:template match="itu:formattedref">
		<xsl:text>, </xsl:text><xsl:apply-templates/>
	</xsl:template>
	
	
	<!-- ============================= -->
	<!-- ============================= -->
	
	
	<xsl:template match="text()">
		<xsl:value-of select="."/>
	</xsl:template>
	
	
	<!-- calculate main section number (1,2,3) and pass it deep into templates -->
	<!-- it's necessary, because there is itu:bibliography/itu:references from other section, but numbering should be sequental -->
	<xsl:template match="itu:itu-standard/itu:sections/*">
		<xsl:param name="sectionNum"/>
		<xsl:param name="sectionNumSkew" select="-1"/>
		<fo:block>
			<xsl:variable name="sectionNum_">
				<xsl:choose>
					<xsl:when test="$sectionNum"><xsl:value-of select="$sectionNum"/></xsl:when>
					<xsl:when test="$sectionNumSkew != -1">
						<xsl:variable name="number"><xsl:number count="*"/></xsl:variable> <!-- itu:sections/itu:clause | itu:sections/itu:terms -->
						<xsl:value-of select="$number + $sectionNumSkew"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:apply-templates>
				<xsl:with-param name="sectionNum" select="$sectionNum_"/>
			</xsl:apply-templates>
		</fo:block>
	</xsl:template>
	

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
	
	<xsl:template match="itu:title">
		<xsl:param name="sectionNum"/>
		<xsl:variable name="id">
			<xsl:choose>
				<xsl:when test="../@id">
					<xsl:value-of select="../@id"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="text()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="parent-name" select="local-name(..)"/>
		<xsl:variable name="references_num_current">
			<xsl:number level="any" count="itu:references"/>
		</xsl:variable>
			
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
		
		<xsl:variable name="section">
			<xsl:call-template name="getSection">
				<xsl:with-param name="sectionNum" select="$sectionNum"/>
			</xsl:call-template>
		</xsl:variable>
				
		<xsl:choose>
			<xsl:when test="$parent-name = 'annex'">
				<fo:block id="{$id}" font-size="14pt" font-weight="bold" text-align="center" margin-bottom="18pt">
					<fo:block margin-bottom="18pt">
						<fo:inline id="{@id}"><xsl:value-of select="$section"/></fo:inline>
					</fo:block>
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
			</xsl:when>
			<xsl:when test="$parent-name = 'references' and $references_num_current != 1">
				<fo:block id="{$id}" font-size="14pt" font-weight="bold" text-align="center" margin-bottom="18pt">
					<xsl:apply-templates/>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<fo:block id="{$id}" font-size="{$font-size}" font-weight="bold" space-before="{$space-before}" space-after="{$space-after}" keep-with-next="always">
					<xsl:value-of select="$section"/>
					<fo:inline>
						<xsl:attribute name="padding-right">
							<xsl:choose>
								<xsl:when test="$level = 3">5mm</xsl:when>
								<xsl:when test="$level = 2">8mm</xsl:when>
								<xsl:otherwise>11mm</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:text> </xsl:text>
					</fo:inline>
					<xsl:apply-templates/>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<xsl:template match="itu:legal-statement//itu:title | itu:license-statement//itu:title">
		<fo:block text-align="center" margin-top="6pt">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
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
		<xsl:param name="sectionNum"/>
		<!-- DEBUG need -->
		<fo:block space-before="6pt" text-align="justify">
			<fo:inline id="{../@id}" padding-right="5mm" font-weight="bold">
				<!-- <xsl:value-of select="$sectionNum"/><xsl:number format=".1" level="multiple" count="itu:clause/itu:clause | itu:clause/itu:terms | itu:terms/itu:term"/> -->
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
				<xsl:variable name="section">
					<xsl:call-template name="getSection">
						<xsl:with-param name="sectionNum" select="$sectionNum"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="$section"/>
			</fo:inline>
			<fo:inline font-weight="bold">
				<xsl:apply-templates/>
			</fo:inline>
			<xsl:if test="../itu:termsource/itu:origin">
				<xsl:text> [</xsl:text><xsl:value-of select="../itu:termsource/itu:origin/@citeas"/><xsl:text>]</xsl:text>
			</xsl:if>
			<xsl:text>: </xsl:text>
			<xsl:apply-templates select="following-sibling::itu:definition/node()" mode="process"/> <!--   -->
		</fo:block>
		<!-- <xsl:if test="following-sibling::itu:table">
			<fo:block space-after="18pt">&#xA0;</fo:block>
		</xsl:if> -->
	</xsl:template>
	
	<xsl:template match="itu:definition/itu:p"/>
	<xsl:template match="itu:definition/itu:formula"/>
	
	<xsl:template match="itu:definition/itu:p" mode="process"> <!--   -->
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

	<xsl:template match="itu:p/itu:fn" priority="2">
		<fo:footnote>
			<xsl:variable name="number">
				<xsl:number level="any" count="itu:p/itu:fn"/>
			</xsl:variable>
			<fo:inline font-size="60%" keep-with-previous.within-line="always" vertical-align="super">
				<fo:basic-link internal-destination="footnote_{@reference}_{$number}" fox:alt-text="footnote {@reference} {$number}">
					<!-- <xsl:value-of select="@reference"/> -->
					<xsl:value-of select="$number + count(//itu:bibitem/itu:note)"/>
				</fo:basic-link>
			</fo:inline>
			<fo:footnote-body>
				<fo:block font-size="11pt" margin-bottom="12pt">
					<fo:inline id="footnote_{@reference}_{$number}" font-size="85%" padding-right="2mm" keep-with-next.within-line="always" baseline-shift="30%"> <!-- alignment-baseline="hanging" -->
						<xsl:value-of select="$number + count(//itu:bibitem/itu:note)"/>
					</fo:inline>
					<xsl:for-each select="itu:p">
							<xsl:apply-templates/>
					</xsl:for-each>
				</fo:block>
			</fo:footnote-body>
		</fo:footnote>
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


	
	<xsl:template match="itu:figure">
		<fo:block-container id="{@id}">
			<fo:block>
				<xsl:apply-templates/>
			</fo:block>
			<xsl:call-template name="fn_display_figure"/>
			<xsl:for-each select="itu:note//itu:p">
				<xsl:call-template name="note"/>
			</xsl:for-each>
			<fo:block font-weight="bold" text-align="center" margin-top="6pt" margin-bottom="6pt" keep-with-previous="always">
				<xsl:variable name="itemnumber">
					<xsl:call-template name="getItemNumber">
						<xsl:with-param name="brackets" select="'false'"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="$itemnumber != ''">
					<xsl:text>Figure </xsl:text>
					<xsl:value-of select="$itemnumber"/>
				</xsl:if>
				<xsl:if test="itu:name">
					<xsl:text> — </xsl:text>
					<xsl:value-of select="itu:name"/>
				</xsl:if>
			</fo:block>
		</fo:block-container>
	</xsl:template>
	
	<xsl:template match="itu:figure/itu:name"/>
	<xsl:template match="itu:figure/itu:fn" priority="2"/>
	<xsl:template match="itu:figure/itu:note"/>

	<!-- itu:figure/itu:image -->
	<xsl:template match="itu:image">
		<fo:block text-align="center">
			<!-- <fo:external-graphic src="{@src}" content-width="75%" content-height="scale-to-fit" scaling="uniform"/> -->
			<fo:external-graphic src="{@src}" fox:alt-text="Image {@alt}" width="75%" content-height="100%" content-width="scale-to-fit" scaling="uniform"/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="itu:figure[@class = 'pseudocode']">
		<fo:block>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="itu:figure[@class = 'pseudocode']//itu:p">
		<fo:block font-size="10pt" margin-top="6pt" margin-bottom="6pt">
			<xsl:apply-templates/>
		</fo:block>
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
	
	
	
	<xsl:template match="itu:annex2//itu:note/itu:p">
		<fo:block font-size="11pt" margin-top="4pt">
			<xsl:text>NOTE </xsl:text>
			<!-- <xsl:if test="../following-sibling::itu:note or ../preceding-sibling::itu:note"> -->
				<xsl:number count="itu:note"/><xsl:text> </xsl:text>
			<!-- </xsl:if> -->
			<xsl:text>– </xsl:text>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="itu:ul | itu:ol | itu:sections/itu:ul | itu:sections/itu:ol">
		<xsl:if test="preceding-sibling::*[1][local-name() = 'title']">
			<fo:block padding-top="-8pt" font-size="1pt"> </fo:block>
		</xsl:if>
		<fo:list-block>
			<xsl:apply-templates/>
		</fo:list-block>
		<xsl:apply-templates select="./itu:note" mode="process"/>
	</xsl:template>
	
	<xsl:template match="itu:ul//itu:note |  itu:ol//itu:note"/>
	<xsl:template match="itu:ul//itu:note/itu:p  | itu:ol//itu:note/itu:p" mode="process">
		<xsl:variable name="id" select="ancestor::*[local-name() = 'clause'][1]/@id"/>
		<fo:block font-size="11pt" margin-top="4pt">
			<xsl:text>NOTE </xsl:text>
			<!-- <xsl:if test="../following-sibling::itu:note or ../preceding-sibling::itu:note"> -->
			<xsl:if test="count(//itu:note[ancestor::*[@id = $id] and not (ancestor::itu:table)]) &gt; 1">
				<xsl:number count="itu:note[ancestor::*[@id = $id] and not (ancestor::itu:table)]" level="any"/>
			</xsl:if>
				<!-- <xsl:number count="itu:note"/> --><xsl:text> </xsl:text>
			<!-- </xsl:if> -->
			<xsl:text>– </xsl:text>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="itu:li">
		<xsl:variable name="level">
			<xsl:variable name="numtmp">
				<xsl:number level="multiple" count="itu:ol"/>
			</xsl:variable>
			<!-- level example: 1.1 
				calculate counts of '.' in numtmp value - level of nested lists
			-->
			<xsl:value-of select="string-length($numtmp) - string-length(translate($numtmp, '.', '')) + 1"/>
		</xsl:variable>
		<fo:list-item>
			<fo:list-item-label end-indent="label-end()">
				<fo:block>
					<xsl:choose>
						<xsl:when test="local-name(..) = 'ul'">–</xsl:when> <!-- dash &#x2014; -->
						<xsl:otherwise> <!-- for ordered lists -->
							<xsl:choose>
								<xsl:when test="../@type = 'arabic'">
									<xsl:number format="a)"/>
								</xsl:when>
								<xsl:when test="ancestor::*[itu:annex]">
									<!-- <xsl:variable name="level">
										<xsl:number level="multiple" count="itu:ol"/>
									</xsl:variable> -->
									<xsl:choose>
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
											<xsl:number format="1.)"/>
										</xsl:otherwise>
									</xsl:choose>
									
								</xsl:when>
								<xsl:when test="../@class = 'steps'">
									<xsl:number format="1)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:number format="1."/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</fo:block>
			</fo:list-item-label>
			<fo:list-item-body start-indent="body-start()">
				<xsl:if test="../preceding-sibling::*[1][local-name() = 'title']">
					<xsl:attribute name="margin-left">18mm</xsl:attribute>
				</xsl:if>
				<xsl:if test="local-name(..) = 'ul'">
					<xsl:attribute name="margin-left">15mm</xsl:attribute>
				</xsl:if>
				<xsl:apply-templates/>
				<xsl:apply-templates select=".//itu:note" mode="process"/>
			</fo:list-item-body>
		</fo:list-item>
	</xsl:template>
	
	<xsl:template match="itu:li//itu:p">
		<fo:block margin-bottom="0pt"> <!-- margin-bottom="6pt" -->
			<!-- <xsl:if test="local-name(ancestor::itu:li[1]/..) = 'ul'">
				<xsl:attribute name="margin-bottom">0pt</xsl:attribute>
			</xsl:if> -->
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="itu:link">
		<fo:inline color="blue">
			<xsl:if test="local-name(..) = 'formattedref' or ancestor::itu:preface">
				<xsl:attribute name="font-family">Arial</xsl:attribute>
				<xsl:attribute name="font-size">8pt</xsl:attribute>
			</xsl:if>
			<fo:basic-link external-destination="{@target}" fox:alt-text="{@target}">
				<xsl:choose>
					<xsl:when test="normalize-space(.) = ''">
						<xsl:value-of select="@target"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates/>
					</xsl:otherwise>
				</xsl:choose>
			</fo:basic-link>
		</fo:inline>
	</xsl:template>
	

	<xsl:template match="itu:termnote">
		<fo:block id="{@id}" margin-top="4pt">
			<xsl:text>NOTE </xsl:text>
				<xsl:if test="following-sibling::itu:termnote or preceding-sibling::itu:termnote">
					<xsl:number/><xsl:text> </xsl:text>
				</xsl:if>
				<xsl:text>– </xsl:text>
				<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	<xsl:template match="itu:termnote/itu:p">
		<xsl:apply-templates/>
	</xsl:template>
	
	
	<xsl:template match="itu:annex">
		<fo:block break-after="page"/>
		<xsl:apply-templates/>
	</xsl:template>
	
	
	<xsl:template match="itu:annex/itu:clause">
		<xsl:apply-templates/>
	</xsl:template>
	
	<!-- Clause without title -->
	<xsl:template match="itu:clause[not(itu:title)]">
		<xsl:param name="sectionNum"/>
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
		<xsl:apply-templates>
			<xsl:with-param name="sectionNum" select="$sectionNum"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="itu:formula" name="formula">
		<fo:block id="{@id}" margin-top="6pt"> <!--  text-align="center" -->
			<fo:table table-layout="fixed" width="100%">
				<fo:table-column column-width="95%"/>
				<fo:table-column column-width="5%"/>
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell display-align="center">
							<fo:block text-align="center">
								<xsl:apply-templates/>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell display-align="center">
							<fo:block text-align="right">
								<xsl:call-template name="getItemNumber"/>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
			<fo:inline keep-together.within-line="always">
			</fo:inline>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="itu:formula" mode="process">
		<xsl:call-template name="formula"/>
	</xsl:template>
	
	<xsl:template match="mathml:math">
		<!-- <fo:inline font-size="12pt" color="red">
			MathML: 
		</fo:inline> -->
		<fo:inline font-family="Cambria Math" font-size="11pt">
			<fo:instream-foreign-object fox:alt-text="Math"> 
				<xsl:copy-of select="."/>
			</fo:instream-foreign-object>
		</fo:inline>
	</xsl:template>
	
	<xsl:template match="itu:xref">
		<xsl:param name="sectionNum"/>
		
		<xsl:variable name="section" select="xalan:nodeset($contents)//item[@id = current()/@target]/@section"/>
		
		<xsl:variable name="text" select="xalan:nodeset($contents)//item[@id = current()/@target]/text()"/>
		
		<fo:basic-link internal-destination="{@target}" color="blue" text-decoration="underline" fox:alt-text="{@target}">
			<xsl:variable name="type" select="xalan:nodeset($contents)//item[@id = current()/@target]/@type"/>
			<xsl:choose>
				<xsl:when test="$type = 'clause'">Clause </xsl:when><!-- and not (ancestor::annex) -->
				<xsl:when test="$type = 'example'">Example </xsl:when>
				<xsl:when test="$type = 'figure'"/>
				<xsl:when test="$type = 'formula'"/>
				<xsl:when test="$type = 'table'"/>
				<xsl:when test="$type = 'term'">Clause </xsl:when>
				<xsl:when test="$type = 'note'"><xsl:text>Note </xsl:text><xsl:value-of select="xalan:nodeset($contents)//item[@id = current()/@target]/text()"/></xsl:when>
					
				<xsl:otherwise/> <!-- <xsl:value-of select="$type"/> -->
			</xsl:choose>
			
			<xsl:choose>
				<xsl:when test="$type = 'example'">
					<xsl:variable name="currentSection">
						<xsl:call-template name="getSection"/>
					</xsl:variable>
					<xsl:if test="not(contains($section, $currentSection))">
						<xsl:text>in </xsl:text>
						<xsl:value-of select="xalan:nodeset($contents)//item[@id = current()/@target]/@parent"/>
						<xsl:text> </xsl:text>
						<xsl:value-of select="$section"/>
					</xsl:if>
				</xsl:when>
				
				<xsl:when test="$type = 'figure'">
					<xsl:value-of select="$text"/>
				</xsl:when>
				
				<xsl:when test="$type = 'formula'">
					<xsl:value-of select="$text"/>
					<xsl:variable name="currentSection">
						<xsl:call-template name="getSection"/>
					</xsl:variable>
					<xsl:if test="not(contains($section, $currentSection))">
						<xsl:text> in </xsl:text>
						<xsl:value-of select="xalan:nodeset($contents)//item[@id = current()/@target]/@parent"/>
						<xsl:text> </xsl:text>
						<xsl:value-of select="$section"/>
					</xsl:if>
				</xsl:when>
				
				<xsl:when test="$type = 'table'">
					<xsl:value-of select="$text"/>
				</xsl:when>
				
				<xsl:when test="$type = 'note'">
					<xsl:text> in Clause </xsl:text>
					<xsl:value-of select="$section"/>
				</xsl:when>
				<!-- <xsl:when test="$type = 'formula'">
				
					<xsl:value-of select="$section"/>
					
					<xsl:variable name="currentSection">
						<xsl:call-template name="getSection"/>
					</xsl:variable>
					<xsl:variable name="refSection">
						<xsl:for-each select="//*[@id = @target]/ancestor::itu:clause">
							<xsl:call-template name="getSection"/>
						</xsl:for-each>
					</xsl:variable>
					currentSection=<xsl:value-of select="$currentSection"/>
					refSection=<xsl:value-of select="$refSection"/>
					<xsl:if test="$currentSection != $refSection">
						<xsl:text>in </xsl:text>
						<xsl:value-of select="xalan:nodeset($contents)//item[@id = current()/@target]/@parent"/>
						<xsl:text> </xsl:text>
						<xsl:value-of select="$refSection"/>
					</xsl:if>
				</xsl:when> -->
				<xsl:otherwise>
					<xsl:value-of select="$section"/>
				</xsl:otherwise>
			</xsl:choose>
			
		</fo:basic-link>
	</xsl:template>

	
	<xsl:template match="itu:example">
		<fo:block id="{@id}" font-size="10pt" margin-top="12pt">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="itu:example/itu:name">
		<fo:block font-weight="bold">
			<xsl:text>EXAMPLE</xsl:text>
			<xsl:if test="count(ancestor::itu:clause[1]/itu:example) &gt; 1">
				<xsl:text> </xsl:text><xsl:number count="itu:example"/>
			</xsl:if>
			<xsl:text> — </xsl:text>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="itu:example/itu:p">
		<fo:block font-size="10pt" margin-top="12pt" margin-bottom="12pt">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	

	<xsl:template match="itu:eref">
		<fo:inline>
			<xsl:if test="@type = 'footnote'">
				<xsl:attribute name="keep-together.within-line">always</xsl:attribute>
				<xsl:attribute name="font-size">80%</xsl:attribute>
				<xsl:attribute name="keep-with-previous.within-line">always</xsl:attribute>
				<xsl:attribute name="vertical-align">super</xsl:attribute>
			</xsl:if>
			<fo:basic-link internal-destination="{@bibitemid}" color="blue" text-decoration="underline" fox:alt-text="{@citeas}">
				<xsl:text>[</xsl:text><xsl:value-of select="@citeas" disable-output-escaping="yes"/><xsl:text>]</xsl:text>
				<xsl:if test="itu:locality">
					<xsl:text>, </xsl:text>
					<xsl:choose>
						<xsl:when test="itu:locality/@type = 'section'">Section </xsl:when>
						<xsl:otherwise/>
					</xsl:choose>
					<xsl:apply-templates select="itu:locality"/>
				</xsl:if>
			</fo:basic-link>
		</fo:inline>
	</xsl:template>
	
	<xsl:template match="itu:references[position() &gt; 1]">
		<fo:block break-after="page"/>
			<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="itu:sourcecode">
		<fo:block font-family="Courier" font-size="10pt" margin-top="6pt" margin-bottom="6pt">
			<xsl:choose>
				<xsl:when test="@lang = 'en'"/>
				<xsl:otherwise>
					<xsl:attribute name="white-space">pre</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
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
		<xsl:text>iVBORw0KGgoAAAANSUhEUgAAAHoAAANLCAMAAAC5SXlDAAADAFBMVEX2kYX1zcLNeITqUw/+7Nnh
		cnP3yr3/jD72iYD+xZnWY2vwhH7z0MbSW2bCSVzmgX3so5n3vrG5RFy5SGD5wr7+9evUbXH5h0Tz
		mYz+z6uuLErblZj/ZQD+n1vDUmP3xLiyMU3+qGv4wbTsaze1OlT+eRryraD+lkzDWmvpubPyoZL+
		vIu9PVT2jILcgoLNVGL1pHfoi4PcfHv2j4TynI7/sn/cChv0lYnyv7Xim5rps67ztqjyqJrmZmv+
		4svqlIr/2L/hlJL2iH/2uazyrJ3UdXrynpDypJXVjZPzsKHLZHDrnZPmfHrUhIz//vztwrn+bAna
		cXPz1MrHS1znoZ7uqqLeior02c/YFyf53drKYW3CRVn//PzjkY72vK6pIkTjiYT+giz0l4r1uKrr
		fnrkravyppj0183LUF/4cx/LWWXhjouzNVHNaXSzLkupH0LxsabuekzrkIfKXWnzuZ/fo6PCQlfk
		mJX+2bWuJkb0taapIEP3x7vMc3/ylne4NlDObXj+n1jYhIj00MSkGD/HZXTcZmvkTFLxiIDVaG7+
		bwzcam7rmY7qpaD2kobmeHbUcHbWen/yopPrenf+7uPzsqLWiY7+snbgbnD++PPnqaXzlYnzmIzz
		08fqhX/+1LTGanrzs6XuycD+3cP+17zyqpvjhYDCVWjonpn+dBXwimX+/Pr+9u/1h3/ATmH+aATz
		1szyuK/0po3adnjBXm/1lIndf379/fytKUjsgmv0zsLeh4b1longLTe3PVb+0av0s6Tz1cr53NDp
		XR+pI0X++/f2k4fzm4ziO0T0mIv//f3mc3P0rJv3zcv408TWf4XfJS/feXjGV2b0ppL2rZuuLk32
		zMDGaHfuglrwi4O6QFjwk5fgp6jwhFrtiYzsr6jcnJ71lIjzl4v1xMPmWF6uJ0fzn4WmIEPgdnbw
		gXv///7vjoT+/v7+///+//7zz8T+/v/z0MTXX2f00MP9/v30z8P9/f3qcnfhoKDxemHfSRj//v6j
		GT//ZgD///+kGT9CyJ4iAAAAAWJLR0QAiAUdSAAAAAxjbVBQSkNtcDA3MTIAAAADSABzvAAAVV9J
		REFUeF7NfQm8nVWR5xNpiLHBsDbLwwAKYUBAECRsatgUaDC2iSh7AIEmItsICqEJdCPNEgREWQWR
		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</xsl:text>
	</xsl:variable>
	
	<xsl:variable name="Image-Logo">
		<xsl:text>iVBORw0KGgoAAAANSUhEUgAAAKEAAABDCAMAAADDA5UNAAADAFBMVEX////0oLP50NnqUHPwgJnk
		IE3nMFnhADP4wM398PPucI3d4u7CyuGHlcS/yN/T2OnoP2b1r7/e5+2Vo8uLnMVpe7WsudXW3ere
		5+7c5uvb5uvZ5OrL1+Oks9FKY6ZWa6zi5fHhDz/9/v6jr9I6U589V6C6xtzi6u/h6e7c5+zY4+nV
		4ejS3+efsc9yjbhec7ClsNPx8/hRZ6ksRpjk6/Dm7fK/zt6mt9JxhLl7k71JYqbA0N/J2eKarMxi
		erH74ObDWINrgLYzTpt4iL16jb20vdpTbKqBlsC8zduftM1abq7sYICMW5FCW6LY4+rp7/Pq8PTs
		8fXo7vO6zN2MoMXS3+aZss1IYaTC1d5keLMdOJDZCDpdY6Pu8vbs8va1xNladK1uhLjK2ePI2OFR
		aqmyydclQZTYgpvSIU/v8/bx9Pevv9Xa5ezW4+pMZqbL2uRnf7RWb6ze6O7UFETjWXry9vj09/gO
		K4nD1d+1ythEX6O90N26z9vW4ujSucfqk6nt8vX2+fr4+vvF0eHT4OfO3ea2zNnDy+Lmq7z7/PzQ
		3uaFmcJedq+/0tywxdevyNXl3eXvx9P9/v39/f6Yp8xKYKfG1+GOp8arxtTyytT8/f1gdrHM2+XE
		1uCpxdOauMy6R3Oux9Wjv9F6mL3bydTdPGThZYXidZLWaou4PGnB1N5bf6+nwdOeu85QbqlmirXa
		5eqZe6m5ztqLrcbmt8bU4Oiduc2XtspNbKe4y9qUq8m70dynw9GAn8CWtcrb2N+lwdE/YKGOsMdM
		aabhLFZih7O+0uC3zdyxyNj///+SsshkfbJUd6yevNDU4ukqR5ehvc9wlrrQTHDJytZVeKx+psHZ
		J1K1vc3Eqrymjang5PCWtszv8fdpjrZNcKh+kMBGaKWGqsR3nr3GVHi3dZOats5HZaZskLdCYqOV
		tMmXe5zJKlZ/pcGQscc4WZ5iYZquZYgxUZqBqMKam7VsTojDNGAqSZeDm7qKka+hQ3OQhqapXYKX
		P3mmFVGSg7LK0uWH32cgAAAAAXRSTlMAQObYZgAAAAFvck5UAc+id5oAAApTSURBVGjezZoNXBPn
		HcePVjy7cQslBBVQw4wCRjExpIICDsKLhgoBUcMxKPJiC6LiG6cCtSghNRDoNi+yykth6zZRqkMF
		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
		v0rL9rg7ifF/FLKviJ4tGb0AAAAASUVORK5CYII=</xsl:text>
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
	
	<xsl:template name="getLevel">
		<xsl:variable name="level_total" select="count(ancestor::*)"/>
		<xsl:variable name="level">
			<xsl:choose>
				<xsl:when test="ancestor::itu:sections">
					<xsl:value-of select="$level_total - 2"/>
				</xsl:when>
				<xsl:when test="ancestor::itu:bibliography">
					<xsl:value-of select="$level_total - 2"/>
				</xsl:when>
				<xsl:when test="local-name(ancestor::*[1]) = 'annex'">1</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$level_total - 1"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$level"/>
	</xsl:template>

	<xsl:template name="getSection">
		<xsl:param name="sectionNum"/>
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		<xsl:variable name="section">
			<xsl:choose>
				<xsl:when test="ancestor::itu:bibliography">
					<xsl:value-of select="$sectionNum"/>
				</xsl:when>
				<xsl:when test="ancestor::itu:sections">
					<!-- 1, 2, 3, 4, ... from main section (not annex, bibliography, ...) -->
					<xsl:choose>
						<xsl:when test="$level = 1">
							<xsl:value-of select="$sectionNum"/>
						</xsl:when>
						<xsl:when test="$level &gt;= 2">
							<xsl:variable name="num">
								<xsl:number format=".1" level="multiple" count="itu:clause/itu:clause | itu:clause/itu:terms | itu:terms/itu:term | itu:clause/itu:term"/>
							</xsl:variable>
							<xsl:value-of select="concat($sectionNum, $num)"/>
						</xsl:when>
						<xsl:otherwise>
							<!-- z<xsl:value-of select="$sectionNum"/>z -->
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="ancestor::itu:annex[@obligation = 'informative']">
					<xsl:choose>
						<xsl:when test="$level = 1">
							<xsl:text>Appendix  </xsl:text>
							<xsl:number format="I" level="any" count="itu:annex[@obligation = 'informative']"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:number format="I.1" level="multiple" count="itu:annex[@obligation = 'informative'] | itu:clause"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="ancestor::itu:annex[not(@obligation) or @obligation != 'informative']">
					<xsl:choose>
						<xsl:when test="$level = 1">
							<xsl:text>Annex </xsl:text>
							<xsl:choose>
								<xsl:when test="count(//itu:annex) = 1">
									<xsl:choose>
										<xsl:when test="/itu:itu-standard/itu:bibdata/itu:ext/itu:structuredidentifier/itu:annexid">
											<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:structuredidentifier/itu:annexid"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:number format="A" level="any" count="itu:annex[not(@obligation) or @obligation != 'informative']"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<xsl:number format="A" level="any" count="itu:annex[not(@obligation) or @obligation != 'informative']"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="count(//itu:annex) = 1">
									<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:structuredidentifier/itu:annexid"/><xsl:number format=".1" level="multiple" count="itu:clause"/> <!-- itu:annex |  -->
								</xsl:when>
								<xsl:otherwise>
									<xsl:number format="A.1" level="multiple" count="itu:annex | itu:clause"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$section"/>
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
	
<xsl:variable xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable><xsl:variable xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable><xsl:variable xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" name="en_chars" select="concat($lower,$upper,',.`1234567890-=~!@#$%^*()_+[]{}\|?/')"/><xsl:variable xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" name="linebreak" select="'&#8232;'"/><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="text()">
		<xsl:value-of select="."/>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='br']">
		<xsl:value-of select="$linebreak"/>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='td']//text() | *[local-name()='th']//text()" priority="1">
		<xsl:call-template name="add-zero-spaces"/>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='table']">
	
		<xsl:variable name="simple-table">
			<!-- <xsl:copy> -->
				<xsl:call-template name="getSimpleTable"/>
			<!-- </xsl:copy> -->
		</xsl:variable>
	
		<!-- DEBUG -->
		<!-- SourceTable=<xsl:copy-of select="current()"/>EndSourceTable -->
		<!-- Simpletable=<xsl:copy-of select="$simple-table"/>EndSimpltable -->
	
		<!-- <xsl:variable name="namespace" select="substring-before(name(/*), '-')"/> -->
		
			<fo:block space-before="18pt"> </fo:block>				
		
		
		<xsl:choose>
			<xsl:when test="@unnumbered = 'true'"/>
			<xsl:otherwise>
				
				
				
					<fo:block font-weight="bold" text-align="center" margin-bottom="6pt" keep-with-next="always">
						
						
						
						<xsl:text>Table </xsl:text>
						<xsl:choose>
							<xsl:when test="ancestor::*[local-name()='executivesummary']"> <!-- NIST -->
								<xsl:text>ES-</xsl:text><xsl:number format="1" count="*[local-name()='executivesummary']//*[local-name()='table'][not(@unnumbered) or @unnumbered != 'true']"/>
							</xsl:when>
							<xsl:when test="ancestor::*[local-name()='annex']">
								
								
									<xsl:choose>
										<xsl:when test="ancestor::itu:annex[@obligation = 'informative']">
											<xsl:variable name="annex-id" select="ancestor::itu:annex/@id"/>
											<!-- Table in Appendix -->
											<xsl:number format="I-" count="itu:annex[@obligation = 'informative']"/>
											<xsl:number format="1" level="any" count="itu:table[(not(@unnumbered) or @unnumbered != 'true') and ancestor::itu:annex[@id = $annex-id]]"/>
										</xsl:when>
										<!-- Table in Annex -->
										<xsl:when test="ancestor::itu:annex[not(@obligation) or @obligation != 'informative']">
											<xsl:variable name="annex-id" select="ancestor::itu:annex/@id"/>
											<xsl:number format="A-" count="itu:annex[not(@obligation) or @obligation != 'informative']"/>
											<xsl:number format="1" level="any" count="itu:table[(not(@unnumbered) or @unnumbered != 'true') and ancestor::itu:annex[@id = $annex-id]]"/>
										</xsl:when>
									</xsl:choose>
								
								
								
								
								
							</xsl:when>
							<xsl:otherwise>
								<!-- <xsl:number format="1"/> -->
								<xsl:number format="A." count="*[local-name()='annex']"/>
								<!-- <xsl:number format="1" level="any" count="*[local-name()='sections']//*[local-name()='table'][not(@unnumbered) or @unnumbered != 'true']"/> -->
								<xsl:number format="1" level="any" count="//*[local-name()='table']                                          [not(ancestor::*[local-name()='annex']) and not(ancestor::*[local-name()='executivesummary'])]                                          [not(@unnumbered) or @unnumbered != 'true']"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="*[local-name()='name']">
							
							
								<xsl:text> — </xsl:text>
							
							<xsl:apply-templates select="*[local-name()='name']" mode="process"/>
						</xsl:if>
					</fo:block>
				
				
				<xsl:call-template name="fn_name_display"/>
			</xsl:otherwise>
		</xsl:choose>
		
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
		
		<xsl:variable name="colwidths2">
			<xsl:call-template name="calculate-column-widths">
				<xsl:with-param name="cols-count" select="$cols-count"/>
			</xsl:call-template>
		</xsl:variable>
		
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
			
			<fo:table id="{@id}" table-layout="fixed" width="100%" margin-left="{$margin-left}mm" margin-right="{$margin-left}mm">
				
				
					<xsl:attribute name="margin-left">0mm</xsl:attribute>
					<xsl:attribute name="margin-right">0mm</xsl:attribute>
				
				
				
				
					<xsl:attribute name="font-size">10pt</xsl:attribute>
				
				
				<xsl:for-each select="xalan:nodeset($colwidths)//column">
					<xsl:choose>
						<xsl:when test=". = 1">
							<fo:table-column column-width="proportional-column-width(2)"/>
						</xsl:when>
						<xsl:otherwise>
							<fo:table-column column-width="proportional-column-width({.})"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
				<xsl:apply-templates/>
			</fo:table>
		</fo:block-container>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='table']/*[local-name()='name']"/><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='table']/*[local-name()='name']" mode="process">
		<xsl:apply-templates/>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" name="calculate-columns-numbers">
		<xsl:param name="table-row"/>
		<xsl:variable name="columns-count" select="count($table-row/*)"/>
		<xsl:variable name="sum-colspans" select="sum($table-row/*/@colspan)"/>
		<xsl:variable name="columns-with-colspan" select="count($table-row/*[@colspan])"/>
		<xsl:value-of select="$columns-count + $sum-colspans - $columns-with-colspan"/>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" name="calculate-column-widths">
		<xsl:param name="table"/>
		<xsl:param name="cols-count"/>
		<xsl:param name="curr-col" select="1"/>
		<xsl:param name="width" select="0"/>
		
		<xsl:if test="$curr-col &lt;= $cols-count">
			<xsl:variable name="widths">
				<xsl:choose>
					<xsl:when test="not($table)">
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
							<xsl:variable name="words">
								<xsl:call-template name="tokenize">
									<xsl:with-param name="text" select="translate(td[$curr-col],'- —:', '    ')"/>
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
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='table2']"/><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='thead']"/><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='thead']" mode="process">
		<!-- <fo:table-header font-weight="bold">
			<xsl:apply-templates />
		</fo:table-header> -->
		<xsl:apply-templates/>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='tfoot']"/><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='tfoot']" mode="process">
		<xsl:apply-templates/>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='tbody']">
		<xsl:variable name="cols-count">
			<xsl:choose>
				<xsl:when test="../*[local-name()='thead']">
					<!-- <xsl:value-of select="count(../*[local-name()='thead']/*[local-name()='tr']/*[local-name()='th'])"/> -->
					<xsl:call-template name="calculate-columns-numbers">
						<xsl:with-param name="table-row" select="../*[local-name()='thead']/*[local-name()='tr'][1]"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<!-- <xsl:value-of select="count(./*[local-name()='tr'][1]/*[local-name()='td'])"/> -->
					<xsl:call-template name="calculate-columns-numbers">
						<xsl:with-param name="table-row" select="./*[local-name()='tr'][1]"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
	
		<fo:table-body>
			<xsl:apply-templates select="../*[local-name()='thead']" mode="process"/>
			<xsl:apply-templates/>
			<xsl:apply-templates select="../*[local-name()='tfoot']" mode="process"/>
			<!-- if there are note(s) or fn(s) then create footer row -->
			<xsl:if test="../*[local-name()='note'] or ..//*[local-name()='fn'][local-name(..) != 'name']">
				<fo:table-row>
					<fo:table-cell border="solid black 1pt" padding-left="1mm" padding-right="1mm" padding-top="1mm" number-columns-spanned="{$cols-count}">
						
						
							<xsl:if test="ancestor::*[local-name()='preface']">
								<xsl:attribute name="border">solid black 0pt</xsl:attribute>
							</xsl:if>
						
						<!-- fn will be processed inside 'note' processing -->
						<xsl:apply-templates select="../*[local-name()='note']" mode="process"/>
						<!-- fn processing -->
						<xsl:call-template name="fn_display"/>
						
					</fo:table-cell>
				</fo:table-row>
				
			</xsl:if>
		</fo:table-body>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='tr']">
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
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='th']">
		<fo:table-cell text-align="{@align}" font-weight="bold" border="solid black 1pt" padding-left="1mm" display-align="center">
			
			
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
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='td']">
		<fo:table-cell text-align="{@align}" display-align="center" border="solid black 1pt" padding-left="1mm">
			
			
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
			<!-- <xsl:choose>
				<xsl:when test="count(*) = 1 and *[local-name() = 'p']">
					<xsl:apply-templates />
				</xsl:when>
				<xsl:otherwise>
					<fo:block>
						<xsl:apply-templates />
					</fo:block>
				</xsl:otherwise>
			</xsl:choose> -->
			
			
		</fo:table-cell>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='table']/*[local-name()='note']"/><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='table']/*[local-name()='note']" mode="process">
		
		
			<fo:block font-size="10pt" margin-bottom="12pt">
				
				<fo:inline padding-right="2mm">
					<xsl:text>NOTE </xsl:text>
					
						<xsl:variable name="id" select="ancestor::*[local-name() = 'table'][1]/@id"/>
						<xsl:if test="count(//itu:note[ancestor::*[@id = $id]]) &gt; 1">
							<xsl:number count="itu:note[ancestor::*[@id = $id]]" level="any"/>
						</xsl:if>
					
					
				</fo:inline>
				<xsl:apply-templates mode="process"/>
			</fo:block>
		
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='table']/*[local-name()='note']/*[local-name()='p']" mode="process">
		<xsl:apply-templates/>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" name="fn_display">
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
					
					<fo:inline font-size="80%" padding-right="5mm" id="{@id}">
						
							<xsl:attribute name="vertical-align">super</xsl:attribute>
						
						
						
							<xsl:attribute name="padding-right">3mm</xsl:attribute>
						
						
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
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" name="fn_name_display">
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
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" name="fn_display_figure">
		<xsl:variable name="key_iso">
			 <!-- and (not(@class) or @class !='pseudocode') -->
		</xsl:variable>
		<xsl:variable name="references">
			<xsl:for-each select=".//*[local-name()='fn']">
				<fn reference="{@reference}" id="{@reference}_{ancestor::*[@id][1]/@id}">
					<xsl:apply-templates/>
				</fn>
			</xsl:for-each>
		</xsl:variable>
		<xsl:if test="xalan:nodeset($references)//fn">
			<fo:block>
				<fo:table width="95%" table-layout="fixed">
					<xsl:if test="normalize-space($key_iso) = 'true'">
						<xsl:attribute name="font-size">10pt</xsl:attribute>
					</xsl:if>
					<fo:table-column column-width="15%"/>
					<fo:table-column column-width="85%"/>
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
		
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='fn']">
		<!-- <xsl:variable name="namespace" select="substring-before(name(/*), '-')"/> -->
		<fo:inline font-size="80%" keep-with-previous.within-line="always">
			
			
				<xsl:attribute name="vertical-align">super</xsl:attribute>
				<xsl:attribute name="color">blue</xsl:attribute>
			
			
			<fo:basic-link internal-destination="{@reference}_{ancestor::*[@id][1]/@id}" fox:alt-text="{@reference}"> <!-- @reference   | ancestor::*[local-name()='clause'][1]/@id-->
				<xsl:value-of select="@reference"/>
			</fo:basic-link>
		</fo:inline>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='fn']/*[local-name()='p']">
		<fo:inline>
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='dl']">
		<xsl:variable name="parent" select="local-name(..)"/>
		
		<xsl:variable name="key_iso">
			 <!-- and  (not(../@class) or ../@class !='pseudocode') -->
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$parent = 'formula' and count(*[local-name()='dt']) = 1"> <!-- only one component -->
				
				
					<fo:block margin-bottom="12pt" text-align="left">
						
						<xsl:text>where </xsl:text>
						<xsl:apply-templates select="*[local-name()='dt']/*"/>
						<xsl:text/>
						<xsl:apply-templates select="*[local-name()='dd']/*" mode="inline"/>
					</fo:block>
				
			</xsl:when>
			<xsl:when test="$parent = 'formula'"> <!-- a few components -->
				<fo:block margin-bottom="12pt" text-align="left">
					
					
					
						<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
					
					<xsl:text>where</xsl:text>
				</fo:block>
			</xsl:when>
			<xsl:when test="$parent = 'figure' and  (not(../@class) or ../@class !='pseudocode')">
				<fo:block font-weight="bold" text-align="left" margin-bottom="12pt">
					
					<xsl:text>Key</xsl:text>
				</fo:block>
			</xsl:when>
		</xsl:choose>
		
		<!-- a few components -->
		<xsl:if test="not($parent = 'formula' and count(*[local-name()='dt']) = 1)">
			<fo:block>
				
				
					<xsl:if test="local-name(..) = 'li'">
						<xsl:attribute name="margin-left">-4mm</xsl:attribute>
					</xsl:if>
				
				
				
				<fo:block>
					
					
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
					
					<fo:table width="95%" table-layout="fixed">
						<xsl:choose>
							<xsl:when test="normalize-space($key_iso) = 'true' and $parent = 'formula'">
								<!-- <xsl:attribute name="font-size">11pt</xsl:attribute> -->
							</xsl:when>
							<xsl:when test="normalize-space($key_iso) = 'true'">
								<xsl:attribute name="font-size">10pt</xsl:attribute>
							</xsl:when>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="ancestor::*[local-name()='dl']"><!-- second level, i.e. inlined table -->
								<fo:table-column column-width="50%"/>
								<fo:table-column column-width="50%"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
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
												<xsl:when test=". = 1">
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
						<fo:table-body>
							<xsl:apply-templates>
								<xsl:with-param name="key_iso" select="normalize-space($key_iso)"/>
							</xsl:apply-templates>
						</fo:table-body>
					</fo:table>
				</fo:block>
			</fo:block>
		</xsl:if>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='dl']/*[local-name()='note']">
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
					NOTE
				</fo:block>
			</fo:table-cell>
			<fo:table-cell>
				<fo:block>
					<xsl:apply-templates/>
				</fo:block>
			</fo:table-cell>
		</fo:table-row>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='dt']" mode="dl">
		<tr>
			<td>
				<xsl:apply-templates/>
			</td>
			<td>
				
				
					<xsl:apply-templates select="following-sibling::*[local-name()='dd'][1]" mode="process"/>
				
			</td>
		</tr>
		
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='dt']">
		<xsl:param name="key_iso"/>
		
		<fo:table-row>
			<fo:table-cell>
				<fo:block margin-top="6pt">
					<xsl:if test="normalize-space($key_iso) = 'true'">
						<xsl:attribute name="margin-top">0</xsl:attribute>
						
					</xsl:if>
					
					<xsl:apply-templates/>
				</fo:block>
			</fo:table-cell>
			<fo:table-cell>
				<fo:block>
					
						<xsl:attribute name="text-align">justify</xsl:attribute>
					
					
					
						<xsl:apply-templates select="following-sibling::*[local-name()='dd'][1]" mode="process"/>
					
				</fo:block>
			</fo:table-cell>
		</fo:table-row>
		
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='dd']" mode="dl"/><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='dd']" mode="dl_process">
		<xsl:apply-templates/>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='dd']"/><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='dd']" mode="process">
		<xsl:apply-templates/>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='dd']/*[local-name()='p']" mode="inline">
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='em']">
		<fo:inline font-style="italic">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='strong']">
		<fo:inline font-weight="bold">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='sup']">
		<fo:inline font-size="80%" vertical-align="super">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='sub']">
		<fo:inline font-size="80%" vertical-align="sub">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='tt']">
		<fo:inline font-family="Courier" font-size="10pt">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='del']">
		<fo:inline font-size="10pt" color="red" text-decoration="line-through">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="text()[ancestor::*[local-name()='smallcap']]">
		<xsl:variable name="text" select="normalize-space(.)"/>
		<fo:inline font-size="75%">
				<xsl:if test="string-length($text) &gt; 0">
					<xsl:call-template name="recursiveSmallCaps">
						<xsl:with-param name="text" select="$text"/>
					</xsl:call-template>
				</xsl:if>
			</fo:inline> 
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" name="recursiveSmallCaps">
    <xsl:param name="text"/>
    <xsl:variable name="char" select="substring($text,1,1)"/>
    <xsl:variable name="upperCase" select="translate($char, $lower, $upper)"/>
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
  </xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" name="tokenize">
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
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" name="max_length">
		<xsl:param name="words"/>
		<xsl:for-each select="$words//word">
				<xsl:sort select="." data-type="number" order="descending"/>
				<xsl:if test="position()=1">
						<xsl:value-of select="."/>
				</xsl:if>
		</xsl:for-each>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" name="add-zero-spaces">
		<xsl:param name="text" select="."/>
		<xsl:variable name="zero-space-after-chars">-</xsl:variable>
		<xsl:variable name="zero-space-after-dot">.</xsl:variable>
		<xsl:variable name="zero-space-after-colon">:</xsl:variable>
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
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" name="getSimpleTable">
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
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='thead'] | *[local-name()='tbody']" mode="simple-table-colspan">
		<xsl:apply-templates mode="simple-table-colspan"/>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='fn']" mode="simple-table-colspan"/><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='th'] | *[local-name()='td']" mode="simple-table-colspan">
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
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="@colspan" mode="simple-table-colspan"/><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="*[local-name()='tr']" mode="simple-table-colspan">
		<xsl:element name="tr">
			<xsl:apply-templates select="@*" mode="simple-table-colspan"/>
			<xsl:apply-templates mode="simple-table-colspan"/>
		</xsl:element>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="@*|node()" mode="simple-table-colspan">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="simple-table-colspan"/>
		</xsl:copy>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" name="repeatNode">
		<xsl:param name="count"/>
		<xsl:param name="node"/>
		
		<xsl:if test="$count &gt; 0">
			<xsl:call-template name="repeatNode">
				<xsl:with-param name="count" select="$count - 1"/>
				<xsl:with-param name="node" select="$node"/>
			</xsl:call-template>
			<xsl:copy-of select="$node"/>
		</xsl:if>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="@*|node()" mode="simple-table-rowspan">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="simple-table-rowspan"/>
		</xsl:copy>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="tbody" mode="simple-table-rowspan">
		<xsl:copy>
				<xsl:copy-of select="tr[1]"/>
				<xsl:apply-templates select="tr[2]" mode="simple-table-rowspan">
						<xsl:with-param name="previousRow" select="tr[1]"/>
				</xsl:apply-templates>
		</xsl:copy>
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" match="tr" mode="simple-table-rowspan">
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
	</xsl:template><xsl:template xmlns:iso="http://riboseinc.com/isoxml" xmlns:iec="http://riboseinc.com/isoxml" xmlns:nist="http://www.nist.gov/metanorma" xmlns:un="https://open.ribose.com/standards/unece" xmlns:csd="https://www.calconnect.org/standards/csd" name="getLang">
		<xsl:variable name="language" select="//*[local-name()='bibdata']//*[local-name()='language']"/>
		<xsl:choose>
			<xsl:when test="$language = 'English'">en</xsl:when>
			<xsl:otherwise><xsl:value-of select="$language"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template></xsl:stylesheet>
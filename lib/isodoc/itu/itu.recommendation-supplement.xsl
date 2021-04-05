<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:itu="https://www.metanorma.org/ns/itu" xmlns:mathml="http://www.w3.org/1998/Math/MathML" xmlns:xalan="http://xml.apache.org/xalan" xmlns:fox="http://xmlgraphics.apache.org/fop/extensions" xmlns:java="http://xml.apache.org/xalan/java" exclude-result-prefixes="java" version="1.0">

	<xsl:output method="xml" encoding="UTF-8" indent="no"/>

	<xsl:param name="svg_images"/>
	<xsl:param name="external_index"/><!-- path to index xml, generated on 1st pass, based on FOP Intermediate Format -->
	<xsl:variable name="images" select="document($svg_images)"/>
	<xsl:param name="basepath"/>
	
	
	
	<xsl:key name="kfn" match="itu:p/itu:fn" use="@reference"/>
	
	
	
	<xsl:variable name="debug">false</xsl:variable>
	<xsl:variable name="pageWidth" select="'210mm'"/>
	<xsl:variable name="pageHeight" select="'297mm'"/>
	
	<!-- Rec. ITU-T G.650.1 (03/2018) -->
	<xsl:variable name="footerprefix" select="'Rec. '"/>
	<xsl:variable name="docname">		
		<xsl:value-of select="substring-before(/itu:itu-standard/itu:bibdata/itu:docidentifier[@type = 'ITU'], ' ')"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="substring-after(/itu:itu-standard/itu:bibdata/itu:docidentifier[@type = 'ITU'], ' ')"/>
		<xsl:text> </xsl:text>
	</xsl:variable>
	<xsl:variable name="docdate">
		<xsl:call-template name="formatDate">
			<xsl:with-param name="date" select="/itu:itu-standard/itu:bibdata/itu:date[@type = 'published']/itu:on"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="doctype" select="/itu:itu-standard/itu:bibdata/itu:ext/itu:doctype[not(@language) or @language = '']"/>

	<xsl:variable name="xSTR-ACRONYM">
		<xsl:variable name="x" select="/itu:itu-standard/itu:bibdata/itu:series[@type = 'main']/itu:title[@type = 'abbrev']"/>
		<xsl:variable name="acronym" select="/itu:itu-standard/itu:bibdata/itu:docnumber"/>
		<xsl:value-of select="concat($x,'STR-', $acronym)"/>
	</xsl:variable>
	

	<!-- Example:
		<item level="1" id="Foreword" display="true">Foreword</item>
		<item id="term-script" display="false">3.2</item>
	-->
	<xsl:variable name="contents">
		<contents>
			<!-- <xsl:apply-templates select="/itu:itu-standard/itu:preface/node()" mode="contents"/> -->
			<xsl:apply-templates select="/itu:itu-standard/itu:sections/itu:clause[@type='scope']" mode="contents"/> <!-- @id = 'scope' -->
				
			<!-- Normative references -->
			<xsl:apply-templates select="/itu:itu-standard/itu:bibliography/itu:references[@normative='true']" mode="contents"/> <!-- @id = 'references' -->
			
			<xsl:apply-templates select="/itu:itu-standard/itu:sections/*[not(@type='scope')]" mode="contents"/> <!-- @id != 'scope' -->
				
			<xsl:apply-templates select="/itu:itu-standard/itu:annex" mode="contents"/>
			
			<!-- Bibliography -->
			<xsl:apply-templates select="/itu:itu-standard/itu:bibliography/itu:references[not(@normative='true')]" mode="contents"/> <!-- @id = 'bibliography' -->
			
			<xsl:apply-templates select="//itu:table" mode="contents"/>
			
		</contents>
	</xsl:variable>

	<xsl:variable name="lang">
		<xsl:call-template name="getLang"/>
	</xsl:variable>
	
	<xsl:variable name="doctypeTitle">
		<xsl:choose>
			<xsl:when test="/itu:itu-standard/itu:bibdata/itu:ext/itu:doctype[@language = $lang]">
				<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:doctype[@language = $lang]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="capitalizeWords">
					<xsl:with-param name="str" select="$doctype"/>
				</xsl:call-template>		
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="footer-text">
		<xsl:choose>
			<xsl:when test="$doctype = 'technical-report' or $doctype = 'technical-paper'">
				<xsl:variable name="date" select="concat('(',substring(/itu:itu-standard/itu:bibdata/itu:version/itu:revision-date,1,7), ')')"/>
				<xsl:value-of select="concat($xSTR-ACRONYM, ' ', $date)"/>
			</xsl:when>
			<xsl:when test="$doctype = 'implementers-guide'">
				<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:doctype[@language = $lang]"/>
				<xsl:text> for </xsl:text>
				<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:docidentifier[@type='ITU-Recommendation']"/>
				<xsl:text> </xsl:text>
				<xsl:variable name="date" select="concat('(',substring(/itu:itu-standard/itu:bibdata/itu:date[@type = 'published']/itu:on,1,7), ')')"/>
				<xsl:value-of select="$date"/>
			</xsl:when>
			<xsl:when test="$doctype = 'resolution'">
				<!-- WTSA-16 – Resolution 1  -->
				<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:meeting/@acronym"/>
				<xsl:text> – </xsl:text>
				<xsl:value-of select="$doctypeTitle"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:structuredidentifier/itu:docnumber"/>
			</xsl:when>
			<xsl:when test="$doctype = 'recommendation-supplement'">
				<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:docidentifier[@type = 'ITU-Supplement-Short']"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="$docdate"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($footerprefix, $docname, ' ', $docdate)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="isAmendment" select="normalize-space(/itu:itu-standard/itu:bibdata/itu:ext/itu:structuredidentifier/itu:amendment[@language = $lang])"/>
	<xsl:variable name="isCorrigendum" select="normalize-space(/itu:itu-standard/itu:bibdata/itu:ext/itu:structuredidentifier/itu:corrigendum[@language = $lang])"/>
	
	<xsl:template match="/">
		<xsl:call-template name="namespaceCheck"/>
		<fo:root font-family="Times New Roman, STIX Two Math" font-size="12pt" xml:lang="{$lang}">
			<xsl:if test="$doctype = 'resolution'">
				<xsl:attribute name="font-size">11pt</xsl:attribute>
			</xsl:if>
			<fo:layout-master-set>
			
			
				<!-- Technical Report first page -->
				<fo:simple-page-master master-name="TR-first-page" page-width="{$pageWidth}" page-height="{$pageHeight}">
					<fo:region-body margin-top="21.6mm" margin-bottom="25.4mm" margin-left="20.1mm" margin-right="22.6mm"/>
					<fo:region-before region-name="TR-first-page-header" extent="21.6mm" display-align="center"/>
					<fo:region-after region-name="TR-first-page-footer" extent="25.4mm" display-align="center"/>					
					<fo:region-start region-name="TR-first-page-left-region" extent="20.1mm"/>
					<fo:region-end region-name="TR-first-page-right-region" extent="22.6mm"/>
				</fo:simple-page-master>
				
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
				<xsl:call-template name="addPDFUAmeta"/>
			</fo:declarations>
			
			<xsl:call-template name="addBookmarks">
				<xsl:with-param name="contents" select="$contents"/>
			</xsl:call-template>
			
			
			<xsl:if test="$doctype = 'technical-report' or               $doctype = 'technical-paper' or              $doctype = 'implementers-guide'">
				<fo:page-sequence master-reference="TR-first-page">
					<fo:flow flow-name="xsl-region-body">						
							<fo:block>
								<fo:table width="175mm" table-layout="fixed" border-top="1.5pt solid black">									
									<fo:table-column column-width="29mm"/>
									<fo:table-column column-width="45mm"/>
									<fo:table-column column-width="28mm"/>
									<fo:table-column column-width="72mm"/>
									<fo:table-body>
										<fo:table-row>
											<fo:table-cell padding-left="1mm" padding-top="3mm">
													<fo:block font-weight="bold">Question(s):</fo:block>
											</fo:table-cell>
											<fo:table-cell padding-top="3mm">
													<fo:block><xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:editorialgroup/itu:group/itu:name"/></fo:block>
											</fo:table-cell>
											<fo:table-cell padding-top="3mm">
													<fo:block font-weight="bold">Meeting, date:</fo:block>
											</fo:table-cell>
											<fo:table-cell padding-top="3mm" text-align="right" padding-right="1mm">
												<fo:block>
													<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:meeting"/>
													<xsl:text>, </xsl:text>
													<xsl:call-template name="formatMeetingDate">
														<xsl:with-param name="date" select="/itu:itu-standard/itu:bibdata/itu:ext/itu:meeting-date/itu:from"/>
													</xsl:call-template>													
													<xsl:text>/</xsl:text>
													<xsl:call-template name="formatMeetingDate">
														<xsl:with-param name="date" select="/itu:itu-standard/itu:bibdata/itu:ext/itu:meeting-date/itu:to"/>
													</xsl:call-template>													
												</fo:block>
											</fo:table-cell>
										</fo:table-row>
									</fo:table-body>
								</fo:table>
								
								<fo:table width="175mm" table-layout="fixed">									
									<fo:table-column column-width="29mm"/>
									<fo:table-column column-width="10mm"/>
									<fo:table-column column-width="35mm"/>
									<fo:table-column column-width="9mm"/>
									<fo:table-column column-width="83mm"/>
									<fo:table-column column-width="6mm"/>
									<fo:table-body>										
										<fo:table-row>
											<fo:table-cell padding-left="1mm" padding-top="2mm">
												<fo:block font-weight="bold">Study Group:</fo:block>
											</fo:table-cell>
											<fo:table-cell padding-top="2mm">
												<fo:block><xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:editorialgroup/itu:subgroup/itu:name"/></fo:block>
											</fo:table-cell>
											<fo:table-cell padding-top="2mm">
												<fo:block font-weight="bold">Working Party:</fo:block>
											</fo:table-cell>
											<fo:table-cell padding-top="2mm">
												<fo:block><xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:editorialgroup/itu:workgroup/itu:name"/></fo:block>
											</fo:table-cell>
											<fo:table-cell padding-top="2mm">
												<fo:block font-weight="bold">Intended type of document <fo:inline font-weight="normal">(R-C-TD)</fo:inline>:</fo:block>
											</fo:table-cell>
											<fo:table-cell padding-top="2mm">
												<fo:block font-weight="normal"><xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:intended-type"/></fo:block>
											</fo:table-cell>
										</fo:table-row>
										<fo:table-row>
											<fo:table-cell padding-left="1mm" padding-top="2mm">
												<fo:block font-weight="bold">Source:</fo:block>
											</fo:table-cell>
											<fo:table-cell number-columns-spanned="4" padding-top="2mm">
												<fo:block><xsl:value-of select="java:toUpperCase(java:java.lang.String.new(/itu:itu-standard/itu:bibdata/itu:ext/itu:source))"/></fo:block>
											</fo:table-cell>
										</fo:table-row>
										<fo:table-row>
											<fo:table-cell padding-left="1mm" padding-top="2mm">
												<fo:block font-weight="bold">Title:</fo:block>
											</fo:table-cell>
											<fo:table-cell number-columns-spanned="4" padding-top="2mm">
												<fo:block><xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:title[@language='en' and @type='main']"/></fo:block>
											</fo:table-cell>
										</fo:table-row>
									</fo:table-body>
								</fo:table>
								
								<xsl:if test="/itu:itu-standard/itu:bibdata/itu:contributor/itu:person">								
									<fo:table width="175mm" table-layout="fixed" line-height="110%">
										<fo:table-column column-width="29mm"/>
										<fo:table-column column-width="75mm"/>
										<fo:table-column column-width="71mm"/>									
										<fo:table-body>
										
											<xsl:for-each select="/itu:itu-standard/itu:bibdata/itu:contributor/itu:person">
											
										
												<fo:table-row border-top="1.5pt solid black">
													<xsl:if test="position() = last()">
														<xsl:attribute name="border-bottom">1.5pt solid black</xsl:attribute>
													</xsl:if>
													<fo:table-cell padding-left="1mm" padding-top="2.5mm">
														<fo:block font-weight="bold">Contact:</fo:block>
													</fo:table-cell>
													<fo:table-cell padding-top="3mm">
														<fo:block><xsl:value-of select="itu:name/itu:completename"/></fo:block>
														<fo:block><xsl:value-of select="itu:affiliation/itu:organization/itu:name"/></fo:block>
														<fo:block><xsl:value-of select="itu:affiliation/itu:organization/itu:address/itu:formattedAddress"/></fo:block>
													</fo:table-cell>
													<fo:table-cell padding-top="3mm">
														<fo:block>Tel: <xsl:value-of select="itu:phone[not(@type)]"/></fo:block>
														<fo:block>Fax: <xsl:value-of select="itu:phone[@type = 'fax']"/></fo:block>
														<fo:block>E-mail: <xsl:value-of select="itu:email"/></fo:block>
													</fo:table-cell>
												</fo:table-row>
											</xsl:for-each>											
										</fo:table-body>
									</fo:table>
								</xsl:if>
								<fo:block space-before="0.5mm" font-size="9pt" margin-left="1mm">Please do not change the structure of this table, just insert the necessary information.</fo:block>
								<fo:block space-before="6pt">&lt;INSERT TEXT&gt;</fo:block>
							</fo:block>
					</fo:flow>
				</fo:page-sequence>
			</xsl:if>
			
			<!-- cover page -->
			<fo:page-sequence master-reference="cover-page">
				<xsl:if test="$doctype = 'resolution'">
					<xsl:attribute name="force-page-count">no-force</xsl:attribute>
				</xsl:if>
				<fo:flow flow-name="xsl-region-body">
				
					<fo:block-container absolute-position="fixed" top="265mm">
						<fo:block text-align="right" margin-right="19mm">
							<xsl:choose>
								<xsl:when test="$doctype = 'resolution'">
									<fo:external-graphic src="{concat('data:image/png;base64,', normalize-space($Image-Logo_resolution))}" content-height="21mm" content-width="scale-to-fit" scaling="uniform" fox:alt-text="Image Logo"/>
								</xsl:when>
								<xsl:otherwise>
									<fo:external-graphic src="{concat('data:image/png;base64,', normalize-space($Image-Logo))}" content-height="17.7mm" content-width="scale-to-fit" scaling="uniform" fox:alt-text="Image Logo"/>
								</xsl:otherwise>
							</xsl:choose>
							
						</fo:block>
					</fo:block-container>
				
					<fo:block-container absolute-position="fixed" left="-7mm" top="0" font-size="0">
						<fo:block>
							<fo:external-graphic src="{concat('data:image/png;base64,', normalize-space($Image-Fond-Rec))}" width="43.6mm" content-height="299.2mm" content-width="scale-to-fit" scaling="uniform" fox:alt-text="Image Cover Page"/>
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
											<xsl:value-of select="substring-before(/itu:itu-standard/itu:bibdata/itu:docidentifier[@type = 'ITU'], ' ')"/>
										</fo:block>
									</fo:table-cell>
									<fo:table-cell padding-top="1mm" number-columns-spanned="2" padding-bottom="-1mm">
										<fo:block font-size="30pt" font-weight="bold" text-align="right" margin-top="12pt" padding="0mm">
											<xsl:choose>
												<xsl:when test="$doctype = 'technical-report' or $doctype = 'technical-paper'">
													<xsl:value-of select="$doctypeTitle"/>
												</xsl:when>
												<xsl:when test="$doctype = 'implementers-guide'">
													<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:docidentifier[@type='ITU-Recommendation']"/>
													<xsl:text> </xsl:text>
													<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:doctype[@language = $lang]"/>
												</xsl:when>
												<xsl:when test="$doctype = 'resolution'"/>
												<xsl:when test="$doctype = 'recommendation-supplement'">
													<!-- Series L -->
													<xsl:variable name="title-series">
														<xsl:call-template name="getLocalizedString">
															<xsl:with-param name="key">series</xsl:with-param>
														</xsl:call-template>
													</xsl:variable>
													<xsl:call-template name="capitalize">
														<xsl:with-param name="str" select="$title-series"/>
													</xsl:call-template>
													<xsl:text> </xsl:text>
													<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:series[@type='main']/itu:title[@type='abbrev']"/>
													<!-- Ex. Supplement 37 -->
													<fo:block font-size="18pt">
														<xsl:call-template name="getLocalizedString">
															<xsl:with-param name="key">doctype_dict.recommendation-supplement</xsl:with-param>
														</xsl:call-template>
														<xsl:text> </xsl:text>
														<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:docnumber"/>
													</fo:block>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="substring-after(/itu:itu-standard/itu:bibdata/itu:docidentifier[@type = 'ITU'], ' ')"/>
												</xsl:otherwise>
											</xsl:choose>
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
										<xsl:if test="$isAmendment != ''">
											<fo:block font-size="18pt" font-weight="bold">
												<xsl:value-of select="$isAmendment"/>
											</fo:block>
										</xsl:if>
										<xsl:if test="$isCorrigendum != ''">
											<fo:block font-size="18pt" font-weight="bold">
												<xsl:value-of select="$isCorrigendum"/>
											</fo:block>
										</xsl:if>
										<fo:block font-size="14pt">
											<xsl:choose>
												<xsl:when test="($doctype = 'technical-report' or $doctype = 'technical-paper') and /itu:itu-standard/itu:bibdata/itu:version/itu:revision-date">
													<xsl:text>(</xsl:text>
														<xsl:call-template name="formatMeetingDate">
															<xsl:with-param name="date" select="/itu:itu-standard/itu:bibdata/itu:version/itu:revision-date"/>
														</xsl:call-template>
													<xsl:text>)</xsl:text>
												</xsl:when>
												<xsl:otherwise>
													<xsl:call-template name="formatDate">
														<xsl:with-param name="date" select="/itu:itu-standard/itu:bibdata/itu:date[@type = 'published']/itu:on"/>
													</xsl:call-template>
												</xsl:otherwise>
											</xsl:choose>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
								<fo:table-row height="64mm"> <!-- 59mm -->
									<fo:table-cell>
										<fo:block> </fo:block>
									</fo:table-cell>
									<fo:table-cell font-size="16pt" number-columns-spanned="3" border-bottom="0.5mm solid black" padding-right="2mm" display-align="after">
										<fo:block padding-bottom="7mm">
											<xsl:if test="$doctype = 'resolution'">
												<fo:block><xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:meeting"/></fo:block>
												<fo:block>
													<xsl:variable name="meeting-place" select="/itu:itu-standard/itu:bibdata/itu:ext/itu:meeting-place"/>
													<xsl:variable name="meeting-date_from" select="/itu:itu-standard/itu:bibdata/itu:ext/itu:meeting-date/itu:from"/>
													<xsl:variable name="meeting-date_from_year" select="substring($meeting-date_from, 1, 4)"/>
													<xsl:variable name="meeting-date_to" select="/itu:itu-standard/itu:bibdata/itu:ext/itu:meeting-date/itu:to"/>
													<xsl:variable name="meeting-date_to_year" select="substring($meeting-date_to, 1, 4)"/>
													
													<xsl:variable name="date_format">
														<xsl:choose>
															<xsl:when test="$meeting-date_from_year = $meeting-date_to_year">ddMM</xsl:when>
															<xsl:otherwise>ddMMyyyy</xsl:otherwise>
														</xsl:choose>
													</xsl:variable>
													<xsl:variable name="meeting-date_from_str">
														<xsl:call-template name="convertDateLocalized">
															<xsl:with-param name="date" select="$meeting-date_from"/>
															<xsl:with-param name="format" select="$date_format"/>
														</xsl:call-template>
													</xsl:variable>													

													<xsl:variable name="meeting-date_to_str">
														<xsl:call-template name="convertDateLocalized">
															<xsl:with-param name="date" select="$meeting-date_to"/>
															<xsl:with-param name="format" select="'ddMMyyyy'"/>
														</xsl:call-template>
													</xsl:variable>
													
													<xsl:value-of select="$meeting-place"/>
													<xsl:if test="$meeting-place != '' and (normalize-space($meeting-date_from_str) != '' or normalize-space($meeting-date_to_str != ''))">
														<xsl:text>, </xsl:text>
														<xsl:value-of select="$meeting-date_from_str"/>
														<xsl:if test="normalize-space($meeting-date_from_str) != '' and  normalize-space($meeting-date_to_str) != ''">
														<xsl:text> – </xsl:text>
														</xsl:if>
														<xsl:value-of select="$meeting-date_to_str"/>
													</xsl:if>
												</fo:block>
											</xsl:if>
											<fo:block text-transform="uppercase">
												<xsl:variable name="series_title" select="normalize-space(/itu:itu-standard/itu:bibdata/itu:series[@type = 'main']/itu:title[@type = 'full'])"/>
												<xsl:if test="$series_title != ''">
													<xsl:variable name="title">
														<xsl:if test="$doctype != 'resolution'">
															<!-- <xsl:text>Series </xsl:text> -->
															<xsl:call-template name="getLocalizedString">
																<xsl:with-param name="key">series</xsl:with-param>
															</xsl:call-template>
															<xsl:text> </xsl:text>
														</xsl:if>
														<xsl:value-of select="$series_title"/>
													</xsl:variable>
													<xsl:value-of select="$title"/>												
												</xsl:if>
											</fo:block>
											<xsl:choose>
												<xsl:when test="$doctype = 'recommendation-supplement'"/>
												<xsl:otherwise>
													<xsl:if test="/itu:itu-standard/itu:bibdata/itu:series">
														<fo:block margin-top="6pt">
															<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:series[@type = 'secondary']"/>
															<xsl:if test="normalize-space(/itu:itu-standard/itu:bibdata/itu:series[@type = 'tertiary']) != ''">
																<xsl:text> — </xsl:text>
																<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:series[@type = 'tertiary']"/>
															</xsl:if>
														</fo:block>
													</xsl:if>
												</xsl:otherwise>
											</xsl:choose>
											
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
								<fo:table-row height="40mm">
									<fo:table-cell>
										<fo:block> </fo:block>
									</fo:table-cell>
									<fo:table-cell font-size="18pt" number-columns-spanned="3">
										<fo:block padding-right="2mm" margin-top="6pt">
											<xsl:if test="not(/itu:itu-standard/itu:bibdata/itu:title[@type = 'annex' and @language = 'en']) and $isAmendment = '' and $isCorrigendum = ''">
												<xsl:attribute name="font-weight">bold</xsl:attribute>
											</xsl:if>
											<xsl:if test="($doctype = 'technical-report' or $doctype = 'technical-paper') and /itu:itu-standard/itu:bibdata/itu:docnumber">
												<fo:block font-weight="bold">													
													<xsl:value-of select="$xSTR-ACRONYM"/>
												</fo:block>
											</xsl:if>
											<xsl:if test="$doctype = 'implementers-guide'">
												<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:doctype[@language = $lang]"/>
												<xsl:text> for </xsl:text>
											</xsl:if>
											<xsl:if test="$doctype = 'resolution'">
												<!-- Resolution 1 -->
												<xsl:value-of select="$doctypeTitle"/><xsl:text> </xsl:text><xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:structuredidentifier/itu:docnumber"/>
												<xsl:text> – </xsl:text>
											</xsl:if>
											<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:title[@type = 'main' and @language = 'en']"/>
										</fo:block>
										<xsl:for-each select="/itu:itu-standard/itu:bibdata/itu:title[@type = 'annex' and @language = 'en']">
											<fo:block font-weight="bold">
												<xsl:value-of select="."/>
											</fo:block>
										</xsl:for-each>
										<xsl:if test="$isAmendment != ''">
											<fo:block padding-right="2mm" margin-top="6pt" font-weight="bold">
												<xsl:value-of select="$isAmendment"/>
												<xsl:if test="/itu:itu-standard/itu:bibdata/itu:title[@type = 'amendment']">
													<xsl:text>: </xsl:text>
													<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:title[@type = 'amendment']"/>
												</xsl:if>
											</fo:block>
										</xsl:if>
										<xsl:if test="$isCorrigendum != ''">
											<fo:block padding-right="2mm" margin-top="6pt" font-weight="bold">
												<xsl:value-of select="$isCorrigendum"/>
												<xsl:if test="/itu:itu-standard/itu:bibdata/itu:title[@type = 'corrigendum']">
													<xsl:text>: </xsl:text>
													<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:title[@type = 'corrigendum']"/>
												</xsl:if>
											</fo:block>
										</xsl:if>
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
											<xsl:if test="/itu:itu-standard/itu:boilerplate/itu:legal-statement/itu:clause[@id='draft-warning']">
												<xsl:attribute name="margin-top">6pt</xsl:attribute>
												<xsl:if test="$doctype = 'recommendation-supplement'">
													<xsl:attribute name="margin-top">12pt</xsl:attribute>
												</xsl:if>
											</xsl:if>
											
											<xsl:choose>
												<xsl:when test="$doctype = 'technical-report' or $doctype = 'technical-paper'">
													<xsl:if test="/itu:itu-standard/itu:bibdata/itu:status/itu:stage">
														<xsl:call-template name="capitalizeWords">
															<xsl:with-param name="str" select="/itu:itu-standard/itu:bibdata/itu:status/itu:stage"/>
														</xsl:call-template>												
														<xsl:text> </xsl:text>
													</xsl:if>
													<xsl:value-of select="$doctypeTitle"/>
													<xsl:text>  </xsl:text>
													<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:docidentifier[@type='ITU']"/>
												</xsl:when>
												<xsl:when test="$doctype = 'implementers-guide'"/>
												<xsl:when test="$doctype = 'resolution'"/>
												<xsl:when test="$doctype = 'recommendation-supplement'">
													<xsl:if test="/itu:itu-standard/itu:bibdata/itu:status/itu:stage = 'draft'">Draft </xsl:if>
													<xsl:text>ITU-</xsl:text><xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:editorialgroup/itu:bureau"/><xsl:text> </xsl:text>
													<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:docidentifier[@type = 'ITU-Supplement']"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="$doctypeTitle"/>
													<xsl:text>  </xsl:text>
													<xsl:if test="/itu:itu-standard/itu:bibdata/itu:contributor/itu:organization/itu:abbreviation">
														<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:contributor/itu:organization/itu:abbreviation"/>
														<xsl:text>-</xsl:text>
													</xsl:if>
													<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:structuredidentifier/itu:bureau"/>
													<xsl:text>  </xsl:text>
													<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:structuredidentifier/itu:docnumber"/>
												</xsl:otherwise>
											</xsl:choose>
											
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
				
					<xsl:if test="/itu:itu-standard/itu:preface/* or /itu:itu-standard/itu:bibdata/itu:keyword">
						<fo:block-container font-size="14pt" font-weight="bold">
							<xsl:choose>
								<xsl:when test="$doctype = 'implementers-guide'"/>
								<xsl:when test="$doctype = 'recommendation-supplement'">
									<fo:block>
										<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:docidentifier[@type = 'ITU-Supplement-Internal']"/>
									</fo:block>
								</xsl:when>
								<xsl:otherwise>
									<fo:block>
										<xsl:value-of select="$doctypeTitle"/>
										<xsl:text> </xsl:text>
										<xsl:value-of select="$docname"/>
									</fo:block>
								</xsl:otherwise>
							</xsl:choose>
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
					</xsl:if>
					
					
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
					
					<xsl:if test="xalan:nodeset($contents)//item[@display = 'true'] and $doctype != 'resolution'">
						<fo:block break-after="page"/>
						<fo:block-container>
							<fo:block margin-top="6pt" text-align="center" font-weight="bold">
								<xsl:call-template name="getLocalizedString">
									<xsl:with-param name="key">table_of_contents</xsl:with-param>
								</xsl:call-template>
							</fo:block>
							<fo:block margin-top="6pt" text-align="right" font-weight="bold">
								<xsl:call-template name="getLocalizedString">
									<xsl:with-param name="key">Page.sg</xsl:with-param>
								</xsl:call-template>
							</fo:block>
							
							<xsl:for-each select="xalan:nodeset($contents)//item[@display = 'true']">									
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
														<fo:basic-link internal-destination="{@id}" fox:alt-text="{title}">
															<xsl:apply-templates select="title"/>
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
							

						<xsl:if test="$doctype = 'technical-report' or $doctype = 'technical-paper'">
							<xsl:if test="//itu:table[@id and itu:name]">								
								<xsl:variable name="title-list-tables">
									<xsl:call-template name="getTitle">
										<xsl:with-param name="name" select="'title-list-tables'"/>
									</xsl:call-template>
								</xsl:variable>
								
								<fo:block space-before="36pt" text-align="center" font-weight="bold" keep-with-next="always">
									<xsl:value-of select="$title-list-tables"/>
								</fo:block>
								<fo:block margin-top="6pt" text-align="right" font-weight="bold" keep-with-next="always">
									<xsl:call-template name="getLocalizedString">
										<xsl:with-param name="key">Page.sg</xsl:with-param>
									</xsl:call-template>
								</fo:block>
								
								<fo:block-container>
									<xsl:for-each select="//itu:table[@id and itu:name]">
										<fo:block text-align-last="justify" margin-top="6pt">
											<fo:basic-link internal-destination="{@id}" fox:alt-text="{itu:name}">
												<xsl:apply-templates select="itu:name" mode="contents"/>										
												<fo:inline keep-together.within-line="always">
													<fo:leader leader-pattern="dots"/>
													<fo:page-number-citation ref-id="{@id}"/>
												</fo:inline>
											</fo:basic-link>
										</fo:block>
									</xsl:for-each>
								</fo:block-container>							
							</xsl:if>
									
							<xsl:if test="//itu:figure[@id and itu:name]">								
								<xsl:variable name="title-list-figures">
									<xsl:call-template name="getTitle">
										<xsl:with-param name="name" select="'title-list-figures'"/>
									</xsl:call-template>
								</xsl:variable>
								
								
								<fo:block space-before="36pt" text-align="center" font-weight="bold" keep-with-next="always">
									<xsl:value-of select="$title-list-figures"/>
								</fo:block>
								<fo:block margin-top="6pt" text-align="right" font-weight="bold" keep-with-next="always">
									<xsl:call-template name="getLocalizedString">
										<xsl:with-param name="key">Page.sg</xsl:with-param>
									</xsl:call-template>
								</fo:block>
								
								<fo:block-container>
									<xsl:for-each select="//itu:figure[@id and itu:name]">
										<fo:block text-align-last="justify" margin-top="6pt">
											<fo:basic-link internal-destination="{@id}" fox:alt-text="{itu:name}">
												<xsl:apply-templates select="itu:name" mode="contents"/>										
												<fo:inline keep-together.within-line="always">
													<fo:leader leader-pattern="dots"/>
													<fo:page-number-citation ref-id="{@id}"/>
												</fo:inline>
											</fo:basic-link>
										</fo:block>
									</xsl:for-each>
								</fo:block-container>							
							</xsl:if>
						</xsl:if>
							
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
				
					
					<fo:block-container font-size="14pt">
						<xsl:choose>
							<xsl:when test="$doctype = 'resolution'">
								<fo:block text-align="center">
									<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:title[@type='resolution' and @language = $lang]"/>
								</fo:block>
							</xsl:when>
							<xsl:when test="$doctype = 'implementers-guide'"/>
							<xsl:when test="$doctype = 'recommendation-supplement'">
									<fo:block font-weight="bold">
										<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:docidentifier[@type = 'ITU-Supplement-Internal']"/>
									</fo:block>
								</xsl:when>
							<xsl:otherwise>
								<fo:block font-weight="bold">
									<xsl:value-of select="$doctypeTitle"/>
									<xsl:text> </xsl:text>
									<xsl:value-of select="$docname"/>
								</fo:block>
							</xsl:otherwise>
						</xsl:choose>
						<fo:block font-weight="bold" text-align="center" margin-top="15pt" margin-bottom="15pt">
							<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:title[@type = 'main' and @language = $lang]"/>
							
							<xsl:variable name="subtitle" select="/itu:itu-standard/itu:bibdata/itu:title[@type = 'subtitle' and @language = $lang]"/>
							<xsl:if test="$subtitle != ''">
								<fo:block margin-top="18pt" font-weight="normal" font-style="italic">
									<xsl:value-of select="$subtitle"/>
								</fo:block>								
							</xsl:if>
							
							<xsl:variable name="resolution-placedate" select="/itu:itu-standard/itu:bibdata/itu:title[@type = 'resolution-placedate' and @language = $lang]"/>
							<xsl:if test="$doctype = 'resolution' and $resolution-placedate != ''">
								<fo:block font-size="11pt" margin-top="6pt" font-weight="normal">
									<fo:inline font-style="italic">
										<xsl:text>(</xsl:text><xsl:value-of select="$resolution-placedate"/><xsl:text>)</xsl:text>
									</fo:inline>
									<xsl:apply-templates select="/itu:itu-standard/itu:bibdata/itu:note[@type = 'title-footnote']" mode="title_footnote"/>
								</fo:block>
							</xsl:if>
						</fo:block>
					</fo:block-container>
						
					
					
					<!-- Clause(s) -->
					<fo:block>
						<!-- Scope -->
						<xsl:apply-templates select="/itu:itu-standard/itu:sections/itu:clause[@type='scope']"/> <!-- @id = 'scope' -->
							
						<!-- Normative references -->						
						<xsl:apply-templates select="/itu:itu-standard/itu:bibliography/itu:references[@normative='true']"/> <!-- @id = 'references' -->
							
						<xsl:apply-templates select="/itu:itu-standard/itu:sections/*[not(@type='scope')]"/> <!-- @id != 'scope' -->
							
						<xsl:apply-templates select="/itu:itu-standard/itu:annex"/>
						
						<!-- Bibliography -->
						<xsl:apply-templates select="/itu:itu-standard/itu:bibliography/itu:references[not(@normative='true')]"/> <!-- @id = 'bibliography' -->
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
			<!-- <xsl:call-template name="getSection"/> -->
			<xsl:for-each select="*[local-name() = 'title']/*[local-name() = 'tab'][1]/preceding-sibling::node()">
				<xsl:value-of select="."/>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:variable name="type">
			<xsl:value-of select="local-name()"/>
		</xsl:variable>
			
		<xsl:variable name="display">
			<xsl:choose>				
				<xsl:when test="$level &gt;= 3">false</xsl:when>
				<xsl:when test="$section = '' and $type = 'clause' and $level &gt;= 2">false</xsl:when>
				<xsl:otherwise>true</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="skip">
			<xsl:choose>
				<xsl:when test="ancestor-or-self::itu:bibitem">true</xsl:when>
				<xsl:when test="ancestor-or-self::itu:term">true</xsl:when>
				<xsl:when test="@inline-header = 'true' and not(*[local-name() = 'title']/*[local-name() = 'tab'])">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="$skip = 'false'">		
			
			<xsl:variable name="title">
				<xsl:call-template name="getName"/>
			</xsl:variable>
			
			<item level="{$level}" section="{$section}" type="{$type}" display="{$display}">
				<xsl:call-template name="setId"/>
				<title>
					<xsl:apply-templates select="xalan:nodeset($title)" mode="contents_item"/>
				</title>
				<xsl:apply-templates mode="contents"/>
			</item>
			
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
						<xsl:number format="a)" lang="en"/>
					</xsl:when>
					<xsl:when test="../@class = 'steps'">
						<xsl:number format="1)"/>
					</xsl:when>
					<xsl:when test="$level = 1">
						<xsl:number format="a)" lang="en"/>
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
		<xsl:variable name="previous-element" select="local-name(preceding-sibling::*[1])"/>
		<xsl:variable name="element-name">
			<xsl:choose>
				<xsl:when test="../@inline-header = 'true' and $previous-element = 'title'">fo:inline</xsl:when> <!-- first paragraph after inline title -->
				<xsl:otherwise>fo:block</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="{$element-name}">
			<xsl:attribute name="margin-top">6pt</xsl:attribute>
			<xsl:if test="@keep-with-next = 'true'">
				<xsl:attribute name="keep-with-next">always</xsl:attribute>
			</xsl:if>
			<xsl:if test="@class='supertitle'">
				<xsl:attribute name="space-before">36pt</xsl:attribute>
				<xsl:attribute name="margin-bottom">24pt</xsl:attribute>
				<xsl:attribute name="margin-top">0pt</xsl:attribute>
				<xsl:attribute name="font-size">14pt</xsl:attribute>
				
			</xsl:if>
			<xsl:attribute name="text-align">
				<xsl:choose>
					<xsl:when test="@class='supertitle'">center</xsl:when>
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
		</xsl:element>
		<xsl:if test="$element-name = 'fo:inline'">
			<fo:block><xsl:value-of select="$linebreak"/></fo:block>
		</xsl:if>
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
			<xsl:if test="$doctype = 'implementers-guide'">
				<xsl:attribute name="margin-left">0mm</xsl:attribute>
				<xsl:attribute name="text-indent">0mm</xsl:attribute>
			</xsl:if>
			
			<xsl:variable name="bibitem_label">
				<xsl:choose>
					<xsl:when test="itu:docidentifier[@type = 'metanorma']">
						<xsl:value-of select="itu:docidentifier[@type = 'metanorma']"/>
					</xsl:when>
					<xsl:otherwise>
						<fo:inline padding-right="5mm">
							<xsl:text>[</xsl:text>
								<xsl:value-of select="itu:docidentifier"/>
							<xsl:text>] </xsl:text>
						</fo:inline>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="bibitem_body">
				<xsl:text> </xsl:text>
				<xsl:choose>
					<xsl:when test="itu:docidentifier[@type = 'metanorma']">
						<xsl:if test="itu:docidentifier[not(@type) or not(@type = 'metanorma')]">
							<xsl:value-of select="itu:docidentifier[not(@type) or not(@type = 'metanorma')]"/>
							<xsl:text>, </xsl:text>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
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
			</xsl:variable>
			
			<xsl:choose>
				<xsl:when test="$doctype = 'implementers-guide'">
					<fo:table width="100%" table-layout="fixed">
						<fo:table-column column-width="20%"/>
						<fo:table-column column-width="80%"/>
						<fo:table-body>
							<fo:table-row>
								<fo:table-cell><fo:block><xsl:copy-of select="$bibitem_label"/></fo:block></fo:table-cell>
								<fo:table-cell><fo:block><xsl:copy-of select="$bibitem_body"/></fo:block></fo:table-cell>
							</fo:table-row>
						</fo:table-body>
					</fo:table>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="$bibitem_label"/>
					<xsl:copy-of select="$bibitem_body"/>
				</xsl:otherwise>
			</xsl:choose>
		
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
		<fo:block font-size="16pt" font-family="Times New Roman" font-style="italic" font-weight="bold" text-align="center" space-after="6pt">
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
			<xsl:if test="$doctype != 'resolution'">
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
			</xsl:if>
		</fo:block>
	</xsl:template>
	
	<!-- Bibliography -->
	<xsl:template match="itu:references[not(@normative='true')]/itu:title">
		<fo:block font-size="14pt" font-weight="bold" text-align="center" margin-bottom="18pt">
			<xsl:if test="$doctype = 'implementers-guide'">
				<xsl:attribute name="text-align">left</xsl:attribute>
				<xsl:attribute name="font-size">12pt</xsl:attribute>
				<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="itu:title">
		
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		
		<xsl:variable name="font-size">
			<xsl:choose>
				<xsl:when test="$level = 1 and $doctype = 'resolution'">14pt</xsl:when>
				<xsl:when test="$level &gt;= 2 and $doctype = 'resolution' and ../@inline-header = 'true'">11pt</xsl:when>
				<xsl:when test="$level = 2">12pt</xsl:when>
				<xsl:when test="$level &gt;= 3">12pt</xsl:when>
				<xsl:otherwise>12pt</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="element-name">
			<xsl:choose>
				<xsl:when test="../@inline-header = 'true'">fo:inline</xsl:when>
				<xsl:otherwise>fo:block</xsl:otherwise>
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
				<xsl:when test="$level = 1 and $doctype = 'resolution'">24pt</xsl:when>
				<xsl:when test="$level = 2">6pt</xsl:when>
				<xsl:otherwise>6pt</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="text-align">
			<xsl:choose>
				<xsl:when test="$level = 1 and $doctype = 'resolution'">center</xsl:when>
				<xsl:otherwise>left</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:element name="{$element-name}">
			<xsl:attribute name="font-size"><xsl:value-of select="$font-size"/></xsl:attribute>
			<xsl:attribute name="font-weight">bold</xsl:attribute>
			<xsl:attribute name="text-align"><xsl:value-of select="$text-align"/></xsl:attribute>
			<xsl:attribute name="space-before"><xsl:value-of select="$space-before"/></xsl:attribute>
			<xsl:attribute name="space-after"><xsl:value-of select="$space-after"/></xsl:attribute>
			<xsl:attribute name="keep-with-next">always</xsl:attribute>
			<xsl:if test="$element-name = 'fo:inline'">
				<xsl:attribute name="padding-right">
					<xsl:choose>
						<xsl:when test="$level = 2">9mm</xsl:when>
						<xsl:when test="$level = 3">6.5mm</xsl:when>
						<xsl:otherwise>4mm</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</xsl:element>
		
		<xsl:if test="$element-name = 'fo:inline' and not(following-sibling::itu:p)">
			<fo:block margin-bottom="12pt"><xsl:value-of select="$linebreak"/></fo:block>
		</xsl:if>
		
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
				<xsl:text>: </xsl:text>
				<xsl:variable name="citeas" select="../itu:termsource/itu:origin/@citeas"/>
				<xsl:variable name="bibitemid" select="../itu:termsource/itu:origin/@bibitemid"/>
				<xsl:variable name="origin_text" select="normalize-space(../itu:termsource/itu:origin/text())"/>
				
				<fo:basic-link internal-destination="{$bibitemid}" fox:alt-text="{$citeas}">
					<xsl:choose>
						<xsl:when test="$origin_text != ''">
							<xsl:text> </xsl:text><xsl:apply-templates select="../itu:termsource/itu:origin/node()"/>
						</xsl:when>
						<xsl:when test="contains($citeas, '[')">
							<xsl:text> </xsl:text><xsl:value-of select="$citeas"/> <!--  disable-output-escaping="yes" -->
						</xsl:when>
						<xsl:otherwise>
							<xsl:text> [</xsl:text><xsl:value-of select="$citeas"/><xsl:text>]</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</fo:basic-link>
			</xsl:if>			
			<xsl:if test="following-sibling::itu:definition/node()">
				<xsl:text>: </xsl:text>
				<xsl:apply-templates select="following-sibling::itu:definition/node()" mode="process"/>			
			</xsl:if>			
		</fo:block>
		<!-- <xsl:if test="following-sibling::itu:table">
			<fo:block space-after="18pt">&#xA0;</fo:block>
		</xsl:if> -->
	</xsl:template>
	
	<xsl:template match="itu:term[itu:preferred]/itu:termsource" priority="2"/>
	
	
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

	<!-- footnotes for title -->
	<xsl:template match="itu:bibdata/itu:note[@type = 'title-footnote']" mode="title_footnote">
		<xsl:variable name="number" select="position()"/>
		<fo:footnote>
			<fo:inline font-size="60%" keep-with-previous.within-line="always" vertical-align="super">
				<fo:basic-link internal-destination="title_footnote_{$number}" fox:alt-text="titlefootnote  {$number}">
					<xsl:value-of select="$number"/>
				</fo:basic-link>
				<xsl:if test="position() != last()">,</xsl:if><!-- <fo:inline  baseline-shift="20%">,</fo:inline> -->
			</fo:inline>
			<fo:footnote-body>
				<fo:block font-size="11pt" margin-bottom="12pt" text-align="justify">
					<fo:inline id="title_footnote_{$number}" font-size="85%" padding-right="2mm" keep-with-next.within-line="always" baseline-shift="30%">
						<xsl:value-of select="$number"/>
					</fo:inline>
					<xsl:apply-templates/>
				</fo:block>
			</fo:footnote-body>
		</fo:footnote>
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
		<xsl:variable name="count_title_footnotes" select="count(/itu:itu-standard/itu:bibdata/itu:note[@type='title-footnote'])"/>
		<xsl:variable name="count_bibitem_notes" select="count(//itu:bibitem/itu:note)"/>
		<xsl:variable name="current_fn_number" select="$number + $count_title_footnotes + $count_bibitem_notes"/>
		<xsl:choose>
			<xsl:when test="xalan:nodeset($p_fn)//fn[@gen_id = $gen_id]">
				<fo:footnote>
					<fo:inline font-size="60%" keep-with-previous.within-line="always" vertical-align="super">
						<fo:basic-link internal-destination="footnote_{@reference}_{$number}" fox:alt-text="footnote {@reference} {$number}">
							<xsl:value-of select="$current_fn_number"/>
						</fo:basic-link>
					</fo:inline>
					<fo:footnote-body>
						<fo:block font-size="11pt" margin-bottom="12pt" text-align="justify">
							<fo:inline id="footnote_{@reference}_{$number}" font-size="85%" padding-right="2mm" keep-with-next.within-line="always" baseline-shift="30%">
								<xsl:value-of select="$current_fn_number"/>
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
						<xsl:value-of select="$current_fn_number"/>
					</fo:basic-link>
				</fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<xsl:template match="*[local-name()='tt']" priority="2">
		<xsl:variable name="element-name">
			<xsl:choose>
				<xsl:when test="ancestor::itu:dd">fo:inline</xsl:when>
				<xsl:when test="ancestor::itu:title">fo:inline</xsl:when>
				<xsl:when test="normalize-space(ancestor::itu:p[1]//text()[not(parent::itu:tt)]) != ''">fo:inline</xsl:when>
				<xsl:otherwise>fo:block</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="{$element-name}">
			<xsl:attribute name="font-family">Courier</xsl:attribute>
			<xsl:attribute name="font-size">10pt</xsl:attribute>
			<xsl:if test="local-name(..) != 'dt' and not(ancestor::itu:dd) and not(ancestor::itu:title)">
				<xsl:attribute name="text-align">center</xsl:attribute>
			</xsl:if>
			<xsl:if test="ancestor::itu:title">
				<xsl:attribute name="font-size">11pt</xsl:attribute>
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
	
	
	<xsl:template match="itu:ul | itu:ol | itu:sections/itu:ul | itu:sections/itu:ol" mode="ul_ol">
		<xsl:if test="preceding-sibling::*[1][local-name() = 'title']">
			<fo:block padding-top="-8pt" font-size="1pt"> </fo:block>
		</xsl:if>
		<fo:list-block>
			<xsl:apply-templates/>
		</fo:list-block>
		<xsl:apply-templates select="./itu:note" mode="process"/>
		<xsl:if test="../@inline-header='true'">
			<fo:block><xsl:value-of select="$linebreak"/></fo:block>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="itu:ul//itu:note |  itu:ol//itu:note" priority="2"/>
	<xsl:template match="itu:ul//itu:note  | itu:ol//itu:note" mode="process">
		<fo:block id="{@id}">
			<xsl:apply-templates select="itu:name" mode="presentation"/>
			<xsl:apply-templates mode="process"/>
		</fo:block>
	</xsl:template>
	<xsl:template match="itu:ul//itu:note/itu:name  | itu:ol//itu:note/itu:name" mode="process" priority="2"/>
	<xsl:template match="itu:ul//itu:note/itu:p  | itu:ol//itu:note/itu:p" mode="process" priority="2">		
		<fo:block font-size="11pt" margin-top="4pt">			
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="itu:ul//itu:note/*  | itu:ol//itu:note/*" mode="process">
		<xsl:apply-templates select="."/>
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
		<fo:inline font-family="STIX Two Math" font-size="11pt">
			<xsl:variable name="mathml">
				<xsl:apply-templates select="." mode="mathml"/>
			</xsl:variable>
			<fo:instream-foreign-object fox:alt-text="Math"> 
				<!-- <xsl:copy-of select="."/> -->
				<xsl:copy-of select="xalan:nodeset($mathml)"/>
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
								<fo:block><xsl:value-of select="$footer-text"/></fo:block>
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
								<fo:block><xsl:value-of select="$footer-text"/></fo:block>
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
	
	<xsl:variable name="Image-Logo_resolution">
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
	
	<xsl:template name="formatMeetingDate">
		<xsl:param name="date"/>
		<xsl:variable name="year" select="substring($date, 1, 4)"/>
		<xsl:variable name="month" select="substring($date, 6, 2)"/>
		<xsl:variable name="day" select="substring($date, 9)"/>
		
		<xsl:variable name="monthStr">
			<xsl:choose>
				<xsl:when test="$month = '01'">Jan</xsl:when>
				<xsl:when test="$month = '02'">Feb</xsl:when>
				<xsl:when test="$month = '03'">Mar</xsl:when>
				<xsl:when test="$month = '04'">Apr</xsl:when>
				<xsl:when test="$month = '05'">May</xsl:when>
				<xsl:when test="$month = '06'">Jun</xsl:when>
				<xsl:when test="$month = '07'">Jul</xsl:when>
				<xsl:when test="$month = '08'">Aug</xsl:when>
				<xsl:when test="$month = '09'">Sep</xsl:when>
				<xsl:when test="$month = '10'">Oct</xsl:when>
				<xsl:when test="$month = '11'">Nov</xsl:when>
				<xsl:when test="$month = '12'">Dec</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:value-of select="$day"/><xsl:text> </xsl:text><xsl:value-of select="$monthStr"/><xsl:text> </xsl:text><xsl:value-of select="$year"/>
		
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
		
		<title-edition lang="fr">
			
				<xsl:text>Édition </xsl:text>
			
		</title-edition>
		

		<title-toc lang="en">
			
			
				<xsl:text>Table of Contents</xsl:text>
			
			
		</title-toc>
		<title-toc lang="fr">
			
				<xsl:text>Sommaire</xsl:text>
			
			
			</title-toc>
		
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
		
		<title-subpart lang="en">			
			
		</title-subpart>
		<title-subpart lang="fr">		
			
		</title-subpart>
		
		<title-modified lang="en">modified</title-modified>
		<title-modified lang="fr">modifiée</title-modified>
		
			<title-modified lang="zh">modified</title-modified>
		
		
		
		<title-source lang="en">
			
				<xsl:text>SOURCE</xsl:text>
						
			 
		</title-source>
		
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
		
		<title-continued lang="en">(continued)</title-continued>
		<title-continued lang="fr">(continué)</title-continued>
		
	</xsl:variable><xsl:variable name="tab_zh">　</xsl:variable><xsl:template name="getTitle">
		<xsl:param name="name"/>
		<xsl:param name="lang"/>
		<xsl:variable name="lang_">
			<xsl:choose>
				<xsl:when test="$lang != ''">
					<xsl:value-of select="$lang"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="getLang"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="language" select="normalize-space($lang_)"/>
		<xsl:variable name="title_" select="$titles/*[local-name() = $name][@lang = $language]"/>
		<xsl:choose>
			<xsl:when test="normalize-space($title_) != ''">
				<xsl:value-of select="$title_"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$titles/*[local-name() = $name][@lang = 'en']"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable><xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable><xsl:variable name="en_chars" select="concat($lower,$upper,',.`1234567890-=~!@#$%^*()_+[]{}\|?/')"/><xsl:variable name="linebreak" select="'&#8232;'"/><xsl:attribute-set name="root-style">
		
	</xsl:attribute-set><xsl:attribute-set name="link-style">
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="sourcecode-style">
		<xsl:attribute name="white-space">pre</xsl:attribute>
		<xsl:attribute name="wrap-option">wrap</xsl:attribute>
		
		
		
		
		
			<xsl:attribute name="font-family">Courier</xsl:attribute>			
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
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:variable name="note-body-indent">10mm</xsl:variable><xsl:variable name="note-body-indent-table">5mm</xsl:variable><xsl:attribute-set name="note-name-style">
		
		
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="note-p-style">
		
		
		
				
		
		
					
			<xsl:attribute name="space-before">4pt</xsl:attribute>			
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="termnote-style">
		
		
		
					
			<xsl:attribute name="margin-top">4pt</xsl:attribute>			
		
		
	</xsl:attribute-set><xsl:attribute-set name="termnote-name-style">		
				
		
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
		<xsl:attribute name="keep-with-previous">always</xsl:attribute>
		
	</xsl:attribute-set><xsl:attribute-set name="domain-style">
				
	</xsl:attribute-set><xsl:attribute-set name="admitted-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="deprecates-style">
		
	</xsl:attribute-set><xsl:attribute-set name="definition-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="add-style">
		<xsl:attribute name="color">red</xsl:attribute>
		<xsl:attribute name="text-decoration">underline</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="del-style">
		<xsl:attribute name="color">red</xsl:attribute>
		<xsl:attribute name="text-decoration">line-through</xsl:attribute>
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
	</xsl:template><xsl:template match="*[local-name()='table']" name="table">
	
		<xsl:variable name="table">
	
			<xsl:variable name="simple-table">	
				<xsl:call-template name="getSimpleTable"/>			
			</xsl:variable>
		
			
				<fo:block space-before="18pt"> </fo:block>				
			
			
			
			
			<!-- <xsl:if test="$namespace = 'bipm'">
				<fo:block>&#xA0;</fo:block>				
			</xsl:if> -->
			
			<!-- $namespace = 'iso' or  -->
			
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
				<xsl:if test="not(*[local-name()='colgroup']/*[local-name()='col'])">
					<xsl:call-template name="calculate-column-widths">
						<xsl:with-param name="cols-count" select="$cols-count"/>
						<xsl:with-param name="table" select="$simple-table"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:variable>
			<!-- colwidths=<xsl:copy-of select="$colwidths"/> -->
			
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
				
					<xsl:attribute name="font-size">10pt</xsl:attribute>
				
				
					<xsl:attribute name="space-after">6pt</xsl:attribute>
				
							
							
							
				
					<xsl:attribute name="margin-left">0mm</xsl:attribute>
					<xsl:attribute name="margin-right">0mm</xsl:attribute>
					<xsl:attribute name="space-after">18pt</xsl:attribute>
				
				
										
				
				
				
				
				
				
				<xsl:variable name="table_width">
					<!-- for centered table always 100% (@width will be set for middle/second cell of outer table) -->
					100%
							
					
				</xsl:variable>
				
				<xsl:variable name="table_attributes">
					<attribute name="table-layout">fixed</attribute>
					<attribute name="width"><xsl:value-of select="normalize-space($table_width)"/></attribute>
					<attribute name="margin-left"><xsl:value-of select="$margin-left"/>mm</attribute>
					<attribute name="margin-right"><xsl:value-of select="$margin-left"/>mm</attribute>
					
					
					
						<attribute name="margin-left">0mm</attribute>
						<attribute name="margin-right">0mm</attribute>
					
					
									
									
									
					
									
					
				</xsl:variable>
				
				
				<fo:table id="{@id}" table-omit-footer-at-break="true">
					
					<xsl:for-each select="xalan:nodeset($table_attributes)/attribute">					
						<xsl:attribute name="{@name}">
							<xsl:value-of select="."/>
						</xsl:attribute>
					</xsl:for-each>
					
					<xsl:variable name="isNoteOrFnExist" select="./*[local-name()='note'] or .//*[local-name()='fn'][local-name(..) != 'name']"/>				
					<xsl:if test="$isNoteOrFnExist = 'true'">
						<xsl:attribute name="border-bottom">0pt solid black</xsl:attribute> <!-- set 0pt border, because there is a separete table below for footer  -->
					</xsl:if>
					
					<xsl:choose>
						<xsl:when test="*[local-name()='colgroup']/*[local-name()='col']">
							<xsl:for-each select="*[local-name()='colgroup']/*[local-name()='col']">
								<fo:table-column column-width="{@width}"/>
							</xsl:for-each>
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
					
					<xsl:choose>
						<xsl:when test="not(*[local-name()='tbody']) and *[local-name()='thead']">
							<xsl:apply-templates select="*[local-name()='thead']" mode="process_tbody"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates/>
						</xsl:otherwise>
					</xsl:choose>
					
				</fo:table>
				
				<xsl:variable name="colgroup" select="*[local-name()='colgroup']"/>				
				<xsl:for-each select="*[local-name()='tbody']"><!-- select context to tbody -->
					<xsl:call-template name="insertTableFooterInSeparateTable">
						<xsl:with-param name="table_attributes" select="$table_attributes"/>
						<xsl:with-param name="colwidths" select="$colwidths"/>				
						<xsl:with-param name="colgroup" select="$colgroup"/>				
					</xsl:call-template>
				</xsl:for-each>
				
				<!-- insert footer as table -->
				<!-- <fo:table>
					<xsl:for-each select="xalan::nodeset($table_attributes)/attribute">
						<xsl:attribute name="{@name}">
							<xsl:value-of select="."/>
						</xsl:attribute>
					</xsl:for-each>
					
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
				</fo:table>-->
				
				
				
				
				
			</fo:block-container>
		</xsl:variable>
		
		
		
		<xsl:choose>
			<xsl:when test="@width">
	
				<!-- centered table when table name is centered (see table-name-style) -->
				
					<fo:table table-layout="fixed" width="100%">
						<fo:table-column column-width="proportional-column-width(1)"/>
						<fo:table-column column-width="{@width}"/>
						<fo:table-column column-width="proportional-column-width(1)"/>
						<fo:table-body>
							<fo:table-row>
								<fo:table-cell column-number="2">
									<fo:block><xsl:copy-of select="$table"/></fo:block>
								</fo:table-cell>
							</fo:table-row>
						</fo:table-body>
					</fo:table>
				
				
				
				
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="$table"/>
			</xsl:otherwise>
		</xsl:choose>
		
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
								
								<!-- <xsl:if test="$namespace = 'bipm'">
									<xsl:for-each select="*[local-name()='td'][$curr-col]//*[local-name()='math']">									
										<word><xsl:value-of select="normalize-space(.)"/></word>
									</xsl:for-each>
								</xsl:if> -->
								
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
	</xsl:template><xsl:template match="*[local-name()='math']" mode="td_text">
		<xsl:variable name="mathml">
			<xsl:for-each select="*">
				<xsl:if test="local-name() != 'unit' and local-name() != 'prefix' and local-name() != 'dimension' and local-name() != 'quantity'">
					<xsl:copy-of select="."/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:variable name="math_text" select="normalize-space(xalan:nodeset($mathml))"/>
		<xsl:value-of select="translate($math_text, ' ', '#')"/><!-- mathml images as one 'word' without spaces -->
	</xsl:template><xsl:template match="*[local-name()='table2']"/><xsl:template match="*[local-name()='thead']"/><xsl:template match="*[local-name()='thead']" mode="process">
		<xsl:param name="cols-count"/>
		<!-- font-weight="bold" -->
		<fo:table-header>
			
			<xsl:apply-templates/>
		</fo:table-header>
	</xsl:template><xsl:template name="table-header-title">
		<xsl:param name="cols-count"/>		
		<!-- row for title -->
		<fo:table-row>
			<fo:table-cell number-columns-spanned="{$cols-count}" border-left="1.5pt solid white" border-right="1.5pt solid white" border-top="1.5pt solid white" border-bottom="1.5pt solid black">
				<xsl:apply-templates select="ancestor::*[local-name()='table']/*[local-name()='name']" mode="presentation"/>
				<xsl:for-each select="ancestor::*[local-name()='table'][1]">
					<xsl:call-template name="fn_name_display"/>
				</xsl:for-each>				
				<fo:block text-align="right" font-style="italic">
					<xsl:text> </xsl:text>
					<fo:retrieve-table-marker retrieve-class-name="table_continued"/>
				</fo:block>
			</fo:table-cell>
		</fo:table-row>
	</xsl:template><xsl:template match="*[local-name()='thead']" mode="process_tbody">		
		<fo:table-body>
			<xsl:apply-templates/>
		</fo:table-body>
	</xsl:template><xsl:template match="*[local-name()='tfoot']"/><xsl:template match="*[local-name()='tfoot']" mode="process">
		<xsl:apply-templates/>
	</xsl:template><xsl:template name="insertTableFooter">
		<xsl:param name="cols-count"/>
		<xsl:if test="../*[local-name()='tfoot']">
			<fo:table-footer>			
				<xsl:apply-templates select="../*[local-name()='tfoot']" mode="process"/>
			</fo:table-footer>
		</xsl:if>
	</xsl:template><xsl:template name="insertTableFooter2">
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
							
							
							<!-- show Note under table in preface (ex. abstract) sections -->
							<!-- empty, because notes show at page side in main sections -->
							<!-- <xsl:if test="$namespace = 'bipm'">
								<xsl:choose>
									<xsl:when test="ancestor::*[local-name()='preface']">										
										<xsl:apply-templates select="../*[local-name()='note']" mode="process"/>
									</xsl:when>
									<xsl:otherwise>										
									<fo:block/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if> -->
							
							
							<!-- horizontal row separator -->
							
							
							<!-- fn processing -->
							<xsl:call-template name="fn_display"/>
							
						</fo:table-cell>
					</fo:table-row>
					
				</xsl:if>
			</fo:table-footer>
		
		</xsl:if>
	</xsl:template><xsl:template name="insertTableFooterInSeparateTable">
		<xsl:param name="table_attributes"/>
		<xsl:param name="colwidths"/>
		<xsl:param name="colgroup"/>
		
		<xsl:variable name="isNoteOrFnExist" select="../*[local-name()='note'] or ..//*[local-name()='fn'][local-name(..) != 'name']"/>
		
		<xsl:if test="$isNoteOrFnExist = 'true'">
		
			<xsl:variable name="cols-count">
				<xsl:choose>
					<xsl:when test="xalan:nodeset($colgroup)//*[local-name()='col']">
						<xsl:value-of select="count(xalan:nodeset($colgroup)//*[local-name()='col'])"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="count(xalan:nodeset($colwidths)//column)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<fo:table keep-with-previous="always">
				<xsl:for-each select="xalan:nodeset($table_attributes)/attribute">
					<xsl:choose>
						<xsl:when test="@name = 'border-top'">
							<xsl:attribute name="{@name}">0pt solid black</xsl:attribute>
						</xsl:when>
						<xsl:when test="@name = 'border'">
							<xsl:attribute name="{@name}"><xsl:value-of select="."/></xsl:attribute>
							<xsl:attribute name="border-top">0pt solid black</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="{@name}"><xsl:value-of select="."/></xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
				
				<xsl:choose>
					<xsl:when test="xalan:nodeset($colgroup)//*[local-name()='col']">
						<xsl:for-each select="xalan:nodeset($colgroup)//*[local-name()='col']">
							<fo:table-column column-width="{@width}"/>
						</xsl:for-each>
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
				
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell border="solid black 1pt" padding-left="1mm" padding-right="1mm" padding-top="1mm" number-columns-spanned="{$cols-count}">
							
							
							
								<xsl:if test="ancestor::*[local-name()='preface']">
									<xsl:attribute name="border">solid black 0pt</xsl:attribute>
								</xsl:if>
							
							<!-- fn will be processed inside 'note' processing -->
							
							
							
							
							
							
							
							<!-- except gb  -->
							
								<xsl:apply-templates select="../*[local-name()='note']" mode="process"/>
							
							
							<!-- <xsl:if test="$namespace = 'bipm'">
								<xsl:choose>
									<xsl:when test="ancestor::*[local-name()='preface']">
										show Note under table in preface (ex. abstract) sections
										<xsl:apply-templates select="../*[local-name()='note']" mode="process"/>
									</xsl:when>
									<xsl:otherwise>
										empty, because notes show at page side in main sections
									<fo:block/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if> -->
							
							
							<!-- horizontal row separator -->
							
							
							<!-- fn processing -->
							<xsl:call-template name="fn_display"/>
							
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
				
			</fo:table>
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
				
				
				
				
				<!-- <xsl:if test="$namespace = 'bipm'">
					<xsl:attribute name="height">8mm</xsl:attribute>
				</xsl:if> -->
				
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
			<xsl:call-template name="display-align"/>
			<fo:block>
				<xsl:apply-templates/>
			</fo:block>
		</fo:table-cell>
	</xsl:template><xsl:template name="display-align">
		<xsl:if test="@valign">
			<xsl:attribute name="display-align">
				<xsl:choose>
					<xsl:when test="@valign = 'top'">before</xsl:when>
					<xsl:when test="@valign = 'middle'">center</xsl:when>
					<xsl:when test="@valign = 'bottom'">after</xsl:when>
					<xsl:otherwise>before</xsl:otherwise>
				</xsl:choose>					
			</xsl:attribute>
		</xsl:if>
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
			<xsl:call-template name="display-align"/>
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
						
						<!-- <xsl:apply-templates /> -->
						<xsl:copy-of select="./node()"/>
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
					<xsl:variable name="doc_ns">
						
					</xsl:variable>
					<xsl:variable name="ns">
						<xsl:choose>
							<xsl:when test="normalize-space($doc_ns)  != ''">
								<xsl:value-of select="normalize-space($doc_ns)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="substring-before(name(/*), '-')"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<!-- <xsl:variable name="ns" select="substring-before(name(/*), '-')"/> -->
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
											
											<!-- <xsl:apply-templates /> -->
											<xsl:copy-of select="./node()"/>
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
		<fo:block-container>
			
				<xsl:if test="not(ancestor::*[local-name() = 'quote'])">
					<xsl:attribute name="margin-left">0mm</xsl:attribute>
				</xsl:if>
			
			
			<xsl:if test="parent::*[local-name() = 'note']">
				<xsl:attribute name="margin-left">
					<xsl:choose>
						<xsl:when test="not(ancestor::*[local-name() = 'table'])"><xsl:value-of select="$note-body-indent"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="$note-body-indent-table"/></xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				
			</xsl:if>
			<fo:block-container>
				
					<xsl:attribute name="margin-left">0mm</xsl:attribute>
					<xsl:attribute name="margin-right">0mm</xsl:attribute>
				
				
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
									<xsl:variable name="doc_ns">
										
									</xsl:variable>
									<xsl:variable name="ns">
										<xsl:choose>
											<xsl:when test="normalize-space($doc_ns)  != ''">
												<xsl:value-of select="normalize-space($doc_ns)"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="substring-before(name(/*), '-')"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<!-- <xsl:variable name="ns" select="substring-before(name(/*), '-')"/> -->
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
								<!-- colwidths=<xsl:copy-of select="$colwidths"/> -->
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
			</fo:block-container>
		</fo:block-container>
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
					<!-- to set width check most wide chars like `W` -->
					<xsl:when test="normalize-space($maxlength_dt) != '' and number($maxlength_dt) &lt;= 2"> <!-- if dt contains short text like t90, a, etc -->
						<fo:table-column column-width="7%"/>
						<fo:table-column column-width="93%"/>
					</xsl:when>
					<xsl:when test="normalize-space($maxlength_dt) != '' and number($maxlength_dt) &lt;= 5"> <!-- if dt contains short text like ABC, etc -->
						<fo:table-column column-width="15%"/>
						<fo:table-column column-width="85%"/>
					</xsl:when>
					<xsl:when test="normalize-space($maxlength_dt) != '' and number($maxlength_dt) &lt;= 7"> <!-- if dt contains short text like ABCDEF, etc -->
						<fo:table-column column-width="20%"/>
						<fo:table-column column-width="80%"/>
					</xsl:when>
					<xsl:when test="normalize-space($maxlength_dt) != '' and number($maxlength_dt) &lt;= 10"> <!-- if dt contains short text like ABCDEFEF, etc -->
						<fo:table-column column-width="25%"/>
						<fo:table-column column-width="75%"/>
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
		<xsl:variable name="lengths">
			<xsl:for-each select="*[local-name()='dt']">
				<xsl:variable name="maintext_length" select="string-length(normalize-space(.))"/>
				<xsl:variable name="attributes">
					<xsl:for-each select=".//@open"><xsl:value-of select="."/></xsl:for-each>
					<xsl:for-each select=".//@close"><xsl:value-of select="."/></xsl:for-each>
				</xsl:variable>
				<length><xsl:value-of select="string-length(normalize-space(.)) + string-length($attributes)"/></length>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="maxLength">
			<!-- <xsl:for-each select="*[local-name()='dt']">
				<xsl:sort select="string-length(normalize-space(.))" data-type="number" order="descending"/>
				<xsl:if test="position() = 1">
					<xsl:value-of select="string-length(normalize-space(.))"/>
				</xsl:if>
			</xsl:for-each> -->
			<xsl:for-each select="xalan:nodeset($lengths)/length">
				<xsl:sort select="." data-type="number" order="descending"/>
				<xsl:if test="position() = 1">
					<xsl:value-of select="."/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<!-- <xsl:message>DEBUG:<xsl:value-of select="$maxLength"/></xsl:message> -->
		<xsl:value-of select="$maxLength"/>
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
					
					<!-- <xsl:if test="$namespace = 'nist-cswp'  or $namespace = 'nist-sp'">
						<xsl:if test="local-name(*[1]) != 'stem'">
							<xsl:apply-templates select="following-sibling::*[local-name()='dd'][1]" mode="process"/>
						</xsl:if>
					</xsl:if> -->
					
						<xsl:apply-templates select="following-sibling::*[local-name()='dd'][1]" mode="process"/>
					
				</fo:block>
			</fo:table-cell>
		</fo:table-row>
		<!-- <xsl:if test="$namespace = 'nist-cswp'  or $namespace = 'nist-sp'">
			<xsl:if test="local-name(*[1]) = 'stem'">
				<fo:table-row>
				<fo:table-cell>
					<fo:block margin-top="6pt">
						<xsl:if test="normalize-space($key_iso) = 'true'">
							<xsl:attribute name="margin-top">0</xsl:attribute>
						</xsl:if>
						<xsl:text>&#xA0;</xsl:text>
					</fo:block>
				</fo:table-cell>
				<fo:table-cell>
					<fo:block>
						<xsl:apply-templates select="following-sibling::*[local-name()='dd'][1]" mode="process"/>
					</fo:block>
				</fo:table-cell>
			</fo:table-row>
			</xsl:if>
		</xsl:if> -->
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
			<xsl:variable name="_font-size">
				
				
				
				
				
				
				
				
				
				
				
				
				
				
						
			</xsl:variable>
			<xsl:variable name="font-size" select="normalize-space($_font-size)"/>		
			<xsl:if test="$font-size != ''">
				<xsl:attribute name="font-size">
					<xsl:choose>
						<xsl:when test="ancestor::*[local-name()='note']"><xsl:value-of select="$font-size * 0.91"/>pt</xsl:when>
						<xsl:otherwise><xsl:value-of select="$font-size"/>pt</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='underline']">
		<fo:inline text-decoration="underline">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='add']">
		<fo:inline xsl:use-attribute-sets="add-style">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='del']">
		<fo:inline xsl:use-attribute-sets="del-style">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='hi']">
		<fo:inline background-color="yellow">
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
	</xsl:template><xsl:template name="add-zero-spaces-link-java">
		<xsl:param name="text" select="."/>
		<!-- add zero-width space (#x200B) after characters: dash, dot, colon, equal, underscore, em dash, thin space  -->
		<xsl:value-of select="java:replaceAll(java:java.lang.String.new($text),'(-|\.|:|=|_|—| |,)','$1​')"/>
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
		<xsl:variable name="language_current" select="normalize-space(//*[local-name()='bibdata']//*[local-name()='language'][@current = 'true'])"/>
		<xsl:variable name="language">
			<xsl:choose>
				<xsl:when test="$language_current != ''">
					<xsl:value-of select="$language_current"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="//*[local-name()='bibdata']//*[local-name()='language']"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
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
		<fo:inline font-family="STIX Two Math"> <!--  -->
			
			<xsl:variable name="mathml">
				<xsl:apply-templates select="." mode="mathml"/>
			</xsl:variable>
			<fo:instream-foreign-object fox:alt-text="Math">
				
				<!-- <xsl:copy-of select="."/> -->
				<xsl:copy-of select="xalan:nodeset($mathml)"/>
			</fo:instream-foreign-object>			
		</fo:inline>
	</xsl:template><xsl:template match="@*|node()" mode="mathml">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="mathml"/>
		</xsl:copy>
	</xsl:template><xsl:template match="mathml:mtext" mode="mathml">
		<xsl:copy>
			<!-- replace start and end spaces to non-break space -->
			<xsl:value-of select="java:replaceAll(java:java.lang.String.new(.),'(^ )|( $)',' ')"/>
		</xsl:copy>
	</xsl:template><xsl:template match="mathml:mi[. = ',' and not(following-sibling::*[1][local-name() = 'mtext' and text() = ' '])]" mode="mathml">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="mathml"/>
		</xsl:copy>
		<mathml:mspace width="0.5ex"/>
	</xsl:template><xsl:template match="mathml:math/*[local-name()='unit']" mode="mathml"/><xsl:template match="mathml:math/*[local-name()='prefix']" mode="mathml"/><xsl:template match="mathml:math/*[local-name()='dimension']" mode="mathml"/><xsl:template match="mathml:math/*[local-name()='quantity']" mode="mathml"/><xsl:template match="*[local-name()='localityStack']"/><xsl:template match="*[local-name()='link']" name="link">
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
								<!-- <xsl:value-of select="$target"/> -->
								<xsl:call-template name="add-zero-spaces-link-java">
									<xsl:with-param name="text" select="$target"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates/>
							</xsl:otherwise>
						</xsl:choose>
					</fo:basic-link>
				</xsl:otherwise>
			</xsl:choose>
		</fo:inline>
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
		<fo:block-container margin-left="0mm">
			<xsl:if test="parent::*[local-name() = 'note']">
				<xsl:attribute name="margin-left">
					<xsl:choose>
						<xsl:when test="not(ancestor::*[local-name() = 'table'])"><xsl:value-of select="$note-body-indent"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="$note-body-indent-table"/></xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				
			</xsl:if>
			<fo:block-container margin-left="0mm">	
				<fo:block id="{@id}" xsl:use-attribute-sets="formula-style">
					<xsl:apply-templates/>
				</fo:block>
			</fo:block-container>
		</fo:block-container>
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
			<fo:inline xsl:use-attribute-sets="termnote-name-style">
				<xsl:apply-templates select="*[local-name() = 'name']" mode="presentation"/>
			</fo:inline>
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
	</xsl:template><xsl:template match="*[local-name() = 'figure']" name="figure">
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
		<xsl:apply-templates select="*[local-name() = 'name']" mode="presentation"/>
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
					<xsl:when test="not(starts-with(@src, 'data:'))">
						<xsl:value-of select="concat('url(file:',$basepath, @src, ')')"/>
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
	</xsl:template><xsl:template match="*[local-name() = 'figure']/*[local-name() = 'name'] |                *[local-name() = 'table']/*[local-name() = 'name'] |               *[local-name() = 'permission']/*[local-name() = 'name'] |               *[local-name() = 'recommendation']/*[local-name() = 'name'] |               *[local-name() = 'requirement']/*[local-name() = 'name']" mode="bookmarks">		
		<xsl:apply-templates mode="bookmarks"/>
		<xsl:text> </xsl:text>
	</xsl:template><xsl:template match="*[local-name() = 'name']/text()" mode="contents" priority="2">
		<xsl:value-of select="."/>
	</xsl:template><xsl:template match="*[local-name() = 'name']/text()" mode="bookmarks" priority="2">
		<xsl:value-of select="."/>
	</xsl:template><xsl:template match="node()" mode="contents">
		<xsl:apply-templates mode="contents"/>
	</xsl:template><xsl:template match="node()" mode="bookmarks">
		<xsl:apply-templates mode="bookmarks"/>
	</xsl:template><xsl:template match="*[local-name() = 'stem']" mode="contents">
		<xsl:apply-templates select="."/>
	</xsl:template><xsl:template match="*[local-name() = 'references'][@hidden='true']" mode="contents" priority="3"/><xsl:template match="*[local-name() = 'stem']" mode="bookmarks">
		<xsl:apply-templates mode="bookmarks"/>
	</xsl:template><xsl:template name="addBookmarks">
		<xsl:param name="contents"/>
		<xsl:if test="xalan:nodeset($contents)//item">
			<fo:bookmark-tree>
				<xsl:choose>
					<xsl:when test="xalan:nodeset($contents)/doc">
						<xsl:choose>
							<xsl:when test="count(xalan:nodeset($contents)/doc) &gt; 1">
								<xsl:for-each select="xalan:nodeset($contents)/doc">
									<fo:bookmark internal-destination="{contents/item[1]/@id}" starting-state="hide">
										<fo:bookmark-title>
											<xsl:variable name="bookmark-title_">
												<xsl:call-template name="getLangVersion">
													<xsl:with-param name="lang" select="@lang"/>
													<xsl:with-param name="doctype" select="@doctype"/>
													<xsl:with-param name="title" select="@title-part"/>
												</xsl:call-template>
											</xsl:variable>
											<xsl:choose>
												<xsl:when test="normalize-space($bookmark-title_) != ''">
													<xsl:value-of select="normalize-space($bookmark-title_)"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:choose>
														<xsl:when test="@lang = 'en'">English</xsl:when>
														<xsl:when test="@lang = 'fr'">Français</xsl:when>
														<xsl:when test="@lang = 'de'">Deutsche</xsl:when>
														<xsl:otherwise><xsl:value-of select="@lang"/> version</xsl:otherwise>
													</xsl:choose>
												</xsl:otherwise>
											</xsl:choose>
										</fo:bookmark-title>
										<xsl:apply-templates select="contents/item" mode="bookmark"/>
										
										<xsl:call-template name="insertFigureBookmarks">
											<xsl:with-param name="contents" select="contents"/>
										</xsl:call-template>
										
										<xsl:call-template name="insertTableBookmarks">
											<xsl:with-param name="contents" select="contents"/>
											<xsl:with-param name="lang" select="@lang"/>
										</xsl:call-template>
										
									</fo:bookmark>
									
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:for-each select="xalan:nodeset($contents)/doc">
								
									<xsl:apply-templates select="contents/item" mode="bookmark"/>
									
									<xsl:call-template name="insertFigureBookmarks">
										<xsl:with-param name="contents" select="contents"/>
									</xsl:call-template>
										
									<xsl:call-template name="insertTableBookmarks">
										<xsl:with-param name="contents" select="contents"/>
										<xsl:with-param name="lang" select="@lang"/>
									</xsl:call-template>
									
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="xalan:nodeset($contents)/contents/item" mode="bookmark"/>				
					</xsl:otherwise>
				</xsl:choose>
				
				
				
				
				
				
				
				
			</fo:bookmark-tree>
		</xsl:if>
	</xsl:template><xsl:template name="insertFigureBookmarks">
		<xsl:param name="contents"/>
		<xsl:if test="xalan:nodeset($contents)/figure">
			<fo:bookmark internal-destination="{xalan:nodeset($contents)/figure[1]/@id}" starting-state="hide">
				<fo:bookmark-title>Figures</fo:bookmark-title>
				<xsl:for-each select="xalan:nodeset($contents)/figure">
					<fo:bookmark internal-destination="{@id}">
						<fo:bookmark-title>
							<xsl:value-of select="normalize-space(title)"/>
						</fo:bookmark-title>
					</fo:bookmark>
				</xsl:for-each>
			</fo:bookmark>	
		</xsl:if>
	</xsl:template><xsl:template name="insertTableBookmarks">
		<xsl:param name="contents"/>
		<xsl:param name="lang"/>
		<xsl:if test="xalan:nodeset($contents)/table">
			<fo:bookmark internal-destination="{xalan:nodeset($contents)/table[1]/@id}" starting-state="hide">
				<fo:bookmark-title>
					<xsl:choose>
						<xsl:when test="$lang = 'fr'">Tableaux</xsl:when>
						<xsl:otherwise>Tables</xsl:otherwise>
					</xsl:choose>
				</fo:bookmark-title>
				<xsl:for-each select="xalan:nodeset($contents)/table">
					<fo:bookmark internal-destination="{@id}">
						<fo:bookmark-title>
							<xsl:value-of select="normalize-space(title)"/>
						</fo:bookmark-title>
					</fo:bookmark>
				</xsl:for-each>
			</fo:bookmark>	
		</xsl:if>
	</xsl:template><xsl:template name="getLangVersion">
		<xsl:param name="lang"/>
		<xsl:param name="doctype" select="''"/>
		<xsl:param name="title" select="''"/>
		<xsl:choose>
			<xsl:when test="$lang = 'en'">
				
				
				</xsl:when>
			<xsl:when test="$lang = 'fr'">
				
				
			</xsl:when>
			<xsl:when test="$lang = 'de'">Deutsche</xsl:when>
			<xsl:otherwise><xsl:value-of select="$lang"/> version</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="item" mode="bookmark">
		<fo:bookmark internal-destination="{@id}" starting-state="hide">
				<fo:bookmark-title>
					<xsl:if test="@section != ''">
						<xsl:value-of select="@section"/> 
						<xsl:text> </xsl:text>
					</xsl:if>
					<xsl:value-of select="normalize-space(title)"/>
				</fo:bookmark-title>
				<xsl:apply-templates mode="bookmark"/>				
		</fo:bookmark>
	</xsl:template><xsl:template match="title" mode="bookmark"/><xsl:template match="text()" mode="bookmark"/><xsl:template match="*[local-name() = 'figure']/*[local-name() = 'name'] |         *[local-name() = 'image']/*[local-name() = 'name']" mode="presentation">
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
		<!-- 
		<xsl:for-each select="*[local-name() = 'title']/*[local-name() = 'tab'][1]/preceding-sibling::node()">
			<xsl:value-of select="."/>
		</xsl:for-each>
		-->
		
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
	</xsl:template><xsl:template match="*[local-name() = 'fn']" mode="contents"/><xsl:template match="*[local-name() = 'fn']" mode="bookmarks"/><xsl:template match="*[local-name() = 'fn']" mode="contents_item"/><xsl:template match="*[local-name() = 'tab']" mode="contents_item">
		<xsl:text> </xsl:text>
	</xsl:template><xsl:template match="*[local-name() = 'strong']" mode="contents_item">
		<xsl:copy>
			<xsl:apply-templates mode="contents_item"/>
		</xsl:copy>		
	</xsl:template><xsl:template match="*[local-name() = 'em']" mode="contents_item">
		<xsl:copy>
			<xsl:apply-templates mode="contents_item"/>
		</xsl:copy>		
	</xsl:template><xsl:template match="*[local-name() = 'stem']" mode="contents_item">
		<xsl:copy-of select="."/>
	</xsl:template><xsl:template match="*[local-name() = 'br']" mode="contents_item">
		<xsl:text> </xsl:text>
	</xsl:template><xsl:template match="*[local-name()='sourcecode']" name="sourcecode">
	
		<fo:block-container margin-left="0mm">
			<xsl:if test="parent::*[local-name() = 'note']">
				<xsl:attribute name="margin-left">
					<xsl:choose>
						<xsl:when test="not(ancestor::*[local-name() = 'table'])"><xsl:value-of select="$note-body-indent"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="$note-body-indent-table"/></xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				
			</xsl:if>
			<fo:block-container margin-left="0mm">
	
				<fo:block xsl:use-attribute-sets="sourcecode-style">
					<xsl:variable name="_font-size">
						
												
						
						
						
						
						
						10
								
						
						
						
												
						
								
				</xsl:variable>
				<xsl:variable name="font-size" select="normalize-space($_font-size)"/>		
				<xsl:if test="$font-size != ''">
					<xsl:attribute name="font-size">
						<xsl:choose>
							<xsl:when test="ancestor::*[local-name()='note']"><xsl:value-of select="$font-size * 0.91"/>pt</xsl:when>
							<xsl:otherwise><xsl:value-of select="$font-size"/>pt</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</xsl:if>
					<xsl:apply-templates/>			
				</fo:block>
				<xsl:apply-templates select="*[local-name()='name']" mode="presentation"/>
				
			</fo:block-container>
		</fo:block-container>
	</xsl:template><xsl:template match="*[local-name()='sourcecode']/text()" priority="2">
		<xsl:variable name="text">
			<xsl:call-template name="add-zero-spaces-equal"/>
		</xsl:variable>
		<xsl:call-template name="add-zero-spaces-java">
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
			<xsl:if test="ancestor::*[local-name() = 'table'][@class = 'recommendation' or @class='requirement' or @class='permission']">
				<xsl:attribute name="margin-bottom">0pt</xsl:attribute>
			</xsl:if>
			<fo:block-container margin-left="0mm" margin-right="0mm">
				<fo:table id="{@id}" table-layout="fixed" width="100%"> <!-- border="1pt solid black" -->
					<xsl:if test="ancestor::*[local-name() = 'table'][@class = 'recommendation' or @class='requirement' or @class='permission']">
						<!-- <xsl:attribute name="border">0.5pt solid black</xsl:attribute> -->
					</xsl:if>
					<xsl:variable name="simple-table">	
						<xsl:call-template name="getSimpleTable"/>			
					</xsl:variable>					
					<xsl:variable name="cols-count" select="count(xalan:nodeset($simple-table)//tr[1]/td)"/>
					<xsl:if test="$cols-count = 2 and not(ancestor::*[local-name()='table'])">
						<!-- <fo:table-column column-width="35mm"/>
						<fo:table-column column-width="115mm"/> -->
						<fo:table-column column-width="30%"/>
						<fo:table-column column-width="70%"/>
					</xsl:if>
					<xsl:apply-templates mode="requirement"/>
				</fo:table>
				<!-- fn processing -->
				<xsl:if test=".//*[local-name() = 'fn']">
					<xsl:for-each select="*[local-name() = 'tbody']">
						<fo:block font-size="90%" border-bottom="1pt solid black">
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
		<fo:table-row height="7mm" border-bottom="0.5pt solid grey">			
			<xsl:if test="parent::*[local-name()='thead']"> <!-- and not(ancestor::*[local-name() = 'table'][@class = 'recommendation' or @class='requirement' or @class='permission']) -->
				<!-- <xsl:attribute name="border">1pt solid black</xsl:attribute> -->
				<xsl:attribute name="background-color">rgb(33, 55, 92)</xsl:attribute>
			</xsl:if>
			<xsl:if test="starts-with(*[local-name()='td'][1], 'Requirement ')">
				<xsl:attribute name="background-color">rgb(252, 246, 222)</xsl:attribute>
			</xsl:if>
			<xsl:if test="starts-with(*[local-name()='td'][1], 'Recommendation ')">
				<xsl:attribute name="background-color">rgb(233, 235, 239)</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates mode="requirement"/>
		</fo:table-row>
	</xsl:template><xsl:template match="*[local-name()='th']" mode="requirement">
		<fo:table-cell text-align="{@align}" display-align="center" padding="1mm" padding-left="2mm"> <!-- border="0.5pt solid black" -->
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
			<xsl:call-template name="display-align"/>
			
			<!-- <xsl:if test="ancestor::*[local-name()='table']/@type = 'recommend'">
				<xsl:attribute name="padding-top">0.5mm</xsl:attribute>
				<xsl:attribute name="background-color">rgb(165, 165, 165)</xsl:attribute>				
			</xsl:if>
			<xsl:if test="ancestor::*[local-name()='table']/@type = 'recommendtest'">
				<xsl:attribute name="padding-top">0.5mm</xsl:attribute>
				<xsl:attribute name="background-color">rgb(201, 201, 201)</xsl:attribute>				
			</xsl:if> -->
			
			<fo:block>
				<xsl:apply-templates/>
			</fo:block>
		</fo:table-cell>
	</xsl:template><xsl:template match="*[local-name()='td']" mode="requirement">
		<fo:table-cell text-align="{@align}" display-align="center" padding="1mm" padding-left="2mm"> <!-- border="0.5pt solid black" -->
			<xsl:if test="*[local-name() = 'table'][@class = 'recommendation' or @class='requirement' or @class='permission']">
				<xsl:attribute name="padding">0mm</xsl:attribute>
				<xsl:attribute name="padding-left">0mm</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="text-align">
				<xsl:choose>
					<xsl:when test="@align">
						<xsl:value-of select="@align"/>
					</xsl:when>
					<xsl:otherwise>left</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:if test="following-sibling::*[local-name()='td'] and not(preceding-sibling::*[local-name()='td'])">
				<xsl:attribute name="font-weight">bold</xsl:attribute>
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
			<xsl:call-template name="display-align"/>
			
			<!-- <xsl:if test="ancestor::*[local-name()='table']/@type = 'recommend'">
				<xsl:attribute name="padding-left">0.5mm</xsl:attribute>
				<xsl:attribute name="padding-top">0.5mm</xsl:attribute>				 
				<xsl:if test="parent::*[local-name()='tr']/preceding-sibling::*[local-name()='tr'] and not(*[local-name()='table'])">
					<xsl:attribute name="background-color">rgb(201, 201, 201)</xsl:attribute>					
				</xsl:if>
			</xsl:if> -->
			<!-- 2nd line and below -->
			
			<fo:block>			
				<xsl:apply-templates/>
			</fo:block>			
		</fo:table-cell>
	</xsl:template><xsl:template match="*[local-name() = 'p'][@class='RecommendationTitle' or @class = 'RecommendationTestTitle']" priority="2">
		<fo:block font-size="11pt" color="rgb(237, 193, 35)"> <!-- font-weight="bold" margin-bottom="4pt" text-align="center"  -->
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'p2'][ancestor::*[local-name() = 'table'][@class = 'recommendation' or @class='requirement' or @class='permission']]">
		<fo:block> <!-- margin-bottom="10pt" -->
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
				
				<xsl:if test=".//*[local-name() = 'table']">block</xsl:if> 
			</xsl:variable>
			
			<xsl:choose>
				<xsl:when test="contains(normalize-space($element), 'block')">
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
		<xsl:variable name="num"><xsl:number/></xsl:variable>
		<xsl:variable name="element">
			block
			
			
		</xsl:variable>		
		<xsl:choose>			
			<xsl:when test="normalize-space($element) = 'block'">
				<fo:block xsl:use-attribute-sets="example-p-style">
					
					<xsl:apply-templates/>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline xsl:use-attribute-sets="example-p-style">
					<xsl:apply-templates/>					
				</fo:inline>
			</xsl:otherwise>
		</xsl:choose>	
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
		<fo:block-container margin-left="0mm">
			<xsl:if test="parent::*[local-name() = 'note']">
				<xsl:if test="not(ancestor::*[local-name() = 'table'])">
					<xsl:attribute name="margin-left">5mm</xsl:attribute>
				</xsl:if>
			</xsl:if>
			
			
			<fo:block-container margin-left="0mm">
		
				<fo:block xsl:use-attribute-sets="quote-style">
					<!-- <xsl:apply-templates select=".//*[local-name() = 'p']"/> -->
					
					<xsl:apply-templates select="./node()[not(local-name() = 'author') and not(local-name() = 'source')]"/> <!-- process all nested nodes, except author and source -->
				</fo:block>
				<xsl:if test="*[local-name() = 'author'] or *[local-name() = 'source']">
					<fo:block xsl:use-attribute-sets="quote-source-style">
						<!-- — ISO, ISO 7301:2011, Clause 1 -->
						<xsl:apply-templates select="*[local-name() = 'author']"/>
						<xsl:apply-templates select="*[local-name() = 'source']"/>				
					</fo:block>
				</xsl:if>
				
			</fo:block-container>
		</fo:block-container>
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
	
		<xsl:variable name="bibitemid">
			<xsl:choose>
				<xsl:when test="//*[local-name() = 'bibitem'][@hidden='true' and @id = current()/@bibitemid]"/>
				<xsl:when test="//*[local-name() = 'references'][@hidden='true']/*[local-name() = 'bibitem'][@id = current()/@bibitemid]"/>
				<xsl:otherwise><xsl:value-of select="@bibitemid"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
	
		<xsl:choose>
			<xsl:when test="normalize-space($bibitemid) != ''">
				<fo:inline xsl:use-attribute-sets="eref-style">
					<xsl:if test="@type = 'footnote'">
						
							<xsl:attribute name="keep-together.within-line">always</xsl:attribute>
							<xsl:attribute name="font-size">80%</xsl:attribute>
							<xsl:attribute name="keep-with-previous.within-line">always</xsl:attribute>
							<xsl:attribute name="vertical-align">super</xsl:attribute>
											
						
					</xsl:if>	
											
					<fo:basic-link internal-destination="{@bibitemid}" fox:alt-text="{@citeas}">
						<xsl:if test="normalize-space(@citeas) = ''">
							<xsl:attribute name="fox:alt-text"><xsl:value-of select="."/></xsl:attribute>
						</xsl:if>
						<xsl:if test="@type = 'inline'">
							
							
							
						</xsl:if>

						<xsl:apply-templates/>
					</fo:basic-link>
							
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline><xsl:apply-templates/></fo:inline>
			</xsl:otherwise>
		</xsl:choose>
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
			
			
			
			
			
				<xsl:if test="*[1][@class='supertitle']">
					<xsl:attribute name="space-before">36pt</xsl:attribute>
				</xsl:if>
				<xsl:if test="@inline-header='true'">
					<xsl:attribute name="text-align">justify</xsl:attribute>
				</xsl:if>
			
						
			
						
			
			
			
			<xsl:apply-templates/>
		</fo:block>
		
		
		
	</xsl:template><xsl:template match="//*[contains(local-name(), '-standard')]/*[local-name() = 'preface']/*" priority="2"> <!-- /*/*[local-name() = 'preface']/* -->
		<fo:block break-after="page"/>
		<fo:block>
			<xsl:call-template name="setId"/>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'clause']">
		<fo:block>
			<xsl:call-template name="setId"/>
			
			
				<xsl:if test="@inline-header='true'">
					<xsl:attribute name="text-align">justify</xsl:attribute>
				</xsl:if>
			
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'definitions']">
		<fo:block id="{@id}">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'references'][@hidden='true']" priority="3"/><xsl:template match="*[local-name() = 'bibitem'][@hidden='true']" priority="3"/><xsl:template match="/*/*[local-name() = 'bibliography']/*[local-name() = 'references'][@normative='true']">
		
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
	</xsl:template><xsl:template match="*[local-name() = 'ul'] | *[local-name() = 'ol']">
		<xsl:choose>
			<xsl:when test="parent::*[local-name() = 'note']">
				<fo:block-container>
					<xsl:attribute name="margin-left">
						<xsl:choose>
							<xsl:when test="not(ancestor::*[local-name() = 'table'])"><xsl:value-of select="$note-body-indent"/></xsl:when>
							<xsl:otherwise><xsl:value-of select="$note-body-indent-table"/></xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					
					
					<fo:block-container margin-left="0mm">
						<fo:block>
							<xsl:apply-templates select="." mode="ul_ol"/>
						</fo:block>
					</fo:block-container>
				</fo:block-container>
			</xsl:when>
			<xsl:otherwise>
				<fo:block>
					<xsl:apply-templates select="." mode="ul_ol"/>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:variable name="index" select="document($external_index)"/><xsl:variable name="dash" select="'–'"/><xsl:variable name="bookmark_in_fn">
		<xsl:for-each select="//*[local-name() = 'bookmark'][ancestor::*[local-name() = 'fn']]">
			<bookmark><xsl:value-of select="@id"/></bookmark>
		</xsl:for-each>
	</xsl:variable><xsl:template match="@*|node()" mode="index_add_id">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="index_add_id"/>
		</xsl:copy>
	</xsl:template><xsl:template match="*[local-name() = 'xref']" mode="index_add_id">
		<xsl:variable name="id">
			<xsl:call-template name="generateIndexXrefId"/>
		</xsl:variable>
		<xsl:copy> <!-- add id to xref -->
			<xsl:apply-templates select="@*" mode="index_add_id"/>
			<xsl:attribute name="id">
				<xsl:value-of select="$id"/>
			</xsl:attribute>
			<xsl:apply-templates mode="index_add_id"/>
		</xsl:copy>
		<!-- split <xref target="bm1" to="End" pagenumber="true"> to two xref:
		<xref target="bm1" pagenumber="true"> and <xref target="End" pagenumber="true"> -->
		<xsl:if test="@to">
			<xsl:value-of select="$dash"/>
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:attribute name="target"><xsl:value-of select="@to"/></xsl:attribute>
				<xsl:attribute name="id">
					<xsl:value-of select="$id"/><xsl:text>_to</xsl:text>
				</xsl:attribute>
				<xsl:apply-templates mode="index_add_id"/>
			</xsl:copy>
		</xsl:if>
	</xsl:template><xsl:template match="@*|node()" mode="index_update">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="index_update"/>
		</xsl:copy>
	</xsl:template><xsl:template match="*[local-name() = 'indexsect']//*[local-name() = 'li']" mode="index_update">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="index_update"/>
		<xsl:apply-templates select="node()[1]" mode="process_li_element"/>
		</xsl:copy>
	</xsl:template><xsl:template match="*[local-name() = 'indexsect']//*[local-name() = 'li']/node()" mode="process_li_element" priority="2">
		<xsl:param name="element"/>
		<xsl:param name="remove" select="'false'"/>
		<xsl:param name="target"/>
		<!-- <node></node> -->
		<xsl:choose>
			<xsl:when test="self::text()  and (normalize-space(.) = ',' or normalize-space(.) = $dash) and $remove = 'true'">
				<!-- skip text (i.e. remove it) and process next element -->
				<!-- [removed_<xsl:value-of select="."/>] -->
				<xsl:apply-templates select="following-sibling::node()[1]" mode="process_li_element">
					<xsl:with-param name="target"><xsl:value-of select="$target"/></xsl:with-param>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="self::text()">
				<xsl:value-of select="."/>
				<xsl:apply-templates select="following-sibling::node()[1]" mode="process_li_element"/>
			</xsl:when>
			<xsl:when test="self::* and local-name(.) = 'xref'">
				<xsl:variable name="id" select="@id"/>
				<xsl:variable name="page" select="$index//item[@id = $id]"/>
				<xsl:variable name="id_next" select="following-sibling::*[local-name() = 'xref'][1]/@id"/>
				<xsl:variable name="page_next" select="$index//item[@id = $id_next]"/>
				
				<xsl:variable name="id_prev" select="preceding-sibling::*[local-name() = 'xref'][1]/@id"/>
				<xsl:variable name="page_prev" select="$index//item[@id = $id_prev]"/>
				
				<xsl:choose>
					<!-- 2nd pass -->
					<!-- if page is equal to page for next and page is not the end of range -->
					<xsl:when test="$page != '' and $page_next != '' and $page = $page_next and not(contains($page, '_to'))">  <!-- case: 12, 12-14 -->
						<!-- skip element (i.e. remove it) and remove next text ',' -->
						<!-- [removed_xref] -->
						
						<xsl:apply-templates select="following-sibling::node()[1]" mode="process_li_element">
							<xsl:with-param name="remove">true</xsl:with-param>
							<xsl:with-param name="target">
								<xsl:choose>
									<xsl:when test="$target != ''"><xsl:value-of select="$target"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="@target"/></xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:apply-templates>
					</xsl:when>
					
					<xsl:when test="$page != '' and $page_prev != '' and $page = $page_prev and contains($page_prev, '_to')"> <!-- case: 12-14, 14, ... -->
						<!-- remove xref -->
						<xsl:apply-templates select="following-sibling::node()[1]" mode="process_li_element">
							<xsl:with-param name="remove">true</xsl:with-param>
						</xsl:apply-templates>
					</xsl:when>

					<xsl:otherwise>
						<xsl:apply-templates select="." mode="xref_copy">
							<xsl:with-param name="target" select="$target"/>
						</xsl:apply-templates>
						<xsl:apply-templates select="following-sibling::node()[1]" mode="process_li_element"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="self::* and local-name(.) = 'ul'">
				<!-- ul -->
				<xsl:apply-templates select="." mode="index_update"/>
			</xsl:when>
			<xsl:otherwise>
			 <xsl:apply-templates select="." mode="xref_copy">
					<xsl:with-param name="target" select="$target"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="following-sibling::node()[1]" mode="process_li_element"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="@*|node()" mode="xref_copy">
		<xsl:param name="target"/>
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="xref_copy"/>
			<xsl:if test="$target != '' and not(xalan:nodeset($bookmark_in_fn)//bookmark[. = $target])">
				<xsl:attribute name="target"><xsl:value-of select="$target"/></xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="node()" mode="xref_copy"/>
		</xsl:copy>
	</xsl:template><xsl:template name="generateIndexXrefId">
		<xsl:variable name="level" select="count(ancestor::*[local-name() = 'ul'])"/>
		
		<xsl:variable name="docid">
			<xsl:call-template name="getDocumentId"/>
		</xsl:variable>
		<xsl:variable name="item_number">
			<xsl:number count="*[local-name() = 'li'][ancestor::*[local-name() = 'indexsect']]" level="any"/>
		</xsl:variable>
		<xsl:variable name="xref_number"><xsl:number count="*[local-name() = 'xref']"/></xsl:variable>
		<xsl:value-of select="concat($docid, '_', $item_number, '_', $xref_number)"/> <!-- $level, '_',  -->
	</xsl:template><xsl:template match="*[local-name() = 'indexsect']/*[local-name() = 'clause']" priority="4">
		<xsl:apply-templates/>
		<fo:block>
		<xsl:if test="following-sibling::*[local-name() = 'clause']">
			<fo:block> </fo:block>
		</xsl:if>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'indexsect']//*[local-name() = 'ul']" priority="4">
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name() = 'indexsect']//*[local-name() = 'li']" priority="4">
		<xsl:variable name="level" select="count(ancestor::*[local-name() = 'ul'])"/>
		<fo:block start-indent="{5 * $level}mm" text-indent="-5mm">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'bookmark']" name="bookmark">
		<fo:inline id="{@id}" font-size="1pt"/>
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
				<fo:table-row text-align="center" font-weight="bold" background-color="black" color="white">
					
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
	</xsl:template><xsl:template name="processBibitem">
		
		
		<!-- end BIPM bibitem processing-->
		
		 
		
		
		 
	</xsl:template><xsl:template name="processBibitemDocId">
		<xsl:variable name="_doc_ident" select="*[local-name() = 'docidentifier'][not(@type = 'DOI' or @type = 'metanorma' or @type = 'ISSN' or @type = 'ISBN' or @type = 'rfc-anchor')]"/>
		<xsl:choose>
			<xsl:when test="normalize-space($_doc_ident) != ''">
				<xsl:variable name="type" select="*[local-name() = 'docidentifier'][not(@type = 'DOI' or @type = 'metanorma' or @type = 'ISSN' or @type = 'ISBN' or @type = 'rfc-anchor')]/@type"/>
				<xsl:if test="$type != '' and not(contains($_doc_ident, $type))">
					<xsl:value-of select="$type"/><xsl:text> </xsl:text>
				</xsl:if>
				<xsl:value-of select="$_doc_ident"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="type" select="*[local-name() = 'docidentifier'][not(@type = 'metanorma')]/@type"/>
				<xsl:if test="$type != ''">
					<xsl:value-of select="$type"/><xsl:text> </xsl:text>
				</xsl:if>
				<xsl:value-of select="*[local-name() = 'docidentifier'][not(@type = 'metanorma')]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="processPersonalAuthor">
		<xsl:choose>
			<xsl:when test="*[local-name() = 'name']/*[local-name() = 'completename']">
				<author>
					<xsl:apply-templates select="*[local-name() = 'name']/*[local-name() = 'completename']"/>
				</author>
			</xsl:when>
			<xsl:when test="*[local-name() = 'name']/*[local-name() = 'surname'] and *[local-name() = 'name']/*[local-name() = 'initial']">
				<author>
					<xsl:apply-templates select="*[local-name() = 'name']/*[local-name() = 'surname']"/>
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="*[local-name() = 'name']/*[local-name() = 'initial']" mode="strip"/>
				</author>
			</xsl:when>
			<xsl:when test="*[local-name() = 'name']/*[local-name() = 'surname'] and *[local-name() = 'name']/*[local-name() = 'forename']">
				<author>
					<xsl:apply-templates select="*[local-name() = 'name']/*[local-name() = 'surname']"/>
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="*[local-name() = 'name']/*[local-name() = 'forename']" mode="strip"/>
				</author>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="renderDate">		
			<xsl:if test="normalize-space(*[local-name() = 'on']) != ''">
				<xsl:value-of select="*[local-name() = 'on']"/>
			</xsl:if>
			<xsl:if test="normalize-space(*[local-name() = 'from']) != ''">
				<xsl:value-of select="concat(*[local-name() = 'from'], '–', *[local-name() = 'to'])"/>
			</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'name']/*[local-name() = 'initial']/text()" mode="strip">
		<xsl:value-of select="translate(.,'. ','')"/>
	</xsl:template><xsl:template match="*[local-name() = 'name']/*[local-name() = 'forename']/text()" mode="strip">
		<xsl:value-of select="substring(.,1,1)"/>
	</xsl:template><xsl:template match="*[local-name() = 'title']" mode="title">
		<fo:inline><xsl:apply-templates/></fo:inline>
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
				<xsl:when test="$format = 'ddMMyyyy'">
					<xsl:if test="$day != ''"><xsl:value-of select="number($day)"/></xsl:if>
					<xsl:text> </xsl:text>
					<xsl:value-of select="normalize-space(concat($monthStr, ' ' , $year))"/>
				</xsl:when>
				<xsl:when test="$format = 'ddMM'">
					<xsl:if test="$day != ''"><xsl:value-of select="number($day)"/></xsl:if>
					<xsl:text> </xsl:text><xsl:value-of select="$monthStr"/>
				</xsl:when>
				<xsl:when test="$format = 'short' or $day = ''">
					<xsl:value-of select="normalize-space(concat($monthStr, ' ', $year))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(concat($monthStr, ' ', $day, ', ' , $year))"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$result"/>
	</xsl:template><xsl:template name="convertDateLocalized">
		<xsl:param name="date"/>
		<xsl:param name="format" select="'short'"/>
		<xsl:variable name="year" select="substring($date, 1, 4)"/>
		<xsl:variable name="month" select="substring($date, 6, 2)"/>
		<xsl:variable name="day" select="substring($date, 9, 2)"/>
		<xsl:variable name="monthStr">
			<xsl:choose>
				<xsl:when test="$month = '01'"><xsl:call-template name="getLocalizedString"><xsl:with-param name="key">month_january</xsl:with-param></xsl:call-template></xsl:when>
				<xsl:when test="$month = '02'"><xsl:call-template name="getLocalizedString"><xsl:with-param name="key">month_february</xsl:with-param></xsl:call-template></xsl:when>
				<xsl:when test="$month = '03'"><xsl:call-template name="getLocalizedString"><xsl:with-param name="key">month_march</xsl:with-param></xsl:call-template></xsl:when>
				<xsl:when test="$month = '04'"><xsl:call-template name="getLocalizedString"><xsl:with-param name="key">month_april</xsl:with-param></xsl:call-template></xsl:when>
				<xsl:when test="$month = '05'"><xsl:call-template name="getLocalizedString"><xsl:with-param name="key">month_may</xsl:with-param></xsl:call-template></xsl:when>
				<xsl:when test="$month = '06'"><xsl:call-template name="getLocalizedString"><xsl:with-param name="key">month_june</xsl:with-param></xsl:call-template></xsl:when>
				<xsl:when test="$month = '07'"><xsl:call-template name="getLocalizedString"><xsl:with-param name="key">month_july</xsl:with-param></xsl:call-template></xsl:when>
				<xsl:when test="$month = '08'"><xsl:call-template name="getLocalizedString"><xsl:with-param name="key">month_august</xsl:with-param></xsl:call-template></xsl:when>
				<xsl:when test="$month = '09'"><xsl:call-template name="getLocalizedString"><xsl:with-param name="key">month_september</xsl:with-param></xsl:call-template></xsl:when>
				<xsl:when test="$month = '10'"><xsl:call-template name="getLocalizedString"><xsl:with-param name="key">month_october</xsl:with-param></xsl:call-template></xsl:when>
				<xsl:when test="$month = '11'"><xsl:call-template name="getLocalizedString"><xsl:with-param name="key">month_november</xsl:with-param></xsl:call-template></xsl:when>
				<xsl:when test="$month = '12'"><xsl:call-template name="getLocalizedString"><xsl:with-param name="key">month_december</xsl:with-param></xsl:call-template></xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="result">
			<xsl:choose>
				<xsl:when test="$format = 'ddMMyyyy'">
					<xsl:if test="$day != ''"><xsl:value-of select="number($day)"/></xsl:if>
					<xsl:text> </xsl:text>
					<xsl:value-of select="normalize-space(concat($monthStr, ' ' , $year))"/>
				</xsl:when>
				<xsl:when test="$format = 'ddMM'">
					<xsl:if test="$day != ''"><xsl:value-of select="number($day)"/></xsl:if>
					<xsl:text> </xsl:text><xsl:value-of select="$monthStr"/>
				</xsl:when>
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
				<xsl:for-each select="//*[contains(local-name(), '-standard')]/*[local-name() = 'bibdata']//*[local-name() = 'keyword']">
					<xsl:sort data-type="text" order="ascending"/>
					<xsl:call-template name="insertKeyword">
						<xsl:with-param name="charAtEnd" select="$charAtEnd"/>
						<xsl:with-param name="charDelim" select="$charDelim"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="//*[contains(local-name(), '-standard')]/*[local-name() = 'bibdata']//*[local-name() = 'keyword']">
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
		<xsl:variable name="lang">
			<xsl:call-template name="getLang"/>
		</xsl:variable>
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
							<xsl:for-each select="(//*[contains(local-name(), '-standard')])[1]/*[local-name() = 'bibdata']">
								
								
								
								
								
								
									<xsl:value-of select="*[local-name() = 'title'][@type='main']"/>
																
							</xsl:for-each>
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
						<xsl:for-each select="(//*[contains(local-name(), '-standard')])[1]/*[local-name() = 'bibdata']">
							
								<xsl:for-each select="*[local-name() = 'contributor'][*[local-name() = 'role']/@type='author']">
									<xsl:value-of select="*[local-name() = 'organization']/*[local-name() = 'name']"/>
									<xsl:if test="position() != last()">; </xsl:if>
								</xsl:for-each>
							
							
							
						</xsl:for-each>
					</dc:creator>
					<dc:description>
						<xsl:variable name="abstract">
							
								<xsl:copy-of select="//*[contains(local-name(), '-standard')]/*[local-name() = 'preface']/*[local-name() = 'abstract']//text()"/>									
							
							
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
		<xsl:param name="normalize-space" select="'true'"/>
		<xsl:if test="string-length($pText) &gt;0">
		<item>
			<xsl:choose>
				<xsl:when test="$normalize-space = 'true'">
					<xsl:value-of select="normalize-space(substring-before(concat($pText, $sep), $sep))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-before(concat($pText, $sep), $sep)"/>
				</xsl:otherwise>
			</xsl:choose>
		</item>
		<xsl:call-template name="split">
			<xsl:with-param name="pText" select="substring-after($pText, $sep)"/>
			<xsl:with-param name="sep" select="$sep"/>
			<xsl:with-param name="normalize-space" select="$normalize-space"/>
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
	</xsl:template><xsl:template name="add-letter-spacing">
		<xsl:param name="text"/>
		<xsl:param name="letter-spacing" select="'0.15'"/>
		<xsl:if test="string-length($text) &gt; 0">
			<xsl:variable name="char" select="substring($text, 1, 1)"/>
			<fo:inline padding-right="{$letter-spacing}mm">
				<xsl:if test="$char = '®'">
					<xsl:attribute name="font-size">58%</xsl:attribute>
					<xsl:attribute name="baseline-shift">30%</xsl:attribute>
				</xsl:if>				
				<xsl:value-of select="$char"/>
			</fo:inline>
			<xsl:call-template name="add-letter-spacing">
				<xsl:with-param name="text" select="substring($text, 2)"/>
				<xsl:with-param name="letter-spacing" select="$letter-spacing"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template><xsl:template name="repeat">
		<xsl:param name="char" select="'*'"/>
		<xsl:param name="count"/>
		<xsl:if test="$count &gt; 0">
			<xsl:value-of select="$char"/>
			<xsl:call-template name="repeat">
				<xsl:with-param name="char" select="$char"/>
				<xsl:with-param name="count" select="$count - 1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template><xsl:template name="getLocalizedString">
		<xsl:param name="key"/>		
		
		<xsl:variable name="curr_lang">
			<xsl:call-template name="getLang"/>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="/*/*[local-name() = 'localized-strings']/*[local-name() = 'localized-string'][@key = $key and @language = $curr_lang]">
				<xsl:value-of select="/*/*[local-name() = 'localized-strings']/*[local-name() = 'localized-string'][@key = $key and @language = $curr_lang]"/>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="$key"/></xsl:otherwise>
		</xsl:choose>
		
	</xsl:template></xsl:stylesheet>
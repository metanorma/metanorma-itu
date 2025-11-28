require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Itu do
  it "cleans up footnotes" do
    FileUtils.rm_f "test.html"
    input = <<~INPUT
      <itu-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <title language="en" format="text/plain" type="main">An ITU Standard</title>
          <ext><doctype>recommendation</doctype></ext>
          </bibdata>
          <preface>
          <foreword displayorder="1">
      <note type="title-footnote" id="A1"><p>One fn</p></note>
      <note type="title-footnote" id="A2"><p>Another fn</p></note>
          <p>A.<fn reference="2">
        <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
      </fn></p>
          <p>B.<fn reference="2">
        <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
      </fn></p>
          <p>C.<fn reference="1">
        <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Hello! denoted as 15 % (m/m).</p>
      </fn></p>
      <table id="tableD-1" alt="tool tip" summary="long desc">
        <name>Table 1&#xA0;&#x2014; Repeatability and reproducibility of <em>husked</em> rice yield</name>
        <thead>
          <tr>
            <td rowspan="2" align="left">Description</td>
            <td colspan="4" align="center">Rice sample</td>
          </tr>
          </thead>
          <tbody>
          <tr>
            <td align="left">Arborio</td>
            <td align="center">Drago<fn reference="a">
        <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p>
      </fn></td>
            <td align="center">Balilla<fn reference="a">
        <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p>
      </fn></td>
            <td align="center">Thaibonnet</td>
          </tr>
          </tbody>
      </table>
          </foreword>
          </preface>
          <sections>
          <clause/>
          </sections>
          </itu-standard>
    INPUT
    presxml = <<~PRESXML
      <itu-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata>
             <title language="en" format="text/plain" type="main">An ITU Standard</title>
             <ext>
                <doctype language="">recommendation</doctype>
                <doctype language="en">Recommendation</doctype>
             </ext>
          </bibdata>
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Table of Contents</fmt-title>
             </clause>
             <foreword displayorder="2" id="_">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <p>
                   A.
                   <fn reference="1" id="_" original-reference="2" target="_">
                      <p original-id="_">Formerly denoted as 15 % (m/m).</p>
                      <fmt-fn-label>
                         <span class="fmt-caption-label">
                            <sup>
                               <semx element="autonum" source="_">1</semx>
                            </sup>
                         </span>
                      </fmt-fn-label>
                   </fn>
                </p>
                <p>
                   B.
                   <fn reference="1" id="_" original-reference="2" target="_">
                      <p id="_">Formerly denoted as 15 % (m/m).</p>
                      <fmt-fn-label>
                         <span class="fmt-caption-label">
                            <sup>
                               <semx element="autonum" source="_">1</semx>
                            </sup>
                         </span>
                      </fmt-fn-label>
                   </fn>
                </p>
                <p>
                   C.
                   <fn reference="2" id="_" original-reference="1" target="_">
                      <p original-id="_">Hello! denoted as 15 % (m/m).</p>
                      <fmt-fn-label>
                         <span class="fmt-caption-label">
                            <sup>
                               <semx element="autonum" source="_">2</semx>
                            </sup>
                         </span>
                      </fmt-fn-label>
                   </fn>
                </p>
                <table id="tableD-1" alt="tool tip" summary="long desc" autonum="1">
                   <name id="_">
                      Table 1 — Repeatability and reproducibility of
                      <em>husked</em>
                      rice yield
                   </name>
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Table</span>
                         <semx element="autonum" source="tableD-1">1</semx>
                      </span>
                      <span class="fmt-caption-delim"> — </span>
                      <semx element="name" source="_">
                         Table 1 — Repeatability and reproducibility of
                         <em>husked</em>
                         rice yield
                      </semx>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="tableD-1">1</semx>
                   </fmt-xref-label>
                   <thead>
                      <tr>
                         <td rowspan="2" align="left">Description</td>
                         <td colspan="4" align="center">Rice sample</td>
                      </tr>
                   </thead>
                   <tbody>
                      <tr>
                         <td align="left">Arborio</td>
                         <td align="center">
                            Drago
                            <fn reference="a" id="_" target="_">
                               <p original-id="_">Parboiled rice.</p>
                               <fmt-fn-label>
                                  <span class="fmt-caption-label">
                                     <sup>
                                        <semx element="autonum" source="_">a</semx>
                                        <span class="fmt-label-delim">)</span>
                                     </sup>
                                  </span>
                               </fmt-fn-label>
                            </fn>
                         </td>
                         <td align="center">
                            Balilla
                            <fn reference="a" id="_" target="_">
                               <p id="_">Parboiled rice.</p>
                               <fmt-fn-label>
                                  <span class="fmt-caption-label">
                                     <sup>
                                        <semx element="autonum" source="_">a</semx>
                                        <span class="fmt-label-delim">)</span>
                                     </sup>
                                  </span>
                               </fmt-fn-label>
                            </fn>
                         </td>
                         <td align="center">Thaibonnet</td>
                      </tr>
                   </tbody>
                   <fmt-footnote-container>
                      <fmt-fn-body id="_" target="_" reference="a">
                         <semx element="fn" source="_">
                            <p id="_">
                               <fmt-fn-label>
                                  <span class="fmt-caption-label">
                                     <sup>
                                        <semx element="autonum" source="_">a</semx>
                                        <span class="fmt-label-delim">)</span>
                                     </sup>
                                  </span>
                                  <span class="fmt-caption-delim">
                                     <tab/>
                                  </span>
                               </fmt-fn-label>
                               Parboiled rice.
                            </p>
                         </semx>
                      </fmt-fn-body>
                   </fmt-footnote-container>
                </table>
             </foreword>
          </preface>
          <sections>
             <p class="zzSTDTitle2" displayorder="3">
                An ITU Standard
                <fn id="_" reference="3" original-reference="H0" target="_">
                   <p>One fn</p>
                   <fmt-fn-label>
                      <span class="fmt-caption-label">
                         <sup>
                            <semx element="autonum" source="_">3</semx>
                         </sup>
                      </span>
                   </fmt-fn-label>
                </fn>
                <fn id="_" reference="4" original-reference="H1" target="_">
                   <p>Another fn</p>
                   <fmt-fn-label>
                      <span class="fmt-caption-label">
                         <sup>
                            <semx element="autonum" source="_">4</semx>
                         </sup>
                      </span>
                   </fmt-fn-label>
                </fn>
             </p>
      <clause id="_" displayorder="4">
         <fmt-title depth="1" id="_">
            <span class="fmt-caption-label">
               <semx element="autonum" source="_">1</semx>
               <span class="fmt-autonum-delim">.</span>
            </span>
         </fmt-title>
         <fmt-xref-label>
            <span class="fmt-element-name">clause</span>
            <semx element="autonum" source="_">1</semx>
         </fmt-xref-label>
      </clause>
          </sections>
          <fmt-footnote-container>
             <fmt-fn-body id="_" target="_" reference="1">
                <semx element="fn" source="_">
                   <p id="_">
                      <fmt-fn-label>
                         <span class="fmt-caption-label">
                            <sup>
                               <semx element="autonum" source="_">1</semx>
                            </sup>
                         </span>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                      </fmt-fn-label>
                      Formerly denoted as 15 % (m/m).
                   </p>
                </semx>
             </fmt-fn-body>
             <fmt-fn-body id="_" target="_" reference="2">
                <semx element="fn" source="_">
                   <p id="_">
                      <fmt-fn-label>
                         <span class="fmt-caption-label">
                            <sup>
                               <semx element="autonum" source="_">2</semx>
                            </sup>
                         </span>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                      </fmt-fn-label>
                      Hello! denoted as 15 % (m/m).
                   </p>
                </semx>
             </fmt-fn-body>
             <fmt-fn-body id="_" target="_" reference="3">
                <semx element="fn" source="_">
                   <p>
                      <fmt-fn-label>
                         <span class="fmt-caption-label">
                            <sup>
                               <semx element="autonum" source="_">3</semx>
                            </sup>
                         </span>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                      </fmt-fn-label>
                      One fn
                   </p>
                </semx>
             </fmt-fn-body>
             <fmt-fn-body id="_" target="_" reference="4">
                <semx element="fn" source="_">
                   <p>
                      <fmt-fn-label>
                         <span class="fmt-caption-label">
                            <sup>
                               <semx element="autonum" source="_">4</semx>
                            </sup>
                         </span>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                      </fmt-fn-label>
                      Another fn
                   </p>
                </semx>
             </fmt-fn-body>
          </fmt-footnote-container>
       </itu-standard>
    PRESXML
    pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Canon.format_xml(strip_guid(pres_output
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Canon.format_xml(presxml)
    IsoDoc::Itu::HtmlConvert.new({}).convert("test", pres_output, false)
    expect(File.exist?("test.html")).to be true
    html = File.read("test.html", encoding: "UTF-8")
    output = <<~OUTPUT
      <main xmlns:epub="epub" class="main-section">
          <button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
          <br/>
          <div id="_">
             <h1 class="IntroTitle" id="_">
                <a class="anchor" href="#_"/>
                <a class="header" href="#_">Foreword</a>
             </h1>
             <p>
                A.
                <a class="FootnoteRef" href="#fn:_" id="fnref:1">
                   <sup>1</sup>
                </a>
             </p>
             <p>
                B.
                <a class="FootnoteRef" href="#fn:_">
                   <sup>1</sup>
                </a>
             </p>
             <p>
                C.
                <a class="FootnoteRef" href="#fn:_" id="fnref:3">
                   <sup>2</sup>
                </a>
             </p>
             <p class="TableTitle" style="text-align:center;">
                Table 1 — Table 1 — Repeatability and reproducibility of
                <i>husked</i>
                rice yield
             </p>
             <table id="tableD-1" class="MsoISOTable" style="border-width:1px;border-spacing:0;" title="tool tip">
                <caption>
                   <span style="display:none">long desc</span>
                </caption>
                <thead>
                   <tr>
                      <td rowspan="2" style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;" scope="col">Description</td>
                      <td colspan="4" style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;" scope="colgroup">Rice sample</td>
                   </tr>
                </thead>
                <tbody>
                   <tr>
                      <td style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Arborio</td>
                      <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">
                         Drago
                         <a href="#tableD-1a" class="TableFootnoteRef">a)</a>
                      </td>
                      <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">
                         Balilla
                         <a href="#tableD-1a" class="TableFootnoteRef">a)</a>
                      </td>
                      <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Thaibonnet</td>
                   </tr>
                </tbody>
                <tfoot>
                   <tr>
                      <td colspan="5" style="border-top:0pt;border-bottom:solid windowtext 1.5pt;">
                         <div id="fn:tableD-1a" class="TableFootnote">
                            <p id="_" class="TableFootnote">
                               <span class="TableFootnoteRef">a)</span>
                                 Parboiled rice.
                            </p>
                         </div>
                      </td>
                   </tr>
                </tfoot>
             </table>
          </div>
          <p class="zzSTDTitle2">
             An ITU Standard
             <a class="FootnoteRef" href="#fn:_" id="fnref:4">
                <sup>3, </sup>
             </a>
             <a class="FootnoteRef" href="#fn:_" id="fnref:5">
                <sup>4</sup>
             </a>
          </p>
            <div id="_">
               <h1 id="_">
                  <a class="anchor" href="#_"/>
                  <a class="header" href="#_">1.</a>
               </h1>
            </div>
          <aside id="fn:_" class="footnote">
             <p id="_">
                <a class="FootnoteRef" href="#fn:_">
                   <sup>1</sup>
                </a>
                Formerly denoted as 15 % (m/m).
             </p>
             <a href="#fnref:1">↩</a>
          </aside>
          <aside id="fn:_" class="footnote">
             <p id="_">
                <a class="FootnoteRef" href="#fn:_">
                   <sup>2</sup>
                </a>
                Hello! denoted as 15 % (m/m).
             </p>
             <a href="#fnref:3">↩</a>
          </aside>
          <aside id="fn:_" class="footnote">
             <p>
                <a class="FootnoteRef" href="#fn:_">
                   <sup>3</sup>
                </a>
                One fn
             </p>
             <a href="#fnref:4">↩</a>
          </aside>
          <aside id="fn:_" class="footnote">
             <p>
                <a class="FootnoteRef" href="#fn:_">
                   <sup>4</sup>
                </a>
                Another fn
             </p>
             <a href="#fnref:5">↩</a>
          </aside>
       </main>
    OUTPUT
    expect(Canon.format_xml(strip_guid(html.sub(/^.*<main /m, "<main xmlns:epub='epub' ")
      .sub(%r{</main>.*$}m, "</main>")
      .gsub(%r{<script>.+?</script>}i, "")
      .gsub(/fn:[0-9a-f][0-9a-f-]+/, "fn:_"))))
      .to be_equivalent_to Canon.format_xml(output)

    FileUtils.rm_f "test.doc"
    IsoDoc::Itu::WordConvert.new({}).convert("test", pres_output, false)
    expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc", encoding: "UTF-8")
    output = <<~OUTPUT
      <table class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;" title="tool tip" summary="long desc">
         <a name="tableD-1" id="tableD-1"/>
         <thead>
            <tr>
               <td rowspan="2" valign="top" align="left" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">Description</td>
               <td colspan="4" valign="top" align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">Rice sample</td>
            </tr>
         </thead>
         <tbody>
            <tr>
               <td valign="top" align="left" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">Arborio</td>
               <td valign="top" align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">
                  Drago
                  <a href="#tableD-1a" class="TableFootnoteRef">a)</a>
               </td>
               <td valign="top" align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">
                  Balilla
                  <a href="#tableD-1a" class="TableFootnoteRef">a)</a>
               </td>
               <td valign="top" align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">Thaibonnet</td>
            </tr>
         </tbody>
         <tfoot>
            <tr>
               <td colspan="5" style="border-top:0pt;mso-border-top-alt:0pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">
                  <div class="TableFootnote">
                     <a name="ftntableD-1a" id="ftntableD-1a"/>
                     <p class="TableFootnote">
                        <a name="_0fe65e9a-5531-408e-8295-eeff35f41a55" id="_0fe65e9a-5531-408e-8295-eeff35f41a55"/>
                        <span class="TableFootnoteRef">a)</span>
                        <span style="mso-tab-count:1">  </span>
                        Parboiled rice.
                     </p>
                  </div>
               </td>
            </tr>
         </tfoot>
      </table>
    OUTPUT
    expect(Canon.format_xml(html
    .sub(%r{^.*<div align="center" class="table_container">}m, "")
    .sub(%r{</table>.*$}m, "</table>")))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes eref types" do
    input = <<~INPUT
          <itu-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <p id="A">
          <eref type="footnote" bibitemid="ISO712" citeas="ISO 712">A</eref>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712">A</eref>
          <eref type="footnote" bibitemid="ISO712" citeas="ISO 712"></eref>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712"></eref>
          <eref type="footnote" bibitemid="ISO712" citeas="ISO 712"><locality type="section"><referenceFrom>8</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712"><locality type="section"><referenceFrom>8</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712"><localityStack connective="and"><locality type="section"><referenceFrom>8</referenceFrom></locality></localityStack><localityStack connective="and"><locality type="section"><referenceFrom>10</referenceFrom></locality></localityStack></eref>
          </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>References</title>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals and cereal products</title>
        <docidentifier>ISO 712</docidentifier>
        <date type="published"><on>2019-01-01</on></date>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
          </references>
          </bibliography>
          </itu-standard>
    INPUT
    output = <<~OUTPUT
      <p id="A">
         <eref type="footnote" bibitemid="ISO712" citeas="ISO 712" id="_">A</eref>
         <semx element="eref" source="_">
            <sup>
               <fmt-xref type="footnote" target="ISO712">A</fmt-xref>
            </sup>
         </semx>
         <eref type="inline" bibitemid="ISO712" citeas="ISO 712" id="_">A</eref>
         <semx element="eref" source="_">
            <fmt-xref type="inline" target="ISO712">A</fmt-xref>
         </semx>
         <eref type="footnote" bibitemid="ISO712" citeas="ISO 712" id="_"/>
         <semx element="eref" source="_">
            <sup>
               <fmt-xref type="footnote" target="ISO712">[ISO 712]</fmt-xref>
            </sup>
         </semx>
         <eref type="inline" bibitemid="ISO712" citeas="ISO 712" id="_"/>
         <semx element="eref" source="_">
            <fmt-xref type="inline" target="ISO712">[ISO 712]</fmt-xref>
         </semx>
         <eref type="footnote" bibitemid="ISO712" citeas="ISO 712" id="_">
            <locality type="section">
               <referenceFrom>8</referenceFrom>
            </locality>
         </eref>
         <semx element="eref" source="_">
            <sup>
               <fmt-xref type="footnote" target="ISO712">[ISO 712], Section 8</fmt-xref>
            </sup>
         </semx>
         <eref type="inline" bibitemid="ISO712" citeas="ISO 712" id="_">
            <locality type="section">
               <referenceFrom>8</referenceFrom>
            </locality>
         </eref>
         <semx element="eref" source="_">
            <fmt-xref type="inline" target="ISO712">[ISO 712], Section 8</fmt-xref>
         </semx>
         <eref type="inline" bibitemid="ISO712" citeas="ISO 712" id="_">
            <localityStack connective="and">
               <locality type="section">
                  <referenceFrom>8</referenceFrom>
               </locality>
            </localityStack>
            <localityStack connective="and">
               <locality type="section">
                  <referenceFrom>10</referenceFrom>
               </locality>
            </localityStack>
         </eref>
         <semx element="eref" source="_">
            <fmt-xref type="inline" target="ISO712">
               [ISO 712], Sections 8
               <span class="fmt-conn">and</span>
               10
            </fmt-xref>
         </semx
    OUTPUT
    expect(Canon.format_xml(strip_guid(Nokogiri::XML(IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:p[@id = 'A']").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes erefs and xrefs and links (Word)" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <p>
          <eref type="footnote" bibitemid="ISO712" citeas="ISO 712">A</stem>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712">A</stem>
          <xref target="http_1_1">Requirement <tt>/req/core/http</tt></xref>
          <link target="http://www.example.com">Test</link>
          <link target="http://www.example.com"/>
          </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>References</title>
      <bibitem id="ISO712" type="standard">
        <formattedref format="text/plain"><em>Cereals and cereal products</em>.</formattedref>
        <docidentifier>ISO 712</docidentifier>
      </bibitem>
          </references>
          </bibliography>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <preface>
            <clause type="toc" id="_" displayorder="1">
               <fmt-title id="_" depth="1">Table of Contents</fmt-title>
            </clause>
            <foreword displayorder="2" id="_">
               <title id="_">Foreword</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Foreword</semx>
               </fmt-title>
               <p>
                  <eref type="footnote" bibitemid="ISO712" citeas="ISO 712" id="_">A</eref>
                  <semx element="eref" source="_">
                     <sup>
                        <fmt-xref type="footnote" target="ISO712">A</fmt-xref>
                     </sup>
                  </semx>
                  <eref type="inline" bibitemid="ISO712" citeas="ISO 712" id="_">A</eref>
                  <semx element="eref" source="_">
                     <fmt-xref type="inline" target="ISO712">A</fmt-xref>
                  </semx>
                  <xref target="http_1_1" id="_">
                     Requirement
                     <tt>/req/core/http</tt>
                  </xref>
                  <semx element="xref" source="_">
                     <fmt-xref target="http_1_1">
                        Requirement
                        <tt>/req/core/http</tt>
                     </fmt-xref>
                  </semx>
                  <link target="http://www.example.com" id="_">Test</link>
                  <semx element="link" source="_">
                     <fmt-link target="http://www.example.com">Test</fmt-link>
                  </semx>
                  <link target="http://www.example.com" id="_"/>
                  <semx element="link" source="_">
                     <fmt-link target="http://www.example.com"/>
                  </semx>
               </p>
            </foreword>
         </preface>
         <sections>
            <references id="_" obligation="informative" normative="true" displayorder="3">
               <title id="_">References</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="_">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">References</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">clause</span>
                  <semx element="autonum" source="_">1</semx>
               </fmt-xref-label>
               <bibitem id="ISO712" type="standard">
                  <formattedref format="text/plain">
                     ISO 712,
                     <em>Cereals and cereal products</em>
                     .
                  </formattedref>
                  <docidentifier>ISO 712</docidentifier>
                  <docidentifier scope="biblio-tag">ISO 712</docidentifier>
                  <biblio-tag>[ISO 712]</biblio-tag>
               </bibitem>
            </references>
         </sections>
         <bibliography>
          </bibliography>
      </iso-standard>
    OUTPUT
    output = <<~OUTPUT
          <body lang="EN-US" link="blue" vlink="#954F72">
        <div class="WordSection1">
          <p> </p>
        </div>
        <p class="section-break">
          <br clear="all" class="section"/>
        </p>
        <div class="WordSection2">
          <p class="page-break">
            <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
          </p>
          <div id="_" class="TOC">
            <p class="zzContents">Table of Contents</p>
            <p style="tab-stops:right 17.0cm">
              <span style="mso-tab-count:1">  </span>
              <b>Page</b>
            </p>
          </div>
          <div id="_">
            <h1 class="IntroTitle">Foreword</h1>
            <p>
              <sup>
                <a href="#ISO712">A</a>
              </sup>
              <a href="#ISO712">A</a>
              <a href="#http_1_1">Requirement <tt>/req/core/http</tt></a>
              <a href="http://www.example.com">Test</a>
              <a href="http://www.example.com">http://www.example.com</a>
            </p>
          </div>
          <p> </p>
        </div>
        <p class="section-break">
          <br clear="all" class="section"/>
        </p>
        <div class="WordSection3">
          <div>
            <h1>1.<span style="mso-tab-count:1">  </span>References</h1>
            <table class="biblio" border="0">
              <tbody>
                <tr id="ISO712" class="NormRef">
                  <td style="vertical-align:top">[ISO 712]</td>
                  <td>ISO 712, <i>Cereals and cereal products</i>.</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </body>
    OUTPUT
    pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Canon.format_xml(strip_guid(pres_output
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(Canon.format_xml(strip_guid(IsoDoc::Itu::WordConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "formats URIs" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
       <boilerplate>
       <copyright-statement>
       <p><link target="http://www.example.com"/></p>
       </copyright-statement>
       </boilerplate>
       <preface>
       <foreword id="A">
       <p><link target="http://www.example.com"/></p>
       </foreword>
       </preface>
       <sections>
       <clause id="B">
       <p><link target="http://www.example.com"/></p>
       <p><link target="http://www.example.com">Word</link></p>
       <p><link target="http://www.example.com"><tt>http://www.example.com</tt></link></p>
       </clause>
       </sections>
       <annex id="C">
       </annex>
       <bibliography>
       <references id="_normative_references" obligation="informative" normative="true">
       <title>References</title>
      <bibitem id="ISO712" type="standard">
         <formattedref format="application/x-isodoc+xml"><smallcap>Standard No I.C.C 167</smallcap>. <em>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</em> (see <link target="http://www.icc.or.at"/>)</formattedref>
        <docidentifier>ISO 712</docidentifier>
        <date type="published"><on>2019-01-01</on></date>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
        <uri target="http://www.example.com"/>
      </bibitem>
          </references>
          </bibliography>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <boilerplate>
            <copyright-statement>
               <p>
                  <link target="http://www.example.com" id="_"/>
                  <semx element="link" source="_">
                     <fmt-link target="http://www.example.com"/>
                  </semx>
               </p>
            </copyright-statement>
         </boilerplate>
         <preface>
            <clause type="toc" id="_" displayorder="1">
               <fmt-title depth="1" id="_">Table of Contents</fmt-title>
            </clause>
            <foreword id="A" displayorder="2">
               <title id="_">Foreword</title>
               <fmt-title depth="1" id="_">
                  <semx element="title" source="_">Foreword</semx>
               </fmt-title>
               <p>
                  <link target="http://www.example.com" id="_"/>
                  <semx element="link" source="_">
                     <fmt-link target="http://www.example.com"/>
                  </semx>
               </p>
            </foreword>
         </preface>
         <sections>
            <clause id="B" displayorder="4">
               <fmt-title depth="1" id="_">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="B">2</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">clause</span>
                  <semx element="autonum" source="B">2</semx>
               </fmt-xref-label>
               <p>
                  <link target="http://www.example.com" id="_"/>
                  <semx element="link" source="_">
                     <fmt-link style="url" target="http://www.example.com"/>
                  </semx>
               </p>
               <p>
                  <link target="http://www.example.com" id="_">Word</link>
                  <semx element="link" source="_">
                     <fmt-link target="http://www.example.com">Word</fmt-link>
                  </semx>
               </p>
               <p>
                  <link target="http://www.example.com" id="_">
                     <tt>http://www.example.com</tt>
                  </link>
                  <semx element="link" source="_">
                     <fmt-link target="http://www.example.com" style="url">
                        <tt>http://www.example.com</tt>
                     </fmt-link>
                  </semx>
               </p>
            </clause>
            <references id="_" obligation="informative" normative="true" displayorder="3">
               <title id="_">References</title>
               <fmt-title depth="1" id="_">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="_">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">References</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">clause</span>
                  <semx element="autonum" source="_">1</semx>
               </fmt-xref-label>
               <bibitem id="ISO712" type="standard">
                  <biblio-tag>[ISO 712]</biblio-tag>
                   <formattedref format="application/x-isodoc+xml">
                      ISO 712 (2019),
                      <smallcap>Standard No I.C.C 167</smallcap>
                      .
                      <em>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</em>
                      (see
                      <link target="http://www.icc.or.at" id="_"/>
                      <semx element="link" source="_">
                         <fmt-link target="http://www.icc.or.at" style="url"/>
                      </semx>
                      ).
                   </formattedref>
                  <docidentifier>ISO 712</docidentifier>
                  <docidentifier scope="biblio-tag">ISO 712</docidentifier>
                  <date type="published">
                     <on>2019-01-01</on>
                  </date>
                  <contributor>
                     <role type="publisher"/>
                     <organization>
                        <abbreviation>ISO</abbreviation>
                     </organization>
                  </contributor>
                  <uri target="http://www.example.com"/>
               </bibitem>
            </references>
         </sections>
         <annex id="C" autonum="A" displayorder="5">
            <fmt-title id="_">
               <strong>
                  <span class="fmt-caption-label">
                     <span class="fmt-element-name">Annex</span>
                     <semx element="autonum" source="C">A</semx>
                  </span>
               </strong>
            </fmt-title>
            <fmt-xref-label>
               <span class="fmt-element-name">Annex</span>
               <semx element="autonum" source="C">A</semx>
            </fmt-xref-label>
            <p class="annex_obligation">
               <span class="fmt-obligation">(This annex forms an integral part of this .)</span>
            </p>
         </annex>
         <bibliography>
          </bibliography>
      </iso-standard>
    OUTPUT
    html = <<~OUTPUT
      <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US" class="container">
          <div class="title-section">
             <p> </p>
          </div>
          <br/>
          <div class="prefatory-section">
             <p> </p>
          </div>
          <br/>
          <div class="main-section">
             <div class="authority">
                <div class="boilerplate-copyright">
                   <p>
                      <a href="http://www.example.com">http://www.example.com</a>
                   </p>
                </div>
             </div>
             <br/>
             <div id="_" class="TOC">
                <h1 class="IntroTitle">Table of Contents</h1>
             </div>
             <div id="A">
                <h1 class="IntroTitle">Foreword</h1>
                <p>
                   <a href="http://www.example.com">http://www.example.com</a>
                </p>
             </div>
             <div>
                <h1>1.  References</h1>
                <table class="biblio" border="0">
                   <tbody>
                      <tr id="ISO712" class="NormRef">
                         <td style="vertical-align:top">[ISO 712]</td>
                         <td>
                            ISO 712 (2019),
                            <span style="font-variant:small-caps;">Standard No I.C.C 167</span>
                            .
                            <i>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</i>
                            (see
                            <a href="http://www.icc.or.at" class="url">http://www.icc.or.at</a>
                            ).
                         </td>
                      </tr>
                   </tbody>
                </table>
             </div>
             <div id="B">
                <h1>2.</h1>
                <p>
                   <a href="http://www.example.com" class="url">http://www.example.com</a>
                </p>
                <p>
                   <a href="http://www.example.com">Word</a>
                </p>
                <p>
                   <a href="http://www.example.com" class="url">
                      <tt>http://www.example.com</tt>
                   </a>
                </p>
             </div>
             <br/>
             <div id="C" class="Section3">
                <h1 class="Annex">
                   <b>Annex A</b>
                </h1>
                <p class="annex_obligation">(This annex forms an integral part of this .)</p>
             </div>
          </div>
       </body>
    OUTPUT
    word = <<~OUTPUT
           <body lang="EN-US" link="blue" vlink="#954F72">
          <div class="WordSection1">
             <p> </p>
          </div>
          <p class="section-break">
             <br clear="all" class="section"/>
          </p>
          <div class="WordSection2">
             <div class="authority">
                <div class="boilerplate-copyright">
                   <p>
                      <a href="http://www.example.com">http://www.example.com</a>
                   </p>
                </div>
             </div>
             <p class="page-break">
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
             </p>
             <div id="_" class="TOC">
                <p class="zzContents">Table of Contents</p>
                <p style="tab-stops:right 17.0cm">
                   <span style="mso-tab-count:1">  </span>
                   <b>Page</b>
                </p>
             </div>
             <div id="A">
                <h1 class="IntroTitle">Foreword</h1>
                <p>
                   <a href="http://www.example.com">http://www.example.com</a>
                </p>
             </div>
             <p> </p>
          </div>
          <p class="section-break">
             <br clear="all" class="section"/>
          </p>
          <div class="WordSection3">
             <div>
                <h1>
                   1.
                   <span style="mso-tab-count:1">  </span>
                   References
                </h1>
                <table class="biblio" border="0">
                   <tbody>
                      <tr id="ISO712" class="NormRef">
                         <td style="vertical-align:top">[ISO 712]</td>
                         <td>
                            ISO 712 (2019),
                            <span style="font-variant:small-caps;">Standard No I.C.C 167</span>
                            .
                            <i>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</i>
                            (see
                            <a href="http://www.icc.or.at" class="url">http://www.icc.or.at</a>
                            ).
                         </td>
                      </tr>
                   </tbody>
                </table>
             </div>
             <div id="B">
                <h1>2.</h1>
                <p>
                   <a href="http://www.example.com" class="url">http://www.example.com</a>
                </p>
                <p>
                   <a href="http://www.example.com">Word</a>
                </p>
                <p>
                   <a href="http://www.example.com" class="url">
                      <tt>http://www.example.com</tt>
                   </a>
                </p>
             </div>
             <p class="page-break">
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
             </p>
             <div id="C" class="Section3">
                <h1 class="Annex">
                   <b>Annex A</b>
                </h1>
                <p class="annex_obligation">(This annex forms an integral part of this .)</p>
             </div>
          </div>
       </body>
    OUTPUT
    pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Canon.format_xml(strip_guid(pres_output
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(Canon.format_xml(strip_guid(IsoDoc::Itu::HtmlConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Canon.format_xml(html)
    expect(Canon.format_xml(strip_guid(IsoDoc::Itu::WordConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Canon.format_xml(word)
  end

  it "localises numbers in MathML" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
           <title language="en">test</title>
           </bibdata>
           <preface>
           <p><stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mn>30000</mn></math></stem>
           <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>P</mi><mfenced open="(" close=")"><mrow><mi>X</mi><mo>≥</mo><msub><mrow><mi>X</mi></mrow><mrow><mo>max</mo></mrow></msub></mrow></mfenced><mo>=</mo><munderover><mrow><mo>∑</mo></mrow><mrow><mrow><mi>j</mi><mo>=</mo><msub><mrow><mi>X</mi></mrow><mrow><mo>max</mo></mrow></msub></mrow></mrow><mrow><mn>1000</mn></mrow></munderover><mfenced open="(" close=")"><mtable><mtr><mtd><mn>1000</mn></mtd></mtr><mtr><mtd><mi>j</mi></mtd></mtr></mtable></mfenced><msup><mrow><mi>p</mi></mrow><mrow><mi>j</mi></mrow></msup><msup><mrow><mfenced open="(" close=")"><mrow><mn>1</mn><mo>−</mo><mi>p</mi></mrow></mfenced></mrow><mrow><mrow><mn>1.003</mn><mo>−</mo><mi>j</mi></mrow></mrow></msup></math></stem></p>
           </preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <bibdata>
            <title language="en">test</title>
         </bibdata>
         <preface>
            <clause type="toc" id="_" displayorder="1">
               <fmt-title id="_" depth="1">Table of Contents</fmt-title>
            </clause>
            <p displayorder="2">
               <stem type="MathML" id="_">
                  <math xmlns="http://www.w3.org/1998/Math/MathML">
                     <mn>30000</mn>
                  </math>
               </stem>
               <fmt-stem type="MathML">
                  <semx element="stem" source="_">30'000</semx>
               </fmt-stem>
               <stem type="MathML" id="_">
                  <math xmlns="http://www.w3.org/1998/Math/MathML">
                     <mi>P</mi>
                     <mfenced open="(" close=")">
                        <mrow>
                           <mi>X</mi>
                           <mo>≥</mo>
                           <msub>
                              <mrow>
                                 <mi>X</mi>
                              </mrow>
                              <mrow>
                                 <mo>max</mo>
                              </mrow>
                           </msub>
                        </mrow>
                     </mfenced>
                     <mo>=</mo>
                     <munderover>
                        <mrow>
                           <mo>∑</mo>
                        </mrow>
                        <mrow>
                           <mrow>
                              <mi>j</mi>
                              <mo>=</mo>
                              <msub>
                                 <mrow>
                                    <mi>X</mi>
                                 </mrow>
                                 <mrow>
                                    <mo>max</mo>
                                 </mrow>
                              </msub>
                           </mrow>
                        </mrow>
                        <mrow>
                           <mn>1000</mn>
                        </mrow>
                     </munderover>
                     <mfenced open="(" close=")">
                        <mtable>
                           <mtr>
                              <mtd>
                                 <mn>1000</mn>
                              </mtd>
                           </mtr>
                           <mtr>
                              <mtd>
                                 <mi>j</mi>
                              </mtd>
                           </mtr>
                        </mtable>
                     </mfenced>
                     <msup>
                        <mrow>
                           <mi>p</mi>
                        </mrow>
                        <mrow>
                           <mi>j</mi>
                        </mrow>
                     </msup>
                     <msup>
                        <mrow>
                           <mfenced open="(" close=")">
                              <mrow>
                                 <mn>1</mn>
                                 <mo>−</mo>
                                 <mi>p</mi>
                              </mrow>
                           </mfenced>
                        </mrow>
                        <mrow>
                           <mrow>
                              <mn>1.003</mn>
                              <mo>−</mo>
                              <mi>j</mi>
                           </mrow>
                        </mrow>
                     </msup>
                  </math>
               </stem>
               <fmt-stem type="MathML">
                  <semx element="stem" source="_">
                     <math xmlns="http://www.w3.org/1998/Math/MathML">
                        <mi>P</mi>
                        <mfenced open="(" close=")">
                           <mrow>
                              <mi>X</mi>
                              <mo>≥</mo>
                              <msub>
                                 <mrow>
                                    <mi>X</mi>
                                 </mrow>
                                 <mrow>
                                    <mo>max</mo>
                                 </mrow>
                              </msub>
                           </mrow>
                        </mfenced>
                        <mo>=</mo>
                        <munderover>
                           <mrow>
                              <mo>∑</mo>
                           </mrow>
                           <mrow>
                              <mrow>
                                 <mi>j</mi>
                                 <mo>=</mo>
                                 <msub>
                                    <mrow>
                                       <mi>X</mi>
                                    </mrow>
                                    <mrow>
                                       <mo>max</mo>
                                    </mrow>
                                 </msub>
                              </mrow>
                           </mrow>
                           <mrow>
                              <mn>1'000</mn>
                           </mrow>
                        </munderover>
                        <mfenced open="(" close=")">
                           <mtable>
                              <mtr>
                                 <mtd>
                                    <mn>1'000</mn>
                                 </mtd>
                              </mtr>
                              <mtr>
                                 <mtd>
                                    <mi>j</mi>
                                 </mtd>
                              </mtr>
                           </mtable>
                        </mfenced>
                        <msup>
                           <mrow>
                              <mi>p</mi>
                           </mrow>
                           <mrow>
                              <mi>j</mi>
                           </mrow>
                        </msup>
                        <msup>
                           <mrow>
                              <mfenced open="(" close=")">
                                 <mrow>
                                    <mn>1</mn>
                                    <mo>−</mo>
                                    <mi>p</mi>
                                 </mrow>
                              </mfenced>
                           </mrow>
                           <mrow>
                              <mrow>
                                 <mn>1.003</mn>
                                 <mo>−</mo>
                                 <mi>j</mi>
                              </mrow>
                           </mrow>
                        </msup>
                     </math>
                     <asciimath>P (X ge X_(max)) = sum_(j = X_(max))^(1000) ([[1000], [j]]) p^(j) (1 - p)^(1.003 - j)</asciimath>
                  </semx>
               </fmt-stem>
            </p>
         </preface>
      </iso-standard>
    OUTPUT
    expect(Canon.format_xml(strip_guid(IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Canon.format_xml(output)
  end
end

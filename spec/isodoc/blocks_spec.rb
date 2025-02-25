require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Itu do
  it "processes pre" do
    input = <<~INPUT
      <itu-standard xmlns="https://www.calconnect.org/standards/itu">
      <preface>
          <clause type="toc" id="_" displayorder="1">
      <fmt-title depth="1">Table of Contents</fmt-title>
      </clause>
      <foreword  displayorder="2">
      <pre>ABC</pre>
      </foreword></preface>
      </itu-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
               <div>
                 <h1 class="IntroTitle"/>
                 <pre>ABC</pre>
               </div>
             </div>
           </body>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::Itu::HtmlConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes dl" do
    input = <<~INPUT
      <itu-standard xmlns="https://www.calconnect.org/standards/itu">
      <preface>
      <foreword>
      <dl id="A"><name>Deflist</name>
      <dt>A</dt><dd>B</dd>
      <dt>C</dt><dd>D</dd>
      <note>hien?</note>
      </dl>
      </foreword></preface>
      </itu-standard>
    INPUT
    presxml = <<~OUTPUT
       <itu-standard xmlns="https://www.calconnect.org/standards/itu" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of Contents</fmt-title>
             </clause>
             <foreword displayorder="2" id="_">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                      <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <dl id="A" autonum="">
                   <name id="_">Deflist</name>
                   <fmt-name>
                         <semx element="name" source="_">Deflist</semx>
                   </fmt-name>
                   <colgroup>
                      <col width="20%"/>
                      <col width="80%"/>
                   </colgroup>
                   <dt>A</dt>
                   <dd>B</dd>
                   <dt>C</dt>
                   <dd>D</dd>
                   <note>
                      <fmt-name>
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">NOTE</span>
                         </span>
                      </fmt-name>
                      hien?
                   </note>
                </dl>
             </foreword>
          </preface>
       </itu-standard>
    OUTPUT
    html = <<~OUTPUT
       #{HTML_HDR}
              <div id="_">
              <h1 class="IntroTitle">Foreword</h1>
            <p class="TableTitle" style="text-align:center;">Deflist</p>
            <table id="A" class="dl" style="table-layout:fixed;">
              <colgroup>
                <col style="width: 20%;"/>
                <col style="width: 80%;"/>
              </colgroup>
              <tbody>
                <tr>
                  <th style="font-weight:bold;" scope="row">A</th>
                  <td style="">B</td>
                </tr>
                <tr>
                  <th style="font-weight:bold;" scope="row">C</th>
                  <td style="">D</td>
                </tr>
              </tbody>
              <div class="Note"><p><span class="note_label">NOTE</span></p>hien?</div>
            </table>
          </div>
        </div>
      </body>
    OUTPUT
    doc = <<~OUTPUT
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
             <p class="TableTitle" style="text-align:center;">Deflist</p>
             <div align="center" class="table_container">
               <table id="A" class="dl" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;">
                 <colgroup>
                   <col width="20%"/>
                   <col width="80%"/>
                 </colgroup>
                 <tbody>
                   <tr>
                     <th valign="top" style="font-weight:bold;page-break-after:avoid;">A</th>
                     <td valign="top" style="page-break-after:avoid;">B</td>
                   </tr>
                   <tr>
                     <th valign="top" style="font-weight:bold;page-break-after:auto;">C</th>
                     <td valign="top" style="page-break-after:auto;">D</td>
                   </tr>
                 </tbody>
                 <div class="Note"><p class="Note"><span class="note_label">NOTE</span></p>hien?</div>
               </table>
             </div>
           </div>
           <p> </p>
         </div>
         <p class="section-break">
           <br clear="all" class="section"/>
         </p>
         <div class="WordSection3"/>
       </body>
    OUTPUT
    pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::HtmlConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::WordConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(doc)
  end

  it "processes formulae" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
        <formula id="_be9158af-7e93-4ee2-90c5-26d31c181934" unnumbered="true"  keep-with-next="true" keep-lines-together="true">
        <stem type="AsciiMath">r = 1 %</stem>
      <dl id="_e4fe94fe-1cde-49d9-b1ad-743293b7e21d">
        <dt><stem type="AsciiMath">r</stem></dt>
        <dd><p id="_1b99995d-ff03-40f5-8f2e-ab9665a69b77">is the repeatability limit.</p></dd>
      </dl>
      </formula>
      <formula id="_be9158af-7e93-4ee2-90c5-26d31c181935" unnumbered="true"  keep-with-next="true" keep-lines-together="true">
        <stem type="AsciiMath">r = 1 %</stem>
      <dl id="_e4fe94fe-1cde-49d9-b1ad-743293b7e21e">
        <dt><stem type="AsciiMath">r</stem></dt>
        <dd><p id="_1b99995d-ff03-40f5-8f2e-ab9665a69b78">is the repeatability limit.</p></dd>
        <dt><stem type="AsciiMath">s</stem></dt>
        <dd><p id="_1b99995d-ff03-40f5-8f2e-ab9665a69b79">is the other repeatability limit.</p></dd>
      </dl>
      </formula>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of Contents</fmt-title>
             </clause>
             <foreword id="_" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <formula id="_" unnumbered="true" keep-with-next="true" keep-lines-together="true">
                   <stem type="AsciiMath" id="_">r = 1 %</stem>
                   <fmt-stem type="AsciiMath">
                      <semx element="stem" source="_">r = 1 %</semx>
                   </fmt-stem>
                   <p keep-with-next="true">where</p>
                   <dl id="_" class="formula_dl">
                      <dt>
                         <stem type="AsciiMath" id="_">r</stem>
                         <fmt-stem type="AsciiMath">
                            <semx element="stem" source="_">r</semx>
                         </fmt-stem>
                      </dt>
                      <dd>
                         <p id="_">is the repeatability limit.</p>
                      </dd>
                   </dl>
                </formula>
                <formula id="_" unnumbered="true" keep-with-next="true" keep-lines-together="true">
                   <stem type="AsciiMath" id="_">r = 1 %</stem>
                   <fmt-stem type="AsciiMath">
                      <semx element="stem" source="_">r = 1 %</semx>
                   </fmt-stem>
                   <p keep-with-next="true">where:</p>
                   <dl id="_" class="formula_dl">
                      <dt>
                         <stem type="AsciiMath" id="_">r</stem>
                         <fmt-stem type="AsciiMath">
                            <semx element="stem" source="_">r</semx>
                         </fmt-stem>
                      </dt>
                      <dd>
                         <p id="_">is the repeatability limit.</p>
                      </dd>
                      <dt>
                         <stem type="AsciiMath" id="_">s</stem>
                         <fmt-stem type="AsciiMath">
                            <semx element="stem" source="_">s</semx>
                         </fmt-stem>
                      </dt>
                      <dd>
                         <p id="_">is the other repeatability limit.</p>
                      </dd>
                   </dl>
                </formula>
             </foreword>
          </preface>
       </iso-standard>
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
                <div id="_" style="page-break-after: avoid;page-break-inside: avoid;">
                   <div class="formula">
                      <p class="formula">
                         <span style="mso-tab-count:1">  </span>
                         <span class="stem">(#(r = 1 %)#)</span>
                      </p>
                   </div>
                   <p style="page-break-after: avoid;">where</p>
                   <table id="_" class="formula_dl">
                      <tr>
                         <td valign="top" align="left">
                            <p align="left" style="margin-left:0pt;text-align:left;">
                               <span class="stem">(#(r)#)</span>
                            </p>
                         </td>
                         <td valign="top">
                            <p id="_">is the repeatability limit.</p>
                         </td>
                      </tr>
                   </table>
                </div>
                <div id="_" style="page-break-after: avoid;page-break-inside: avoid;">
                   <div class="formula">
                      <p class="formula">
                         <span style="mso-tab-count:1">  </span>
                         <span class="stem">(#(r = 1 %)#)</span>
                      </p>
                   </div>
                   <p style="page-break-after: avoid;">where:</p>
                   <table id="_" class="formula_dl">
                      <tr>
                         <td valign="top" align="left">
                            <p align="left" style="margin-left:0pt;text-align:left;">
                               <span class="stem">(#(r)#)</span>
                            </p>
                         </td>
                         <td valign="top">
                            <p id="_">is the repeatability limit.</p>
                         </td>
                      </tr>
                      <tr>
                         <td valign="top" align="left">
                            <p align="left" style="margin-left:0pt;text-align:left;">
                               <span class="stem">(#(s)#)</span>
                            </p>
                         </td>
                         <td valign="top">
                            <p id="_">is the other repeatability limit.</p>
                         </td>
                      </tr>
                   </table>
                </div>
             </div>
             <p> </p>
          </div>
          <p class="section-break">
             <br clear="all" class="section"/>
          </p>
          <div class="WordSection3"/>
       </body>
    OUTPUT
    pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::WordConvert.new({})
      .convert("test", pres_output, true)
      .gsub(/^.*<body/m, "<body")
      .sub(/<\/body>.*$/m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes tables" do
    input = <<~INPUT
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface>
            <foreword id="fwd">
              <table id="tableD-1" alt="tool tip" summary="long desc" width="70%" keep-with-next="true" keep-lines-together="true">
          <name>Repeatability and reproducibility of <em>husked</em> rice yield<fn reference="1"><p>X</p></fn></name>
          <colgroup>
          <col width="30%"/>
          <col width="20%"/>
          <col width="20%"/>
          <col width="20%"/>
          <col width="10%"/>
          </colgroup>
          <thead>
            <tr>
              <td rowspan="2" align="left">Description</td>
              <td colspan="4" align="center">Rice sample</td>
            </tr>
            <tr>
              <td valign="top" align="left">Arborio</td>
              <td valign="middle" align="center">Drago<fn reference="a">
          <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p>
        </fn></td>
              <td valign="bottom" align="center">Balilla<fn reference="a">
          <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p>
        </fn></td>
              <td align="center">Thaibonnet</td>
            </tr>
            </thead>
            <tbody>
            <tr>
              <th align="left">Number of laboratories retained after eliminating outliers</th>
              <td align="center">13</td>
              <td align="center">11</td>
              <td align="center">13</td>
              <td align="center">13</td>
            </tr>
            <tr>
              <td align="left">Mean value, g/100 g</td>
              <td align="center">81,2</td>
              <td align="center">82,0</td>
              <td align="center">81,8</td>
              <td align="center">77,7</td>
            </tr>
            </tbody>
            <tfoot>
            <tr>
              <td align="left">Reproducibility limit, <stem type="AsciiMath">R</stem> (= 2,83 <stem type="AsciiMath">s_R</stem>)</td>
              <td align="center">2,89</td>
              <td align="center">0,57</td>
              <td align="center">2,26</td>
              <td align="center"><dl><dt>6,06</dt><dd>Definition</dd></dl></td>
            </tr>
          </tfoot>
          <dl key="true">
             <name>Key</name>
          <dt>Drago</dt>
        <dd>A type of rice</dd>
        </dl>
              <source status="generalisation">
          <origin bibitemid="ISO712" type="inline" citeas="">
            <localityStack>
              <locality type="section">
                <referenceFrom>1</referenceFrom>
              </locality>
            </localityStack>
          </origin>
          <modification>
            <p id="_">with adjustments</p>
          </modification>
        </source>
              <source status="specialisation">
          <origin bibitemid="ISO712" type="inline" citeas="">
            <localityStack>
              <locality type="section">
                <referenceFrom>2</referenceFrom>
              </locality>
            </localityStack>
          </origin>
        </source>
        <note><p>This is a table about rice</p></note>
        </table>
        <table id="tableD-2" unnumbered="true">
        <tbody><tr><td>A</td></tr></tbody>
        </table>
        </foreword>
        </preface>
        <annex id="Annex1">
        <table id="AnnexTable">
        <tbody><tr><td>A</td></td></tbody>
        </table>
        <table>
        <tbody><tr><td>B</td></td></tbody>
        </table>
        </annex>
        <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
        <bibitem id="ISO712" type="standard">
          <title format="text/plain">Cereals or cereal products</title>
          <title type="main" format="text/plain">Cereals and cereal products</title>
          <docidentifier type="ISO">ISO 712</docidentifier>
          <contributor>
            <role type="publisher"/>
            <organization>
              <name>International Organization for Standardization</name>
            </organization>
          </contributor>
        </bibitem>
      </bibliography>
        </iso-standard>
    INPUT
    presxml = <<~OUTPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of Contents</fmt-title>
             </clause>
             <foreword id="fwd" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <table id="tableD-1" alt="tool tip" summary="long desc" width="70%" keep-with-next="true" keep-lines-together="true" autonum="1">
                   <name id="_">
                      Repeatability and reproducibility of
                      <em>husked</em>
                      rice yield
                      <fn reference="1" original-reference="1" target="_" original-id="_">
                         <p>X</p>
                         <fmt-fn-label>
                            <sup>
                               <semx element="autonum" source="_">1</semx>
                               <span class="fmt-label-delim">)</span>
                            </sup>
                         </fmt-fn-label>
                      </fn>
                   </name>
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Table</span>
                         <semx element="autonum" source="tableD-1">1</semx>
                      </span>
                      <span class="fmt-caption-delim"> — </span>
                      <semx element="name" source="_">
                         Repeatability and reproducibility of
                         <em>husked</em>
                         rice yield
                         <fn reference="1" original-reference="1" id="_" target="_">
                            <p>X</p>
                            <fmt-fn-label>
                               <sup>
                                  <semx element="autonum" source="_">1</semx>
                                  <span class="fmt-label-delim">)</span>
                               </sup>
                            </fmt-fn-label>
                         </fn>
                      </semx>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="tableD-1">1</semx>
                   </fmt-xref-label>
                   <colgroup>
                      <col width="30%"/>
                      <col width="20%"/>
                      <col width="20%"/>
                      <col width="20%"/>
                      <col width="10%"/>
                   </colgroup>
                   <thead>
                      <tr>
                         <td rowspan="2" align="left">Description</td>
                         <td colspan="4" align="center">Rice sample</td>
                      </tr>
                      <tr>
                         <td valign="top" align="left">Arborio</td>
                         <td valign="middle" align="center">
                            Drago
                            <fn reference="a" id="_" target="_">
                               <p original-id="_">Parboiled rice.</p>
                               <fmt-fn-label>
                                  <sup>
                                     <semx element="autonum" source="_">a</semx>
                                     <span class="fmt-label-delim">)</span>
                                  </sup>
                               </fmt-fn-label>
                            </fn>
                         </td>
                         <td valign="bottom" align="center">
                            Balilla
                            <fn reference="a" id="_" target="_">
                               <p id="_">Parboiled rice.</p>
                               <fmt-fn-label>
                                  <sup>
                                     <semx element="autonum" source="_">a</semx>
                                     <span class="fmt-label-delim">)</span>
                                  </sup>
                               </fmt-fn-label>
                            </fn>
                         </td>
                         <td align="center">Thaibonnet</td>
                      </tr>
                   </thead>
                   <tbody>
                      <tr>
                         <th align="left">Number of laboratories retained after eliminating outliers</th>
                         <td align="center">13</td>
                         <td align="center">11</td>
                         <td align="center">13</td>
                         <td align="center">13</td>
                      </tr>
                      <tr>
                         <td align="left">Mean value, g/100 g</td>
                         <td align="center">81,2</td>
                         <td align="center">82,0</td>
                         <td align="center">81,8</td>
                         <td align="center">77,7</td>
                      </tr>
                   </tbody>
                   <tfoot>
                      <tr>
                         <td align="left">
                            Reproducibility limit,
                            <stem type="AsciiMath" id="_">R</stem>
                            <fmt-stem type="AsciiMath">
                               <semx element="stem" source="_">R</semx>
                            </fmt-stem>
                            (= 2,83
                            <stem type="AsciiMath" id="_">s_R</stem>
                            <fmt-stem type="AsciiMath">
                               <semx element="stem" source="_">s_R</semx>
                            </fmt-stem>
                            )
                         </td>
                         <td align="center">2,89</td>
                         <td align="center">0,57</td>
                         <td align="center">2,26</td>
                         <td align="center">
                            <dl>
                               <dt>6,06</dt>
                               <dd>Definition</dd>
                            </dl>
                         </td>
                      </tr>
                   </tfoot>
                   <dl key="true">
                      <name id="_">Key</name>
                      <fmt-name>
                         <semx element="name" source="_">Key</semx>
                      </fmt-name>
                      <dt>Drago</dt>
                      <dd>A type of rice</dd>
                   </dl>
                   <source status="generalisation">
                      [SOURCE:
                      <origin bibitemid="ISO712" type="inline" citeas="" id="_">
                         <localityStack>
                            <locality type="section">
                               <referenceFrom>1</referenceFrom>
                            </locality>
                         </localityStack>
                      </origin>
                      <semx element="origin" source="_">
                         <fmt-xref type="inline" target="ISO712">[ISO 712], Section 1</fmt-xref>
                      </semx>
                      —
                      <semx element="modification" source="_">with adjustments</semx>
                      ;
                      <origin bibitemid="ISO712" type="inline" citeas="" id="_">
                         <localityStack>
                            <locality type="section">
                               <referenceFrom>2</referenceFrom>
                            </locality>
                         </localityStack>
                      </origin>
                      <semx element="origin" source="_">
                         <fmt-xref type="inline" target="ISO712">[ISO 712], Section 2</fmt-xref>
                      </semx>
                      ]
                   </source>
                   <note>
                      <fmt-name>
                         <span class="fmt-caption-label">
                            <span class="fmt-element-name">NOTE</span>
                         </span>
                         <span class="fmt-label-delim"> – </span>
                      </fmt-name>
                      <p>This is a table about rice</p>
                   </note>
                   <fmt-footnote-container>
                      <fmt-fn-body id="_" target="_" reference="a">
                         <semx element="fn" source="_">
                            <p id="_">
                               <fmt-fn-label>
                                  <sup>
                                     <semx element="autonum" source="_">a</semx>
                                     <span class="fmt-label-delim">)</span>
                                  </sup>
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
                <table id="tableD-2" unnumbered="true">
                   <tbody>
                      <tr>
                         <td>A</td>
                      </tr>
                   </tbody>
                </table>
             </foreword>
          </preface>
          <sections>
             <references id="_" obligation="informative" normative="true" displayorder="3">
                <title id="_">Normative References</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="_">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Normative References</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">clause</span>
                   <semx element="autonum" source="_">1</semx>
                </fmt-xref-label>
                <bibitem id="ISO712" type="standard">
                   <formattedref>
                      ISO 712,
                      <em>Cereals and cereal products</em>
                      .
                   </formattedref>
                   <title format="text/plain">Cereals or cereal products</title>
                   <title type="main" format="text/plain">Cereals and cereal products</title>
                   <docidentifier type="ISO">ISO 712</docidentifier>
                   <docidentifier scope="biblio-tag">ISO 712</docidentifier>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <name>International Organization for Standardization</name>
                      </organization>
                   </contributor>
                   <biblio-tag>[ISO 712]</biblio-tag>
                </bibitem>
             </references>
          </sections>
          <annex id="Annex1" autonum="A" displayorder="4">
             <fmt-title>
                <strong>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="Annex1">A</semx>
                   </span>
                </strong>
             </fmt-title>
             <fmt-xref-label>
                <span class="fmt-element-name">Annex</span>
                <semx element="autonum" source="Annex1">A</semx>
             </fmt-xref-label>
             <p class="annex_obligation">
                <span class="fmt-obligation">(This annex forms an integral part of this .)</span>
             </p>
             <table id="AnnexTable" autonum="A.1">
                <fmt-name>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="Annex1">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="AnnexTable">1</semx>
                   </span>
                </fmt-name>
                <fmt-xref-label>
                   <span class="fmt-element-name">Table</span>
                   <semx element="autonum" source="Annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="AnnexTable">1</semx>
                </fmt-xref-label>
                <tbody>
                   <tr>
                      <td>A</td>
                   </tr>
                </tbody>
             </table>
             <table>
                <fmt-name>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Table</span>
                   </span>
                </fmt-name>
                <tbody>
                   <tr>
                      <td>B</td>
                   </tr>
                </tbody>
             </table>
          </annex>
          <bibliography>
         </bibliography>
          <fmt-footnote-container>
             <fmt-fn-body id="_" target="_" reference="1">
                <semx element="fn" source="_">
                   <p>
                      <fmt-fn-label>
                         <sup>
                            <semx element="autonum" source="_">1</semx>
                            <span class="fmt-label-delim">)</span>
                         </sup>
                         <span class="fmt-caption-delim">
                            <tab/>
                         </span>
                      </fmt-fn-label>
                      X
                   </p>
                </semx>
             </fmt-fn-body>
          </fmt-footnote-container>
       </iso-standard>
    OUTPUT
    html = <<~OUTPUT
          <html lang="en">
          <head/>
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
                <br/>
                <div id="_" class="TOC">
                   <h1 class="IntroTitle">Table of Contents</h1>
                </div>
                <div id="fwd">
                   <h1 class="IntroTitle">Foreword</h1>
                   <p class="TableTitle" style="text-align:center;">
                      Table 1 — Repeatability and reproducibility of
                      <i>husked</i>
                      rice yield
                      <a class="FootnoteRef" href="#fn:1">
                         <sup>1)</sup>
                      </a>
                   </p>
                   <table id="tableD-1" class="MsoISOTable" style="border-width:1px;border-spacing:0;width:70%;page-break-after: avoid;page-break-inside: avoid;table-layout:fixed;" title="tool tip">
                      <caption>
                         <span style="display:none">long desc</span>
                      </caption>
                      <colgroup>
                         <col style="width: 30%;"/>
                         <col style="width: 20%;"/>
                         <col style="width: 20%;"/>
                         <col style="width: 20%;"/>
                         <col style="width: 10%;"/>
                      </colgroup>
                      <thead>
                         <tr>
                            <td rowspan="2" style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;" scope="col">Description</td>
                            <td colspan="4" style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;" scope="colgroup">Rice sample</td>
                         </tr>
                         <tr>
                            <td style="text-align:left;vertical-align:top;border-top:none;border-bottom:solid windowtext 1.5pt;" scope="col">Arborio</td>
                            <td style="text-align:center;vertical-align:middle;border-top:none;border-bottom:solid windowtext 1.5pt;" scope="col">
                               Drago
                               <a href="#tableD-1a" class="TableFootnoteRef">a)</a>
                            </td>
                            <td style="text-align:center;vertical-align:bottom;border-top:none;border-bottom:solid windowtext 1.5pt;" scope="col">
                               Balilla
                               <a href="#tableD-1a" class="TableFootnoteRef">a)</a>
                            </td>
                            <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;" scope="col">Thaibonnet</td>
                         </tr>
                      </thead>
                      <tbody>
                         <tr>
                            <th style="font-weight:bold;text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;" scope="row">Number of laboratories retained after eliminating outliers</th>
                            <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">13</td>
                            <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">11</td>
                            <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">13</td>
                            <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;">13</td>
                         </tr>
                         <tr>
                            <td style="text-align:left;border-top:none;border-bottom:solid windowtext 1.5pt;">Mean value, g/100 g</td>
                            <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;">81,2</td>
                            <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;">82,0</td>
                            <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;">81,8</td>
                            <td style="text-align:center;border-top:none;border-bottom:solid windowtext 1.5pt;">77,7</td>
                         </tr>
                      </tbody>
                      <tfoot>
                         <tr>
                            <td style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">
                               Reproducibility limit,
                               <span class="stem">(#(R)#)</span>
                               (= 2,83
                               <span class="stem">(#(s_R)#)</span>
                               )
                            </td>
                            <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">2,89</td>
                            <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">0,57</td>
                            <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">2,26</td>
                            <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">
                               <div class="figdl">
                                  <dl>
                                     <dt>
                                        <p>6,06</p>
                                     </dt>
                                     <dd>Definition</dd>
                                  </dl>
                               </div>
                            </td>
                         </tr>
                      </tfoot>
                      <div class="figdl">
                         <p class="ListTitle">Key</p>
                         <dl>
                            <dt>
                               <p>Drago</p>
                            </dt>
                            <dd>A type of rice</dd>
                         </dl>
                      </div>
                      <div class="BlockSource">
                         <p>
                            [SOURCE:
                            <a href="#ISO712">[ISO 712], Section 1</a>
                            — with adjustments;
                            <a href="#ISO712">[ISO 712], Section 2</a>
                            ]
                         </p>
                      </div>
                      <div class="Note">
                         <p>
                            <span class="note_label">NOTE – </span>
                            This is a table about rice
                         </p>
                      </div>
                      <aside id="fn:tableD-1a" class="footnote">
                         <p id="_">
                            <span class="TableFootnoteRef">a)</span>
                              Parboiled rice.
                         </p>
                      </aside>
                   </table>
                   <table id="tableD-2" class="MsoISOTable" style="border-width:1px;border-spacing:0;">
                      <tbody>
                         <tr>
                            <td style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">A</td>
                         </tr>
                      </tbody>
                   </table>
                </div>
                <div>
                   <h1>1.  Normative References</h1>
                   <table class="biblio" border="0">
                      <tbody>
                         <tr id="ISO712" class="NormRef">
                            <td style="vertical-align:top">[ISO 712]</td>
                            <td>
                               ISO 712,
                               <i>Cereals and cereal products</i>
                               .
                            </td>
                         </tr>
                      </tbody>
                   </table>
                </div>
                <br/>
                <div id="Annex1" class="Section3">
                   <h1 class="Annex">
                      <b>Annex A</b>
                   </h1>
                   <p class="annex_obligation">(This annex forms an integral part of this .)</p>
                   <p class="TableTitle" style="text-align:center;">Table A.1</p>
                   <table id="AnnexTable" class="MsoISOTable" style="border-width:1px;border-spacing:0;">
                      <tbody>
                         <tr>
                            <td style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">A</td>
                         </tr>
                      </tbody>
                   </table>
                   <p class="TableTitle" style="text-align:center;">Table</p>
                   <table class="MsoISOTable" style="border-width:1px;border-spacing:0;">
                      <tbody>
                         <tr>
                            <td style="border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">B</td>
                         </tr>
                      </tbody>
                   </table>
                </div>
                <aside id="fn:1" class="footnote">
                   <p>X</p>
                </aside>
             </div>
          </body>
       </html>
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
             <div id="fwd">
                <h1 class="IntroTitle">Foreword</h1>
                <p class="TableTitle" style="text-align:center;">
                   Table 1 — Repeatability and reproducibility of
                   <i>husked</i>
                   rice yield
                   <span style="mso-bookmark:_Ref">
                      <a class="FootnoteRef" href="#ftn1" epub:type="footnote">
                         <sup>1)</sup>
                      </a>
                   </span>
                </p>
                <div align="center" class="table_container">
                   <table id="tableD-1" class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;page-break-after: avoid;page-break-inside: avoid;" title="tool tip" summary="long desc" width="70%">
                      <colgroup>
                         <col width="30%"/>
                         <col width="20%"/>
                         <col width="20%"/>
                         <col width="20%"/>
                         <col width="10%"/>
                      </colgroup>
                      <thead>
                         <tr>
                            <td rowspan="2" valign="top" align="left" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">Description</td>
                            <td colspan="4" valign="top" align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">Rice sample</td>
                         </tr>
                         <tr>
                            <td valign="top" align="left" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">Arborio</td>
                            <td valign="top" align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">
                               Drago
                               <a href="#tableD-1a" class="TableFootnoteRef">a)</a>
                            </td>
                            <td valign="top" align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">
                               Balilla
                               <a href="#tableD-1a" class="TableFootnoteRef">a)</a>
                            </td>
                            <td valign="top" align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">Thaibonnet</td>
                         </tr>
                      </thead>
                      <tbody>
                         <tr>
                            <th valign="top" align="left" style="font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">Number of laboratories retained after eliminating outliers</th>
                            <td valign="top" align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">13</td>
                            <td valign="top" align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">11</td>
                            <td valign="top" align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">13</td>
                            <td valign="top" align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;page-break-after:avoid;">13</td>
                         </tr>
                         <tr>
                            <td valign="top" align="left" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">Mean value, g/100 g</td>
                            <td valign="top" align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">81,2</td>
                            <td valign="top" align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">82,0</td>
                            <td valign="top" align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">81,8</td>
                            <td valign="top" align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">77,7</td>
                         </tr>
                      </tbody>
                      <tfoot>
                         <tr>
                            <td valign="top" align="left" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">
                               Reproducibility limit,
                               <span class="stem">(#(R)#)</span>
                               (= 2,83
                               <span class="stem">(#(s_R)#)</span>
                               )
                            </td>
                            <td valign="top" align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">2,89</td>
                            <td valign="top" align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">0,57</td>
                            <td valign="top" align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">2,26</td>
                            <td valign="top" align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">
                               <div class="figdl">
                                  <p style="text-indent: -2.0cm; margin-left: 2.0cm; tab-stops: 2.0cm;">
                                     6,06
                                     <span style="mso-tab-count:1">  </span>
                                     Definition
                                  </p>
                               </div>
                            </td>
                         </tr>
                      </tfoot>
                      <div class="figdl">
                         <p class="ListTitle">Key</p>
                         <p style="text-indent: -2.0cm; margin-left: 2.0cm; tab-stops: 2.0cm;">
                            Drago
                            <span style="mso-tab-count:1">  </span>
                            A type of rice
                         </p>
                      </div>
                      <div class="BlockSource">
                         <p>
                            [SOURCE:
                            <a href="#ISO712">[ISO 712], Section 1</a>
                            — with adjustments;
                            <a href="#ISO712">[ISO 712], Section 2</a>
                            ]
                         </p>
                      </div>
                      <div class="Note">
                         <p class="Note">
                            <span class="note_label">NOTE – </span>
                            This is a table about rice
                         </p>
                      </div>
                      <aside id="ftntableD-1a">
                         <p id="_">
                            <span class="TableFootnoteRef">a)</span>
                            <span style="mso-tab-count:1">  </span>
                            Parboiled rice.
                         </p>
                      </aside>
                   </table>
                </div>
                <div align="center" class="table_container">
                   <table id="tableD-2" class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;">
                      <tbody>
                         <tr>
                            <td valign="top" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">A</td>
                         </tr>
                      </tbody>
                   </table>
                </div>
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
                   Normative References
                </h1>
                <table class="biblio" border="0">
                   <tbody>
                      <tr id="ISO712" class="NormRef">
                         <td style="vertical-align:top">[ISO 712]</td>
                         <td>
                            ISO 712,
                            <i>Cereals and cereal products</i>
                            .
                         </td>
                      </tr>
                   </tbody>
                </table>
             </div>
             <p class="page-break">
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
             </p>
             <div id="Annex1" class="Section3">
                <h1 class="Annex">
                   <b>Annex A</b>
                </h1>
                <p class="annex_obligation">(This annex forms an integral part of this .)</p>
                <p class="TableTitle" style="text-align:center;">Table A.1</p>
                <div align="center" class="table_container">
                   <table id="AnnexTable" class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;">
                      <tbody>
                         <tr>
                            <td valign="top" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">A</td>
                         </tr>
                      </tbody>
                   </table>
                </div>
                <p class="TableTitle" style="text-align:center;">Table</p>
                <div align="center" class="table_container">
                   <table class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;">
                      <tbody>
                         <tr>
                            <td valign="top" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">B</td>
                         </tr>
                      </tbody>
                   </table>
                </div>
             </div>
             <aside id="ftn1">
                <p>X</p>
             </aside>
          </div>
       </body>
    OUTPUT
    pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
     expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::WordConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")
      .gsub(/mso-bookmark:_Ref\d+/, "mso-bookmark:_Ref"))))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes steps class of ordered lists" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <ol id="_ae34a226-aab4-496d-987b-1aa7b6314026" class="steps">
        <li>
          <p id="_0091a277-fb0e-424a-aea8-f0001303fe78">all information necessary for the complete identification of the sample;</p>
          </li>
          <li>
        <ol id="A">
        <li>
          <p id="_8a7b6299-db05-4ff8-9de7-ff019b9017b2">a reference to this document (i.e. ISO 17301-1);</p>
        </li>
        <li>
        <ol id="B">
        <li>
          <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">the sampling method used;</p>
        </li>
        </ol>
        </li>
        </ol>
        </li>
      </ol>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of Contents</fmt-title>
             </clause>
             <foreword displayorder="2" id="_">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                      <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <ol id="_" class="steps" type="arabic">
                   <li id="_" label="1">
                      <p id="_">all information necessary for the complete identification of the sample;</p>
                   </li>
                   <li id="_" label="2">
                      <ol id="A" type="alphabet">
                         <li id="_" label="a">
                            <p id="_">a reference to this document (i.e. ISO 17301-1);</p>
                         </li>
                         <li id="_" label="b">
                            <ol id="B" type="roman">
                               <li id="_" label="i">
                                  <p id="_">the sampling method used;</p>
                               </li>
                            </ol>
                         </li>
                      </ol>
                   </li>
                </ol>
             </foreword>
          </preface>
       </iso-standard>
    OUTPUT
    html = <<~OUTPUT
      #{HTML_HDR}
            <div id="_">
              <h1 class="IntroTitle">Foreword</h1>
               <div class="ol_wrap">
                           <ol type="1" id="_">
               <li id="_">
                 <p id="_">all information necessary for the complete identification of the sample;</p>
               </li>
               <li id="_">
                <div class="ol_wrap">
                 <ol type="a" id="A">
                   <li id="_">
                     <p id="_">a reference to this document (i.e. ISO 17301-1);</p>
                   </li>
                   <li id="_">
                    <div class="ol_wrap">
                     <ol type="i" id="B">
                       <li id="_">
                         <p id="_">the sampling method used;</p>
                       </li>
                     </ol>
                     </div>
                   </li>
                 </ol>
                 </div>
               </li>
             </ol>
             </div>
           </div>
         </div>
       </body>
    OUTPUT
    doc = <<~OUTPUT
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
             <div class="ol_wrap">
               <ol class="steps" id="_">
                 <li id="_">
                   <p id="_">all information necessary for the complete identification of the sample;</p>
                 </li>
                 <li id="_">
                   <div class="ol_wrap">
                     <ol id="A">
                       <li id="_">
                         <p id="_">a reference to this document (i.e. ISO 17301-1);</p>
                       </li>
                       <li id="_">
                         <div class="ol_wrap">
                           <ol id="B">
                             <li id="_">
                               <p id="_">the sampling method used;</p>
                             </li>
                           </ol>
                         </div>
                       </li>
                     </ol>
                   </div>
                 </li>
               </ol>
             </div>
           </div>
           <p> </p>
         </div>
         <p class="section-break">
           <br clear="all" class="section"/>
         </p>
         <div class="WordSection3"/>
       </body>
    OUTPUT
    pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::HtmlConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::WordConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(doc)
  end

  it "capitalises table titles" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <table><name>title title</name>
          <thead>
          <tr><th>title title1</th><th>title Title2</th><td>title title3</td></tr>
          </thead>
          <tbody>
          <tr><th>title title4</th><th>title title5</th><td>title title6</td></tr>
          </tbody>
          </table>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of Contents</fmt-title>
             </clause>
             <foreword displayorder="2" id="_">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                      <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <table>
                   <name id="_">title title</name>
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Table</span>
                         </span>
                         <span class="fmt-caption-delim"> — </span>
                         <semx element="name" source="_">Title title</semx>
                   </fmt-name>
                   <thead>
                      <tr>
                         <th>Title title1</th>
                         <th>Title Title2</th>
                         <td>title title3</td>
                      </tr>
                   </thead>
                   <tbody>
                      <tr>
                         <th>title title4</th>
                         <th>title title5</th>
                         <td>title title6</td>
                      </tr>
                   </tbody>
                </table>
             </foreword>
          </preface>
       </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)

    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <table><name><span style="text-transform:none">title</span> title</name>
          <thead>
          <tr><th><span style="text-transform:none">title</span> title1</th><th><em><span style="text-transform:none">ti</span>tle</em> title2</th><td>title title3</td></tr>
          </thead>
          <tbody>
          <tr><th>title title4</th><th>title title5</th><td>title title6</td></tr>
          </tbody>
          </table>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of Contents</fmt-title>
             </clause>
             <foreword displayorder="2" id="_">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                      <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <table>
                   <name id="_">
                      <span style="text-transform:none">title</span>
                      title
                   </name>
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Table</span>
                         </span>
                         <span class="fmt-caption-delim"> — </span>
                         <semx element="name" source="_">
                            <span style="text-transform:none">title</span>
                            title
                         </semx>
                   </fmt-name>
                   <thead>
                      <tr>
                         <th>
                            <span style="text-transform:none">title</span>
                            title1
                         </th>
                         <th>
                            <em>
                               <span style="text-transform:none">ti</span>
                               tle
                            </em>
                            title2
                         </th>
                         <td>title title3</td>
                      </tr>
                   </thead>
                   <tbody>
                      <tr>
                         <th>title title4</th>
                         <th>title title5</th>
                         <td>title title6</td>
                      </tr>
                   </tbody>
                </table>
             </foreword>
          </preface>
       </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "post-processes steps class of ordered lists (Word)" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::Itu::WordConvert.new({}).convert("test", <<~INPUT, false)
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword id="A"  displayorder="1">
          <ol id="_ae34a226-aab4-496d-987b-1aa7b6314026" class="steps">
        <li>
          <p id="_0091a277-fb0e-424a-aea8-f0001303fe78">all information necessary for the complete identification of the sample;</p>
        </li>
        <ol>
        <li>
          <p id="_8a7b6299-db05-4ff8-9de7-ff019b9017b2">a reference to this document (i.e. ISO 17301-1);</p>
        </li>
        <ol>
        <li>
          <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">the sampling method used;</p>
        </li>
        </ol>
        </ol>
      </ol>
      </foreword></preface>
      </iso-standard>
    INPUT
    expect(File.exist?("test.doc")).to be true
    html = Nokogiri::XML(File.read("test.doc")
      .sub(/^.*<html/m, "<html").sub(/<\/html>.*$/m, "</html>"))
      .at("//*[@id = 'A']").parent.to_xml
    expect(Xml::C14n.format(strip_guid(html)))
      .to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
          <div><a name="A" id="A"/>
        <p class='h1Preface'/>
        <div class="ol_wrap">
        <p style='mso-list:l4 level1 lfo1;' class='MsoListParagraphCxSpFirst'> <a name="_" id="_"/> all information necessary for the complete identification of the sample; </p>
        <div class="ol_wrap">
        <p style='mso-list:l4 level1 lfo2;' class='MsoListParagraphCxSpFirst'> a reference to this document (i.e. ISO 17301-1); </p>
        <div class="ol_wrap">
        <p style='mso-list:l4 level1 lfo3;;mso-list:l4 level1 lfo4;' class='MsoListParagraphCxSpFirst'> the sampling method used; </p>
        </div></div></div>
      </div>
    OUTPUT
  end

  it "processes unlabelled notes" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
        <foreword id="A">
          <note unnumbered="true">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of Contents</fmt-title>
             </clause>
             <foreword id="A" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                      <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <note unnumbered="true">
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">NOTE</span>
                      </span>
                      <span class="fmt-label-delim"> – </span>
                   </fmt-name>
                   <p id="_">These results are based on a study carried out on three different types of kernel.</p>
                </note>
             </foreword>
          </preface>
       </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
             <div id="A">
                <h1 class="IntroTitle">Foreword</h1>
                <div class="Note">
                   <p>
                      <span class="note_label">NOTE – </span>
                      These results are based on a study carried out on three different types of kernel.
                   </p>
                </div>
             </div>
          </div>
       </body>
    OUTPUT

    doc = <<~OUTPUT
      <body lang='EN-US' link='blue' vlink='#954F72'>
           <div class='WordSection1'>
             <p>&#160;</p>
           </div>
           <p class="section-break">
             <br clear='all' class='section'/>
           </p>
           <div class='WordSection2'>
               <p class="page-break">
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
              </p>
              <div class="TOC" id="_">
                <p class="zzContents">Table of Contents</p>
                <p style="tab-stops:right 17.0cm">
                  <span style="mso-tab-count:1">  </span>
                  <b>Page</b>
                </p>
              </div>
             <div id="A">
               <h1 class="IntroTitle">Foreword</h1>
               <div class='Note'>
                 <p class="Note">
                   <span class="note_label">NOTE – </span>
                   These results are based on a study carried out on three different
                   types of kernel.
                 </p>
               </div>
             </div>
             <p>&#160;</p>
           </div>
           <p class="section-break">
             <br clear='all' class='section'/>
           </p>
           <div class='WordSection3'>
           </div>
         </body>
    OUTPUT
    pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::HtmlConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::WordConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(doc)
  end

  it "processes sequences of notes" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword id="A">
          <note id="note1">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          <note id="note2">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83b">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table of Contents</fmt-title>
             </clause>
             <foreword id="A" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                      <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <note id="note1" autonum="1">
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">NOTE</span>
                         <semx element="autonum" source="note1">1</semx>
                      </span>
                      <span class="fmt-label-delim"> – </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Note</span>
                      <semx element="autonum" source="note1">1</semx>
                   </fmt-xref-label>
                               <fmt-xref-label container="A">
               <span class="fmt-element-name">Note</span>
               <semx element="autonum" source="note1">1</semx>
               <span class="fmt-conn">in</span>
               <span class="fmt-xref-container">
                  <semx element="foreword" source="A">Foreword</semx>
               </span>
            </fmt-xref-label>
                   <p id="_">These results are based on a study carried out on three different types of kernel.</p>
                </note>
                <note id="note2" autonum="2">
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">NOTE</span>
                         <semx element="autonum" source="note2">2</semx>
                      </span>
                      <span class="fmt-label-delim"> – </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Note</span>
                      <semx element="autonum" source="note2">2</semx>
                   </fmt-xref-label>
                               <fmt-xref-label container="A">
               <span class="fmt-element-name">Note</span>
               <semx element="autonum" source="note2">2</semx>
               <span class="fmt-conn">in</span>
               <span class="fmt-xref-container">
                  <semx element="foreword" source="A">Foreword</semx>
               </span>
            </fmt-xref-label>
                   <p id="_">These results are based on a study carried out on three different types of kernel.</p>
                   <p id="_">These results are based on a study carried out on three different types of kernel.</p>
                </note>
             </foreword>
          </preface>
       </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
      <div id="A">
               <h1 class="IntroTitle">Foreword</h1>
               <div id='note1' class='Note'>
                 <p>
                   <span class='note_label'>NOTE 1 – </span>
                   These results are based on a study carried out on three
                   different types of kernel.
                 </p>
               </div>
               <div id='note2' class='Note'>
                 <p>
                   <span class='note_label'>NOTE 2 – </span>
                   These results are based on a study carried out on three
                   different types of kernel.
                 </p>
                 <p id='_'>
                   These results are based on a study carried out on three different
                   types of kernel.
                 </p>
               </div>
             </div>
           </div>
         </body>
    OUTPUT

    doc = <<~OUTPUT
      <body lang='EN-US' link='blue' vlink='#954F72'>
               <div class='WordSection1'>
                 <p>&#160;</p>
               </div>
               <p class="section-break">
                 <br clear='all' class='section'/>
               </p>
               <div class='WordSection2'>
                   <p class="page-break">
                    <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
                  </p>
                  <div class="TOC" id="_">
                    <p class="zzContents">Table of Contents</p>
                    <p style="tab-stops:right 17.0cm">
                      <span style="mso-tab-count:1">  </span>
                      <b>Page</b>
                    </p>
                  </div>
                 <div id="A">
                   <h1 class="IntroTitle">Foreword</h1>
                   <div id='note1' class='Note'>
                     <p class="Note">
                       <span class='note_label'>NOTE 1 – </span>
                       These results are based on a study carried out on three different
                       types of kernel.
                     </p>
                   </div>
                   <div id='note2' class='Note'>
                     <p class="Note">
                       <span class='note_label'>NOTE 2 – </span>
                       These results are based on a study carried out on three different
                       types of kernel.
                     </p>
                     <p class='Note' id='_'>
                       These results are based on a study carried out on three different
                       types of kernel.
                     </p>
                   </div>
                 </div>
                 <p>&#160;</p>
               </div>
               <p class="section-break">
                 <br clear='all' class='section'/>
               </p>
               <div class='WordSection3'>
               </div>
             </body>
    OUTPUT
    pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::HtmlConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::WordConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(doc)
  end
end

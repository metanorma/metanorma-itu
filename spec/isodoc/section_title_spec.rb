require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Itu do
  it "processes section names" do
    presxml = <<~OUTPUT
       <metanorma xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata type="standard">
             <title language="en" type="main">An ITU Standard</title>
             <title language="fr" type="main">Un Standard ITU</title>
             <docidentifier type="ITU">12345</docidentifier>
             <language current="true">en</language>
             <script current="true">Latn</script>
             <keyword>A</keyword>
             <keyword>B</keyword>
             <ext>
                <doctype language="">recommendation</doctype>
                <doctype language="en">Recommendation</doctype>
                <flavor>itu</flavor>
             </ext>
          </bibdata>
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1" id="_">Table of Contents</fmt-title>
             </clause>
             <abstract id="_" displayorder="2">
                <title id="_">Abstract</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Abstract</semx>
                </fmt-title>
                <p>This is an abstract</p>
             </abstract>
             <clause id="_" type="keyword" displayorder="3">
                <fmt-title id="_" depth="1">Keywords</fmt-title>
                <p>A, B.</p>
             </clause>
             <foreword obligation="informative" id="_" displayorder="4">
                <title id="_">Foreword</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <p id="A">This is a preamble</p>
             </foreword>
             <introduction id="B" obligation="informative" displayorder="5">
                <title id="_">Introduction</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Introduction</semx>
                </fmt-title>
                <clause id="C" inline-header="false" obligation="informative">
                   <title id="_">Introduction Subsection</title>
                   <fmt-title depth="2" id="_">
                      <semx element="title" source="_">Introduction Subsection</semx>
                   </fmt-title>
                </clause>
             </introduction>
             <clause id="A0" displayorder="6">
                <title id="_">History</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">History</semx>
                </fmt-title>
                <p>history</p>
             </clause>
          </preface>
          <sections>
             <p class="zzSTDTitle1" displayorder="7">Recommendation
         12345</p>
             <p class="zzSTDTitle2" displayorder="8">An ITU Standard</p>
             <clause id="D" obligation="normative" type="scope" displayorder="9">
                <title id="_">Scope</title>
                <fmt-title depth="1" id="_">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="D">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Scope</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">clause</span>
                   <semx element="autonum" source="D">1</semx>
                </fmt-xref-label>
                <p id="E">Text</p>
             </clause>
             <terms id="I" obligation="normative" displayorder="11">
                <fmt-title depth="1" id="_">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="I">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">clause</span>
                   <semx element="autonum" source="I">3</semx>
                </fmt-xref-label>
                <term id="J">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="I">3</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="J">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">clause</span>
                      <semx element="autonum" source="I">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="J">1</semx>
                   </fmt-xref-label>
                   <preferred id="_">
                      <expression>
                         <name id="_">Term2</name>
                      </expression>
                   </preferred>
                   <fmt-preferred>
                      <semx element="preferred" source="_">
                         <strong>
                            <semx element="expression/name" source="_">Term2</semx>
                         </strong>
                         :
                      </semx>
                   </fmt-preferred>
                </term>
             </terms>
             <definitions id="L" displayorder="12">
                <title id="_">Abbreviations and acronyms</title>
                <fmt-title depth="1" id="_">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="L">4</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Abbreviations and acronyms</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">clause</span>
                   <semx element="autonum" source="L">4</semx>
                </fmt-xref-label>
                <dl>
                   <colgroup>
                      <col width="20%"/>
                      <col width="80%"/>
                   </colgroup>
                   <dt>Symbol</dt>
                   <dd>Definition</dd>
                </dl>
             </definitions>
             <clause id="M" inline-header="false" obligation="normative" displayorder="13">
                <title id="_">Clause 4</title>
                <fmt-title depth="1" id="_">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="M">5</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Clause 4</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">clause</span>
                   <semx element="autonum" source="M">5</semx>
                </fmt-xref-label>
                <clause id="N" inline-header="false" obligation="normative">
                   <title id="_">Introduction</title>
                   <fmt-title depth="2" id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="M">5</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="N">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Introduction</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">clause</span>
                      <semx element="autonum" source="M">5</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="N">1</semx>
                   </fmt-xref-label>
                </clause>
                <clause id="O" inline-header="false" obligation="normative">
                   <title id="_">Clause 4.2</title>
                   <fmt-title depth="2" id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="M">5</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="O">2</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Clause 4.2</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">clause</span>
                      <semx element="autonum" source="M">5</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="O">2</semx>
                   </fmt-xref-label>
                </clause>
             </clause>
             <references id="R" obligation="informative" normative="true" displayorder="10">
                <title id="_">References</title>
                <fmt-title depth="1" id="_">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="R">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">References</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">clause</span>
                   <semx element="autonum" source="R">2</semx>
                </fmt-xref-label>
             </references>
          </sections>
          <annex id="P" inline-header="false" obligation="normative" autonum="A" displayorder="14">
           <title id="_">Annex</title>
             <fmt-title id="_">
                <strong>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="P">A</semx>
                   </span>
                </strong>
                <span class="fmt-caption-delim">
                   <br/>
                   <br/>
                </span>
                <semx element="title" source="_">
                   <strong>Annex</strong>
                </semx>
             </fmt-title>
             <fmt-xref-label>
                <span class="fmt-element-name">Annex</span>
                <semx element="autonum" source="P">A</semx>
             </fmt-xref-label>
             <p class="annex_obligation">
                <span class="fmt-obligation">(This annex forms an integral part of this Recommendation.)</span>
                </p>
      <variant-title type="toc">
         <span class="fmt-caption-label">
            <span class="fmt-element-name">Annex</span>
            <semx element="autonum" source="P">A</semx>
         </span>
         <span class="fmt-caption-delim">
            <tab/>
         </span>
         <semx element="title" source="_">Annex</semx>
      </variant-title>
             <clause id="Q" inline-header="false" obligation="normative">
                <title id="_">Annex A.1</title>
                <fmt-title depth="2" id="_">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="P">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Annex A.1</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">clause</span>
                   <semx element="autonum" source="P">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Q">1</semx>
                </fmt-xref-label>
                <clause id="Q1" inline-header="false" obligation="normative">
                   <title id="_">Annex A.1a</title>
                   <fmt-title depth="3" id="_">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="P">A</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="Q">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="Q1">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Annex A.1a</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">clause</span>
                      <semx element="autonum" source="P">A</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="Q1">1</semx>
                   </fmt-xref-label>
                </clause>
             </clause>
          </annex>
          <bibliography>
             <clause id="S" obligation="informative" displayorder="15">
                <title id="_">Bibliography</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Bibliography</semx>
                </fmt-title>
                <references id="T" obligation="informative" normative="false">
                   <title id="_">Bibliography Subsection</title>
                   <fmt-title depth="2" id="_">
                      <semx element="title" source="_">Bibliography Subsection</semx>
                   </fmt-title>
                </references>
             </clause>
          </bibliography>
       </metanorma>
    OUTPUT

    html = <<~OUTPUT
       #{HTML_HDR}
                 <br/>
                 <div id="_">
           <h1 class="AbstractTitle">Abstract</h1>
           <p>This is an abstract</p>
         </div>
            <div class="Keyword" id="_">
        <h1 class="IntroTitle">Keywords</h1>
        <p>A, B.</p>
      </div>
                      <div id="_">
                          <h1 class="IntroTitle">Foreword</h1>
                          <p id="A">This is a preamble</p>
                        </div>
                        <div id="B">
                          <h1 class="IntroTitle">Introduction</h1>
                          <div id="C">
                   <h2>Introduction Subsection</h2>
                 </div>
                        </div>
         <div id="A0">
           <h1 class="IntroTitle">History</h1>
           <p>history</p>
         </div>
                        <p class="zzSTDTitle1">Recommendation 12345</p>
                        <p class="zzSTDTitle2">An ITU Standard</p>
                        <div id="D">
                          <h1>1.&#160; Scope</h1>
                          <p id="E">Text</p>
                        </div>
                        <div>
                          <h1>2.&#160; References</h1>
                          <table class='biblio' border='0'>
           <tbody/>
         </table>
                        </div>
                        <div id="I">
                        <h1>3.</h1>
                        <div id="J"><p class="TermNum" id="J"><b>3.1.&#160; <b><dfn>Term2</dfn></b>:</b></p>
                 </div>
                      </div>
                        <div id="L" class="Symbols">
                        <h1>4.  Abbreviations and acronyms</h1>
                                <table class="dl" style="table-layout:fixed;">
        <colgroup>
          <col style="width: 20%;"/>
          <col style="width: 80%;"/>
        </colgroup>
                            <tbody>
                              <tr>
                                <th style="font-weight:bold;" scope="row">Symbol</th>
                                <td style="">Definition</td>
                              </tr>
                            </tbody>
                          </table>
                        </div>
                        <div id="M">
                          <h1>5.&#160; Clause 4</h1>
                          <div id="N">
                   <h2>5.1.&#160; Introduction</h2>
                 </div>
                          <div id="O">
                   <h2>5.2.&#160; Clause 4.2</h2>
                 </div>
                        </div>
                        <br/>
                        <div id="P" class="Section3">
                          <h1 class="Annex"><b>Annex A</b> <br/><br/><b>Annex</b></h1>
                          <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
                          <p style="display:none;" class="variant-title-toc">Annex A  Annex</p>
                          <div id="Q">
                   <h2>A.1.&#160; Annex A.1</h2>
                   <div id="Q1">
                   <h3>A.1.1.&#160; Annex A.1a</h3>
                   </div>
                 </div>
                        </div>
                        <br/>
                        <div>
                          <h1 class="Section3">Bibliography</h1>
                          <table class='biblio' border='0'>
           <tbody/>
         </table>
                          <div>
                            <h2 class="Section3">Bibliography Subsection</h2>
                            <table class='biblio' border='0'>
           <tbody/>
         </table>
                          </div>
                        </div>
                      </div>
                    </body>
    OUTPUT

    word = <<~OUTPUT
         <body lang="EN-US" link="blue" vlink="#954F72">
         <div class="WordSection1">
           <p>&#160;</p>
         </div>
         <p class="section-break">
           <br clear="all" class="section"/>
         </p>
         <div class="WordSection2">
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
         <div class='Abstract' id="_">
             <h1 class="AbstractTitle">Summary</h1>
             <p>This is an abstract</p>
           </div>
           <div class='Keyword' id="_">
             <h1 class="IntroTitle">Keywords</h1>
             <p>A, B.</p>
           </div>
           <div id="_">
             <h1 class="IntroTitle">Foreword</h1>
             <p id="A">This is a preamble</p>
           </div>
           <div id="B">
             <h1 class="IntroTitle">Introduction</h1>
             <div id="C"><h2>Introduction Subsection</h2>
      </div>
      </div>
           <div id="A0">
              <h1 class="IntroTitle">History</h1>
              <p>history</p>
            </div>
           <p>&#160;</p>
         </div>
         <p class="section-break">
           <br clear="all" class="section"/>
         </p>
         <div class="WordSection3">
           <p class="zzSTDTitle1">Recommendation 12345</p>
           <p class="zzSTDTitle2">An ITU Standard</p>
           <div id="D">
             <h1>1.<span style="mso-tab-count:1">&#160; </span>Scope</h1>
             <p id="E">Text</p>
          </div>
           <div>
             <h1>2.<span style="mso-tab-count:1">&#160; </span>References</h1>
              <table class='biblio' border='0'>
              <tbody/>
            </table>
           </div>
           <div id="I"><h1>3.</h1>
        <div id="J"><p class="TermNum" id="J"><b>3.1.<span style="mso-tab-count:1">&#160; </span><b>Term2</b>:</b> </p>
      </div>
      </div>
           <div id="L" class="Symbols">
           <h1>
            4.
            <span style="mso-tab-count:1">  </span>
            Abbreviations and acronyms
         </h1>

                   <div align="center" class="table_container">
        <table class="dl" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;">
          <colgroup>
           <col width="20%"/>
           <col width="80%"/>
         </colgroup>
          <tbody>
            <tr>
              <th valign="top" style="font-weight:bold;page-break-after:auto;">Symbol</th>
              <td valign="top" style="page-break-after:auto;">Definition</td>
            </tr>
          </tbody>
        </table>
      </div>
           </div>
           <div id="M">
             <h1>5.<span style="mso-tab-count:1">&#160; </span>Clause 4</h1>
             <div id="N"><h2>5.1.<span style="mso-tab-count:1">&#160; </span>Introduction</h2>
      </div>
             <div id="O"><h2>5.2.<span style="mso-tab-count:1">&#160; </span>Clause 4.2</h2>
      </div>
           </div>
           <p class="page-break">
             <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
           </p>
           <div id="P" class="Section3">
             <h1 class="Annex"><b>Annex A</b> <br/><br/><b>Annex</b></h1>
              <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
         <p style="display:none;" class="variant-title-toc">
            Annex A
            <span style="mso-tab-count:1">  </span>
            Annex
         </p>
             <div id="Q"><h2>A.1.<span style="mso-tab-count:1">&#160; </span>Annex A.1</h2>
        <div id="Q1"><h3>A.1.1.<span style="mso-tab-count:1">&#160; </span>Annex A.1a</h3>
        </div>
      </div>
           </div>
           <p class="page-break">
             <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
           </p>
           <div>
             <h1 class="Section3">Bibliography</h1>
             <table class='biblio' border='0'>
              <tbody/>
            </table>
             <div>
               <h2 class="Section3">Bibliography Subsection</h2>
               <table class='biblio' border='0'>
              <tbody/>
            </table>
             </div>
           </div>
         </div>
       </body>
    OUTPUT
    pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", itudoc("en"), true)
    expect(strip_guid(pres_output
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_xml_equivalent_to presxml
    expect(strip_guid(IsoDoc::Itu::HtmlConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_xml_equivalent_to html
    expect(strip_guid(IsoDoc::Itu::WordConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_html4_equivalent_to word
  end

  it "post-processes section names (Word)" do
    FileUtils.rm_f "test.doc"
    IsoDoc::Itu::WordConvert.new({}).convert("test", <<~INPUT, false)
      <metanorma xmlns="http://riboseinc.com/isoxml">
                     <bibdata type="standard">
                     <title language="en" format="text/plain" type="main">An ITU Standard</title>
                     <docidentifier type="ITU">12345</docidentifier>
                     <language>en</language>
                     <keyword>A</keyword>
                     <keyword>B</keyword>
                     <ext>
                     <doctype>recommendation</doctype>
                     </ext>
                     </bibdata>
            <preface/>
             <sections>
             <clause id="D" obligation="normative" type="scope" displayorder="1">
               <fmt-title id="_">1<tab/>Scope</fmt-title>
               <p id="E">Text</p>
               <figure id="fig-f1-1">
        <fmt-name id="_">Static aspects of SDL‑2010</fmt-name>
        </figure>
        <p>Hello</p>
        <figure id="fig-f1-2">
        <fmt-name id="_">Static aspects of SDL‑2010</fmt-name>
        </figure>
        <note><p>Hello</p></note>
             </clause>
             </sections>
              <annex id="P" inline-header="false" obligation="normative" displayorder="2">
               <fmt-title id="_"><strong>Annex A</strong><br/><br/><strong>Annex 1</strong></fmt-title>
               <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
               <clause id="Q" inline-header="false" obligation="normative">
               <fmt-title id="_">A.1<tab/>Annex A.1</fmt-title>
               <p>Hello</p>
               </clause>
             </annex>
                 <annex id="P1" inline-header="false" obligation="normative" displayorder="3">
               <fmt-title id="_"><strong>Annex B</strong><br/><br/><strong>Annex 2</strong></fmt-title>
               <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
               <p>Hello</p>
               <clause id="Q1" inline-header="false" obligation="normative">
               <fmt-title id="_">B.1<tab/>Annex A1.1</fmt-title>
               <p>Hello</p>
               </clause>
               </clause>
             </annex>
             </metanorma>
    INPUT
    expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc", encoding: "UTF-8")
    expect(html
      .sub(%r{^.*<div class="WordSection3">}m, %{<body><div class="WordSection3">})
      .gsub(%r{</body>.*$}m, "</body>"))
      .to be_xml_equivalent_to <<~OUTPUT
        <body><div class="WordSection3">
              <div><a name="D" id="D"></a>
                <h1>1<span style="mso-tab-count:1">&#xA0; </span>Scope</h1>
                <p class="MsoNormal"><a name="E" id="E"></a>Text</p>
                <div class="figure"><a name="fig-f1-1" id="fig-f1-1"></a>
          <p class="FigureTitle" style="text-align:center;">Static aspects of SDL&#x2011;2010</p></div>
                <p class="Normalaftertitle">Hello</p>
                <div class="figure"><a name="fig-f1-2" id="fig-f1-2"></a>
          <p class="FigureTitle" style="text-align:center;">Static aspects of SDL&#x2011;2010</p></div>
                <div class="Note">
                  <p class="Note">Hello</p>
                </div>
              </div>
              <p class="MsoNormal">
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
              </p>
              <div class="Section3"><a name="P" id="P"></a>
                <h1 class="Annex"><b>Annex A</b> <br/><br/><b>Annex 1</b></h1>
                <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
                <div><a name="Q" id="Q"></a><h2>A.1<span style="mso-tab-count:1">&#xA0; </span>Annex A.1</h2>
                 <p class="MsoNormal">Hello</p>
                 </div>
              </div>
              <p class="MsoNormal">
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
              </p>
              <div class="Section3"><a name="P1" id="P1"></a>
                <h1 class="Annex"><b>Annex B</b> <br/><br/><b>Annex 2</b></h1>
                <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
                <p class="Normalaftertitle">Hello</p>
                <div><a name="Q1" id="Q1"></a><h2>B.1<span style="mso-tab-count:1">&#xA0; </span>Annex A1.1</h2>
                 <p class="MsoNormal">Hello</p>
                 </div>
              </div>
            </div>
          <div style="mso-element:footnote-list"/></body>
      OUTPUT
  end

  it "processes annex with supplied annexid" do
    FileUtils.rm_f "test.html"
    FileUtils.rm_f "test.doc"
    input = <<~INPUT
             <metanorma xmlns="http://riboseinc.com/isoxml">
             <bibdata type="standard">
             <title language="en" format="text/plain" type="main">An ITU Standard</title>
             <title language="en" format="text/plain" type="subtitle">Subtitle</title>
             <docidentifier type="ITU">12345</docidentifier>
             <language>en</language>
             <keyword>A</keyword>
             <keyword>B</keyword>
             <ext>
             <doctype>recommendation-annex</doctype>
             <structuredidentifier>
             <annexid>F2</annexid>
             </structuredidentifier>
             </ext>
             </bibdata>
             <sections><clause/></sections>
      <annex id="A1" obligation="normative">
              <title>Annex</title>
              <clause id="A2"><title>Subtitle</title>
              <table id="T"/>
              <figure id="U"/>
              <formula id="V"><stem type="AsciiMath">r = 1 %</stem></formula>
              </clause>
      </annex>
      </metanorma>
    INPUT

    presxml = <<~OUTPUT
      <metanorma xmlns="http://riboseinc.com/isoxml" type="presentation">
           <bibdata type="standard">
              <title language="en" format="text/plain" type="main">An ITU Standard</title>
              <title language="en" format="text/plain" type="subtitle">Subtitle</title>
              <docidentifier type="ITU">12345</docidentifier>
              <language current="true">en</language>
              <keyword>A</keyword>
              <keyword>B</keyword>
              <ext>
                 <doctype language="">recommendation-annex</doctype>
                 <doctype language="en">Recommendation Annex</doctype>
                 <structuredidentifier>
                    <annexid>F2</annexid>
                 </structuredidentifier>
              </ext>
           </bibdata>
           <preface>
              <clause type="keyword" displayorder="1" id="_">
                 <fmt-title id="_" depth="1">Keywords</fmt-title>
                 <p>A, B.</p>
              </clause>
              <clause type="toc" id="_" displayorder="2">
                 <fmt-title id="_" depth="1">Table of Contents</fmt-title>
              </clause>
           </preface>
           <sections>
              <p class="zzSTDTitle1" displayorder="3">Recommendation 12345</p>
              <p class="zzSTDTitle2" displayorder="4">An ITU Standard</p>
              <p class="zzSTDTitle3" displayorder="5">Subtitle</p>
       <clause id="_" displayorder="6">
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
           <annex id="A1" obligation="normative" autonum="F2" displayorder="7">
              <title id="_">Annex</title>
              <fmt-title id="_">
                 <strong>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Annex</span>
                       <semx element="autonum" source="A1">F2</semx>
                    </span>
                 </strong>
                 <span class="fmt-caption-delim">
                    <br/>
                    <br/>
                 </span>
                 <semx element="title" source="_">
                    <strong>Annex</strong>
                 </semx>
              </fmt-title>
              <fmt-xref-label>
                 <span class="fmt-element-name">Annex</span>
                 <semx element="autonum" source="A1">F2</semx>
              </fmt-xref-label>
              <p class="annex_obligation">
                 <span class="fmt-obligation">(This annex forms an integral part of this Recommendation Annex.)</span>
              </p>
      <variant-title type="toc">
         <span class="fmt-caption-label">
            <span class="fmt-element-name">Annex</span>
            <semx element="autonum" source="A1">F2</semx>
         </span>
         <span class="fmt-caption-delim">
            <tab/>
         </span>
         <semx element="title" source="_">Annex</semx>
      </variant-title>
              <clause id="A2">
                 <title id="_">Subtitle</title>
                 <fmt-title id="_" depth="2">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="A1">F2</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="A2">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">Subtitle</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">clause</span>
                    <semx element="autonum" source="A1">F2</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="A2">1</semx>
                 </fmt-xref-label>
                 <table id="T" autonum="F2.1">
                    <fmt-name id="_">
                       <span class="fmt-caption-label">
                          <span class="fmt-element-name">Table</span>
                          <semx element="autonum" source="A1">F2</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="T">1</semx>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <span class="fmt-element-name">Table</span>
                       <semx element="autonum" source="A1">F2</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="T">1</semx>
                    </fmt-xref-label>
                 </table>
                 <figure id="U" autonum="F2.1">
                    <fmt-name id="_">
                       <span class="fmt-caption-label">
                          <span class="fmt-element-name">Figure</span>
                          <semx element="autonum" source="A1">F2</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="U">1</semx>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <span class="fmt-element-name">Figure</span>
                       <semx element="autonum" source="A1">F2</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="U">1</semx>
                    </fmt-xref-label>
                 </figure>
                 <formula id="V" autonum="F2-1">
                    <fmt-name id="_">
                       <span class="fmt-caption-label">
                          <span class="fmt-autonum-delim">(</span>
                          <semx element="autonum" source="A1">F2</semx>
                          <span class="fmt-autonum-delim">-</span>
                          <semx element="autonum" source="V">1</semx>
                          <span class="fmt-autonum-delim">)</span>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <span class="fmt-element-name">Equation</span>
                       <span class="fmt-autonum-delim">(</span>
                       <semx element="autonum" source="A1">F2</semx>
                       <span class="fmt-autonum-delim">-</span>
                       <semx element="autonum" source="V">1</semx>
                       <span class="fmt-autonum-delim">)</span>
                    </fmt-xref-label>
            <stem type="AsciiMath" id="_">r = 1 %</stem>
            <fmt-stem type="AsciiMath">
               <semx element="stem" source="_">r = 1 %</semx>
            </fmt-stem>
                 </formula>
              </clause>
           </annex>
        </metanorma>
    OUTPUT
    pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(pres_output
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_xml_equivalent_to presxml
    IsoDoc::Itu::HtmlConvert.new({}).convert("test", pres_output, false)
    html = File.read("test.html", encoding: "utf-8")
      output = <<~OUTPUT
            <main class='main-section'>
                 <button onclick='topFunction()' id='myBtn' title='Go to top'>Top</button>
                    <div id="_" class="Keyword">
              <h1 class="IntroTitle" id="_">
                <a class="anchor" href="#_"/>
                <a class="header" href="#_">Keywords</a>
              </h1>
                    <p>A, B.</p>
                </div>
                 <br/>
                 <p class='zzSTDTitle1'>Recommendation 12345</p>
                 <p class='zzSTDTitle2'>An ITU Standard</p>
                 <p class='zzSTDTitle3'>Subtitle</p>
                  <div id="_">
                     <h1 id="_">
                        <a class="anchor" href="#_"/>
                        <a class="header" href="#_">1.</a>
                     </h1>
                  </div>
                 <div id='A1' class='Section3'>
                   <p class='h1Annex'>
                     <b>Annex F2</b>
                     <br/>
                     <br/>
                     <b>Annex</b>
                   </p>
                   <p class='annex_obligation'>(This annex forms an integral part of this Recommendation Annex.)</p>
                   <p style="display:none;" class="variant-title-toc">Annex F2  Annex</p>
                   <div id='A2'>
                     <h2 id='_'><a class="anchor" href="#A2"/><a class="header" href="#A2">F2.1.&#xA0; Subtitle</a></h2>
                     <table id='T' class='MsoISOTable' style='border-width:1px;border-spacing:0;'>
                     <caption>Table F2.1</caption>
                     </table>
                     <figure id='U' class='figure'>
          <figcaption>Figure F2.1</figcaption>
        </figure>
                     <div id='V'><div class='formula'>
                       <p>
                         <span class='stem'>(#(r = 1 %)#)</span>
                         &#xA0; (F2-1)
                       </p>
                     </div>
                     </div>
                   </div>
                 </div>
               </main>
      OUTPUT
          expect(strip_guid(html.gsub(%r{^.*<main}m, "<main")
      .gsub(%r{</main>.*}m, "</main>")))
      .to be_xml_equivalent_to output

    IsoDoc::Itu::WordConvert.new({}).convert("test", pres_output, false)
    html = File.read("test.doc", encoding: "utf-8")
    output = <<~OUTPUT
        <div class='WordSection3' xmlns:m='http://schemas.microsoft.com/office/2004/12/omml'>
              <p class='zzSTDTitle1'>Recommendation 12345</p>
              <p class='zzSTDTitle2'>An ITU Standard</p>
              <p class='zzSTDTitle3'>Subtitle</p>
                <div>
                  <a name="_" id="_"/>
                  <h1>1.</h1>
                  </div>
              <div class='Section3'>
                <a name='A1' id='A1'/>
                <p class='h1Annex'>
                  <b>Annex F2</b>
                  <br/>
                  <br/>
                  <b>Annex</b>
                </p>
                <p class='annex_obligation'>(This annex forms an integral part of this Recommendation Annex.)</p>
                <p style="display:none;" class="variant-title-toc">
                    Annex F2
                    <span style="mso-tab-count:1">  </span>
                    Annex
                  </p>
                <div>
                  <a name='A2' id='A2'/>
                  <h2>
                    F2.1.
                    <span style='mso-tab-count:1'>&#xA0; </span>
                    Subtitle
                  </h2>
                 <p class='TableTitle' style='text-align:center;'>Table F2.1</p>
                  <div align='center' class='table_container'>
                    <table class='MsoISOTable' style='mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;'>
                      <a name='T' id='T'/>
                    </table>
                  </div>
                  <div class='figure'>
                    <a name='U' id='U'/>
                    <p class='FigureTitle' style='text-align:center;'>Figure F2.1</p>
                  </div>
                  <div>
                    <a name='V' id='V'/>
                    <div class='formula'>
                      <p class='formula'>
                        <span style='mso-tab-count:1'>&#xA0; </span>
                        <span class="stem">(#(r = 1 %)#)</span>
                        <span style='mso-tab-count:1'>&#xA0; </span>
                        (F2-1)
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
      OUTPUT
      expect(strip_guid(html
 .gsub(%r{^.*<div class="WordSection3">}m, '<div class="WordSection3" xmlns:m="http://schemas.microsoft.com/office/2004/12/omml">')
 .gsub(%r{<div style="mso-element:footnote-list"/>.*}m, "")))
      .to be_xml_equivalent_to output
  end

  it "processes unnumbered clauses" do
    input = <<~INPUT
             <metanorma xmlns="http://riboseinc.com/isoxml">
             <bibdata type="standard">
             <title language="en" format="text/plain" type="main">An ITU Standard</title>
             <title language="en" format="text/plain" type="subtitle">Subtitle</title>
             <docidentifier type="ITU">12345</docidentifier>
             <language>en</language>
             <ext>
             <doctype>resolution</doctype>
             <structuredidentifier>
             <annexid>F2</annexid>
             </structuredidentifier>
             </ext>
             </bibdata>
      <sections>
      <clause unnumbered="true" id="A"><p>Text</p></clause>
      <clause id="B"><title>First Clause</title></clause>
      </sections>
      </metanorma>
    INPUT
    presxml = <<~OUTPUT
        <metanorma xmlns="http://riboseinc.com/isoxml" type="presentation">
           <bibdata type="standard">
              <title language="en" format="text/plain" type="main">An ITU Standard</title>
              <title language="en" format="text/plain" type="resolution">RESOLUTION  (, )</title>
              <title language="en" format="text/plain" type="resolution-placedate">, </title>
              <title language="en" format="text/plain" type="subtitle">Subtitle</title>
              <docidentifier type="ITU">12345</docidentifier>
              <language current="true">en</language>
              <ext>
                 <doctype language="">resolution</doctype>
                 <doctype language="en">Resolution</doctype>
                 <structuredidentifier>
                    <annexid>F2</annexid>
                 </structuredidentifier>
              </ext>
           </bibdata>
           <sections>
              <p class="zzSTDTitle1" align="center" displayorder="1">RESOLUTION  (, )</p>
              <p class="zzSTDTitle2" displayorder="2">An ITU Standard</p>
              <p align="center" class="zzSTDTitle2" displayorder="3">
                 <em>(, )</em>
              </p>
              <clause unnumbered="true" id="A" displayorder="4">
                 <p>Text</p>
              </clause>
              <p keep-with-next="true" class="supertitle" displayorder="5">
                 <span class="fmt-element-name">SECTION</span>
                 <semx element="autonum" source="B">1</semx>
              </p>
              <clause id="B" displayorder="6">
                 <title id="_">First Clause</title>
                 <fmt-title id="_" depth="1">
                       <semx element="title" source="_">First Clause</semx>
                 </fmt-title>
              </clause>
           </sections>
        </metanorma>
    OUTPUT
    expect(strip_guid(IsoDoc::Itu::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_xml_equivalent_to presxml
  end

  it "processes bis, ter etc clauses" do
    input = <<~INPUT
                     <metanorma xmlns="http://riboseinc.com/isoxml">
                     <bibdata type="standard">
                     <title language="en" format="text/plain" type="main">An ITU Standard</title>
                     <title language="en" format="text/plain" type="subtitle">Subtitle</title>
                     <docidentifier type="ITU">12345</docidentifier>
                     <language>en</language>
                     <ext>
                     <doctype>resolution</doctype>
                     <structuredidentifier>
                     <annexid>F2</annexid>
                     </structuredidentifier>
                     </ext>
                     </bibdata>
              <sections>
              <clause id="A">
      <p><xref target="B"/>, <xref target="C"/>, <xref target="D"/>, <xref target="E"/></p>
              </clause>
              <clause id="B" number="1bis"><title>First Clause</title></clause>
              <clause id="C" number="10ter"><title>Second Clause</title>
              <clause id="D" number="10quater"><title>Second Clause Subclause</title></clause>
      </clause>
              <clause id="E" number="10bit"><title>Non-Clause</title></clause>
              </sections>
              </metanorma>
    INPUT
    presxml = <<~OUTPUT
        <metanorma xmlns="http://riboseinc.com/isoxml" type="presentation">
           <bibdata type="standard">
              <title language="en" format="text/plain" type="main">An ITU Standard</title>
              <title language="en" format="text/plain" type="resolution">RESOLUTION  (, )</title>
              <title language="en" format="text/plain" type="resolution-placedate">, </title>
              <title language="en" format="text/plain" type="subtitle">Subtitle</title>
              <docidentifier type="ITU">12345</docidentifier>
              <language current="true">en</language>
              <ext>
                 <doctype language="">resolution</doctype>
                 <doctype language="en">Resolution</doctype>
                 <structuredidentifier>
                    <annexid>F2</annexid>
                 </structuredidentifier>
              </ext>
           </bibdata>
           <sections>
              <p class="zzSTDTitle1" align="center" displayorder="1">RESOLUTION  (, )</p>
              <p class="zzSTDTitle2" displayorder="2">An ITU Standard</p>
              <p align="center" class="zzSTDTitle2" displayorder="3">
                 <em>(, )</em>
              </p>
              <p keep-with-next="true" class="supertitle" displayorder="4">
                 <span class="fmt-element-name">SECTION</span>
                 <semx element="autonum" source="A">1</semx>
              </p>
              <clause id="A" displayorder="5">
                 <p>
                    <xref target="B" id="_"/>
                    <semx element="xref" source="_">
                       <fmt-xref target="B">
                          <span class="fmt-element-name">Section</span>
                          <semx element="autonum" source="B">
                             1
                             <em>bis</em>
                          </semx>
                       </fmt-xref>
                    </semx>
                    ,
                    <xref target="C" id="_"/>
                    <semx element="xref" source="_">
                       <fmt-xref target="C">
                          <span class="fmt-element-name">Section</span>
                          <semx element="autonum" source="C">
                             10
                             <em>ter</em>
                          </semx>
                       </fmt-xref>
                    </semx>
                    ,
                    <xref target="D" id="_"/>
                    <semx element="xref" source="_">
                       <fmt-xref target="D">
                          <semx element="autonum" source="C">
                             10
                             <em>ter</em>
                          </semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="D">
                             10
                             <em>quater</em>
                          </semx>
                       </fmt-xref>
                    </semx>
                    ,
                    <xref target="E" id="_"/>
                    <semx element="xref" source="_">
                       <fmt-xref target="E">
                          <span class="fmt-element-name">Section</span>
                          <semx element="autonum" source="E">10bit</semx>
                       </fmt-xref>
                    </semx>
                 </p>
              </clause>
              <p keep-with-next="true" class="supertitle" displayorder="6">
                 <span class="fmt-element-name">SECTION</span>
                 <semx element="autonum" source="B">
                    1
                    <em>bis</em>
                 </semx>
              </p>
              <clause id="B" number="1bis" displayorder="7">
                 <title id="_">First Clause</title>
                 <fmt-title id="_" depth="1">
                    <semx element="title" source="_">First Clause</semx>
                 </fmt-title>
              </clause>
              <p keep-with-next="true" class="supertitle" displayorder="8">
                 <span class="fmt-element-name">SECTION</span>
                 <semx element="autonum" source="C">
                    10
                    <em>ter</em>
                 </semx>
              </p>
              <clause id="C" number="10ter" displayorder="9">
                 <title id="_">Second Clause</title>
                 <fmt-title id="_" depth="1">
                    <semx element="title" source="_">Second Clause</semx>
                 </fmt-title>
                 <clause id="D" number="10quater">
                    <title id="_">Second Clause Subclause</title>
                    <fmt-title id="_" depth="2">
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="C">
                             10
                             <em>ter</em>
                          </semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="D">
                             10
                             <em>quater</em>
                          </semx>
                          <span class="fmt-autonum-delim">.</span>
                       </span>
                       <span class="fmt-caption-delim">
                          <tab/>
                       </span>
                       <semx element="title" source="_">Second Clause Subclause</semx>
                    </fmt-title>
                    <fmt-xref-label>
                       <semx element="autonum" source="C">
                          10
                          <em>ter</em>
                       </semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="D">
                          10
                          <em>quater</em>
                       </semx>
                    </fmt-xref-label>
                 </clause>
              </clause>
              <p keep-with-next="true" class="supertitle" displayorder="10">
                 <span class="fmt-element-name">SECTION</span>
                 <semx element="autonum" source="E">10bit</semx>
              </p>
              <clause id="E" number="10bit" displayorder="11">
                 <title id="_">Non-Clause</title>
                 <fmt-title id="_" depth="1">
                    <semx element="title" source="_">Non-Clause</semx>
                 </fmt-title>
              </clause>
           </sections>
        </metanorma>
    OUTPUT
    expect(strip_guid(IsoDoc::Itu::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_xml_equivalent_to presxml
  end
end

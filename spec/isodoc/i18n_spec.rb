require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Itu do
  it "processes section names in French" do
    presxml = <<~OUTPUT
      <metanorma xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata type="standard">
             <title language="en" format="text/plain" type="main">An ITU Standard</title>
             <title language="fr" format="text/plain" type="main">Un Standard ITU</title>
             <docidentifier type="ITU">12345</docidentifier>
             <language current="true">fr</language>
             <script current="true">Latn</script>
             <keyword>A</keyword>
             <keyword>B</keyword>
             <ext>
                <doctype language="">recommendation</doctype>
                <doctype language="fr">Recommandation</doctype>
                <flavor>itu</flavor>
             </ext>
          </bibdata>
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">Table des matières</fmt-title>
             </clause>
             <abstract displayorder="2">
                <title id="_">Abstract</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Abstract</semx>
                </fmt-title>
                <p>This is an abstract</p>
             </abstract>
             <clause type="keyword" displayorder="3">
                <fmt-title depth="1">Mots clés</fmt-title>
                <p>A, B.</p>
             </clause>
             <foreword obligation="informative" displayorder="4">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <p id="A">This is a preamble</p>
             </foreword>
             <introduction id="B" obligation="informative" displayorder="5">
                <title id="_">Introduction</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Introduction</semx>
                </fmt-title>
                <clause id="C" inline-header="false" obligation="informative">
                   <title id="_">Introduction Subsection</title>
                   <fmt-title depth="2">
                      <semx element="title" source="_">Introduction Subsection</semx>
                   </fmt-title>
                </clause>
             </introduction>
             <clause id="A0" displayorder="6">
                <title id="_">History</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">History</semx>
                </fmt-title>
                <p>history</p>
             </clause>
          </preface>
          <sections>
             <p class="zzSTDTitle1" displayorder="7">Projet de nouvelle Recommendation 12345</p>
             <p class="zzSTDTitle2" displayorder="8">Un Standard ITU</p>
             <clause id="D" obligation="normative" type="scope" displayorder="9">
                <title id="_">Scope</title>
                <fmt-title depth="1">
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
                   <span class="fmt-element-name">article</span>
                   <semx element="autonum" source="D">1</semx>
                </fmt-xref-label>
                <p id="E">Text</p>
             </clause>
             <terms id="I" obligation="normative" displayorder="11">
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="I">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">article</span>
                   <semx element="autonum" source="I">3</semx>
                </fmt-xref-label>
                <term id="J">
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="I">3</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="J">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">article</span>
                      <semx element="autonum" source="I">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="J">1</semx>
                   </fmt-xref-label>
            <preferred id="_">
               <expression>
                  <name>Term2</name>
               </expression>
            </preferred>
            <fmt-preferred>
               <semx element="preferred" source="_">
                  <strong>Term2</strong> :
               </semx>
            </fmt-preferred>
                </term>
             </terms>
             <definitions id="L" displayorder="12">
                <title id="_">Abréviations et acronymes</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="L">4</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Abréviations et acronymes</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">article</span>
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
                <fmt-title depth="1">
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
                   <span class="fmt-element-name">article</span>
                   <semx element="autonum" source="M">5</semx>
                </fmt-xref-label>
                <clause id="N" inline-header="false" obligation="normative">
                   <title id="_">Introduction</title>
                   <fmt-title depth="2">
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
                      <span class="fmt-element-name">article</span>
                      <semx element="autonum" source="M">5</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="N">1</semx>
                   </fmt-xref-label>
                </clause>
                <clause id="O" inline-header="false" obligation="normative">
                   <title id="_">Clause 4.2</title>
                   <fmt-title depth="2">
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
                      <span class="fmt-element-name">article</span>
                      <semx element="autonum" source="M">5</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="O">2</semx>
                   </fmt-xref-label>
                </clause>
             </clause>
             <references id="R" obligation="informative" normative="true" displayorder="10">
                <title id="_">References</title>
                <fmt-title depth="1">
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
                   <span class="fmt-element-name">article</span>
                   <semx element="autonum" source="R">2</semx>
                </fmt-xref-label>
             </references>
          </sections>
          <annex id="P" inline-header="false" obligation="normative" autonum="A" displayorder="14">
             <title id="_">
                <strong>Annex</strong>
             </title>
             <fmt-title>
                <strong>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Annexe</span>
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
                <span class="fmt-element-name">Annexe</span>
                <semx element="autonum" source="P">A</semx>
             </fmt-xref-label>
             <p class="annex_obligation">
                <span class="fmt-obligation">(Cette annexe fait partie intégrante de ce Recommandation.)</span>
             </p>
             <clause id="Q" inline-header="false" obligation="normative">
                <title id="_">Annex A.1</title>
                <fmt-title depth="2">
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
                   <span class="fmt-element-name">article</span>
                   <semx element="autonum" source="P">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Q">1</semx>
                </fmt-xref-label>
                <clause id="Q1" inline-header="false" obligation="normative">
                   <title id="_">Annex A.1a</title>
                   <fmt-title depth="3">
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
                      <span class="fmt-element-name">article</span>
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
                <fmt-title depth="1">
                   <semx element="title" source="_">Bibliography</semx>
                </fmt-title>
                <references id="T" obligation="informative" normative="false">
                   <title id="_">Bibliography Subsection</title>
                   <fmt-title depth="2">
                      <semx element="title" source="_">Bibliography Subsection</semx>
                   </fmt-title>
                </references>
             </clause>
          </bibliography>
       </metanorma>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR.sub('Table of Contents', 'Table des matières')}
              <br/>
              <div>
        <h1 class="AbstractTitle">Abstract</h1>
        <p>This is an abstract</p>
      </div>
          <div class="Keyword">
      <h1 class="IntroTitle">Mots clés</h1>
      <p>A, B.</p>
      </div>
                   <div>
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
                     <p class="zzSTDTitle1">Projet de nouvelle Recommendation 12345</p>
                     <p class="zzSTDTitle2">Un Standard ITU</p>
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
                     <div id="J"><p class="TermNum" id="J"><b>3.1.&#160; <b>Term2</b> :</b></p>
              </div>
                   </div>
                     <div id="L" class="Symbols">
                        <h1>4.  Abréviations et acronymes</h1>
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
                       <h1 class="Annex"><b>Annexe A</b> <br/><br/><b>Annex</b></h1>
                      <p class="annex_obligation">(Cette annexe fait partie intégrante de ce Recommandation.)</p>
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
    pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", itudoc("fr"), true)
    expect(Xml::C14n.format(strip_guid(pres_output
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::HtmlConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "processes section names in Chinese" do
    presxml = <<~OUTPUT
       <metanorma xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata type="standard">
             <title language="en" format="text/plain" type="main">An ITU Standard</title>
             <title language="fr" format="text/plain" type="main">Un Standard ITU</title>
             <docidentifier type="ITU">12345</docidentifier>
             <language current="true">zh</language>
             <script current="true">Hans</script>
             <keyword>A</keyword>
             <keyword>B</keyword>
             <ext>
                <doctype language="">recommendation</doctype>
                <doctype language="zh">建议书</doctype>
                <flavor>itu</flavor>
             </ext>
          </bibdata>
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1">目　录</fmt-title>
             </clause>
             <abstract displayorder="2">
                <title id="_">Abstract</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Abstract</semx>
                </fmt-title>
                <p>This is an abstract</p>
             </abstract>
             <clause type="keyword" displayorder="3">
                <fmt-title depth="1">关　键　词</fmt-title>
                <p>A, B.</p>
             </clause>
             <foreword obligation="informative" displayorder="4">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <p id="A">This is a preamble</p>
             </foreword>
             <introduction id="B" obligation="informative" displayorder="5">
                <title id="_">Introduction</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Introduction</semx>
                </fmt-title>
                <clause id="C" inline-header="false" obligation="informative">
                   <title id="_">Introduction Subsection</title>
                   <fmt-title depth="2">
                      <semx element="title" source="_">Introduction Subsection</semx>
                   </fmt-title>
                </clause>
             </introduction>
             <clause id="A0" displayorder="6">
                <title id="_">History</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">History</semx>
                </fmt-title>
                <p>history</p>
             </clause>
          </preface>
          <sections>
             <p class="zzSTDTitle1" displayorder="7">新Recommendation草案 12345</p>
             <clause id="D" obligation="normative" type="scope" displayorder="8">
                <title id="_">Scope</title>
                <fmt-title depth="1">
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
                   <span class="fmt-element-name">条款</span>
                   <semx element="autonum" source="D">1</semx>
                </fmt-xref-label>
                <p id="E">Text</p>
             </clause>
             <terms id="I" obligation="normative" displayorder="10">
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="I">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">条款</span>
                   <semx element="autonum" source="I">3</semx>
                </fmt-xref-label>
                <term id="J">
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="I">3</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="J">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">条款</span>
                      <semx element="autonum" source="I">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="J">1</semx>
                   </fmt-xref-label>
            <preferred id="_">
               <expression>
                  <name>Term2</name>
               </expression>
            </preferred>
            <fmt-preferred>
               <semx element="preferred" source="_">
                  <strong>Term2</strong>
                  :
               </semx>
            </fmt-preferred>
                </term>
             </terms>
             <definitions id="L" displayorder="11">
                <title id="_">缩略语与缩写</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="L">4</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">缩略语与缩写</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">条款</span>
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
             <clause id="M" inline-header="false" obligation="normative" displayorder="12">
                <title id="_">Clause 4</title>
                <fmt-title depth="1">
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
                   <span class="fmt-element-name">条款</span>
                   <semx element="autonum" source="M">5</semx>
                </fmt-xref-label>
                <clause id="N" inline-header="false" obligation="normative">
                   <title id="_">Introduction</title>
                   <fmt-title depth="2">
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
                      <span class="fmt-element-name">条款</span>
                      <semx element="autonum" source="M">5</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="N">1</semx>
                   </fmt-xref-label>
                </clause>
                <clause id="O" inline-header="false" obligation="normative">
                   <title id="_">Clause 4.2</title>
                   <fmt-title depth="2">
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
                      <span class="fmt-element-name">条款</span>
                      <semx element="autonum" source="M">5</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="O">2</semx>
                   </fmt-xref-label>
                </clause>
             </clause>
             <references id="R" obligation="informative" normative="true" displayorder="9">
                <title id="_">References</title>
                <fmt-title depth="1">
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
                   <span class="fmt-element-name">条款</span>
                   <semx element="autonum" source="R">2</semx>
                </fmt-xref-label>
             </references>
          </sections>
          <annex id="P" inline-header="false" obligation="normative" autonum="A" displayorder="13">
             <title id="_">
                <strong>Annex</strong>
             </title>
             <fmt-title>
                <strong>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">附件</span>
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
                <span class="fmt-element-name">附件</span>
                <semx element="autonum" source="P">A</semx>
             </fmt-xref-label>
             <p class="annex_obligation">
                <span class="fmt-obligation">（本附件不构成本建议书的不可或缺部分）</span>
             </p>
             <clause id="Q" inline-header="false" obligation="normative">
                <title id="_">Annex A.1</title>
                <fmt-title depth="2">
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
                   <span class="fmt-element-name">条款</span>
                   <semx element="autonum" source="P">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="Q">1</semx>
                </fmt-xref-label>
                <clause id="Q1" inline-header="false" obligation="normative">
                   <title id="_">Annex A.1a</title>
                   <fmt-title depth="3">
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
                      <span class="fmt-element-name">条款</span>
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
             <clause id="S" obligation="informative" displayorder="14">
                <title id="_">Bibliography</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Bibliography</semx>
                </fmt-title>
                <references id="T" obligation="informative" normative="false">
                   <title id="_">Bibliography Subsection</title>
                   <fmt-title depth="2">
                      <semx element="title" source="_">Bibliography Subsection</semx>
                   </fmt-title>
                </references>
             </clause>
          </bibliography>
       </metanorma>
    OUTPUT

    html = <<~OUTPUT
       #{HTML_HDR.sub('Table of Contents', '目　录')}
            <br/>
             <div>
                <h1 class="AbstractTitle">Abstract</h1>
                <p>This is an abstract</p>
             </div>
             <div class="Keyword">
                <h1 class="IntroTitle">关　键　词</h1>
                <p>A, B.</p>
             </div>
             <div>
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
             <p class="zzSTDTitle1">新Recommendation草案 12345</p>
             <div id="D">
                <h1>1.　Scope</h1>
                <p id="E">Text</p>
             </div>
             <div>
                <h1>2.　References</h1>
                <table class="biblio" border="0">
                   <tbody/>
                </table>
             </div>
             <div id="I">
                <h1>3.</h1>
                <div id="J">
                   <p class="TermNum" id="J">
                                  <b>
                  3.1.　
                  <b>Term2</b>
                  :
               </b>
                   </p>
                </div>
             </div>
             <div id="L" class="Symbols">
                <h1>4.　缩略语与缩写</h1>
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
                <h1>5.　Clause 4</h1>
                <div id="N">
                   <h2>5.1.　Introduction</h2>
                </div>
                <div id="O">
                   <h2>5.2.　Clause 4.2</h2>
                </div>
             </div>
             <br/>
             <div id="P" class="Section3">
                <h1 class="Annex">
                   <b>附件A</b>
                   <br/>
                   <br/>
                   <b>Annex</b>
                </h1>
                <p class="annex_obligation">（本附件不构成本建议书的不可或缺部分）</p>
                <div id="Q">
                   <h2>A.1.　Annex A.1</h2>
                   <div id="Q1">
                      <h3>A.1.1.　Annex A.1a</h3>
                   </div>
                </div>
             </div>
             <br/>
             <div>
                <h1 class="Section3">Bibliography</h1>
                <table class="biblio" border="0">
                   <tbody/>
                </table>
                <div>
                   <h2 class="Section3">Bibliography Subsection</h2>
                   <table class="biblio" border="0">
                      <tbody/>
                   </table>
                </div>
             </div>
          </div>
       </body>
    OUTPUT
    pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", itudoc("zh"), true)
    expect(Xml::C14n.format(strip_guid(pres_output
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::HtmlConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "processes editor clauses, two editors in French" do
    FileUtils.rm_f "test.html"
    input = <<~INPUT
      <metanorma xmlns="http://riboseinc.com/isoxml">
      <bibdata type="standard">
      <title language="en" format="text/plain" type="main">An ITU Standard</title>
      <title language="en" format="text/plain" type="subtitle">Subtitle</title>
      <docidentifier type="ITU">12345</docidentifier>
      <contributor><role type="editor"/>
      <person><name><completename>Fred Flintstone</completename></name>
      <affiliation><organization><name>World Health Organization</name></organization></affiliation>
      <email>jack@example.com</email>
      </person>
      </contributor>
      <contributor><role type="editor"/>
      <person><name><forename>Barney</forename> <surname>Rubble</surname></name></person>
      </contributor>
      <language>fr</language>
      <ext>
      <doctype>resolution</doctype>
      <structuredidentifier>
      <annexid>F2</annexid>
      </structuredidentifier>
      </ext>
      </bibdata>
      <sections>
        <clause id="A"><p/></clause>
      </sections>
      </metanorma>
    INPUT
    presxml = <<~OUTPUT
      <preface>
         <clause id='_' type='editors' displayorder='1'>
           <table id='_' unnumbered='true'>
             <tbody>
               <tr>
                 <th>Éditeurs&#xa0;:</th>
                 <td>
                   Fred Flintstone
                   <br/>
                   World Health Organization
                 </td>
                 <td>
                   E-mail&#xa0;:
                   <link target='mailto:jack@example.com'>jack@example.com</link>
                 </td>
               </tr>
               <tr>
                 <th/>
                 <td>Barney Rubble</td>
                 <td/>
               </tr>
             </tbody>
           </table>
         </clause>
       </preface>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::Itu::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
    xml = xml.at("//xmlns:preface").to_xml
    expect(Xml::C14n.format(strip_guid(xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end
end

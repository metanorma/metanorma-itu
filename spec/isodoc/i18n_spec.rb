require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Itu do
  it "processes section names in French" do
    presxml = <<~OUTPUT
      <itu-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
               <bibdata type="standard">
               <title language="en" format="text/plain" type="main">An ITU Standard</title>
               <title language="fr" format="text/plain" type="main">Un Standard ITU</title>
               <docidentifier type="ITU">12345</docidentifier>
               <language current="true">fr</language>
               <script current="true">Latn</script>
               <keyword>A</keyword>
               <keyword>B</keyword>
               <ext>
               <doctype language="">recommendation</doctype><doctype language="fr">Recommandation</doctype>
               <flavor>itu</flavor>
               </ext>
               </bibdata>
      <preface>
          <clause type="toc" id="_" displayorder="1">
      <title depth="1">Table des matières</title>
      </clause>
      <abstract displayorder="2"><title>Abstract</title>
      <p>This is an abstract</p>
      </abstract>
          <clause type="keyword" displayorder="3">
      <title depth="1">Mots clés</title>
      <p>A, B.</p>
      </clause>
      <foreword obligation="informative" displayorder="4">
         <title>Foreword</title>
         <p id="A">This is a preamble</p>
       </foreword>
        <introduction id="B" obligation="informative" displayorder="5">
        <title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title depth="2">Introduction Subsection</title>
       </clause>
       </introduction>
      <clause id="A0" displayorder="6"><title depth="1">History</title>
      <p>history</p>
      </clause>
      </preface><sections>
      <p class="zzSTDTitle1" displayorder="7">Projet de nouvelle Recommendation 12345</p>
      <p class="zzSTDTitle2" displayorder="8">Un Standard ITU</p>
       <clause id="D" obligation="normative" type="scope" displayorder="9">
         <title depth="1">1.<tab/>Scope</title>
         <p id="E">Text</p>
       </clause>
       <terms id="I" obligation="normative" displayorder="11"><title>3.</title>
         <term id="J"><name>3.1.</name>
         <preferred>Term2:</preferred>
       </term>
       </terms>
       <definitions id="L" displayorder="12"><title depth="1">
            4.
            <tab/>
            Abréviations et acronymes
         </title>
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
        <title depth="1">5.<tab/>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
         <title depth="2">5.1.<tab/>Introduction</title>
       </clause>
       <clause id="O" inline-header="false" obligation="normative">
         <title depth="2">5.2.<tab/>Clause 4.2</title>
       </clause></clause>
       <references id="R" obligation="informative" normative="true" displayorder="10">
         <title depth="1">2.<tab/>References</title>
       </references>
       </sections><annex id="P" inline-header="false" obligation="normative" displayorder="14">
         <title><strong>Annexe A</strong><br/><br/><strong>Annex</strong></title>
         <p class="annex_obligation">(Cette annexe fait partie intégrante de ce Recommandation.)</p>
         <clause id="Q" inline-header="false" obligation="normative">
         <title depth="2">A.1.<tab/>Annex A.1</title>
         <clause id="Q1" inline-header="false" obligation="normative">
         <title depth="3">A.1.1.<tab/>Annex A.1a</title>
         </clause>
       </clause>
       </annex><bibliography>
       <clause id="S" obligation="informative" displayorder="15">
         <title depth="1">Bibliography</title>
         <references id="T" obligation="informative" normative="false">
         <title depth="2">Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </itu-standard>
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
                     <div id="J"><p class="TermNum" id="J"><b>3.1.&#160; Term2 :</b></p>
              </div>
                   </div>
                     <div id="L" class="Symbols">
                              <h1>
          4.
       
           Abréviations et acronymes
         </h1>

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
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", itudoc("fr"), true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::HtmlConvert.new({})
      .convert("test", presxml, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "processes section names in Chinese" do
    presxml = <<~OUTPUT
      <itu-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
               <bibdata type="standard">
               <title language="en" format="text/plain" type="main">An ITU Standard</title>
               <title language="fr" format="text/plain" type="main">Un Standard ITU</title>
               <docidentifier type="ITU">12345</docidentifier>
               <language current="true">zh</language>
               <script current="true">Hans</script>
               <keyword>A</keyword>
               <keyword>B</keyword>
               <ext>
               <doctype language="">recommendation</doctype><doctype language="zh">&#x5EFA;&#x8BAE;&#x4E66;</doctype>
               <flavor>itu</flavor>
               </ext>
               </bibdata>
      <preface>
          <clause type="toc" id="_" displayorder="1">
      <title depth="1">目　录</title>
      </clause>
      <abstract displayorder="2"><title>Abstract</title>
      <p>This is an abstract</p>
      </abstract>
          <clause type="keyword" displayorder="3">
      <title depth="1">关　键　词</title>
      <p>A, B.</p>
      </clause>
      <foreword obligation="informative" displayorder="4">
         <title>Foreword</title>
         <p id="A">This is a preamble</p>
       </foreword>
        <introduction id="B" obligation="informative" displayorder="5">
        <title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title depth="2">Introduction Subsection</title>
       </clause>
       </introduction>
      <clause id="A0" displayorder="6"><title depth="1">History</title>
      <p>history</p>
      </clause>
      </preface><sections>
      <p class="zzSTDTitle1" displayorder="7">新Recommendation草案 12345</p>
       <clause id="D" obligation="normative" type="scope" displayorder="8">
         <title depth="1">1.<tab/>Scope</title>
         <p id="E">Text</p>
       </clause>
       <terms id="I" obligation="normative" displayorder="10"><title>3.</title>
         <term id="J"><name>3.1.</name>
         <preferred>Term2:</preferred>
       </term>
       </terms>
       <definitions id="L" displayorder="11"><title depth="1">
            4.
            <tab/>
            缩略语与缩写
         </title>
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
        <title depth="1">5.<tab/>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
         <title depth="2">5.1.<tab/>Introduction</title>
       </clause>
       <clause id="O" inline-header="false" obligation="normative">
         <title depth="2">5.2.<tab/>Clause 4.2</title>
       </clause></clause>
       <references id="R" obligation="informative" normative="true" displayorder="9">
         <title depth="1">2.<tab/>References</title>
       </references>
       </sections><annex id="P" inline-header="false" obligation="normative" displayorder="13">
         <title><strong>&#x9644;&#x4EF6;A</strong><br/><br/><strong>Annex</strong></title>
         <p class="annex_obligation">（本附件不构成本建议书的不可或缺部分）</p>
         <clause id="Q" inline-header="false" obligation="normative">
         <title depth="2">A.1.<tab/>Annex A.1</title>
         <clause id="Q1" inline-header="false" obligation="normative">
         <title depth="3">A.1.1.<tab/>Annex A.1a</title>
         </clause>
       </clause>
       </annex><bibliography>
       <clause id="S" obligation="informative" displayorder="14">
         <title depth="1">Bibliography</title>
         <references id="T" obligation="informative" normative="false">
         <title depth="2">Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </itu-standard>
    OUTPUT

    html = <<~OUTPUT
       #{HTML_HDR.sub('Table of Contents', '目　录')}
          <br/>
          <div>
            <h1 class='AbstractTitle'>Abstract</h1>
            <p>This is an abstract</p>
          </div>
          <div class="Keyword">
          <h1 class="IntroTitle">关　键　词</h1>
          <p>A, B.</p>
        </div>
          <div>
            <h1 class='IntroTitle'>Foreword</h1>
            <p id='A'>This is a preamble</p>
          </div>
          <div id='B'>
            <h1 class='IntroTitle'>Introduction</h1>
            <div id='C'>
              <h2>Introduction Subsection</h2>
            </div>
          </div>
          <div id='A0'>
            <h1 class='IntroTitle'>History</h1>
            <p>history</p>
          </div>
          <p class='zzSTDTitle1'>&#26032;Recommendation&#33609;&#26696; 12345</p>
          <div id='D'>
            <h1>1.&#12288;Scope</h1>
            <p id='E'>Text</p>
          </div>
          <div>
            <h1>2.&#12288;References</h1>
            <table class='biblio' border='0'>
              <tbody/>
            </table>
          </div>
          <div id='I'>
            <h1>3.</h1>
            <div id='J'>
              <p class='TermNum' id='J'>
                <b>3.1.&#12288;Term2:</b>
              </p>
            </div>
          </div>
          <div id='L' class='Symbols'>
                     <h1>
          4.
      　
            缩略语与缩写
          </h1>
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
          <div id='M'>
            <h1>5.&#12288;Clause 4</h1>
            <div id='N'>
              <h2>5.1.&#12288;Introduction</h2>
            </div>
            <div id='O'>
              <h2>5.2.&#12288;Clause 4.2</h2>
            </div>
          </div>
          <br/>
          <div id='P' class='Section3'>
            <h1 class='Annex'>
              <b>&#38468;&#20214;A</b>
              <br/>
              <br/>
              <b>Annex</b>
            </h1>
            <p class='annex_obligation'>（本附件不构成本建议书的不可或缺部分）</p>
            <div id='Q'>
              <h2>A.1.&#12288;Annex A.1</h2>
              <div id='Q1'>
                <h3>A.1.1.&#12288;Annex A.1a</h3>
              </div>
            </div>
          </div>
          <br/>
          <div>
            <h1 class='Section3'>Bibliography</h1>
            <table class='biblio' border='0'>
              <tbody/>
            </table>
            <div>
              <h2 class='Section3'>Bibliography Subsection</h2>
              <table class='biblio' border='0'>
                <tbody/>
              </table>
            </div>
          </div>
        </div>
      </body>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", itudoc("zh"), true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::HtmlConvert.new({})
      .convert("test", presxml, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "processes editor clauses, two editors in French" do
    FileUtils.rm_f "test.html"
    input = <<~INPUT
      <itu-standard xmlns="http://riboseinc.com/isoxml">
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
      </itu-standard>
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

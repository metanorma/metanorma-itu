require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::ITU do
  it "processes history and source clauses (Word)" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <clause type="history" id="H" displayorder="1"><title>History</title></clause>
      <clause type="source" id="I" displayorder="2"><title>Source</title></clause>
      </preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
          <div class='WordSection2'>
        <div id='H' class="history">
          <h1 class='IntroTitle'>History</h1>
        </div>
        <div id='I' class="source">
          <h1 class='IntroTitle'>Source</h1>
        </div>
        <p>&#160;</p>
      </div>
    OUTPUT
    expect(xmlpp(IsoDoc::ITU::WordConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<div class="WordSection2">}m, '<div class="WordSection2">')
      .gsub(%r{<p>\s*<br clear="all" class="section"/>\s*</p>\s*<div class="WordSection3">.*}m, "")))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes annexes and appendixes" do
    input = <<~INPUT
             <itu-standard xmlns="http://riboseinc.com/isoxml">
             <bibdata type="standard">
             <title language="en" format="text/plain" type="main">An ITU Standard</title>
             <docidentifier type="ITU">12345</docidentifier>
             <language>en</language>
             <ext>
             <doctype>recommendation</doctype>
             </ext>
             </bibdata>
             <preface>
             <abstract>
             <title>Abstract</title>
                 <xref target="A1"/>
                 <xref target="B1"/>
             </abstract>
             </preface>
      <annex id="A1" obligation="normative"><title>Annex</title></annex>
      <annex id="A2" obligation="normative"><title>Annex</title></annex>
      <annex id="A3" obligation="normative"><title>Annex</title></annex>
      <annex id="A4" obligation="normative"><title>Annex</title></annex>
      <annex id="A5" obligation="normative"><title>Annex</title></annex>
      <annex id="A6" obligation="normative"><title>Annex</title></annex>
      <annex id="A7" obligation="normative"><title>Annex</title></annex>
      <annex id="A8" obligation="normative"><title>Annex</title></annex>
      <annex id="A9" obligation="normative"><title>Annex</title></annex>
      <annex id="A10" obligation="normative"><title>Annex</title></annex>
      <annex id="B1" obligation="informative"><title>Annex</title></annex>
      <annex id="B2" obligation="informative"><title>Annex</title></annex>
      <annex id="B3" obligation="informative"><title>Annex</title></annex>
      <annex id="B4" obligation="informative"><title>Annex</title></annex>
      <annex id="B5" obligation="informative"><title>Annex</title></annex>
      <annex id="B6" obligation="informative"><title>Annex</title></annex>
      <annex id="B7" obligation="informative"><title>Annex</title></annex>
      <annex id="B8" obligation="informative"><title>Annex</title></annex>
      <annex id="B9" obligation="informative"><title>Annex</title></annex>
      <annex id="B10" obligation="informative"><title>Annex</title></annex>
    INPUT
    presxml = <<~OUTPUT
      <itu-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
             <bibdata type="standard">
             <title language="en" format="text/plain" type="main">An ITU Standard</title>
             <docidentifier type="ITU">12345</docidentifier>
             <language current="true">en</language>
             <ext>
             <doctype language="">recommendation</doctype><doctype language="en">Recommendation</doctype>
             </ext>
             </bibdata>
             <preface>
             <clause type="toc" id="_" displayorder="1"> <title depth="1">Table of Contents</title> </clause>
             <abstract displayorder="2">
             <title>Abstract</title>
                 <xref target="A1">Annex A</xref>
                 <xref target="B1">Appendix I</xref>
             </abstract>
             </preface>
      <annex id="A1" obligation="normative" displayorder="3"><title><strong>Annex A</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="A2" obligation="normative" displayorder="4"><title><strong>Annex B</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="A3" obligation="normative" displayorder="5"><title><strong>Annex C</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="A4" obligation="normative" displayorder="6"><title><strong>Annex D</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="A5" obligation="normative" displayorder="7"><title><strong>Annex E</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="A6" obligation="normative" displayorder="8"><title><strong>Annex F</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="A7" obligation="normative" displayorder="9"><title><strong>Annex G</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="A8" obligation="normative" displayorder="10"><title><strong>Annex H</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="A9" obligation="normative" displayorder="11"><title><strong>Annex J</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="A10" obligation="normative" displayorder="12"><title><strong>Annex K</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="B1" obligation="informative" displayorder="13"><title><strong>Appendix I</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="B2" obligation="informative" displayorder="14"><title><strong>Appendix II</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="B3" obligation="informative" displayorder="15"><title><strong>Appendix III</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="B4" obligation="informative" displayorder="16"><title><strong>Appendix IV</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="B5" obligation="informative" displayorder="17"><title><strong>Appendix V</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="B6" obligation="informative" displayorder="18"><title><strong>Appendix VI</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="B7" obligation="informative" displayorder="19"><title><strong>Appendix VII</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="B8" obligation="informative" displayorder="20"><title><strong>Appendix VIII</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="B9" obligation="informative" displayorder="21"><title><strong>Appendix IX</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="B10" obligation="informative" displayorder="22"><title><strong>Appendix X</strong><br/><br/><strong>Annex</strong></title></annex>
      </itu-standard>
    OUTPUT
    html = <<~OUTPUT
              #{HTML_HDR}
              <br/>
              <div>
                     <h1 class="AbstractTitle">Abstract</h1>
                     <a href='#A1'>Annex A</a>
      <a href='#B1'>Appendix I</a>
                   </div>
                   <br/>
                   <div id="A1" class="Section3">
                     <h1 class="Annex"><b>Annex A</b> <br/><br/><b>Annex</b></h1>
                     <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
                   </div>
                   <br/>
                   <div id="A2" class="Section3">
                     <h1 class="Annex"><b>Annex B</b> <br/><br/><b>Annex</b></h1>
                     <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
                   </div>
                   <br/>
                   <div id="A3" class="Section3">
                     <h1 class="Annex"><b>Annex C</b> <br/><br/><b>Annex</b></h1>
                     <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
                   </div>
                   <br/>
                   <div id="A4" class="Section3">
                     <h1 class="Annex"><b>Annex D</b> <br/><br/><b>Annex</b></h1>
                     <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
                   </div>
                   <br/>
                   <div id="A5" class="Section3">
                     <h1 class="Annex"><b>Annex E</b> <br/><br/><b>Annex</b></h1>
                     <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
                   </div>
                   <br/>
                   <div id="A6" class="Section3">
                     <h1 class="Annex"><b>Annex F</b> <br/><br/><b>Annex</b></h1>
                     <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
                   </div>
                   <br/>
                   <div id="A7" class="Section3">
                     <h1 class="Annex"><b>Annex G</b> <br/><br/><b>Annex</b></h1>
                     <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
                   </div>
                   <br/>
                   <div id="A8" class="Section3">
                     <h1 class="Annex"><b>Annex H</b> <br/><br/><b>Annex</b></h1>
                     <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
                   </div>
                   <br/>
                   <div id="A9" class="Section3">
                     <h1 class="Annex"><b>Annex J</b> <br/><br/><b>Annex</b></h1>
                     <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
                   </div>
                   <br/>
                   <div id="A10" class="Section3">
                     <h1 class="Annex"><b>Annex K</b> <br/><br/><b>Annex</b></h1>
                     <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
                   </div>
                   <br/>
                   <div id="B1" class="Section3">
                     <h1 class="Annex"><b>Appendix I</b> <br/><br/><b>Annex</b></h1>
                     <p class="annex_obligation">(This appendix does not form an integral part of this Recommendation.)</p>
                   </div>
                   <br/>
                   <div id="B2" class="Section3">
                     <h1 class="Annex"><b>Appendix II</b> <br/><br/><b>Annex</b></h1>
                     <p class="annex_obligation">(This appendix does not form an integral part of this Recommendation.)</p>
                   </div>
                   <br/>
                   <div id="B3" class="Section3">
                     <h1 class="Annex"><b>Appendix III</b> <br/><br/><b>Annex</b></h1>
                                    <p class="annex_obligation">(This appendix does not form an integral part of this Recommendation.)</p>
                   </div>
                   <br/>
                   <div id="B4" class="Section3">
                     <h1 class="Annex"><b>Appendix IV</b> <br/><br/><b>Annex</b></h1>
                                    <p class="annex_obligation">(This appendix does not form an integral part of this Recommendation.)</p>
                   </div>
                   <br/>
                   <div id="B5" class="Section3">
                     <h1 class="Annex"><b>Appendix V</b> <br/><br/><b>Annex</b></h1>
                                    <p class="annex_obligation">(This appendix does not form an integral part of this Recommendation.)</p>
                   </div>
                   <br/>
                   <div id="B6" class="Section3">
                     <h1 class="Annex"><b>Appendix VI</b> <br/><br/><b>Annex</b></h1>
                                    <p class="annex_obligation">(This appendix does not form an integral part of this Recommendation.)</p>
                   </div>
                   <br/>
                   <div id="B7" class="Section3">
                     <h1 class="Annex"><b>Appendix VII</b> <br/><br/><b>Annex</b></h1>
                                    <p class="annex_obligation">(This appendix does not form an integral part of this Recommendation.)</p>
                   </div>
                   <br/>
                   <div id="B8" class="Section3">
                     <h1 class="Annex"><b>Appendix VIII</b> <br/><br/><b>Annex</b></h1>
                                    <p class="annex_obligation">(This appendix does not form an integral part of this Recommendation.)</p>
                   </div>
                   <br/>
                   <div id="B9" class="Section3">
                     <h1 class="Annex"><b>Appendix IX</b> <br/><br/><b>Annex</b></h1>
                                    <p class="annex_obligation">(This appendix does not form an integral part of this Recommendation.)</p>
                   </div>
                   <br/>
                   <div id="B10" class="Section3">
                     <h1 class="Annex"><b>Appendix X</b> <br/><br/><b>Annex</b></h1>
                                    <p class="annex_obligation">(This appendix does not form an integral part of this Recommendation.)</p>
                   </div>
                 </div>
               </body>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::ITU::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({})
      .convert("test", presxml, true)
      .gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to xmlpp(html)
  end

  it "processes section names" do
    presxml = <<~OUTPUT
      <itu-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
               <bibdata type="standard">
               <title language="en" format="text/plain" type="main">An ITU Standard</title>
               <title language="fr" format="text/plain" type="main">Un Standard ITU</title>
               <docidentifier type="ITU">12345</docidentifier>
               <language current="true">en</language>
               <script current="true">Latn</script>
               <keyword>A</keyword>
               <keyword>B</keyword>
               <ext>
               <doctype language="">recommendation</doctype><doctype language="en">Recommendation</doctype>
               </ext>
               </bibdata>
      <preface>
        <clause type="toc" id="_" displayorder="1">
        <title depth="1">Table of Contents</title>
        </clause>
      <abstract displayorder="2"><title>Abstract</title>
      <p>This is an abstract</p>
      </abstract>
          <clause type="keyword" displayorder="3">
          <title depth="1">Keywords</title>
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
            <p class="zzSTDTitle1" displayorder="7">Draft new Recommendation 12345</p>
        <p class="zzSTDTitle2" displayorder="8">An ITU Standard</p>
       <clause id="D" obligation="normative" type="scope" displayorder="9">
         <title depth="1">1.<tab/>Scope</title>
         <p id="E">Text</p>
       </clause>
       <terms id="I" obligation="normative" displayorder="11"><title>3.</title>
         <term id="J"><name>3.1.</name>
         <preferred>Term2</preferred>
       </term>
       </terms>
       <definitions id="L" displayorder="12"><title>4.</title>
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
       </references><
       </sections><annex id="P" inline-header="false" obligation="normative" displayorder="14">
         <title><strong>Annex A</strong><br/><br/><strong>Annex</strong></title>
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
       #{HTML_HDR}
                 <br/>
                 <div>
           <h1 class="AbstractTitle">Abstract</h1>
           <p>This is an abstract</p>
         </div>
            <div class="Keyword">
        <h1 class="IntroTitle">Keywords</h1>
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
                        <p class="zzSTDTitle1">Draft new Recommendation 12345</p>
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
                        <div id="J"><p class="TermNum" id="J"><b>3.1.&#160; Term2</b>:</p>
                 </div>
                      </div>
                        <div id="L" class="Symbols">
                          <h1>4.</h1>
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
         <div class='Abstract'>
             <h1 class="AbstractTitle">Summary</h1>
             <p>This is an abstract</p>
           </div>
           <div class='Keyword'>
             <h1 class="IntroTitle">Keywords</h1>
             <p>A, B.</p>
           </div>
           <div>
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
           <p class="zzSTDTitle1">Draft new Recommendation 12345</p>
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
        <div id="J"><p class="TermNum" id="J"><b>3.1.<span style="mso-tab-count:1">&#160; </span>Term2</b>: </p>
      </div>
      </div>
           <div id="L" class="Symbols">
             <h1>4.</h1>
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
    expect(xmlpp(strip_guid(IsoDoc::ITU::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", itudoc("en"), true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({})
      .convert("test", presxml, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::ITU::WordConvert.new({})
      .convert("test", presxml, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to xmlpp(word)
  end

  it "post-processes section names (Word)" do
    FileUtils.rm_f "test.doc"
    IsoDoc::ITU::WordConvert.new({}).convert("test", <<~INPUT, false)
      <itu-standard xmlns="http://riboseinc.com/isoxml">
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
               <title>1<tab/>Scope</title>
               <p id="E">Text</p>
               <figure id="fig-f1-1">
        <name>Static aspects of SDL‑2010</name>
        </figure>
        <p>Hello</p>
        <figure id="fig-f1-2">
        <name>Static aspects of SDL‑2010</name>
        </figure>
        <note><p>Hello</p></note>
             </clause>
             </sections>
              <annex id="P" inline-header="false" obligation="normative" displayorder="2">
               <title><strong>Annex A</strong><br/><br/><strong>Annex 1</strong></title>
               <clause id="Q" inline-header="false" obligation="normative">
               <title>A.1<tab/>Annex A.1</title>
               <p>Hello</p>
               </clause>
             </annex>
                 <annex id="P1" inline-header="false" obligation="normative" displayorder="3">
               <title><strong>Annex B</strong><br/><br/><strong>Annex 2</strong></title>
               <p>Hello</p>
               <clause id="Q1" inline-header="false" obligation="normative">
               <title>B.1<tab/>Annex A1.1</title>
               <p>Hello</p>
               </clause>
               </clause>
             </annex>
             </itu-standard>
    INPUT
    expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc", encoding: "UTF-8")
    expect(xmlpp(html
      .sub(%r{^.*<div class="WordSection3">}m, %{<body><div class="WordSection3">})
      .gsub(%r{</body>.*$}m, "</body>")))
      .to be_equivalent_to xmlpp(<<~OUTPUT)
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
             <itu-standard xmlns="http://riboseinc.com/isoxml">
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
      </itu-standard>
    INPUT

    presxml = <<~OUTPUT
      <itu-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
            <bibdata type='standard'>
              <title language='en' format='text/plain' type='main'>An ITU Standard</title>
              <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
              <docidentifier type='ITU'>12345</docidentifier>
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
            <clause type="keyword" displayorder="1">
              <title depth="1">Keywords</title>
              <p>A, B.</p>
            </clause>
            <clause type="toc" id="_" displayorder="2"> <title depth="1">Table of Contents</title> </clause>
            </preface>
              <sections>
          <p class="zzSTDTitle1" displayorder="3">Draft new Recommendation 12345</p>
          <p class="zzSTDTitle2" displayorder="4">An ITU Standard</p>
          <p class="zzSTDTitle3" displayorder="5">Subtitle</p>
          <clause displayorder="6"/>
        </sections>
            <annex id='A1' obligation='normative' displayorder='7'>
              <title>
                <strong>Annex F2</strong>
                <br/>
                <br/>
                <strong>Annex</strong>
              </title>
              <clause id='A2'>
                <title depth='2'>F2.1.<tab/>Subtitle</title>
                <table id='T'>
                  <name>Table F2.1</name>
                </table>
                <figure id='U'>
                  <name>Figure F2.1</name>
                </figure>
                <formula id='V'>
                  <name>F2-1</name>
                  <stem type='AsciiMath'>r = 1 %</stem>
                </formula>
              </clause>
            </annex>
          </itu-standard>
    OUTPUT
    expect(xmlpp(strip_guid(IsoDoc::ITU::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to xmlpp(presxml)
    IsoDoc::ITU::HtmlConvert.new({}).convert("test", presxml, false)
    html = File.read("test.html", encoding: "utf-8")
    expect(xmlpp(strip_guid(html.gsub(%r{^.*<main}m, "<main")
      .gsub(%r{</main>.*}m, "</main>"))))
      .to be_equivalent_to xmlpp(<<~OUTPUT)
            <main class='main-section'>
                 <button onclick='topFunction()' id='myBtn' title='Go to top'>Top</button>
                   <div class="Keyword">
                  <h1 class="IntroTitle" id="_">Keywords</h1>
                    <p>A, B.</p>
                </div>
                 <br/>
                 <p class='zzSTDTitle1'>Draft new Recommendation 12345</p>
                 <p class='zzSTDTitle2'>An ITU Standard</p>
                 <p class='zzSTDTitle3'>Subtitle</p>
                 <div/>
                 <div id='A1' class='Section3'>
                   <p class='h1Annex'>
                     <b>Annex F2</b>
                     <br/>
                     <br/>
                     <b>Annex</b>
                   </p>
                   <p class='annex_obligation'>(This annex forms an integral part of this Recommendation.)</p>
                   <div id='A2'>
                     <h2 id='_'><a class="anchor" href="#A2"/><a class="header" href="#A2">F2.1.&#xA0; Subtitle</a></h2>
                     <p class='TableTitle' style='text-align:center;'>Table F2.1</p>
                     <table id='T' class='MsoISOTable' style='border-width:1px;border-spacing:0;'/>
                     <div id='U' class='figure'>
          <p class='FigureTitle' style='text-align:center;'>Figure F2.1</p>
        </div>
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

    IsoDoc::ITU::WordConvert.new({}).convert("test", presxml, false)
    html = File.read("test.doc", encoding: "utf-8")
    expect(xmlpp(html
 .gsub(%r{^.*<div class="WordSection3">}m, '<div class="WordSection3" xmlns:m="http://schemas.microsoft.com/office/2004/12/omml">')
 .gsub(%r{<div style="mso-element:footnote-list"/>.*}m, "")))
      .to be_equivalent_to xmlpp(<<~OUTPUT)
        <div class='WordSection3' xmlns:m='http://schemas.microsoft.com/office/2004/12/omml'>
              <p class='zzSTDTitle1'>Draft new Recommendation 12345</p>
              <p class='zzSTDTitle2'>An ITU Standard</p>
              <p class='zzSTDTitle3'>Subtitle</p>
              <div/>
              <div class='Section3'>
                <a name='A1' id='A1'/>
                <p class='h1Annex'>
                  <b>Annex F2</b>
                  <br/>
                  <br/>
                  <b>Annex</b>
                </p>
                <p class='annex_obligation'>(This annex forms an integral part of this Recommendation.)</p>
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
  end

  it "processes history tables (Word)" do
    FileUtils.rm_f "test.doc"
    IsoDoc::ITU::WordConvert.new({}).convert("test", <<~INPUT, false)
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface><clause id="_history" obligation="normative" displayorder="1">
        <title>History</title>
        <table id="_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4">
        <name>Table 1</name>
        <tbody>
          <tr>
            <td align="left">Edition</td>
            <td align="left">Recommendation</td>
            <td align="left">Approval</td>
            <td align="left">Study Group</td>
            <td align="left">Unique ID<fn reference="a">
        <p id="_8a4ff03f-e7a6-4430-939d-1b7b0ffa60e9">To access the Recommendation, type the URL <link target="http://handle.itu.int/"/> in the address field of your web browser, followed by the Recommendation?~@~Ys unique ID. For example, <link target="http://handle.itu.int/11.1002/1000/11830-en"/></p>
      </fn>.</td>
          </tr>
      <tr>
            <td align="left">1.0</td>
            <td align="left">ITU-T G.650</td>
            <td align="left">1993-03-12</td>
            <td align="left">XV</td>
            <td align="left">
              <link target="http://handle.itu.int/11.1002/1000/879">11.1002/1000/879</link>
            </td>
          </tr>
          </tbody>
          </table>
          </clause>
          </preface>
          </iso-standard>
    INPUT
    expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc", encoding: "UTF-8")
    expect(xmlpp(html
      .gsub(%r{.*<p class="h1Preface">History</p>}m,
            '<div><p class="h1Preface">History</p>')
      .sub(%r{</table>.*$}m, "</table></div></div>")))
      .to be_equivalent_to xmlpp(<<~OUTPUT)
              <div>
              <p class="h1Preface">History</p>
                       <p class="TableTitle" style="text-align:center;">Table 1</p>
                        <div align='center' class='table_container'>
        <table class='MsoNormalTable' style='mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;'>
        <a name='_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4' id='_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4'/>
                           <tbody>
                             <tr>
                               <td align="left" style="" valign="top">Edition</td>
                               <td align="left" style="" valign="top">Recommendation</td>
                               <td align="left" style="" valign="top">Approval</td>
                               <td align="left" style="" valign="top">Study Group</td>
                               <td align="left" style="" valign="top">Unique ID<a href="#_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4a" class="TableFootnoteRef">a)</a>.</td>
                             </tr>
                             <tr>
                               <td align="left" style="" valign="top">1.0</td>
                               <td align="left" style="" valign="top">ITU-T G.650</td>
                               <td align="left" style="" valign="top">1993-03-12</td>
                               <td align="left" style="" valign="top">XV</td>
                               <td align="left" style="" valign="top">
                       <a href="http://handle.itu.int/11.1002/1000/879" class="url">11.1002/1000/879</a>
                     </td>
                             </tr>
                           </tbody>
                         <tfoot><tr><td colspan="5" style=""><div class="TableFootnote"><div><a name="ftn_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4a" id="ftn_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4a"></a>
                 <p class="TableFootnote"><a name="_8a4ff03f-e7a6-4430-939d-1b7b0ffa60e9" id="_8a4ff03f-e7a6-4430-939d-1b7b0ffa60e9"></a><span><span class="TableFootnoteRef"><a name="_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4a" id="_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4a"></a>a)</span><span style="mso-tab-count:1">&#xA0; </span></span>To access the Recommendation, type the URL <a href="http://handle.itu.int/" class="url">http://handle.itu.int/</a> in the address field of your web browser, followed by the Recommendation?~@~Ys unique ID. For example, <a href="http://handle.itu.int/11.1002/1000/11830-en" class="url">http://handle.itu.int/11.1002/1000/11830-en</a></p>
               </div></div></td></tr></tfoot></table>
               </div></div>
      OUTPUT
  end

  it "processes unnumbered clauses" do
    input = <<~INPUT
             <itu-standard xmlns="http://riboseinc.com/isoxml">
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
      </itu-standard>
    INPUT
    presxml = <<~OUTPUT
        <itu-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
      <bibdata type='standard'>
        <title language='en' format='text/plain' type='main'>An ITU Standard</title>
        <title language='en' format='text/plain' type='resolution'>RESOLUTION (, )</title>
        <title language='en' format='text/plain' type='resolution-placedate'>, </title>
        <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
        <docidentifier type='ITU'>12345</docidentifier>
        <language current='true'>en</language>
        <ext>
          <doctype language=''>resolution</doctype>
          <doctype language='en'>Resolution</doctype>
          <structuredidentifier>
            <annexid>F2</annexid>
          </structuredidentifier>
        </ext>
      </bibdata>
                <sections>
          <p class="zzSTDTitle1" align="center" displayorder="1">RESOLUTION  (, )</p>
          <p class="zzSTDTitle2" displayorder="2">An ITU Standard</p>
          <p align="center" class="zzSTDTitle2" displayorder="3"><em>(,</em>)</p>
          <clause unnumbered="true" id="A" displayorder="4">
            <p>Text</p>
          </clause>
          <p keep-with-next="true" class="supertitle" displayorder="5">SECTION 1</p>
          <clause id="B" displayorder="6">
            <title depth="1">First Clause</title>
          </clause>
        </sections>
      </itu-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "processes bis, ter etc clauses" do
    input = <<~INPUT
                     <itu-standard xmlns="http://riboseinc.com/isoxml">
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
              </itu-standard>
    INPUT
    presxml = <<~OUTPUT
      <itu-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
                        <bibdata type="standard">
                        <title language="en" format="text/plain" type="main">An ITU Standard</title><title language="en" format="text/plain" type="resolution">RESOLUTION  (, )</title>
         <title language="en" format="text/plain" type="resolution-placedate">, </title>

                        <title language="en" format="text/plain" type="subtitle">Subtitle</title>
                        <docidentifier type="ITU">12345</docidentifier>
                        <language current="true">en</language>
                        <ext>
                        <doctype language="">resolution</doctype><doctype language="en">Resolution</doctype>
                        <structuredidentifier>
                        <annexid>F2</annexid>
                        </structuredidentifier>
                        </ext>
                        </bibdata>
                                  <sections>
            <p class="zzSTDTitle1" align="center" displayorder="1">RESOLUTION  (, )</p>
            <p class="zzSTDTitle2" displayorder="2">An ITU Standard</p>
            <p align="center" class="zzSTDTitle2" displayorder="3"><em>(,</em>)</p>
            <p keep-with-next="true" class="supertitle" displayorder="4">SECTION 1</p>
            <clause id="A" displayorder="5">
              <p><xref target="B">Section 1<em>bis</em></xref>, <xref target="C">Section 10<em>ter</em></xref>, <xref target="D">10<em>ter</em>.10<em>quater</em></xref>, <xref target="E">Section 10bit</xref></p>
            </clause>
            <p keep-with-next="true" class="supertitle" displayorder="6">SECTION 1<em>bis</em></p>
            <clause id="B" number="1bis" displayorder="7">
              <title depth="1">First Clause</title>
            </clause>
            <p keep-with-next="true" class="supertitle" displayorder="8">SECTION 10<em>ter</em></p>
            <clause id="C" number="10ter" displayorder="9">
              <title depth="1">Second Clause</title>
              <clause id="D" number="10quater">
                <title depth="2">10<em>ter</em>.10<em>quater</em>.<tab/>Second Clause Subclause</title>
              </clause>
            </clause>
            <p keep-with-next="true" class="supertitle" displayorder="10">SECTION 10bit</p>
            <clause id="E" number="10bit" displayorder="11">
              <title depth="1">Non-Clause</title>
            </clause>
          </sections>
        </itu-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "processes editor clauses, one editor" do
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
      </contributor>
      <contributor><role type="author"/>
      <person><name><completename>Barney Rubble</completename></name>
      <affiliation><organization><name>World Health Organization</name></organization></affiliation>
      <email>jack@example.com</email>
      </person>
      </contributor>
      <language>en</language>
      <ext>
      <doctype>resolution</doctype>
      <structuredidentifier>
      <annexid>F2</annexid>
      </structuredidentifier>
      </ext>
      </bibdata>
      <sections>
        <clause id="A"/>
      </sections>
      </itu-standard>
    INPUT
    presxml = <<~OUTPUT
      <preface>
        <clause type="toc" id="_" displayorder="1"> <title depth="1">Table of Contents</title> </clause>
         <clause id='_' type='editors' displayorder='2'>
           <table id='_' unnumbered='true'>
             <tbody>
               <tr>
                 <th>Editor:</th>
                 <td>
                   Fred Flintstone
                   <br/>
                   World Health Organization
                 </td>
                 <td>
                   E-mail:
                   <link target='mailto:jack@example.com'>jack@example.com</link>
                 </td>
               </tr>
             </tbody>
           </table>
         </clause>
       </preface>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::ITU::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
    xml = xml.at("//xmlns:preface").to_xml
    expect(xmlpp(strip_guid(xml)))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "processes editor clauses, two editors" do
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
      <language>en</language>
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
                 <th>Editors:</th>
                 <td>
                   Fred Flintstone
                   <br/>
                   World Health Organization
                 </td>
                 <td>
                   E-mail:
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
    xml = Nokogiri::XML(IsoDoc::ITU::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
    xml = xml.at("//xmlns:preface").to_xml
    expect(xmlpp(strip_guid(xml)))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "generates contribution prefatory table and abstract table" do
    logoloc = File.expand_path(
      File.join(File.dirname(__FILE__), "..", "..", "lib", "isodoc", "itu",
                "html"),
    )
    input = <<~INPUT
      <itu-standard xmlns='https://www.metanorma.org/ns/itu' type='semantic'>
        <bibdata type='standard'>
          <title language='en' format='text/plain' type='main'>Main Title</title>
          <title language='fr' format='text/plain' type='main'>Titre Principal</title>
          <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
          <title language='fr' format='text/plain' type='subtitle'>Soustitre</title>
          <docidentifier type='ITU-provisional'>ABC</docidentifier>
          <docidentifier primary="true" type='ITU'>SG17-C1000</docidentifier>
          <docidentifier type='ITU-lang'>SG17-C1000-E</docidentifier>
          <docnumber>1000</docnumber>
          <contributor>
            <role type='author'/>
            <organization>
              <name>International Telecommunication Union</name><abbreviation>ITU</abbreviation>
            </organization>
          </contributor>
          <contributor>
          <role type='editor'>raporteur</role>
            <person>
              <name>
                <completename>Fred Flintstone</completename>
              </name>
              <affiliation>
                <organization>
                  <name>Bedrock Quarry</name>
                  <address>
                    <formattedAddress>Canada</formattedAddress>
                  </address>
                </organization>
              </affiliation>
              <phone>555</phone>
              <phone type='fax'>556</phone>
              <email>x@example.com</email>
            </person>
          </contributor>
          <contributor>
            <role type='editor'/>
            <person>
              <name>
                <completename>Barney Rubble</completename>
              </name>
              <affiliation>
                <organization>
                  <name>Bedrock Quarry 2</name>
                  <address>
                    <formattedAddress>USA</formattedAddress>
                  </address>
                </organization>
              </affiliation>
              <phone>557</phone>
              <phone type='fax'>558</phone>
            </person>
          </contributor>
          <contributor>
            <role type='publisher'/>
            <organization>
              <name>International Telecommunication Union</name>
              <abbreviation>ITU</abbreviation>
            </organization>
          </contributor>
          <edition>2</edition>
          <version>
            <revision-date>2000-01-01</revision-date>
            <draft>5</draft>
          </version>
          <language>en</language>
          <script>Latn</script>
          <status>
            <stage>draft</stage>
          </status>
          <copyright>
            <from>2001</from>
            <owner>
              <organization>
                <name>International Telecommunication Union</name>
                <abbreviation>ITU</abbreviation>
              </organization>
            </owner>
          </copyright>
          <series type='main'>
            <title>A3</title>
          </series>
          <series type='secondary'>
            <title>B3</title>
          </series>
          <series type='tertiary'>
            <title>C3</title>
          </series>
          <keyword>VoIP</keyword>
          <keyword>word1</keyword>
          <ext>
            <doctype>contribution</doctype>
            <editorialgroup>
              <bureau>R</bureau>
              <group type="study-group">
                <name>Study Group 17</name>
                <acronym>SG17</acronym>
                <period>
                  <start>2000</start>
                  <end>2002</end>
                </period>
              </group>
              <subgroup>
                <name>I1</name>
              </subgroup>
              <workgroup>
                <name>I2</name>
              </workgroup>
            </editorialgroup>
            <recommendationstatus>
                <from>D3</from>
                <to>E3</to>
                <approvalstage process='F3'>G3</approvalstage>
              </recommendationstatus>
              <ip-notice-received>false</ip-notice-received>
              <timing>2025-Q4</timing>
            <meeting acronym='MX'>Meeting X</meeting>
            <meeting-place>Kronos</meeting-place>
            <meeting-date>
              <from>2000-01-01</from>
              <to>2000-01-02</to>
            </meeting-date>
            <intended-type>TD</intended-type>
            <source>Source1</source>
            <structuredidentifier>
              <bureau>R</bureau>
              <docnumber>1000</docnumber>
            </structuredidentifier>
          </ext>
        </bibdata>
        <preface>
        <abstract id="A"><p>This is an abstract.</p></abstract>
        </preface>
        <sections>
        <clause id="B"><title>First</title><p>This is the first clause</p></clause>
        </sections>
        <annex id="A1"><title>Annex</title></annex>
        <annex id="A2" type="justification">
        clause id="_a6ac7b3c-2a73-4afb-502c-c683372215ca" type="scope" inline-header="false" obligation="normative">
        <title>Scope</title><p id="_37adf2c4-28f1-ea9c-0f52-b2ff84b33b55">TEXT 1</p>
        </clause>
        <clause id="_2" type="summary" inline-header="false" obligation="normative">
        <p id="_5f7e73d1-bd2e-8b40-bd86-c2ba5a400577">TEXT 2</p>
        </clause>
        <clause id="_3" type="relatedstandards" inline-header="false" obligation="normative">
        <ol id="_5d94d081-b33a-6cb0-61f3-d4ce3bb47ea2"><li><p id="_7e51a815-c9d7-074a-7125-bea511e3927d">TEXT 3</p>
        </li>
        <li><p id="_d8492089-77f3-0b7d-2750-aaacd5c0e8d3">TEXT 4</p>
        </li>
        <li><p id="_16595e62-ff08-3742-84c1-dbbae8ac1fab">TEXT 5</p>
        </li>
        </ol>
        </clause>
        <clause id="_4" type="liaisons" inline-header="false" obligation="normative">
        <ol id="_22e6d6a2-63f6-8afc-2adb-329f4bef13e7"><li><p id="_111c6bfd-8e98-c405-a425-c6112d028f8e">TEXT 6</p>
        </li>
        <li><p id="_7df8ce97-29db-c8c9-46ef-5731bc258a16">TEXT 7</p>
        </li>
        <li><p id="_ea1810b1-db12-e76f-6597-c67aea0160f5">TEXT 8</p>
        </li>
        </ol>
        </clause>
        <clause id="_5" type="supportingmembers" inline-header="false" obligation="normative">
        <p id="_a42297b2-5f04-5da9-64c2-7e92670d5cad">TEXT 9</p>
        </clause>
        </annex>
        </itu-standard>
    INPUT
    presxml = <<~OUTPUT
      <itu-standard>
        <preface>
          <clause unnumbered="true" type="contribution-metadata" displayorder="1">
            <table class="contribution-metadata" unnumbered="true" width="100%">
              <colgroup>
                <col width="11.8%"/>
                <col width="41.2%"/>
                <col width="47.0%"/>
              </colgroup>
              <thead>
                <tr>
                  <th rowspan="3">
                   <image height="56" width="56" src="#{File.join(logoloc, '/logo-small.png')}"/>
                  </th>
                  <td rowspan="3">
                    <p style="font-size:8pt;margin-top:6pt;margin-bottom:0pt;">INTERNATIONAL TELECOMMUNICATION UNION</p>
                    <p class="bureau_big" style="font-size:13pt;margin-top:6pt;margin-bottom:0pt;">
                      <strong>RADIOCOMMUNICATION BUREAU</strong>
                      <br/>
                      <strong>OF ITU</strong>
                    </p>
                    <p style="font-size:10pt;margin-top:6pt;margin-bottom:0pt;">STUDY PERIOD 2000–2002</p>
                  </td>
                  <th align="right">
                    <p style="font-size:16pt;">SG17-C1000</p>
                  </th>
                </tr>
                <tr>
                  <th align="right">
                    <p style="font-size:14pt;">STUDY GROUP 17</p>
                  </th>
                </tr>
                <tr>
                  <th align="right">
                    <p style="font-size:14pt;">Original: English</p>
                  </th>
                </tr>
              </thead>
                             <tbody>
                 <tr>
                   <th align="left" width="95">Question(s):</th>
                   <td/>
                   <td align="right">Kronos, 01 Jan 2000/02 Jan 2000</td>
                 </tr>
                 <tr>
                   <th align="center" colspan="3">CONTRIBUTION</th>
                 </tr>
                 <tr>
                   <th align="left" width="95">Source:</th>
                   <td colspan="2">Source1</td>
                 </tr>
                 <tr>
                   <th align="left" width="95">Title:</th>
                   <td colspan="2">Main Title</td>
                 </tr>
                 <tr>
                   <th align="left" width="95">Contact:</th>
                   <td>Fred Flintstone<br/>
       Bedrock Quarry<br/>
       Canada</td>
                   <td>Tel.<tab/>555<br/>E-mail<tab/>x@example.com</td>
                 </tr>
                 <tr>
                   <th align="left" width="95">Contact:</th>
                   <td>Barney Rubble<br/>
       Bedrock Quarry 2<br/>
       USA</td>
                   <td>Tel.<tab/>557</td>
                 </tr>
                 <tr>
                   <th align="left" width="95">Contact:</th>
                   <td>
                     <br/>
                     <br/>
                   </td>
                   <td>Tel.<tab/></td>
                 </tr>
               </tbody>
             </table>
           </clause>
           <abstract id="A" displayorder="2">
             <table class="abstract" unnumbered="true" width="100%">
               <colgroup>
                 <col width="11.8%"/>
                 <col width="78.2%"/>
               </colgroup>
               <tbody>
                 <tr>
                   <th align="left" width="95">
                     <p>Abstract:</p>
                   </th>
                   <td>
                     <p>This is an abstract.</p>
                   </td>
                 </tr>
               </tbody>
             </table>
           </abstract>
         </preface>
         <sections>
           <clause id="B" displayorder="3">
             <title depth="1">1.<tab/>First</title>
             <p>This is the first clause</p>
           </clause>
         </sections>
         <annex id="A1" displayorder="4">
           <title>
             <strong>Annex A</strong>
             <br/>
             <br/>
             <strong>Annex</strong>
           </title>
         </annex>
         <annex id="A2" type="justification" displayorder="5">
           <title>
             <strong>Annex B</strong>
             <br/>
             <br/>
             <strong>A.13 justification for proposed draft new  SG17-C1000 “Main Title”</strong>
           </title>
           <table class="contribution-metadata" unnumbered="true" width="100%">
             <colgroup>
               <col width="15.9%"/>
               <col width="6.1%"/>
               <col width="45.5%"/>
               <col width="17.4%"/>
               <col width="15.1%"/>
             </colgroup>
             <tbody>
               <tr>
                 <th align="left">Question(s):</th>
                 <td/>
                 <th align="left">Proposed new ITU-T </th>
                 <td colspan="2">Kronos, 01 Jan 2000/02 Jan 2000</td>
               </tr>
               <tr>
                 <th align="left">Reference and title:</th>
                 <td colspan="4">Draft new  on “Main Title”</td>
               </tr>
               <tr>
                 <th align="left">Base text:</th>
                 <td colspan="2"/>
                 <th align="left">Timing:</th>
                 <td>2025-Q4</td>
               </tr>
               <tr>
                 <th align="left" rowspan="2">Editor(s):</th>
                 <td colspan="2">Fred Flintstone<br/>
       Bedrock Quarry<br/>
       Canada, E-mail<tab/>x@example.com
       </td>
                 <th align="left" rowspan="2">Approval process:</th>
                 <td rowspan="2">F3</td>
               </tr>
               <tr>
                 <td colspan="2">Barney Rubble<br/>
       Bedrock Quarry 2<br/>
       USA
       </td>
               </tr>
               <tr>
                 <td colspan="2">
                   <br/>
                   <br/>
                 </td>
               </tr>
               <tr>
                 <td colspan="5">
                   <p><strong>Scope</strong> (defines the intent or object of the Recommendation and the aspects covered, thereby indicating the limits of its applicability):</p>
                 </td>
               </tr>
               <tr>
                 <td colspan="5">
                   <p><strong>Summary</strong> (provides a brief overview of the purpose and contents of the Recommendation, thus permitting readers to judge its usefulness for their work):</p>
                 </td>
               </tr>
               <tr>
                 <td colspan="5">
                   <p><strong>Relations to ITU-T Recommendations or to other standards</strong> (approved or under development):</p>
                 </td>
               </tr>
               <tr>
                 <td colspan="5">
                   <p>
                     <strong>Liaisons with other study groups or with other standards bodies:</strong>
                   </p>
                 </td>
               </tr>
               <tr>
                 <td colspan="5">
                   <p>
                     <strong>Supporting members that are committing to contributing actively to the work item:</strong>
                   </p>
                 </td>
               </tr>
             </tbody>
           </table>
         </annex>
       </itu-standard>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::ITU::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
    xml = xml.xpath("//xmlns:preface | //xmlns:sections | //xmlns:annex").to_xml
    expect(xmlpp(strip_guid("<itu-standard>#{xml}</itu-standard>")))
      .to be_equivalent_to xmlpp(presxml)

    presxml = <<~OUTPUT
      <preface>
         <clause unnumbered="true" type="contribution-metadata" displayorder="1">
           <table class="contribution-metadata" unnumbered="true" width="100%">
             <colgroup>
               <col width="11.8%"/>
               <col width="41.2%"/>
               <col width="47.0%"/>
             </colgroup>
             <thead>
               <tr>
                 <th rowspan="3">
                   <image height="56" width="56" src="#{File.join(logoloc, '/logo-small.png')}"/>
                 </th>
                 <td rowspan="3">
                   <p style="font-size:8pt;margin-top:6pt;margin-bottom:0pt;">UNION INTERNATIONALE DES TÉLÉCOMMUNICATIONS</p>
                   <p class="bureau_big" style="font-size:13pt;margin-top:6pt;margin-bottom:0pt;">
                     <strong>BUREAU DES RADIOCOMMUNICATIONS</strong>
                     <br/>
                     <strong>DE L’UIT</strong>
                   </p>
                   <p style="font-size:10pt;margin-top:6pt;margin-bottom:0pt;">PÉRIODE D’ÉTUDES 2000–2002</p>
                 </td>
                 <th align="right">
                   <p style="font-size:16pt;">SG17-C1000</p>
                 </th>
               </tr>
               <tr>
                 <th align="right">
                   <p style="font-size:14pt;">STUDY GROUP 17</p>
                 </th>
               </tr>
               <tr>
                 <th align="right">
                   <p style="font-size:14pt;">Original : Français</p>
                 </th>
               </tr>
             </thead>
                         <tbody>
               <tr>
                 <th align="left" width="95">Question(s):</th>
                 <td/>
                 <td align="right">Kronos, 01 janv. 2000/02 janv. 2000</td>
               </tr>
               <tr>
                 <th align="center" colspan="3">CONTRIBUTION</th>
               </tr>
               <tr>
                 <th align="left" width="95">Source :</th>
                 <td colspan="2">Source1</td>
               </tr>
               <tr>
                 <th align="left" width="95">Titre :</th>
                 <td colspan="2">Main Title</td>
               </tr>
               <tr>
                 <th align="left" width="95">Contact :</th>
                 <td>Fred Flintstone<br/>
       Bedrock Quarry<br/>
       Canada</td>
                 <td>Tél.<tab/>555<br/>E-mail<tab/>x@example.com</td>
               </tr>
               <tr>
                 <th align="left" width="95">Contact :</th>
                 <td>Barney Rubble<br/>
       Bedrock Quarry 2<br/>
       USA</td>
                 <td>Tél.<tab/>557</td>
               </tr>
               <tr>
                 <th align="left" width="95">Contact :</th>
                 <td>
                   <br/>
                   <br/>
                 </td>
                 <td>Tél.<tab/></td>
               </tr>
             </tbody>
           </table>
         </clause>
         <abstract id="A" displayorder="2">
           <table class="abstract" unnumbered="true" width="100%">
             <colgroup>
               <col width="11.8%"/>
               <col width="78.2%"/>
             </colgroup>
             <tbody>
               <tr>
                 <th align="left" width="95">
                   <p>Résumé :</p>
                 </th>
                 <td>
                   <p>This is an abstract.</p>
                 </td>
               </tr>
             </tbody>
           </table>
         </abstract>
       </preface>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::ITU::PresentationXMLConvert.new(presxml_options)
      .convert("test", input
      .sub("<language>en</language>", "<language>fr</language>"), true))
    xml = xml.at("//xmlns:preface").to_xml
    expect(xmlpp(strip_guid(xml)))
      .to be_equivalent_to xmlpp(presxml)
  end
end

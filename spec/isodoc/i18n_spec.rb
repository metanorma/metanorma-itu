require "spec_helper"
require "fileutils"

logoloc = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "isodoc", "itu", "html"))

RSpec.describe Asciidoctor::ITU do
    it "processes section names in French" do
              presxml = <<~OUTPUT
              <itu-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
                 <bibdata type="standard">
                 <title language="en" format="text/plain" type="main">An ITU Standard</title>
                 <title language="fr" format="text/plain" type="main">Un Standard ITU</title>
                 <docidentifier type="ITU">12345</docidentifier>
                 <language current="true">fr</language>
                 <script current='true'>Latn</script>
                 <keyword>A</keyword>
                 <keyword>B</keyword>
                 <ext>
                 <doctype language="">recommendation</doctype>
                 <doctype language='fr'>Recommendation</doctype>
                 </ext>
                 </bibdata>
        <preface>
        <abstract><title>Abstract</title>
        <p>This is an abstract</p>
        </abstract>
        <clause id="A0"><title depth="1">History</title>
        <p>history</p>
        </clause>
        <foreword obligation="informative">
           <title>Foreword</title>
           <p id="A">This is a preamble</p>
         </foreword>
          <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
           <title depth="2">Introduction Subsection</title>
         </clause>
         </introduction></preface><sections>
         <clause id="D" obligation="normative" type="scope">
           <title depth="1">1.<tab/>Scope</title>
           <p id="E">Text</p>
         </clause>

         <terms id="I" obligation="normative"><title>3.</title>
           <term id="J"><name>3.1.</name>
           <preferred>Term2</preferred>
         </term>
         </terms>
         <definitions id="L"><title>4.</title>
           <dl>
           <dt>Symbol</dt>
           <dd>Definition</dd>
           </dl>
         </definitions>
         <clause id="M" inline-header="false" obligation="normative"><title depth="1">5.<tab/>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
           <title depth="2">5.1.<tab/>Introduction</title>
         </clause>
         <clause id="O" inline-header="false" obligation="normative">
           <title depth="2">5.2.<tab/>Clause 4.2</title>
         </clause></clause>

         </sections><annex id="P" inline-header="false" obligation="normative">
           <title><strong>Annexe A</strong><br/><br/><strong>Annex</strong></title>
           <clause id="Q" inline-header="false" obligation="normative">
           <title depth="2">A.1.<tab/>Annex A.1</title>
           <clause id="Q1" inline-header="false" obligation="normative">
           <title depth="3">A.1.1.<tab/>Annex A.1a</title>
           </clause>
         </clause>
         </annex><bibliography><references id="R" obligation="informative" normative="true">
           <title depth="1">2.<tab/>References</title>
         </references><clause id="S" obligation="informative">
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
<div id="A0">
  <h1 class="IntroTitle">History</h1>
  <p>history</p>
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
               <p class="zzSTDTitle1">Recommendation 12345</p>
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
               <div id="J"><p class="TermNum" id="J"><b>3.1.&#160; Term2</b>:</p>

        </div>
             </div>
               <div id="L" class="Symbols">
                 <h1>4.</h1>
                 <dl>
                   <dt>
                     <p>Symbol</p>
                   </dt>
                   <dd>Definition</dd>
                 </dl>
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
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({}).convert("test", itudoc("fr"), true).gsub(%r{<localized-strings>.*</localized-strings>}m, ""))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", presxml, true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(html)
    end

    it "processes section names in Chinese" do
              presxml = <<~OUTPUT
              <itu-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
                 <bibdata type="standard">
                 <title language="en" format="text/plain" type="main">An ITU Standard</title>
                 <title language="fr" format="text/plain" type="main">Un Standard ITU</title>
                 <docidentifier type="ITU">12345</docidentifier>
                 <language current='true'>zh</language>
                 <script current='true'>Hans</script>
                 <keyword>A</keyword>
                 <keyword>B</keyword>
                 <ext>
                 <doctype language="">recommendation</doctype>
                 <doctype language='zh'>&#x5EFA;&#x8BAE;&#x4E66;</doctype>
                 </ext>
                 </bibdata>
        <preface>
        <abstract><title>Abstract</title>
        <p>This is an abstract</p>
        </abstract>
        <clause id="A0"><title depth="1">History</title>
        <p>history</p>
        </clause>
        <foreword obligation="informative">
           <title>Foreword</title>
           <p id="A">This is a preamble</p>
         </foreword>
          <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
           <title depth="2">Introduction Subsection</title>
         </clause>
         </introduction></preface><sections>
         <clause id="D" obligation="normative" type="scope">
           <title depth="1">1.<tab/>Scope</title>
           <p id="E">Text</p>
         </clause>

         <terms id="I" obligation="normative"><title>3.</title>
           <term id="J"><name>3.1.</name>
           <preferred>Term2</preferred>
         </term>
         </terms>
         <definitions id="L"><title>4.</title>
           <dl>
           <dt>Symbol</dt>
           <dd>Definition</dd>
           </dl>
         </definitions>
         <clause id="M" inline-header="false" obligation="normative"><title depth="1">5.<tab/>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
           <title depth="2">5.1.<tab/>Introduction</title>
         </clause>
         <clause id="O" inline-header="false" obligation="normative">
           <title depth="2">5.2.<tab/>Clause 4.2</title>
         </clause></clause>

         </sections><annex id="P" inline-header="false" obligation="normative">
           <title><strong>&#x9644;&#x4EF6;A</strong><br/><br/><strong>Annex</strong></title>
           <clause id="Q" inline-header="false" obligation="normative">
           <title depth="2">A.1.<tab/>Annex A.1</title>
           <clause id="Q1" inline-header="false" obligation="normative">
           <title depth="3">A.1.1.<tab/>Annex A.1a</title>
           </clause>
         </clause>
         </annex><bibliography><references id="R" obligation="informative" normative="true">
           <title depth="1">2.<tab/>References</title>
         </references><clause id="S" obligation="informative">
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
             <h1 class='AbstractTitle'>Abstract</h1>
             <p>This is an abstract</p>
           </div>
           <div id='A0'>
             <h1 class='IntroTitle'>History</h1>
             <p>history</p>
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
           <p class='zzSTDTitle1'>Recommendation 12345</p>
           <p class='zzSTDTitle2'/>
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
                 <b>3.1.&#12288;Term2</b>
                 : 
               </p>
             </div>
           </div>
           <div id='L' class='Symbols'>
             <h1>4.</h1>
             <dl>
               <dt>
                 <p>Symbol</p>
               </dt>
               <dd>Definition</dd>
             </dl>
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
             <p class='annex_obligation'>
               &#65288;&#26412;&#38468;&#20214;&#19981;&#26500;&#25104;&#26412;Recommendation&#30340;&#19981;&#21487;&#25110;&#32570;&#37096;&#20998;&#65289;
             </p>
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
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({}).convert("test", itudoc("zh"), true).gsub(%r{<localized-strings>.*</localized-strings>}m, ""))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", presxml, true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(html)
  end
end

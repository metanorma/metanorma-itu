require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::ITU do
  it "processes default metadata" do
    csdc = IsoDoc::ITU::HtmlConvert.new({})
    docxml, filename, dir = csdc.convert_init(<<~"INPUT", "test", true)
<itu-standard xmlns="https://www.calconnect.org/standards/itu">
  <bibdata type="standard">
  <title language="en" format="text/plain" type="main">Main Title</title>
  <title language="en" format="text/plain" type="annex">Annex Title</title>
  <title language="fr" format="text/plain" type="main">Titre Principal</title>
  <docidentifier type="ITU-provisional">ABC</docidentifier>
  <docidentifier type="ITU">ITU-R 1000</docidentifier>
  <docnumber>1000</docnumber>
  <contributor>
    <role type="author"/>
    <organization>
      <name>International Telecommunication Union</name>
      <abbreviation>ITU</abbreviation>
    </organization>
  </contributor>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>International Telecommunication Union</name>
      <abbreviation>ITU</abbreviation>
    </organization>
  </contributor>
  <edition>2</edition>
<version>
  <revision-date>2000-01-01</revision-date>
  <draft>3.4</draft>
</version>  
  <language>en</language>
  <script>Latn</script>
  <status>
    <stage>final-draft</stage>
    <iteration>3</iteration>
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
  <series type="main">
  <title>A3</title>
</series>
<series type="secondary">
  <title>B3</title>
</series>
<series type="tertiary">
  <title>C3</title>
</series>
     <keyword>word1</keyword>
 <keyword>word2</keyword>
  <ext>
  <doctype>directive</doctype>
      <editorialgroup>
      <bureau>R</bureau>
      <group type="A">
        <name>I</name>
        <acronym>C</acronym>
        <period>
          <start>E</start>
          <end>G</end>
        </period>
      </group>
      <subgroup type="A1">
        <name>I1</name>
        <acronym>C1</acronym>
        <period>
          <start>E1</start>
          <end>G1</end>
        </period>
      </subgroup>
      <workgroup type="A2">
        <name>I2</name>
        <acronym>C2</acronym>
        <period>
          <start>E2</start>
          <end>G2</end>
        </period>
      </workgroup>
    </editorialgroup>
    <editorialgroup>
      <bureau>T</bureau>
      <group type="B">
        <name>J</name>
        <acronym>D</acronym>
        <period>
          <start>F</start>
          <end>H</end>
        </period>
      </group>
      <subgroup type="B1">
        <name>J1</name>
        <acronym>D1</acronym>
        <period>
          <start>F1</start>
          <end>H1</end>
        </period>
      </subgroup>
      <workgroup type="B2">
        <name>J2</name>
        <acronym>D2</acronym>
        <period>
          <start>F2</start>
          <end>H2</end>
        </period>
      </workgroup>
    </editorialgroup>
 <recommendationstatus>
  <from>D3</from>
  <to>E3</to>
  <approvalstage process="F3">G3</approvalstage>
</recommendationstatus>
<ip-notice-received>false</ip-notice-received>
<structuredidentifier>
<bureau>R</bureau>
<docnumber>1000</docnumber>
<annexid>F1</annexid>
</structuredidentifier>
  </ext>
</bibdata>
<preface/><sections/>
<annex obligation="informative"/>
</itu-standard>
    INPUT
    expect(htmlencode(Hash[csdc.info(docxml, nil).sort].to_s)).to be_equivalent_to <<~"OUTPUT"
    {:accesseddate=>"XXX", :annexid=>"Appendix F1", :annextitle=>"Annex Title", :bureau=>"R", :circulateddate=>"XXX", :confirmeddate=>"XXX", :copieddate=>"XXX", :createddate=>"XXX", :docidentifier=>"ABC", :docnumber=>"1000", :doctitle=>"Main Title", :doctype=>"Directive", :docyear=>"2001", :draft=>"3.4", :draftinfo=>" (draft 3.4, 2000-01-01)", :edition=>"2", :implementeddate=>"XXX", :ip_notice_received=>"false", :issueddate=>"XXX", :iteration=>"3", :keywords=>["word1", "word2"], :obsoleteddate=>"XXX", :pubdate_monthyear=>"", :publisheddate=>"XXX", :receiveddate=>"XXX", :revdate=>"2000-01-01", :revdate_monthyear=>"01/2000", :series=>"A3", :series1=>"B3", :series2=>"C3", :stage=>"Final Draft", :transmitteddate=>"XXX", :unchangeddate=>"XXX", :unpublished=>false, :updateddate=>"XXX"}
    OUTPUT
  end

   it "processes metadata for in-force-prepublished" do
    csdc = IsoDoc::ITU::HtmlConvert.new({})
    docxml, filename, dir = csdc.convert_init(<<~"INPUT", "test", true)
<itu-standard xmlns="https://www.calconnect.org/standards/itu">
  <bibdata type="standard">
  <title language="en" format="text/plain" type="main">Main Title</title>
  <title language="fr" format="text/plain" type="main">Titre Principal</title>
  <docidentifier type="ITU-provisional">ABC</docidentifier>
  <docidentifier type="ITU">ITU-R 1000</docidentifier>
  <docnumber>1000</docnumber>
  <contributor>
    <role type="author"/>
    <organization>
      <name>International Telecommunication Union</name>
      <abbreviation>ITU</abbreviation>
    </organization>
  </contributor>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>International Telecommunication Union</name>
      <abbreviation>ITU</abbreviation>
    </organization>
  </contributor>
  <language>en</language>
  <script>Latn</script>
  <status>
    <stage>in-force-prepublished</stage>
  </status>
INPUT
expect(htmlencode(Hash[csdc.info(docxml, nil).sort].to_s)).to be_equivalent_to <<~"OUTPUT"
    {:accesseddate=>"XXX", :annextitle=>nil, :circulateddate=>"XXX", :confirmeddate=>"XXX", :copieddate=>"XXX", :createddate=>"XXX", :docidentifier=>"ABC", :docnumber=>"1000", :doctitle=>"Main Title", :docyear=>nil, :draft=>nil, :draftinfo=>"", :edition=>nil, :implementeddate=>"XXX", :ip_notice_received=>"false", :issueddate=>"XXX", :keywords=>[], :obsoleteddate=>"XXX", :pubdate_monthyear=>"", :publisheddate=>"XXX", :receiveddate=>"XXX", :revdate=>nil, :revdate_monthyear=>nil, :series=>nil, :series1=>nil, :series2=>nil, :stage=>"In Force Prepublished", :transmitteddate=>"XXX", :unchangeddate=>"XXX", :unpublished=>true, :updateddate=>"XXX"}
    OUTPUT
   end

  it "processes pre" do
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
<itu-standard xmlns="https://www.calconnect.org/standards/itu">
<preface><foreword>
<pre>ABC</pre>
</foreword></preface>
</itu-standard>
    INPUT
    #{HTML_HDR}
             <div>
               <h1 class="IntroTitle"/>
               <pre>ABC</pre>
             </div>
             <p class="zzSTDTitle1"/>
             <p class="zzSTDTitle2"/>
           </div>
         </body>
    OUTPUT
  end

  it "processes keyword" do
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
<itu-standard xmlns="https://www.calconnect.org/standards/itu">
<preface><foreword>
<keyword>ABC</keyword>
</foreword></preface>
</itu-standard>
    INPUT
        #{HTML_HDR}
             <div>
               <h1 class="IntroTitle"/>
               <span class="keyword">ABC</span>
             </div>
             <p class="zzSTDTitle1"/>
             <p class="zzSTDTitle2"/>
           </div>
         </body>
    OUTPUT
  end

  it "processes simple terms & definitions" do
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
               <itu-standard xmlns="http://riboseinc.com/isoxml">
       <preface/><sections>
       <terms id="H" obligation="normative">
         <term id="J">
         <preferred>Term2</preferred>
         <definition><p>This is a journey into sound</p></definition>
         <termsource><origin citeas="XYZ">x y z</origin></termsource>
         <termnote id="J1"><p>This is a note</p></termnote>
       </term>
        </terms>
        </sections>
        </itu-standard>
    INPUT
        #{HTML_HDR}
               <p class="zzSTDTitle1"/>
             <p class="zzSTDTitle2"/>
               <div id="H"><h1>1&#160; Definitions</h1>
               <div id="J"><p class="TermNum" id="J"><b>1.1&#160; Term2</b> [XYZ]: </p><p>This is a journey into sound</p>



         <div class="Note"><p>NOTE 1: This is a note</p></div>
       </div>
        </div>
           </div>
         </body>
    OUTPUT
  end

  it "postprocesses simple terms & definitions" do
        FileUtils.rm_f "test.html"
        FileUtils.rm_f "test.doc"
    IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", false)
               <itu-standard xmlns="http://riboseinc.com/isoxml">
       <preface/><sections>
       <terms id="H" obligation="normative">
         <term id="J">
         <preferred>Term2</preferred>
         <definition><p>This is a journey into sound</p></definition>
         <termsource><origin citeas="XYZ">x y z</origin></termsource>
         <termnote id="J1"><p>This is a note</p></termnote>
       </term>
        </terms>
        </sections>
        </itu-standard>
    INPUT
        expect(xmlpp(File.read("test.html", encoding: "utf-8").to_s.gsub(%r{^.*<main}m, "<main").gsub(%r{</main>.*}m, "</main>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
        <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
             <p class="zzSTDTitle1"></p>
             <p class="zzSTDTitle2"></p>
             <div id="H"><h1>1&#xA0; Definitions</h1>
         <div id="J"><p class="TermNum" id="J"><b>1.1&#xA0; Term2</b> [XYZ]: This is a journey into sound</p>



         <div class="Note"><p>NOTE 1: This is a note</p></div>
       </div>
        </div>
           </main>
    OUTPUT
  end

  it "processes terms & definitions subclauses with external, internal, and empty definitions" do
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
               <itu-standard xmlns="http://riboseinc.com/isoxml">
         <termdocsource type="inline" bibitemid="ISO712"/>
       <preface/><sections>
       <clause id="G"><title>Terms, Definitions, Symbols and Abbreviated Terms</title>
       <terms id="H" obligation="normative"><title>Terms defined in this recommendation</title>
         <term id="J">
         <preferred>Term2</preferred>
       </term>
       </terms>
       <terms id="I" obligation="normative"><title>Terms defined elsewhere</title>
         <term id="K">
         <preferred>Term2</preferred>
       </term>
       </terms>
       <terms id="L" obligation="normative"><title>Other terms</title>
       </terms>
       </clause>
        </sections>
        <bibliography>
        <references id="_normative_references" obligation="informative"><title>References</title>
<bibitem id="ISO712" type="standard">
  <title format="text/plain">Cereals and cereal products?~@~I?~@~T?~@~IDetermination of moisture content?~@~I?~@~T?~@~IReference method</title>
  <docidentifier>ISO 712</docidentifier>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>International Organization for Standardization</name>
    </organization>
  </contributor>
</bibitem></references>
</bibliography>
        </itu-standard>
    INPUT
        #{HTML_HDR}
               <p class="zzSTDTitle1"/>
             <p class="zzSTDTitle2"/>
               <div>
                 <h1>1&#160; References</h1>
                 <p id="ISO712" class="NormRef">[ISO 712]&#160; ISO 712, <i>Cereals and cereal products?~@~I?~@~T?~@~IDetermination of moisture content?~@~I?~@~T?~@~IReference method</i>.</p>
               </div>

<div id="G"><h1>2&#160; Terms, Definitions, Symbols and Abbreviated Terms</h1>
              <div id="H"><h2>2.1&#160; Terms defined in this recommendation</h2>
                <div id="J"><p class="TermNum" id="J"><b>2.1.1&#160; Term2</b>:</p>
     
              </div>
              </div>
              <div id="I"><h2>2.2&#160; Terms defined elsewhere</h2>
                <div id="K"><p class="TermNum" id="K"><b>2.2.1&#160; Term2</b>:</p>
     
              </div>
              </div>
              <div id="L"><h2>2.3&#160; Other terms</h2><p>None.</p></div>
              </div>
           </div>
           </body>
    OUTPUT
  end

    it "rearranges term headers" do
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s)).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <html>
           <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US" class="container">
             <div class="title-section">
               <p>&#160;</p>
             </div>
             <br/>
             <div class="WordSection2">
               <p>&#160;</p>
             </div>
             <br/>
             <div class="WordSection3">
               <p class="zzSTDTitle1"/>
             <p class="zzSTDTitle2"/>
               <div id="H"><h1>1.&#160; Terms and definitions</h1><p>For the purposes of this document,
           the following terms and definitions apply.</p>
       <p class="TermNum" id="J">1.1.</p>
         <p class="Terms" style="text-align:left;">Term2</p>
       </div>
             </div>
           </body>
           </html>
           INPUT
                 <?xml version="1.0"?>
       <html>
              <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US" class="container">
                <div class="title-section">
                  <p>&#xA0;</p>
                </div>
                <br/>
                <div class="WordSection2">
                  <p>&#xA0;</p>
                </div>
                <br/>
                <div class="WordSection3">
                  <p class="zzSTDTitle1"/>
             <p class="zzSTDTitle2"/>
                  <div id="H"><h1>1.&#xA0; Terms and definitions</h1><p>For the purposes of this document,
              the following terms and definitions apply.</p>
          <p class="TermNum" id="J">1.1.&#xA0;<p class="Terms" style="text-align:left;">Term2</p></p>

          </div>
                </div>
              </body>
              </html>
    OUTPUT
  end

   it "processes IsoXML footnotes (Word)" do
     expect(xmlpp(IsoDoc::ITU::WordConvert.new({}).convert("test", <<~"INPUT", true).sub(%r{^.*<body }m, "<body xmlns:epub='epub' ").sub(%r{</body>.*$}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <itu-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
    <p>A.<fn reference="2">
  <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
</fn></p>
    <p>B.<fn reference="2">
  <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
</fn></p>
    <p>C.<fn reference="1">
  <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Hello! denoted as 15 % (m/m).</p>
</fn></p>
    </foreword>
    </preface>
    </itu-standard>
    INPUT
    <body xmlns:epub="epub" lang="EN-US" link="blue" vlink="#954F72">
           <div class="WordSection1">
             <p>&#160;</p>
           </div>
           <p>
             <br clear="all" class="section"/>
           </p>
           <div class="WordSection2">
             <div>
               <h1 class="IntroTitle"/>
               <p>A.<a href="#ftn1" epub:type="footnote"><sup>1</sup></a></p>
               <p>B.<a href="#ftn2" epub:type="footnote"><sup>2</sup></a></p>
               <p>C.<a href="#ftn3" epub:type="footnote"><sup>3</sup></a></p>
             </div>
             <p>&#160;</p>
           </div>
           <p>
             <br clear="all" class="section"/>
           </p>
           <div class="WordSection3">
             <p class="zzSTDTitle1"/>
             <p class="zzSTDTitle2"/>
             <aside id="ftn1">
         <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
       </aside>
             <aside id="ftn2">
         <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
       </aside>
             <aside id="ftn3">
         <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Hello! denoted as 15 % (m/m).</p>
       </aside>
           </div>
         </body>
    OUTPUT
  end

  it "cleans up footnotes (Word)" do
    FileUtils.rm_f "test.doc"
    IsoDoc::ITU::WordConvert.new({}).convert("test", <<~"INPUT", false)
    <itu-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
    <p>A.<fn reference="2">
  <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
</fn></p>
    <p>B.<fn reference="2">
  <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
</fn></p>
    <p>C.<fn reference="1">
  <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Hello! denoted as 15 % (m/m).</p>
</fn></p>
    </foreword>
    </preface>
    </itu-standard>
    INPUT
     expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc", encoding: "UTF-8")
    expect(xmlpp(html.sub(%r{^.*<div style="mso-element:footnote-list">}m, '<div style="mso-element:footnote-list">').sub(%r{</body>.*$}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
           <div style="mso-element:footnote-list"><div style="mso-element:footnote" id="ftn1">

         <p class="MsoFootnoteText"><a name="_1e228e29-baef-4f38-b048-b05a051747e4" id="_1e228e29-baef-4f38-b048-b05a051747e4"></a><a style="mso-footnote-id:ftn1" href="#_ftn1" name="_ftnref1" title="" id="_ftnref1"><span class="MsoFootnoteReference"><span style="mso-special-character:footnote"></span></span></a><span style="mso-tab-count:1"></span>Formerly denoted as 15 % (m/m).</p>
       </div>
       <div style="mso-element:footnote" id="ftn2">

         <p class="MsoFootnoteText"><a name="_1e228e29-baef-4f38-b048-b05a051747e4" id="_1e228e29-baef-4f38-b048-b05a051747e4"></a><a style="mso-footnote-id:ftn2" href="#_ftn2" name="_ftnref2" title="" id="_ftnref2"><span class="MsoFootnoteReference"><span style="mso-special-character:footnote"></span></span></a><span style="mso-tab-count:1"></span>Formerly denoted as 15 % (m/m).</p>
       </div>
       <div style="mso-element:footnote" id="ftn3">

         <p class="MsoFootnoteText"><a name="_1e228e29-baef-4f38-b048-b05a051747e4" id="_1e228e29-baef-4f38-b048-b05a051747e4"></a><a style="mso-footnote-id:ftn3" href="#_ftn3" name="_ftnref3" title="" id="_ftnref3"><span class="MsoFootnoteReference"><span style="mso-special-character:footnote"></span></span></a><span style="mso-tab-count:1"></span>Hello! denoted as 15 % (m/m).</p>
       </div>
       </div>
OUTPUT
  end


 def itudoc(lang)
<<~"INPUT"
               <itu-standard xmlns="http://riboseinc.com/isoxml">
               <bibdata type="standard">
               <title language="en" format="text/plain" type="main">An ITU Standard</title>
               <docidentifier>12345</docidentifier>
               <language>#{lang}</language>
               <keyword>A</keyword>
               <keyword>B</keyword>
               <ext>
               </ext>
               </bibdata>
      <preface>
      <abstract><title>Abstract</title>
      <p>This is an abstract</p>
      </abstract>
      <clause id="A0"><title>History</title>
      <p>history</p>
      </clause>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble</p>
       </foreword>
        <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       </introduction></preface><sections>
       <clause id="D" obligation="normative">
         <title>Scope</title>
         <p id="E">Text</p>
       </clause>

       <terms id="I" obligation="normative">
         <term id="J">
         <preferred>Term2</preferred>
       </term>
       </terms>
       <definitions id="L">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       <clause id="M" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
         <title>Introduction</title>
       </clause>
       <clause id="O" inline-header="false" obligation="normative">
         <title>Clause 4.2</title>
       </clause></clause>

       </sections><annex id="P" inline-header="false" obligation="normative">
         <title>Annex</title>
         <clause id="Q" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
         <clause id="Q1" inline-header="false" obligation="normative">
         <title>Annex A.1a</title>
         </clause>
       </clause>
       </annex><bibliography><references id="R" obligation="informative">
         <title>References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </itu-standard>
    INPUT
 end

       it "processes annexes and appendixes" do
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
               <itu-standard xmlns="http://riboseinc.com/isoxml">
               <bibdata type="standard">
               <title language="en" format="text/plain" type="main">An ITU Standard</title>
               <docidentifier>12345</docidentifier>
               <language>en</language>
               <keyword>A</keyword>
               <keyword>B</keyword>
               <ext>
               </ext>
               </bibdata>
               <preface>
               <abstract>
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
        #{HTML_HDR}
        <br/>
        <div>
               <h1 class="AbstractTitle">Abstract</h1>
               <a href="#A1">Annex A</a>
               <a href="#B1">Appendix I</a>
             </div>
        <p class="zzSTDTitle1">Recommendation 12345</p>
             <p class="zzSTDTitle2">An ITU Standard</p>
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
       end

      it "processes section names" do
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", itudoc("en"), true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
               <p class="zzSTDTitle2">An ITU Standard</p>
               <div id="D">
                 <h1>1&#160; Scope</h1>
                 <p id="E">Text</p>
               </div>
               <div>
                 <h1>2&#160; References</h1>
               </div>
               <div id="I">
               <h1>3&#160; Definitions</h1>
               <div id="J"><p class="TermNum" id="J"><b>3.1&#160; Term2</b>:</p>

        </div>
             </div>
               <div id="L" class="Symbols">
                 <h1>4&#160; Symbols and abbreviated terms</h1>
                 <dl>
                   <dt>
                     <p>Symbol</p>
                   </dt>
                   <dd>Definition</dd>
                 </dl>
               </div>
               <div id="M">
                 <h1>5&#160; Clause 4</h1>
                 <div id="N">
          <h2>5.1&#160; Introduction</h2>
        </div>
                 <div id="O">
          <h2>5.2&#160; Clause 4.2</h2>
        </div>
               </div>
               <br/>
               <div id="P" class="Section3">
                 <h1 class="Annex"><b>Annex A</b> <br/><br/><b>Annex</b></h1>
                 <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
                 <div id="Q">
          <h2>A.1&#160; Annex A.1</h2>
          <div id="Q1">
          <h3>A.1.1&#160; Annex A.1a</h3>
          </div>
        </div>
               </div>
               <br/>
               <div>
                 <h1 class="Section3">Bibliography</h1>
                 <div>
                   <h2 class="Section3">Bibliography Subsection</h2>
                 </div>
               </div>
             </div>
           </body>
    OUTPUT
  end

            it "processes section names in French" do
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", itudoc("fr"), true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
        #{HTML_HDR}
        <br/>
        <div>
  <h1 class="AbstractTitle">R&#233;sum&#233;</h1>
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
               <p class="zzSTDTitle2">An ITU Standard</p>
               <div id="D">
                 <h1>1&#160; Domaine d'application</h1>
                 <p id="E">Text</p>
               </div>
               <div>
                 <h1>2&#160; References</h1>
               </div>
               <div id="I">
               <h1>3&#160; Definitions</h1>
               <div id="J"><p class="TermNum" id="J"><b>3.1&#160; Term2</b>:</p>

        </div>
             </div>
               <div id="L" class="Symbols">
                 <h1>4&#160; Symboles et termes abr&#233;g&#233;s</h1>
                 <dl>
                   <dt>
                     <p>Symbol</p>
                   </dt>
                   <dd>Definition</dd>
                 </dl>
               </div>
               <div id="M">
                 <h1>5&#160; Clause 4</h1>
                 <div id="N">
          <h2>5.1&#160; Introduction</h2>
        </div>
                 <div id="O">
          <h2>5.2&#160; Clause 4.2</h2>
        </div>
               </div>
               <br/>
               <div id="P" class="Section3">
                 <h1 class="Annex"><b>Annexe A</b> <br/><br/><b>Annex</b></h1>
                <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
                 <div id="Q">
          <h2>A.1&#160; Annex A.1</h2>
          <div id="Q1">
          <h3>A.1.1&#160; Annex A.1a</h3>
          </div>
        </div>
               </div>
               <br/>
               <div>
                 <h1 class="Section3">Bibliographie</h1>
                 <div>
                   <h2 class="Section3">Bibliography Subsection</h2>
                 </div>
               </div>
             </div>
           </body>
    OUTPUT
  end

      it "processes section names (Word)" do
    expect(xmlpp(IsoDoc::ITU::WordConvert.new({}).convert("test", itudoc("en"), true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
           <body lang="EN-US" link="blue" vlink="#954F72">
           <div class="WordSection1">
             <p>&#160;</p>
           </div>
           <p>
             <br clear="all" class="section"/>
           </p>
           <div class="WordSection2">
             <div>
               <h1 class="AbstractTitle">Summary</h1>
               <p>This is an abstract</p>
             </div>
             <div id="A0">
  <h1 class="IntroTitle">History</h1>
  <p>history</p>
</div>
             <div>
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
             <p>&#160;</p>
           </div>
           <p>
             <br clear="all" class="section"/>
           </p>
           <div class="WordSection3">
             <p class="zzSTDTitle1">Recommendation 12345</p>
             <p class="zzSTDTitle2">An ITU Standard</p>
             <div id="D">
               <h1>1<span style="mso-tab-count:1">&#160; </span>Scope</h1>
               <p id="E">Text</p>
             </div>
             <div>
               <h1>2<span style="mso-tab-count:1">&#160; </span>References</h1>
             </div>
             <div id="I"><h1>3<span style="mso-tab-count:1">&#160; </span>Definitions</h1>
          <div id="J"><p class="TermNum" id="J"><b>3.1<span style="mso-tab-count:1">&#160; </span>Term2</b>: </p>
     
        </div>
        </div>
             <div id="L" class="Symbols">
               <h1>4<span style="mso-tab-count:1">&#160; </span>Symbols and abbreviated terms</h1>
               <table class="dl">
                 <tr>
                   <td valign="top" align="left">
                     <p align="left" style="margin-left:0pt;text-align:left;">Symbol</p>
                   </td>
                   <td valign="top">Definition</td>
                 </tr>
               </table>
             </div>
             <div id="M">
               <h1>5<span style="mso-tab-count:1">&#160; </span>Clause 4</h1>
               <div id="N"><h2>5.1<span style="mso-tab-count:1">&#160; </span>Introduction</h2>
     
        </div>
               <div id="O"><h2>5.2<span style="mso-tab-count:1">&#160; </span>Clause 4.2</h2>
     
        </div>
             </div>
             <p>
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
             </p>
             <div id="P" class="Section3">
               <h1 class="Annex"><b>Annex A</b> <br/><br/><b>Annex</b></h1>
                <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
               <div id="Q"><h2>A.1<span style="mso-tab-count:1">&#160; </span>Annex A.1</h2>
     
          <div id="Q1"><h3>A.1.1<span style="mso-tab-count:1">&#160; </span>Annex A.1a</h3>
     
          </div>
        </div>
             </div>
             <p>
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
             </p>
             <div>
               <h1 class="Section3">Bibliography</h1>
               <div>
                 <h2 class="Section3">Bibliography Subsection</h2>
               </div>
             </div>
           </div>
         </body>
    OUTPUT
      end

            it "post-processes section names (Word)" do
              FileUtils.rm_f "test.doc"
    IsoDoc::ITU::WordConvert.new({}).convert("test", itudoc("en"), false)
     expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc", encoding: "UTF-8")
expect(xmlpp(html.gsub(%r{^.*<div>\s*<a name="abstractbox"}m, %{<div><a name="abstractbox"}).gsub(%r{</div>.*}m, "</div></div>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
<div><a name="abstractbox" id="abstractbox"></a>
         <div>
               <p class="h1Preface">Summary</p>
               <p class="Normalaftertitle">This is an abstract</p>
             </div></div>
OUTPUT
expect(xmlpp(html.gsub(%r{^.*<div>\s*<a name="keywordsbox"}m, %{<div><a name="keywordsbox"}).gsub(%r{</div>.*}m, "</div></div>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
<div><a name="keywordsbox" id="keywordsbox"></a>
    <div>
        <p class="h1Preface">Keywords</p>
        <p class="Normalaftertitle">A, B.</p>
      </div></div>
OUTPUT
expect(xmlpp(html.gsub(%r{^.*<div>\s*<a name="historybox"}m, %{<div><a name="historybox"}).gsub(%r{</div>.*}m, "</div></div>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
<div><a name="historybox" id="historybox"></a>
   <div><a name="A0" id="A0"></a>
       <p class="h1Preface">History</p>
       <p class="Normalaftertitle">history</p>
     </div></div>
OUTPUT
expect(xmlpp(html.gsub(%r{^.*<h1>}m, %{<div><h1>}).gsub(%r{</div>.*}m, "</div></div>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
<div>
<h1>5<span style="mso-tab-count:1">&#xA0; </span>Clause 4</h1>
        <div><a name="N" id="N"></a><h2>5.1<span style="mso-tab-count:1">&#xA0; </span>Introduction</h2>

 </div>
 </div>
OUTPUT
            end

  it "injects JS into blank html" do
    FileUtils.rm_f "test.html"
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
    INPUT
    #{BLANK_HDR}
<preface/><sections/>
</itu-standard>
    OUTPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r{jquery\.min\.js})
    expect(html).to match(%r{Open Sans})
    expect(html).to match(%r{<main class="main-section"><button})
  end

    it "processes eref types" do
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <itu-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p>
    <eref type="footnote" bibitemid="ISO712" citeas="ISO 712">A</eref>
    <eref type="inline" bibitemid="ISO712" citeas="ISO 712">A</eref>
    <eref type="footnote" bibitemid="ISO712" citeas="ISO 712"></eref>
    <eref type="inline" bibitemid="ISO712" citeas="ISO 712"></eref>
    <eref type="footnote" bibitemid="ISO712" citeas="ISO 712"><locality type="section"><referenceFrom>8</referenceFrom></locality></eref>
    <eref type="inline" bibitemid="ISO712" citeas="ISO 712"><locality type="section"><referenceFrom>8</referenceFrom></locality></eref>
    </p>
    </foreword></preface>
    <bibliography><references id="_normative_references" obligation="informative"><title>References</title>
<bibitem id="ISO712" type="standard">
  <title format="text/plain">Cereals and cereal products</title>
  <docidentifier>ISO 712</docidentifier>
  <date type="published">2019-01-01</date>
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
    #{HTML_HDR}
               <div>
                 <h1 class="IntroTitle"/>
                 <p>
           <sup><a href="#ISO712">A</a></sup>
           <a href="#ISO712">A</a>
           <sup><a href="#ISO712">[ISO 712]</a></sup>
        <a href="#ISO712">[ISO 712]</a>
        <sup><a href="#ISO712">[ISO 712], Section 8</a></sup>
        <a href="#ISO712">[ISO 712], Section 8</a>

           </p>
               </div>
               <p class="zzSTDTitle1"/>
               <p class="zzSTDTitle2"/>
               <div>
                              <h1>1&#160; References</h1>
               <p id="ISO712" class="NormRef">[ISO 712]&#160; ISO 712 (2019), <i>Cereals and cereal products</i>.</p>
             </div>
           </div>
         </body>
    OUTPUT
  end

           it "processes annex with supplied annexid" do
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
               <itu-standard xmlns="http://riboseinc.com/isoxml">
               <bibdata type="standard">
               <title language="en" format="text/plain" type="main">An ITU Standard</title>
               <docidentifier>12345</docidentifier>
               <language>en</language>
               <keyword>A</keyword>
               <keyword>B</keyword>
               <ext>
               <structuredidentifier>
               <annexid>F2</annexid>
               </structuredidentifier>
               </ext>
               </bibdata>
        <annex id="A1" obligation="normative">
                <title>Annex</title>
                <clause id="A2"><title>Subtitle</title>
                <table id="T"/>
                <figure id="U"/>
                <formula id="V"><stem type="AsciiMath">r = 1 %</stem></formula>
                </clause>
        </annex>
    INPUT
        #{HTML_HDR}
        <p class="zzSTDTitle1">Recommendation 12345</p>
             <p class="zzSTDTitle2">An ITU Standard</p>
             <br/>
             <div id="A1" class="Section3">
               <h1 class="Annex"><b>Annex F2</b> <br/><br/><b>Annex</b></h1>
                <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
               <div id="A2"><h2>F2.1&#160; Subtitle</h2>
               <p class="TableTitle" style="text-align:center;">Table F2-1</p><table id="T" class="MsoISOTable" style="border-width:1px;border-spacing:0;"/>
               <div id="U" class="figure"><p class="FigureTitle" style="text-align:center;">Figure F2-1</p></div>
               <div id="V" class="formula"><p><span class="stem">(#(r = 1 %)#)</span>&#160; (F2-1)</p></div>
               </div>
             </div>
           </div>
         </body>

OUTPUT
           end

       it "cross-references formulae" do
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
            <itu-standard xmlns="http://riboseinc.com/isoxml">
            <preface>
    <foreword>
    <p>
    <xref target="N1"/>
    <xref target="N2"/>
    </p>
    </foreword>
    <introduction id="intro">
    <formula id="N1">
  <stem type="AsciiMath">r = 1 %</stem>
  </formula>
  <clause id="xyz"><title>Preparatory</title>
    <formula id="N2" inequality="true">
  <stem type="AsciiMath">r = 1 %</stem>
  </formula>
</clause>
    </introduction>
    </itu-standard>
    INPUT
            #{HTML_HDR}
            <div>
               <h1 class="IntroTitle"/>
               <p>
           <a href="#N1">Equation (1) in Introduction</a>
           <a href="#N2">Inequality (2) in Preparatory</a>
           </p>
             </div>
             <div id="intro"><h1 class="IntroTitle"/><div id="N1" class="formula"><p><span class="stem">(#(r = 1 %)#)</span>&#160; (1)</p></div>

         <div id="xyz"><h2>Preparatory</h2>
           <div id="N2" class="formula"><p><span class="stem">(#(r = 1 %)#)</span>&#160; (2)</p></div>


       </div></div>
             <p class="zzSTDTitle1"/>
             <p class="zzSTDTitle2"/>
           </div>
         </body>

    OUTPUT
       end

              it "cross-references annex subclauses" do
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
        <itu-standard xmlns="http://riboseinc.com/isoxml">
               <bibdata type="standard">
               <title language="en" format="text/plain" type="main">An ITU Standard</title>
               <docidentifier>12345</docidentifier>
               <language>en</language>
               <keyword>A</keyword>
               <keyword>B</keyword>
               <ext>
               <structuredidentifier>
               <annexid>F2</annexid>
               </structuredidentifier>
               </ext>
               </bibdata>
               <preface>
      <abstract><title>Abstract</title>
      <p>
      <xref target="A1"/>
    <xref target="A2"/>
    </p>
      </abstract>
               <sections>
               </sections>
        <annex id="A1" obligation="normative">
                <title>Annex</title>
                <clause id="A2"><title>Subtitle</title>
                </clause>
        </annex>
    INPUT
            #{HTML_HDR}
             <br/>
             <div>
               <h1 class="AbstractTitle">Abstract</h1>
               <p>
         <a href="#A1">Annex F2</a>
       <a href="#A2">Clause F2.1</a>
       </p>
             </div>
             <div>
               <h1 class="IntroTitle"/>
             </div>
             <div id="A1">
               <h1 class="IntroTitle">Annex</h1>
               <div id="A2"><h2>F2.1&#160; Subtitle</h2>
                   </div>
             </div>
             <p class="zzSTDTitle1">Recommendation 12345</p>
             <p class="zzSTDTitle2">An ITU Standard</p>
             <br/>
             <div id="A1" class="Section3">
               <h1 class="Annex"><b>Annex F2</b> <br/><br/><b>Annex</b></h1>
<p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
               <div id="A2"><h2>F2.1&#160; Subtitle</h2>
                   </div>
             </div>
           </div>
         </body>

    OUTPUT
       end

                it "processes IsoXML bibliographies" do
                      expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <itu-standard xmlns="http://riboseinc.com/isoxml">
    <bibdata>
    <language>en</language>
    </bibdata>
    <preface><foreword>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
  <eref bibitemid="ISO712"/>
  </p>
    </foreword></preface>
    <bibliography><references id="_normative_references" obligation="informative"><title>References</title>
    <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
<bibitem id="ISO712" type="standard">
  <title format="text/plain">Cereals or cereal products</title>
  <title type="main" format="text/plain">Cereals and cereal products</title>
  <docidentifier type="ISO">ISO 712</docidentifier>
  <date type="published">2001-01</date>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>International Organization for Standardization</name>
    </organization>
  </contributor>
</bibitem>
<bibitem id="ITU712" type="standard">
  <title format="text/plain">Cereals or cereal products</title>
  <title type="main" format="text/plain">Cereals and cereal products</title>
  <docidentifier type="ITU">ITU 712</docidentifier>
  <docidentifier type="DOI">DOI 712</docidentifier>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>International Organization for Standardization</name>
    </organization>
  </contributor>
</bibitem>
<bibitem id="ITU712" type="standard">
  <title format="text/plain">Cereals or cereal products</title>
  <title type="main" format="text/plain">Cereals and cereal products</title>
  <docidentifier type="ISO">ISO 712</docidentifier>
  <docidentifier type="ITU">ITU 712</docidentifier>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>International Organization for Standardization</name>
    </organization>
  </contributor>
</bibitem>
</references>
</bibliography>
</itu-standard>
INPUT
            #{HTML_HDR}
    <div>
               <h1 class="IntroTitle"/>
               <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
         <a href="#ISO712">[ISO 712]</a>
         </p>
             </div>
             <p class="zzSTDTitle1"/>
             <p class="zzSTDTitle2"/>
             <div>
               <h1>1&#160; References</h1>
               <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
               <p id="ISO712" class="NormRef">[ISO 712]&#160; ISO 712 (2001), <i>Cereals and cereal products</i>.</p>
               <p id="ITU712" class="NormRef">[ITU 712]&#160; Recommendation ITU 712, <i>Cereals and cereal products</i>.</p>
               <p id="ITU712" class="NormRef">[ITU 712]&#160; Recommendation ITU 712 | ISO 712, <i>Cereals and cereal products</i>.</p>
             </div>
           </div>
         </body>

            OUTPUT
                end

  it "processes formulae (Word)" do
    expect(xmlpp(IsoDoc::ITU::WordConvert.new({}).convert("test", <<~"INPUT", true).gsub(/.*<h1 class="IntroTitle"\/>/m, "<div>").sub(/<p>&#160;<\/p>.*$/m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <formula id="_be9158af-7e93-4ee2-90c5-26d31c181934" unnumbered="true">
  <stem type="AsciiMath">r = 1 %</stem>
<dl id="_e4fe94fe-1cde-49d9-b1ad-743293b7e21d">
  <dt>
    <stem type="AsciiMath">r</stem>
  </dt>
  <dd>
    <p id="_1b99995d-ff03-40f5-8f2e-ab9665a69b77">is the repeatability limit.</p>
  </dd>
</dl>
    </formula>
    </foreword></preface>
    </iso-standard>
    INPUT
    <div>
    <div id="_be9158af-7e93-4ee2-90c5-26d31c181934" class="formula"><p class="formula"><span style="mso-tab-count:2">&#160; </span><span class="stem">(#(r = 1 %)#)</span></p></div><p>where:</p><table class="dl"><tr><td valign="top" align="left"><p align="left" style="margin-left:0pt;text-align:left;">
           <span class="stem">(#(r)#)</span>
         </p></td><td valign="top">
           <p id="_1b99995d-ff03-40f5-8f2e-ab9665a69b77">is the repeatability limit.</p>
         </td></tr></table>


           </div>
OUTPUT
  end

    it "processes tables (Word)" do
      expect(xmlpp(IsoDoc::ITU::WordConvert.new({}).convert("test", <<~"INPUT", true).gsub(/.*<h1 class="IntroTitle"\/>/m, "<div>").sub(/<p>\s*<br clear="all".*$/m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <table id="tableD-1" alt="tool tip" summary="long desc">
  <name>Repeatability and reproducibility of <em>husked</em> rice yield</name>
  <thead>
    <tr>
      <td rowspan="2" align="left">Description</td>
      <td colspan="4" align="center">Rice sample</td>
    </tr>
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
    </thead>
    <tbody>
    <tr>
      <th align="left">Number of laboratories retained after eliminating outliers</td>
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
      <td align="center">6,06</td>
    </tr>
  </tfoot>
  <dl>
  <dt>Drago</dt>
<dd>A type of rice</dd>
</dl>
<note><p>This is a table about rice</p></note>
</table>
    </foreword></preface>
    </iso-standard>
    INPUT
    <div>
<p class="TableTitle" style="text-align:center;">Table 1&#160;&#8212; Repeatability and reproducibility of <i>husked</i> rice yield</p>
               <div align="center">
                 <table id="tableD-1" class="MsoISOTable" style="mso-table-lspace:15.0cm;margin-left:423.0pt;mso-table-rspace:15.0cm;margin-right:423.0pt;mso-table-bspace:14.2pt;mso-table-anchor-vertical:paragraph;mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;" title="tool tip" summary="long desc">
                   <thead>
                     <tr>
                       <td rowspan="2" align="left" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">Description</td>
                       <td colspan="4" align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;" valign="top">Rice sample</td>
                     </tr>
                     <tr>
                       <td align="left" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">Arborio</td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">Drago<a href="#tableD-1a" class="TableFootnoteRef">a</a><aside><div id="ftntableD-1a"><span><span id="tableD-1a" class="TableFootnoteRef">a)</span><span style="mso-tab-count:1">&#160; </span></span>
         <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p>
       </div></aside></td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">Balilla<a href="#tableD-1a" class="TableFootnoteRef">a</a></td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">Thaibonnet</td>
                     </tr>
                   </thead>
                   <tbody>
                     <tr>
                       <th align="left" style="font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;" valign="top">Number of laboratories retained after eliminating outliers</th>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;" valign="top">13</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;" valign="top">11</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;" valign="top">13</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;" valign="top">13</td>
                     </tr>
                     <tr>
                       <td align="left" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">Mean value, g/100 g</td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">81,2</td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">82,0</td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">81,8</td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">77,7</td>
                     </tr>
                   </tbody>
                   <tfoot>
                     <tr>
                       <td align="left" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">Reproducibility limit, <span class="stem">(#(R)#)</span> (= 2,83 <span class="stem">(#(s_R)#)</span>)</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">2,89</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">0,57</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">2,26</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">6,06</td>
                     </tr>
                   </tfoot>
                   <table class="dl">
                     <tr>
                       <td valign="top" align="left">
                         <p align="left" style="margin-left:0pt;text-align:left;">Drago</p>
                       </td>
                       <td valign="top">A type of rice</td>
                     </tr>
                   </table>
                   <div id="" class="Note">
                     <p class="Note"><span class="note_label">NOTE</span><span style="mso-tab-count:1">&#160; </span>This is a table about rice</p>
                   </div>
                 </table>
               </div>
             </div>
             <p>&#160;</p>
             </div>
OUTPUT
  end

    it "processes history tables (Word)" do
FileUtils.rm_f "test.doc"
      IsoDoc::ITU::WordConvert.new({}).convert("test", <<~"INPUT", false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><clause id="_history" obligation="normative">
  <title>History</title>
  <table id="_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4">
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
      expect(xmlpp(html.gsub(%r{.*<p class="h1Preface">History</p>}m, '<div><p class="h1Preface">History</p>').sub(%r{</table>.*$}m, "</table></div></div>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <div>
      <p class="h1Preface">History</p>
               <p class="TableTitle" style="text-align:center;">Table 1</p>
               <div align="center">
                 <table class="MsoNormalTable" style="mso-table-lspace:15.0cm;margin-left:423.0pt;mso-table-rspace:15.0cm;margin-right:423.0pt;mso-table-bspace:14.2pt;mso-table-anchor-vertical:paragraph;mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;"><a name="_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4" id="_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4"></a>
                   <tbody>
                     <tr>
                       <td align="left" style="" valign="top">Edition</td>
                       <td align="left" style="" valign="top">Recommendation</td>
                       <td align="left" style="" valign="top">Approval</td>
                       <td align="left" style="" valign="top">Study Group</td>
                       <td align="left" style="" valign="top">Unique ID<a href="#_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4a" class="TableFootnoteRef">a</a>.</td>
                     </tr>
                     <tr>
                       <td align="left" style="" valign="top">1.0</td>
                       <td align="left" style="" valign="top">ITU-T G.650</td>
                       <td align="left" style="" valign="top">1993-03-12</td>
                       <td align="left" style="" valign="top">XV</td>
                       <td align="left" style="" valign="top">
               <a href="http://handle.itu.int/11.1002/1000/879">11.1002/1000/879</a>
             </td>
                     </tr>
                   </tbody>
                 <tfoot><tr><td colspan="5" style=""><div class="TableFootnote"><div><a name="ftn_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4a" id="ftn_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4a"></a>
         <p class="TableFootnote"><a name="_8a4ff03f-e7a6-4430-939d-1b7b0ffa60e9" id="_8a4ff03f-e7a6-4430-939d-1b7b0ffa60e9"></a><span><span class="TableFootnoteRef"><a name="_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4a" id="_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4a"></a>a)</span><span style="mso-tab-count:1">&#xA0; </span></span>To access the Recommendation, type the URL <a href="http://handle.itu.int/">http://handle.itu.int/</a> in the address field of your web browser, followed by the Recommendation?~@~Ys unique ID. For example, <a href="http://handle.itu.int/11.1002/1000/11830-en">http://handle.itu.int/11.1002/1000/11830-en</a></p>
       </div></div></td></tr></tfoot></table>
       </div></div>
      OUTPUT
    end

      it "cross-references subfigures" do
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
    <foreword id="fwd">
    <p>
    <xref target="N"/>
    <xref target="note1"/>
    <xref target="note2"/>
    <xref target="AN"/>
    <xref target="Anote1"/>
    <xref target="Anote2"/>
    </p>
    </foreword>
    </preface>
    <sections>
    <clause id="scope"><title>Scope</title>
    </clause>
    <terms id="terms"/>
    <clause id="widgets"><title>Widgets</title>
    <clause id="widgets1">
    <figure id="N">
        <figure id="note1">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
  </figure>
    <figure id="note2">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
  </figure>
  </figure>
  <p>    <xref target="note1"/> <xref target="note2"/> </p>
    </clause>
    </clause>
    </sections>
    <annex id="annex1">
    <clause id="annex1a">
    </clause>
    <clause id="annex1b">
    <figure id="AN">
        <figure id="Anote1">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
  </figure>
    <figure id="Anote2">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
  </figure>
  </figure>
    </clause>
    </annex>
    </iso-standard>
    INPUT
        #{HTML_HDR}
        <div id="fwd">
               <h1 class="IntroTitle"/>
               <p>
         <a href="#N">Figure 1</a>
         <a href="#note1">Figure 1-b</a>
         <a href="#note2">Figure 1-c</a>
         <a href="#AN">Figure A-1</a>
         <a href="#Anote1">Figure A-1-b</a>
         <a href="#Anote2">Figure A-1-c</a>
         </p>
             </div>
             <p class="zzSTDTitle1"/>
             <p class="zzSTDTitle2"/>
             <div id="scope">
               <h1>1&#160; Scope</h1>
             </div>
             <div id="terms">
               <h1>2&#160; Definitions</h1>
               <p>None.</p>
             </div>
             <div id="widgets">
               <h1>3&#160; Widgets</h1>
               <div id="widgets1"><h2>3.1&#160; </h2>
         <div id="N" class="figure">
             <div id="note1" class="figure">

       <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
       <p class="FigureTitle" style="text-align:center;">Figure 1-b&#160;&#8212; Split-it-right sample divider</p></div>
         <div id="note2" class="figure">

       <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
       <p class="FigureTitle" style="text-align:center;">Figure 1-c&#160;&#8212; Split-it-right sample divider</p></div>
       </div>
       <p>    <a href="#note1">Figure 1-b</a> <a href="#note2">Figure 1-c</a> </p>
         </div>
             </div>
             <br/>
             <div id="annex1" class="Section3">
               <div id="annex1a"><h2>A.1&#160; </h2>
         </div>
               <div id="annex1b"><h2>A.2&#160; </h2>
         <div id="AN" class="figure">
             <div id="Anote1" class="figure">

       <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
       <p class="FigureTitle" style="text-align:center;">Figure A-1-b&#160;&#8212; Split-it-right sample divider</p></div>
         <div id="Anote2" class="figure">

       <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
       <p class="FigureTitle" style="text-align:center;">Figure A-1-c&#160;&#8212; Split-it-right sample divider</p></div>
       </div>
         </div>
             </div>
           </div>
         </body>
OUTPUT
      end

it "processes hierarchical assets" do
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({hierarchical_assets: true}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
    <foreword id="fwd">
    <p>
    <xref target="N"/>
    <xref target="note1"/>
    <xref target="note2"/>
    <xref target="AN"/>
    <xref target="Anote1"/>
    <xref target="Anote2"/>
    </p>
    </foreword>
    </preface>
    <sections>
    <clause id="scope"><title>Scope</title>
    </clause>
    <terms id="terms"/>
    <clause id="widgets"><title>Widgets</title>
    <clause id="widgets1">
    <figure id="N">
        <figure id="note1">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
  </figure>
    <figure id="note2">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
  </figure>
  </figure>
  <p>    <xref target="note1"/> <xref target="note2"/> </p>
    </clause>
    </clause>
    </sections>
    <annex id="annex1">
    <clause id="annex1a">
    </clause>
    <clause id="annex1b">
    <figure id="AN">
        <figure id="Anote1">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
  </figure>
    <figure id="Anote2">
  <name>Split-it-right sample divider</name>
  <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
  </figure>
  </figure>
    </clause>
    </annex>
    </iso-standard>
    INPUT
    <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US" class="container">
           <div class="title-section">
             <p>&#160;</p>
           </div>
           <br/>
           <div class="prefatory-section">
             <p>&#160;</p>
           </div>
           <br/>
           <div class="main-section">
             <div id="fwd">
               <h1 class="IntroTitle"/>
               <p>
         <a href="#N">Figure 3-1</a>
         <a href="#note1">Figure 3-1-b</a>
         <a href="#note2">Figure 3-1-c</a>
         <a href="#AN">Figure A-1</a>
         <a href="#Anote1">Figure A-1-b</a>
         <a href="#Anote2">Figure A-1-c</a>
         </p>
             </div>
             <p class="zzSTDTitle1"/>
             <p class="zzSTDTitle2"/>
             <div id="scope">
               <h1>1&#160; Scope</h1>
             </div>
             <div id="terms">
               <h1>2&#160; Definitions</h1>
               <p>None.</p>
             </div>
             <div id="widgets">
               <h1>3&#160; Widgets</h1>
               <div id="widgets1"><h2>3.1&#160; </h2>
         <div id="N" class="figure">
             <div id="note1" class="figure">

       <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
       <p class="FigureTitle" style="text-align:center;">Figure 3-1-b&#160;&#8212; Split-it-right sample divider</p></div>
         <div id="note2" class="figure">

       <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
       <p class="FigureTitle" style="text-align:center;">Figure 3-1-c&#160;&#8212; Split-it-right sample divider</p></div>
       </div>
       <p>    <a href="#note1">Figure 3-1-b</a> <a href="#note2">Figure 3-1-c</a> </p>
         </div>
             </div>
             <br/>
             <div id="annex1" class="Section3">
               <div id="annex1a"><h2>A.1&#160; </h2>
         </div>
               <div id="annex1b"><h2>A.2&#160; </h2>
         <div id="AN" class="figure">
             <div id="Anote1" class="figure">

       <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
       <p class="FigureTitle" style="text-align:center;">Figure A-1-b&#160;&#8212; Split-it-right sample divider</p></div>
         <div id="Anote2" class="figure">

       <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
       <p class="FigureTitle" style="text-align:center;">Figure A-1-c&#160;&#8212; Split-it-right sample divider</p></div>
       </div>
         </div>
             </div>
           </div>
         </body>
    OUTPUT
end

it "processes steps class of ordered lists" do
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
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
    #{HTML_HDR}
      <div>
        <h1 class="IntroTitle"/>
        <ol type="1" id="_ae34a226-aab4-496d-987b-1aa7b6314026">
  <li>
    <p id="_0091a277-fb0e-424a-aea8-f0001303fe78">all information necessary for the complete identification of the sample;</p>
  </li>
  <ol type="a">
  <li>
    <p id="_8a7b6299-db05-4ff8-9de7-ff019b9017b2">a reference to this document (i.e. ISO 17301-1);</p>
  </li>
  <ol type="i">
  <li>
    <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">the sampling method used;</p>
  </li>
  </ol>
  </ol>
</ol>
      </div>
      <p class="zzSTDTitle1"/>
      <p class="zzSTDTitle2"/>
    </div>
  </body>
    OUTPUT
  end

it "cross-references notes" do
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
    <p>
    <xref target="N1"/>
    <xref target="N2"/>
    <xref target="N"/>
    <xref target="note1"/>
    <xref target="note2"/>
    <xref target="AN"/>
    <xref target="Anote1"/>
    <xref target="Anote2"/>
    </p>
    </foreword>
    <introduction id="intro">
    <note id="N1">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83e">These results are based on a study carried out on three different types of kernel.</p>
</note>
<clause id="xyz"><title>Preparatory</title>
    <note id="N2">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83d">These results are based on a study carried out on three different types of kernel.</p>
</note>
</clause>
    </introduction>
    </preface>
    <sections>
    <clause id="scope"><title>Scope</title>
    <note id="N">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
<p><xref target="N"/></p>

    </clause>
    <terms id="terms"/>
    <clause id="widgets"><title>Widgets</title>
    <clause id="widgets1">
    <note id="note1">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    <note id="note2">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
</note>
<p>    <xref target="note1"/> <xref target="note2"/> </p>

    </clause>
    </clause>
    </sections>
    <annex id="annex1">
    <clause id="annex1a">
    <note id="AN">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </clause>
    <clause id="annex1b">
    <note id="Anote1">
<p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    <note id="Anote2">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </clause>
    </annex>
    </iso-standard>
    INPUT
    #{HTML_HDR}
             <div>
               <h1 class="IntroTitle"/>
               <p>
           <a href="#N1">Note in Introduction</a>
           <a href="#N2">Note in Preparatory</a>
           <a href="#N">Note in Clause 1</a>
           <a href="#note1">Note  1 in Clause 3.1</a>
           <a href="#note2">Note  2 in Clause 3.1</a>
           <a href="#AN">Note in Clause A.1</a>
           <a href="#Anote1">Note  1 in Clause A.2</a>
           <a href="#Anote2">Note  2 in Clause A.2</a>
           </p>
             </div>
             <div id="intro">
               <h1 class="IntroTitle"/>
               <div id="N1" class="Note">
                 <p><span class="note_label">NOTE</span>&#160; These results are based on a study carried out on three different types of kernel.</p>
               </div>
               <div id="xyz"><h2>Preparatory</h2>
           <div id="N2" class="Note"><p><span class="note_label">NOTE</span>&#160; These results are based on a study carried out on three different types of kernel.</p></div>
       </div>
             </div>
             <p class="zzSTDTitle1"/>
             <p class="zzSTDTitle2"/>
             <div id="scope">
               <h1>1&#160; Scope</h1>
               <div id="N" class="Note">
                 <p><span class="note_label">NOTE</span>&#160; These results are based on a study carried out on three different types of kernel.</p>
               </div>
               <p>
                 <a href="#N">Note</a>
               </p>
             </div>
             <div id="terms">
               <h1>2&#160; Definitions</h1>
               <p>None.</p>
             </div>
             <div id="widgets">
               <h1>3&#160; Widgets</h1>
               <div id="widgets1"><h2>3.1&#160; </h2>
           <div id="note1" class="Note"><p><span class="note_label">NOTE  1</span>&#160; These results are based on a study carried out on three different types of kernel.</p></div>
           <div id="note2" class="Note"><p><span class="note_label">NOTE  2</span>&#160; These results are based on a study carried out on three different types of kernel.</p></div>
       <p>    <a href="#note1">Note  1</a> <a href="#note2">Note  2</a> </p>

           </div>
             </div>
             <br/>
             <div id="annex1" class="Section3">
               <div id="annex1a"><h2>A.1&#160; </h2>
           <div id="AN" class="Note"><p><span class="note_label">NOTE</span>&#160; These results are based on a study carried out on three different types of kernel.</p></div>
           </div>
               <div id="annex1b"><h2>A.2&#160; </h2>
           <div id="Anote1" class="Note"><p><span class="note_label">NOTE  1</span>&#160; These results are based on a study carried out on three different types of kernel.</p></div>
           <div id="Anote2" class="Note"><p><span class="note_label">NOTE  2</span>&#160; These results are based on a study carried out on three different types of kernel.</p></div>
           </div>
             </div>
           </div>
         </body>

OUTPUT
end

end

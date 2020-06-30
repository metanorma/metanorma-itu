require "spec_helper"
require "fileutils"

logoloc = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "isodoc", "itu", "html"))

RSpec.describe Asciidoctor::ITU do
  it "processes default metadata" do
    csdc = IsoDoc::ITU::HtmlConvert.new({})
    docxml, filename, dir = csdc.convert_init(<<~"INPUT", "test", true)
<itu-standard xmlns="https://www.calconnect.org/standards/itu">
  <bibdata type="standard">
  <title language="en" format="text/plain" type="main">Main Title</title>
  <title language="en" format="text/plain" type="annex">Annex Title</title>
  <title language="fr" format="text/plain" type="main">Titre Principal</title>
  <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
<title language='fr' format='text/plain' type='subtitle'>Soustitre</title>
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
     <keyword>word2</keyword>
 <keyword>word1</keyword>
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
    expect(htmlencode(Hash[csdc.info(docxml, nil).sort].to_s.gsub(/, :/, ",\n:"))).to be_equivalent_to <<~"OUTPUT"
{:accesseddate=>"XXX",
:agency=>"ITU",
:annexid=>"Appendix F1",
:annextitle=>"Annex Title",
:authors=>[],
:authors_affiliations=>{},
:bureau=>"R",
:circulateddate=>"XXX",
:confirmeddate=>"XXX",
:copieddate=>"XXX",
:createddate=>"XXX",
:docnumber=>"ITU-R 1000",
:docnumeric=>"1000",
:docsubtitle=>"Subtitle",
:doctitle=>"Main Title",
:doctype=>"Directive",
:doctype_original=>"directive",
:docyear=>"2001",
:draft=>"3.4",
:draftinfo=>" (draft 3.4, 2000-01-01)",
:edition=>"2",
:implementeddate=>"XXX",
:ip_notice_received=>"false",
:issueddate=>"XXX",
:iteration=>"3",
:keywords=>["word1", "word2"],
:logo_comb=>"#{File.join(logoloc, "itu-document-comb.png")}",
:logo_html=>"#{File.join(logoloc, "/International_Telecommunication_Union_Logo.svg")}",
:logo_word=>"#{File.join(logoloc, "International_Telecommunication_Union_Logo.svg")}",
:obsoleteddate=>"XXX",
:pubdate_monthyear=>"",
:publisheddate=>"XXX",
:publisher=>"International Telecommunication Union",
:receiveddate=>"XXX",
:revdate=>"2000-01-01",
:revdate_monthyear=>"01/2000",
:series=>"A3",
:series1=>"B3",
:series2=>"C3",
:stage=>"Final Draft",
:transmitteddate=>"XXX",
:unchangeddate=>"XXX",
:unpublished=>false,
:updateddate=>"XXX",
:vote_endeddate=>"XXX",
:vote_starteddate=>"XXX"}
    OUTPUT
  end

   it "processes metadata for in-force-prepublished, recommendation annex" do
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
  <ext>
  <doctype>recommendation-annex</doctype>
  </ext>
  </bibdata>
<preface/><sections/>
<annex obligation="informative"/>
</itu-standard>

INPUT
expect(htmlencode(Hash[csdc.info(docxml, nil).sort].to_s).gsub(/, :/, ",\n:")).to be_equivalent_to <<~"OUTPUT"
{:accesseddate=>"XXX",
:agency=>"ITU",
:annextitle=>nil,
:authors=>[],
:authors_affiliations=>{},
:circulateddate=>"XXX",
:confirmeddate=>"XXX",
:copieddate=>"XXX",
:createddate=>"XXX",
:docnumber=>"ITU-R 1000",
:docnumeric=>"1000",
:docsubtitle=>nil,
:doctitle=>"Main Title",
:doctype=>"Recommendation",
:doctype_original=>"recommendation-annex",
:docyear=>nil,
:draft=>nil,
:draftinfo=>"",
:edition=>nil,
:implementeddate=>"XXX",
:ip_notice_received=>"false",
:issueddate=>"XXX",
:keywords=>[],
:logo_comb=>"#{File.join(logoloc, "itu-document-comb.png")}",
:logo_html=>"#{File.join(logoloc, "/International_Telecommunication_Union_Logo.svg")}",
:logo_word=>"#{File.join(logoloc, "International_Telecommunication_Union_Logo.svg")}",
:obsoleteddate=>"XXX",
:pubdate_monthyear=>"",
:publisheddate=>"XXX",
:publisher=>"International Telecommunication Union",
:receiveddate=>"XXX",
:revdate=>nil,
:revdate_monthyear=>nil,
:series=>nil,
:series1=>nil,
:series2=>nil,
:stage=>"In Force Prepublished",
:stageabbr=>"IFP",
:transmitteddate=>"XXX",
:unchangeddate=>"XXX",
:unpublished=>true,
:updateddate=>"XXX",
:vote_endeddate=>"XXX",
:vote_starteddate=>"XXX"}
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

  it "processes add, del" do
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
<itu-standard xmlns="https://www.calconnect.org/standards/itu">
<preface><foreword id="A">
<add>ABC <xref target="A"></add> <del><strong>B</strong></del>
</foreword></preface>
</itu-standard>
    INPUT
        #{HTML_HDR}
             <div id='A'>
             <h1 class='IntroTitle'/>
  <span class='addition'>
               ABC 
               <a href='#A'>Foreword</a>
               <span class='deletion'>
                 <b>B</b>
               </span>
             </span>
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
         <termnote id="J1" keep-with-next="true" keep-lines-together="true"><name>NOTE</name><p>This is a note</p></termnote>
       </term>
         <term id="K">
         <preferred>Term3</preferred>
         <definition><p>This is a journey into sound</p></definition>
         <termsource><origin citeas="XYZ">x y z</origin></termsource>
         <termnote id="J2"><name>NOTE 1</name><p>This is a note</p></termnote>
         <termnote id="J3"><name>NOTE 2</name><p>This is a note</p></termnote>
       </term>
        </terms>
        </sections>
        </itu-standard>
    INPUT
        #{HTML_HDR}
               <p class="zzSTDTitle1"/>
             <p class="zzSTDTitle2"/>
               <div id="H"><h1>1&#160; </h1>
               <div id='J'>
               <p class='TermNum' id='J'>
                 <b>1.1&#160; Term2</b>
                  [XYZ]: 
               </p>
               <p>This is a journey into sound</p>
               <div id="J1" class='Note' style='page-break-after: avoid;page-break-inside: avoid;'>
                 <p>NOTE &#8211; This is a note</p>
               </div>
             </div>
             <div id='K'>
               <p class='TermNum' id='K'>
                 <b>1.2&#160; Term3</b>
                  [XYZ]: 
               </p>
               <p>This is a journey into sound</p>
               <div id="J2" class='Note'>
                 <p>NOTE 1 &#8211; This is a note</p>
               </div>
               <div id="J3" class='Note'>
                 <p>NOTE 2 &#8211; This is a note</p>
               </div>
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
         <termnote id="J1"><name>NOTE</name><p>This is a note</p></termnote>
       </term>
        </terms>
        </sections>
        </itu-standard>
    INPUT
        expect(xmlpp(File.read("test.html", encoding: "utf-8").to_s.gsub(%r{^.*<main}m, "<main").gsub(%r{</main>.*}m, "</main>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
        <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
             <p class="zzSTDTitle1"></p>
             <p class="zzSTDTitle2"></p>
             <div id="H"><h1 id="toc0">1&#xA0; </h1>
         <div id="J"><p class="TermNum" id="J"><b>1.1&#xA0; Term2</b> [XYZ]: This is a journey into sound</p>



         <div id="J1" class="Note"><p>NOTE &#x2013; This is a note</p></div>
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
        <references id="_normative_references" obligation="informative" normative="true"><title>References</title>
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
                 <table class='biblio' border='0'>
  <tbody>
    <tr id='ISO712' class='NormRef'>
      <td  style='vertical-align:top'>[ISO&#160;712]</td>
                 <td>ISO 712, <i>Cereals and cereal products?~@~I?~@~T?~@~IDetermination of moisture content?~@~I?~@~T?~@~IReference method</i>.</td>
                 </tr>
                 </tbody>
                 </table>
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
          <p class="Terms" style='text-align:left;' id="J"><b>1.1.</b>&#xA0;Term2</p>

          </div>
                </div>
              </body>
              </html>
    OUTPUT
  end

   it "processes IsoXML footnotes (Word)" do
     expect(xmlpp(IsoDoc::ITU::WordConvert.new({}).convert("test", <<~"INPUT", true).sub(%r{^.*<body }m, "<body xmlns:epub='epub' ").sub(%r{</body>.*$}m, "</body>").gsub(%r{_Ref\d+}, "_Ref"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
               <p>A.<span style='mso-bookmark:_Ref'>
  <a href='#ftn2' class='FootnoteRef' epub:type='footnote'>
    <sup>2</sup>
  </a>
</span></p>
               <p>B.<span style='mso-element:field-begin'/>
 NOTEREF _Ref \\f \\h
<span style='mso-element:field-separator'/>
<span class='MsoFootnoteReference'>2</span>
<span style='mso-element:field-end'/>
</p>
               <p>C.<span style='mso-bookmark:_Ref'>
  <a href='#ftn1' class='FootnoteRef' epub:type='footnote'>
    <sup>1</sup>
  </a>
</span>
</p>
             </div>
             <p>&#160;</p>
           </div>
           <p>
             <br clear="all" class="section"/>
           </p>
           <div class="WordSection3">
             <p class="zzSTDTitle1"/>
             <p class="zzSTDTitle2"/>
             <aside id="ftn2">
         <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
       </aside>
             <aside id="ftn1">
         <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Hello! denoted as 15 % (m/m).</p>
       </aside>
           </div>
         </body>
    OUTPUT
  end

     it "cleans up footnotes" do
    FileUtils.rm_f "test.html"
    IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", false)
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
    </itu-standard>
    INPUT
     expect(File.exist?("test.html")).to be true
    html = File.read("test.html", encoding: "UTF-8")
    expect(xmlpp(html.sub(/^.*<main /m, "<main xmlns:epub='epub' ").sub(%r{</main>.*$}m, "</main>").gsub(%r{<script>.+?</script>}, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <main xmlns:epub='epub' class='main-section'>
  <button onclick='topFunction()' id='myBtn' title='Go to top'>Top</button>
  <div>
    <h1 class='IntroTitle'/>
    <p>
      A.
      <a class='FootnoteRef' href='#fn:2' id='fnref:1'>
        <sup>1</sup>
      </a>
    </p>
    <p>
      B.
      <a class='FootnoteRef' href='#fn:2'>
        <sup>1</sup>
      </a>
    </p>
    <p>
      C.
      <a class='FootnoteRef' href='#fn:1' id='fnref:3'>
        <sup>2</sup>
      </a>
    </p>
    <p class='TableTitle' style='text-align:center;'>
      Table 1&#xA0;&#x2014; Repeatability and reproducibility of
      <i>husked</i>
       rice yield
    </p>
    <table id='tableD-1' class='MsoISOTable' style='border-width:1px;border-spacing:0;' title='tool tip'>
      <caption>
        <span style='display:none'>long desc</span>
      </caption>
      <thead>
        <tr>
          <td rowspan='2' style='text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;' scope='col'>Description</td>
          <td colspan='4' style='text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;' scope='colgroup'>Rice sample</td>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td style='text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;'>Arborio</td>
          <td style='text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;'>
            Drago
            <a href='#tableD-1a' class='TableFootnoteRef'>a)</a>
          </td>
          <td style='text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;'>
            Balilla
            <a href='#tableD-1a' class='TableFootnoteRef'>a)</a>
          </td>
          <td style='text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;'>Thaibonnet</td>
        </tr>
      </tbody>
      <tfoot>
        <tr>
          <td colspan='5' style='border-top:0pt;border-bottom:solid windowtext 1.5pt;'>
            <div class='TableFootnote'>
              <div id='fn:tableD-1a'>
                <p id='_0fe65e9a-5531-408e-8295-eeff35f41a55' class='TableFootnote'>
                  <span>
                    <span id='tableD-1a' class='TableFootnoteRef'>a)</span>
                    &#xA0;
                  </span>
                  Parboiled rice.
                </p>
              </div>
            </div>
          </td>
        </tr>
      </tfoot>
    </table>
  </div>
  <p class='zzSTDTitle1'/>
  <p class='zzSTDTitle2'/>
  <aside id='fn:2' class='footnote'>
    <p id='_1e228e29-baef-4f38-b048-b05a051747e4'>
      <a class='FootnoteRef' href='#fn:2'>
        <sup>1</sup>
      </a>
      Formerly denoted as 15 % (m/m).
    </p>
    <a href='#fnref:1'>&#x21A9;</a>
  </aside>
  <aside id='fn:1' class='footnote'>
    <p id='_1e228e29-baef-4f38-b048-b05a051747e4'>
      <a class='FootnoteRef' href='#fn:1'>
        <sup>2</sup>
      </a>
      Hello! denoted as 15 % (m/m).
    </p>
    <a href='#fnref:3'>&#x21A9;</a>
  </aside>
</main>
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
<table id="tableD-1" alt="tool tip" summary="long desc">
  <name>Repeatability and reproducibility of <em>husked</em> rice yield</name>
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
    </itu-standard>
    INPUT
     expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc", encoding: "UTF-8")
expect(xmlpp(html.sub(%r{^.*<div align="center" class="table_container">}m, '').sub(%r{</table>.*$}m, "</table>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
<table class='MsoISOTable' style='mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;' title='tool tip'  summary='long desc'>
  <a name='tableD-1' id='tableD-1'/>
  <thead>
    <tr>
      <td rowspan='2' align='left' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;' valign='top'>Description</td>
      <td colspan='4' align='center' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' valign='top'>Rice sample</td>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align='left' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' valign='top'>Arborio</td>
      <td align='center' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' valign='top'>
        Drago
        <a href='#tableD-1a' class='TableFootnoteRef'>a)</a>
      </td>
      <td align='center' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' valign='top'>
        Balilla
        <a href='#tableD-1a' class='TableFootnoteRef'>a)</a>
      </td>
      <td align='center' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' valign='top'>Thaibonnet</td>
    </tr>
  </tbody>
  <tfoot>
    <tr>
      <td colspan='5' style='border-top:0pt;mso-border-top-alt:0pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>
        <div class='TableFootnote'>
          <div>
            <a name='ftntableD-1a' id='ftntableD-1a'/>
            <p class='TableFootnote'>
              <a name='_0fe65e9a-5531-408e-8295-eeff35f41a55' id='_0fe65e9a-5531-408e-8295-eeff35f41a55'/>
              <span>
                <span class='TableFootnoteRef'>
                  <a name='tableD-1a' id='tableD-1a'/>
                  a)
                </span>
                <span style='mso-tab-count:1'>&#xA0; </span>
              </span>
              Parboiled rice.
            </p>
          </div>
        </div>
      </td>
    </tr>
  </tfoot>
</table>
OUTPUT

  end


 def itudoc(lang)
<<~"INPUT"
               <itu-standard xmlns="http://riboseinc.com/isoxml">
               <bibdata type="standard">
               <title language="en" format="text/plain" type="main">An ITU Standard</title>
               <title language="fr" format="text/plain" type="main">Un Standard ITU</title>
               <docidentifier type="ITU">12345</docidentifier>
               <language>#{lang}</language>
               <keyword>A</keyword>
               <keyword>B</keyword>
               <ext>
               <doctype>recommendation</doctype>
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
       </annex><bibliography><references id="R" obligation="informative" normative="true">
         <title>References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative" normative="false">
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
               <docidentifier type="ITU">12345</docidentifier>
               <language>en</language>
               <keyword>A</keyword>
               <keyword>B</keyword>
               <ext>
               <doctype>recommendation</doctype>
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
                 <table class='biblio' border='0'>
  <tbody/>
</table>
               </div>
               <div id="I">
               <h1>3&#160; </h1>
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
               <p class="zzSTDTitle2">Un Standard ITU</p>
               <div id="D">
                 <h1>1&#160; Domaine d'application</h1>
                 <p id="E">Text</p>
               </div>
               <div>
                 <h1>2&#160; References</h1>
                 <table class='biblio' border='0'>
  <tbody/>
</table>

               </div>
               <div id="I">
               <h1>3&#160; </h1>
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
             <div>
               <h1 class="IntroTitle">Keywords</h1>
               <p>A, B.</p>
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
                <table class='biblio' border='0'>
   <tbody/>
 </table>
             </div>
             <div id="I"><h1>3<span style="mso-tab-count:1">&#160; </span></h1>
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
       <clause id="D" obligation="normative">
         <title>Scope</title>
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
        <annex id="P" inline-header="false" obligation="normative">
         <title>Annex 1</title>
         <clause id="Q" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
         <p>Hello</p>
         </clause>
       </annex>
           <annex id="P1" inline-header="false" obligation="normative">
         <title>Annex 2</title>
         <p>Hello</p>
         <clause id="Q1" inline-header="false" obligation="normative">
         <title>Annex A1.1</title>
         <p>Hello</p>
         </clause>
         </clause>
       </annex>
       </itu-standard>
    INPUT
     expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc", encoding: "UTF-8")
expect(xmlpp(html.sub(%r{^.*<div class="WordSection3">}m, %{<body><div class="WordSection3">}).gsub(%r{</body>.*$}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
<body><div class="WordSection3">
      <p class="zzSTDTitle1">Recommendation 12345</p>
      <p class="zzSTDTitle2">An ITU Standard</p>
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

  it "injects JS into blank html" do
    FileUtils.rm_f "test.html"
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r{jquery\.min\.js})
    expect(html).to match(%r{Times New Roman})
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
    <eref type="inline" bibitemid="ISO712" citeas="ISO 712"><localityStack><locality type="section"><referenceFrom>8</referenceFrom></locality></localityStack><localityStack><locality type="section"><referenceFrom>10</referenceFrom></locality></localityStack></eref>
    </p>
    </foreword></preface>
    <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>References</title>
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
        <a href='#ISO712'>[ISO 712], Section 8</a>
        <a href="#ISO712">[ISO 712], Section 8; Section 10</a>

           </p>
               </div>
               <p class="zzSTDTitle1"/>
               <p class="zzSTDTitle2"/>
               <div>
                              <h1>1&#160; References</h1>
                                 <table class='biblio' border='0'>
     <tbody>
       <tr id='ISO712' class='NormRef'>
         <td  style='vertical-align:top'>[ISO&#160;712]</td>
         <td>
           ISO 712 (2019),
           <i>Cereals and cereal products</i>
           .
         </td>
       </tr>
     </tbody>
   </table>
             </div>
           </div>
         </body>
    OUTPUT
  end

           it "processes annex with supplied annexid" do
             FileUtils.rm_f "test.html"
             IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", false)
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
        <annex id="A1" obligation="normative">
                <title>Annex</title>
                <clause id="A2"><title>Subtitle</title>
                <table id="T"/>
                <figure id="U"/>
                <formula id="V"><stem type="AsciiMath">r = 1 %</stem></formula>
                </clause>
        </annex>
    INPUT
             html = File.read("test.html", encoding: "utf-8")
    expect(xmlpp(html.gsub(%r{^.*<main}m, "<main").gsub(%r{</main>.*}m, "</main>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <main class='main-section'>
         <button onclick='topFunction()' id='myBtn' title='Go to top'>Top</button>
         <p class='zzSTDTitle1'>Recommendation 12345</p>
         <p class='zzSTDTitle2'>An ITU Standard</p>
         <p class='zzSTDTitle3'>Subtitle</p>
         <div id='A1' class='Section3'>
           <p class='h1Annex'>
             <b>Annex F2</b>
             <br/>
             <br/>
             <b>Annex</b>
           </p>
           <p class='annex_obligation'>(This annex forms an integral part of this Recommendation.)</p>
           <div id='A2'>
             <h2 id='toc0'>F2.1&#xA0; Subtitle</h2>
             <table id='T' class='MsoISOTable' style='border-width:1px;border-spacing:0;'/>
             <div id='U' class='figure'/>
             <div id='V'><div class='formula'>
               <p>
                 <span class='stem'>(#(r = 1 %)#)</span>
               </p>
             </div>
             </div>
           </div>
         </div>
       </main>
OUTPUT
           end

    it "processes annex with supplied annexid (Word)" do
             FileUtils.rm_f "test.doc"
             IsoDoc::ITU::WordConvert.new({}).convert("test", <<~"INPUT", false)
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
        <annex id="A1" obligation="normative">
                <title>Annex</title>
                <clause id="A2"><title>Subtitle</title>
                <table id="T"/>
                <figure id="U"/>
                <formula id="V"><stem type="AsciiMath">r = 1 %</stem></formula>
                </clause>
        </annex>
    INPUT
             html = File.read("test.doc", encoding: "utf-8")
    expect(xmlpp(html.gsub(%r{^.*<div class="WordSection3">}m, '<div class="WordSection3" xmlns:m="http://schemas.microsoft.com/office/2004/12/omml">').gsub(%r{<div style="mso-element:footnote-list"/>.*}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <div class="WordSection3" xmlns:m="http://schemas.microsoft.com/office/2004/12/omml">
             <p class="zzSTDTitle1">Recommendation 12345</p>
             <p class="zzSTDTitle2">An ITU Standard</p>
             <p class="zzSTDTitle3">Subtitle</p>
             <div class="Section3"><a name="A1" id="A1"></a>
               <p class="h1Annex"><b>Annex F2</b> <br/><br/><b>Annex</b></p>
               <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
               <div><a name="A2" id="A2"></a><h2>F2.1<span style="mso-tab-count:1">&#xA0; </span>Subtitle</h2>
               <div align="center" class="table_container"><table class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;"><a name="T" id="T"></a></table></div>
               <div class="figure"><a name="U" id="U"></a></div>
               <div><a name="V" id="V"></a><div class="formula"><p class="formula"><span style="mso-tab-count:1">&#xA0; </span><span class="stem"><m:oMath>
         <m:r><m:t>r=1%</m:t></m:r>
       </m:oMath>
       </span></p></div>
               </div>
               </div>
             </div>
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
      expect(xmlpp(html.gsub(%r{.*<p class="h1Preface">History</p>}m, '<div><p class="h1Preface">History</p>').sub(%r{</table>.*$}m, "</table></div></div>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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




it "processes erefs and xrefs and links (Word)" do
    expect(xmlpp(IsoDoc::ITU::WordConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
<iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p>
    <eref type="footnote" bibitemid="ISO712" citeas="ISO 712">A</stem>
    <eref type="inline" bibitemid="ISO712" citeas="ISO 712">A</stem>
    <xref target="_http_1_1">Requirement <tt>/req/core/http</tt></xref>
    <link target="http://www.example.com">Test</link>
    <link target="http://www.example.com"/>
    </p>
    </foreword></preface>
    <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>References</title>
<bibitem id="ISO712" type="standard">
  <title format="text/plain">Cereals and cereal products</title>
  <docidentifier>ISO 712</docidentifier>
  <contributor>
    <role type="publisher"/>
    <organization>
      <abbreviation>ISO</abbreviation>
    </organization>
  </contributor>
</bibitem>
    </references>
    </bibliography>
    </iso-standard>
    INPUT
    <body lang='EN-US' link='blue' vlink='#954F72'>
  <div class='WordSection1'>
    <p>&#160;</p>
  </div>
  <p>
    <br clear='all' class='section'/>
  </p>
  <div class='WordSection2'>
    <div>
      <h1 class='IntroTitle'/>
      <p>
      <sup>
  <a href='#ISO712'>A</a>
</sup>
<a href='#ISO712'>A</a>
<a href='#_http_1_1'>
  Requirement 
  <tt>/req/core/http</tt>
</a>
<a href='http://www.example.com' class='url'>Test</a>
<a href='http://www.example.com' class='url'>http://www.example.com</a>
      </p>
    </div>
    <p>&#160;</p>
  </div>
  <p>
    <br clear='all' class='section'/>
  </p>
  <div class='WordSection3'>
    <p class='zzSTDTitle1'/>
    <p class='zzSTDTitle2'/>
    <div>
      <h1>
        1
        <span style='mso-tab-count:1'>&#160; </span>
        References
      </h1>
       <table class='biblio' border='0'>
   <tbody>
     <tr id='ISO712' class='NormRef'>
       <td  style='vertical-align:top'>[ISO&#160;712]</td>
       <td>
         ISO 712,
         <i>Cereals and cereal products</i>
         .
       </td>
     </tr>
   </tbody>
 </table>
    </div>
  </div>
</body>
OUTPUT
end



    it "processes boilerplate" do
      FileUtils.rm_f "test.html"
    IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    #{BOILERPLATE}
    </iso-standard>
    INPUT
        expect(xmlpp(File.read("test.html", encoding: "utf-8").gsub(%r{^.*<div class="prefatory-section">}m, '<div class="prefatory-section">').gsub(%r{<nav>.*}m, "</div>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
        <div class='prefatory-section'>
         <div class='boilerplate-legal'>
           <div>
             <h1 class='IntroTitle'>FOREWORD</h1>
             <p id='_'>
               The International Telecommunication Union (ITU) is the United Nations
               specialized agency in the field of telecommunications , information and
               communication technologies (ICTs). The ITU Telecommunication
               Standardization Sector (ITU-T) is a permanent organ of ITU. ITU-T is
               responsible for studying technical, operating and tariff questions and
               issuing Recommendations on them with a view to standardizing
               telecommunications on a worldwide basis.
             </p>
             <p id='_'>
               The World Telecommunication Standardization Assembly (WTSA), which meets
               every four years, establishes the topics for study by the ITU T study
               groups which, in turn, produce Recommendations on these topics.
             </p>
             <p id='_'>
               The approval of ITU-T Recommendations is covered by the procedure laid
               down in WTSA Resolution 1 .
             </p>
             <p id='_'>
               In some areas of information technology which fall within ITU-T's
               purview, the necessary standards are prepared on a collaborative basis
               with ISO and IEC.
             </p>
             <div>
               <h1 class='IntroTitle'>NOTE</h1>
               <p id='_'>
                 In this Recommendation, the expression "Administration" is used for
                 conciseness to indicate both a telecommunication administration and a
                 recognized operating agency .
               </p>
               <p id='_'>
                 Compliance with this Recommendation is voluntary. However, the
                 Recommendation may contain certain mandatory provisions (to ensure,
                 e.g., interoperability or applicability) and compliance with the
                 Recommendation is achieved when all of these mandatory provisions are
                 met. The words "shall" or some other obligatory language such as
                 "must" and the negative equivalents are used to express requirements.
                 The use of such words does not suggest that compliance with the
                 Recommendation is required of any party .
               </p>
             </div>
           </div>
         </div>
         <div class='boilerplate-license'>
           <div>
             <h1 class='IntroTitle'>INTELLECTUAL PROPERTY RIGHTS</h1>
             <p id='_'>
               ITU draws attention to the possibility that the practice or
               implementation of this Recommendation may involve the use of a claimed
               Intellectual Property Right. ITU takes no position concerning the
               evidence, validity or applicability of claimed Intellectual Property
               Rights, whether asserted by ITU members or others outside of the
               Recommendation development process.
             </p>
             <p id='_'>
               As of the date of approval of this Recommendation, ITU had received
               notice of intellectual property, protected by patents, which may be
               required to implement this Recommendation. However, implementers are
               cautioned that this may not represent the latest information and are
               therefore strongly urged to consult the TSB patent database at
               <a href='http://www.itu.int/ITU-T/ipr/'>http://www.itu.int/ITU-T/ipr/</a>
               .
             </p>
           </div>
         </div>
       </div>
    OUTPUT
    end

        it "processes boilerplate (Word)" do
      FileUtils.rm_f "test.doc"
    IsoDoc::ITU::WordConvert.new({}).convert("test", <<~"INPUT", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    #{BOILERPLATE}
    </iso-standard>
    INPUT
        expect(xmlpp(File.read("test.doc", encoding: "utf-8").gsub(%r{^.*<div class="boilerplate-legal">}m, '<div><div class="boilerplate-legal">').gsub(%r{<b>Table of Contents</b></p>.*}m, "<b>Table of Contents</b></p></div>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
               <div>
         <div class='boilerplate-legal'>
           <div>
             <p class='boilerplateHdr'>FOREWORD</p>
             <p class='boilerplate'>
               <a name='_' id='_'/>
               The International Telecommunication Union (ITU) is the United Nations
               specialized agency in the field of telecommunications , information and
               communication technologies (ICTs). The ITU Telecommunication
               Standardization Sector (ITU-T) is a permanent organ of ITU. ITU-T is
               responsible for studying technical, operating and tariff questions and
               issuing Recommendations on them with a view to standardizing
               telecommunications on a worldwide basis.
             </p>
             <p class='boilerplate'>
               <a name='_' id='_'/>
               The World Telecommunication Standardization Assembly (WTSA), which meets
               every four years, establishes the topics for study by the ITU T study
               groups which, in turn, produce Recommendations on these topics.
             </p>
             <p class='boilerplate'>
               <a name='_' id='_'/>
               The approval of ITU-T Recommendations is covered by the procedure laid
               down in WTSA Resolution 1 .
             </p>
             <p class='boilerplate'>
               <a name='_' id='_'/>
               In some areas of information technology which fall within ITU-T's
               purview, the necessary standards are prepared on a collaborative basis
               with ISO and IEC.
             </p>
             <div>
               <p class='boilerplate'>&#xA0;</p>
               <p class='boilerplate'>&#xA0;</p>
               <p class='boilerplate'>&#xA0;</p>
               <p class='boilerplateHdr'>NOTE</p>
               <p class='boilerplate'>
                 <a name='_' id='_'/>
                 In this Recommendation, the expression "Administration" is used for
                 conciseness to indicate both a telecommunication administration and a
                 recognized operating agency .
               </p>
               <p class='boilerplate'>
                 <a name='_' id='_'/>
                 Compliance with this Recommendation is voluntary. However, the
                 Recommendation may contain certain mandatory provisions (to ensure,
                 e.g., interoperability or applicability) and compliance with the
                 Recommendation is achieved when all of these mandatory provisions are
                 met. The words "shall" or some other obligatory language such as
                 "must" and the negative equivalents are used to express requirements.
                 The use of such words does not suggest that compliance with the
                 Recommendation is required of any party .
               </p>
             </div>
           </div>
           <p class='MsoNormal'>&#xA0;</p>
           <p class='MsoNormal'>&#xA0;</p>
           <p class='MsoNormal'>&#xA0;</p>
         </div>
         <div class='boilerplate-license'>
           <div>
             <p class='boilerplateHdr'>INTELLECTUAL PROPERTY RIGHTS</p>
             <p class='boilerplate'>
               <a name='_' id='_'/>
               ITU draws attention to the possibility that the practice or
               implementation of this Recommendation may involve the use of a claimed
               Intellectual Property Right. ITU takes no position concerning the
               evidence, validity or applicability of claimed Intellectual Property
               Rights, whether asserted by ITU members or others outside of the
               Recommendation development process.
             </p>
             <p class='boilerplate'>
               <a name='_' id='_'/>
               As of the date of approval of this Recommendation, ITU had received
               notice of intellectual property, protected by patents, which may be
               required to implement this Recommendation. However, implementers are
               cautioned that this may not represent the latest information and are
               therefore strongly urged to consult the TSB patent database at
               <a href='http://www.itu.int/ITU-T/ipr/' class='url'>http://www.itu.int/ITU-T/ipr/</a>
               .
             </p>
           </div>
           <p class='MsoNormal'>&#xA0;</p>
           <p class='MsoNormal'>&#xA0;</p>
           <p class='MsoNormal'>&#xA0;</p>
         </div>
         <div class='boilerplate-copyright'>
           <div>
             <p class='boilerplateHdr'/>
             <p class='boilerplate' style='text-align:center;'>
               <a name='_' id='_'/>
               &#xA9; ITU 2020
             </p>
             <p class='boilerplate'>
               <a name='_' id='_'/>
               All rights reserved. No part of this publication may be reproduced, by
               any means whatsoever, without the prior written permission of ITU.
             </p>
           </div>
         </div>
         <b style='mso-bidi-font-weight:normal'>
           <span lang='EN-US' xml:lang='EN-US' style='font-size:12.0pt;&#10;mso-bidi-font-size:10.0pt;font-family:&quot;Times New Roman&quot;,serif;mso-fareast-font-family:&#10;&quot;Times New Roman&quot;;mso-ansi-language:EN-US;mso-fareast-language:EN-US;&#10;mso-bidi-language:AR-SA'>
             <br clear='all' style='page-break-before:always'/>
           </span>
         </b>
         <p class='MsoNormal' align='center' style='text-align:center'>
           <b>Table of Contents</b>
         </p>
       </div>
    OUTPUT
    end

end

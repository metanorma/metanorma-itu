require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::ITU do
  it "processes history and source clauses (Word)" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <clause type="history" id="H"><title>History</title></clause>
      <clause type="source" id="I"><title>Source</title></clause>
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

  it "processes amendments and corrigenda" do
    input = <<~INPUT
      <itu-standard xmlns="https://www.calconnect.org/standards/itu">
      <bibdata>
      <language>en</language>
      <script>Latn</script>
      <ext>
      <structuredidentifier>
              <amendment>1</amendment>
              <corrigendum>2</corrigendum>
      </structuredidentifier>
      </ext>
      </bibdata>
      </itu-standard>
    INPUT
    output = <<~OUTPUT
          <itu-standard xmlns='https://www.calconnect.org/standards/itu' type='presentation'>
        <bibdata>
          <language current="true">en</language>
          <script current="true">Latn</script>
          <ext>
            <structuredidentifier>
      <amendment language=''>1</amendment>
      <amendment language='en'>Amendment 1</amendment>
      <corrigendum language=''>2</corrigendum>
      <corrigendum language='en'>Corrigendum 2</corrigendum>
            </structuredidentifier>
          </ext>
        </bibdata>
      </itu-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes titles for service publications" do
    input = <<~INPUT
      <itu-standard xmlns="https://www.calconnect.org/standards/itu">
      <bibdata>
      <language>en</language>
      <script>Latn</script>
      <title type="main">Title</title>
      <date type="published">2010-09-08</date>
      <ext>
      <doctype>service-publication</doctype>
      </ext>
      </bibdata>
      </itu-standard>
    INPUT
    output = <<~OUTPUT
          <itu-standard xmlns='https://www.calconnect.org/standards/itu' type='presentation'>
        <bibdata>
          <language current='true'>en</language>
                 <script current='true'>Latn</script>
                 <title type='main'>Title</title>
                 <title language='en' format='text/plain' type='position-sp'>(Position on 8 September 2010)</title>
                 <date type='published'>2010-09-08</date>
                 <date type='published' format='ddMMMyyyy'>8.IX.2010</date>
                 <ext>
                   <doctype language=''>service-publication</doctype>
                   <doctype language='en'>Service Publication</doctype>
                 </ext>
        </bibdata>
      </itu-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes titles for resolutions" do
    input = <<~INPUT
      <itu-standard xmlns="https://www.calconnect.org/standards/itu">
      <bibdata>
      <docnumber>1</docnumber>
      <edition>1</edition>
      <language>en</language>
      <script>Latn</script>
      <title type="main">Title</title>
      <date type="published">2010-09-08</date>
      <ext>
      <doctype>resolution</doctype>
      <meeting>World Meeting on Stuff</meeting>
      <meeting-place>Andorra</meeting-place>
      <meeting-date><from>1204-04-01</from><to>1207-01-01</to></meeting-date>
      </ext>
      </bibdata>
      <sections>
      <clause id="A">
      <note type="title-footnote" id="A1"><p>One fn</p></note>
      <note type="title-footnote" id="A2"><p>Another fn</p></note>
      <p>Hello.<fn reference="3"><p>Normal footnote</p></fn></p>
      </clause>
      </sections>
      </itu-standard>
    INPUT
    presxml = <<~OUTPUT
          <itu-standard xmlns='https://www.calconnect.org/standards/itu' type='presentation'>
        <bibdata>
        <docnumber>1</docnumber>
      <edition>1</edition>
          <language current='true'>en</language>
                 <script current='true'>Latn</script>
                 <title type='main'>Title</title>
                 <title language='en' format='text/plain' type='resolution'>RESOLUTION 1 (Andorra, 1204)</title>
      <title language='en' format='text/plain' type='resolution-placedate'>Andorra, 1204</title>
                 <date type='published'>2010-09-08</date>
                 <date type='published' format='ddMMMyyyy'>8.IX.2010</date>
                 <ext>
                   <doctype language=''>resolution</doctype>
                   <doctype language='en'>Resolution</doctype>
      <meeting>World Meeting on Stuff</meeting>
      <meeting-place>Andorra</meeting-place>
      <meeting-date><from>1204-04-01</from><to>1207-01-01</to></meeting-date>
                 </ext>
        </bibdata>
        <sections>
        <clause id='A' displayorder='1'>
        <p keep-with-next='true' class='supertitle'>SECTION 1</p>
          <note type='title-footnote' id="A1">
            <p>One fn</p>
          </note>
          <note type='title-footnote' id="A2">
            <p>Another fn</p>
          </note>
          <p>Hello.<fn reference='3'><p>Normal footnote</p></fn></p>
        </clause>
      </sections>
      </itu-standard>
    OUTPUT
    html = <<~OUTPUT
                  #{HTML_HDR}
              <p align='center'  style='text-align:center;'>RESOLUTION 1 (Andorra, 1204)</p>
          <p class='zzSTDTitle2'/>
          <p align='center'  style='text-align:center;'>
            <i>(Andorra, 1204)</i>
            <a class='FootnoteRef' href='#fn:_'>
              <sup>_</sup>
            </a>
            <a class='FootnoteRef' href='#fn:_'>
              <sup>_</sup>
            </a>
          </p>
          <div id='A'>
            <p style='page-break-after: avoid;' class='supertitle'>SECTION 1</p>
            <p>
              Hello.
              <a class='FootnoteRef' href='#fn:3'>
                <sup>3</sup>
              </a>
            </p>
          </div>
          <aside id='fn:_' class='footnote'>
            <p>One fn</p>
          </aside>
          <aside id='fn:_' class='footnote'>
            <p>Another fn</p>
          </aside>
          <aside id='fn:3' class='footnote'>
            <p>Normal footnote</p>
          </aside>
        </div>
      </body>
    OUTPUT

    word = <<~OUTPUT
      <body xmlns:epub='epub' lang='EN-US' link='blue' vlink='#954F72'>
           <div class='WordSection1'>
             <p>&#160;</p>
           </div>
           <p>
             <br clear='all' class='section'/>
           </p>
           <div class='WordSection2'>
             <p>&#160;</p>
           </div>
           <p>
             <br clear='all' class='section'/>
           </p>
           <div class='WordSection3'>
             <p align='center' style='text-align:center;'>RESOLUTION 1 (Andorra, 1204)</p>
             <p class='zzSTDTitle2'/>
             <p align='center' style='text-align:center;'>
               <i>(Andorra, 1204)</i>
               <span style='mso-bookmark:_Ref'>
                 <a class='FootnoteRef' href='#ftn_' epub:type='footnote'>
                   <sup>_</sup>
                 </a>
               </span>
               <span style='mso-bookmark:_Ref'>
                 <a class='FootnoteRef' href='#ftn_' epub:type='footnote'>
                   <sup>_</sup>
                 </a>
               </span>
             </p>
             <div id='A'>
               <p class='supertitle' style='page-break-after: avoid;'>SECTION 1</p>
               <p>
                 Hello.
                 <span style='mso-bookmark:_Ref'>
                   <a class='FootnoteRef' href='#ftn3' epub:type='footnote'>
                     <sup>3</sup>
                   </a>
                 </span>
               </p>
             </div>
             <aside id='ftn_'>
               <p>One fn</p>
             </aside>
             <aside id='ftn_'>
               <p>Another fn</p>
             </aside>
             <aside id='ftn3'>
               <p>Normal footnote</p>
             </aside>
           </div>
         </body>
    OUTPUT
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({})
      .convert("test", presxml, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")
      .gsub(/fn:[0-9a-f-][0-9a-f-]+/, "fn:_")
      .gsub(%r{<sup>[0-9a-f-][0-9a-f-]+</sup>}, "<sup>_</sup>")))
      .to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::ITU::WordConvert.new({})
      .convert("test", presxml, true)
      .sub(%r{^.*<body }m, "<body xmlns:epub='epub' ")
      .sub(%r{</body>.*$}m, "</body>")
      .gsub(%r{_Ref\d+}, "_Ref")
      .gsub(%r{<sup>[0-9a-f-][0-9a-f-]+</sup>}, "<sup>_</sup>")
      .gsub(%r{ftn[0-9a-f-][0-9a-f-]+}, "ftn_")))
      .to be_equivalent_to xmlpp(word)
  end

  it "processes titles for revised resolutions" do
    input = <<~INPUT
      <itu-standard xmlns="https://www.calconnect.org/standards/itu">
      <bibdata>
      <docnumber>1</docnumber>
      <edition>2</edition>
      <language>en</language>
      <script>Latn</script>
      <title type="main">Title</title>
      <status>
      <stage>draft</stage>
      </status>
      <date type="published">2010-09-08</date>
      <ext>
      <doctype>resolution</doctype>
      <meeting>World Meeting on Stuff</meeting>
      <meeting-place>Andorra</meeting-place>
      <meeting-date><from>1204-04-01</from><to>1207-01-01</to></meeting-date>
      </ext>
      </bibdata>
      </itu-standard>
    INPUT
    presxml = <<~OUTPUT
          <itu-standard xmlns='https://www.calconnect.org/standards/itu' type='presentation'>
        <bibdata>
        <docnumber>1</docnumber>
      <edition>2</edition>
          <language current='true'>en</language>
                 <script current='true'>Latn</script>
                 <title type='main'>Title</title>
                 <title language='en' format='text/plain' type='resolution'>RESOLUTION 1 (Rev. Andorra, 1204)</title>
      <title language='en' format='text/plain' type='resolution-placedate'>Andorra, 1204</title>
      <status> <stage language=''>draft</stage> </status>
                 <date type='published'>2010-09-08</date>
                 <date type='published' format='ddMMMyyyy'>8.IX.2010</date>
                 <ext>
                   <doctype language=''>resolution</doctype>
                   <doctype language='en'>Resolution</doctype>
      <meeting>World Meeting on Stuff</meeting>
      <meeting-place>Andorra</meeting-place>
      <meeting-date><from>1204-04-01</from><to>1207-01-01</to></meeting-date>
                 </ext>
        </bibdata>
      </itu-standard>
    OUTPUT
    html = <<~OUTPUT
                #{HTML_HDR}
          <p align='center'  style='text-align:center;'>RESOLUTION 1 (Rev. Andorra, 1204)</p>
          <p class='zzSTDTitle2'/>
          <p align='center'  style='text-align:center;'>
            <i>(Andorra, 1204)</i>
          </p>
        </div>
      </body>
    OUTPUT
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({})
      .convert("test", presxml, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to xmlpp(html)
  end

  it "processes keyword" do
    input = <<~INPUT
      <itu-standard xmlns="https://www.calconnect.org/standards/itu">
      <preface><foreword>
      <keyword>ABC</keyword>
      </foreword></preface>
      </itu-standard>
    INPUT
    output = <<~OUTPUT
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
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes simple terms & definitions" do
    input = <<~INPUT
              <itu-standard xmlns="http://riboseinc.com/isoxml">
      <preface/><sections>
      <terms id="H" obligation="normative"><title>Terms</title>
        <term id="J">
        <preferred><expression><name>Term2</name></expression></preferred>
        <definition><verbal-definition><p>This is a journey into sound</p></verbal-definition></definition>
        <termsource><origin citeas="XYZ">x y z</origin></termsource>
        <termnote id="J1" keep-with-next="true" keep-lines-together="true"><p>This is a note</p></termnote>
      </term>
        <term id="K">
        <preferred><expression><name>Term3</name></expression></preferred>
        <definition><verbal-definition><p>This is a journey into sound</p></verbal-definition></definition>
        <termsource><origin citeas="XYZ">x y z</origin></termsource>
        <termnote id="J2"><p>This is a note</p></termnote>
        <termnote id="J3"><p>This is a note</p></termnote>
      </term>
       </terms>
       </sections>
       </itu-standard>
    INPUT

    presxml = <<~INPUT
              <itu-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
      <preface/><sections>
      <terms id="H" obligation="normative" displayorder='1'><title depth="1">1.<tab/>Terms</title>
        <term id="J">
        <name>1.1.</name>
        <preferred><strong>Term2</strong></preferred>
        <definition><p>This is a journey into sound</p></definition>
        <termsource><origin citeas="XYZ">x y z</origin></termsource>
        <termnote id="J1" keep-with-next="true" keep-lines-together="true"><name>NOTE</name><p>This is a note</p></termnote>
      </term>
        <term id="K">
        <name>1.2.</name>
        <preferred><strong>Term3</strong></preferred>
        <definition><p>This is a journey into sound</p></definition>
        <termsource><origin citeas="XYZ">x y z</origin></termsource>
        <termnote id="J2"><name>NOTE 1</name><p>This is a note</p></termnote>
        <termnote id="J3"><name>NOTE 2</name><p>This is a note</p></termnote>
      </term>
       </terms>
       </sections>
       </itu-standard>
    INPUT

    output = <<~OUTPUT
       #{HTML_HDR}
          <p class='zzSTDTitle1'/>
          <p class='zzSTDTitle2'/>
          <div id='H'>
            <h1>1.&#160; Terms</h1>
            <div id='J'>
              <p class='TermNum' id='J'>
                <b>1.1.&#160; <b>Term2</b></b>:
                 [XYZ]
              </p>
              <p>This is a journey into sound</p>
              <div id='J1' class='Note' style='page-break-after: avoid;page-break-inside: avoid;'>
                <p>NOTE &#8211; This is a note</p>
              </div>
            </div>
            <div id='K'>
              <p class='TermNum' id='K'>
                <b>1.2.&#160; <b>Term3</b></b>:
                 [XYZ]
              </p>
              <p>This is a journey into sound</p>
              <div id='J2' class='Note'>
                <p>NOTE 1 &#8211; This is a note</p>
              </div>
              <div id='J3' class='Note'>
                <p>NOTE 2 &#8211; This is a note</p>
              </div>
            </div>
          </div>
        </div>
      </body>
    OUTPUT
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({})
      .convert("test", presxml, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to xmlpp(output)
  end

  it "postprocesses simple terms & definitions" do
    FileUtils.rm_f "test.html"
    FileUtils.rm_f "test.doc"
    IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", false)
              <itu-standard xmlns="http://riboseinc.com/isoxml">
      <preface/><sections>
      <terms id="H" obligation="normative"><title>1<tab/>Terms</title>
        <term id="J">
        <name>1.1</name>
        <preferred>Term2</preferred>
        <definition><p>This is a journey into sound</p></definition>
        <termsource><origin citeas="XYZ">x y z</origin></termsource>
        <termnote id="J1"><name>NOTE</name><p>This is a note</p></termnote>
      </term>
       </terms>
       </sections>
       </itu-standard>
    INPUT
    expect(xmlpp(File.read("test.html", encoding: "utf-8").to_s
      .gsub(%r{^.*<main}m, "<main")
      .gsub(%r{</main>.*}m, "</main>")))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
         <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
              <p class="zzSTDTitle1"></p>
              <p class="zzSTDTitle2"></p>
              <div id="H"><h1 id="toc0">1&#xA0; Terms</h1>
          <div id="J"><p class="TermNum" id="J"><b>1.1&#xA0; Term2</b>: [XYZ] This is a journey into sound</p>



          <div id="J1" class="Note"><p>NOTE &#x2013; This is a note</p></div>
        </div>
         </div>
            </main>
      OUTPUT
  end

  it "processes terms & definitions subclauses with external, internal, and empty definitions" do
    input = <<~INPUT
                     <itu-standard xmlns="http://riboseinc.com/isoxml">
               <termdocsource type="inline" bibitemid="ISO712"/>
             <preface/><sections>
             <clause id="G"><title>2<tab/>Terms, Definitions, Symbols and Abbreviated Terms</title>
             <terms id="H" obligation="normative"><title>2.1<tab/>Terms defined in this recommendation</title>
               <term id="J">
               <name>2.1.1</name>
               <preferred>Term2</preferred>
             </term>
             </terms>
             <terms id="I" obligation="normative"><title>2.2<tab/>Terms defined elsewhere</title>
               <term id="K">
               <name>2.2.1</name>
               <preferred>Term2</preferred>
             </term>
             </terms>
             <terms id="L" obligation="normative"><title>2.3<tab/>Other terms</title>
             </terms>
             </clause>
              </sections>
              <bibliography>
              <references id="_normative_references" obligation="informative" normative="true"><title>1<tab/>References</title>
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
    output = <<~OUTPUT
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
                  <div id="L"><h2>2.3&#160; Other terms</h2></div>
                  </div>
               </div>
               </body>
    OUTPUT
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to xmlpp(output)
  end

  it "rearranges term headers" do
    input = <<~INPUT
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
    output = <<~OUTPUT
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
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({})
      .cleanup(Nokogiri::XML(input)).to_s))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes IsoXML footnotes (Word)" do
    input = <<~INPUT
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
    output = <<~OUTPUT
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
    expect(xmlpp(IsoDoc::ITU::WordConvert.new({})
      .convert("test", input, true)
      .sub(%r{^.*<body }m, "<body xmlns:epub='epub' ")
      .sub(%r{</body>.*$}m, "</body>")
      .gsub(%r{_Ref\d+}, "_Ref")))
      .to be_equivalent_to xmlpp(output)
  end

  it "cleans up footnotes" do
    FileUtils.rm_f "test.html"
    input = <<~"INPUT"
          <itu-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <title language="en" format="text/plain" type="main">An ITU Standard</title>
          <ext><doctype>recommendation</doctype></ext>
          </bibdata>
          <preface>
          <foreword>
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
          </itu-standard>
    INPUT
    IsoDoc::ITU::HtmlConvert.new({}).convert("test", input, false)
    expect(File.exist?("test.html")).to be true
    html = File.read("test.html", encoding: "UTF-8")
    expect(xmlpp(html.sub(/^.*<main /m, "<main xmlns:epub='epub' ")
      .sub(%r{</main>.*$}m, "</main>")
      .gsub(%r{<script>.+?</script>}, "")
      .gsub(/fn:[0-9a-f][0-9a-f-]+/, "fn:_")))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
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
          <p class='zzSTDTitle2'>
          An ITU Standard
          <a class='FootnoteRef' href='#fn:_' id='fnref:4'>
            <sup>3</sup>
          </a>
          <a class='FootnoteRef' href='#fn:_' id='fnref:5'>
            <sup>4</sup>
          </a>
        </p>
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
          <aside id='fn:_' class='footnote'>
          <p>
            <a class='FootnoteRef' href='#fn:_'>
              <sup>3</sup>
            </a>
            One fn
          </p>
          <a href='#fnref:4'>&#x21A9;</a>
        </aside>
        <aside id='fn:_' class='footnote'>
          <p>
            <a class='FootnoteRef' href='#fn:_'>
              <sup>4</sup>
            </a>
            Another fn
          </p>
          <a href='#fnref:5'>&#x21A9;</a>
        </aside>
        </main>
      OUTPUT

    FileUtils.rm_f "test.doc"
    IsoDoc::ITU::WordConvert.new({}).convert("test", input, false)
    expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc", encoding: "UTF-8")
    expect(xmlpp(html
      .sub(%r{^.*<div align="center" class="table_container">}m, "")
      .sub(%r{</table>.*$}m, "</table>")))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
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

  it "processes annexes and appendixes" do
    input = <<~INPUT
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
             <keyword>A</keyword>
             <keyword>B</keyword>
             <ext>
             <doctype language="">recommendation</doctype><doctype language="en">Recommendation</doctype>
             </ext>
             </bibdata>
             <preface>
             <abstract displayorder="1">
             <title>Abstract</title>
                 <xref target="A1">Annex A</xref>
                 <xref target="B1">Appendix I</xref>
             </abstract>
             </preface>
      <annex id="A1" obligation="normative" displayorder="2"><title><strong>Annex A</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="A2" obligation="normative" displayorder="3"><title><strong>Annex B</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="A3" obligation="normative" displayorder="4"><title><strong>Annex C</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="A4" obligation="normative" displayorder="5"><title><strong>Annex D</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="A5" obligation="normative" displayorder="6"><title><strong>Annex E</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="A6" obligation="normative" displayorder="7"><title><strong>Annex F</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="A7" obligation="normative" displayorder="8"><title><strong>Annex G</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="A8" obligation="normative" displayorder="9"><title><strong>Annex H</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="A9" obligation="normative" displayorder="10"><title><strong>Annex J</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="A10" obligation="normative" displayorder="11"><title><strong>Annex K</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="B1" obligation="informative" displayorder="12"><title><strong>Appendix I</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="B2" obligation="informative" displayorder="13"><title><strong>Appendix II</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="B3" obligation="informative" displayorder="14"><title><strong>Appendix III</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="B4" obligation="informative" displayorder="15"><title><strong>Appendix IV</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="B5" obligation="informative" displayorder="16"><title><strong>Appendix V</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="B6" obligation="informative" displayorder="17"><title><strong>Appendix VI</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="B7" obligation="informative" displayorder="18"><title><strong>Appendix VII</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="B8" obligation="informative" displayorder="19"><title><strong>Appendix VIII</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="B9" obligation="informative" displayorder="20"><title><strong>Appendix IX</strong><br/><br/><strong>Annex</strong></title></annex>
      <annex id="B10" obligation="informative" displayorder="21"><title><strong>Appendix X</strong><br/><br/><strong>Annex</strong></title></annex>
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
              <p class="zzSTDTitle1">Draft new Recommendation 12345</p>
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
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")))
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
      <abstract displayorder="1"><title>Abstract</title>
      <p>This is an abstract</p>
      </abstract>
      <clause id="A0" displayorder="2"><title depth="1">History</title>
      <p>history</p>
      </clause>
      <foreword obligation="informative" displayorder="3">
         <title>Foreword</title>
         <p id="A">This is a preamble</p>
       </foreword>
        <introduction id="B" obligation="informative" displayorder="4"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title depth="2">Introduction Subsection</title>
       </clause>
       </introduction></preface><sections>
       <clause id="D" obligation="normative" type="scope" displayorder="5">
         <title depth="1">1.<tab/>Scope</title>
         <p id="E">Text</p>
       </clause>
       <terms id="I" obligation="normative" displayorder="7"><title>3.</title>
         <term id="J"><name>3.1.</name>
         <preferred>Term2</preferred>
       </term>
       </terms>
       <definitions id="L" displayorder="8"><title>4.</title>
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       <clause id="M" inline-header="false" obligation="normative" displayorder="9"><title depth="1">5.<tab/>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
         <title depth="2">5.1.<tab/>Introduction</title>
       </clause>
       <clause id="O" inline-header="false" obligation="normative">
         <title depth="2">5.2.<tab/>Clause 4.2</title>
       </clause></clause>
       </sections><annex id="P" inline-header="false" obligation="normative" displayorder="10">
         <title><strong>Annex A</strong><br/><br/><strong>Annex</strong></title>
         <clause id="Q" inline-header="false" obligation="normative">
         <title depth="2">A.1.<tab/>Annex A.1</title>
         <clause id="Q1" inline-header="false" obligation="normative">
         <title depth="3">A.1.1.<tab/>Annex A.1a</title>
         </clause>
       </clause>
       </annex><bibliography><references id="R" obligation="informative" normative="true" displayorder="6">
         <title depth="1">2.<tab/>References</title>
       </references><clause id="S" obligation="informative" displayorder="11">
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
                 <p>
                   <br clear="all" class="section"/>
                 </p>
                 <div class="WordSection2">
                 <div class='Abstract'>
                     <h1 class="AbstractTitle">Summary</h1>
                     <p>This is an abstract</p>
                   </div>
                   <div class='Keyword'>
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
                     <h1>5.<span style="mso-tab-count:1">&#160; </span>Clause 4</h1>
                     <div id="N"><h2>5.1.<span style="mso-tab-count:1">&#160; </span>Introduction</h2>
              </div>
                     <div id="O"><h2>5.2.<span style="mso-tab-count:1">&#160; </span>Clause 4.2</h2>
              </div>
                   </div>
                   <p>
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
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({})
      .convert("test", itudoc("en"), true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")))
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
             <clause id="D" obligation="normative" type="scope">
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
              <annex id="P" inline-header="false" obligation="normative">
               <title><strong>Annex A</strong><br/><br/><strong>Annex 1</strong></title>
               <clause id="Q" inline-header="false" obligation="normative">
               <title>A.1<tab/>Annex A.1</title>
               <p>Hello</p>
               </clause>
             </annex>
                 <annex id="P1" inline-header="false" obligation="normative">
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
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
        <body><div class="WordSection3">
              <p class="zzSTDTitle1">Draft new Recommendation 12345</p>
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
      :no-pdf:
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r{jquery\.min\.js})
    expect(html).to match(%r{Times New Roman})
    expect(html).to match(%r{<main class="main-section"><button})
  end

  it "processes eref types" do
    input = <<~INPUT
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
    output = <<~OUTPUT
                <?xml version='1.0'?>
       <itu-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
         <preface>
           <foreword displayorder='1'>
             <p>
               <eref type='footnote' bibitemid='ISO712' citeas='ISO 712'>A</eref>
               <eref type='inline' bibitemid='ISO712' citeas='ISO 712'>A</eref>
               <eref type='footnote' bibitemid='ISO712' citeas='ISO 712'>[ISO 712]</eref>
               <eref type='inline' bibitemid='ISO712' citeas='ISO 712'>[ISO 712]</eref>
               <eref type='footnote' bibitemid='ISO712' citeas='ISO 712'>
                 <locality type='section'>
                   <referenceFrom>8</referenceFrom>
                 </locality>
                 [ISO 712], Section 8
               </eref>
               <eref type='inline' bibitemid='ISO712' citeas='ISO 712'>
                 <locality type='section'>
                   <referenceFrom>8</referenceFrom>
                 </locality>
                 [ISO 712], Section 8
               </eref>
               <eref type='inline' bibitemid='ISO712' citeas='ISO 712'>
                 <localityStack>
                   <locality type='section'>
                     <referenceFrom>8</referenceFrom>
                   </locality>
                 </localityStack>
                 <localityStack>
                   <locality type='section'>
                     <referenceFrom>10</referenceFrom>
                   </locality>
                 </localityStack>
                 [ISO 712], Section 8; Section 10
               </eref>
             </p>
           </foreword>
         </preface>
         <bibliography>
           <references id='_normative_references' obligation='informative' normative='true' displayorder='2'>
           <title depth='1'>
        1.
        <tab/>
        References
      </title>
             <bibitem id='ISO712' type='standard'>
               <title format='text/plain'>Cereals and cereal products</title>
               <docidentifier>ISO 712</docidentifier>
               <date type='published'>2019-01-01</date>
               <contributor>
                 <role type='publisher'/>
                 <organization>
                   <abbreviation>ISO</abbreviation>
                 </organization>
               </contributor>
             </bibitem>
           </references>
         </bibliography>
       </itu-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(output)
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
            <annex id='A1' obligation='normative' displayorder='1'>
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
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
    IsoDoc::ITU::HtmlConvert.new({}).convert("test", presxml, false)
    html = File.read("test.html", encoding: "utf-8")
    expect(xmlpp(html.gsub(%r{^.*<main}m, "<main")
      .gsub(%r{</main>.*}m, "</main>")))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
            <main class='main-section'>
                 <button onclick='topFunction()' id='myBtn' title='Go to top'>Top</button>
                 <p class='zzSTDTitle1'>Draft new Recommendation 12345</p>
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
                     <h2 id='toc0'>F2.1.&#xA0; Subtitle</h2>
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
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
        <div class='WordSection3' xmlns:m='http://schemas.microsoft.com/office/2004/12/omml'>
              <p class='zzSTDTitle1'>Draft new Recommendation 12345</p>
              <p class='zzSTDTitle2'>An ITU Standard</p>
              <p class='zzSTDTitle3'>Subtitle</p>
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
                        <span class='stem'>
                          <m:oMath>
                            <m:r>
                              <m:t>r=1%</m:t>
                            </m:r>
                          </m:oMath>
                        </span>
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
    expect(xmlpp(html
      .gsub(%r{.*<p class="h1Preface">History</p>}m, '<div><p class="h1Preface">History</p>')
      .sub(%r{</table>.*$}m, "</table></div></div>")))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    input = <<~INPUT
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
    output = <<~OUTPUT
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
            <h1>References</h1>
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
    expect(xmlpp(IsoDoc::ITU::WordConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes boilerplate" do
    FileUtils.rm_f "test.html"
    IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      #{boilerplate(Nokogiri::XML(%(<iso-standard xmlns="http://riboseinc.com/isoxml"><bibdata><language>en</language><script>Latn</script><copyright><from>#{Time.new.year}</from></copyright><ext><doctype>recommendation</doctype></ext></bibdata></iso-standard>)))}
      </iso-standard>
    INPUT
    expect(xmlpp(File.read("test.html", encoding: "utf-8")
      .gsub(%r{^.*<div class="prefatory-section">}m, '<div class="prefatory-section">')
      .gsub(%r{<nav>.*}m, "</div>")))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
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
                <h2 class='IntroTitle'>NOTE</h2>
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
      #{boilerplate(Nokogiri::XML(%(<iso-standard xmlns="http://riboseinc.com/isoxml"><bibdata><language>en</language><script>Latn</script><copyright><from>#{Time.new.year}</from></copyright><ext><doctype>recommendation</doctype></ext></bibdata></iso-standard>)))}
      </iso-standard>
    INPUT
    expect(xmlpp(File.read("test.doc", encoding: "utf-8")
      .gsub(%r{^.*<div class="boilerplate-legal">}m, '<div><div class="boilerplate-legal">')
      .gsub(%r{<b>Table of Contents</b></p>.*}m, "<b>Table of Contents</b></p></div>")))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
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
              <p class='boilerplateHdr'>
                <a name='_' id='_'/>
                &#xA9; ITU #{Time.new.year}
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

  it "processes lists within tables (Word)" do
    FileUtils.rm_f "test.doc"
    IsoDoc::ITU::WordConvert.new({}).convert("test", <<~"INPUT", false)
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <clause id="A">
                <table id="_2a8bd899-ab80-483a-90dc-002b6f497f54">
      <thead>
      <tr>
      <th align="left">A</th>
      <th align="left">B</th>
      </tr>
      </thead>
      <tbody>
      <tr>
      <td align="left">C</td>
      <td align="left">
      <ul id="_7c74d800-bac5-48d9-919a-fcf0a56b6891">
      <li>
      <p id="_32b6b048-26ad-4bce-a544-b3862aa5fa19">A</p>
      <ul id="_62c437de-18c8-44b0-8c2c-749946c54b4e">
      <li>
      <p id="_7289e3c0-ad96-4f5f-ba55-d91b2349f1b5">B</p>
      <ul id="_a3a4be14-120c-4d88-a298-5f9130d0bb9a">
      <li>
      <p id="_41ac8144-9892-4510-a538-4a1b8de72884">C</p>
      </li>
      </ul>
      </li>
      </ul>
      </li>
      </ul>
      </td>
      </tr>
      </tbody>
      <note id="_cf69f8ff-21f2-4ce9-aefb-0bebf988b8fa">
      <p id="_a510f7c5-1d32-47b2-8937-e827c7bf459a">B</p>
      </note></table>
      </clause>
      </preface>
          </iso-standard>
    INPUT
    expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc", encoding: "UTF-8")
    expect(xmlpp(html
      .sub(%r{^.*<div align="center" class="table_container">}m, "")
      .sub(%r{</table>.*$}m, "</table>")))
      .to be_equivalent_to xmlpp(<<~"OUTPUT")
        <table class='MsoISOTable' style='mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;'>
          <a name='_2a8bd899-ab80-483a-90dc-002b6f497f54' id='_2a8bd899-ab80-483a-90dc-002b6f497f54'/>
          <thead>
            <tr>
              <th align='left' style='font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' valign='top'>A</th>
              <th align='left' style='font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' valign='top'>B</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td align='left' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' valign='top'>C</td>
              <td align='left' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' valign='top'>
                <p style='margin-left: 0.5cm;text-indent: -0.5cm;;mso-list:l3 level1 lfo1;' class='MsoListParagraphCxSpFirst'>
                   A
                  <p style='margin-left: 1.0cm;text-indent: -0.5cm;;mso-list:l3 level2 lfo1;' class='MsoListParagraphCxSpFirst'>
                     B
                    <p style='margin-left: 1.5cm;text-indent: -0.5cm;;mso-list:l3 level3 lfo1;' class='MsoListParagraphCxSpFirst'> C </p>
                  </p>
                </p>
              </td>
            </tr>
          </tbody>
          <tfoot>
            <tr>
              <td colspan='2' style='border-top:0pt;mso-border-top-alt:0pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>
                <div class='Note'>
                  <a name='_cf69f8ff-21f2-4ce9-aefb-0bebf988b8fa' id='_cf69f8ff-21f2-4ce9-aefb-0bebf988b8fa'/>
                  <p class='Note'>B</p>
                </div>
              </td>
            </tr>
          </tfoot>
        </table>
      OUTPUT
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
      <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
               <bibdata>
                 <title language='en'>test</title>
               </bibdata>
               <preface>
                 <p displayorder='1'>
                   30'000
                   <stem type='MathML'>
                     <math xmlns='http://www.w3.org/1998/Math/MathML'>
                       <mi>P</mi>
                       <mfenced open='(' close=')'>
                         <mrow>
                           <mi>X</mi>
                           <mo>&#x2265;</mo>
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
                           <mo>&#x2211;</mo>
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
                       <mfenced open='(' close=')'>
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
                           <mfenced open='(' close=')'>
                             <mrow>
                               <mn>1</mn>
                               <mo>&#x2212;</mo>
                               <mi>p</mi>
                             </mrow>
                           </mfenced>
                         </mrow>
                         <mrow>
                           <mrow>
                             <mn>1.003</mn>
                             <mo>&#x2212;</mo>
                             <mi>j</mi>
                           </mrow>
                         </mrow>
                       </msup>
                     </math>
                   </stem>
                 </p>
               </preface>
             </iso-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({})
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes unnumbered clauses" do
    FileUtils.rm_f "test.html"
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
          <clause unnumbered='true' id='A' displayorder='1'>
            <p>Text</p>
          </clause>
          <clause id='B' displayorder='2'>
            <p keep-with-next='true' class='supertitle'>SECTION 1</p>
      <title depth='1'>First Clause</title>
          </clause>
        </sections>
      </itu-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "processes bis, ter etc clauses" do
    FileUtils.rm_f "test.html"
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
                 <clause id="A" displayorder='1'>
         <p keep-with-next="true" class="supertitle">SECTION 1</p><p><xref target="B">Section 1<em>bis</em></xref>, <xref target="C">Section 10<em>ter</em></xref>, <xref target="D">10<em>ter</em>.10<em>quater</em></xref>, <xref target="E">Section 10bit</xref></p>
                 </clause>
                 <clause id="B" number="1bis" displayorder='2'><p keep-with-next="true" class="supertitle">SECTION 1<em>bis</em></p><title depth="1">First Clause</title></clause>
                 <clause id="C" number="10ter" displayorder='3'><p keep-with-next="true" class="supertitle">SECTION 10<em>ter</em></p><title depth="1">Second Clause</title>
                 <clause id="D" number="10quater"><title depth="2">10<em>ter</em>.10<em>quater</em>.<tab/>Second Clause Subclause</title></clause>
         </clause>
                 <clause id="E" number="10bit" displayorder='4'><p keep-with-next="true" class="supertitle">SECTION 10bit</p><title depth="1">Non-Clause</title></clause>
                 </sections>
                 </itu-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
  end
end

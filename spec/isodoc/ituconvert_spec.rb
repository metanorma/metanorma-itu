require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Itu do
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
    expect(Canon.format_xml(strip_guid(IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Canon.format_xml(output)
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
    expect(Canon.format_xml(strip_guid(IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Canon.format_xml(output)
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
      <itu-standard xmlns="https://www.calconnect.org/standards/itu" type="presentation">
         <bibdata>
            <docnumber>1</docnumber>
            <edition language="">1</edition>
            <edition language="en">first edition</edition>
            <language current="true">en</language>
            <script current="true">Latn</script>
            <title type="main">Title</title>
            <title language="en" format="text/plain" type="resolution">RESOLUTION 1 (Andorra, 1204)</title>
            <title language="en" format="text/plain" type="resolution-placedate">Andorra, 1204</title>
            <date type="published">2010-09-08</date>
            <date type="published" format="ddMMMyyyy">8.IX.2010</date>
            <ext>
               <doctype language="">resolution</doctype>
               <doctype language="en">Resolution</doctype>
               <meeting>World Meeting on Stuff</meeting>
               <meeting-place>Andorra</meeting-place>
               <meeting-date>
                  <from>1204-04-01</from>
                  <to>1207-01-01</to>
               </meeting-date>
            </ext>
         </bibdata>
         <sections>
            <p class="zzSTDTitle1" align="center" displayorder="1">RESOLUTION 1 (Andorra, 1204)</p>
            <p align="center" class="zzSTDTitle2" displayorder="2">
               <em>(Andorra, 1204)</em>
               <fn id="_" reference="1" original-reference="H0" target="_">
                  <p>One fn</p>
                  <fmt-fn-label>
                     <span class="fmt-caption-label">
                        <sup>
                           <semx element="autonum" source="_">1</semx>
                        </sup>
                     </span>
                  </fmt-fn-label>
               </fn>
               <fn id="_" reference="2" original-reference="H1" target="_">
                  <p>Another fn</p>
                  <fmt-fn-label>
                     <span class="fmt-caption-label">
                        <sup>
                           <semx element="autonum" source="_">2</semx>
                        </sup>
                     </span>
                  </fmt-fn-label>
               </fn>
            </p>
            <p keep-with-next="true" class="supertitle" displayorder="3">
               <span class="fmt-element-name">SECTION</span>
               <semx element="autonum" source="A">1</semx>
            </p>
            <clause id="A" displayorder="4">
               <p>
                  Hello.
                  <fn reference="3" id="_" original-reference="3" target="_">
                     <p>Normal footnote</p>
                     <fmt-fn-label>
                        <span class="fmt-caption-label">
                           <sup>
                              <semx element="autonum" source="_">3</semx>
                           </sup>
                        </span>
                     </fmt-fn-label>
                  </fn>
               </p>
            </clause>
         </sections>
         <fmt-footnote-container>
            <fmt-fn-body id="_" target="_" reference="1">
               <semx element="fn" source="_">
                  <p>
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
                     One fn
                  </p>
               </semx>
            </fmt-fn-body>
            <fmt-fn-body id="_" target="_" reference="2">
               <semx element="fn" source="_">
                  <p>
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
                     Another fn
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
                     Normal footnote
                  </p>
               </semx>
            </fmt-fn-body>
         </fmt-footnote-container>
      </itu-standard>
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
            <p class="zzSTDTitle1" style="text-align:center;">RESOLUTION 1 (Andorra, 1204)</p>
            <p class="zzSTDTitle2" style="text-align:center;">
               <i>(Andorra, 1204)</i>
               <a class="FootnoteRef" href="#fn:_">
                  <sup>1</sup>
               </a>
               <a class="FootnoteRef" href="#fn:_">
                  <sup>2</sup>
               </a>
            </p>
            <p class="supertitle" style="page-break-after: avoid;">SECTION 1</p>
            <div id="A">
               <p>
                  Hello.
                  <a class="FootnoteRef" href="#fn:_">
                     <sup>3</sup>
                  </a>
               </p>
            </div>
            <aside id="fn:_" class="footnote">
               <p>One fn</p>
            </aside>
            <aside id="fn:_" class="footnote">
               <p>Another fn</p>
            </aside>
            <aside id="fn:_" class="footnote">
               <p>Normal footnote</p>
            </aside>
         </div>
      </body>
    OUTPUT

    word = <<~OUTPUT
      <body xmlns:epub="epub" lang="EN-US" link="blue" vlink="#954F72">
         <div class="WordSection1">
            <p> </p>
         </div>
         <p class="section-break">
            <br clear="all" class="section"/>
         </p>
         <div class="WordSection2">
            <p> </p>
         </div>
         <p class="section-break">
            <br clear="all" class="section"/>
         </p>
         <div class="WordSection3">
            <p class="zzSTDTitle1" style="text-align:center;" align="center">RESOLUTION 1 (Andorra, 1204)</p>
            <p class="zzSTDTitle2" style="text-align:center;" align="center">
               <i>(Andorra, 1204)</i>
               <span style="mso-bookmark:_Ref" class="MsoFootnoteReference">
                  <a class="FootnoteRef" epub:type="footnote" href="#ftn_">1</a>
               </span>
               <span style="mso-bookmark:_Ref" class="MsoFootnoteReference">
                  <a class="FootnoteRef" epub:type="footnote" href="#ftn_">2</a>
               </span>
            </p>
            <p class="supertitle" style="page-break-after: avoid;">SECTION 1</p>
            <div id="A">
               <p>
                  Hello.
                  <span style="mso-bookmark:_Ref" class="MsoFootnoteReference">
                     <a class="FootnoteRef" epub:type="footnote" href="#ftn_">3</a>
                  </span>
               </p>
            </div>
            <aside id="ftn_">
               <p>One fn</p>
            </aside>
            <aside id="ftn_">
               <p>Another fn</p>
            </aside>
            <aside id="ftn_">
               <p>Normal footnote</p>
            </aside>
         </div>
      </body>
    OUTPUT
    pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Canon.format_xml(strip_guid(pres_output
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(Canon.format_xml(IsoDoc::Itu::HtmlConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")
      .gsub(/fn:_?[0-9a-f-][0-9a-f-]+/, "fn:_")
      .gsub(%r{<sup>[0-9a-f-][0-9a-f-]+</sup>}, "<sup>_</sup>")))
      .to be_equivalent_to Canon.format_xml(html)
    expect(Canon.format_xml(IsoDoc::Itu::WordConvert.new({})
      .convert("test", pres_output, true)
      .sub(%r{^.*<body }m, "<body xmlns:epub='epub' ")
      .sub(%r{</body>.*$}m, "</body>")
      .gsub(%r{_Ref\d+}, "_Ref")
      .gsub(%r{<sup>[0-9a-f-][0-9a-f-]+</sup>}, "<sup>_</sup>")
      .gsub(%r{ftn_?[0-9a-f-][0-9a-f-]+}, "ftn_")))
      .to be_equivalent_to Canon.format_xml(word)
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
      <sections>
      <clause/>
      </sections>
      </itu-standard>
    INPUT
    presxml = <<~OUTPUT
          <itu-standard xmlns='https://www.calconnect.org/standards/itu' type='presentation'>
        <bibdata>
        <docnumber>1</docnumber>
      <edition language=''>2</edition>
      <edition language='en'>second edition</edition>
          <language current='true'>en</language>
                 <script current='true'>Latn</script>
                 <title type='main'>Title</title>
                 <title language='en' format='text/plain' type='resolution'>RESOLUTION 1 (Rev. Andorra, 1204)</title>
      <title language='en' format='text/plain' type='resolution-placedate'>Andorra, 1204</title>
      <status> <stage>draft</stage> </status>
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
            <p class="zzSTDTitle1" align="center" displayorder="1">RESOLUTION 1 (Rev. Andorra, 1204)</p>
            <p align="center" class="zzSTDTitle2" displayorder="2"><em>(Andorra, 1204)</em></p>
       <p keep-with-next="true" class="supertitle" displayorder="3">
         <span class="fmt-element-name">SECTION</span>
         <semx element="autonum" source="_">1</semx>
      </p>
      <clause id="_" displayorder="4"/>
          </sections>
      </itu-standard>
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
           <p class='zzSTDTitle1'  style='text-align:center;'>RESOLUTION 1 (Rev. Andorra, 1204)</p>
           <p class='zzSTDTitle2'  style='text-align:center;'><i>(Andorra, 1204)</i></p>
      <p class="supertitle" style="page-break-after: avoid;">SECTION 1</p>
      <div id="_"/>
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
  end

  it "processes keyword" do
    input = <<~INPUT
        <itu-standard xmlns="https://www.calconnect.org/standards/itu">
        <preface>
            <clause type="toc" id="_" displayorder="1">
        <fmt-title id="_" depth="1">Table of Contents</fmt-title>
      </clause>
        <foreword displayorder="2" id="_">
        <keyword>ABC</keyword>
        </foreword></preface>
        </itu-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
           <div id="_">
             <h1 class="IntroTitle"/>
             <span class="keyword">ABC</span>
           </div>
         </div>
       </body>
    OUTPUT
    expect(Canon.format_xml(IsoDoc::Itu::HtmlConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "injects JS into blank html" do
    FileUtils.rm_f "test.html"
    Asciidoctor.convert(<<~INPUT, backend: :itu, header_footer: true)
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

  it "processes boilerplate" do
    FileUtils.rm_f "test.html"
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      #{boilerplate(Nokogiri::XML(%(<iso-standard xmlns="http://riboseinc.com/isoxml"><bibdata><language>en</language><script>Latn</script><copyright><from>#{Time.new.year}</from></copyright><ext><doctype>recommendation</doctype></ext></bibdata></iso-standard>)))}
      </iso-standard>
    INPUT
    pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    IsoDoc::Itu::HtmlConvert.new({}).convert("test", pres_output, false)
    expect(Canon.format_xml(strip_guid(File.read("test.html", encoding: "utf-8")
      .gsub(%r{^.*<div class="prefatory-section">}m, '<div class="prefatory-section">')
      .gsub(%r{<nav>.*}m, "</div>"))))
      .to be_equivalent_to Canon.format_xml(<<~OUTPUT)
         <div class='prefatory-section'>
          <div class='boilerplate-legal'>
            <div id="_">
              <h1 class='IntroTitle'><a class="anchor" href="#_"/><a class="header" href="#_">FOREWORD</a></h1>
              <p id='_'>The International Telecommunication Union (ITU) is the United Nations specialized agency in the field of telecommunications , information and communication technologies (ICTs). The ITU Telecommunication Standardization Sector (ITU-T) is a permanent organ of ITU. ITU-T is responsible for studying technical, operating and tariff questions and issuing Recommendations on them with a view to standardizing telecommunications on a worldwide basis.</p>
              <p id='_'>The World Telecommunication Standardization Assembly (WTSA), which meets every four years, establishes the topics for study by the ITU T study groups which, in turn, produce Recommendations on these topics.</p>
              <p id='_'>The approval of ITU-T Recommendations is covered by the procedure laid down in WTSA Resolution 1.</p>
              <p id='_'>In some areas of information technology which fall within ITU-T's purview, the necessary standards are prepared on a collaborative basis with ISO and IEC.</p>
              <div id="_">
                <h2 class='IntroTitle'><a class="anchor" href="#_"/><a class="header" href="#_">NOTE</a></h2>
                <p id='_'>In this Recommendation, the expression "Administration" is used for conciseness to indicate both a telecommunication administration and a recognized operating agency.</p>
                <p id='_'>Compliance with this Recommendation is voluntary. However, the Recommendation may contain certain mandatory provisions (to ensure, e.g., interoperability or applicability) and compliance with the Recommendation is achieved when all of these mandatory provisions are met. The words "shall" or some other obligatory language such as "must" and the negative equivalents are used to express requirements. The use of such words does not suggest that compliance with the Recommendation is required of any party.</p>
              </div>
            </div>
          </div>
          <div class='boilerplate-license'>
            <div id="_">
              <h1 class='IntroTitle'><a class="anchor" href="#_"/><a class="header" href="#_">INTELLECTUAL PROPERTY RIGHTS</a></h1>
               <p id="_">ITU draws attention to the possibility that the practice or implementation of this Recommendation may involve the use of a claimed Intellectual Property Right. ITU takes no position concerning the evidence, validity or applicability of claimed Intellectual Property Rights, whether asserted by ITU members or others outside of the Recommendation development process.</p>
             <p id="_">As of the date of approval of this Recommendation, ITU had not received notice of intellectual property, protected by patents, which may be required to implement this Recommendation. However, implementers are cautioned that this may not represent the latest information and are therefore strongly urged to consult the TSB patent database at <a href="http://www.itu.int/ITU-T/ipr/">http://www.itu.int/ITU-T/ipr/</a>.</p>
            </div>
          </div>
        </div>
      OUTPUT

    FileUtils.rm_f "test.doc"
    IsoDoc::Itu::WordConvert.new({}).convert("test", pres_output, false)
    expect(Canon.format_xml(strip_guid(File.read("test.doc", encoding: "utf-8"))
      .gsub(%r{^.*<div class="boilerplate-legal">}m, '<div><div class="boilerplate-legal">')
      .gsub(%r{<b>Table of Contents</b></p>.*}m, "<b>Table of Contents</b></p></div>")))
      .to be_equivalent_to Canon.format_xml(<<~"OUTPUT")
            <div><div class="boilerplate-legal">
            <div><a name="_" id="_"/><p class="boilerplateHdr">FOREWORD</p>

        <p class="boilerplate"><a name="_" id="_"></a>The International Telecommunication Union (ITU) is the United Nations specialized agency in the field of telecommunications , information and communication technologies (ICTs). The ITU Telecommunication Standardization Sector (ITU-T) is a permanent organ of ITU. ITU-T is responsible for studying technical, operating and tariff questions and issuing Recommendations on them with a view to standardizing telecommunications on a worldwide basis.</p>
        <p class="boilerplate"><a name="_" id="_"></a>The World Telecommunication Standardization Assembly (WTSA), which meets every four years, establishes the topics for study by the ITU T study groups which, in turn, produce Recommendations on these topics.</p>
        <p class="boilerplate"><a name="_" id="_"></a>The approval of ITU-T Recommendations is covered by the procedure laid down in WTSA Resolution 1.</p>
        <p class="boilerplate"><a name="_" id="_"></a>In some areas of information technology which fall within ITU-T's purview, the necessary standards are prepared on a collaborative basis with ISO and IEC.</p>


        <div><a name="_" id="_"/><p class="boilerplateHdr">NOTE</p>

        <p class="boilerplate"><a name="_" id="_"></a>In this Recommendation, the expression "Administration" is used for conciseness to indicate both a telecommunication administration and a recognized operating agency.</p>
        <p class="boilerplate"><a name="_" id="_"></a>Compliance with this Recommendation is voluntary. However, the Recommendation may contain certain mandatory provisions (to ensure, e.g., interoperability or applicability) and compliance with the Recommendation is achieved when all of these mandatory provisions are met. The words "shall" or some other obligatory language such as "must" and the negative equivalents are used to express requirements. The use of such words does not suggest that compliance with the Recommendation is required of any party.</p>
        </div>

            </div>



          <p class="MsoNormal">&#xA0;</p><p class="MsoNormal">&#xA0;</p><p class="MsoNormal">&#xA0;</p></div>
        <div class="boilerplate-license">
            <div><a name="_" id="_"/><p class="boilerplateHdr">INTELLECTUAL PROPERTY RIGHTS</p>

              <p class="boilerplate"><a name="_" id="_"></a>ITU draws attention to the possibility that the practice or implementation of this Recommendation may involve the use of a claimed Intellectual Property Right. ITU takes no position concerning the evidence, validity or applicability of claimed Intellectual Property Rights, whether asserted by ITU members or others outside of the Recommendation development process.</p>
        <p class="boilerplate"><a name="_" id="_"></a>As of the date of approval of this Recommendation, ITU had not received notice of intellectual property, protected by patents, which may be required to implement this Recommendation. However, implementers are cautioned that this may not represent the latest information and are therefore strongly urged to consult the TSB patent database at <a href="http://www.itu.int/ITU-T/ipr/">http://www.itu.int/ITU-T/ipr/</a>.
        </p>
        </div>
        <p class="MsoNormal">&#xA0;</p><p class="MsoNormal">&#xA0;</p><p class="MsoNormal">&#xA0;</p></div>
        <div class="boilerplate-copyright">
            <div><a name="_" id="_"/>
              <p class="boilerplateHdr"><a name="_" id="_"></a>&#xA9; ITU #{Date.today.year}</p>
        <p class="boilerplate"><a name="_" id="_"></a>All rights reserved. No part of this publication may be reproduced, by any means whatsoever, without the prior written permission of ITU.</p>
            </div>
          </div>


        </div>
      OUTPUT
  end

  it "processes lists within tables (Word)" do
    FileUtils.rm_f "test.doc"
    IsoDoc::Itu::WordConvert.new({}).convert("test", <<~INPUT, false)
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <clause id="A" displayorder="1">
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
    expect(Canon.format_xml(html
      .sub(%r{^.*<div align="center" class="table_container">}m, "")
      .sub(%r{</table>.*$}m, "</table>")))
      .to be_equivalent_to Canon.format_xml(<<~OUTPUT)
        <table class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;">
          <a name="_2a8bd899-ab80-483a-90dc-002b6f497f54" id="_2a8bd899-ab80-483a-90dc-002b6f497f54"/>
          <thead>
            <tr>
              <th valign="top" align="left" style="font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">A</th>
              <th valign="top" align="left" style="font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">B</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td valign="top" align="left" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">C</td>
              <td valign="top" align="left" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">
                <div class="ul_wrap" style="page-break-after:auto">
                  <p style="margin-left: 0.5cm;text-indent: -0.5cm;;mso-list:l3 level1 lfo1;margin-left: 0.5cm;text-indent: -0.5cm;page-break-after:auto" class="MsoListParagraphCxSpFirst">
        A
        <div class="ListContLevel1"><div class="ul_wrap" style="margin-left: 0.5cm;text-indent: -0.5cm;page-break-after:auto"><p style="margin-left: 1.0cm;text-indent: -0.5cm;;mso-list:l3 level2 lfo1;margin-left: 1.0cm;text-indent: -0.5cm;page-break-after:auto" class="MsoListParagraphCxSpFirst">
        B
        <div class="ListContLevel2"><div class="ul_wrap" style="margin-left: 1.0cm;text-indent: -0.5cm;page-break-after:auto"><p style="margin-left: 1.5cm;text-indent: -0.5cm;;mso-list:l3 level3 lfo1;margin-left: 1.5cm;text-indent: -0.5cm;page-break-after:auto" class="MsoListParagraphCxSpFirst">
        C
        </p></div></div></p></div></div></p>
                </div>
              </td>
            </tr>
          </tbody>
          <tfoot>
            <tr>
              <td colspan="2" style="border-top:0pt;mso-border-top-alt:0pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">
                <div class="Note">
                  <a name="_cf69f8ff-21f2-4ce9-aefb-0bebf988b8fa" id="_cf69f8ff-21f2-4ce9-aefb-0bebf988b8fa"/>
                  <p class="Note">B</p>
                </div>
              </td>
            </tr>
          </tfoot>
        </table>
      OUTPUT
  end
end

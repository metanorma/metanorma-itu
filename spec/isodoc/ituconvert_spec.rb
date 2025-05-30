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
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(output)
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
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(output)
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
                <em>(Andorra, 1204</em>
                )
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
                <i>(Andorra, 1204</i>
                )
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
                <i>(Andorra, 1204</i>
                )
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
    expect(Xml::C14n.format(strip_guid(pres_output
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(IsoDoc::Itu::HtmlConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")
      .gsub(/fn:_?[0-9a-f-][0-9a-f-]+/, "fn:_")
      .gsub(%r{<sup>[0-9a-f-][0-9a-f-]+</sup>}, "<sup>_</sup>")))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(IsoDoc::Itu::WordConvert.new({})
      .convert("test", pres_output, true)
      .sub(%r{^.*<body }m, "<body xmlns:epub='epub' ")
      .sub(%r{</body>.*$}m, "</body>")
      .gsub(%r{_Ref\d+}, "_Ref")
      .gsub(%r{<sup>[0-9a-f-][0-9a-f-]+</sup>}, "<sup>_</sup>")
      .gsub(%r{ftn_?[0-9a-f-][0-9a-f-]+}, "ftn_")))
      .to be_equivalent_to Xml::C14n.format(word)
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
            <p align="center" class="zzSTDTitle2" displayorder="2"><em>(Andorra, 1204</em>)</p>
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
          <p class='zzSTDTitle2'  style='text-align:center;'><i>(Andorra, 1204</i>)</p>
     <p class="supertitle" style="page-break-after: avoid;">SECTION 1</p>
     <div id="_"/>
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
    expect(Xml::C14n.format(IsoDoc::Itu::HtmlConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "cleans up footnotes" do
    FileUtils.rm_f "test.html"
    input = <<~INPUT
      <itu-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <title language="en" format="text/plain" type="main">An ITU Standard</title>
          <ext><doctype>recommendation</doctype></ext>
          </bibdata>
          <preface>
          <foreword displayorder="1">
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
          <sections>
          <clause/>
          </sections>
          </itu-standard>
    INPUT
    presxml = <<~PRESXML
      <itu-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata>
             <title language="en" format="text/plain" type="main">An ITU Standard</title>
             <ext>
                <doctype language="">recommendation</doctype>
                <doctype language="en">Recommendation</doctype>
             </ext>
          </bibdata>
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Table of Contents</fmt-title>
             </clause>
             <foreword displayorder="2" id="_">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <p>
                   A.
                   <fn reference="1" id="_" original-reference="2" target="_">
                      <p original-id="_">Formerly denoted as 15 % (m/m).</p>
                      <fmt-fn-label>
                         <span class="fmt-caption-label">
                            <sup>
                               <semx element="autonum" source="_">1</semx>
                            </sup>
                         </span>
                      </fmt-fn-label>
                   </fn>
                </p>
                <p>
                   B.
                   <fn reference="1" id="_" original-reference="2" target="_">
                      <p id="_">Formerly denoted as 15 % (m/m).</p>
                      <fmt-fn-label>
                         <span class="fmt-caption-label">
                            <sup>
                               <semx element="autonum" source="_">1</semx>
                            </sup>
                         </span>
                      </fmt-fn-label>
                   </fn>
                </p>
                <p>
                   C.
                   <fn reference="2" id="_" original-reference="1" target="_">
                      <p original-id="_">Hello! denoted as 15 % (m/m).</p>
                      <fmt-fn-label>
                         <span class="fmt-caption-label">
                            <sup>
                               <semx element="autonum" source="_">2</semx>
                            </sup>
                         </span>
                      </fmt-fn-label>
                   </fn>
                </p>
                <table id="tableD-1" alt="tool tip" summary="long desc" autonum="1">
                   <name id="_">
                      Table 1 — Repeatability and reproducibility of
                      <em>husked</em>
                      rice yield
                   </name>
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Table</span>
                         <semx element="autonum" source="tableD-1">1</semx>
                      </span>
                      <span class="fmt-caption-delim"> — </span>
                      <semx element="name" source="_">
                         Table 1 — Repeatability and reproducibility of
                         <em>husked</em>
                         rice yield
                      </semx>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Table</span>
                      <semx element="autonum" source="tableD-1">1</semx>
                   </fmt-xref-label>
                   <thead>
                      <tr>
                         <td rowspan="2" align="left">Description</td>
                         <td colspan="4" align="center">Rice sample</td>
                      </tr>
                   </thead>
                   <tbody>
                      <tr>
                         <td align="left">Arborio</td>
                         <td align="center">
                            Drago
                            <fn reference="a" id="_" target="_">
                               <p original-id="_">Parboiled rice.</p>
                               <fmt-fn-label>
                                  <span class="fmt-caption-label">
                                     <sup>
                                        <semx element="autonum" source="_">a</semx>
                                        <span class="fmt-label-delim">)</span>
                                     </sup>
                                  </span>
                               </fmt-fn-label>
                            </fn>
                         </td>
                         <td align="center">
                            Balilla
                            <fn reference="a" id="_" target="_">
                               <p id="_">Parboiled rice.</p>
                               <fmt-fn-label>
                                  <span class="fmt-caption-label">
                                     <sup>
                                        <semx element="autonum" source="_">a</semx>
                                        <span class="fmt-label-delim">)</span>
                                     </sup>
                                  </span>
                               </fmt-fn-label>
                            </fn>
                         </td>
                         <td align="center">Thaibonnet</td>
                      </tr>
                   </tbody>
                   <fmt-footnote-container>
                      <fmt-fn-body id="_" target="_" reference="a">
                         <semx element="fn" source="_">
                            <p id="_">
                               <fmt-fn-label>
                                  <span class="fmt-caption-label">
                                     <sup>
                                        <semx element="autonum" source="_">a</semx>
                                        <span class="fmt-label-delim">)</span>
                                     </sup>
                                  </span>
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
             </foreword>
          </preface>
          <sections>
             <p class="zzSTDTitle2" displayorder="3">
                An ITU Standard
                <fn id="_" reference="3" original-reference="H0" target="_">
                   <p>One fn</p>
                   <fmt-fn-label>
                      <span class="fmt-caption-label">
                         <sup>
                            <semx element="autonum" source="_">3</semx>
                         </sup>
                      </span>
                   </fmt-fn-label>
                </fn>
                <fn id="_" reference="4" original-reference="H1" target="_">
                   <p>Another fn</p>
                   <fmt-fn-label>
                      <span class="fmt-caption-label">
                         <sup>
                            <semx element="autonum" source="_">4</semx>
                         </sup>
                      </span>
                   </fmt-fn-label>
                </fn>
             </p>
      <clause id="_" displayorder="4">
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
          <fmt-footnote-container>
             <fmt-fn-body id="_" target="_" reference="1">
                <semx element="fn" source="_">
                   <p id="_">
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
                      Formerly denoted as 15 % (m/m).
                   </p>
                </semx>
             </fmt-fn-body>
             <fmt-fn-body id="_" target="_" reference="2">
                <semx element="fn" source="_">
                   <p id="_">
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
                      Hello! denoted as 15 % (m/m).
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
                      One fn
                   </p>
                </semx>
             </fmt-fn-body>
             <fmt-fn-body id="_" target="_" reference="4">
                <semx element="fn" source="_">
                   <p>
                      <fmt-fn-label>
                         <span class="fmt-caption-label">
                            <sup>
                               <semx element="autonum" source="_">4</semx>
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
          </fmt-footnote-container>
       </itu-standard>
    PRESXML
    pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    IsoDoc::Itu::HtmlConvert.new({}).convert("test", pres_output, false)
    expect(File.exist?("test.html")).to be true
    html = File.read("test.html", encoding: "UTF-8")
    output = <<~OUTPUT
      <main xmlns:epub="epub" class="main-section">
          <button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
          <br/>
          <div id="_">
             <h1 class="IntroTitle" id="_">
                <a class="anchor" href="#_"/>
                <a class="header" href="#_">Foreword</a>
             </h1>
             <p>
                A.
                <a class="FootnoteRef" href="#fn:_" id="fnref:1">
                   <sup>1</sup>
                </a>
             </p>
             <p>
                B.
                <a class="FootnoteRef" href="#fn:_">
                   <sup>1</sup>
                </a>
             </p>
             <p>
                C.
                <a class="FootnoteRef" href="#fn:_" id="fnref:3">
                   <sup>2</sup>
                </a>
             </p>
             <p class="TableTitle" style="text-align:center;">
                Table 1 — Table 1 — Repeatability and reproducibility of
                <i>husked</i>
                rice yield
             </p>
             <table id="tableD-1" class="MsoISOTable" style="border-width:1px;border-spacing:0;" title="tool tip">
                <caption>
                   <span style="display:none">long desc</span>
                </caption>
                <thead>
                   <tr>
                      <td rowspan="2" style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;" scope="col">Description</td>
                      <td colspan="4" style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;" scope="colgroup">Rice sample</td>
                   </tr>
                </thead>
                <tbody>
                   <tr>
                      <td style="text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Arborio</td>
                      <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">
                         Drago
                         <a href="#tableD-1a" class="TableFootnoteRef">a)</a>
                      </td>
                      <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">
                         Balilla
                         <a href="#tableD-1a" class="TableFootnoteRef">a)</a>
                      </td>
                      <td style="text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;">Thaibonnet</td>
                   </tr>
                </tbody>
                <tfoot>
                   <tr>
                      <td colspan="5" style="border-top:0pt;border-bottom:solid windowtext 1.5pt;">
                         <div id="fn:tableD-1a" class="TableFootnote">
                            <p id="_" class="TableFootnote">
                               <span class="TableFootnoteRef">a)</span>
                                 Parboiled rice.
                            </p>
                         </div>
                      </td>
                   </tr>
                </tfoot>
             </table>
          </div>
          <p class="zzSTDTitle2">
             An ITU Standard
             <a class="FootnoteRef" href="#fn:_" id="fnref:4">
                <sup>3</sup>
             </a>
             <a class="FootnoteRef" href="#fn:_" id="fnref:5">
                <sup>4</sup>
             </a>
          </p>
            <div id="_">
               <h1 id="_">
                  <a class="anchor" href="#_"/>
                  <a class="header" href="#_">1.</a>
               </h1>
            </div>
          <aside id="fn:_" class="footnote">
             <p id="_">
                <a class="FootnoteRef" href="#fn:_">
                   <sup>1</sup>
                </a>
                Formerly denoted as 15 % (m/m).
             </p>
             <a href="#fnref:1">↩</a>
          </aside>
          <aside id="fn:_" class="footnote">
             <p id="_">
                <a class="FootnoteRef" href="#fn:_">
                   <sup>2</sup>
                </a>
                Hello! denoted as 15 % (m/m).
             </p>
             <a href="#fnref:3">↩</a>
          </aside>
          <aside id="fn:_" class="footnote">
             <p>
                <a class="FootnoteRef" href="#fn:_">
                   <sup>3</sup>
                </a>
                One fn
             </p>
             <a href="#fnref:4">↩</a>
          </aside>
          <aside id="fn:_" class="footnote">
             <p>
                <a class="FootnoteRef" href="#fn:_">
                   <sup>4</sup>
                </a>
                Another fn
             </p>
             <a href="#fnref:5">↩</a>
          </aside>
       </main>
      OUTPUT
    expect(Xml::C14n.format(strip_guid(html.sub(/^.*<main /m, "<main xmlns:epub='epub' ")
      .sub(%r{</main>.*$}m, "</main>")
      .gsub(%r{<script>.+?</script>}i, "")
      .gsub(/fn:[0-9a-f][0-9a-f-]+/, "fn:_"))))
      .to be_equivalent_to Xml::C14n.format(output)

    FileUtils.rm_f "test.doc"
    IsoDoc::Itu::WordConvert.new({}).convert("test", pres_output, false)
    expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc", encoding: "UTF-8")
    output = <<~OUTPUT
       <table class="MsoISOTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;" title="tool tip" summary="long desc">
          <a name="tableD-1" id="tableD-1"/>
          <thead>
             <tr>
                <td rowspan="2" valign="top" align="left" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">Description</td>
                <td colspan="4" valign="top" align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:avoid;">Rice sample</td>
             </tr>
          </thead>
          <tbody>
             <tr>
                <td valign="top" align="left" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">Arborio</td>
                <td valign="top" align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">
                   Drago
                   <a href="#tableD-1a" class="TableFootnoteRef">a)</a>
                </td>
                <td valign="top" align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">
                   Balilla
                   <a href="#tableD-1a" class="TableFootnoteRef">a)</a>
                </td>
                <td valign="top" align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;page-break-after:auto;">Thaibonnet</td>
             </tr>
          </tbody>
          <tfoot>
             <tr>
                <td colspan="5" style="border-top:0pt;mso-border-top-alt:0pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;">
                   <div class="TableFootnote">
                      <a name="ftntableD-1a" id="ftntableD-1a"/>
                      <p class="TableFootnote">
                         <a name="_0fe65e9a-5531-408e-8295-eeff35f41a55" id="_0fe65e9a-5531-408e-8295-eeff35f41a55"/>
                         <span class="TableFootnoteRef">a)</span>
                         <span style="mso-tab-count:1">  </span>
                         Parboiled rice.
                      </p>
                   </div>
                </td>
             </tr>
          </tfoot>
       </table>
      OUTPUT
      expect(Xml::C14n.format(html
      .sub(%r{^.*<div align="center" class="table_container">}m, "")
      .sub(%r{</table>.*$}m, "</table>")))
      .to be_equivalent_to Xml::C14n.format(output)
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

  it "processes eref types" do
    input = <<~INPUT
          <itu-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <p id="A">
          <eref type="footnote" bibitemid="ISO712" citeas="ISO 712">A</eref>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712">A</eref>
          <eref type="footnote" bibitemid="ISO712" citeas="ISO 712"></eref>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712"></eref>
          <eref type="footnote" bibitemid="ISO712" citeas="ISO 712"><locality type="section"><referenceFrom>8</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712"><locality type="section"><referenceFrom>8</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712"><localityStack connective="and"><locality type="section"><referenceFrom>8</referenceFrom></locality></localityStack><localityStack connective="and"><locality type="section"><referenceFrom>10</referenceFrom></locality></localityStack></eref>
          </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>References</title>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals and cereal products</title>
        <docidentifier>ISO 712</docidentifier>
        <date type="published"><on>2019-01-01</on></date>
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
       <p id="A">
          <eref type="footnote" bibitemid="ISO712" citeas="ISO 712" id="_">A</eref>
          <semx element="eref" source="_">
             <sup>
                <fmt-xref type="footnote" target="ISO712">A</fmt-xref>
             </sup>
          </semx>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712" id="_">A</eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">A</fmt-xref>
          </semx>
          <eref type="footnote" bibitemid="ISO712" citeas="ISO 712" id="_"/>
          <semx element="eref" source="_">
             <sup>
                <fmt-xref type="footnote" target="ISO712">[ISO 712]</fmt-xref>
             </sup>
          </semx>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712" id="_"/>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">[ISO 712]</fmt-xref>
          </semx>
          <eref type="footnote" bibitemid="ISO712" citeas="ISO 712" id="_">
             <locality type="section">
                <referenceFrom>8</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <sup>
                <fmt-xref type="footnote" target="ISO712">[ISO 712], Section 8</fmt-xref>
             </sup>
          </semx>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712" id="_">
             <locality type="section">
                <referenceFrom>8</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">[ISO 712], Section 8</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712" id="_">
             <localityStack connective="and">
                <locality type="section">
                   <referenceFrom>8</referenceFrom>
                </locality>
             </localityStack>
             <localityStack connective="and">
                <locality type="section">
                   <referenceFrom>10</referenceFrom>
                </locality>
             </localityStack>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">
                [ISO 712], Sections 8
                <span class="fmt-conn">and</span>
                10
             </fmt-xref>
          </semx
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes erefs and xrefs and links (Word)" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <p>
          <eref type="footnote" bibitemid="ISO712" citeas="ISO 712">A</stem>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712">A</stem>
          <xref target="http_1_1">Requirement <tt>/req/core/http</tt></xref>
          <link target="http://www.example.com">Test</link>
          <link target="http://www.example.com"/>
          </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>References</title>
      <bibitem id="ISO712" type="standard">
        <formattedref format="text/plain"><em>Cereals and cereal products</em>.</formattedref>
        <docidentifier>ISO 712</docidentifier>
      </bibitem>
          </references>
          </bibliography>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Table of Contents</fmt-title>
             </clause>
             <foreword displayorder="2" id="_">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <p>
                   <eref type="footnote" bibitemid="ISO712" citeas="ISO 712" id="_">A</eref>
                   <semx element="eref" source="_">
                      <sup>
                         <fmt-xref type="footnote" target="ISO712">A</fmt-xref>
                      </sup>
                   </semx>
                   <eref type="inline" bibitemid="ISO712" citeas="ISO 712" id="_">A</eref>
                   <semx element="eref" source="_">
                      <fmt-xref type="inline" target="ISO712">A</fmt-xref>
                   </semx>
                   <xref target="http_1_1" id="_">
                      Requirement
                      <tt>/req/core/http</tt>
                   </xref>
                   <semx element="xref" source="_">
                      <fmt-xref target="http_1_1">
                         Requirement
                         <tt>/req/core/http</tt>
                      </fmt-xref>
                   </semx>
                   <link target="http://www.example.com" id="_">Test</link>
                   <semx element="link" source="_">
                      <fmt-link target="http://www.example.com">Test</fmt-link>
                   </semx>
                   <link target="http://www.example.com" id="_"/>
                   <semx element="link" source="_">
                      <fmt-link target="http://www.example.com"/>
                   </semx>
                </p>
             </foreword>
          </preface>
          <sections>
             <references id="_" obligation="informative" normative="true" displayorder="3">
                <title id="_">References</title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="_">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">References</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">clause</span>
                   <semx element="autonum" source="_">1</semx>
                </fmt-xref-label>
                <bibitem id="ISO712" type="standard">
                   <formattedref format="text/plain">
                      ISO 712,
                      <em>Cereals and cereal products</em>
                      .
                   </formattedref>
                   <docidentifier>ISO 712</docidentifier>
                   <docidentifier scope="biblio-tag">ISO 712</docidentifier>
                   <biblio-tag>[ISO 712]</biblio-tag>
                </bibitem>
             </references>
          </sections>
          <bibliography>
           </bibliography>
       </iso-standard>
    OUTPUT
    output = <<~OUTPUT
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
            <p>
              <sup>
                <a href="#ISO712">A</a>
              </sup>
              <a href="#ISO712">A</a>
              <a href="#http_1_1">Requirement <tt>/req/core/http</tt></a>
              <a href="http://www.example.com" class="url">Test</a>
              <a href="http://www.example.com" class="url">http://www.example.com</a>
            </p>
          </div>
          <p> </p>
        </div>
        <p class="section-break">
          <br clear="all" class="section"/>
        </p>
        <div class="WordSection3">
          <div>
            <h1>1.<span style="mso-tab-count:1">  </span>References</h1>
            <table class="biblio" border="0">
              <tbody>
                <tr id="ISO712" class="NormRef">
                  <td style="vertical-align:top">[ISO 712]</td>
                  <td>ISO 712, <i>Cereals and cereal products</i>.</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </body>
    OUTPUT
    pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::WordConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(output)
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
    expect(Xml::C14n.format(strip_guid(File.read("test.html", encoding: "utf-8")
      .gsub(%r{^.*<div class="prefatory-section">}m, '<div class="prefatory-section">')
      .gsub(%r{<nav>.*}m, "</div>"))))
      .to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
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
    expect(Xml::C14n.format(strip_guid(File.read("test.doc", encoding: "utf-8"))
      .gsub(%r{^.*<div class="boilerplate-legal">}m, '<div><div class="boilerplate-legal">')
      .gsub(%r{<b>Table of Contents</b></p>.*}m, "<b>Table of Contents</b></p></div>")))
      .to be_equivalent_to Xml::C14n.format(<<~"OUTPUT")
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
        <p class="boilerplate"><a name="_" id="_"></a>As of the date of approval of this Recommendation, ITU had not received notice of intellectual property, protected by patents, which may be required to implement this Recommendation. However, implementers are cautioned that this may not represent the latest information and are therefore strongly urged to consult the TSB patent database at <a href="http://www.itu.int/ITU-T/ipr/" class="url">http://www.itu.int/ITU-T/ipr/</a>.
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
    expect(Xml::C14n.format(html
      .sub(%r{^.*<div align="center" class="table_container">}m, "")
      .sub(%r{</table>.*$}m, "</table>")))
      .to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
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
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata>
             <title language="en">test</title>
          </bibdata>
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Table of Contents</fmt-title>
             </clause>
             <p displayorder="2">
                <stem type="MathML" id="_">
                   <math xmlns="http://www.w3.org/1998/Math/MathML">
                      <mn>30000</mn>
                   </math>
                </stem>
                <fmt-stem type="MathML">
                   <semx element="stem" source="_">30'000</semx>
                </fmt-stem>
                <stem type="MathML" id="_">
                   <math xmlns="http://www.w3.org/1998/Math/MathML">
                      <mi>P</mi>
                      <mfenced open="(" close=")">
                         <mrow>
                            <mi>X</mi>
                            <mo>≥</mo>
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
                            <mo>∑</mo>
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
                            <mn>1000</mn>
                         </mrow>
                      </munderover>
                      <mfenced open="(" close=")">
                         <mtable>
                            <mtr>
                               <mtd>
                                  <mn>1000</mn>
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
                            <mfenced open="(" close=")">
                               <mrow>
                                  <mn>1</mn>
                                  <mo>−</mo>
                                  <mi>p</mi>
                               </mrow>
                            </mfenced>
                         </mrow>
                         <mrow>
                            <mrow>
                               <mn>1.003</mn>
                               <mo>−</mo>
                               <mi>j</mi>
                            </mrow>
                         </mrow>
                      </msup>
                   </math>
                </stem>
                <fmt-stem type="MathML">
                   <semx element="stem" source="_">
                      <math xmlns="http://www.w3.org/1998/Math/MathML">
                         <mi>P</mi>
                         <mfenced open="(" close=")">
                            <mrow>
                               <mi>X</mi>
                               <mo>≥</mo>
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
                               <mo>∑</mo>
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
                         <mfenced open="(" close=")">
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
                               <mfenced open="(" close=")">
                                  <mrow>
                                     <mn>1</mn>
                                     <mo>−</mo>
                                     <mi>p</mi>
                                  </mrow>
                               </mfenced>
                            </mrow>
                            <mrow>
                               <mrow>
                                  <mn>1.003</mn>
                                  <mo>−</mo>
                                  <mi>j</mi>
                               </mrow>
                            </mrow>
                         </msup>
                      </math>
                      <asciimath>P (X ge X_(max)) = sum_(j = X_(max))^(1000) ([[1000], [j]]) p^(j) (1 - p)^(1.003 - j)</asciimath>
                   </semx>
                </fmt-stem>
             </p>
          </preface>
       </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end

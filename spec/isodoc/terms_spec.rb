require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Itu do
  it "processes simple terms & definitions" do
    input = <<~INPUT
              <itu-standard xmlns="http://riboseinc.com/isoxml">
      <sections>
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
                <preface>
                    <clause type="toc" id="_" displayorder="1">
        <title depth="1">Table of Contents</title>
      </clause>
        </preface><sections>
        <terms id="H" obligation="normative" displayorder='2'><title depth="1">1.<tab/>Terms</title>
          <term id="J">
          <name>1.1.</name>
          <preferred><strong>Term2</strong>:</preferred>
          <definition><p>This is a journey into sound</p></definition>
          <termsource><origin citeas="[XYZ]">x y z</origin></termsource>
          <termnote id="J1" keep-with-next="true" keep-lines-together="true"><name>NOTE –</name><p>This is a note</p></termnote>
        </term>
          <term id="K">
          <name>1.2.</name>
          <preferred><strong>Term3</strong>:</preferred>
          <definition><p>This is a journey into sound</p></definition>
          <termsource><origin citeas="[XYZ]">x y z</origin></termsource>
          <termnote id="J2"><name>NOTE 1 –</name><p>This is a note</p></termnote>
          <termnote id="J3"><name>NOTE 2 –</name><p>This is a note</p></termnote>
        </term>
         </terms>
         </sections>
         </itu-standard>
    INPUT

    output = <<~OUTPUT
       #{HTML_HDR}
          <div id='H'>
            <h1>1.&#160; Terms</h1>
            <div id='J'>
              <p class='TermNum' id='J'>
                <b>1.1.&#160; <b>Term2</b>:</b>
                 [XYZ]
              </p>
              <p>This is a journey into sound</p>
              <div id='J1' class='Note' style='page-break-after: avoid;page-break-inside: avoid;'>
                <p>NOTE &#8211; This is a note</p>
              </div>
            </div>
            <div id='K'>
              <p class='TermNum' id='K'>
                <b>1.2.&#160; <b>Term3</b>:</b>
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
    pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(IsoDoc::Itu::HtmlConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "postprocesses simple terms & definitions" do
    FileUtils.rm_f "test.html"
    FileUtils.rm_f "test.doc"
    input = <<~INPUT
      <itu-standard xmlns="http://riboseinc.com/isoxml">
      <preface/><sections>
      <terms id="H" obligation="normative"><title>Terms</title>
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
    presxml = <<~INPUT
          <itu-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
      <preface>
            <clause type="toc" id="_" displayorder="1">
         <title depth="1">Table of Contents</title>
      </clause>
      </preface>
      <sections>
      <terms id="H" obligation="normative" displayorder="2"><title depth="1">1.<tab/>Terms</title>
        <term id="J">
        <name>1.1.</name>
        <preferred>Term2:</preferred>
        <definition><p>This is a journey into sound</p></definition>
        <termsource><origin citeas="[XYZ]">x y z</origin></termsource>
        <termnote id="J1"><name>NOTE –</name><p>This is a note</p></termnote>
      </term>
       </terms>
       </sections>
       </itu-standard>
    INPUT
    pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    IsoDoc::Itu::HtmlConvert.new({}).convert("test", pres_output, false)
    expect(Xml::C14n.format(strip_guid(File.read("test.html", encoding: "utf-8").to_s
      .gsub(%r{^.*<main}m, "<main")
      .gsub(%r{</main>.*}m, "</main>"))))
      .to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
         <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
         <br/>
              <div id="H"><h1 id="_"><a class="anchor" href="#H"/><a class="header" href="#H">1.&#xA0; Terms</a></h1>
          <div id="J"><p class="TermNum" id="J"><b>1.1.&#xA0; Term2:</b> [XYZ] This is a journey into sound</p>



          <div id="J1" class="Note"><p>NOTE – This is a note</p></div>
        </div>
         </div>
            </main>
      OUTPUT
  end

  it "processes terms & definitions subclauses with external, internal, and empty definitions" do
    input = <<~INPUT
         <itu-standard xmlns="http://riboseinc.com/isoxml">
               <termdocsource type="inline" bibitemid="ISO712"/>
               <preface>
             </preface><sections>
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
        <formattedref format="text/plain"><em>Cereals and cereal products?~@~I?~@~T?~@~IDetermination of moisture content?~@~I?~@~T?~@~IReference method</em>.</formattedref>
        <docidentifier>ISO 712</docidentifier>
      </bibitem></references>
      </bibliography>
              </itu-standard>
    INPUT
    presxml = <<~INPUT
      <itu-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
               <termdocsource type="inline" bibitemid="ISO712"/>
               <preface>
                   <clause type="toc" id="_" displayorder="1">
                  <title depth="1">Table of Contents</title>
            </clause>
             </preface><sections>
             <clause id="G" displayorder="3"><title depth="1">2.<tab/>Terms, Definitions, Symbols and Abbreviated Terms</title>
             <terms id="H" obligation="normative"><title depth="2">2.1.<tab/>Terms defined in this recommendation</title>
               <term id="J">
               <name>2.1.1.</name>
               <preferred>Term2:</preferred>
             </term>
             </terms>
             <terms id="I" obligation="normative"><title depth="2">2.2.<tab/>Terms defined elsewhere</title>
               <term id="K">
               <name>2.2.1.</name>
               <preferred>Term2:</preferred>
             </term>
             </terms>
             <terms id="L" obligation="normative"><title depth="2">2.3.<tab/>Other terms</title>
             </terms>
             </clause>
              <references id="_" obligation="informative" normative="true" displayorder="2"><title depth="1">1.<tab/>References</title>
      <bibitem id="ISO712" type="standard">
        <formattedref format="text/plain">ISO 712, <em>Cereals and cereal products?~@~I?~@~T?~@~IDetermination of moisture content?~@~I?~@~T?~@~IReference method</em>.</formattedref>
        <docidentifier>ISO 712</docidentifier>
        <docidentifier scope="biblio-tag">ISO 712</docidentifier>
        <biblio-tag>[ISO 712]</biblio-tag>
      </bibitem></references>
      </sections>
              <bibliography>
      </bibliography>
              </itu-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
                         <div>
                <h1>1.  References</h1>
                <table class="biblio" border="0">
                   <tbody>
                      <tr id="ISO712" class="NormRef">
                         <td style="vertical-align:top">[ISO 712]</td>
                         <td>
                            ISO 712,
                            <i>Cereals and cereal products?~@~I?~@~T?~@~IDetermination of moisture content?~@~I?~@~T?~@~IReference method</i>
                            .
                         </td>
                      </tr>
                   </tbody>
                </table>
             </div>
             <div id="G">
                <h1>2.  Terms, Definitions, Symbols and Abbreviated Terms</h1>
                <div id="H">
                   <h2>2.1.  Terms defined in this recommendation</h2>
                   <div id="J">
                      <p class="TermNum" id="J">
                         <b>2.1.1.  Term2:</b>
                      </p>
                   </div>
                </div>
                <div id="I">
                   <h2>2.2.  Terms defined elsewhere</h2>
                   <div id="K">
                      <p class="TermNum" id="K">
                         <b>2.2.1.  Term2:</b>
                      </p>
                   </div>
                </div>
                <div id="L">
                   <h2>2.3.  Other terms</h2>
                </div>
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
    expect(Xml::C14n.format(IsoDoc::Itu::HtmlConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to Xml::C14n.format(output)
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
                 <div id="H"><h1>1.&#xA0; Terms and definitions</h1><p>For the purposes of this document,
             the following terms and definitions apply.</p>
         <p class="Terms" style='text-align:left;' id="J"><b>1.1.</b>&#xA0;Term2</p>

         </div>
               </div>
             </body>
             </html>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::Itu::HtmlConvert.new({})
      .cleanup(Nokogiri::XML(input)).to_s))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end

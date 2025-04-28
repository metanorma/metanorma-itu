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
        <source><origin citeas="XYZ">x y z</origin></source>
        <termnote id="J1" keep-with-next="true" keep-lines-together="true"><p>This is a note</p></termnote>
      </term>
        <term id="K">
        <preferred><expression><name>Term3</name></expression></preferred>
        <definition><verbal-definition><p>This is a journey into sound</p></verbal-definition></definition>
        <source><origin citeas="XYZ">x y z</origin></source>
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
                 <fmt-title depth="1">Table of Contents</fmt-title>
              </clause>
           </preface>
           <sections>
              <terms id="H" obligation="normative" displayorder="2">
                 <title id="_">Terms</title>
                 <fmt-title depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="H">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">Terms</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">clause</span>
                    <semx element="autonum" source="H">1</semx>
                 </fmt-xref-label>
                 <term id="J">
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="H">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="J">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <span class="fmt-element-name">clause</span>
                       <semx element="autonum" source="H">1</semx>
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
                    <definition id="_">
                       <verbal-definition>
                          <p>This is a journey into sound</p>
                       </verbal-definition>
                    </definition>
                    <fmt-definition>
                       <semx element="definition" source="_">
                          <p>This is a journey into sound</p>
                       </semx>
                    </fmt-definition>
                    <source id="_">
                       <origin citeas="XYZ">x y z</origin>
                    </source>
                    <fmt-termsource>
                       <semx element="source" source="_">
                          <origin citeas="XYZ" id="_">x y z</origin>
                          <semx element="origin" source="_">
                             <fmt-origin citeas="[XYZ]">x y z</fmt-origin>
                          </semx>
                       </semx>
                    </fmt-termsource>
                    <termnote id="J1" keep-with-next="true" keep-lines-together="true" autonum="">
                       <fmt-name>
                          <span class="fmt-caption-label">
                             <span class="fmt-element-name">NOTE</span>
                          </span>
                          <span class="fmt-label-delim"> – </span>
                       </fmt-name>
                       <fmt-xref-label>
                          <span class="fmt-element-name">clause</span>
                          <semx element="autonum" source="H">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="J">1</semx>
                          <span class="fmt-comma">,</span>
                          <span class="fmt-element-name">Note</span>
                       </fmt-xref-label>
                       <p>This is a note</p>
                    </termnote>
                 </term>
                 <term id="K">
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="H">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="K">2</semx>
                          <span class="fmt-autonum-delim">.</span>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <span class="fmt-element-name">clause</span>
                       <semx element="autonum" source="H">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="K">2</semx>
                    </fmt-xref-label>
                    <preferred id="_">
                       <expression>
                          <name>Term3</name>
                       </expression>
                    </preferred>
                    <fmt-preferred>
                       <semx element="preferred" source="_">
                          <strong>Term3</strong>
                          :
                       </semx>
                    </fmt-preferred>
                    <definition id="_">
                       <verbal-definition>
                          <p>This is a journey into sound</p>
                       </verbal-definition>
                    </definition>
                    <fmt-definition>
                       <semx element="definition" source="_">
                          <p>This is a journey into sound</p>
                       </semx>
                    </fmt-definition>
                    <source id="_">
                       <origin citeas="XYZ">x y z</origin>
                    </source>
                    <fmt-termsource>
                       <semx element="source" source="_">
                          <origin citeas="XYZ" id="_">x y z</origin>
                          <semx element="origin" source="_">
                             <fmt-origin citeas="[XYZ]">x y z</fmt-origin>
                          </semx>
                       </semx>
                    </fmt-termsource>
                    <termnote id="J2" autonum="1">
                       <fmt-name>
                          <span class="fmt-caption-label">
                             <span class="fmt-element-name">NOTE</span>
                             <semx element="autonum" source="J2">1</semx>
                          </span>
                          <span class="fmt-label-delim"> – </span>
                       </fmt-name>
                       <fmt-xref-label>
                          <span class="fmt-element-name">clause</span>
                          <semx element="autonum" source="H">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="K">2</semx>
                          <span class="fmt-comma">,</span>
                          <span class="fmt-element-name">Note</span>
                          <semx element="autonum" source="J2">1</semx>
                       </fmt-xref-label>
                       <p>This is a note</p>
                    </termnote>
                    <termnote id="J3" autonum="2">
                       <fmt-name>
                          <span class="fmt-caption-label">
                             <span class="fmt-element-name">NOTE</span>
                             <semx element="autonum" source="J3">2</semx>
                          </span>
                          <span class="fmt-label-delim"> – </span>
                       </fmt-name>
                       <fmt-xref-label>
                          <span class="fmt-element-name">clause</span>
                          <semx element="autonum" source="H">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="K">2</semx>
                          <span class="fmt-comma">,</span>
                          <span class="fmt-element-name">Note</span>
                          <semx element="autonum" source="J3">2</semx>
                       </fmt-xref-label>
                       <p>This is a note</p>
                    </termnote>
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
                          <b>
               1.1. 
               <b>Term2</b>
               :
            </b>
                 [XYZ]
              </p>
              <p>This is a journey into sound</p>
              <div id='J1' class='Note' style='page-break-after: avoid;page-break-inside: avoid;'>
                <p><span class="termnote_label">NOTE &#8211; </span>This is a note</p>
              </div>
            </div>
            <div id='K'>
              <p class='TermNum' id='K'>
                <b>1.2.&#160; <b>Term3</b>:</b>
                 [XYZ]
              </p>
              <p>This is a journey into sound</p>
              <div id='J2' class='Note'>
                <p><span class="termnote_label">NOTE 1 &#8211; </span>This is a note</p>
              </div>
              <div id='J3' class='Note'>
                <p><span class="termnote_label">NOTE 2 &#8211; </span>This is a note</p>
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
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::HtmlConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
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
        <preferred><expression><name>Term2</name></expression></preferred>
        <definition><p>This is a journey into sound</p></definition>
        <source><origin citeas="XYZ">x y z</origin></source>
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
                 <fmt-title depth="1">Table of Contents</fmt-title>
              </clause>
           </preface>
           <sections>
              <terms id="H" obligation="normative" displayorder="2">
                 <title id="_">Terms</title>
                 <fmt-title depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="H">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">Terms</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">clause</span>
                    <semx element="autonum" source="H">1</semx>
                 </fmt-xref-label>
                 <term id="J">
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="H">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="J">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <span class="fmt-element-name">clause</span>
                       <semx element="autonum" source="H">1</semx>
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
                    <definition id="_">
                       <p>This is a journey into sound</p>
                    </definition>
                    <fmt-definition>
                       <semx element="definition" source="_">
                          <p>This is a journey into sound</p>
                       </semx>
                    </fmt-definition>
                    <source id="_">
                       <origin citeas="XYZ">x y z</origin>
                    </source>
                    <fmt-termsource>
                       <semx element="source" source="_">
                          <origin citeas="XYZ" id="_">x y z</origin>
                          <semx element="origin" source="_">
                             <fmt-origin citeas="[XYZ]">x y z</fmt-origin>
                          </semx>
                       </semx>
                    </fmt-termsource>
                    <termnote id="J1" autonum="">
                       <fmt-name>
                          <span class="fmt-caption-label">
                             <span class="fmt-element-name">NOTE</span>
                          </span>
                          <span class="fmt-label-delim"> – </span>
                       </fmt-name>
                       <fmt-xref-label>
                          <span class="fmt-element-name">clause</span>
                          <semx element="autonum" source="H">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="J">1</semx>
                          <span class="fmt-comma">,</span>
                          <span class="fmt-element-name">Note</span>
                       </fmt-xref-label>
                       <p>This is a note</p>
                    </termnote>
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
          <div id="J"><p class="TermNum" id="J"><b>1.1.&#xA0; <b>Term2</b>:</b> [XYZ] This is a journey into sound</p>



          <div id="J1" class="Note"><p><span class="termnote_label">NOTE – </span>This is a note</p></div>
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
               <preferred><expression><name>Term2</name></expression></preferred>
             </term>
             </terms>
             <terms id="I" obligation="normative"><title>Terms defined elsewhere</title>
               <term id="K">
               <preferred><expression><name>Term2</name></expression></preferred>
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
                <fmt-title depth="1">Table of Contents</fmt-title>
             </clause>
          </preface>
          <sections>
             <clause id="G" displayorder="3">
                <title id="_">Terms, Definitions, Symbols and Abbreviated Terms</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="G">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Terms, Definitions, Symbols and Abbreviated Terms</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">clause</span>
                   <semx element="autonum" source="G">2</semx>
                </fmt-xref-label>
                <terms id="H" obligation="normative">
                   <title id="_">Terms defined in this recommendation</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="G">2</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="H">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Terms defined in this recommendation</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">clause</span>
                      <semx element="autonum" source="G">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="H">1</semx>
                   </fmt-xref-label>
                   <term id="J">
                      <fmt-name>
                         <span class="fmt-caption-label">
                            <semx element="autonum" source="G">2</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="H">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="J">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">clause</span>
                         <semx element="autonum" source="G">2</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="H">1</semx>
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
                <terms id="I" obligation="normative">
                   <title id="_">Terms defined elsewhere</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="G">2</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="I">2</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Terms defined elsewhere</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">clause</span>
                      <semx element="autonum" source="G">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="I">2</semx>
                   </fmt-xref-label>
                   <term id="K">
                      <fmt-name>
                         <span class="fmt-caption-label">
                            <semx element="autonum" source="G">2</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="I">2</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="K">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">clause</span>
                         <semx element="autonum" source="G">2</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="I">2</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="K">1</semx>
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
                <terms id="L" obligation="normative">
                   <title id="_">Other terms</title>
                   <fmt-title depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="G">2</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="L">3</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Other terms</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">clause</span>
                      <semx element="autonum" source="G">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="L">3</semx>
                   </fmt-xref-label>
                </terms>
             </clause>
             <references id="_" obligation="informative" normative="true" displayorder="2">
                <title id="_">References</title>
                <fmt-title depth="1">
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
                      <em>Cereals and cereal products?~@~I?~@~T?~@~IDetermination of moisture content?~@~I?~@~T?~@~IReference method</em>
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
                         <b>
                            2.1.1. 
                            <b>Term2</b>
                            :
                         </b>
                      </p>
                   </div>
                </div>
                <div id="I">
                   <h2>2.2.  Terms defined elsewhere</h2>
                   <div id="K">
                      <p class="TermNum" id="K">
                         <b>
                            2.2.1. 
                            <b>Term2</b>
                            :
                         </b>
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
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::HtmlConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
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

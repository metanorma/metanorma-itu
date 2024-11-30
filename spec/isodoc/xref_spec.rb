require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Itu do
  it "cross-references notes" do
    input = <<~INPUT
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
          <clause id="scope" type="scope"><title>Scope</title>
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
    output = <<~OUTPUT
      <foreword displayorder="2">
          <title id="_">Foreword</title>
          <fmt-title depth="1">
             <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="N1">
                <span class="fmt-element-name">Note</span>
                <span class="fmt-conn">in</span>
                <span class="fmt-xref-container">
                   <semx element="introduction" source="intro">Introduction</semx>
                </span>
             </xref>
             <xref target="N2">
                <span class="fmt-element-name">Note</span>
                <span class="fmt-conn">in</span>
                <span class="fmt-xref-container">
                   <semx element="clause" source="xyz">Preparatory</semx>
                </span>
             </xref>
             <xref target="N">
                <span class="fmt-element-name">Note</span>
                <span class="fmt-conn">in</span>
                <span class="fmt-xref-container">
                   <span class="fmt-element-name">clause</span>
                   <semx element="autonum" source="scope">1</semx>
                </span>
             </xref>
             <xref target="note1">
                <span class="fmt-element-name">Note</span>
                <semx element="autonum" source="note1">1</semx>
                <span class="fmt-conn">in</span>
                <span class="fmt-xref-container">
                   <span class="fmt-element-name">clause</span>
                   <semx element="autonum" source="widgets">3</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="widgets1">1</semx>
                </span>
             </xref>
             <xref target="note2">
                <span class="fmt-element-name">Note</span>
                <semx element="autonum" source="note2">2</semx>
                <span class="fmt-conn">in</span>
                <span class="fmt-xref-container">
                   <span class="fmt-element-name">clause</span>
                   <semx element="autonum" source="widgets">3</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="widgets1">1</semx>
                </span>
             </xref>
             <xref target="AN">
                <span class="fmt-element-name">Note</span>
                <span class="fmt-conn">in</span>
                <span class="fmt-xref-container">
                   <span class="fmt-element-name">clause</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="annex1a">1</semx>
                </span>
             </xref>
             <xref target="Anote1">
                <span class="fmt-element-name">Note</span>
                <semx element="autonum" source="Anote1">1</semx>
                <span class="fmt-conn">in</span>
                <span class="fmt-xref-container">
                   <span class="fmt-element-name">clause</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="annex1b">2</semx>
                </span>
             </xref>
             <xref target="Anote2">
                <span class="fmt-element-name">Note</span>
                <semx element="autonum" source="Anote2">2</semx>
                <span class="fmt-conn">in</span>
                <span class="fmt-xref-container">
                   <span class="fmt-element-name">clause</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="annex1b">2</semx>
                </span>
             </xref>
          </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Itu::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "cross-references subfigures" do
    input = <<~INPUT
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
                <xref target="AN1"/>
        <xref target="Anote11"/>
        <xref target="Anote21"/>
        </p>
        </foreword>
        </preface>
        <sections>
        <clause id="scope" type="scope"><title>Scope</title>
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
                  <bibliography><references normative="false" id="biblio"><title>Bibliographical Section</title>
                  <figure id="AN1">
            <figure id="Anote11">
      <name>Split-it-right sample divider</name>
      <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
      </figure>
        <figure id="Anote21">
      <name>Split-it-right sample divider</name>
      <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
      </figure>
      </figure>
          </references></bibliography>
        </iso-standard>
    INPUT
    presxml = <<~OUTPUT
              <foreword id="fwd" displayorder="2">
                 <title id="_">Foreword</title>
                 <fmt-title depth="1">
                    <semx element="title" source="_">Foreword</semx>
                 </fmt-title>
                 <p>
                    <xref target="N">
                       <span class="fmt-element-name">Figure</span>
                       <semx element="autonum" source="N">1</semx>
                    </xref>
                    <xref target="note1">
                       <span class="fmt-element-name">Figure</span>
                       <semx element="autonum" source="N">1</semx>
                       <span class="fmt-autonum-delim">-</span>
                       <semx element="autonum" source="note1">a</semx>
                    </xref>
                    <xref target="note2">
                       <span class="fmt-element-name">Figure</span>
                       <semx element="autonum" source="N">1</semx>
                       <span class="fmt-autonum-delim">-</span>
                       <semx element="autonum" source="note2">b</semx>
                    </xref>
                    <xref target="AN">
                       <span class="fmt-element-name">Figure</span>
                       <semx element="autonum" source="annex1">A</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="AN">1</semx>
                    </xref>
                    <xref target="Anote1">
                       <span class="fmt-element-name">Figure</span>
                       <semx element="autonum" source="annex1">A</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="AN">1</semx>
                       <span class="fmt-autonum-delim">-</span>
                       <semx element="autonum" source="Anote1">a</semx>
                    </xref>
                    <xref target="Anote2">
                       <span class="fmt-element-name">Figure</span>
                       <semx element="autonum" source="annex1">A</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="AN">1</semx>
                       <span class="fmt-autonum-delim">-</span>
                       <semx element="autonum" source="Anote2">b</semx>
                    </xref>
                          <xref target="AN1">
         <span class="fmt-element-name">Figure</span>
         <semx element="autonum" source="AN1">1</semx>
         <span class="fmt-conn">in</span>
         <span class="fmt-xref-container">
            <semx element="references" source="biblio">Bibliographical Section</semx>
         </span>
      </xref>
      <xref target="Anote11">
         <span class="fmt-element-name">Figure</span>
         <semx element="autonum" source="AN1">1</semx>
         <span class="fmt-autonum-delim">-</span>
         <semx element="autonum" source="Anote11">a</semx>
         <span class="fmt-conn">in</span>
         <span class="fmt-xref-container">
            <semx element="references" source="biblio">Bibliographical Section</semx>
         </span>
      </xref>
      <xref target="Anote21">
         <span class="fmt-element-name">Figure</span>
         <semx element="autonum" source="AN1">1</semx>
         <span class="fmt-autonum-delim">-</span>
         <semx element="autonum" source="Anote21">b</semx>
         <span class="fmt-conn">in</span>
         <span class="fmt-xref-container">
            <semx element="references" source="biblio">Bibliographical Section</semx>
         </span>
      </xref>

                 </p>
              </foreword>
    OUTPUT

    html = <<~OUTPUT
      <div id='fwd'>
      <h1 class="IntroTitle">Foreword</h1>
            <p>
              <a href='#N'>Figure 1</a>
              <a href='#note1'>Figure 1-a</a>
              <a href='#note2'>Figure 1-b</a>
              <a href='#AN'>Figure A.1</a>
              <a href='#Anote1'>Figure A.1-a</a>
              <a href='#Anote2'>Figure A.1-b</a>
      <a href="#AN1">Figure 1 in Bibliographical Section</a>
      <a href="#Anote11">Figure 1-a in Bibliographical Section</a>
      <a href="#Anote21">Figure 1-b in Bibliographical Section</a>
            </p>
          </div>
    OUTPUT
    pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(pres_output)
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Itu::HtmlConvert.new({})
      .convert("test", pres_output, true))
      .at("//div[@id = 'fwd']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "cross-references formulae" do
    input = <<~INPUT
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
    output = <<~OUTPUT
       <foreword displayorder="2">
          <title id="_">Foreword</title>
          <fmt-title depth="1">
                <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="N1">
                <span class="fmt-element-name">Equation</span>
                <span class="fmt-autonum-delim">(</span>
                <semx element="introduction" source="intro">Introduction</semx>
                <span class="fmt-autonum-delim">-</span>
                <semx element="autonum" source="N1">1</semx>
                <span class="fmt-autonum-delim">)</span>
             </xref>
             <xref target="N2">
                <span class="fmt-element-name">Inequality</span>
                <span class="fmt-autonum-delim">(</span>
                <semx element="introduction" source="intro">Introduction</semx>
                <span class="fmt-autonum-delim">-</span>
                <semx element="autonum" source="N2">2</semx>
                <span class="fmt-autonum-delim">)</span>
             </xref>
          </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Itu::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "cross-references annex subclauses" do
    input = <<~INPUT
          <itu-standard xmlns="http://riboseinc.com/isoxml">
                 <bibdata type="standard">
                 <title language="en" format="text/plain" type="main">An ITU Standard</title>
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
                 <preface>
        <abstract displayorder='2'><title>Abstract</title>
        <p>
        <xref target="A1"/>
      <xref target="A2"/>
      </p>
        </abstract>
        </preface>
                 <sections>
                 </sections>
          <annex id="A1" obligation="normative" displayorder='5'>
                  <title>Annex</title>
                  <clause id="A2"><title>Subtitle</title>
                  </clause>
          </annex>
    INPUT
    output = <<~OUTPUT
        <itu-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
           <bibdata type="standard">
              <title language="en" format="text/plain" type="main">An ITU Standard</title>
              <docidentifier type="ITU">12345</docidentifier>
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
              <clause type="toc" id="_" displayorder="1">
                 <fmt-title depth="1">Table of Contents</fmt-title>
              </clause>
              <abstract displayorder="2">
                 <title id="_">Abstract</title>
                 <fmt-title depth="1">
                    <semx element="title" source="_">Abstract</semx>
                 </fmt-title>
                 <p>
                    <xref target="A1">
                       <span class="fmt-element-name">Annex</span>
                       <semx element="autonum" source="A1">F2</semx>
                    </xref>
                    <xref target="A2">
                       <span class="fmt-element-name">clause</span>
                       <semx element="autonum" source="A1">F2</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="A2">1</semx>
                    </xref>
                 </p>
              </abstract>
              <clause type="keyword" displayorder="3">
                 <fmt-title depth="1">Keywords</fmt-title>
                 <p>A, B.</p>
              </clause>
           </preface>
           <sections>
              <p class="zzSTDTitle1">Draft new Recommendation 12345</p>
              <p class="zzSTDTitle2">An ITU Standard</p>
           </sections>
           <annex id="A1" obligation="normative" displayorder="4" autonum="F2">
              <title id="_">
                 <strong>Annex</strong>
              </title>
              <fmt-title>
                 <strong>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Annex</span>
                       <semx element="autonum" source="A1">F2</semx>
                    </span>
                 </strong>
                 <span class="fmt-caption-delim">
                    <br/>
                    <br/>
                 </span>
                 <semx element="title" source="_">
                    <strong>Annex</strong>
                 </semx>
              </fmt-title>
              <fmt-xref-label>
                 <span class="fmt-element-name">Annex</span>
                 <semx element="autonum" source="A1">F2</semx>
              </fmt-xref-label>
              <p class="annex_obligation">
                 <span class="fmt-obligation">(This annex forms an integral part of this Recommendation Annex.)</span>
              </p>
              <clause id="A2">
                 <title id="_">Subtitle</title>
                 <fmt-title depth="2">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="A1">F2</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="A2">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">Subtitle</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">clause</span>
                    <semx element="autonum" source="A1">F2</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="A2">1</semx>
                 </fmt-xref-label>
              </clause>
           </annex>
        </itu-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes figures as hierarchical assets (Presentation XML)" do
    input = <<~INPUT
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
        <clause id="scope" type="scope"><title>Scope</title>
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
    output = <<~OUTPUT
       <foreword id="fwd" displayorder="2">
          <title id="_">Foreword</title>
          <fmt-title depth="1">
                <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="N">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="widgets">3</semx>
                <span class="fmt-autonum-delim">.</span>
                <semx element="autonum" source="N">1</semx>
             </xref>
             <xref target="note1">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="widgets">3</semx>
                <span class="fmt-autonum-delim">.</span>
                <semx element="autonum" source="N">1</semx>
                <span class="fmt-autonum-delim">-</span>
                <semx element="autonum" source="note1">a</semx>
             </xref>
             <xref target="note2">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="widgets">3</semx>
                <span class="fmt-autonum-delim">.</span>
                <semx element="autonum" source="N">1</semx>
                <span class="fmt-autonum-delim">-</span>
                <semx element="autonum" source="note2">b</semx>
             </xref>
             <xref target="AN">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="annex1">A</semx>
                <span class="fmt-autonum-delim">.</span>
                <semx element="autonum" source="AN">1</semx>
             </xref>
             <xref target="Anote1">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="annex1">A</semx>
                <span class="fmt-autonum-delim">.</span>
                <semx element="autonum" source="AN">1</semx>
                <span class="fmt-autonum-delim">-</span>
                <semx element="autonum" source="Anote1">a</semx>
             </xref>
             <xref target="Anote2">
                <span class="fmt-element-name">Figure</span>
                <semx element="autonum" source="annex1">A</semx>
                <span class="fmt-autonum-delim">.</span>
                <semx element="autonum" source="AN">1</semx>
                <span class="fmt-autonum-delim">-</span>
                <semx element="autonum" source="Anote2">b</semx>
             </xref>
          </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Itu::PresentationXMLConvert
      .new({ hierarchicalassets: true })
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes formulae as non-hierarchical assets" do
    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface>
        <foreword id="fwd">
        <p>
        <xref target="note1"/>
        <xref target="note2"/>
        <xref target="AN"/>
        <xref target="Anote1"/>
        <xref target="Anote2"/>
        </p>
        </foreword>
        </preface>
        <sections>
        <clause id="scope" type="scope"><title>Scope</title>
        </clause>
        <terms id="terms"/>
        <clause id="widgets"><title>Widgets</title>
        <clause id="widgets1">
            <formula id="note1">
      <stem type="AsciiMath">r = 1 %</stem>
      </formula>
        <formula id="note2">
      <stem type="AsciiMath">r = 1 %</stem>
      </formula>
      <p>    <xref target="note1"/> <xref target="note2"/> </p>
        </clause>
        </clause>
        </sections>
        <annex id="annex1">
        <clause id="annex1a">
        </clause>
        <clause id="annex1b">
            <formula id="Anote1">
      <stem type="AsciiMath">r = 1 %</stem>
      </formula>
        <formula id="Anote2">
      <stem type="AsciiMath">r = 1 %</stem>
      </formula>
        </clause>
        </annex>
        </iso-standard>
    INPUT
    output = <<~OUTPUT
       <foreword id="fwd" displayorder="2">
          <title id="_">Foreword</title>
          <fmt-title depth="1">
                <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="note1">
                <span class="fmt-element-name">Equation</span>
                <span class="fmt-autonum-delim">(</span>
                <semx element="autonum" source="widgets">3</semx>
                <span class="fmt-autonum-delim">-</span>
                <semx element="autonum" source="note1">1</semx>
                <span class="fmt-autonum-delim">)</span>
             </xref>
             <xref target="note2">
                <span class="fmt-element-name">Equation</span>
                <span class="fmt-autonum-delim">(</span>
                <semx element="autonum" source="widgets">3</semx>
                <span class="fmt-autonum-delim">-</span>
                <semx element="autonum" source="note2">2</semx>
                <span class="fmt-autonum-delim">)</span>
             </xref>
             <xref target="AN">[AN]</xref>
             <xref target="Anote1">
                <span class="fmt-element-name">Equation</span>
                <span class="fmt-autonum-delim">(</span>
                <semx element="autonum" source="annex1">A</semx>
                <span class="fmt-autonum-delim">-</span>
                <semx element="autonum" source="Anote1">1</semx>
                <span class="fmt-autonum-delim">)</span>
             </xref>
             <xref target="Anote2">
                <span class="fmt-element-name">Equation</span>
                <span class="fmt-autonum-delim">(</span>
                <semx element="autonum" source="annex1">A</semx>
                <span class="fmt-autonum-delim">-</span>
                <semx element="autonum" source="Anote2">2</semx>
                <span class="fmt-autonum-delim">)</span>
             </xref>
          </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Itu::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "cross-references sections" do
    input = <<~INPUT
      <itu-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <ext><doctype>recommendation</doctype></ext>
      </bibdata>
      <preface>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble
         <xref target="C"/>
         <xref target="C1"/>
         <xref target="D"/>
         <xref target="H"/>
         <xref target="I"/>
         <xref target="J"/>
         <xref target="K"/>
         <xref target="L"/>
         <xref target="M"/>
         <xref target="N"/>
         <xref target="O"/>
         <xref target="P"/>
         <xref target="Q"/>
         <xref target="Q1"/>
         <xref target="R"/>
         <xref target="S"/>
         </p>
       </foreword>
        <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       <clause id="C1" inline-header="false" obligation="informative">Text</clause>
       </introduction></preface><sections>
       <clause id="D" obligation="normative" type="scope">
         <title>Scope</title>
         <p id="E">Text</p>
       </clause>

       <terms id="H" obligation="normative"><title>Terms, definitions, symbols and abbreviated terms</title><terms id="I" obligation="normative">
         <title>Normal Terms</title>
         <term id="J">
         <preferred><expression><name>Term2</name></expression></preferred>
       </term>
       </terms>
       <definitions id="K">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
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
       </annex>
        <bibliography><references id="R" obligation="informative" normative="true">
         <title>Normative References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative" normative="false">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </itu-standard>
    INPUT
    output = <<~OUTPUT
        <foreword obligation="informative" displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
                 <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p id="A">
              This is a preamble
              <xref target="C">
                 <semx element="clause" source="C">Introduction Subsection</semx>
              </xref>
              <xref target="C1">
                 <semx element="introduction" source="B">Introduction</semx>
                 <span class="fmt-comma">,</span>
                 <semx element="autonum" source="C1">2</semx>
              </xref>
              <xref target="D">
                 <span class="fmt-element-name">clause</span>
                 <semx element="autonum" source="D">1</semx>
              </xref>
              <xref target="H">
                 <span class="fmt-element-name">clause</span>
                 <semx element="autonum" source="H">3</semx>
              </xref>
              <xref target="I">
                 <span class="fmt-element-name">clause</span>
                 <semx element="autonum" source="H">3</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="I">1</semx>
              </xref>
              <xref target="J">
                 <span class="fmt-element-name">clause</span>
                 <semx element="autonum" source="H">3</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="I">1</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="J">1</semx>
              </xref>
              <xref target="K">
                 <span class="fmt-element-name">clause</span>
                 <semx element="autonum" source="H">3</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="K">2</semx>
              </xref>
              <xref target="L">
                 <span class="fmt-element-name">clause</span>
                 <semx element="autonum" source="L">4</semx>
              </xref>
              <xref target="M">
                 <span class="fmt-element-name">clause</span>
                 <semx element="autonum" source="M">5</semx>
              </xref>
              <xref target="N">
                 <span class="fmt-element-name">clause</span>
                 <semx element="autonum" source="M">5</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="N">1</semx>
              </xref>
              <xref target="O">
                 <span class="fmt-element-name">clause</span>
                 <semx element="autonum" source="M">5</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="O">2</semx>
              </xref>
              <xref target="P">
                 <span class="fmt-element-name">Annex</span>
                 <semx element="autonum" source="P">A</semx>
              </xref>
              <xref target="Q">
                 <span class="fmt-element-name">clause</span>
                 <semx element="autonum" source="P">A</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="Q">1</semx>
              </xref>
              <xref target="Q1">
                 <span class="fmt-element-name">clause</span>
                 <semx element="autonum" source="P">A</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="Q">1</semx>
                 <span class="fmt-autonum-delim">.</span>
                 <semx element="autonum" source="Q1">1</semx>
              </xref>
              <xref target="R">
                 <span class="fmt-element-name">clause</span>
                 <semx element="autonum" source="R">2</semx>
              </xref>
              <xref target="S">
                 <semx element="clause" source="S">Bibliography</semx>
              </xref>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Itu::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "cross-references sections in resolutions" do
    input = <<~INPUT
            <itu-standard xmlns="http://riboseinc.com/isoxml">
            <bibdata>
            <title>X</title>
            <ext><doctype>resolution</doctype>
            <meeting-place>Peoria</meeting-place>
            <meeting-date><on>1871-02-09</on></meeting-date>
      </ext>
            </bibdata>
            <preface>
            <foreword obligation="informative">
               <title>Foreword</title>
               <p id="A">This is a preamble
               <xref target="C"/>
               <xref target="C1"/>
               <xref target="D"/>
               <xref target="M"/>
               <xref target="N"/>
               <xref target="O"/>
               <xref target="P"/>
               <xref target="Q"/>
               <xref target="Q1"/>
               <xref target="S"/>
               </p>
             </foreword>
              <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
               <title>Introduction Subsection</title>
             </clause>
             <clause id="C1" inline-header="false" obligation="informative">Text</clause>
             </introduction></preface><sections>
             <clause id="D" obligation="normative" type="scope">
               <title>Scope</title>
               <p id="E">Text</p>
             </clause>
             <clause id="M" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
               <title>Introduction</title>
             </clause>
             <clause id="O" inline-header="false" obligation="normative">
               <title>Clause 4.2</title>
             </clause></clause>
             </sections><annex id="P" inline-header="false" obligation="normative">
               <title>Annex Title</title>
               <clause id="Q" inline-header="false" obligation="normative">
               <title>Annex A.1</title>
               <clause id="Q1" inline-header="false" obligation="normative">
               <title>Annex A.1a</title>
               </clause>
             </clause>
             </annex>
              <bibliography>
             <clause id="S" obligation="informative">
               <title>Bibliography</title>
               <references id="T" obligation="informative" normative="false">
               <title>Bibliography Subsection</title>
             </references>
             </clause>
             </bibliography>
             </itu-standard>
    INPUT

    presxml = <<~OUTPUT
        <itu-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
           <bibdata>
              <title>X</title>
              <title language="en" format="text/plain" type="resolution">RESOLUTION  (Peoria, 1871)</title>
              <title language="en" format="text/plain" type="resolution-placedate">Peoria, 1871</title>
              <ext>
                 <doctype language="">resolution</doctype>
                 <doctype language="en">Resolution</doctype>
                 <meeting-place>Peoria</meeting-place>
                 <meeting-date>
                    <on>1871-02-09</on>
                 </meeting-date>
              </ext>
           </bibdata>
           <preface>
              <foreword obligation="informative" displayorder="1">
                 <title id="_">Foreword</title>
                 <fmt-title depth="1">
                    <semx element="title" source="_">Foreword</semx>
                 </fmt-title>
                 <p id="A">
                    This is a preamble
                    <xref target="C">
                       <semx element="clause" source="C">Introduction Subsection</semx>
                    </xref>
                    <xref target="C1">
                       <semx element="introduction" source="B">Introduction</semx>
                       <span class="fmt-comma">,</span>
                       <semx element="autonum" source="C1">2</semx>
                    </xref>
                    <xref target="D">
                       <span class="fmt-element-name">Section</span>
                       <semx element="autonum" source="D">1</semx>
                    </xref>
                    <xref target="M">
                       <span class="fmt-element-name">Section</span>
                       <semx element="autonum" source="M">2</semx>
                    </xref>
                    <xref target="N">
                       <semx element="autonum" source="M">2</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="N">1</semx>
                    </xref>
                    <xref target="O">
                       <semx element="autonum" source="M">2</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="O">2</semx>
                    </xref>
                    <xref target="P">
                       <span class="fmt-element-name">Annex</span>
                       <semx element="autonum" source="P">A</semx>
                    </xref>
                    <xref target="Q">
                       <semx element="autonum" source="P">A</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="Q">1</semx>
                    </xref>
                    <xref target="Q1">
                       <semx element="autonum" source="P">A</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="Q">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="Q1">1</semx>
                    </xref>
                    <xref target="S">
                       <semx element="clause" source="S">Bibliography</semx>
                    </xref>
                 </p>
              </foreword>
              <introduction id="B" obligation="informative" displayorder="2">
                 <title id="_">Introduction</title>
                 <fmt-title depth="1">
                    <semx element="title" source="_">Introduction</semx>
                 </fmt-title>
                 <clause id="C" inline-header="false" obligation="informative">
                    <title id="_">Introduction Subsection</title>
                    <fmt-title depth="2">
                       <semx element="title" source="_">Introduction Subsection</semx>
                    </fmt-title>
                 </clause>
                 <clause id="C1" inline-header="false" obligation="informative">Text</clause>
              </introduction>
           </preface>
           <sections>
              <p class="zzSTDTitle1" align="center" displayorder="3">RESOLUTION  (Peoria, 1871)</p>
              <p align="center" class="zzSTDTitle2" displayorder="4">
                 <em>(Peoria, 1871</em>
                 )
              </p>
              <p keep-with-next="true" class="supertitle" displayorder="5">
                 <span element="fmt-element-name">SECTION</span>
                 <semx element="autonum" source="D">1</semx>
              </p>
              <clause id="D" obligation="normative" type="scope" displayorder="6">
                 <title id="_">Scope</title>
                 <fmt-title depth="1">
                    <semx element="title" source="_">Scope</semx>
                 </fmt-title>
                 <p id="E">Text</p>
              </clause>
              <p keep-with-next="true" class="supertitle" displayorder="7">
                 <span element="fmt-element-name">SECTION</span>
                 <semx element="autonum" source="M">2</semx>
              </p>
              <clause id="M" inline-header="false" obligation="normative" displayorder="8">
                 <title id="_">Clause 4</title>
                 <fmt-title depth="1">
                    <semx element="title" source="_">Clause 4</semx>
                 </fmt-title>
                 <clause id="N" inline-header="false" obligation="normative">
                    <title id="_">Introduction</title>
                    <fmt-title depth="2">
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="M">2</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="N">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                       </span>
                       <span class="fmt-caption-delim">
                          <tab/>
                       </span>
                       <semx element="title" source="_">Introduction</semx>
                    </fmt-title>
                    <fmt-xref-label>
                       <semx element="autonum" source="M">2</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="N">1</semx>
                    </fmt-xref-label>
                 </clause>
                 <clause id="O" inline-header="false" obligation="normative">
                    <title id="_">Clause 4.2</title>
                    <fmt-title depth="2">
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="M">2</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="O">2</semx>
                          <span class="fmt-autonum-delim">.</span>
                       </span>
                       <span class="fmt-caption-delim">
                          <tab/>
                       </span>
                       <semx element="title" source="_">Clause 4.2</semx>
                    </fmt-title>
                    <fmt-xref-label>
                       <semx element="autonum" source="M">2</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="O">2</semx>
                    </fmt-xref-label>
                 </clause>
              </clause>
           </sections>
           <annex id="P" inline-header="false" obligation="normative" autonum="A" displayorder="9">
              <p class="supertitle">
                 <span class="fmt-element-name">ANNEX</span>
                 <semx element="autonum" source="P">A</semx>
                 <br/>
                 (to RESOLUTION (Peoria, 1871))
              </p>
              <title id="_">
                 <strong>Annex Title</strong>
              </title>
              <fmt-title>
                 <semx element="title" source="_">
                    <strong>Annex Title</strong>
                 </semx>
              </fmt-title>
              <clause id="Q" inline-header="false" obligation="normative">
                 <title id="_">Annex A.1</title>
                 <fmt-title depth="2">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="P">A</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="Q">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">Annex A.1</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <semx element="autonum" source="P">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="Q">1</semx>
                 </fmt-xref-label>
                 <clause id="Q1" inline-header="false" obligation="normative">
                    <title id="_">Annex A.1a</title>
                    <fmt-title depth="3">
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="P">A</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="Q">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="Q1">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                       </span>
                       <span class="fmt-caption-delim">
                          <tab/>
                       </span>
                       <semx element="title" source="_">Annex A.1a</semx>
                    </fmt-title>
                    <fmt-xref-label>
                       <semx element="autonum" source="P">A</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="Q">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="Q1">1</semx>
                    </fmt-xref-label>
                 </clause>
              </clause>
           </annex>
           <bibliography>
              <clause id="S" obligation="informative" displayorder="10">
                 <title id="_">Bibliography</title>
                 <fmt-title depth="1">
                    <semx element="title" source="_">Bibliography</semx>
                 </fmt-title>
                 <references id="T" obligation="informative" normative="false">
                    <title id="_">Bibliography Subsection</title>
                    <fmt-title depth="2">
                       <semx element="title" source="_">Bibliography Subsection</semx>
                    </fmt-title>
                 </references>
              </clause>
           </bibliography>
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
                 <div>
                   <h1 class='IntroTitle'>Foreword</h1>
                   <p id='A'>
                      This is a preamble
                     <a href='#C'>Introduction Subsection</a>
                     <a href='#C1'>Introduction, 2</a>
                     <a href='#D'>Section 1</a>
                     <a href='#M'>Section 2</a>
      <a href='#N'>2.1</a>
      <a href='#O'>2.2</a>
                     <a href='#P'>Annex A</a>
                     <a href='#Q'>A.1</a>
                     <a href='#Q1'>A.1.1</a>
                     <a href='#S'>Bibliography</a>
                   </p>
                 </div>
                 <div id='B'>
                   <h1 class='IntroTitle'>Introduction</h1>
                   <div id='C'>
                     <h2>Introduction Subsection</h2>
                   </div>
                   <div id='C1'>Text</div>
                 </div>
                 <p class='zzSTDTitle1' style='text-align:center;'>RESOLUTION (Peoria, 1871)</p>
                 <p class='zzSTDTitle2' style='text-align:center;'>
                   <i>(Peoria, 1871</i>)
                 </p>
                 <p style='page-break-after: avoid;' class="supertitle">SECTION 1</p>
                 <div id='D'>
      <h1>Scope</h1>
                   <p id='E'>Text</p>
                 </div>
                 <p style='page-break-after: avoid;' class="supertitle">SECTION 2</p>
                 <div id='M'>
      <h1>Clause 4</h1>
                   <div id='N'>
                     <h2>2.1.  Introduction</h2>
                   </div>
                   <div id='O'>
                   <h2>2.2.  Clause 4.2</h2>
                   </div>
                 </div>
                 <br/>
                 <div id='P' class='Section3'>
                   <p class='supertitle'>
                     ANNEX A
                     <br/>
                      (to RESOLUTION (Peoria, 1871))
                   </p>
                   <h1 class='Annex'>
                     <b>Annex Title</b>
                   </h1>
                   <div id='Q'>
                   <h2>A.1.  Annex A.1</h2>
                     <div id='Q1'>
                     <h3>A.1.1.  Annex A.1a</h3>
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
    pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(IsoDoc::Itu::HtmlConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "cross-references list items" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword>
          <p>
          <xref target="N1"/>
          <xref target="N11"/>
          <xref target="N12"/>
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
          <ol id="N01">
        <li id="N1"><p>A</p>
          <ol id="N011">
        <li id="N11"><p>A</p>
          <ol id="N012">
        <li id="N12"><p>A</p>
         </li>
      </ol></li></ol></li></ol>
        <clause id="xyz"><title>Preparatory</title>
           <ol id="N02" type="arabic">
        <li id="N2"><p>A</p></li>
      </ol>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <ol id="N0" type="roman">
        <li id="N"><p>A</p></li>
      </ol>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <ol id="note1l" type="alphabet">
        <li id="note1"><p>A</p></li>
      </ol>
          <ol id="note2l" type="roman_upper">
        <li id="note2"><p>A</p></li>
      </ol>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <ol id="ANl" type="alphabet_upper">
        <li id="AN"><p>A</p></li>
      </ol>
          </clause>
          <clause id="annex1b">
          <ol id="Anote1l" type="roman" start="4">
        <li id="Anote1"><p>A</p></li>
      </ol>
          <ol id="Anote2l">
        <li id="Anote2"><p>A</p></li>
      </ol>
          </clause>
          </annex>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword displayorder="2">
          <title id="_">Foreword</title>
          <fmt-title depth="1">
             <semx element="title" source="_">Foreword</semx>
          </fmt-title>
          <p>
             <xref target="N1">
                <semx element="autonum" source="N1">a</semx>
                <span class="fmt-autonum-delim">)</span>
                <span class="fmt-conn">in</span>
                <span class="fmt-xref-container">
                   <semx element="introduction" source="intro">Introduction</semx>
                </span>
             </xref>
             <xref target="N11">
                <semx element="autonum" source="N1">a</semx>
                <span class="fmt-autonum-delim">)</span>
                <semx element="autonum" source="N11">1</semx>
                <span class="fmt-autonum-delim">)</span>
                <span class="fmt-conn">in</span>
                <span class="fmt-xref-container">
                   <semx element="introduction" source="intro">Introduction</semx>
                </span>
             </xref>
             <xref target="N12">
                <semx element="autonum" source="N1">a</semx>
                <span class="fmt-autonum-delim">)</span>
                <semx element="autonum" source="N11">1</semx>
                <span class="fmt-autonum-delim">)</span>
                <semx element="autonum" source="N12">i</semx>
                <span class="fmt-autonum-delim">)</span>
                <span class="fmt-conn">in</span>
                <span class="fmt-xref-container">
                   <semx element="introduction" source="intro">Introduction</semx>
                </span>
             </xref>
             <xref target="N2">
                <semx element="autonum" source="N2">1</semx>
                <span class="fmt-autonum-delim">)</span>
                <span class="fmt-conn">in</span>
                <span class="fmt-xref-container">
                   <semx element="clause" source="xyz">Preparatory</semx>
                </span>
             </xref>
             <xref target="N">
                <semx element="autonum" source="N">i</semx>
                <span class="fmt-autonum-delim">)</span>
                <span class="fmt-conn">in</span>
                <span class="fmt-xref-container">
                   <span class="fmt-element-name">clause</span>
                   <semx element="autonum" source="scope">1</semx>
                </span>
             </xref>
             <xref target="note1">
                <span class="fmt-element-name">List</span>
                <semx element="autonum" source="note1l">1</semx>
                <semx element="autonum" source="note1">a</semx>
                <span class="fmt-autonum-delim">)</span>
                <span class="fmt-conn">in</span>
                <span class="fmt-xref-container">
                   <span class="fmt-element-name">clause</span>
                   <semx element="autonum" source="widgets">3</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="widgets1">1</semx>
                </span>
             </xref>
             <xref target="note2">
                <span class="fmt-element-name">List</span>
                <semx element="autonum" source="note2l">2</semx>
                <semx element="autonum" source="note2">I</semx>
                <span class="fmt-autonum-delim">)</span>
                <span class="fmt-conn">in</span>
                <span class="fmt-xref-container">
                   <span class="fmt-element-name">clause</span>
                   <semx element="autonum" source="widgets">3</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="widgets1">1</semx>
                </span>
             </xref>
             <xref target="AN">
                <semx element="autonum" source="AN">A</semx>
                <span class="fmt-autonum-delim">)</span>
                <span class="fmt-conn">in</span>
                <span class="fmt-xref-container">
                   <span class="fmt-element-name">clause</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="annex1a">1</semx>
                </span>
             </xref>
             <xref target="Anote1">
                <span class="fmt-element-name">List</span>
                <semx element="autonum" source="Anote1l">1</semx>
                <semx element="autonum" source="Anote1">iv</semx>
                <span class="fmt-autonum-delim">)</span>
                <span class="fmt-conn">in</span>
                <span class="fmt-xref-container">
                   <span class="fmt-element-name">clause</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="annex1b">2</semx>
                </span>
             </xref>
             <xref target="Anote2">
                <span class="fmt-element-name">List</span>
                <semx element="autonum" source="Anote2l">2</semx>
                <semx element="autonum" source="Anote2">a</semx>
                <span class="fmt-autonum-delim">)</span>
                <span class="fmt-conn">in</span>
                <span class="fmt-xref-container">
                   <span class="fmt-element-name">clause</span>
                   <semx element="autonum" source="annex1">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="annex1b">2</semx>
                </span>
             </xref>
          </p>
       </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Itu::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "cross-references list items of steps class" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword>
          <p>
          <xref target="N1"/>
          <xref target="N11"/>
          <xref target="N12"/>
          </p>
          </foreword>
          <introduction id="intro">
          <ol id="N01" class="steps">
        <li id="N1"><p>A</p>
          <ol id="N011">
        <li id="N11"><p>A</p>
          <ol id="N012">
        <li id="N12"><p>A</p>
         </li>
      </ol></li></ol></li></ol>
        <clause id="xyz"><title>Preparatory</title>
           <ol id="N02" type="arabic">
        <li id="N2"><p>A</p></li>
      </ol>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope" type="scope"><title>Scope</title>
          <ol id="N0" type="roman">
        <li id="N"><p>A</p></li>
      </ol>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <ol id="note1l" type="alphabet">
        <li id="note1"><p>A</p></li>
      </ol>
          <ol id="note2l" type="roman_upper">
        <li id="note2"><p>A</p></li>
      </ol>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <ol id="ANl" type="alphabet_upper">
        <li id="AN"><p>A</p></li>
      </ol>
          </clause>
          <clause id="annex1b">
          <ol id="Anote1l" type="roman" start="4">
        <li id="Anote1"><p>A</p></li>
      </ol>
          <ol id="Anote2l">
        <li id="Anote2"><p>A</p></li>
      </ol>
          </clause>
          </annex>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title depth="1">
                 <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <xref target="N1">
                 <semx element="autonum" source="N1">1</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">in</span>
                          <span class="fmt-xref-container">
            <semx element="introduction" source="intro">Introduction</semx>
         </span>
              </xref>
              <xref target="N11">
                 <semx element="autonum" source="N1">1</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="N11">a</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">in</span>
                          <span class="fmt-xref-container">
            <semx element="introduction" source="intro">Introduction</semx>
         </span>
              </xref>
              <xref target="N12">
                 <semx element="autonum" source="N1">1</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="N11">a</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <semx element="autonum" source="N12">i</semx>
                 <span class="fmt-autonum-delim">)</span>
                 <span class="fmt-conn">in</span>
                          <span class="fmt-xref-container">
            <semx element="introduction" source="intro">Introduction</semx>
         </span>
              </xref>
           </p>
        </foreword>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(IsoDoc::Itu::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end

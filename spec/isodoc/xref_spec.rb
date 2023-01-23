require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::ITU do
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
      <foreword displayorder='1'>
        <p>
          <xref target='N1'>Note in Introduction</xref>
          <xref target='N2'>Note in Preparatory</xref>
          <xref target='N'>Note in clause 1</xref>
          <xref target='note1'>Note 1 in clause 3.1</xref>
          <xref target='note2'>Note 2 in clause 3.1</xref>
          <xref target='AN'>Note in clause A.1</xref>
          <xref target='Anote1'>Note 1 in clause A.2</xref>
          <xref target='Anote2'>Note 2 in clause A.2</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::ITU::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
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
    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
                    <preface>
                <foreword id="fwd" displayorder='1'>
                <p>
                <xref target="N">Figure 1</xref>
                <xref target="note1">Figure 1-a</xref>
                <xref target="note2">Figure 1-b</xref>
                <xref target="AN">Figure A.1</xref>
                <xref target="Anote1">Figure A.1-a</xref>
                <xref target="Anote2">Figure A.1-b</xref>
                </p>
                </foreword>
                </preface>
                <sections>
                <clause id="scope" type="scope" displayorder='2'><title depth="1">1.<tab/>Scope</title>
                </clause>
                <terms id="terms"  displayorder='3'><title>2.</title></terms>
                <clause id="widgets"  displayorder='4'><title depth="1">3.<tab/>Widgets</title>
                <clause id="widgets1"><title>3.1.</title>
                <figure id="N">
                    <figure id="note1">
              <name>Figure 1-a&#xA0;&#x2014; Split-it-right sample divider</name>
              <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
              </figure>
                <figure id="note2">
              <name>Figure 1-b&#xA0;&#x2014; Split-it-right sample divider</name>
              <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
              </figure>
              </figure>
              <p>    <xref target="note1">Figure 1-a</xref> <xref target="note2">Figure 1-b</xref> </p>
                </clause>
                </clause>
                </sections>
                <annex id="annex1"   displayorder='5'><title><strong>Annex A</strong></title>
                <clause id="annex1a"><title>A.1.</title>
                </clause>
                <clause id="annex1b"><title>A.2.</title>
                <figure id="AN">
                    <figure id="Anote1">
              <name>Figure A.1-a&#xA0;&#x2014; Split-it-right sample divider</name>
              <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
              </figure>
                <figure id="Anote2">
              <name>Figure A.1-b&#xA0;&#x2014; Split-it-right sample divider</name>
              <image src="rice_images/rice_image1.png" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png"/>
              </figure>
              </figure>
                </clause>
                </annex>
                </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR}
      <div id='fwd'>
            <h1 class='IntroTitle'/>
            <p>
              <a href='#N'>Figure 1</a>
              <a href='#note1'>Figure 1-a</a>
              <a href='#note2'>Figure 1-b</a>
              <a href='#AN'>Figure A.1</a>
              <a href='#Anote1'>Figure A.1-a</a>
              <a href='#Anote2'>Figure A.1-b</a>
            </p>
          </div>
          <p class='zzSTDTitle1'/>
          <p class='zzSTDTitle2'/>
          <div id='scope'>
            <h1>1.&#160; Scope</h1>
          </div>
          <div id='terms'>
            <h1>2.</h1>
          </div>
          <div id='widgets'>
            <h1>3.&#160; Widgets</h1>
            <div id='widgets1'>
              <h2>3.1.</h2>
              <div id='N' class='figure'>
                <div id='note1' class='figure'>
                  <img src='rice_images/rice_image1.png' height='auto' width='auto'/>
                  <p class='FigureTitle' style='text-align:center;'>Figure 1-a&#160;&#8212; Split-it-right sample divider</p>
                </div>
                <div id='note2' class='figure'>
                  <img src='rice_images/rice_image1.png' height='auto' width='auto'/>
                  <p class='FigureTitle' style='text-align:center;'>Figure 1-b&#160;&#8212; Split-it-right sample divider</p>
                </div>
              </div>
              <p>
                <a href='#note1'>Figure 1-a</a>
                <a href='#note2'>Figure 1-b</a>
              </p>
            </div>
          </div>
          <br/>
          <div id='annex1' class='Section3'>
            <h1 class='Annex'>
              <b>Annex A</b>
            </h1>
            <p class='annex_obligation'>(This annex forms an integral part of this .)</p>
            <div id='annex1a'>
              <h2>A.1.</h2>
            </div>
            <div id='annex1b'>
              <h2>A.2.</h2>
              <div id='AN' class='figure'>
                <div id='Anote1' class='figure'>
                  <img src='rice_images/rice_image1.png' height='auto' width='auto'/>
                  <p class='FigureTitle' style='text-align:center;'>Figure A.1-a&#160;&#8212; Split-it-right sample divider</p>
                </div>
                <div id='Anote2' class='figure'>
                  <img src='rice_images/rice_image1.png' height='auto' width='auto'/>
                  <p class='FigureTitle' style='text-align:center;'>Figure A.1-b&#160;&#8212; Split-it-right sample divider</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </body>
    OUTPUT
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({})
      .convert("test", presxml, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to xmlpp(html)
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
          <foreword displayorder='1'>
            <p>
              <xref target='N1'>Equation (Introduction-1)</xref>
      <xref target='N2'>Inequality (Introduction-2)</xref>
            </p>
          </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::ITU::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
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
        <abstract displayorder='1'><title>Abstract</title>
        <p>
        <xref target="A1"/>
      <xref target="A2"/>
      </p>
        </abstract>
                 <sections displayorder='2'>
                 </sections>
          <annex id="A1" obligation="normative" displayorder='4'>
                  <title>Annex</title>
                  <clause id="A2"><title>Subtitle</title>
                  </clause>
          </annex>
    INPUT
    output = <<~OUTPUT
      <itu-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
                <bibdata type='standard'>
                  <title language='en' format='text/plain' type='main'>An ITU Standard</title>
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
                  <abstract displayorder='1'>
                    <title>Abstract</title>
                    <p>
                      <xref target='A1'>Annex F2</xref>
                      <xref target='A2'>clause F2.1</xref>
                    </p>
                  </abstract>
                  <sections displayorder='2'> </sections>
                  <annex id='A1' obligation='normative' displayorder='4'>
                    <title>
                      <strong>Annex F2</strong>
                      <br/>
                      <br/>
                      <strong>Annex</strong>
                    </title>
                    <clause id='A2'>
                      <title depth='2'>
                        F2.1.
                        <tab/>
                        Subtitle
                      </title>
                    </clause>
                  </annex>
                </preface>
              </itu-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(output)
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
      <foreword id='fwd' displayorder='1'>
        <p>
          <xref target='N'>Figure 3.1</xref>
          <xref target='note1'>Figure 3.1-a</xref>
          <xref target='note2'>Figure 3.1-b</xref>
          <xref target='AN'>Figure A.1</xref>
          <xref target='Anote1'>Figure A.1-a</xref>
          <xref target='Anote2'>Figure A.1-b</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::ITU::PresentationXMLConvert
      .new({ hierarchicalassets: true })
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
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
      <foreword id='fwd' displayorder='1'>
        <p>
          <xref target='note1'>Equation (3-1)</xref>
          <xref target='note2'>Equation (3-2)</xref>
          <xref target='AN'>[AN]</xref>
          <xref target='Anote1'>Equation (A-1)</xref>
          <xref target='Anote2'>Equation (A-2)</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::ITU::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
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
      <foreword obligation='informative' displayorder='1'>
        <title>Foreword</title>
        <p id='A'>
          This is a preamble
          <xref target='C'>Introduction Subsection</xref>
          <xref target='C1'>Introduction, 2</xref>
          <xref target='D'>clause 1</xref>
          <xref target='H'>clause 3</xref>
          <xref target='I'>clause 3.1</xref>
          <xref target='J'>clause 3.1.1</xref>
          <xref target='K'>clause 3.2</xref>
          <xref target='L'>clause 4</xref>
          <xref target='M'>clause 5</xref>
          <xref target='N'>clause 5.1</xref>
          <xref target='O'>clause 5.2</xref>
          <xref target='P'>Annex A</xref>
          <xref target='Q'>clause A.1</xref>
          <xref target='Q1'>clause A.1.1</xref>
          <xref target='R'>clause 2</xref>
          <xref target='S'>Bibliography</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::ITU::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
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
          <itu-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
               <bibdata>
                <title>X</title>
       <title language='en' format='text/plain' type='resolution'>RESOLUTION (Peoria, 1871)</title>
            <title language='en' format='text/plain' type='resolution-placedate'>Peoria, 1871</title>
                 <ext>
                   <doctype language=''>resolution</doctype>
                   <doctype language='en'>Resolution</doctype>
            <meeting-place>Peoria</meeting-place>
      <meeting-date>
        <on>1871-02-09</on>
      </meeting-date>
                 </ext>
               </bibdata>
               <preface>
                 <foreword obligation='informative' displayorder='1'>
                   <title>Foreword</title>
                   <p id='A'>
                     This is a preamble
                     <xref target='C'>Introduction Subsection</xref>
                     <xref target='C1'>Introduction, 2</xref>
                     <xref target='D'>Section 1</xref>
                     <xref target='M'>Section 2</xref>
                     <xref target='N'>2.1</xref>
                     <xref target='O'>2.2</xref>
                     <xref target='P'>Annex A</xref>
                     <xref target='Q'>A.1</xref>
                     <xref target='Q1'>A.1.1</xref>
                     <xref target='S'>Bibliography</xref>
                   </p>
                 </foreword>
                 <introduction id='B' obligation='informative' displayorder='2'>
                   <title>Introduction</title>
                   <clause id='C' inline-header='false' obligation='informative'>
                     <title depth='2'>Introduction Subsection</title>
                   </clause>
                   <clause id='C1' inline-header='false' obligation='informative'>Text</clause>
                 </introduction>
               </preface>
               <sections>
                 <clause id='D' obligation='normative' type='scope'  displayorder='3'>
                   <p keep-with-next='true' class='supertitle'>SECTION 1</p>
      <title depth='1'>Scope</title>
                   <p id='E'>Text</p>
                 </clause>
                 <clause id='M' inline-header='false' obligation='normative'  displayorder='4'>
                   <p keep-with-next='true' class='supertitle'>SECTION 2</p>
      <title depth='1'>Clause 4</title>
                   <clause id='N' inline-header='false' obligation='normative'>
                     <title depth='2'>
                       2.1.
                       <tab/>
                       Introduction
                     </title>
                   </clause>
                   <clause id='O' inline-header='false' obligation='normative'>
                     <title depth='2'>
                       2.2.
                       <tab/>
                       Clause 4.2
                     </title>
                   </clause>
                 </clause>
               </sections>
               <annex id='P' inline-header='false' obligation='normative' displayorder='5'>
               <p class='supertitle'>ANNEX A
        <br/>
        (to RESOLUTION (Peoria, 1871))
      </p>
                 <title>
                   <strong>Annex Title</strong>
                 </title>
                 <clause id='Q' inline-header='false' obligation='normative'>
                   <title depth='2'>
                     A.1.
                     <tab/>
                     Annex A.1
                   </title>
                   <clause id='Q1' inline-header='false' obligation='normative'>
                     <title depth='3'>
                       A.1.1.
                       <tab/>
                       Annex A.1a
                     </title>
                   </clause>
                 </clause>
               </annex>
               <bibliography>
                 <clause id='S' obligation='informative' displayorder='6'>
                   <title depth='1'>Bibliography</title>
                   <references id='T' obligation='informative' normative='false'>
                     <title depth='2'>Bibliography Subsection</title>
                   </references>
                 </clause>
               </bibliography>
             </itu-standard>
    OUTPUT
    html = <<~OUTPUT
               #{HTML_HDR}
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
                 <p align='center' style='text-align:center;'>RESOLUTION (Peoria, 1871)</p>
                 <p class='zzSTDTitle2'/>
                 <p align='center' style='text-align:center;'>
                   <i>(Peoria, 1871)</i>
                 </p>
                 <div id='D'>
                 <p style='page-break-after: avoid;' class="supertitle">SECTION 1</p>
      <h1>Scope</h1>
                   <p id='E'>Text</p>
                 </div>
                 <div id='M'>
                 <p style='page-break-after: avoid;' class="supertitle">SECTION 2</p>
      <h1>Clause 4</h1>
                   <div id='N'>
                     <h2> 2.1. &#160; Introduction </h2>
                   </div>
                   <div id='O'>
                     <h2> 2.2. &#160; Clause 4.2 </h2>
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
                     <h2> A.1. &#160; Annex A.1 </h2>
                     <div id='Q1'>
                       <h3> A.1.1. &#160; Annex A.1a </h3>
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
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({})
      .convert("test", presxml, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to xmlpp(html)
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
      <foreword displayorder='1'>
        <p>
          <xref target='N1'>a) in Introduction</xref>
          <xref target='N11'>a) 1) in Introduction</xref>
          <xref target='N12'>a) 1) i) in Introduction</xref>
          <xref target='N2'>1) in Preparatory</xref>
          <xref target='N'>i) in clause 1</xref>
          <xref target='note1'>List 1 a) in clause 3.1</xref>
          <xref target='note2'>List 2 I) in clause 3.1</xref>
          <xref target='AN'>A) in clause A.1</xref>
          <xref target='Anote1'>List 1 iv) in clause A.2</xref>
          <xref target='Anote2'>List 2 a) in clause A.2</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::ITU::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
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
      <foreword displayorder='1'>
        <p>
        <xref target='N1'>1) in Introduction</xref>
        <xref target='N11'>1) a) in Introduction</xref>
        <xref target='N12'>1) a) i) in Introduction</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(Nokogiri::XML(IsoDoc::ITU::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:foreword").to_xml))
      .to be_equivalent_to xmlpp(output)
  end
end

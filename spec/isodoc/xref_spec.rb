require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::ITU do
it "cross-references notes" do
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
          <preface>
            <foreword>
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
            <introduction id='intro'>
              <note id='N1'>
                <name>NOTE</name>
                <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83e'>
                  These results are based on a study carried out on three different
                  types of kernel.
                </p>
              </note>
              <clause id='xyz'>
                <title depth='2'>Preparatory</title>
                <note id='N2'>
                  <name>NOTE</name>
                  <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83d'>
                    These results are based on a study carried out on three different
                    types of kernel.
                  </p>
                </note>
              </clause>
            </introduction>
          </preface>
          <sections>
            <clause id='scope' type='scope'>
              <title depth='1'>
                1.
                <tab/>
                Scope
              </title>
              <note id='N'>
                <name>NOTE</name>
                <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
                  These results are based on a study carried out on three different
                  types of kernel.
                </p>
              </note>
              <p>
                <xref target='N'>Note</xref>
              </p>
            </clause>
            <terms id='terms'>
              <title>2.</title>
            </terms>
            <clause id='widgets'>
              <title depth='1'>
                3.
                <tab/>
                Widgets
              </title>
              <clause id='widgets1'>
                <title>3.1.</title>
                <note id='note1'>
                  <name>NOTE 1</name>
                  <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
                    These results are based on a study carried out on three different
                    types of kernel.
                  </p>
                </note>
                <note id='note2'>
                  <name>NOTE 2</name>
                  <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a'>
                    These results are based on a study carried out on three different
                    types of kernel.
                  </p>
                </note>
                <p>
                  <xref target='note1'>Note 1</xref>
                  <xref target='note2'>Note 2</xref>
                </p>
              </clause>
            </clause>
          </sections>
          <annex id='annex1'>
            <title>
              <strong>Annex A</strong>
            </title>
            <clause id='annex1a'>
              <title>A.1.</title>
              <note id='AN'>
                <name>NOTE</name>
                <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
                  These results are based on a study carried out on three different
                  types of kernel.
                </p>
              </note>
            </clause>
            <clause id='annex1b'>
              <title>A.2.</title>
              <note id='Anote1'>
                <name>NOTE 1</name>
                <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
                  These results are based on a study carried out on three different
                  types of kernel.
                </p>
              </note>
              <note id='Anote2'>
                <name>NOTE 2</name>
                <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a'>
                  These results are based on a study carried out on three different
                  types of kernel.
                </p>
              </note>
            </clause>
          </annex>
        </iso-standard>
OUTPUT
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
          <foreword id="fwd">
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
          <clause id="scope" type="scope"><title depth="1">1.<tab/>Scope</title>
          </clause>
          <terms id="terms"><title>2.</title></terms>
          <clause id="widgets"><title depth="1">3.<tab/>Widgets</title>
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
          <annex id="annex1"><title><strong>Annex A</strong></title>
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
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({}).convert("test", input, true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", presxml, true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(html)
      end

             it "cross-references formulae" do
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
<?xml version='1.0'?>
<itu-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
  <preface>
    <foreword>
      <p>
        <xref target='N1'>Equation (Introduction-1)</xref>
<xref target='N2'>Inequality (Introduction-2)</xref>
      </p>
    </foreword>
    <introduction id='intro'>
      <formula id='N1'>
        <name>Introduction-1</name>
        <stem type='AsciiMath'>r = 1 %</stem>
      </formula>
      <clause id='xyz'>
        <title depth="2">Preparatory</title>
        <formula id='N2' inequality='true'>
          <name>Introduction-2</name>
          <stem type='AsciiMath'>r = 1 %</stem>
        </formula>
      </clause>
    </introduction>
  </preface>
</itu-standard>
    OUTPUT
       end

              it "cross-references annex subclauses" do
                expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{<localized-strings>.*</localized-strings>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
            <abstract>
              <title>Abstract</title>
              <p>
                <xref target='A1'>Annex F2</xref>
                <xref target='A2'>clause F2.1</xref>
              </p>
            </abstract>
            <sections> </sections>
            <annex id='A1' obligation='normative'>
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
       end

              it "processes figures as hierarchical assets (Presentation XML)" do
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({hierarchical_assets: true}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
          <preface>
            <foreword id='fwd'>
              <p>
                <xref target='N'>Figure 3.1</xref>
                <xref target='note1'>Figure 3.1-a</xref>
                <xref target='note2'>Figure 3.1-b</xref>
                <xref target='AN'>Figure A.1</xref>
                <xref target='Anote1'>Figure A.1-a</xref>
                <xref target='Anote2'>Figure A.1-b</xref>
              </p>
            </foreword>
          </preface>
          <sections>
            <clause id='scope' type='scope'>
              <title depth='1'>
                1.
                <tab/>
                Scope
              </title>
            </clause>
            <terms id='terms'>
              <title>2.</title>
            </terms>
            <clause id='widgets'>
              <title depth='1'>
                3.
                <tab/>
                Widgets
              </title>
              <clause id='widgets1'>
                <title>3.1.</title>
                <figure id='N'>
                  <figure id='note1'>
                    <name>Figure 3.1-a&#xA0;&#x2014; Split-it-right sample divider</name>
                    <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
                  </figure>
                  <figure id='note2'>
                    <name>Figure 3.1-b&#xA0;&#x2014; Split-it-right sample divider</name>
                    <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
                  </figure>
                </figure>
                <p>
                  <xref target='note1'>Figure 3.1-a</xref>
                  <xref target='note2'>Figure 3.1-b</xref>
                </p>
              </clause>
            </clause>
          </sections>
          <annex id='annex1'>
            <title>
              <strong>Annex A</strong>
            </title>
            <clause id='annex1a'>
              <title>A.1.</title>
            </clause>
            <clause id='annex1b'>
              <title>A.2.</title>
              <figure id='AN'>
                <figure id='Anote1'>
                  <name>Figure A.1-a&#xA0;&#x2014; Split-it-right sample divider</name>
                  <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
                </figure>
                <figure id='Anote2'>
                  <name>Figure A.1-b&#xA0;&#x2014; Split-it-right sample divider</name>
                  <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
                </figure>
              </figure>
            </clause>
          </annex>
        </iso-standard>
    OUTPUT
end

it "processes formulae as non-hierarchical assets" do
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
 <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
          <preface>
            <foreword id='fwd'>
              <p>
                <xref target='note1'>Equation (3-1)</xref>
                <xref target='note2'>Equation (3-2)</xref>
                <xref target='AN'>[AN]</xref>
                <xref target='Anote1'>Equation (A-1)</xref>
                <xref target='Anote2'>Equation (A-2)</xref>
              </p>
            </foreword>
          </preface>
          <sections>
            <clause id='scope' type='scope'>
              <title depth='1'>
                1.
                <tab/>
                Scope
              </title>
            </clause>
            <terms id='terms'>
              <title>2.</title>
            </terms>
            <clause id='widgets'>
              <title depth='1'>
                3.
                <tab/>
                Widgets
              </title>
              <clause id='widgets1'>
                <title>3.1.</title>
                <formula id='note1'>
                  <name>3-1</name>
                  <stem type='AsciiMath'>r = 1 %</stem>
                </formula>
                <formula id='note2'>
                  <name>3-2</name>
                  <stem type='AsciiMath'>r = 1 %</stem>
                </formula>
                <p>
                  <xref target='note1'>Equation (3-1)</xref>
                  <xref target='note2'>Equation (3-2)</xref>
                </p>
              </clause>
            </clause>
          </sections>
          <annex id='annex1'>
            <title>
              <strong>Annex A</strong>
            </title>
            <clause id='annex1a'>
              <title>A.1.</title>
            </clause>
            <clause id='annex1b'>
              <title>A.2.</title>
              <formula id='Anote1'>
                <name>A-1</name>
                <stem type='AsciiMath'>r = 1 %</stem>
              </formula>
              <formula id='Anote2'>
                <name>A-2</name>
                <stem type='AsciiMath'>r = 1 %</stem>
              </formula>
            </clause>
          </annex>
        </iso-standard>
    OUTPUT
end


end

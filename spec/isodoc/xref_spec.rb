require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::ITU do
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
           <a href="#N">Note in clause 1</a>
           <a href="#note1">Note  1 in clause 3.1</a>
           <a href="#note2">Note  2 in clause 3.1</a>
           <a href="#AN">Note in clause A.1</a>
           <a href="#Anote1">Note  1 in clause A.2</a>
           <a href="#Anote2">Note  2 in clause A.2</a>
           </p>
             </div>
             <div id="intro">
               <h1 class="IntroTitle"/>
               <div id="N1" class="Note">
                 <p><span class="note_label">NOTE &#8211; </span>These results are based on a study carried out on three different types of kernel.</p>
               </div>
               <div id="xyz"><h2>Preparatory</h2>
           <div id="N2" class="Note"><p><span class="note_label">NOTE &#8211; </span>These results are based on a study carried out on three different types of kernel.</p></div>
       </div>
             </div>
             <p class="zzSTDTitle1"/>
             <p class="zzSTDTitle2"/>
             <div id="scope">
               <h1>1&#160; Scope</h1>
               <div id="N" class="Note">
                 <p><span class="note_label">NOTE &#8211; </span>These results are based on a study carried out on three different types of kernel.</p>
               </div>
               <p>
                 <a href="#N">Note</a>
               </p>
             </div>
             <div id="terms">
               <h1>2&#160; </h1>
               <p>None.</p>
             </div>
             <div id="widgets">
               <h1>3&#160; Widgets</h1>
               <div id="widgets1"><h2>3.1&#160; </h2>
           <div id="note1" class="Note"><p><span class="note_label">NOTE  1 &#8211; </span>These results are based on a study carried out on three different types of kernel.</p></div>
           <div id="note2" class="Note"><p><span class="note_label">NOTE  2 &#8211; </span>These results are based on a study carried out on three different types of kernel.</p></div>
       <p>    <a href="#note1">Note  1</a> <a href="#note2">Note  2</a> </p>

           </div>
             </div>
             <br/>
             <div id="annex1" class="Section3">
              <h1 class='Annex'>
   <b>Annex A</b>
   <br/>
   <br/>
   <b/>
 </h1>
 <p class='annex_obligation'>(This annex forms an integral part of this .)</p>

               <div id="annex1a"><h2>A.1&#160; </h2>
           <div id="AN" class="Note"><p><span class="note_label">NOTE &#8211; </span>These results are based on a study carried out on three different types of kernel.</p></div>
           </div>
               <div id="annex1b"><h2>A.2&#160; </h2>
           <div id="Anote1" class="Note"><p><span class="note_label">NOTE  1 &#8211; </span>These results are based on a study carried out on three different types of kernel.</p></div>
           <div id="Anote2" class="Note"><p><span class="note_label">NOTE  2 &#8211; </span>These results are based on a study carried out on three different types of kernel.</p></div>
           </div>
             </div>
           </div>
         </body>

OUTPUT
end

      it "cross-references subfigures (Presentation XML)" do
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    <?xml version='1.0'?>
<iso-standard xmlns='http://riboseinc.com/isoxml'>
  <preface>
    <foreword id='fwd'>
      <p>
        <xref target='N'/>
        <xref target='note1'/>
        <xref target='note2'/>
        <xref target='AN'/>
        <xref target='Anote1'/>
        <xref target='Anote2'/>
      </p>
    </foreword>
  </preface>
  <sections>
    <clause id='scope'>
      <title>Scope</title>
    </clause>
    <terms id='terms'/>
    <clause id='widgets'>
      <title>Widgets</title>
      <clause id='widgets1'>
        <figure id='N'>
          <figure id='note1'>
            <name>Figure 1-a&#xA0;&#x2014; Split-it-right sample divider</name>
            <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
          </figure>
          <figure id='note2'>
            <name>Figure 1-b&#xA0;&#x2014; Split-it-right sample divider</name>
            <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
          </figure>
        </figure>
        <p>
          <xref target='note1'/>
          <xref target='note2'/>
        </p>
      </clause>
    </clause>
  </sections>
  <annex id='annex1'>
    <clause id='annex1a'> </clause>
    <clause id='annex1b'>
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

      it "cross-references subfigures (HTML)" do
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <?xml version='1.0'?>
<iso-standard xmlns='http://riboseinc.com/isoxml'>
  <preface>
    <foreword id='fwd'>
      <p>
        <xref target='N'/>
        <xref target='note1'/>
        <xref target='note2'/>
        <xref target='AN'/>
        <xref target='Anote1'/>
        <xref target='Anote2'/>
      </p>
    </foreword>
  </preface>
  <sections>
    <clause id='scope'>
      <title>Scope</title>
    </clause>
    <terms id='terms'/>
    <clause id='widgets'>
      <title>Widgets</title>
      <clause id='widgets1'>
        <figure id='N'>
          <figure id='note1'>
            <name>Figure 1-a&#xA0;&#x2014; Split-it-right sample divider</name>
            <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
          </figure>
          <figure id='note2'>
            <name>Figure 1-b&#xA0;&#x2014; Split-it-right sample divider</name>
            <image src='rice_images/rice_image1.png' id='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' mimetype='image/png'/>
          </figure>
        </figure>
        <p>
          <xref target='note1'/>
          <xref target='note2'/>
        </p>
      </clause>
    </clause>
  </sections>
  <annex id='annex1'>
    <clause id='annex1a'> </clause>
    <clause id='annex1b'>
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
    INPUT
        #{HTML_HDR}
        <div id="fwd">
               <h1 class="IntroTitle"/>
               <p>
         <a href="#N">Figure 1</a>
         <a href="#note1">Figure 1-a</a>
         <a href="#note2">Figure 1-b</a>
         <a href="#AN">Figure A.1</a>
         <a href="#Anote1">Figure A.1-a</a>
         <a href="#Anote2">Figure A.1-b</a>
         </p>
             </div>
             <p class="zzSTDTitle1"/>
             <p class="zzSTDTitle2"/>
             <div id="scope">
               <h1>1&#160; Scope</h1>
             </div>
             <div id="terms">
               <h1>2&#160; </h1>
               <p>None.</p>
             </div>
             <div id="widgets">
               <h1>3&#160; Widgets</h1>
               <div id="widgets1"><h2>3.1&#160; </h2>
         <div id="N" class="figure">
             <div id="note1" class="figure">

       <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
       <p class="FigureTitle" style="text-align:center;">Figure 1-a&#160;&#8212; Split-it-right sample divider</p></div>
         <div id="note2" class="figure">

       <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
       <p class="FigureTitle" style="text-align:center;">Figure 1-b&#160;&#8212; Split-it-right sample divider</p></div>
       </div>
       <p>    <a href="#note1">Figure 1-a</a> <a href="#note2">Figure 1-b</a> </p>
         </div>
             </div>
             <br/>
             <div id="annex1" class="Section3">
 <h1 class='Annex'>
   <b>Annex A</b>
   <br/>
   <br/>
   <b/>
 </h1>
 <p class='annex_obligation'>(This annex forms an integral part of this .)</p>
               <div id="annex1a"><h2>A.1&#160; </h2>
         </div>
               <div id="annex1b"><h2>A.2&#160; </h2>
         <div id="AN" class="figure">
             <div id="Anote1" class="figure">

       <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
       <p class="FigureTitle" style="text-align:center;">Figure A.1-a&#160;&#8212; Split-it-right sample divider</p></div>
         <div id="Anote2" class="figure">

       <img src="rice_images/rice_image1.png" height="auto" width="auto"/>
       <p class="FigureTitle" style="text-align:center;">Figure A.1-b&#160;&#8212; Split-it-right sample divider</p></div>
       </div>
         </div>
             </div>
           </div>
         </body>
OUTPUT
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
    <!--
           <a href="#N1">Equation (Introduction-1)</a>
           <a href="#N2">Inequality (Introduction-2)</a>
           -->
<?xml version='1.0'?>
<itu-standard xmlns='http://riboseinc.com/isoxml'>
  <preface>
    <foreword>
      <p>
        <xref target='N1'/>
        <xref target='N2'/>
      </p>
    </foreword>
    <introduction id='intro'>
      <formula id='N1'>
        <name>Introduction-1</name>
        <stem type='AsciiMath'>r = 1 %</stem>
      </formula>
      <clause id='xyz'>
        <title>Preparatory</title>
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
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
            #{HTML_HDR}
             <br/>
             <div>
               <h1 class="AbstractTitle">Abstract</h1>
               <p>
         <a href="#A1">Annex F2</a>
       <a href="#A2">clause F2.1</a>
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
             <div id="A1" class="Section3">
               <h1 class="RecommendationAnnex"><b>Annex F2</b> <br/><br/><b>Annex</b></h1>
<p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
               <div id="A2"><h2>F2.1&#160; Subtitle</h2>
                   </div>
             </div>
           </div>
         </body>

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
     <?xml version='1.0'?>
 <iso-standard xmlns='http://riboseinc.com/isoxml'>
   <preface>
     <foreword id='fwd'>
       <p>
         <xref target='N'/>
         <xref target='note1'/>
         <xref target='note2'/>
         <xref target='AN'/>
         <xref target='Anote1'/>
         <xref target='Anote2'/>
       </p>
     </foreword>
   </preface>
   <sections>
     <clause id='scope'>
       <title>Scope</title>
     </clause>
     <terms id='terms'/>
     <clause id='widgets'>
       <title>Widgets</title>
       <clause id='widgets1'>
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
           <xref target='note1'/>
           <xref target='note2'/>
         </p>
       </clause>
     </clause>
   </sections>
   <annex id='annex1'>
     <clause id='annex1a'> </clause>
     <clause id='annex1b'>
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
    <clause id="scope"><title>Scope</title>
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
     <?xml version='1.0'?>
 <iso-standard xmlns='http://riboseinc.com/isoxml'>
   <preface>
     <foreword id='fwd'>
       <p>
         <xref target='note1'/>
         <xref target='note2'/>
         <xref target='AN'/>
         <xref target='Anote1'/>
         <xref target='Anote2'/>
       </p>
     </foreword>
   </preface>
   <sections>
     <clause id='scope'>
       <title>Scope</title>
     </clause>
     <terms id='terms'/>
     <clause id='widgets'>
       <title>Widgets</title>
       <clause id='widgets1'>
         <formula id='note1'>
           <name>3-1</name>
           <stem type='AsciiMath'>r = 1 %</stem>
         </formula>
         <formula id='note2'>
           <name>3-2</name>
           <stem type='AsciiMath'>r = 1 %</stem>
         </formula>
         <p>
           <xref target='note1'/>
           <xref target='note2'/>
         </p>
       </clause>
     </clause>
   </sections>
   <annex id='annex1'>
     <clause id='annex1a'> </clause>
     <clause id='annex1b'>
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

require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::ITU do
  it "processes pre" do
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
<itu-standard xmlns="https://www.calconnect.org/standards/itu">
<preface><foreword>
<pre>ABC</pre>
</foreword></preface>
</itu-standard>
    INPUT
    #{HTML_HDR}
             <div>
               <h1 class="IntroTitle"/>
               <pre>ABC</pre>
             </div>
             <p class="zzSTDTitle1"/>
             <p class="zzSTDTitle2"/>
           </div>
         </body>
    OUTPUT
  end

  it "processes formulae (Word)" do
    expect(xmlpp(IsoDoc::ITU::WordConvert.new({}).convert("test", <<~"INPUT", true).gsub(/.*<h1 class="IntroTitle"\/>/m, "<div>").sub(/<p>&#160;<\/p>.*$/m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <formula id="_be9158af-7e93-4ee2-90c5-26d31c181934" unnumbered="true">
  <stem type="AsciiMath">r = 1 %</stem>
<dl id="_e4fe94fe-1cde-49d9-b1ad-743293b7e21d">
  <dt>
    <stem type="AsciiMath">r</stem>
  </dt>
  <dd>
    <p id="_1b99995d-ff03-40f5-8f2e-ab9665a69b77">is the repeatability limit.</p>
  </dd>
</dl>
    </formula>
    </foreword></preface>
    </iso-standard>
    INPUT
    <div>
    <div id="_be9158af-7e93-4ee2-90c5-26d31c181934" class="formula"><p class="formula"><span style="mso-tab-count:1">&#160; </span><span class="stem">(#(r = 1 %)#)</span></p></div><p>where:</p><table class="formula_dl"><tr><td valign="top" align="left"><p align="left" style="margin-left:0pt;text-align:left;">
           <span class="stem">(#(r)#)</span>
         </p></td><td valign="top">
           <p id="_1b99995d-ff03-40f5-8f2e-ab9665a69b77">is the repeatability limit.</p>
         </td></tr></table>


           </div>
OUTPUT
  end

    it "processes tables (Word)" do
      expect(xmlpp(IsoDoc::ITU::WordConvert.new({}).convert("test", <<~"INPUT", true).gsub(/.*<h1 class="IntroTitle"\/>/m, "<div>").sub(/<p>&#160;<\/p>.*$/m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <table id="tableD-1" alt="tool tip" summary="long desc">
  <name>Repeatability and reproducibility of <em>husked</em> rice yield</name>
  <thead>
    <tr>
      <td rowspan="2" align="left">Description</td>
      <td colspan="4" align="center">Rice sample</td>
    </tr>
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
    </thead>
    <tbody>
    <tr>
      <th align="left">Number of laboratories retained after eliminating outliers</td>
      <td align="center">13</td>
      <td align="center">11</td>
      <td align="center">13</td>
      <td align="center">13</td>
    </tr>
    <tr>
      <td align="left">Mean value, g/100 g</td>
      <td align="center">81,2</td>
      <td align="center">82,0</td>
      <td align="center">81,8</td>
      <td align="center">77,7</td>
    </tr>
    </tbody>
    <tfoot>
    <tr>
      <td align="left">Reproducibility limit, <stem type="AsciiMath">R</stem> (= 2,83 <stem type="AsciiMath">s_R</stem>)</td>
      <td align="center">2,89</td>
      <td align="center">0,57</td>
      <td align="center">2,26</td>
      <td align="center">6,06</td>
    </tr>
  </tfoot>
  <dl>
  <dt>Drago</dt>
<dd>A type of rice</dd>
</dl>
<note><p>This is a table about rice</p></note>
</table>
    </foreword></preface>
    </iso-standard>
    INPUT
    <div>
<p class="TableTitle" style="text-align:center;">Table 1&#160;&#8212; Repeatability and reproducibility of <i>husked</i> rice yield</p>
       <div align='center' class='table_container'>
       <table id='tableD-1' class='MsoISOTable' style='mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;' title='tool tip' summary='long desc'>
                   <thead>
                     <tr>
                       <td rowspan="2" align="left" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">Description</td>
                       <td colspan="4" align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;" valign="top">Rice sample</td>
                     </tr>
                     <tr>
                       <td align="left" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">Arborio</td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">Drago<a href="#tableD-1a" class="TableFootnoteRef">a</a><aside><div id="ftntableD-1a"><span><span id="tableD-1a" class="TableFootnoteRef">a</span><span style="mso-tab-count:1">&#160; </span></span>
         <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p>
       </div></aside></td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">Balilla<a href="#tableD-1a" class="TableFootnoteRef">a</a></td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">Thaibonnet</td>
                     </tr>
                   </thead>
                   <tbody>
                     <tr>
                       <th align="left" style="font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;" valign="top">Number of laboratories retained after eliminating outliers</th>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;" valign="top">13</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;" valign="top">11</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;" valign="top">13</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;" valign="top">13</td>
                     </tr>
                     <tr>
                       <td align="left" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">Mean value, g/100 g</td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">81,2</td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">82,0</td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">81,8</td>
                       <td align="center" style="border-top:none;mso-border-top-alt:none;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">77,7</td>
                     </tr>
                   </tbody>
                   <tfoot>
                     <tr>
                       <td align="left" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">Reproducibility limit, <span class="stem">(#(R)#)</span> (= 2,83 <span class="stem">(#(s_R)#)</span>)</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">2,89</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">0,57</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">2,26</td>
                       <td align="center" style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" valign="top">6,06</td>
                     </tr>
                   </tfoot>
                   <table class="dl">
                     <tr>
                       <td valign="top" align="left">
                         <p align="left" style="margin-left:0pt;text-align:left;">Drago</p>
                       </td>
                       <td valign="top">A type of rice</td>
                     </tr>
                   </table>
                   <div id="" class="Note">
                     <p><span class="note_label">NOTE &#8211; </span>This is a table about rice</p>
                   </div>
                 </table>
               </div>
             </div>
OUTPUT
  end

    it "processes steps class of ordered lists" do
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <ol id="_ae34a226-aab4-496d-987b-1aa7b6314026" class="steps">
  <li>
    <p id="_0091a277-fb0e-424a-aea8-f0001303fe78">all information necessary for the complete identification of the sample;</p>
  </li>
  <ol>
  <li>
    <p id="_8a7b6299-db05-4ff8-9de7-ff019b9017b2">a reference to this document (i.e. ISO 17301-1);</p>
  </li>
  <ol>
  <li>
    <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">the sampling method used;</p>
  </li>
  </ol>
  </ol>
</ol>
</foreword></preface>
</iso-standard>
    INPUT
    #{HTML_HDR}
      <div>
        <h1 class="IntroTitle"/>
        <ol type="1" id="_ae34a226-aab4-496d-987b-1aa7b6314026">
  <li>
    <p id="_0091a277-fb0e-424a-aea8-f0001303fe78">all information necessary for the complete identification of the sample;</p>
  </li>
  <ol type="a">
  <li>
    <p id="_8a7b6299-db05-4ff8-9de7-ff019b9017b2">a reference to this document (i.e. ISO 17301-1);</p>
  </li>
  <ol type="i">
  <li>
    <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">the sampling method used;</p>
  </li>
  </ol>
  </ol>
</ol>
      </div>
      <p class="zzSTDTitle1"/>
      <p class="zzSTDTitle2"/>
    </div>
  </body>
    OUTPUT
  end


it "processes steps class of ordered lists (Word)" do
    expect(xmlpp(IsoDoc::ITU::WordConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <ol id="_ae34a226-aab4-496d-987b-1aa7b6314026" class="steps">
  <li>
    <p id="_0091a277-fb0e-424a-aea8-f0001303fe78">all information necessary for the complete identification of the sample;</p>
  </li>
  <ol>
  <li>
    <p id="_8a7b6299-db05-4ff8-9de7-ff019b9017b2">a reference to this document (i.e. ISO 17301-1);</p>
  </li>
  <ol>
  <li>
    <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">the sampling method used;</p>
  </li>
  </ol>
  </ol>
</ol>
</foreword></preface>
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
             <ol class='steps' id='_ae34a226-aab4-496d-987b-1aa7b6314026'>
               <li>
                 <p id='_0091a277-fb0e-424a-aea8-f0001303fe78'>all information necessary for the complete identification of the sample;</p>
               </li>
               <ol>
                 <li>
                   <p id='_8a7b6299-db05-4ff8-9de7-ff019b9017b2'>a reference to this document (i.e. ISO 17301-1);</p>
                 </li>
                 <ol>
                   <li>
                     <p id='_ea248b7f-839f-460f-a173-a58a830b2abe'>the sampling method used;</p>
                   </li>
                 </ol>
               </ol>
             </ol>
           </div>
           <p>&#160;</p>
         </div>
         <p>
           <br clear='all' class='section'/>
         </p>
         <div class='WordSection3'>
           <p class='zzSTDTitle1'/>
           <p class='zzSTDTitle2'/>
         </div>
       </body>
    OUTPUT
  end

it "post-processes steps class of ordered lists (Word)" do
  FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    IsoDoc::ITU::WordConvert.new({}).convert("test", <<~"INPUT", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <ol id="_ae34a226-aab4-496d-987b-1aa7b6314026" class="steps">
  <li>
    <p id="_0091a277-fb0e-424a-aea8-f0001303fe78">all information necessary for the complete identification of the sample;</p>
  </li>
  <ol>
  <li>
    <p id="_8a7b6299-db05-4ff8-9de7-ff019b9017b2">a reference to this document (i.e. ISO 17301-1);</p>
  </li>
  <ol>
  <li>
    <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">the sampling method used;</p>
  </li>
  </ol>
  </ol>
</ol>
</foreword></preface>
</iso-standard>
    INPUT
    expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc").sub(/^.*<div>\s*<p class="h1Preface">/m, '<div><p class="h1Preface">').sub(%r{</div>.*$}m, "</div>")
    expect(xmlpp(html)).to be_equivalent_to xmlpp(<<~"OUTPUT")
           <div>
         <p class='h1Preface'/>
         <p style='mso-list:l4 level1 lfo1;' class='MsoListParagraphCxSpFirst'> all information necessary for the complete identification of the sample; </p>
         <p style='mso-list:l4 level1 lfo2;' class='MsoListParagraphCxSpFirst'> a reference to this document (i.e. ISO 17301-1); </p>
         <p style='mso-list:l4 level1 lfo3;;mso-list:l4 level1 lfo4;' class='MsoListParagraphCxSpFirst'> the sampling method used; </p>
       </div>
    OUTPUT
end

it "processes unlabelled notes" do
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <note>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </foreword></preface>
    </iso-standard>
    INPUT
    #{HTML_HDR}
               <div>
               <h1 class='IntroTitle'/>
                 <div id="" class="Note">
                   <p><span class="note_label">NOTE &#8211; </span>These results are based on a study carried out on three different types of kernel.</p>
                 </div>
               </div>
               <p class="zzSTDTitle1"/>
               <p class='zzSTDTitle2'/>
             </div>
           </body>
    OUTPUT
  end

it "processes unlabelled notes (Word)" do
    expect(xmlpp(IsoDoc::ITU::WordConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <note>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </foreword></preface>
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
             <div id='' class='Note'>
               <p>
                 <span class='note_label'>NOTE &#8211; </span>
                 These results are based on a study carried out on three different
                 types of kernel.
               </p>
             </div>
           </div>
           <p>&#160;</p>
         </div>
         <p>
           <br clear='all' class='section'/>
         </p>
         <div class='WordSection3'>
           <p class='zzSTDTitle1'/>
           <p class='zzSTDTitle2'/>
         </div>
       </body>
    OUTPUT
  end

 it "processes sequences of notes" do
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <note id="note1">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    <note id="note2">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83b">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </foreword></preface>
    </iso-standard>
INPUT
    #{HTML_HDR}
    <div>
             <h1 class='IntroTitle'/>
             <div id='note1' class='Note'>
               <p>
                 <span class='note_label'>NOTE 1 &#8211; </span>
                 These results are based on a study carried out on three
                 different types of kernel.
               </p>
             </div>
             <div id='note2' class='Note'>
               <p>
                 <span class='note_label'>NOTE 2 &#8211; </span>
                 These results are based on a study carried out on three
                 different types of kernel.
               </p>
               <p id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83b'>
                 These results are based on a study carried out on three different
                 types of kernel.
               </p>
             </div>
           </div>
           <p class='zzSTDTitle1'/>
           <p class='zzSTDTitle2'/>
         </div>
       </body>
    OUTPUT
  end

  it "processes sequences of notes (Word)" do
    expect(xmlpp(IsoDoc::ITU::WordConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <note id="note1">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    <note id="note2">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83b">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </foreword></preface>
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
             <div id='note1' class='Note'>
               <p>
                 <span class='note_label'>NOTE 1 &#8211; </span>
                 These results are based on a study carried out on three different
                 types of kernel.
               </p>
             </div>
             <div id='note2' class='Note'>
               <p>
                 <span class='note_label'>NOTE 2 &#8211; </span>
                 These results are based on a study carried out on three different
                 types of kernel.
               </p>
               <p class='Note' id='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83b'>
                 These results are based on a study carried out on three different
                 types of kernel.
               </p>
             </div>
           </div>
           <p>&#160;</p>
         </div>
         <p>
           <br clear='all' class='section'/>
         </p>
         <div class='WordSection3'>
           <p class='zzSTDTitle1'/>
           <p class='zzSTDTitle2'/>
         </div>
       </body>
    OUTPUT
  end


  end

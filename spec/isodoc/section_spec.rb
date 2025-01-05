require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Itu do
  it "processes history and source clauses (Word)" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <clause type="history" id="H" displayorder="1"><fmt-title>History</fmt-title></clause>
      <clause type="source" id="I" displayorder="2"><fmt-title>Source</fmt-title></clause>
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
    expect(Xml::C14n.format(IsoDoc::Itu::WordConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<div class="WordSection2">}m, '<div class="WordSection2">')
      .gsub(%r{<p>\s*<br clear="all" class="section"/>\s*</p>\s*<div class="WordSection3">.*}m, "")))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes annexes and appendixes" do
    input = <<~INPUT
             <itu-standard xmlns="http://riboseinc.com/isoxml">
             <bibdata type="standard">
             <title language="en" format="text/plain" type="main">An ITU Standard</title>
             <docidentifier type="ITU">12345</docidentifier>
             <language>en</language>
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
              <ext>
                 <doctype language="">recommendation</doctype>
                 <doctype language="en">Recommendation</doctype>
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
                 <xref target="A1">
                    <span class="fmt-element-name">Annex</span>
                    <semx element="autonum" source="A1">A</semx>
                 </xref>
                 <xref target="B1">
                    <span class="fmt-element-name">Appendix</span>
                    <semx element="autonum" source="B1">I</semx>
                 </xref>
              </abstract>
           </preface>
           <annex id="A1" obligation="normative" autonum="A" displayorder="3">
              <title id="_">
                 <strong>Annex</strong>
              </title>
              <fmt-title>
                 <strong>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Annex</span>
                       <semx element="autonum" source="A1">A</semx>
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
                 <semx element="autonum" source="A1">A</semx>
              </fmt-xref-label>
              <p class="annex_obligation">
                 <span class="fmt-obligation">(This annex forms an integral part of this Recommendation.)</span>
              </p>
           </annex>
           <annex id="A2" obligation="normative" autonum="B" displayorder="4">
              <title id="_">
                 <strong>Annex</strong>
              </title>
              <fmt-title>
                 <strong>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Annex</span>
                       <semx element="autonum" source="A2">B</semx>
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
                 <semx element="autonum" source="A2">B</semx>
              </fmt-xref-label>
              <p class="annex_obligation">
                 <span class="fmt-obligation">(This annex forms an integral part of this Recommendation.)</span>
              </p>
           </annex>
           <annex id="A3" obligation="normative" autonum="C" displayorder="5">
              <title id="_">
                 <strong>Annex</strong>
              </title>
              <fmt-title>
                 <strong>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Annex</span>
                       <semx element="autonum" source="A3">C</semx>
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
                 <semx element="autonum" source="A3">C</semx>
              </fmt-xref-label>
              <p class="annex_obligation">
                 <span class="fmt-obligation">(This annex forms an integral part of this Recommendation.)</span>
              </p>
           </annex>
           <annex id="A4" obligation="normative" autonum="D" displayorder="6">
              <title id="_">
                 <strong>Annex</strong>
              </title>
              <fmt-title>
                 <strong>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Annex</span>
                       <semx element="autonum" source="A4">D</semx>
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
                 <semx element="autonum" source="A4">D</semx>
              </fmt-xref-label>
              <p class="annex_obligation">
                 <span class="fmt-obligation">(This annex forms an integral part of this Recommendation.)</span>
              </p>
           </annex>
           <annex id="A5" obligation="normative" autonum="E" displayorder="7">
              <title id="_">
                 <strong>Annex</strong>
              </title>
              <fmt-title>
                 <strong>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Annex</span>
                       <semx element="autonum" source="A5">E</semx>
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
                 <semx element="autonum" source="A5">E</semx>
              </fmt-xref-label>
              <p class="annex_obligation">
                 <span class="fmt-obligation">(This annex forms an integral part of this Recommendation.)</span>
              </p>
           </annex>
           <annex id="A6" obligation="normative" autonum="F" displayorder="8">
              <title id="_">
                 <strong>Annex</strong>
              </title>
              <fmt-title>
                 <strong>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Annex</span>
                       <semx element="autonum" source="A6">F</semx>
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
                 <semx element="autonum" source="A6">F</semx>
              </fmt-xref-label>
              <p class="annex_obligation">
                 <span class="fmt-obligation">(This annex forms an integral part of this Recommendation.)</span>
              </p>
           </annex>
           <annex id="A7" obligation="normative" autonum="G" displayorder="9">
              <title id="_">
                 <strong>Annex</strong>
              </title>
              <fmt-title>
                 <strong>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Annex</span>
                       <semx element="autonum" source="A7">G</semx>
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
                 <semx element="autonum" source="A7">G</semx>
              </fmt-xref-label>
              <p class="annex_obligation">
                 <span class="fmt-obligation">(This annex forms an integral part of this Recommendation.)</span>
              </p>
           </annex>
           <annex id="A8" obligation="normative" autonum="H" displayorder="10">
              <title id="_">
                 <strong>Annex</strong>
              </title>
              <fmt-title>
                 <strong>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Annex</span>
                       <semx element="autonum" source="A8">H</semx>
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
                 <semx element="autonum" source="A8">H</semx>
              </fmt-xref-label>
              <p class="annex_obligation">
                 <span class="fmt-obligation">(This annex forms an integral part of this Recommendation.)</span>
              </p>
           </annex>
           <annex id="A9" obligation="normative" autonum="J" displayorder="11">
              <title id="_">
                 <strong>Annex</strong>
              </title>
              <fmt-title>
                 <strong>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Annex</span>
                       <semx element="autonum" source="A9">J</semx>
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
                 <semx element="autonum" source="A9">J</semx>
              </fmt-xref-label>
              <p class="annex_obligation">
                 <span class="fmt-obligation">(This annex forms an integral part of this Recommendation.)</span>
              </p>
           </annex>
           <annex id="A10" obligation="normative" autonum="K" displayorder="12">
              <title id="_">
                 <strong>Annex</strong>
              </title>
              <fmt-title>
                 <strong>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Annex</span>
                       <semx element="autonum" source="A10">K</semx>
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
                 <semx element="autonum" source="A10">K</semx>
              </fmt-xref-label>
              <p class="annex_obligation">
                 <span class="fmt-obligation">(This annex forms an integral part of this Recommendation.)</span>
              </p>
           </annex>
           <annex id="B1" obligation="informative" autonum="I" displayorder="13">
              <title id="_">
                 <strong>Annex</strong>
              </title>
              <fmt-title>
                 <strong>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Appendix</span>
                       <semx element="autonum" source="B1">I</semx>
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
                 <span class="fmt-element-name">Appendix</span>
                 <semx element="autonum" source="B1">I</semx>
              </fmt-xref-label>
              <p class="annex_obligation">
                 <span class="fmt-obligation">(This appendix does not form an integral part of this Recommendation.)</span>
              </p>
           </annex>
           <annex id="B2" obligation="informative" autonum="II" displayorder="14">
              <title id="_">
                 <strong>Annex</strong>
              </title>
              <fmt-title>
                 <strong>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Appendix</span>
                       <semx element="autonum" source="B2">II</semx>
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
                 <span class="fmt-element-name">Appendix</span>
                 <semx element="autonum" source="B2">II</semx>
              </fmt-xref-label>
              <p class="annex_obligation">
                 <span class="fmt-obligation">(This appendix does not form an integral part of this Recommendation.)</span>
              </p>
           </annex>
           <annex id="B3" obligation="informative" autonum="III" displayorder="15">
              <title id="_">
                 <strong>Annex</strong>
              </title>
              <fmt-title>
                 <strong>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Appendix</span>
                       <semx element="autonum" source="B3">III</semx>
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
                 <span class="fmt-element-name">Appendix</span>
                 <semx element="autonum" source="B3">III</semx>
              </fmt-xref-label>
              <p class="annex_obligation">
                 <span class="fmt-obligation">(This appendix does not form an integral part of this Recommendation.)</span>
              </p>
           </annex>
           <annex id="B4" obligation="informative" autonum="IV" displayorder="16">
              <title id="_">
                 <strong>Annex</strong>
              </title>
              <fmt-title>
                 <strong>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Appendix</span>
                       <semx element="autonum" source="B4">IV</semx>
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
                 <span class="fmt-element-name">Appendix</span>
                 <semx element="autonum" source="B4">IV</semx>
              </fmt-xref-label>
              <p class="annex_obligation">
                 <span class="fmt-obligation">(This appendix does not form an integral part of this Recommendation.)</span>
              </p>
           </annex>
           <annex id="B5" obligation="informative" autonum="V" displayorder="17">
              <title id="_">
                 <strong>Annex</strong>
              </title>
              <fmt-title>
                 <strong>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Appendix</span>
                       <semx element="autonum" source="B5">V</semx>
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
                 <span class="fmt-element-name">Appendix</span>
                 <semx element="autonum" source="B5">V</semx>
              </fmt-xref-label>
              <p class="annex_obligation">
                 <span class="fmt-obligation">(This appendix does not form an integral part of this Recommendation.)</span>
              </p>
           </annex>
           <annex id="B6" obligation="informative" autonum="VI" displayorder="18">
              <title id="_">
                 <strong>Annex</strong>
              </title>
              <fmt-title>
                 <strong>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Appendix</span>
                       <semx element="autonum" source="B6">VI</semx>
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
                 <span class="fmt-element-name">Appendix</span>
                 <semx element="autonum" source="B6">VI</semx>
              </fmt-xref-label>
              <p class="annex_obligation">
                 <span class="fmt-obligation">(This appendix does not form an integral part of this Recommendation.)</span>
              </p>
           </annex>
           <annex id="B7" obligation="informative" autonum="VII" displayorder="19">
              <title id="_">
                 <strong>Annex</strong>
              </title>
              <fmt-title>
                 <strong>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Appendix</span>
                       <semx element="autonum" source="B7">VII</semx>
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
                 <span class="fmt-element-name">Appendix</span>
                 <semx element="autonum" source="B7">VII</semx>
              </fmt-xref-label>
              <p class="annex_obligation">
                 <span class="fmt-obligation">(This appendix does not form an integral part of this Recommendation.)</span>
              </p>
           </annex>
           <annex id="B8" obligation="informative" autonum="VIII" displayorder="20">
              <title id="_">
                 <strong>Annex</strong>
              </title>
              <fmt-title>
                 <strong>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Appendix</span>
                       <semx element="autonum" source="B8">VIII</semx>
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
                 <span class="fmt-element-name">Appendix</span>
                 <semx element="autonum" source="B8">VIII</semx>
              </fmt-xref-label>
              <p class="annex_obligation">
                 <span class="fmt-obligation">(This appendix does not form an integral part of this Recommendation.)</span>
              </p>
           </annex>
           <annex id="B9" obligation="informative" autonum="IX" displayorder="21">
              <title id="_">
                 <strong>Annex</strong>
              </title>
              <fmt-title>
                 <strong>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Appendix</span>
                       <semx element="autonum" source="B9">IX</semx>
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
                 <span class="fmt-element-name">Appendix</span>
                 <semx element="autonum" source="B9">IX</semx>
              </fmt-xref-label>
              <p class="annex_obligation">
                 <span class="fmt-obligation">(This appendix does not form an integral part of this Recommendation.)</span>
              </p>
           </annex>
           <annex id="B10" obligation="informative" autonum="X" displayorder="22">
              <title id="_">
                 <strong>Annex</strong>
              </title>
              <fmt-title>
                 <strong>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Appendix</span>
                       <semx element="autonum" source="B10">X</semx>
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
                 <span class="fmt-element-name">Appendix</span>
                 <semx element="autonum" source="B10">X</semx>
              </fmt-xref-label>
              <p class="annex_obligation">
                 <span class="fmt-obligation">(This appendix does not form an integral part of this Recommendation.)</span>
              </p>
           </annex>
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
    pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::HtmlConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(html)
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
                 <doctype language="">recommendation</doctype>
                 <doctype language="en">Recommendation</doctype>
                 <flavor>itu</flavor>
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
                 <p>This is an abstract</p>
              </abstract>
              <clause type="keyword" displayorder="3">
                 <fmt-title depth="1">Keywords</fmt-title>
                 <p>A, B.</p>
              </clause>
              <foreword obligation="informative" displayorder="4">
                 <title id="_">Foreword</title>
                 <fmt-title depth="1">
                    <semx element="title" source="_">Foreword</semx>
                 </fmt-title>
                 <p id="A">This is a preamble</p>
              </foreword>
              <introduction id="B" obligation="informative" displayorder="5">
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
              </introduction>
              <clause id="A0" displayorder="6">
                 <title id="_">History</title>
                 <fmt-title depth="1">
                    <semx element="title" source="_">History</semx>
                 </fmt-title>
                 <p>history</p>
              </clause>
           </preface>
           <sections>
              <p class="zzSTDTitle1" displayorder="7">Draft new Recommendation 12345</p>
              <p class="zzSTDTitle2" displayorder="8">An ITU Standard</p>
              <clause id="D" obligation="normative" type="scope" displayorder="9">
                 <title id="_">Scope</title>
                 <fmt-title depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="D">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">Scope</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">clause</span>
                    <semx element="autonum" source="D">1</semx>
                 </fmt-xref-label>
                 <p id="E">Text</p>
              </clause>
              <terms id="I" obligation="normative" displayorder="11">
                 <fmt-title depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="I">3</semx>
                       <span class="fmt-autonum-delim">.</span>
                    </span>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">clause</span>
                    <semx element="autonum" source="I">3</semx>
                 </fmt-xref-label>
                 <term id="J">
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="I">3</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="J">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <span class="fmt-element-name">clause</span>
                       <semx element="autonum" source="I">3</semx>
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
              <definitions id="L" displayorder="12">
                 <title id="_">Abbreviations and acronyms</title>
                 <fmt-title depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="L">4</semx>
                       <span class="fmt-autonum-delim">.</span>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">Abbreviations and acronyms</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">clause</span>
                    <semx element="autonum" source="L">4</semx>
                 </fmt-xref-label>
                 <dl>
                    <colgroup>
                       <col width="20%"/>
                       <col width="80%"/>
                    </colgroup>
                    <dt>Symbol</dt>
                    <dd>Definition</dd>
                 </dl>
              </definitions>
              <clause id="M" inline-header="false" obligation="normative" displayorder="13">
                 <title id="_">Clause 4</title>
                 <fmt-title depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="M">5</semx>
                       <span class="fmt-autonum-delim">.</span>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">Clause 4</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">clause</span>
                    <semx element="autonum" source="M">5</semx>
                 </fmt-xref-label>
                 <clause id="N" inline-header="false" obligation="normative">
                    <title id="_">Introduction</title>
                    <fmt-title depth="2">
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="M">5</semx>
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
                       <span class="fmt-element-name">clause</span>
                       <semx element="autonum" source="M">5</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="N">1</semx>
                    </fmt-xref-label>
                 </clause>
                 <clause id="O" inline-header="false" obligation="normative">
                    <title id="_">Clause 4.2</title>
                    <fmt-title depth="2">
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="M">5</semx>
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
                       <span class="fmt-element-name">clause</span>
                       <semx element="autonum" source="M">5</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="O">2</semx>
                    </fmt-xref-label>
                 </clause>
              </clause>
              <references id="R" obligation="informative" normative="true" displayorder="10">
                 <title id="_">References</title>
                 <fmt-title depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="R">2</semx>
                       <span class="fmt-autonum-delim">.</span>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">References</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">clause</span>
                    <semx element="autonum" source="R">2</semx>
                 </fmt-xref-label>
              </references>
           </sections>
           <annex id="P" inline-header="false" obligation="normative" autonum="A" displayorder="14">
              <title id="_">
                 <strong>Annex</strong>
              </title>
              <fmt-title>
                 <strong>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Annex</span>
                       <semx element="autonum" source="P">A</semx>
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
                 <semx element="autonum" source="P">A</semx>
              </fmt-xref-label>
              <p class="annex_obligation">
                 <span class="fmt-obligation">(This annex forms an integral part of this Recommendation.)</span>
              </p>
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
                    <span class="fmt-element-name">clause</span>
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
                       <span class="fmt-element-name">clause</span>
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
              <clause id="S" obligation="informative" displayorder="15">
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
       #{HTML_HDR}
                 <br/>
                 <div>
           <h1 class="AbstractTitle">Abstract</h1>
           <p>This is an abstract</p>
         </div>
            <div class="Keyword">
        <h1 class="IntroTitle">Keywords</h1>
        <p>A, B.</p>
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
         <div id="A0">
           <h1 class="IntroTitle">History</h1>
           <p>history</p>
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
                        <div id="J"><p class="TermNum" id="J"><b>3.1.&#160; <b>Term2</b>:</b></p>
                 </div>
                      </div>
                        <div id="L" class="Symbols">
                        <h1>4.  Abbreviations and acronyms</h1>
                                <table class="dl" style="table-layout:fixed;">
        <colgroup>
          <col style="width: 20%;"/>
          <col style="width: 80%;"/>
        </colgroup>
                            <tbody>
                              <tr>
                                <th style="font-weight:bold;" scope="row">Symbol</th>
                                <td style="">Definition</td>
                              </tr>
                            </tbody>
                          </table>
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
         <p class="section-break">
           <br clear="all" class="section"/>
         </p>
         <div class="WordSection2">
             <p class="page-break">
          <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
        </p>
        <div class="TOC" id="_">
          <p class="zzContents">Table of Contents</p>
          <p style="tab-stops:right 17.0cm">
            <span style="mso-tab-count:1">  </span>
            <b>Page</b>
          </p>
        </div>
         <div class='Abstract'>
             <h1 class="AbstractTitle">Summary</h1>
             <p>This is an abstract</p>
           </div>
           <div class='Keyword'>
             <h1 class="IntroTitle">Keywords</h1>
             <p>A, B.</p>
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
           <div id="A0">
              <h1 class="IntroTitle">History</h1>
              <p>history</p>
            </div>
           <p>&#160;</p>
         </div>
         <p class="section-break">
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
        <div id="J"><p class="TermNum" id="J"><b>3.1.<span style="mso-tab-count:1">&#160; </span><b>Term2</b>:</b> </p>
      </div>
      </div>
           <div id="L" class="Symbols">
           <h1>
            4.
            <span style="mso-tab-count:1">  </span>
            Abbreviations and acronyms
         </h1>

                   <div align="center" class="table_container">
        <table class="dl" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;">
          <colgroup>
           <col width="20%"/>
           <col width="80%"/>
         </colgroup>
          <tbody>
            <tr>
              <th valign="top" style="font-weight:bold;page-break-after:auto;">Symbol</th>
              <td valign="top" style="page-break-after:auto;">Definition</td>
            </tr>
          </tbody>
        </table>
      </div>
           </div>
           <div id="M">
             <h1>5.<span style="mso-tab-count:1">&#160; </span>Clause 4</h1>
             <div id="N"><h2>5.1.<span style="mso-tab-count:1">&#160; </span>Introduction</h2>
      </div>
             <div id="O"><h2>5.2.<span style="mso-tab-count:1">&#160; </span>Clause 4.2</h2>
      </div>
           </div>
           <p class="page-break">
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
           <p class="page-break">
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
    pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", itudoc("en"), true)
    expect(Xml::C14n.format(strip_guid(pres_output
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::HtmlConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::WordConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "post-processes section names (Word)" do
    FileUtils.rm_f "test.doc"
    IsoDoc::Itu::WordConvert.new({}).convert("test", <<~INPUT, false)
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
             <clause id="D" obligation="normative" type="scope" displayorder="1">
               <fmt-title>1<tab/>Scope</fmt-title>
               <p id="E">Text</p>
               <figure id="fig-f1-1">
        <fmt-name>Static aspects of SDL‑2010</fmt-name>
        </figure>
        <p>Hello</p>
        <figure id="fig-f1-2">
        <fmt-name>Static aspects of SDL‑2010</fmt-name>
        </figure>
        <note><p>Hello</p></note>
             </clause>
             </sections>
              <annex id="P" inline-header="false" obligation="normative" displayorder="2">
               <fmt-title><strong>Annex A</strong><br/><br/><strong>Annex 1</strong></fmt-title>
               <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
               <clause id="Q" inline-header="false" obligation="normative">
               <fmt-title>A.1<tab/>Annex A.1</fmt-title>
               <p>Hello</p>
               </clause>
             </annex>
                 <annex id="P1" inline-header="false" obligation="normative" displayorder="3">
               <fmt-title><strong>Annex B</strong><br/><br/><strong>Annex 2</strong></fmt-title>
               <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
               <p>Hello</p>
               <clause id="Q1" inline-header="false" obligation="normative">
               <fmt-title>B.1<tab/>Annex A1.1</fmt-title>
               <p>Hello</p>
               </clause>
               </clause>
             </annex>
             </itu-standard>
    INPUT
    expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc", encoding: "UTF-8")
    expect(Xml::C14n.format(html
      .sub(%r{^.*<div class="WordSection3">}m, %{<body><div class="WordSection3">})
      .gsub(%r{</body>.*$}m, "</body>")))
      .to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
        <body><div class="WordSection3">
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
             <sections><clause/></sections>
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
            <itu-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
           <bibdata type="standard">
              <title language="en" format="text/plain" type="main">An ITU Standard</title>
              <title language="en" format="text/plain" type="subtitle">Subtitle</title>
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
              <clause type="keyword" displayorder="1">
                 <fmt-title depth="1">Keywords</fmt-title>
                 <p>A, B.</p>
              </clause>
              <clause type="toc" id="_" displayorder="2">
                 <fmt-title depth="1">Table of Contents</fmt-title>
              </clause>
           </preface>
           <sections>
              <p class="zzSTDTitle1" displayorder="3">Draft new Recommendation 12345</p>
              <p class="zzSTDTitle2" displayorder="4">An ITU Standard</p>
              <p class="zzSTDTitle3" displayorder="5">Subtitle</p>
              <clause displayorder="6"/>
           </sections>
           <annex id="A1" obligation="normative" autonum="F2" displayorder="7">
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
                 <table id="T" autonum="F2.1">
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <span class="fmt-element-name">Table</span>
                          <semx element="autonum" source="A1">F2</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="T">1</semx>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <span class="fmt-element-name">Table</span>
                       <semx element="autonum" source="A1">F2</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="T">1</semx>
                    </fmt-xref-label>
                 </table>
                 <figure id="U" autonum="F2.1">
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <span class="fmt-element-name">Figure</span>
                          <semx element="autonum" source="A1">F2</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="U">1</semx>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <span class="fmt-element-name">Figure</span>
                       <semx element="autonum" source="A1">F2</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="U">1</semx>
                    </fmt-xref-label>
                 </figure>
                 <formula id="V" autonum="F2-1">
                    <fmt-name>
                       <span class="fmt-caption-label">
                          <span class="fmt-autonum-delim">(</span>
                          <semx element="autonum" source="A1">F2</semx>
                          <span class="fmt-autonum-delim">-</span>
                          <semx element="autonum" source="V">1</semx>
                          <span class="fmt-autonum-delim">)</span>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <span class="fmt-element-name">Equation</span>
                       <span class="fmt-autonum-delim">(</span>
                       <semx element="autonum" source="A1">F2</semx>
                       <span class="fmt-autonum-delim">-</span>
                       <semx element="autonum" source="V">1</semx>
                       <span class="fmt-autonum-delim">)</span>
                    </fmt-xref-label>
                    <stem type="AsciiMath">r = 1 %</stem>
                 </formula>
              </clause>
           </annex>
        </itu-standard>
    OUTPUT
    pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    IsoDoc::Itu::HtmlConvert.new({}).convert("test", pres_output, false)
    html = File.read("test.html", encoding: "utf-8")
    expect(Xml::C14n.format(strip_guid(html.gsub(%r{^.*<main}m, "<main")
      .gsub(%r{</main>.*}m, "</main>"))))
      .to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
            <main class='main-section'>
                 <button onclick='topFunction()' id='myBtn' title='Go to top'>Top</button>
                   <div class="Keyword">
                  <h1 class="IntroTitle" id="_">Keywords</h1>
                    <p>A, B.</p>
                </div>
                 <br/>
                 <p class='zzSTDTitle1'>Draft new Recommendation 12345</p>
                 <p class='zzSTDTitle2'>An ITU Standard</p>
                 <p class='zzSTDTitle3'>Subtitle</p>
                 <div/>
                 <div id='A1' class='Section3'>
                   <p class='h1Annex'>
                     <b>Annex F2</b>
                     <br/>
                     <br/>
                     <b>Annex</b>
                   </p>
                   <p class='annex_obligation'>(This annex forms an integral part of this Recommendation Annex.)</p>
                   <div id='A2'>
                     <h2 id='_'><a class="anchor" href="#A2"/><a class="header" href="#A2">F2.1.&#xA0; Subtitle</a></h2>
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

    IsoDoc::Itu::WordConvert.new({}).convert("test", pres_output, false)
    html = File.read("test.doc", encoding: "utf-8")
    expect(Xml::C14n.format(html
 .gsub(%r{^.*<div class="WordSection3">}m, '<div class="WordSection3" xmlns:m="http://schemas.microsoft.com/office/2004/12/omml">')
 .gsub(%r{<div style="mso-element:footnote-list"/>.*}m, "")))
      .to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
        <div class='WordSection3' xmlns:m='http://schemas.microsoft.com/office/2004/12/omml'>
              <p class='zzSTDTitle1'>Draft new Recommendation 12345</p>
              <p class='zzSTDTitle2'>An ITU Standard</p>
              <p class='zzSTDTitle3'>Subtitle</p>
              <div/>
              <div class='Section3'>
                <a name='A1' id='A1'/>
                <p class='h1Annex'>
                  <b>Annex F2</b>
                  <br/>
                  <br/>
                  <b>Annex</b>
                </p>
                <p class='annex_obligation'>(This annex forms an integral part of this Recommendation Annex.)</p>
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
                        <span class="stem">(#(r = 1 %)#)</span>
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
    IsoDoc::Itu::WordConvert.new({}).convert("test", <<~INPUT, false)
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface><clause id="_history" obligation="normative" displayorder="1">
        <fmt-title>History</fmt-title>
        <table id="_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4">
        <fmt-name>Table 1</fmt-name>
        <tbody>
          <tr>
            <td align="left">Edition</td>
            <td align="left">Recommendation</td>
            <td align="left">Approval</td>
            <td align="left">Study Group</td>
            <td align="left">Unique ID<fn reference="a)">
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
    expect(Xml::C14n.format(html
      .gsub(%r{.*<p class="h1Preface">History</p>}m,
            '<div><p class="h1Preface">History</p>')
      .sub(%r{</table>.*$}m, "</table></div></div>")))
      .to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
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
                               <td align="left" style="" valign="top">Unique ID<a href="#_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4a)" class="TableFootnoteRef">a)</a>.</td>
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
                         <tfoot><tr><td colspan="5" style=""><div class="TableFootnote"><div><a name="ftn_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4a)" id="ftn_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4a)"></a>
                 <p class="TableFootnote"><a name="_8a4ff03f-e7a6-4430-939d-1b7b0ffa60e9" id="_8a4ff03f-e7a6-4430-939d-1b7b0ffa60e9"></a><span><span class="TableFootnoteRef"><a name="_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4a)" id="_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4a)"></a>a)</span><span style="mso-tab-count:1">&#xA0; </span></span>To access the Recommendation, type the URL <a href="http://handle.itu.int/" class="url">http://handle.itu.int/</a> in the address field of your web browser, followed by the Recommendation?~@~Ys unique ID. For example, <a href="http://handle.itu.int/11.1002/1000/11830-en" class="url">http://handle.itu.int/11.1002/1000/11830-en</a></p>
               </div></div></td></tr></tfoot></table>
               </div></div>
      OUTPUT
  end

  it "processes unnumbered clauses" do
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
        <itu-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
           <bibdata type="standard">
              <title language="en" format="text/plain" type="main">An ITU Standard</title>
              <title language="en" format="text/plain" type="resolution">RESOLUTION  (, )</title>
              <title language="en" format="text/plain" type="resolution-placedate">, </title>
              <title language="en" format="text/plain" type="subtitle">Subtitle</title>
              <docidentifier type="ITU">12345</docidentifier>
              <language current="true">en</language>
              <ext>
                 <doctype language="">resolution</doctype>
                 <doctype language="en">Resolution</doctype>
                 <structuredidentifier>
                    <annexid>F2</annexid>
                 </structuredidentifier>
              </ext>
           </bibdata>
           <sections>
              <p class="zzSTDTitle1" align="center" displayorder="1">RESOLUTION  (, )</p>
              <p class="zzSTDTitle2" displayorder="2">An ITU Standard</p>
              <p align="center" class="zzSTDTitle2" displayorder="3">
                 <em>(,</em>
                 )
              </p>
              <clause unnumbered="true" id="A" displayorder="4">
                 <p>Text</p>
              </clause>
              <p keep-with-next="true" class="supertitle" displayorder="5">
                 <span class="fmt-element-name">SECTION</span>
                 <semx element="autonum" source="B">1</semx>
              </p>
              <clause id="B" displayorder="6">
                 <title id="_">First Clause</title>
                 <fmt-title depth="1">
                       <semx element="title" source="_">First Clause</semx>
                 </fmt-title>
              </clause>
           </sections>
        </itu-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "processes bis, ter etc clauses" do
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
              <title language="en" format="text/plain" type="main">An ITU Standard</title>
              <title language="en" format="text/plain" type="resolution">RESOLUTION  (, )</title>
              <title language="en" format="text/plain" type="resolution-placedate">, </title>
              <title language="en" format="text/plain" type="subtitle">Subtitle</title>
              <docidentifier type="ITU">12345</docidentifier>
              <language current="true">en</language>
              <ext>
                 <doctype language="">resolution</doctype>
                 <doctype language="en">Resolution</doctype>
                 <structuredidentifier>
                    <annexid>F2</annexid>
                 </structuredidentifier>
              </ext>
           </bibdata>
           <sections>
              <p class="zzSTDTitle1" align="center" displayorder="1">RESOLUTION  (, )</p>
              <p class="zzSTDTitle2" displayorder="2">An ITU Standard</p>
              <p align="center" class="zzSTDTitle2" displayorder="3">
                 <em>(,</em>
                 )
              </p>
              <p keep-with-next="true" class="supertitle" displayorder="4">
                 <span class="fmt-element-name">SECTION</span>
                 <semx element="autonum" source="A">1</semx>
              </p>
              <clause id="A" displayorder="5">
                 <p>
                    <xref target="B">
                       <span class="fmt-element-name">Section</span>
                       <semx element="autonum" source="B">
                          1
                          <em>bis</em>
                       </semx>
                    </xref>
                    ,
                    <xref target="C">
                       <span class="fmt-element-name">Section</span>
                       <semx element="autonum" source="C">
                          10
                          <em>ter</em>
                       </semx>
                    </xref>
                    ,
                    <xref target="D">
                       <semx element="autonum" source="C">
                          10
                          <em>ter</em>
                       </semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="D">
                          10
                          <em>quater</em>
                       </semx>
                    </xref>
                    ,
                    <xref target="E">
                       <span class="fmt-element-name">Section</span>
                       <semx element="autonum" source="E">10bit</semx>
                    </xref>
                 </p>
              </clause>
              <p keep-with-next="true" class="supertitle" displayorder="6">
                 <span class="fmt-element-name">SECTION</span>
                 <semx element="autonum" source="B">
                    1
                    <em>bis</em>
                 </semx>
              </p>
              <clause id="B" number="1bis" displayorder="7">
                 <title id="_">First Clause</title>
                 <fmt-title depth="1">
                       <semx element="title" source="_">First Clause</semx>
                 </fmt-title>
              </clause>
              <p keep-with-next="true" class="supertitle" displayorder="8">
                 <span class="fmt-element-name">SECTION</span>
                 <semx element="autonum" source="C">
                    10
                    <em>ter</em>
                 </semx>
              </p>
              <clause id="C" number="10ter" displayorder="9">
                 <title id="_">Second Clause</title>
                 <fmt-title depth="1">
                       <semx element="title" source="_">Second Clause</semx>
                 </fmt-title>
                 <clause id="D" number="10quater">
                    <title id="_">Second Clause Subclause</title>
                    <fmt-title depth="2">
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="C">
                             10
                             <em>ter</em>
                          </semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="D">
                             10
                             <em>quater</em>
                          </semx>
                          <span class="fmt-autonum-delim">.</span>
                          </span>
                          <span class="fmt-caption-delim">
                             <tab/>
                          </span>
                          <semx element="title" source="_">Second Clause Subclause</semx>
                    </fmt-title>
                    <fmt-xref-label>
                       <semx element="autonum" source="C">
                          10
                          <em>ter</em>
                       </semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="D">
                          10
                          <em>quater</em>
                       </semx>
                    </fmt-xref-label>
                 </clause>
              </clause>
              <p keep-with-next="true" class="supertitle" displayorder="10">
                 <span class="fmt-element-name">SECTION</span>
                 <semx element="autonum" source="E">10bit</semx>
              </p>
              <clause id="E" number="10bit" displayorder="11">
                 <title id="_">Non-Clause</title>
                 <fmt-title depth="1">
                       <semx element="title" source="_">Non-Clause</semx>
                 </fmt-title>
              </clause>
           </sections>
        </itu-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "processes editor clauses, one editor" do
    input = <<~INPUT
      <itu-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata type="standard">
      <title language="en" format="text/plain" type="main">An ITU Standard</title>
      <title language="en" format="text/plain" type="subtitle">Subtitle</title>
      <docidentifier type="ITU">12345</docidentifier>
      <contributor><role type="editor"/>
      <person><name><completename>Fred Flintstone</completename></name>
      <affiliation><organization><name>World Health Organization</name></organization></affiliation>
      <email>jack@example.com</email>
      </contributor>
      <contributor><role type="author"/>
      <person><name><completename>Barney Rubble</completename></name>
      <affiliation><organization><name>World Health Organization</name></organization></affiliation>
      <email>jack@example.com</email>
      </person>
      </contributor>
      <language>en</language>
      <ext>
      <doctype>resolution</doctype>
      <structuredidentifier>
      <annexid>F2</annexid>
      </structuredidentifier>
      </ext>
      </bibdata>
      <sections>
        <clause id="A"/>
      </sections>
      </itu-standard>
    INPUT
    presxml = <<~OUTPUT
      <preface>
        <clause type="toc" id="_" displayorder="1"> 
        <fmt-title depth="1">Table of Contents</fmt-title>
          </clause>
         <clause id='_' type='editors' displayorder='2'>
           <table id='_' unnumbered='true'>
             <tbody>
               <tr>
                 <th>Editor:</th>
                 <td>
                   Fred Flintstone
                   <br/>
                   World Health Organization
                 </td>
                 <td>
                   E-mail:
                   <link target='mailto:jack@example.com'>jack@example.com</link>
                 </td>
               </tr>
             </tbody>
           </table>
         </clause>
       </preface>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::Itu::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
    xml = xml.at("//xmlns:preface").to_xml
    expect(Xml::C14n.format(strip_guid(xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "processes editor clauses, two editors" do
    input = <<~INPUT
      <itu-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata type="standard">
      <title language="en" format="text/plain" type="main">An ITU Standard</title>
      <title language="en" format="text/plain" type="subtitle">Subtitle</title>
      <docidentifier type="ITU">12345</docidentifier>
      <contributor><role type="editor"/>
      <person><name><completename>Fred Flintstone</completename></name>
      <affiliation><organization><name>World Health Organization</name></organization></affiliation>
      <email>jack@example.com</email>
      </person>
      </contributor>
      <contributor><role type="editor"/>
      <person><name><forename>Barney</forename> <surname>Rubble</surname></name></person>
      </contributor>
      <language>en</language>
      <ext>
      <doctype>resolution</doctype>
      <structuredidentifier>
      <annexid>F2</annexid>
      </structuredidentifier>
      </ext>
      </bibdata>
      <sections>
        <clause id="A"><p/></clause>
      </sections>
      </itu-standard>
    INPUT
    presxml = <<~OUTPUT
      <preface>
         <clause id='_' type='editors' displayorder='1'>
           <table id='_' unnumbered='true'>
             <tbody>
               <tr>
                 <th>Editors:</th>
                 <td>
                   Fred Flintstone
                   <br/>
                   World Health Organization
                 </td>
                 <td>
                   E-mail:
                   <link target='mailto:jack@example.com'>jack@example.com</link>
                 </td>
               </tr>
               <tr>
                 <th/>
                 <td>Barney Rubble</td>
                 <td/>
               </tr>
             </tbody>
           </table>
         </clause>
       </preface>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::Itu::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
    xml = xml.at("//xmlns:preface").to_xml
    expect(Xml::C14n.format(strip_guid(xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "generates contribution prefatory table and abstract table" do
    logoloc = File.expand_path(
      File.join(File.dirname(__FILE__), "..", "..", "lib", "isodoc", "itu",
                "html"),
    )
    input = <<~INPUT
      <itu-standard xmlns='https://www.metanorma.org/ns/itu' type='semantic'>
        <bibdata type='standard'>
          <title language='en' format='text/plain' type='main'>Main Title</title>
          <title language='fr' format='text/plain' type='main'>Titre Principal</title>
          <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
          <title language='fr' format='text/plain' type='subtitle'>Soustitre</title>
          <docidentifier type='ITU-provisional'>ABC</docidentifier>
          <docidentifier primary="true" type='ITU'>SG17-C1000</docidentifier>
          <docidentifier type='ITU-lang'>SG17-C1000-E</docidentifier>
          <docnumber>1000</docnumber>
          <contributor>
            <role type='author'/>
            <organization>
              <name>International Telecommunication Union</name><abbreviation>ITU</abbreviation>
            </organization>
          </contributor>
          <contributor>
          <role type='editor'>raporteur</role>
            <person>
              <name>
                <completename>Fred Flintstone</completename>
              </name>
              <affiliation>
                <organization>
                  <name>Bedrock Quarry</name>
                  <address>
                    <formattedAddress>Canada</formattedAddress>
                  </address>
                </organization>
              </affiliation>
              <phone>555</phone>
              <phone type='fax'>556</phone>
              <email>x@example.com</email>
            </person>
          </contributor>
          <contributor>
            <role type='editor'/>
            <person>
              <name>
                <completename>Barney Rubble</completename>
              </name>
              <affiliation>
                <organization>
                  <name>Bedrock Quarry 2</name>
                  <address>
                    <formattedAddress>USA</formattedAddress>
                  </address>
                </organization>
              </affiliation>
              <phone>557</phone>
              <phone type='fax'>558</phone>
            </person>
          </contributor>
          <contributor>
            <role type='publisher'/>
            <organization>
              <name>International Telecommunication Union</name>
              <abbreviation>ITU</abbreviation>
            </organization>
          </contributor>
          <edition>2</edition>
          <version>
            <revision-date>2000-01-01</revision-date>
            <draft>5</draft>
          </version>
          <language>en</language>
          <script>Latn</script>
          <status>
            <stage>draft</stage>
          </status>
          <copyright>
            <from>2001</from>
            <owner>
              <organization>
                <name>International Telecommunication Union</name>
                <abbreviation>ITU</abbreviation>
              </organization>
            </owner>
          </copyright>
          <series type='main'>
            <title>A3</title>
          </series>
          <series type='secondary'>
            <title>B3</title>
          </series>
          <series type='tertiary'>
            <title>C3</title>
          </series>
          <keyword>VoIP</keyword>
          <keyword>word1</keyword>
          <ext>
            <doctype>contribution</doctype>
            <editorialgroup>
              <bureau>R</bureau>
              <group type="study-group">
                <name>Study Group 17</name>
                <acronym>SG17</acronym>
                <period>
                  <start>2000</start>
                  <end>2002</end>
                </period>
              </group>
              <subgroup>
                <name>I1</name>
              </subgroup>
              <workgroup>
                <name>I2</name>
              </workgroup>
            </editorialgroup>
            <recommendationstatus>
                <from>D3</from>
                <to>E3</to>
                <approvalstage process='F3'>G3</approvalstage>
              </recommendationstatus>
              <ip-notice-received>false</ip-notice-received>
              <timing>2025-Q4</timing>
            <meeting acronym='MX'>Meeting X</meeting>
            <meeting-place>Kronos</meeting-place>
            <meeting-date>
              <from>2000-01-01</from>
              <to>2000-01-02</to>
            </meeting-date>
            <intended-type>TD</intended-type>
            <source>Source1</source>
            <structuredidentifier>
              <bureau>R</bureau>
              <docnumber>1000</docnumber>
            </structuredidentifier>
          </ext>
        </bibdata>
        <preface>
        <abstract id="A"><p>This is an abstract.</p></abstract>
        </preface>
        <sections>
        <clause id="B"><title>First</title><p>This is the first clause</p></clause>
        </sections>
        <annex id="A1"><title>Annex</title></annex>
        <annex id="A2" type="justification">
        <title>Scope</title><p id="_37adf2c4-28f1-ea9c-0f52-b2ff84b33b55">TEXT 1</p>
        </clause>
        <clause id="_2" type="summary" inline-header="false" obligation="normative">
        <p id="_5f7e73d1-bd2e-8b40-bd86-c2ba5a400577">TEXT 2</p>
        </clause>
        <clause id="_3" type="relatedstandards" inline-header="false" obligation="normative">
        <ol id="_5d94d081-b33a-6cb0-61f3-d4ce3bb47ea2"><li><p id="_7e51a815-c9d7-074a-7125-bea511e3927d">TEXT 3</p>
        </li>
        <li><p id="_d8492089-77f3-0b7d-2750-aaacd5c0e8d3">TEXT 4</p>
        </li>
        <li><p id="_16595e62-ff08-3742-84c1-dbbae8ac1fab">TEXT 5</p>
        </li>
        </ol>
        </clause>
        <clause id="_4" type="liaisons" inline-header="false" obligation="normative">
        <ol id="_22e6d6a2-63f6-8afc-2adb-329f4bef13e7"><li><p id="_111c6bfd-8e98-c405-a425-c6112d028f8e">TEXT 6</p>
        </li>
        <li><p id="_7df8ce97-29db-c8c9-46ef-5731bc258a16">TEXT 7</p>
        </li>
        <li><p id="_ea1810b1-db12-e76f-6597-c67aea0160f5">TEXT 8</p>
        </li>
        </ol>
        </clause>
        <clause id="_5" type="supportingmembers" inline-header="false" obligation="normative">
        <p id="_a42297b2-5f04-5da9-64c2-7e92670d5cad">TEXT 9</p>
        </clause>
        </annex>
        </itu-standard>
    INPUT
    presxml = <<~OUTPUT
        <itu-standard>
           <preface>
              <clause unnumbered="true" type="contribution-metadata" displayorder="1">
                 <table class="contribution-metadata" unnumbered="true" width="100%">
                    <colgroup>
                       <col width="11.8%"/>
                       <col width="41.2%"/>
                       <col width="47.0%"/>
                    </colgroup>
                    <thead>
                       <tr>
                          <th rowspan="3">
                             <image height="56" width="56" src="#{logoloc}/logo-small.png"/>
                          </th>
                          <td rowspan="3">
                             <p style="font-size:8pt;margin-top:6pt;margin-bottom:0pt;">INTERNATIONAL TELECOMMUNICATION UNION</p>
                             <p class="bureau_big" style="font-size:13pt;margin-top:6pt;margin-bottom:0pt;">
                                <strong>RADIOCOMMUNICATION BUREAU</strong>
                                <br/>
                                <strong>OF ITU</strong>
                             </p>
                             <p style="font-size:10pt;margin-top:6pt;margin-bottom:0pt;">STUDY PERIOD 2000–2002</p>
                          </td>
                          <th align="right">
                             <p style="font-size:16pt;">SG17-C1000</p>
                          </th>
                       </tr>
                       <tr>
                          <th align="right">
                             <p style="font-size:14pt;">STUDY GROUP 17</p>
                          </th>
                       </tr>
                       <tr>
                          <th align="right">
                             <p style="font-size:14pt;">Original: English</p>
                          </th>
                       </tr>
                    </thead>
                    <tbody>
                       <tr>
                          <th align="left" width="95">Question(s):</th>
                          <td/>
                          <td align="right">Kronos, 01 Jan 2000/02 Jan 2000</td>
                       </tr>
                       <tr>
                          <th align="center" colspan="3">CONTRIBUTION</th>
                       </tr>
                       <tr>
                          <th align="left" width="95">Source:</th>
                          <td colspan="2">Source1</td>
                       </tr>
                       <tr>
                          <th align="left" width="95">Title:</th>
                          <td colspan="2">Main Title</td>
                       </tr>
                       <tr>
                          <th align="left" width="95">Contact:</th>
                          <td>
                             Fred Flintstone
                             <br/>
                             Bedrock Quarry
                             <br/>
                             Canada
                          </td>
                          <td>
                             Tel.
                             <tab/>
                             555
                             <br/>
                             E-mail
                             <tab/>
                             x@example.com
                          </td>
                       </tr>
                       <tr>
                          <th align="left" width="95">Contact:</th>
                          <td>
                             Barney Rubble
                             <br/>
                             Bedrock Quarry 2
                             <br/>
                             USA
                          </td>
                          <td>
                             Tel.
                             <tab/>
                             557
                          </td>
                       </tr>
                       <tr>
                          <th align="left" width="95">Contact:</th>
                          <td>
                             <br/>
                             <br/>
                          </td>
                          <td>
                             Tel.
                             <tab/>
                          </td>
                       </tr>
                    </tbody>
                 </table>
              </clause>
              <abstract id="A" displayorder="2">
                 <table class="abstract" unnumbered="true" width="100%">
                    <colgroup>
                       <col width="11.8%"/>
                       <col width="78.2%"/>
                    </colgroup>
                    <tbody>
                       <tr>
                          <th align="left" width="95">
                             <p>Abstract:</p>
                          </th>
                          <td>
                             <p>This is an abstract.</p>
                          </td>
                       </tr>
                    </tbody>
                 </table>
              </abstract>
           </preface>
           <sections>
              <clause id="B" displayorder="3">
                 <title id="_">First</title>
                 <fmt-title depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="B">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">First</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">clause</span>
                    <semx element="autonum" source="B">1</semx>
                 </fmt-xref-label>
                 <p>This is the first clause</p>
              </clause>
           </sections>
           <annex id="A1" autonum="A" displayorder="4">
              <title id="_">
                 <strong>Annex</strong>
              </title>
              <fmt-title>
                 <strong>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Annex</span>
                       <semx element="autonum" source="A1">A</semx>
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
                 <semx element="autonum" source="A1">A</semx>
              </fmt-xref-label>
              <p class="annex_obligation">
                 <span class="fmt-obligation">(This annex forms an integral part of this Contribution.)</span>
              </p>
           </annex>
           <annex id="A2" type="justification" autonum="B" displayorder="5">
              <title id="_">
         <strong>A.13 justification for proposed draft new  SG17-C1000 “Main Title”</strong>
      </title>
              <fmt-title>
                 <strong>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Annex</span>
                       <semx element="autonum" source="A2">B</semx>
                    </span>
                 </strong>
         <span class="fmt-caption-delim">
            <br/>
            <br/>
         </span>
         <semx element="title" source="_">
            <strong>A.13 justification for proposed draft new  SG17-C1000 “Main Title”</strong>
         </semx>
              </fmt-title>
              <fmt-xref-label>
                 <span class="fmt-element-name">Annex</span>
                 <semx element="autonum" source="A2">B</semx>
              </fmt-xref-label>
              <p class="annex_obligation">
                 <span class="fmt-obligation">(This annex forms an integral part of this Contribution.)</span>
              </p>
              <table class="contribution-metadata" unnumbered="true" width="100%">
                 <colgroup>
                    <col width="15.9%"/>
                    <col width="6.1%"/>
                    <col width="45.5%"/>
                    <col width="17.4%"/>
                    <col width="15.1%"/>
                 </colgroup>
                 <tbody>
                    <tr>
                       <th align="left">Question(s):</th>
                       <td/>
                       <th align="left">Proposed new ITU-T </th>
                       <td colspan="2">Kronos, 01 Jan 2000/02 Jan 2000</td>
                    </tr>
                    <tr>
                       <th align="left">Reference and title:</th>
                       <td colspan="4">Draft new  on “Main Title”</td>
                    </tr>
                    <tr>
                       <th align="left">Base text:</th>
                       <td colspan="2"/>
                       <th align="left">Timing:</th>
                       <td>2025-Q4</td>
                    </tr>
                    <tr>
                       <th align="left" rowspan="2">Editor(s):</th>
                       <td colspan="2">
                          Fred Flintstone
                          <br/>
                          Bedrock Quarry
                          <br/>
                          Canada, E-mail
                          <tab/>
                          x@example.com
                       </td>
                       <th align="left" rowspan="2">Approval process:</th>
                       <td rowspan="2">F3</td>
                    </tr>
                    <tr>
                       <td colspan="2">
                          Barney Rubble
                          <br/>
                          Bedrock Quarry 2
                          <br/>
                          USA
                       </td>
                    </tr>
                    <tr>
                       <td colspan="2">
                          <br/>
                          <br/>
                       </td>
                    </tr>
                    <tr>
                       <td colspan="5">
                          <p>
                             <strong>Scope</strong>
                             (defines the intent or object of the Recommendation and the aspects covered, thereby indicating the limits of its applicability):
                          </p>
                       </td>
                    </tr>
                    <tr>
                       <td colspan="5">
                          <p>
                             <strong>Summary</strong>
                             (provides a brief overview of the purpose and contents of the Recommendation, thus permitting readers to judge its usefulness for their work):
                          </p>
                       </td>
                    </tr>
                    <tr>
                       <td colspan="5">
                          <p>
                             <strong>Relations to ITU-T Recommendations or to other standards</strong>
                             (approved or under development):
                          </p>
                       </td>
                    </tr>
                    <tr>
                       <td colspan="5">
                          <p>
                             <strong>Liaisons with other study groups or with other standards bodies:</strong>
                          </p>
                       </td>
                    </tr>
                    <tr>
                       <td colspan="5">
                          <p>
                             <strong>Supporting members that are committing to contributing actively to the work item:</strong>
                          </p>
                       </td>
                    </tr>
                 </tbody>
              </table>
           </annex>
        </itu-standard>
    OUTPUT

    xml = Nokogiri::XML(IsoDoc::Itu::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
    xml = xml.xpath("//xmlns:preface | //xmlns:sections | //xmlns:annex").to_xml
    expect(Xml::C14n.format(strip_guid("<itu-standard>#{xml}</itu-standard>")))
      .to be_equivalent_to Xml::C14n.format(presxml)

    presxml = <<~OUTPUT
      <preface>
         <clause unnumbered="true" type="contribution-metadata" displayorder="1">
           <table class="contribution-metadata" unnumbered="true" width="100%">
             <colgroup>
               <col width="11.8%"/>
               <col width="41.2%"/>
               <col width="47.0%"/>
             </colgroup>
             <thead>
               <tr>
                 <th rowspan="3">
                   <image height="56" width="56" src="#{File.join(logoloc, '/logo-small.png')}"/>
                 </th>
                 <td rowspan="3">
                   <p style="font-size:8pt;margin-top:6pt;margin-bottom:0pt;">UNION INTERNATIONALE DES TÉLÉCOMMUNICATIONS</p>
                   <p class="bureau_big" style="font-size:13pt;margin-top:6pt;margin-bottom:0pt;">
                     <strong>BUREAU DES RADIOCOMMUNICATIONS</strong>
                     <br/>
                     <strong>DE L’UIT</strong>
                   </p>
                   <p style="font-size:10pt;margin-top:6pt;margin-bottom:0pt;">PÉRIODE D’ÉTUDES 2000–2002</p>
                 </td>
                 <th align="right">
                   <p style="font-size:16pt;">SG17-C1000</p>
                 </th>
               </tr>
               <tr>
                 <th align="right">
                   <p style="font-size:14pt;">STUDY GROUP 17</p>
                 </th>
               </tr>
               <tr>
                 <th align="right">
                   <p style="font-size:14pt;">Original : Français</p>
                 </th>
               </tr>
             </thead>
                         <tbody>
               <tr>
                 <th align="left" width="95">Question(s):</th>
                 <td/>
                 <td align="right">Kronos, 01 janv. 2000/02 janv. 2000</td>
               </tr>
               <tr>
                 <th align="center" colspan="3">CONTRIBUTION</th>
               </tr>
               <tr>
                 <th align="left" width="95">Source :</th>
                 <td colspan="2">Source1</td>
               </tr>
               <tr>
                 <th align="left" width="95">Titre :</th>
                 <td colspan="2">Main Title</td>
               </tr>
               <tr>
                 <th align="left" width="95">Contact :</th>
                 <td>Fred Flintstone<br/>
       Bedrock Quarry<br/>
       Canada</td>
                 <td>Tél.<tab/>555<br/>E-mail<tab/>x@example.com</td>
               </tr>
               <tr>
                 <th align="left" width="95">Contact :</th>
                 <td>Barney Rubble<br/>
       Bedrock Quarry 2<br/>
       USA</td>
                 <td>Tél.<tab/>557</td>
               </tr>
               <tr>
                 <th align="left" width="95">Contact :</th>
                 <td>
                   <br/>
                   <br/>
                 </td>
                 <td>Tél.<tab/></td>
               </tr>
             </tbody>
           </table>
         </clause>
         <abstract id="A" displayorder="2">
           <table class="abstract" unnumbered="true" width="100%">
             <colgroup>
               <col width="11.8%"/>
               <col width="78.2%"/>
             </colgroup>
             <tbody>
               <tr>
                 <th align="left" width="95">
                   <p>Résumé :</p>
                 </th>
                 <td>
                   <p>This is an abstract.</p>
                 </td>
               </tr>
             </tbody>
           </table>
         </abstract>
       </preface>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::Itu::PresentationXMLConvert.new(presxml_options)
      .convert("test", input
      .sub("<language>en</language>", "<language>fr</language>"), true))
    xml = xml.at("//xmlns:preface").to_xml
    expect(Xml::C14n.format(strip_guid(xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end
end

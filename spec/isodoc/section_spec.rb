require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Itu do
  it "processes history and source clauses (Word)" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <clause type="history" id="H" displayorder="1"><fmt-title id="_">History</fmt-title></clause>
      <clause type="source" id="I" displayorder="2"><fmt-title id="_">Source</fmt-title></clause>
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
    expect(IsoDoc::Itu::WordConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<div class="WordSection2">}m, '<div class="WordSection2">')
      .gsub(%r{<p>\s*<br clear="all" class="section"/>\s*</p>\s*<div class="WordSection3">.*}m, ""))
      .to be_html4_equivalent_to output
  end

  it "processes annexes and appendixes" do
    input = <<~INPUT
             <metanorma xmlns="http://riboseinc.com/isoxml">
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
       <metanorma xmlns="http://riboseinc.com/isoxml" type="presentation">
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
                <fmt-title depth="1" id="_">Table of Contents</fmt-title>
             </clause>
             <abstract id="_" displayorder="2">
                <title id="_">Abstract</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Abstract</semx>
                </fmt-title>
                <xref target="A1" id="_"/>
                <semx element="xref" source="_">
                   <fmt-xref target="A1">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="A1">A</semx>
                   </fmt-xref>
                </semx>
                <xref target="B1" id="_"/>
                <semx element="xref" source="_">
                   <fmt-xref target="B1">
                      <span class="fmt-element-name">Appendix</span>
                      <semx element="autonum" source="B1">I</semx>
                   </fmt-xref>
                </semx>
             </abstract>
          </preface>
          <annex id="A1" obligation="normative" autonum="A" displayorder="3">
             <title id="_">Annex</title>
             <fmt-title id="_">
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
             <variant-title type="toc">
                <span class="fmt-caption-label">
                   <span class="fmt-element-name">Annex</span>
                   <semx element="autonum" source="A1">A</semx>
                </span>
                <span class="fmt-caption-delim">
                   <tab/>
                </span>
                <semx element="title" source="_">Annex</semx>
             </variant-title>
          </annex>
          <annex id="A2" obligation="normative" autonum="B" displayorder="4">
             <title id="_">Annex</title>
             <fmt-title id="_">
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
             <variant-title type="toc">
                <span class="fmt-caption-label">
                   <span class="fmt-element-name">Annex</span>
                   <semx element="autonum" source="A2">B</semx>
                </span>
                <span class="fmt-caption-delim">
                   <tab/>
                </span>
                <semx element="title" source="_">Annex</semx>
             </variant-title>
          </annex>
          <annex id="A3" obligation="normative" autonum="C" displayorder="5">
             <title id="_">Annex</title>
             <fmt-title id="_">
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
             <variant-title type="toc">
                <span class="fmt-caption-label">
                   <span class="fmt-element-name">Annex</span>
                   <semx element="autonum" source="A3">C</semx>
                </span>
                <span class="fmt-caption-delim">
                   <tab/>
                </span>
                <semx element="title" source="_">Annex</semx>
             </variant-title>
          </annex>
          <annex id="A4" obligation="normative" autonum="D" displayorder="6">
             <title id="_">Annex</title>
             <fmt-title id="_">
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
             <variant-title type="toc">
                <span class="fmt-caption-label">
                   <span class="fmt-element-name">Annex</span>
                   <semx element="autonum" source="A4">D</semx>
                </span>
                <span class="fmt-caption-delim">
                   <tab/>
                </span>
                <semx element="title" source="_">Annex</semx>
             </variant-title>
          </annex>
          <annex id="A5" obligation="normative" autonum="E" displayorder="7">
             <title id="_">Annex</title>
             <fmt-title id="_">
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
             <variant-title type="toc">
                <span class="fmt-caption-label">
                   <span class="fmt-element-name">Annex</span>
                   <semx element="autonum" source="A5">E</semx>
                </span>
                <span class="fmt-caption-delim">
                   <tab/>
                </span>
                <semx element="title" source="_">Annex</semx>
             </variant-title>
          </annex>
          <annex id="A6" obligation="normative" autonum="F" displayorder="8">
             <title id="_">Annex</title>
             <fmt-title id="_">
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
             <variant-title type="toc">
                <span class="fmt-caption-label">
                   <span class="fmt-element-name">Annex</span>
                   <semx element="autonum" source="A6">F</semx>
                </span>
                <span class="fmt-caption-delim">
                   <tab/>
                </span>
                <semx element="title" source="_">Annex</semx>
             </variant-title>
          </annex>
          <annex id="A7" obligation="normative" autonum="G" displayorder="9">
             <title id="_">Annex</title>
             <fmt-title id="_">
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
             <variant-title type="toc">
                <span class="fmt-caption-label">
                   <span class="fmt-element-name">Annex</span>
                   <semx element="autonum" source="A7">G</semx>
                </span>
                <span class="fmt-caption-delim">
                   <tab/>
                </span>
                <semx element="title" source="_">Annex</semx>
             </variant-title>
          </annex>
          <annex id="A8" obligation="normative" autonum="H" displayorder="10">
             <title id="_">Annex</title>
             <fmt-title id="_">
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
             <variant-title type="toc">
                <span class="fmt-caption-label">
                   <span class="fmt-element-name">Annex</span>
                   <semx element="autonum" source="A8">H</semx>
                </span>
                <span class="fmt-caption-delim">
                   <tab/>
                </span>
                <semx element="title" source="_">Annex</semx>
             </variant-title>
          </annex>
          <annex id="A9" obligation="normative" autonum="J" displayorder="11">
             <title id="_">Annex</title>
             <fmt-title id="_">
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
             <variant-title type="toc">
                <span class="fmt-caption-label">
                   <span class="fmt-element-name">Annex</span>
                   <semx element="autonum" source="A9">J</semx>
                </span>
                <span class="fmt-caption-delim">
                   <tab/>
                </span>
                <semx element="title" source="_">Annex</semx>
             </variant-title>
          </annex>
          <annex id="A10" obligation="normative" autonum="K" displayorder="12">
             <title id="_">Annex</title>
             <fmt-title id="_">
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
             <variant-title type="toc">
                <span class="fmt-caption-label">
                   <span class="fmt-element-name">Annex</span>
                   <semx element="autonum" source="A10">K</semx>
                </span>
                <span class="fmt-caption-delim">
                   <tab/>
                </span>
                <semx element="title" source="_">Annex</semx>
             </variant-title>
          </annex>
          <annex id="B1" obligation="informative" autonum="I" displayorder="13">
             <title id="_">Annex</title>
             <fmt-title id="_">
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
             <variant-title type="toc">
                <span class="fmt-caption-label">
                   <span class="fmt-element-name">Appendix</span>
                   <semx element="autonum" source="B1">I</semx>
                </span>
                <span class="fmt-caption-delim">
                   <tab/>
                </span>
                <semx element="title" source="_">Annex</semx>
             </variant-title>
          </annex>
          <annex id="B2" obligation="informative" autonum="II" displayorder="14">
             <title id="_">Annex</title>
             <fmt-title id="_">
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
             <variant-title type="toc">
                <span class="fmt-caption-label">
                   <span class="fmt-element-name">Appendix</span>
                   <semx element="autonum" source="B2">II</semx>
                </span>
                <span class="fmt-caption-delim">
                   <tab/>
                </span>
                <semx element="title" source="_">Annex</semx>
             </variant-title>
          </annex>
          <annex id="B3" obligation="informative" autonum="III" displayorder="15">
             <title id="_">Annex</title>
             <fmt-title id="_">
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
             <variant-title type="toc">
                <span class="fmt-caption-label">
                   <span class="fmt-element-name">Appendix</span>
                   <semx element="autonum" source="B3">III</semx>
                </span>
                <span class="fmt-caption-delim">
                   <tab/>
                </span>
                <semx element="title" source="_">Annex</semx>
             </variant-title>
          </annex>
          <annex id="B4" obligation="informative" autonum="IV" displayorder="16">
             <title id="_">Annex</title>
             <fmt-title id="_">
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
             <variant-title type="toc">
                <span class="fmt-caption-label">
                   <span class="fmt-element-name">Appendix</span>
                   <semx element="autonum" source="B4">IV</semx>
                </span>
                <span class="fmt-caption-delim">
                   <tab/>
                </span>
                <semx element="title" source="_">Annex</semx>
             </variant-title>
          </annex>
          <annex id="B5" obligation="informative" autonum="V" displayorder="17">
             <title id="_">Annex</title>
             <fmt-title id="_">
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
             <variant-title type="toc">
                <span class="fmt-caption-label">
                   <span class="fmt-element-name">Appendix</span>
                   <semx element="autonum" source="B5">V</semx>
                </span>
                <span class="fmt-caption-delim">
                   <tab/>
                </span>
                <semx element="title" source="_">Annex</semx>
             </variant-title>
          </annex>
          <annex id="B6" obligation="informative" autonum="VI" displayorder="18">
             <title id="_">Annex</title>
             <fmt-title id="_">
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
             <variant-title type="toc">
                <span class="fmt-caption-label">
                   <span class="fmt-element-name">Appendix</span>
                   <semx element="autonum" source="B6">VI</semx>
                </span>
                <span class="fmt-caption-delim">
                   <tab/>
                </span>
                <semx element="title" source="_">Annex</semx>
             </variant-title>
          </annex>
          <annex id="B7" obligation="informative" autonum="VII" displayorder="19">
             <title id="_">Annex</title>
             <fmt-title id="_">
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
             <variant-title type="toc">
                <span class="fmt-caption-label">
                   <span class="fmt-element-name">Appendix</span>
                   <semx element="autonum" source="B7">VII</semx>
                </span>
                <span class="fmt-caption-delim">
                   <tab/>
                </span>
                <semx element="title" source="_">Annex</semx>
             </variant-title>
          </annex>
          <annex id="B8" obligation="informative" autonum="VIII" displayorder="20">
             <title id="_">Annex</title>
             <fmt-title id="_">
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
             <variant-title type="toc">
                <span class="fmt-caption-label">
                   <span class="fmt-element-name">Appendix</span>
                   <semx element="autonum" source="B8">VIII</semx>
                </span>
                <span class="fmt-caption-delim">
                   <tab/>
                </span>
                <semx element="title" source="_">Annex</semx>
             </variant-title>
          </annex>
          <annex id="B9" obligation="informative" autonum="IX" displayorder="21">
             <title id="_">Annex</title>
             <fmt-title id="_">
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
             <variant-title type="toc">
                <span class="fmt-caption-label">
                   <span class="fmt-element-name">Appendix</span>
                   <semx element="autonum" source="B9">IX</semx>
                </span>
                <span class="fmt-caption-delim">
                   <tab/>
                </span>
                <semx element="title" source="_">Annex</semx>
             </variant-title>
          </annex>
          <annex id="B10" obligation="informative" autonum="X" displayorder="22">
             <title id="_">Annex</title>
             <fmt-title id="_">
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
             <variant-title type="toc">
                <span class="fmt-caption-label">
                   <span class="fmt-element-name">Appendix</span>
                   <semx element="autonum" source="B10">X</semx>
                </span>
                <span class="fmt-caption-delim">
                   <tab/>
                </span>
                <semx element="title" source="_">Annex</semx>
             </variant-title>
          </annex>
       </metanorma>
    OUTPUT
    html = <<~OUTPUT
              #{HTML_HDR}
              <br/>
             <div id="_">
                <h1 class="AbstractTitle">Abstract</h1>
                <a href="#A1">Annex A</a>
                <a href="#B1">Appendix I</a>
             </div>
             <br/>
             <div id="A1" class="Section3">
                <h1 class="Annex">
                   <b>Annex A</b>
                   <br/>
                   <br/>
                   <b>Annex</b>
                </h1>
                <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
                <p style="display:none;" class="variant-title-toc">Annex A  Annex</p>
             </div>
             <br/>
             <div id="A2" class="Section3">
                <h1 class="Annex">
                   <b>Annex B</b>
                   <br/>
                   <br/>
                   <b>Annex</b>
                </h1>
                <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
                <p style="display:none;" class="variant-title-toc">Annex B  Annex</p>
             </div>
             <br/>
             <div id="A3" class="Section3">
                <h1 class="Annex">
                   <b>Annex C</b>
                   <br/>
                   <br/>
                   <b>Annex</b>
                </h1>
                <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
                <p style="display:none;" class="variant-title-toc">Annex C  Annex</p>
             </div>
             <br/>
             <div id="A4" class="Section3">
                <h1 class="Annex">
                   <b>Annex D</b>
                   <br/>
                   <br/>
                   <b>Annex</b>
                </h1>
                <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
                <p style="display:none;" class="variant-title-toc">Annex D  Annex</p>
             </div>
             <br/>
             <div id="A5" class="Section3">
                <h1 class="Annex">
                   <b>Annex E</b>
                   <br/>
                   <br/>
                   <b>Annex</b>
                </h1>
                <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
                <p style="display:none;" class="variant-title-toc">Annex E  Annex</p>
             </div>
             <br/>
             <div id="A6" class="Section3">
                <h1 class="Annex">
                   <b>Annex F</b>
                   <br/>
                   <br/>
                   <b>Annex</b>
                </h1>
                <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
                <p style="display:none;" class="variant-title-toc">Annex F  Annex</p>
             </div>
             <br/>
             <div id="A7" class="Section3">
                <h1 class="Annex">
                   <b>Annex G</b>
                   <br/>
                   <br/>
                   <b>Annex</b>
                </h1>
                <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
                <p style="display:none;" class="variant-title-toc">Annex G  Annex</p>
             </div>
             <br/>
             <div id="A8" class="Section3">
                <h1 class="Annex">
                   <b>Annex H</b>
                   <br/>
                   <br/>
                   <b>Annex</b>
                </h1>
                <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
                <p style="display:none;" class="variant-title-toc">Annex H  Annex</p>
             </div>
             <br/>
             <div id="A9" class="Section3">
                <h1 class="Annex">
                   <b>Annex J</b>
                   <br/>
                   <br/>
                   <b>Annex</b>
                </h1>
                <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
                <p style="display:none;" class="variant-title-toc">Annex J  Annex</p>
             </div>
             <br/>
             <div id="A10" class="Section3">
                <h1 class="Annex">
                   <b>Annex K</b>
                   <br/>
                   <br/>
                   <b>Annex</b>
                </h1>
                <p class="annex_obligation">(This annex forms an integral part of this Recommendation.)</p>
                <p style="display:none;" class="variant-title-toc">Annex K  Annex</p>
             </div>
             <br/>
             <div id="B1" class="Section3">
                <h1 class="Annex">
                   <b>Appendix I</b>
                   <br/>
                   <br/>
                   <b>Annex</b>
                </h1>
                <p class="annex_obligation">(This appendix does not form an integral part of this Recommendation.)</p>
                <p style="display:none;" class="variant-title-toc">Appendix I  Annex</p>
             </div>
             <br/>
             <div id="B2" class="Section3">
                <h1 class="Annex">
                   <b>Appendix II</b>
                   <br/>
                   <br/>
                   <b>Annex</b>
                </h1>
                <p class="annex_obligation">(This appendix does not form an integral part of this Recommendation.)</p>
                <p style="display:none;" class="variant-title-toc">Appendix II  Annex</p>
             </div>
             <br/>
             <div id="B3" class="Section3">
                <h1 class="Annex">
                   <b>Appendix III</b>
                   <br/>
                   <br/>
                   <b>Annex</b>
                </h1>
                <p class="annex_obligation">(This appendix does not form an integral part of this Recommendation.)</p>
                <p style="display:none;" class="variant-title-toc">Appendix III  Annex</p>
             </div>
             <br/>
             <div id="B4" class="Section3">
                <h1 class="Annex">
                   <b>Appendix IV</b>
                   <br/>
                   <br/>
                   <b>Annex</b>
                </h1>
                <p class="annex_obligation">(This appendix does not form an integral part of this Recommendation.)</p>
                <p style="display:none;" class="variant-title-toc">Appendix IV  Annex</p>
             </div>
             <br/>
             <div id="B5" class="Section3">
                <h1 class="Annex">
                   <b>Appendix V</b>
                   <br/>
                   <br/>
                   <b>Annex</b>
                </h1>
                <p class="annex_obligation">(This appendix does not form an integral part of this Recommendation.)</p>
                <p style="display:none;" class="variant-title-toc">Appendix V  Annex</p>
             </div>
             <br/>
             <div id="B6" class="Section3">
                <h1 class="Annex">
                   <b>Appendix VI</b>
                   <br/>
                   <br/>
                   <b>Annex</b>
                </h1>
                <p class="annex_obligation">(This appendix does not form an integral part of this Recommendation.)</p>
                <p style="display:none;" class="variant-title-toc">Appendix VI  Annex</p>
             </div>
             <br/>
             <div id="B7" class="Section3">
                <h1 class="Annex">
                   <b>Appendix VII</b>
                   <br/>
                   <br/>
                   <b>Annex</b>
                </h1>
                <p class="annex_obligation">(This appendix does not form an integral part of this Recommendation.)</p>
                <p style="display:none;" class="variant-title-toc">Appendix VII  Annex</p>
             </div>
             <br/>
             <div id="B8" class="Section3">
                <h1 class="Annex">
                   <b>Appendix VIII</b>
                   <br/>
                   <br/>
                   <b>Annex</b>
                </h1>
                <p class="annex_obligation">(This appendix does not form an integral part of this Recommendation.)</p>
                <p style="display:none;" class="variant-title-toc">Appendix VIII  Annex</p>
             </div>
             <br/>
             <div id="B9" class="Section3">
                <h1 class="Annex">
                   <b>Appendix IX</b>
                   <br/>
                   <br/>
                   <b>Annex</b>
                </h1>
                <p class="annex_obligation">(This appendix does not form an integral part of this Recommendation.)</p>
                <p style="display:none;" class="variant-title-toc">Appendix IX  Annex</p>
             </div>
             <br/>
             <div id="B10" class="Section3">
                <h1 class="Annex">
                   <b>Appendix X</b>
                   <br/>
                   <br/>
                   <b>Annex</b>
                </h1>
                <p class="annex_obligation">(This appendix does not form an integral part of this Recommendation.)</p>
                <p style="display:none;" class="variant-title-toc">Appendix X  Annex</p>
             </div>
          </div>
       </body>
    OUTPUT
    pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(pres_output
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_xml_equivalent_to presxml
    expect(strip_guid(IsoDoc::Itu::HtmlConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>")))
      .to be_xml_equivalent_to html
  end

  it "generates middle title for joint ISO/IEC/ITU common text" do
    input = <<~INPUT
             <metanorma xmlns="http://riboseinc.com/isoxml">
             <bibdata type="standard">
             <title language="en" format="text/plain" type="main">An ITU Standard</title>
             <title language="fr" format="text/plain" type="main">Un Standard ITU</title>
             <docidentifier type="ITU">12345</docidentifier>
             <docidentifier type="ISO">ISO/IEC 99999</docidentifier>
             <language>en</language>
             <script>Latn</script>
             <keyword>A</keyword>
             <keyword>B</keyword>
             <ext>
             <doctype>recommendation</doctype>
             <flavor>itu</flavor>
             </ext>
             </bibdata>
    <preface>
    <abstract><title>Abstract</title>
    <p>This is an abstract</p>
    </abstract>
    <clause id="A0"><title>History</title>
    <p>history</p>
    </clause>
    <foreword obligation="informative">
       <title>Foreword</title>
       <p id="A">This is a preamble</p>
     </foreword>
      <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
       <title>Introduction Subsection</title>
     </clause>
     </introduction></preface><sections>
     <clause id="D" obligation="normative" type="scope">
       <title>Scope</title>
       <p id="E">Text</p>
     </clause>
     </sections>
     </metanorma>
    INPUT
    presxml = <<~OUTPUT
           <metanorma xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata type="standard">
             <title language="en" format="text/plain" type="main">An ITU Standard</title>
             <title language="fr" format="text/plain" type="main">Un Standard ITU</title>
             <docidentifier type="ITU">12345</docidentifier>
             <docidentifier type="ISO">ISO/IEC 99999</docidentifier>
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
                <fmt-title depth="1" id="_">Table of Contents</fmt-title>
             </clause>
             <abstract id="_" displayorder="2">
                <title id="_">Abstract</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Abstract</semx>
                </fmt-title>
                <p>This is an abstract</p>
             </abstract>
             <clause id="_" type="keyword" displayorder="3">
                <fmt-title id="_" depth="1">Keywords</fmt-title>
                <p>A, B.</p>
             </clause>
             <foreword obligation="informative" id="_" displayorder="4">
                <title id="_">Foreword</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <p id="A">This is a preamble</p>
             </foreword>
             <introduction id="B" obligation="informative" displayorder="5">
                <title id="_">Introduction</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Introduction</semx>
                </fmt-title>
                <clause id="C" inline-header="false" obligation="informative">
                   <title id="_">Introduction Subsection</title>
                   <fmt-title depth="2" id="_">
                      <semx element="title" source="_">Introduction Subsection</semx>
                   </fmt-title>
                </clause>
             </introduction>
             <clause id="A0" displayorder="6">
                <title id="_">History</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">History</semx>
                </fmt-title>
                <p>history</p>
             </clause>
          </preface>
          <sections>
             <p class="zzSTDTitle1" displayorder="7">International Standard ISO/IEC 99999</p>
             <p class="zzSTDTitle1" displayorder="8">Recommendation 12345</p>
             <p class="zzSTDTitle2" displayorder="9">An ITU Standard</p>
             <clause id="D" obligation="normative" type="scope" displayorder="10">
                <title id="_">Scope</title>
                <fmt-title depth="1" id="_">
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
          </sections>
       </metanorma>
    OUTPUT
     pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(pres_output
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_xml_equivalent_to presxml
  end

  it "processes history tables (Word)" do
    FileUtils.rm_f "test.doc"
    IsoDoc::Itu::WordConvert.new({}).convert("test", <<~INPUT, false)
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface><clause id="_history" obligation="normative" displayorder="1">
        <fmt-title id="_">History</fmt-title>
        <table id="_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4">
        <fmt-name id="_">Table 1</fmt-name>
        <tbody>
          <tr id="_">
            <td id="_" align="left">Edition</td>
            <td id="_" align="left">Recommendation</td>
            <td id="_" align="left">Approval</td>
            <td id="_" align="left">Study Group</td>
            <td id="_" align="left">Unique ID<fn reference="a)" id="F1" target="FF1">
        <p original-id="_8a4ff03f-e7a6-4430-939d-1b7b0ffa60e9">To access the Recommendation, type the URL <fmt-link target="http://handle.itu.int/"/> in the address field of your web browser, followed by the Recommendation?~@~Ys unique ID. For example, <fmt-link target="http://handle.itu.int/11.1002/1000/11830-en"/></p><fmt-fn-label><semx source="F1">a)</semx></fmt-fn-label>
      </fn>.</td>
          </tr>
      <tr id="_">
            <td id="_" align="left">1.0</td>
            <td id="_" align="left">ITU-T G.650</td>
            <td id="_" align="left">1993-03-12</td>
            <td id="_" align="left">XV</td>
            <td id="_" align="left">
              <fmt-link target="http://handle.itu.int/11.1002/1000/879">11.1002/1000/879</link>
            </td>
          </tr>
          </tbody>
          <fmt-footnote-container>
          <fmt-fn-body id="FF1"><fmt-fn-label><semx source="F1">a)</semx></fmt-fn-label>
            <p id="_8a4ff03f-e7a6-4430-939d-1b7b0ffa60e9">To access the Recommendation, type the URL <fmt-link target="http://handle.itu.int/"/> in the address field of your web browser, followed by the Recommendation?~@~Ys unique ID. For example, <fmt-link target="http://handle.itu.int/11.1002/1000/11830-en"/></p>
          </fmt-fn-body>
          </fmt-footnote-container>
          </table>
          </clause>
          </preface>
          </iso-standard>
    INPUT
    expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc", encoding: "UTF-8")
    expect(html
      .gsub(%r{.*<p class="h1Preface">History</p>}m,
            '<div><p class="h1Preface">History</p>')
      .sub(%r{</table>.*$}m, "</table></div></div>"))
      .to be_xml_equivalent_to <<~OUTPUT
       <div>
          <p class="h1Preface">History</p>
          <p class="TableTitle" style="text-align:center;">Table 1</p>
          <div align="center" class="table_container">
             <table class="MsoNormalTable" style="mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;">
                <a name="_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4" id="_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4"/>
                <tbody>
                   <tr>
                      <td valign="top" align="left" style="">Edition</td>
                      <td valign="top" align="left" style="">Recommendation</td>
                      <td valign="top" align="left" style="">Approval</td>
                      <td valign="top" align="left" style="">Study Group</td>
                      <td valign="top" align="left" style="">
                         Unique ID
                         <a href="#_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4a)" class="TableFootnoteRef">a)</a>
                         .
                      </td>
                   </tr>
                   <tr>
                      <td valign="top" align="left" style="">1.0</td>
                      <td valign="top" align="left" style="">ITU-T G.650</td>
                      <td valign="top" align="left" style="">1993-03-12</td>
                      <td valign="top" align="left" style="">XV</td>
                      <td valign="top" align="left" style="">
                         <a href="http://handle.itu.int/11.1002/1000/879">11.1002/1000/879</a>
                      </td>
                   </tr>
                </tbody>
                <tfoot>
                   <tr>
                      <td colspan="5" style="">
                         <div class="TableFootnote">
                            <a name="ftn_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4a)" id="ftn_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4a)"/>
                            <span class="TableFootnoteRef">a)</span>
                            <p class="TableFootnote">
                               <a name="_8a4ff03f-e7a6-4430-939d-1b7b0ffa60e9" id="_8a4ff03f-e7a6-4430-939d-1b7b0ffa60e9"/>
                               To access the Recommendation, type the URL
                               <a href="http://handle.itu.int/">http://handle.itu.int/</a>
                               in the address field of your web browser, followed by the Recommendation?~@~Ys unique ID. For example,
                               <a href="http://handle.itu.int/11.1002/1000/11830-en">http://handle.itu.int/11.1002/1000/11830-en</a>
                            </p>
                         </div>
                      </td>
                   </tr>
                </tfoot>
             </table>
          </div>
       </div>
      OUTPUT
  end

  it "processes editor clauses, one editor" do
    input = <<~INPUT
      <metanorma xmlns="http://riboseinc.com/isoxml">
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
      </metanorma>
    INPUT
    presxml = <<~OUTPUT
      <preface>
        <clause type="toc" id="_" displayorder="1"> 
        <fmt-title id="_" depth="1">Table of Contents</fmt-title>
          </clause>
         <clause id='_' type='editors' displayorder='2'>
           <table id="_" id='_' unnumbered='true'>
             <tbody>
               <tr id="_">
                 <th id="_">Editor:</th>
                 <td id="_">
                   Fred Flintstone
                   <br/>
                   World Health Organization
                 </td>
                 <td id="_">
                   E-mail:
                                     <link target="mailto:jack@example.com" id="_">jack@example.com</link>
                  <semx element="link" source="_">
                     <fmt-link target="mailto:jack@example.com">jack@example.com</fmt-link>
                  </semx>
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
    expect(strip_guid(xml))
      .to be_xml_equivalent_to presxml
  end

  it "processes editor clauses, two editors" do
    input = <<~INPUT
      <metanorma xmlns="http://riboseinc.com/isoxml">
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
      </metanorma>
    INPUT
    presxml = <<~OUTPUT
      <preface>
         <clause id='_' type='editors' displayorder='1'>
           <table id="_" id='_' unnumbered='true'>
             <tbody>
               <tr id="_">
                 <th id="_">Editors:</th>
                 <td id="_">
                   Fred Flintstone
                   <br/>
                   World Health Organization
                 </td>
                 <td id="_">
                   E-mail:
                   <link target="mailto:jack@example.com" id="_">jack@example.com</link>
                  <semx element="link" source="_">
                     <fmt-link target="mailto:jack@example.com">jack@example.com</fmt-link>
                  </semx>
                 </td>
               </tr>
               <tr id="_">
                 <th id="_"/>
                 <td id="_">Barney Rubble</td>
                 <td id="_"/>
               </tr>
             </tbody>
           </table>
         </clause>
       </preface>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::Itu::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
    xml = xml.at("//xmlns:preface").to_xml
    expect(strip_guid(xml))
      .to be_xml_equivalent_to presxml
  end

  it "generates contribution prefatory table and abstract table" do
    logoloc = File.expand_path(
      File.join(File.dirname(__FILE__), "..", "..", "lib", "isodoc", "itu",
                "html"),
    )
    input = <<~INPUT
      <metanorma xmlns='https://www.metanorma.org/ns/itu' type='semantic'>
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
                <role type="author">
                   <description>committee</description>
                </role>
                <organization>
                   <name>International Telecommunication Union</name>
                   <subdivision type="Bureau">
                      <name>R</name>
                   </subdivision>
                   <subdivision type="Sector">
                      <name>Sector</name>
                   </subdivision>
                   <subdivision type="Group" subtype="A">
                      <name>Study Group 17</name>
                      <identifier>C</identifier>
                   </subdivision>
                   <subdivision type="Subgroup" subtype="A1">
                      <name>I1</name>
                      <identifier>C1</identifier>
                   </subdivision>
                   <subdivision type="Workgroup" subtype="A2">
                      <name>I2</name>
                      <identifier>C2</identifier>
                   </subdivision>
                   <abbreviation>ITU</abbreviation>
                </organization>
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
            <recommendationstatus>
                <from>D3</from>
                <to>E3</to>
                <approvalstage process='F3'>G3</approvalstage>
              </recommendationstatus>
              <ip-notice-received>false</ip-notice-received>
              <studyperiod>
           <start>2000</start>
           <end>2002</end>
        </studyperiod>
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
        </metanorma>
    INPUT
    presxml = <<~OUTPUT
        <metanorma>
           <preface>
              <clause unnumbered="true" type="contribution-metadata" displayorder="1" id="_">
                 <table id="_" class="contribution-metadata" unnumbered="true" width="100%">
                    <colgroup>
                       <col width="11.8%"/>
                       <col width="41.2%"/>
                       <col width="47.0%"/>
                    </colgroup>
                    <thead>
                       <tr id="_">
                          <th id="_" rowspan="3">
                             <image height="56" width="56" src="#{logoloc}/logo-small.png"/>
                          </th>
                          <td id="_" rowspan="3">
                             <p style="font-size:8pt;margin-top:6pt;margin-bottom:0pt;">INTERNATIONAL TELECOMMUNICATION UNION</p>
                             <p class="bureau_big" style="font-size:13pt;margin-top:6pt;margin-bottom:0pt;">
                                <strong>RADIOCOMMUNICATION BUREAU</strong>
                                <br/>
                                <strong>OF ITU</strong>
                             </p>
                             <p style="font-size:10pt;margin-top:6pt;margin-bottom:0pt;">STUDY PERIOD 2000–2002</p>
                          </td>
                          <th id="_" align="right">
                             <p style="font-size:16pt;">SG17-C1000</p>
                          </th>
                       </tr>
                       <tr id="_">
                          <th id="_" align="right">
                             <p style="font-size:14pt;">STUDY GROUP 17</p>
                          </th>
                       </tr>
                       <tr id="_">
                          <th id="_" align="right">
                             <p style="font-size:14pt;">Original: English</p>
                          </th>
                       </tr>
                    </thead>
                    <tbody>
                       <tr id="_">
                          <th id="_" align="left" width="95">Question(s):</th>
                          <td id="_"/>
                          <td id="_" align="right">Kronos, 01 Jan 2000/02 Jan 2000</td>
                       </tr>
                       <tr id="_">
                          <th id="_" align="center" colspan="3">CONTRIBUTION</th>
                       </tr>
                       <tr id="_">
                          <th id="_" align="left" width="95">Source:</th>
                          <td id="_" colspan="2">Source1</td>
                       </tr>
                       <tr id="_">
                          <th id="_" align="left" width="95">Title:</th>
                          <td id="_" colspan="2">Main Title</td>
                       </tr>
                       <tr id="_">
                          <th id="_" align="left" width="95">Contact:</th>
                          <td id="_">
                             Fred Flintstone
                             <br/>
                             Bedrock Quarry
                             <br/>
                             Canada
                          </td>
                          <td id="_">
                             Tel.
                             <tab/>
                             555
                             <br/>
                             E-mail
                             <tab/>
                             x@example.com
                          </td>
                       </tr>
                       <tr id="_">
                          <th id="_" align="left" width="95">Contact:</th>
                          <td id="_">
                             Barney Rubble
                             <br/>
                             Bedrock Quarry 2
                             <br/>
                             USA
                          </td>
                          <td id="_">
                             Tel.
                             <tab/>
                             557
                          </td>
                       </tr>
                    </tbody>
                 </table>
              </clause>
              <abstract id="A" displayorder="2">
                 <table id="_" class="abstract" unnumbered="true" width="100%">
                    <colgroup>
                       <col width="11.8%"/>
                       <col width="78.2%"/>
                    </colgroup>
                    <tbody>
                       <tr id="_">
                          <th id="_" align="left" width="95">
                             <p>Abstract:</p>
                          </th>
                          <td id="_">
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
                 <fmt-title id="_" depth="1">
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
             <title id="_">Annex</title>
             <fmt-title id="_">
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
                   <variant-title type="toc">
         <span class="fmt-caption-label">
            <span class="fmt-element-name">Annex</span>
            <semx element="autonum" source="A1">A</semx>
         </span>
         <span class="fmt-caption-delim">
            <tab/>
         </span>
         <semx element="title" source="_">Annex</semx>
      </variant-title>
          </annex>
          <annex id="A2" type="justification" autonum="B" displayorder="5">
             <title id="_">A.13 justification for proposed draft new  SG17-C1000 “Main Title”</title>
             <fmt-title id="_">
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
             <variant-title type="toc">
         <span class="fmt-caption-label">
            <span class="fmt-element-name">Annex</span>
            <semx element="autonum" source="A2">B</semx>
         </span>
         <span class="fmt-caption-delim">
            <tab/>
         </span>
         <semx element="title" source="_">A.13 justification for proposed draft new  SG17-C1000 “Main Title”</semx>
      </variant-title>
             <table id="_" class="contribution-metadata" unnumbered="true" width="100%">
                <colgroup>
                   <col width="15.9%"/>
                   <col width="6.1%"/>
                   <col width="45.5%"/>
                   <col width="17.4%"/>
                   <col width="15.1%"/>
                </colgroup>
                <tbody>
                   <tr id="_">
                      <th id="_" align="left">Question(s):</th>
                      <td id="_"/>
                      <th id="_" align="left">Proposed new ITU-T </th>
                      <td id="_" colspan="2">Kronos, 01 Jan 2000/02 Jan 2000</td>
                   </tr>
                   <tr id="_">
                      <th id="_" align="left">Reference and title:</th>
                      <td id="_" colspan="4">Draft new  on “Main Title”</td>
                   </tr>
                   <tr id="_">
                      <th id="_" align="left">Base text:</th>
                      <td id="_" colspan="2"/>
                      <th id="_" align="left">Timing:</th>
                      <td id="_">2025-Q4</td>
                   </tr>
                   <tr id="_">
                      <th id="_" align="left" rowspan="1">Editor(s):</th>
                      <td id="_" colspan="2">
                         Fred Flintstone
                         <br/>
                         Bedrock Quarry
                         <br/>
                         Canada, E-mail
                         <tab/>
                         x@example.com
                      </td>
                      <th id="_" align="left" rowspan="1">Approval process:</th>
                      <td id="_" rowspan="1">F3</td>
                   </tr>
                   <tr id="_">
                      <td id="_" colspan="2">
                         Barney Rubble
                         <br/>
                         Bedrock Quarry 2
                         <br/>
                         USA
                      </td>
                   </tr>
                   <tr id="_">
                      <td id="_" colspan="5">
                         <p>
                            <strong>Scope</strong>
                            (defines the intent or object of the Recommendation and the aspects covered, thereby indicating the limits of its applicability):
                         </p>
                      </td>
                   </tr>
                   <tr id="_">
                      <td id="_" colspan="5">
                         <p>
                            <strong>Summary</strong>
                            (provides a brief overview of the purpose and contents of the Recommendation, thus permitting readers to judge its usefulness for their work):
                         </p>
                      </td>
                   </tr>
                   <tr id="_">
                      <td id="_" colspan="5">
                         <p>
                            <strong>Relations to ITU-T Recommendations or to other standards</strong>
                            (approved or under development):
                         </p>
                      </td>
                   </tr>
                   <tr id="_">
                      <td id="_" colspan="5">
                         <p>
                            <strong>Liaisons with other study groups or with other standards bodies:</strong>
                         </p>
                      </td>
                   </tr>
                   <tr id="_">
                      <td id="_" colspan="5">
                         <p>
                            <strong>Supporting members that are committing to contributing actively to the work item:</strong>
                         </p>
                      </td>
                   </tr>
                </tbody>
             </table>
          </annex>
       </metanorma>
    OUTPUT

    xml = Nokogiri::XML(IsoDoc::Itu::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
    xml = xml.xpath("//xmlns:preface | //xmlns:sections | //xmlns:annex").to_xml
    expect(strip_guid("<metanorma>#{xml}</itu-standard>"))
      .to be_xml_equivalent_to presxml

    presxml = <<~OUTPUT
      <preface>
         <clause unnumbered="true" type="contribution-metadata" displayorder="1" id="_">
           <table id="_" class="contribution-metadata" unnumbered="true" width="100%">
             <colgroup>
               <col width="11.8%"/>
               <col width="41.2%"/>
               <col width="47.0%"/>
             </colgroup>
             <thead>
               <tr id="_">
                 <th id="_" rowspan="3">
                   <image height="56" width="56" src="#{File.join(logoloc, '/logo-small.png')}"/>
                 </th>
                 <td id="_" rowspan="3">
                   <p style="font-size:8pt;margin-top:6pt;margin-bottom:0pt;">UNION INTERNATIONALE DES TÉLÉCOMMUNICATIONS</p>
                   <p class="bureau_big" style="font-size:13pt;margin-top:6pt;margin-bottom:0pt;">
                     <strong>BUREAU DES RADIOCOMMUNICATIONS</strong>
                     <br/>
                     <strong>DE L’UIT</strong>
                   </p>
                   <p style="font-size:10pt;margin-top:6pt;margin-bottom:0pt;">PÉRIODE D’ÉTUDES 2000–2002</p>
                 </td>
                 <th id="_" align="right">
                   <p style="font-size:16pt;">SG17-C1000</p>
                 </th>
               </tr>
               <tr id="_">
                 <th id="_" align="right">
                   <p style="font-size:14pt;">STUDY GROUP 17</p>
                 </th>
               </tr>
               <tr id="_">
                 <th id="_" align="right">
                   <p style="font-size:14pt;">Original : Français</p>
                 </th>
               </tr>
             </thead>
                         <tbody>
               <tr id="_">
                 <th id="_" align="left" width="95">Question(s):</th>
                 <td id="_"/>
                 <td id="_" align="right">Kronos, 01 janv. 2000/02 janv. 2000</td>
               </tr>
               <tr id="_">
                 <th id="_" align="center" colspan="3">CONTRIBUTION</th>
               </tr>
               <tr id="_">
                 <th id="_" align="left" width="95">Source :</th>
                 <td id="_" colspan="2">Source1</td>
               </tr>
               <tr id="_">
                 <th id="_" align="left" width="95">Titre :</th>
                 <td id="_" colspan="2">Main Title</td>
               </tr>
               <tr id="_">
                 <th id="_" align="left" width="95">Contact :</th>
                 <td id="_">Fred Flintstone<br/>
       Bedrock Quarry<br/>
       Canada</td>
                 <td id="_">Tél.<tab/>555<br/>E-mail<tab/>x@example.com</td>
               </tr>
               <tr id="_">
                 <th id="_" align="left" width="95">Contact :</th>
                 <td id="_">Barney Rubble<br/>
       Bedrock Quarry 2<br/>
       USA</td>
                 <td id="_">Tél.<tab/>557</td>
               </tr>
             </tbody>
           </table>
         </clause>
         <abstract id="A" displayorder="2">
           <table id="_" class="abstract" unnumbered="true" width="100%">
             <colgroup>
               <col width="11.8%"/>
               <col width="78.2%"/>
             </colgroup>
             <tbody>
               <tr id="_">
                 <th id="_" align="left" width="95">
                   <p>Résumé :</p>
                 </th>
                 <td id="_">
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
    expect(strip_guid(xml))
      .to be_xml_equivalent_to presxml
  end
end

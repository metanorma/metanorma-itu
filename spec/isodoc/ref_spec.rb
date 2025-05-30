require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc::Itu do
  it "processes IsoXML bibliographies (1)" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>en</language>
          </bibdata>
          <preface><foreword>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
        <eref bibitemid="ISO712"/>
        <eref bibitemid="ISBN"/>
        <eref bibitemid="ISSN"/>
        <eref bibitemid="ISO16634"/>
        <eref bibitemid="ref1"/>
        <eref bibitemid="ref10"/>
        <eref bibitemid="ref12"/>
        <eref bibitemid="zip_ffs"/>
        </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
          <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="ISO">ISO 712</docidentifier>
        <docidentifier type="metanorma">[110]</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ISO16634" type="standard">
        <title language="x" format="text/plain">Cereals, pulses, milled cereal products, xxxx, oilseeds and animal feeding stuffs</title>
        <title language="en" format="text/plain">Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</title>
        <docidentifier type="ISO">ISO 16634:-- (all parts)</docidentifier>
        <date type="published"><on>--</on></date>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
        <extent type="part">
        <referenceFrom>all</referenceFrom>
        </extent>
      </bibitem>
      <bibitem id="ISO20483" type="standard">
        <title format="text/plain">Cereals and pulses</title>
        <docidentifier type="ISO">ISO 20483:2013-2014</docidentifier>
        <date type="published"><from>2013</from><to>2014</to></date>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ref1">
        <formattedref format="application/x-isodoc+xml"><smallcap>Standard No I.C.C 167</smallcap>. <em>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</em> (see <link target="http://www.icc.or.at"/>)</formattedref>
        <docidentifier type="ICC">167</docidentifier>
      </bibitem>
      <note><p>This is an annotation of ISO 20483:2013-2014</p></note>
          <bibitem id="zip_ffs"><formattedref format="application/x-isodoc+xml">Title 5</formattedref><docidentifier type="metanorma">[5]</docidentifier></bibitem>
      </references><references id="_bibliography" obligation="informative" normative="false">
        <title>Bibliography</title>
      <bibitem id="ISBN" type="book">
        <title format="text/plain">Chemicals for analytical laboratory use</title>
        <docidentifier type="ISBN">ISBN</docidentifier>
        <docidentifier type="metanorma">[3]</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISBN</abbreviation>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ISSN" type="journal">
        <title format="text/plain">Instruments for analytical laboratory use</title>
        <docidentifier type="ISSN">1</docidentifier>
        <docidentifier type="metanorma">[4]</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISSN</abbreviation>
          </organization>
        </contributor>
      </bibitem>
      <note><p>This is an annotation of document ISSN.</p></note>
      <note><p>This is another annotation of document ISSN.</p></note>
      <bibitem id="ISO3696" type="standard">
        <title format="text/plain">Water for analytical laboratory use</title>
        <docidentifier type="ISO">ISO 3696</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ref10">
        <formattedref format="application/x-isodoc+xml"><smallcap>Standard No I.C.C 167</smallcap>. <em>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</em> (see <link target="http://www.icc.or.at"/>)</formattedref>
        <docidentifier type="metanorma">[10]</docidentifier>
      </bibitem>
      <bibitem id="ref11">
        <title>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</title>
        <docidentifier type="IETF">RFC 10</docidentifier>
      </bibitem>
      <bibitem id="ref12">
        <formattedref format="application/x-isodoc+xml">CitationWorks. 2019. <em>How to cite a reference</em>.</formattedref>
        <docidentifier type="metanorma">[Citn]</docidentifier>
        <docidentifier type="IETF">RFC 20</docidentifier>
      </bibitem>
      </references>
      </bibliography>
          </iso-standard>
    INPUT

    presxml = <<~OUTPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata>
             <language current="true">en</language>
          </bibdata>
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Table of Contents</fmt-title>
             </clause>
             <foreword id="_" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <p id="_">
                   <eref bibitemid="ISO712" id="_"/>
                   <semx element="eref" source="_">
                      <fmt-xref target="ISO712">[ISO 712]</fmt-xref>
                   </semx>
                   <eref bibitemid="ISBN" id="_"/>
                   <semx element="eref" source="_">
                      <fmt-xref target="ISBN">[3]</fmt-xref>
                   </semx>
                   <eref bibitemid="ISSN" id="_"/>
                   <semx element="eref" source="_">
                      <fmt-xref target="ISSN">[4]</fmt-xref>
                   </semx>
                   <eref bibitemid="ISO16634" id="_"/>
                   <semx element="eref" source="_">
                      <fmt-xref target="ISO16634">[ISO 16634:--]</fmt-xref>
                   </semx>
                   <eref bibitemid="ref1" id="_"/>
                   <semx element="eref" source="_">
                      <fmt-xref target="ref1">[ICC 167]</fmt-xref>
                   </semx>
                   <eref bibitemid="ref10" id="_"/>
                   <semx element="eref" source="_">
                      <fmt-xref target="ref10">[5]</fmt-xref>
                   </semx>
                   <eref bibitemid="ref12" id="_"/>
                   <semx element="eref" source="_">
                      <fmt-xref target="ref12">[Citn]</fmt-xref>
                   </semx>
                   <eref bibitemid="zip_ffs" id="_"/>
                   <semx element="eref" source="_">
                      <fmt-xref target="zip_ffs">[2]</fmt-xref>
                   </semx>
                </p>
             </foreword>
          </preface>
          <sections>
             <references id="_" obligation="informative" normative="true" displayorder="3">
                <title id="_">Normative References</title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="_">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Normative References</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">clause</span>
                   <semx element="autonum" source="_">1</semx>
                </fmt-xref-label>
                <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
                <bibitem id="ISO712" type="standard">
                   <formattedref>
                      ISO 712,
                      <em>Cereals and cereal products</em>
                      .
                   </formattedref>
                   <title format="text/plain">Cereals or cereal products</title>
                   <title type="main" format="text/plain">Cereals and cereal products</title>
                   <docidentifier type="ISO">ISO 712</docidentifier>
                   <docidentifier type="metanorma-ordinal">[1]</docidentifier>
                   <docidentifier scope="biblio-tag">ISO 712</docidentifier>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <name>International Organization for Standardization</name>
                      </organization>
                   </contributor>
                   <biblio-tag>[1]</biblio-tag>
                </bibitem>
                <bibitem id="ISO16634" type="standard">
                   <formattedref>
                      ISO 16634:-- (all parts) (),
                      <em>Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</em>
                      .
                   </formattedref>
                   <title language="x" format="text/plain">Cereals, pulses, milled cereal products, xxxx, oilseeds and animal feeding stuffs</title>
                   <title language="en" format="text/plain">Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</title>
                   <docidentifier type="ISO">ISO 16634:-- (all parts)</docidentifier>
                   <docidentifier scope="biblio-tag">ISO 16634:-- (all parts)</docidentifier>
                   <date type="published">
                      <on>--</on>
                   </date>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <abbreviation>ISO</abbreviation>
                      </organization>
                   </contributor>
                   <extent type="part">
                      <referenceFrom>all</referenceFrom>
                   </extent>
                   <biblio-tag>[ISO 16634:‑‑ (all parts)]</biblio-tag>
                </bibitem>
                <bibitem id="ISO20483" type="standard">
                   <formattedref>
                      ISO 20483:2013-2014 (2013),
                      <em>Cereals and pulses</em>
                      .
                   </formattedref>
                   <title format="text/plain">Cereals and pulses</title>
                   <docidentifier type="ISO">ISO 20483:2013-2014</docidentifier>
                   <docidentifier scope="biblio-tag">ISO 20483:2013-2014</docidentifier>
                   <date type="published">
                      <from>2013</from>
                      <to>2014</to>
                   </date>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <name>International Organization for Standardization</name>
                      </organization>
                   </contributor>
                   <biblio-tag>[ISO 20483:2013‑2014]</biblio-tag>
                </bibitem>
                <bibitem id="ref1">
                   <formattedref format="application/x-isodoc+xml">
                      ICC 167,
                      <smallcap>Standard No I.C.C 167</smallcap>
                      .
                      <em>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</em>
                      (see
                      <link target="http://www.icc.or.at" id="_"/>
                      <semx element="link" source="_">
                         <fmt-link target="http://www.icc.or.at"/>
                      </semx>
                      ).
                   </formattedref>
                   <docidentifier type="ICC">ICC 167</docidentifier>
                   <docidentifier scope="biblio-tag">ICC 167</docidentifier>
                   <biblio-tag>[ICC 167]</biblio-tag>
                </bibitem>
                <note>
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">NOTE</span>
                      </span>
                      <span class="fmt-label-delim"> – </span>
                   </fmt-name>
                   <p>This is an annotation of ISO 20483:2013-2014</p>
                </note>
                <bibitem id="zip_ffs">
                   <formattedref format="application/x-isodoc+xml">Title 5.</formattedref>
                   <docidentifier type="metanorma-ordinal">[2]</docidentifier>
                   <biblio-tag>[2]</biblio-tag>
                </bibitem>
             </references>
          </sections>
          <bibliography>
             <references id="_" obligation="informative" normative="false" displayorder="4">
                <title id="_">Bibliography</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Bibliography</semx>
                </fmt-title>
                <bibitem id="ISBN" type="book">
                   <formattedref>
                      <em>Chemicals for analytical laboratory use</em>
                      . n.p.: n.d. ISBN: ISBN.
                   </formattedref>
                   <title format="text/plain">Chemicals for analytical laboratory use</title>
                   <docidentifier type="ISBN">ISBN</docidentifier>
                   <docidentifier type="metanorma-ordinal">[3]</docidentifier>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <abbreviation>ISBN</abbreviation>
                      </organization>
                   </contributor>
                   <biblio-tag>[3]</biblio-tag>
                </bibitem>
                <bibitem id="ISSN" type="journal">
                   <formattedref>
                      <em>Instruments for analytical laboratory use</em>
                      . n.d. ISSN: ISSN 1.
                   </formattedref>
                   <title format="text/plain">Instruments for analytical laboratory use</title>
                   <docidentifier type="ISSN">ISSN 1</docidentifier>
                   <docidentifier type="metanorma-ordinal">[4]</docidentifier>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <abbreviation>ISSN</abbreviation>
                      </organization>
                   </contributor>
                   <biblio-tag>[4]</biblio-tag>
                </bibitem>
                <note>
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">NOTE</span>
                      </span>
                      <span class="fmt-label-delim"> – </span>
                   </fmt-name>
                   <p>This is an annotation of document ISSN.</p>
                </note>
                <note>
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">NOTE</span>
                      </span>
                      <span class="fmt-label-delim"> – </span>
                   </fmt-name>
                   <p>This is another annotation of document ISSN.</p>
                </note>
                <bibitem id="ISO3696" type="standard">
                   <formattedref>
                      ISO 3696,
                      <em>Water for analytical laboratory use</em>
                      .
                   </formattedref>
                   <title format="text/plain">Water for analytical laboratory use</title>
                   <docidentifier type="ISO">ISO 3696</docidentifier>
                   <docidentifier scope="biblio-tag">ISO 3696</docidentifier>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <abbreviation>ISO</abbreviation>
                      </organization>
                   </contributor>
                   <biblio-tag>[ISO 3696]</biblio-tag>
                </bibitem>
                <bibitem id="ref10">
                   <formattedref format="application/x-isodoc+xml">
                      <smallcap>Standard No I.C.C 167</smallcap>
                      .
                      <em>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</em>
                      (see
                      <link target="http://www.icc.or.at" id="_"/>
                      <semx element="link" source="_">
                         <fmt-link target="http://www.icc.or.at"/>
                      </semx>
                      ).
                   </formattedref>
                   <docidentifier type="metanorma-ordinal">[5]</docidentifier>
                   <biblio-tag>[5]</biblio-tag>
                </bibitem>
                <bibitem id="ref11">
                   <formattedref>
                      IETF RFC 10,
                      <em>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</em>
                      .
                   </formattedref>
                   <title>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</title>
                   <docidentifier type="IETF">IETF RFC 10</docidentifier>
                   <docidentifier scope="biblio-tag">IETF RFC 10</docidentifier>
                   <biblio-tag>[IETF RFC 10]</biblio-tag>
                </bibitem>
                <bibitem id="ref12">
                   <formattedref format="application/x-isodoc+xml">
                      IETF RFC 20, CitationWorks. 2019.
                      <em>How to cite a reference</em>
                      .
                   </formattedref>
                   <docidentifier type="metanorma">[Citn]</docidentifier>
                   <docidentifier type="IETF">IETF RFC 20</docidentifier>
                   <docidentifier scope="biblio-tag">IETF RFC 20</docidentifier>
                   <biblio-tag>[Citn]</biblio-tag>
                </bibitem>
             </references>
          </bibliography>
       </iso-standard>
    OUTPUT

    FileUtils.rm_f "test.html"
    pres_output = IsoDoc::Itu::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output
      .gsub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    IsoDoc::Itu::HtmlConvert.new({}).convert("test", pres_output, false)
    output = <<~OUTPUT
      <main class="main-section">
          <button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
          <br/>
             <div id="_">
      <h1 class="IntroTitle" id="_">
         <a class="anchor" href="#_"/>
         <a class="header" href="#_">Foreword</a>
      </h1>
             <p id="_">
                <a href="#ISO712">[ISO 712]</a>
                <a href="#ISBN">[3]</a>
                <a href="#ISSN">[4]</a>
                <a href="#ISO16634">[ISO 16634:--]</a>
                <a href="#ref1">[ICC 167]</a>
                <a href="#ref10">[5]</a>
                <a href="#ref12">[Citn]</a>
                <a href="#zip_ffs">[2]</a>
             </p>
          </div>
          <div>
             <h1 id="_">1.  Normative References</h1>
             <table class="biblio" border="0">
                <tbody>
                   <tr>
                      <td colspan="2">
                         <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
                         <td style="vertical-align:top">[1]</td>
                         <td>
                            ISO 712,
                            <i>Cereals and cereal products</i>
                            .
                         </td>
                      </td>
                   </tr>
                   <tr id="ISO16634" class="NormRef">
                      <td style="vertical-align:top">[ISO 16634:‑‑ (all parts)]</td>
                      <td>
                         ISO 16634:-- (all parts) (),
                         <i>Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</i>
                         .
                      </td>
                   </tr>
                   <tr id="ISO20483" class="NormRef">
                      <td style="vertical-align:top">[ISO 20483:2013‑2014]</td>
                      <td>
                         ISO 20483:2013-2014 (2013),
                         <i>Cereals and pulses</i>
                         .
                      </td>
                   </tr>
                   <tr id="ref1" class="NormRef">
                      <td style="vertical-align:top">[ICC 167]</td>
                      <td>
                         ICC 167,
                         <span style="font-variant:small-caps;">Standard No I.C.C 167</span>
                         .
                         <i>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</i>
                         (see
                         <a href="http://www.icc.or.at">http://www.icc.or.at</a>
                         ).
                      </td>
                   </tr>
                   <tr>
                      <td colspan="2">
                         <div class="Note">
                            <p>
                               <span class="note_label">NOTE – </span>
                               This is an annotation of ISO 20483:2013-2014
                            </p>
                         </div>
                      </td>
                   </tr>
                   <tr id="zip_ffs" class="NormRef">
                      <td style="vertical-align:top">[2]</td>
                      <td>Title 5.</td>
                   </tr>
                </tbody>
             </table>
          </div>
          <br/>
          <div>
             <h1 class="Section3" id="_">Bibliography</h1>
             <table class="biblio" border="0">
                <tbody>
                   <tr id="ISBN" class="Biblio">
                      <td style="vertical-align:top">[3]</td>
                      <td>
                         <i>Chemicals for analytical laboratory use</i>
                         . n.p.: n.d. ISBN: ISBN.
                      </td>
                   </tr>
                   <tr id="ISSN" class="Biblio">
                      <td style="vertical-align:top">[4]</td>
                      <td>
                         <i>Instruments for analytical laboratory use</i>
                         . n.d. ISSN: ISSN 1.
                      </td>
                   </tr>
                   <tr>
                      <td colspan="2">
                         <div class="Note">
                            <p>
                               <span class="note_label">NOTE – </span>
                               This is an annotation of document ISSN.
                            </p>
                         </div>
                         <div class="Note">
                            <p>
                               <span class="note_label">NOTE – </span>
                               This is another annotation of document ISSN.
                            </p>
                         </div>
                      </td>
                   </tr>
                   <tr id="ISO3696" class="Biblio">
                      <td style="vertical-align:top">[ISO 3696]</td>
                      <td>
                         ISO 3696,
                         <i>Water for analytical laboratory use</i>
                         .
                      </td>
                   </tr>
                   <tr id="ref10" class="Biblio">
                      <td style="vertical-align:top">[5]</td>
                      <td>
                         <span style="font-variant:small-caps;">Standard No I.C.C 167</span>
                         .
                         <i>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</i>
                         (see
                         <a href="http://www.icc.or.at">http://www.icc.or.at</a>
                         ).
                      </td>
                   </tr>
                   <tr id="ref11" class="Biblio">
                      <td style="vertical-align:top">[IETF RFC 10]</td>
                      <td>
                         IETF RFC 10,
                         <i>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</i>
                         .
                      </td>
                   </tr>
                   <tr id="ref12" class="Biblio">
                      <td style="vertical-align:top">[Citn]</td>
                      <td>
                         IETF RFC 20, CitationWorks. 2019.
                         <i>How to cite a reference</i>
                         .
                      </td>
                   </tr>
                </tbody>
             </table>
          </div>
       </main>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(File.read("test.html", encoding: "utf-8")
      .sub(/^.*<main/m, "<main")
      .sub(%r{</main>.*$}m, "</main>"))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes IsoXML bibliographies (2)" do
    input = <<~INPUT
          <itu-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>en</language>
          </bibdata>
          <preface><foreword>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
        <eref bibitemid="ISO712"/>
        </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>References</title>
          <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="ISO">ISO 712</docidentifier>
        <date type="published"><on>2001-01</on></date>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ITU712" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="ITU">ITU 712</docidentifier>
        <docidentifier type="DOI">DOI 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ITU712a" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="ISO">ISO 712</docidentifier>
        <docidentifier type="ITU">ITU 712</docidentifier>
        <date type="published"><on>2016</on></date>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ITU712b" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="DOI">DOI 712</docidentifier>
        <date type="published"><on>2016</on></date>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ITU713" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="ITU">ITU-T G Suppl. 41</docidentifier>
        <docidentifier type="DOI">DOI 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      </references>
      </bibliography>
      </itu-standard>
    INPUT
    presxml = <<~OUTPUT
       <itu-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata>
             <language current="true">en</language>
          </bibdata>
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Table of Contents</fmt-title>
             </clause>
             <foreword id="_" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <p id="_">
                   <eref bibitemid="ISO712" id="_"/>
                   <semx element="eref" source="_">
                      <fmt-xref target="ISO712">[ISO 712]</fmt-xref>
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
                <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
                <bibitem id="ISO712" type="standard">
                   <formattedref>
                      ISO 712 (2001),
                      <em>Cereals and cereal products</em>
                      .
                   </formattedref>
                   <title format="text/plain">Cereals or cereal products</title>
                   <title type="main" format="text/plain">Cereals and cereal products</title>
                   <docidentifier type="ISO">ISO 712</docidentifier>
                   <docidentifier scope="biblio-tag">ISO 712</docidentifier>
                   <date type="published">
                      <on>2001-01</on>
                   </date>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <name>International Organization for Standardization</name>
                      </organization>
                   </contributor>
                   <biblio-tag>[ISO 712]</biblio-tag>
                </bibitem>
                <bibitem id="ITU712" type="standard">
                   <formattedref>
                      Recommendation ITU 712,
                      <em>Cereals and cereal products</em>
                      .
                   </formattedref>
                   <title format="text/plain">Cereals or cereal products</title>
                   <title type="main" format="text/plain">Cereals and cereal products</title>
                   <docidentifier type="ITU">ITU 712</docidentifier>
                   <docidentifier type="DOI">DOI 712</docidentifier>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <name>International Organization for Standardization</name>
                      </organization>
                   </contributor>
                   <biblio-tag>[ITU 712]</biblio-tag>
                </bibitem>
                <bibitem id="ITU712a" type="standard">
                   <formattedref>
                      Recommendation ITU 712 | ISO 712 (2016),
                      <em>Cereals and cereal products</em>
                      .
                   </formattedref>
                   <title format="text/plain">Cereals or cereal products</title>
                   <title type="main" format="text/plain">Cereals and cereal products</title>
                   <docidentifier type="ISO">ISO 712</docidentifier>
                   <docidentifier type="ITU">ITU 712</docidentifier>
                   <date type="published">
                      <on>2016</on>
                   </date>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <name>International Organization for Standardization</name>
                      </organization>
                   </contributor>
                   <biblio-tag>[ITU 712]</biblio-tag>
                </bibitem>
                <bibitem id="ITU712b" type="standard">
                   <formattedref>
                      <em>Cereals and cereal products</em>
                      .
                   </formattedref>
                   <title format="text/plain">Cereals or cereal products</title>
                   <title type="main" format="text/plain">Cereals and cereal products</title>
                   <docidentifier type="DOI">DOI 712</docidentifier>
                   <date type="published">
                      <on>2016</on>
                   </date>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <name>International Organization for Standardization</name>
                      </organization>
                   </contributor>
                   <biblio-tag/>
                </bibitem>
                <bibitem id="ITU713" type="standard">
                   <formattedref>
                      ITU-T G-series Recommendations – Supplement 41,
                      <em>Cereals and cereal products</em>
                      .
                   </formattedref>
                   <title format="text/plain">Cereals or cereal products</title>
                   <title type="main" format="text/plain">Cereals and cereal products</title>
                   <docidentifier type="ITU">ITU-T G Suppl. 41</docidentifier>
                   <docidentifier type="DOI">DOI 712</docidentifier>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <name>International Organization for Standardization</name>
                      </organization>
                   </contributor>
                   <biblio-tag>[ITU‑T G Suppl. 41]</biblio-tag>
                </bibitem>
             </references>
          </sections>
          <bibliography>
       </bibliography>
       </itu-standard>
    OUTPUT

    html = <<~OUTPUT
              #{HTML_HDR}
      <div id="_">
                 <h1 class="IntroTitle">Foreword</h1>
                 <p id="_">
           <a href="#ISO712">[ISO&#xa0;712]</a>
           </p>
               </div>
               <div>
                 <h1>1.&#160; References</h1>
                       <table class='biblio' border='0'>
          <tbody>
            <tx>
              <p>
                The following documents are referred to in the text in such a way
                that some or all of their content constitutes requirements of this
                document. For dated references, only the edition cited applies.
                For undated references, the latest edition of the referenced
                document (including any amendments) applies.
              </p>
            </tx>
            <tr id='ISO712' class='NormRef'>
              <td style='vertical-align:top'>[ISO&#160;712]</td>
              <td>
                ISO&#xa0;712 (2001),
                <i>Cereals and cereal products</i>
                .
              </td>
            </tr>
            <tr id='ITU712' class='NormRef'>
              <td style='vertical-align:top'>[ITU&#160;712]</td>
              <td>
                Recommendation ITU&#xa0;712,
                <i>Cereals and cereal products</i>
                .
              </td>
            </tr>
            <tr id='ITU712a' class='NormRef'>
              <td style='vertical-align:top'>[ITU&#160;712]</td>
              <td>
                Recommendation ITU&#xa0;712&#xA0;| ISO&#xa0;712 (2016),
                <i>Cereals and cereal products</i>
                .
              </td>
            </tr>
                      <tr id="ITU712b" class="NormRef">
                         <td style="vertical-align:top"/>
                         <td>
                            <i>Cereals and cereal products</i>
                            .
                         </td>
                      </tr>
            <tr id='ITU713' class='NormRef'>
              <td style='vertical-align:top'>[ITU&#8209;T&#160;G&#160;Suppl.&#160;41]</td>
              <td>
                ITU-T&#xa0;G-series Recommendations &#8211; Supplement 41,
                <i>Cereals and cereal products</i>
                .
              </td>
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
    expect(Xml::C14n.format(strip_guid(IsoDoc::Itu::HtmlConvert.new({})
      .convert("test", pres_output, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "selects multiple primary identifiers" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>en</language>
          </bibdata>
          <preface><foreword>
        <p id="A">
        <eref bibitemid="ISO712"/>
        </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
          <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="ISO" primary="true">ISO 712</docidentifier>
        <docidentifier type="IEC" primary="true">IEC 217</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      </references></bibliography></iso-standard>
    INPUT
    presxml = <<~PRESXML
        <p id="A">
           <eref bibitemid="ISO712" id="_"/>
           <semx element="eref" source="_">
              <fmt-xref target="ISO712">[ISO 712 | IEC 217]</fmt-xref>
           </semx>
        </p>
    PRESXML
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(
      IsoDoc::Itu::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true),
    ).at("//xmlns:p[@id = 'A']").to_xml)))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end
end

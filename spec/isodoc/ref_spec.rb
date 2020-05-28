require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc::ITU do
  it "processes IsoXML bibliographies" do
    FileUtils.rm_f "test.html"
    IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", false)
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
<bibitem id="ISBN" type="ISBN">
  <title format="text/plain">Chemicals for analytical laboratory use</title>
  <docidentifier type="ISBN">ISBN</docidentifier>
  <docidentifier type="metanorma">[1]</docidentifier>
  <contributor>
    <role type="publisher"/>
    <organization>
      <abbreviation>ISBN</abbreviation>
    </organization>
  </contributor>
</bibitem>
<bibitem id="ISSN" type="ISSN">
  <title format="text/plain">Instruments for analytical laboratory use</title>
  <docidentifier type="ISSN">ISSN</docidentifier>
  <docidentifier type="metanorma">[2]</docidentifier>
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
    expect(xmlpp(File.read("test.html", encoding: "utf-8").sub(/^.*<main/m, "<main").sub(%r{</main>.*$}m, "</main>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
           <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
             <div>
               <h1 class="IntroTitle"></h1>
               <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
         <a href="#ISO712">[110]</a>
         <a href="#ISBN">[1]</a>
         <a href="#ISSN">[2]</a>
         <a href="#ISO16634">[ISO 16634:-- (all parts)]</a>
         <a href="#ref1">[ICC 167]</a>
         <a href="#ref10">[10]</a>
         <a href="#ref12">[Citn]</a>
         <a href="#zip_ffs">[5]</a>
         </p>
             </div>
             <p class="zzSTDTitle1"></p>
             <p class="zzSTDTitle2"></p>
             <div>
               <h1 id="toc0">1&#xA0; References</h1>
               <table class="biblio" border="0">
                 <tbody>
                   <tr><td rowspan="2">
                     <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>

                     <td>[110]</td>
                     <td>ISO 712, <i>Cereals and cereal products</i>.</td>
                   </td></tr>

                   <tr id="ISO16634" class="NormRef">
                     <td>[ISO 16634:-- (all parts)]</td>
                     <td>ISO 16634:-- (all parts) (), <i>Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</i>.</td>
                   </tr>
                   <tr id="ISO20483" class="NormRef">
                     <td>[ISO 20483:2013-2014]</td>
                     <td>ISO 20483:2013-2014 (20132014), <i>Cereals and pulses</i>.</td>
                   </tr>
                   <tr id="ref1" class="NormRef">
                     <td>[ICC 167]</td>
                     <td>ICC 167, <span style="font-variant:small-caps;">Standard No I.C.C 167</span>. <i>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</i> (see <a href="http://www.icc.or.at">http://www.icc.or.at</a>).</td>
                   </tr>
                   <tr><td rowspan="2">
                     <div id="" class="Note">
                       <p><span class="note_label">NOTE &#x2013; </span>This is an annotation of ISO 20483:2013-2014</p>
                     </div>
                   </td></tr>
                   <tr id="zip_ffs" class="NormRef">
                     <td>[5]</td>
                     <td>Title 5.</td>
                   </tr>
                 </tbody>
               </table>
             </div>
             <br />
             <div>
               <h1 class="Section3" id="toc1">Bibliography</h1>
               <table class="biblio" border="0">
                 <tbody>
                   <tr id="ISBN" class="Biblio">
                     <td>[1]</td>
                     <td>ISBN ISBN, <i>Chemicals for analytical laboratory use</i>.</td>
                   </tr>
                   <tr id="ISSN" class="Biblio">
                     <td>[2]</td>
                     <td>ISSN ISSN, <i>Instruments for analytical laboratory use</i>.</td>
                   </tr>
                   <tr><td rowspan="2">
                     <div id="" class="Note">
                       <p><span class="note_label">NOTE &#x2013; </span>This is an annotation of document ISSN.</p>
                     </div>

                     <div id="" class="Note">
                       <p><span class="note_label">NOTE &#x2013; </span>This is another annotation of document ISSN.</p>
                     </div>
                   </td></tr>

                   <tr id="ISO3696" class="Biblio">
                     <td>[ISO 3696]</td>
                     <td>ISO 3696, <i>Water for analytical laboratory use</i>.</td>
                   </tr>
                   <tr id="ref10" class="Biblio">
                     <td>[10]</td>
                     <td><span style="font-variant:small-caps;">Standard No I.C.C 167</span>. <i>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</i> (see <a href="http://www.icc.or.at">http://www.icc.or.at</a>).</td>
                   </tr>
                   <tr id="ref11" class="Biblio">
                     <td>[IETF RFC 10]</td>
                     <td>IETF RFC 10, <i>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</i>.</td>
                   </tr>
                   <tr id="ref12" class="Biblio">
                     <td>[Citn]</td>
                     <td>IETF RFC 20, CitationWorks. 2019. <i>How to cite a reference</i>.</td>
                   </tr>
                 </tbody>
               </table>
             </div>
           </main>
    OUTPUT
  end

end

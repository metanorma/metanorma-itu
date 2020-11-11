require "spec_helper"
require "fileutils"

logoloc = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "isodoc", "itu", "html"))

RSpec.describe Asciidoctor::ITU do
    it "processes history and source clauses (Word)" do
          expect(xmlpp(IsoDoc::ITU::WordConvert.new({}).convert("test", <<~INPUT, true).gsub(%r{^.*<div class="WordSection2">}m, '<div class="WordSection2">').gsub(%r{<p>\s*<br clear="all" class="section"/>\s*</p>\s*<div class="WordSection3">.*}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <clause type="history" id="H"><title>History</title></clause>
    <clause type="source" id="I"><title>Source</title></clause>
    </preface>
    </iso-standard>
    INPUT
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
   end


  it "processes default metadata" do
    csdc = IsoDoc::ITU::HtmlConvert.new({})
    docxml, filename, dir = csdc.convert_init(<<~"INPUT", "test", true)
<itu-standard xmlns="https://www.calconnect.org/standards/itu">
  <bibdata type="standard">
  <title language="en" format="text/plain" type="main">Main Title</title>
  <title language="en" format="text/plain" type="annex">Annex Title</title>
  <title language="fr" format="text/plain" type="main">Titre Principal</title>
  <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
<title language='fr' format='text/plain' type='subtitle'>Soustitre</title>
<title language='en' format='text/plain' type='amendment'>Amendment Title</title>
<title language='fr' format='text/plain' type='amendment'>Titre de Amendment</title>
<title language='en' format='text/plain' type='corrigendum'>Corrigendum Title</title>
<title language='fr' format='text/plain' type='corrigendum'>Titre de Corrigendum</title>
  <docidentifier type="ITU-provisional">ABC</docidentifier>
  <docidentifier type="ITU">ITU-R 1000</docidentifier>
  <docnumber>1000</docnumber>
  <date type='published'>2018-09-01</date>
           <date type='published' format='ddMMMyyyy'>1.IX.2018</date>
  <contributor>
    <role type="author"/>
    <organization>
      <name>International Telecommunication Union</name>
      <abbreviation>ITU</abbreviation>
    </organization>
  </contributor>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>International Telecommunication Union</name>
      <abbreviation>ITU</abbreviation>
    </organization>
  </contributor>
  <edition>2</edition>
<version>
  <revision-date>2000-01-01</revision-date>
  <draft>3.4</draft>
</version>  
  <language>en</language>
  <script>Latn</script>
  <status>
    <stage>final-draft</stage>
    <iteration>3</iteration>
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
  <series type="main">
  <title>A3</title>
</series>
<series type="secondary">
  <title>B3</title>
</series>
<series type="tertiary">
  <title>C3</title>
</series>
     <keyword>word2</keyword>
 <keyword>word1</keyword>
  <ext>
  <doctype>directive</doctype>
      <editorialgroup>
      <bureau>R</bureau>
      <group type="A">
        <name>I</name>
        <acronym>C</acronym>
        <period>
          <start>E</start>
          <end>G</end>
        </period>
      </group>
      <subgroup type="A1">
        <name>I1</name>
        <acronym>C1</acronym>
        <period>
          <start>E1</start>
          <end>G1</end>
        </period>
      </subgroup>
      <workgroup type="A2">
        <name>I2</name>
        <acronym>C2</acronym>
        <period>
          <start>E2</start>
          <end>G2</end>
        </period>
      </workgroup>
    </editorialgroup>
    <editorialgroup>
      <bureau>T</bureau>
      <group type="B">
        <name>J</name>
        <acronym>D</acronym>
        <period>
          <start>F</start>
          <end>H</end>
        </period>
      </group>
      <subgroup type="B1">
        <name>J1</name>
        <acronym>D1</acronym>
        <period>
          <start>F1</start>
          <end>H1</end>
        </period>
      </subgroup>
      <workgroup type="B2">
        <name>J2</name>
        <acronym>D2</acronym>
        <period>
          <start>F2</start>
          <end>H2</end>
        </period>
      </workgroup>
    </editorialgroup>
 <recommendationstatus>
  <from>D3</from>
  <to>E3</to>
  <approvalstage process="F3">G3</approvalstage>
</recommendationstatus>
<ip-notice-received>false</ip-notice-received>
<structuredidentifier>
<bureau>R</bureau>
<docnumber>1000</docnumber>
<annexid>F1</annexid>
<amendment>2</amendment>
<corrigendum>3</corrigendum>
</structuredidentifier>
  </ext>
</bibdata>
<preface/><sections/>
<annex obligation="informative"/>
</itu-standard>
    INPUT
    expect(htmlencode(metadata(csdc.info(docxml, nil)).to_s.gsub(/, :/, ",\n:"))).to be_equivalent_to <<~"OUTPUT"
{:accesseddate=>"XXX",
:agency=>"ITU",
:amendmentid=>"Amendment 2",
:amendmenttitle=>"Amendment Title",
:annexid=>"Appendix F1",
:annextitle=>"Annex Title",
:bureau=>"R",
:circulateddate=>"XXX",
:confirmeddate=>"XXX",
:copieddate=>"XXX",
:corrigendumid=>"Corrigendum 3",
:corrigendumtitle=>"Corrigendum Title",
:createddate=>"XXX",
:docnumber=>"ITU-R 1000",
:docnumeric=>"1000",
:docsubtitle=>"Subtitle",
:doctitle=>"Main Title",
:doctype=>"Directive",
:doctype_display=>"Directive",
:doctype_original=>"directive",
:docyear=>"2001",
:draft=>"3.4",
:draftinfo=>" (draft 3.4, 2000-01-01)",
:edition=>"2",
:group=>"I",
:implementeddate=>"XXX",
:ip_notice_received=>"false",
:issueddate=>"XXX",
:iteration=>"3",
:keywords=>["word1", "word2"],
:lang=>"en",
:logo_comb=>"#{File.join(logoloc, "itu-document-comb.png")}",
:logo_html=>"#{File.join(logoloc, "/International_Telecommunication_Union_Logo.svg")}",
:logo_word=>"#{File.join(logoloc, "International_Telecommunication_Union_Logo.svg")}",
:obsoleteddate=>"XXX",
:placedate_year=>"Geneva, 2001",
:pubdate_ddMMMyyyy=>"1.IX.2018",
:pubdate_monthyear=>"09/2018",
:publisheddate=>"XXX",
:publisher=>"International Telecommunication Union",
:receiveddate=>"XXX",
:revdate=>"2000-01-01",
:revdate_monthyear=>"01/2000",
:script=>"Latn",
:series=>"A3",
:series1=>"B3",
:series2=>"C3",
:stage=>"Final Draft",
:stage_display=>"Final Draft",
:subgroup=>"I1",
:transmitteddate=>"XXX",
:unchangeddate=>"XXX",
:unpublished=>false,
:updateddate=>"XXX",
:vote_endeddate=>"XXX",
:vote_starteddate=>"XXX",
:workgroup=>"I2"}
    OUTPUT
  end

  it "processes default metadata for technical report" do
    csdc = IsoDoc::ITU::HtmlConvert.new({})
    docxml, filename, dir = csdc.convert_init(<<~"INPUT", "test", true)
    <itu-standard xmlns='https://www.metanorma.org/ns/itu' type='semantic' version='1.2.4'>
         <bibdata type='standard'>
           <title language='en' format='text/plain' type='main'>Main Title</title>
           <title language='fr' format='text/plain' type='main'>Titre Principal</title>
           <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
           <title language='fr' format='text/plain' type='subtitle'>Soustitre</title>
           <docidentifier type='ITU-provisional'>ABC</docidentifier>
           <docidentifier type='ITU-Recommendation'>DEF</docidentifier>
           <docidentifier type='ITU'>ITU-R 1000</docidentifier>
           <docnumber>1000</docnumber>
           <contributor>
             <role type='author'/>
             <organization>
               <name>International Telecommunication Union</name>
             </organization>
           </contributor>
           <contributor>
             <role type='author'/>
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
               <email>y@example.com</email>
             </person>
           </contributor>
           <contributor>
             <role type='publisher'/>
             <organization>
               <name>International Telecommunication Union</name>
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
           <keyword>Word1</keyword>
           <keyword>word2</keyword>
           <ext>
             <doctype>technical-report</doctype>
             <editorialgroup>
               <bureau>R</bureau>
               <group>
                 <name>I</name>
               </group>
               <subgroup>
                 <name>I1</name>
               </subgroup>
               <workgroup>
                 <name>I2</name>
               </workgroup>
             </editorialgroup>
             <ip-notice-received>false</ip-notice-received>
             <meeting>Meeting X</meeting>
             <meeting-date>
               <from>2000-01-01</from>
               <to>2000-01-02</to>
             </meeting-date>
             <intended-type>TD</intended-type>
             <source>Source</source>
             <structuredidentifier>
               <bureau>R</bureau>
               <docnumber>1000</docnumber>
             </structuredidentifier>
           </ext>
         </bibdata>
         <sections> </sections>
       </itu-standard>
INPUT
    expect(htmlencode(metadata(csdc.info(docxml, nil)).to_s.gsub(/, :/, ",\n:"))).to be_equivalent_to <<~"OUTPUT"
{:accesseddate=>"XXX",
:addresses=>["Canada", "USA"],
:affiliations=>["Bedrock Quarry", "Bedrock Quarry 2"],
:agency=>"International Telecommunication Union",
:authors=>["Fred Flintstone", "Barney Rubble"],
:authors_affiliations=>{"Bedrock Quarry, Canada"=>["Fred Flintstone"], "Bedrock Quarry 2, USA"=>["Barney Rubble"]},
:bureau=>"R",
:circulateddate=>"XXX",
:confirmeddate=>"XXX",
:copieddate=>"XXX",
:createddate=>"XXX",
:docnumber=>"ITU-R 1000",
:docnumeric=>"1000",
:docsubtitle=>"Subtitle",
:doctitle=>"Main Title",
:doctype=>"Technical Report",
:doctype_display=>"Technical Report",
:doctype_original=>"technical-report",
:docyear=>"2001",
:draft=>"5",
:draftinfo=>" (draft 5, 2000-01-01)",
:edition=>"2",
:emails=>["x@example.com", "y@example.com"],
:faxes=>["556", "558"],
:group=>"I",    
:implementeddate=>"XXX",
:intended_type=>"TD",
:ip_notice_received=>"false",
:issueddate=>"XXX",
:keywords=>["Word1", "word2"],
:lang=>"en",
:logo_comb=>"#{File.join(logoloc, "itu-document-comb.png")}",
:logo_html=>"#{File.join(logoloc, "/International_Telecommunication_Union_Logo.svg")}",
:logo_word=>"#{File.join(logoloc, "International_Telecommunication_Union_Logo.svg")}",
:meeting=>"Meeting X",
:meeting_date=>"01 Jan 2000/02 Jan 2000",
:obsoleteddate=>"XXX",
:phones=>["555", "557"],
:placedate_year=>"Geneva, 2001",
:publisheddate=>"XXX",
:publisher=>"International Telecommunication Union",
:receiveddate=>"XXX",
:recommendationnumber=>"DEF",
:revdate=>"2000-01-01",
:revdate_monthyear=>"01/2000",
:script=>"Latn",
:series=>"A3",
:series1=>"B3",
:series2=>"C3",
:source=>"Source",
:stage=>"Draft",
:stage_display=>"Draft",
:stageabbr=>"D",
:subgroup=>"I1",
:transmitteddate=>"XXX",
:unchangeddate=>"XXX",
:unpublished=>true,
:updateddate=>"XXX",
:vote_endeddate=>"XXX",
:vote_starteddate=>"XXX",
:workgroup=>"I2"}
OUTPUT
  end

  it "processes default metadata for service publication" do
    csdc = IsoDoc::ITU::HtmlConvert.new({})
    docxml, filename, dir = csdc.convert_init(<<~"INPUT", "test", true)
    <itu-standard xmlns='https://www.metanorma.org/ns/itu' type='semantic' version='1.2.4'>
         <bibdata type='standard'>
           <title language='en' format='text/plain' type='main'>Main Title</title>
           <title language='fr' format='text/plain' type='main'>Titre Principal</title>
           <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
           <title language='fr' format='text/plain' type='subtitle'>Soustitre</title>
           <docidentifier type='ITU-provisional'>ABC</docidentifier>
           <docidentifier type='ITU-Recommendation'>DEF</docidentifier>
           <docidentifier type='ITU'>ITU-R 1000</docidentifier>
           <docnumber>1000</docnumber>
           <contributor>
             <role type='author'/>
             <organization>
               <name>International Telecommunication Union</name>
             </organization>
           </contributor>
           <contributor>
             <role type='author'/>
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
               <email>y@example.com</email>
             </person>
           </contributor>
           <contributor>
             <role type='publisher'/>
             <organization>
               <name>International Telecommunication Union</name>
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
           <keyword>Word1</keyword>
           <keyword>word2</keyword>
           <ext>
             <doctype>technical-report</doctype>
             <editorialgroup>
               <bureau>R</bureau>
               <group>
                 <name>I</name>
               </group>
               <subgroup>
                 <name>I1</name>
               </subgroup>
               <workgroup>
                 <name>I2</name>
               </workgroup>
             </editorialgroup>
             <ip-notice-received>false</ip-notice-received>
             <meeting>Meeting X</meeting>
             <meeting-date>
               <from>2000-01-01</from>
               <to>2000-01-02</to>
             </meeting-date>
             <intended-type>TD</intended-type>
             <source>Source</source>
             <structuredidentifier>
               <bureau>R</bureau>
               <docnumber>1000</docnumber>
             </structuredidentifier>
           </ext>
         </bibdata>
         <sections> </sections>
       </itu-standard>
INPUT
    expect(htmlencode(metadata(csdc.info(docxml, nil)).to_s.gsub(/, :/, ",\n:"))).to be_equivalent_to <<~"OUTPUT"
    {:accesseddate=>"XXX",
:addresses=>["Canada", "USA"],
:affiliations=>["Bedrock Quarry", "Bedrock Quarry 2"],
:agency=>"International Telecommunication Union",
:authors=>["Fred Flintstone", "Barney Rubble"],
:authors_affiliations=>{"Bedrock Quarry, Canada"=>["Fred Flintstone"], "Bedrock Quarry 2, USA"=>["Barney Rubble"]},
:bureau=>"R",
:circulateddate=>"XXX",
:confirmeddate=>"XXX",
:copieddate=>"XXX",
:createddate=>"XXX",
:docnumber=>"ITU-R 1000",
:docnumeric=>"1000",
:docsubtitle=>"Subtitle",
:doctitle=>"Main Title",
:doctype=>"Technical Report",
:doctype_display=>"Technical Report",
:doctype_original=>"technical-report",
:docyear=>"2001",
:draft=>"5",
:draftinfo=>" (draft 5, 2000-01-01)",
:edition=>"2",
:emails=>["x@example.com", "y@example.com"],
:faxes=>["556", "558"],
:group=>"I",
:implementeddate=>"XXX",
:intended_type=>"TD",
:ip_notice_received=>"false",
:issueddate=>"XXX",
:keywords=>["Word1", "word2"],
:lang=>"en",
:logo_comb=>"#{File.join(logoloc, "itu-document-comb.png")}",
:logo_html=>"#{File.join(logoloc, "/International_Telecommunication_Union_Logo.svg")}",
:logo_word=>"#{File.join(logoloc, "International_Telecommunication_Union_Logo.svg")}",
:meeting=>"Meeting X",
:meeting_date=>"01 Jan 2000/02 Jan 2000",
:obsoleteddate=>"XXX",
:phones=>["555", "557"],
:placedate_year=>"Geneva, 2001",
:publisheddate=>"XXX",
:publisher=>"International Telecommunication Union",
:receiveddate=>"XXX",
:recommendationnumber=>"DEF",
:revdate=>"2000-01-01",
:revdate_monthyear=>"01/2000",
:script=>"Latn",
:series=>"A3",
:series1=>"B3",
:series2=>"C3",
:source=>"Source",
:stage=>"Draft",
:stage_display=>"Draft",
:stageabbr=>"D",
:subgroup=>"I1",
:transmitteddate=>"XXX",
:unchangeddate=>"XXX",
:unpublished=>true,
:updateddate=>"XXX",
:vote_endeddate=>"XXX",
:vote_starteddate=>"XXX",
:workgroup=>"I2"}
OUTPUT
  end

   it "processes metadata for in-force-prepublished, recommendation annex" do
    csdc = IsoDoc::ITU::HtmlConvert.new({})
    docxml, filename, dir = csdc.convert_init(<<~"INPUT", "test", true)
<itu-standard xmlns="https://www.calconnect.org/standards/itu">
  <bibdata type="standard">
  <title language="en" format="text/plain" type="main">Main Title</title>
  <title language="fr" format="text/plain" type="main">Titre Principal</title>
  <docidentifier type="ITU-provisional">ABC</docidentifier>
  <docidentifier type="ITU">ITU-R 1000</docidentifier>
  <docnumber>1000</docnumber>
  <contributor>
    <role type="author"/>
    <organization>
      <name>International Telecommunication Union</name>
      <abbreviation>ITU</abbreviation>
    </organization>
  </contributor>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>International Telecommunication Union</name>
      <abbreviation>ITU</abbreviation>
    </organization>
  </contributor>
  <language>en</language>
  <script>Latn</script>
  <status>
    <stage>in-force-prepublished</stage>
  </status>
  <ext>
  <doctype>recommendation-annex</doctype>
  </ext>
  </bibdata>
<preface/><sections/>
<annex obligation="informative"/>
</itu-standard>

INPUT
    expect(htmlencode(metadata(csdc.info(docxml, nil)).to_s.gsub(/, :/, ",\n:"))).to be_equivalent_to <<~"OUTPUT"
{:accesseddate=>"XXX",
:agency=>"ITU",
:circulateddate=>"XXX",
:confirmeddate=>"XXX",
:copieddate=>"XXX",
:createddate=>"XXX",
:docnumber=>"ITU-R 1000",
:docnumeric=>"1000",
:doctitle=>"Main Title",
:doctype=>"Recommendation",
:doctype_display=>"Recommendation",
:doctype_original=>"recommendation-annex",
:implementeddate=>"XXX",
:ip_notice_received=>"false",
:issueddate=>"XXX",
:lang=>"en",
:logo_comb=>"#{File.join(logoloc, "itu-document-comb.png")}",
:logo_html=>"#{File.join(logoloc, "/International_Telecommunication_Union_Logo.svg")}",
:logo_word=>"#{File.join(logoloc, "International_Telecommunication_Union_Logo.svg")}",
:obsoleteddate=>"XXX",
:publisheddate=>"XXX",
:publisher=>"International Telecommunication Union",
:receiveddate=>"XXX",
:script=>"Latn",
:stage=>"In Force Prepublished",
:stage_display=>"In Force Prepublished",
:stageabbr=>"IFP",
:transmitteddate=>"XXX",
:unchangeddate=>"XXX",
:unpublished=>true,
:updateddate=>"XXX",
:vote_endeddate=>"XXX",
:vote_starteddate=>"XXX"}
    OUTPUT
   end

     it "processes amendments and corrigenda" do
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{<localized-strings>.*</localized-strings>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
<itu-standard xmlns="https://www.calconnect.org/standards/itu">
<bibdata>
<language>en</language>
<script>Latn</script>
<ext>
<structuredidentifier>
        <amendment>1</amendment>
        <corrigendum>2</corrigendum>
</structuredidentifier>
</ext>
</bibdata>
</itu-standard>
    INPUT
    <itu-standard xmlns='https://www.calconnect.org/standards/itu' type='presentation'>
  <bibdata>
    <language current="true">en</language>
    <script current="true">Latn</script>
    <ext>
      <structuredidentifier>
<amendment language=''>1</amendment>
<amendment language='en'>Amendment 1</amendment>
<corrigendum language=''>2</corrigendum>
<corrigendum language='en'>Corrigendum 2</corrigendum>
      </structuredidentifier>
    </ext>
  </bibdata>
</itu-standard>
    OUTPUT
  end

     it "processes titles for service publications" do
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{<localized-strings>.*</localized-strings>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
<itu-standard xmlns="https://www.calconnect.org/standards/itu">
<bibdata>
<language>en</language>
<script>Latn</script>
<title type="main">Title</title>
<date type="published">2010-09-08</date>
<ext>
<doctype>service-publication</doctype>
</ext>
</bibdata>
</itu-standard>
    INPUT
    <itu-standard xmlns='https://www.calconnect.org/standards/itu' type='presentation'>
  <bibdata>
    <language current='true'>en</language>
           <script current='true'>Latn</script>
           <title type='main'>Title</title>
           <title language='en' format='text/plain' type='position-sp'>Position on 8 September 2010</title>
           <date type='published'>2010-09-08</date>
           <date type='published' format='ddMMMyyyy'>8.IX.2010</date>
           <ext>
             <doctype language=''>service-publication</doctype>
           </ext>
  </bibdata>
</itu-standard>
    OUTPUT
  end


       it "localises dates in English" do
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{<localized-strings>.*</localized-strings>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
<itu-standard xmlns="https://www.calconnect.org/standards/itu">
<bibdata>
<date type="published">2018-09-01</date>
<date type="published">2018-09</date>
<date type="published">2018</date>
<language>en</language>
</bibdata>
</itu-standard>
    INPUT
    <itu-standard xmlns='https://www.calconnect.org/standards/itu' type='presentation'>
  <bibdata>
  <date type='published'>2018-09-01</date>
           <date type='published' format='ddMMMyyyy'>1.IX.2018</date>
           <date type='published'>2018-09</date>
           <date type='published' format='ddMMMyyyy'>IX.2018</date>
           <date type='published'>2018</date>
           <date type='published' format='ddMMMyyyy'>2018</date>
           <language current='true'>en</language>
  </bibdata>
</itu-standard>
    OUTPUT
  end

              it "localises dates in Arabic" do
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{<localized-strings>.*</localized-strings>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
<itu-standard xmlns="https://www.calconnect.org/standards/itu">
<bibdata>
<date type="published">2018-09-01</date>
<date type="published">2018-09</date>
<date type="published">2018</date>
<language>ar</language>
</bibdata>
</itu-standard>
    INPUT
    <itu-standard xmlns='https://www.calconnect.org/standards/itu' type='presentation'>
  <bibdata>
  <date type='published'>2018-09-01</date>
           <date type='published' format='ddMMMyyyy'>2018.IX.1</date>
           <date type='published'>2018-09</date>
           <date type='published' format='ddMMMyyyy'>2018.IX</date>
           <date type='published'>2018</date>
           <date type='published' format='ddMMMyyyy'>2018</date>
           <language current='true'>ar</language>
  </bibdata>
</itu-standard>
    OUTPUT
  end

                     it "localises dates in Chinese" do
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{<localized-strings>.*</localized-strings>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
<itu-standard xmlns="https://www.calconnect.org/standards/itu">
<bibdata>
<date type="published">2018-09-01</date>
<date type="published">2018-09</date>
<date type="published">2018</date>
<language>zh</language>
<script>Hans</script>
</bibdata>
</itu-standard>
    INPUT
    <itu-standard xmlns='https://www.calconnect.org/standards/itu' type='presentation'>
  <bibdata>
    <date type='published'>2018-09-01</date>
           <date type='published' format='ddMMMyyyy'>2018&#x5E74;9&#x6708;1&#x65E5;</date>
           <date type='published'>2018-09</date>
           <date type='published' format='ddMMMyyyy'>2018&#x5E74;9&#x6708;</date>
           <date type='published'>2018</date>
           <date type='published' format='ddMMMyyyy'>2018&#x5E74;</date>
<language current='true'>zh</language>
<script current='true'>Hans</script>
  </bibdata>
</itu-standard>
    OUTPUT
  end



  it "processes keyword" do
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
<itu-standard xmlns="https://www.calconnect.org/standards/itu">
<preface><foreword>
<keyword>ABC</keyword>
</foreword></preface>
</itu-standard>
    INPUT
        #{HTML_HDR}
             <div>
               <h1 class="IntroTitle"/>
               <span class="keyword">ABC</span>
             </div>
             <p class="zzSTDTitle1"/>
             <p class="zzSTDTitle2"/>
           </div>
         </body>
    OUTPUT
  end

  it "processes add, del" do
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
<itu-standard xmlns="https://www.calconnect.org/standards/itu">
<preface><foreword id="A">
<add>ABC <xref target="A"></add> <del><strong>B</strong></del>
</foreword></preface>
</itu-standard>
    INPUT
        #{HTML_HDR}
             <div id='A'>
             <h1 class='IntroTitle'/>
  <span class='addition'>
               ABC 
               <a href='#A'/>
               <span class='deletion'>
                 <b>B</b>
               </span>
             </span>
             </div>
             <p class="zzSTDTitle1"/>
             <p class="zzSTDTitle2"/>
           </div>
         </body>
    OUTPUT
  end


  it "processes simple terms & definitions" do
    input = <<~INPUT
               <itu-standard xmlns="http://riboseinc.com/isoxml">
       <preface/><sections>
       <terms id="H" obligation="normative"><title>Terms</title>
         <term id="J">
         <preferred>Term2</preferred>
         <definition><p>This is a journey into sound</p></definition>
         <termsource><origin citeas="XYZ">x y z</origin></termsource>
         <termnote id="J1" keep-with-next="true" keep-lines-together="true"><p>This is a note</p></termnote>
       </term>
         <term id="K">
         <preferred>Term3</preferred>
         <definition><p>This is a journey into sound</p></definition>
         <termsource><origin citeas="XYZ">x y z</origin></termsource>
         <termnote id="J2"><p>This is a note</p></termnote>
         <termnote id="J3"><p>This is a note</p></termnote>
       </term>
        </terms>
        </sections>
        </itu-standard>
    INPUT

    presxml = <<~INPUT
               <itu-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
       <preface/><sections>
       <terms id="H" obligation="normative"><title depth="1">1.<tab/>Terms</title>
         <term id="J">
         <name>1.1.</name>
         <preferred>Term2</preferred>
         <definition><p>This is a journey into sound</p></definition>
         <termsource><origin citeas="XYZ">x y z</origin></termsource>
         <termnote id="J1" keep-with-next="true" keep-lines-together="true"><name>NOTE</name><p>This is a note</p></termnote>
       </term>
         <term id="K">
         <name>1.2.</name>
         <preferred>Term3</preferred>
         <definition><p>This is a journey into sound</p></definition>
         <termsource><origin citeas="XYZ">x y z</origin></termsource>
         <termnote id="J2"><name>NOTE 1</name><p>This is a note</p></termnote>
         <termnote id="J3"><name>NOTE 2</name><p>This is a note</p></termnote>
       </term>
        </terms>
        </sections>
        </itu-standard>
    INPUT

    output = <<~OUTPUT
        #{HTML_HDR}
           <p class='zzSTDTitle1'/>
           <p class='zzSTDTitle2'/>
           <div id='H'>
             <h1>1.&#160; Terms</h1>
             <div id='J'>
               <p class='TermNum' id='J'>
                 <b>1.1.&#160; Term2</b>:
                  [XYZ]
               </p>
               <p>This is a journey into sound</p>
               <div id='J1' class='Note' style='page-break-after: avoid;page-break-inside: avoid;'>
                 <p>NOTE &#8211; This is a note</p>
               </div>
             </div>
             <div id='K'>
               <p class='TermNum' id='K'>
                 <b>1.2.&#160; Term3</b>:
                  [XYZ]
               </p>
               <p>This is a journey into sound</p>
               <div id='J2' class='Note'>
                 <p>NOTE 1 &#8211; This is a note</p>
               </div>
               <div id='J3' class='Note'>
                 <p>NOTE 2 &#8211; This is a note</p>
               </div>
             </div>
           </div>
         </div>
       </body>
    OUTPUT
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({}).convert("test", input, true).gsub(%r{<localized-strings>.*</localized-strings>}m, ""))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", presxml, true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(output)
  end

  it "postprocesses simple terms & definitions" do
        FileUtils.rm_f "test.html"
        FileUtils.rm_f "test.doc"
    IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", false)
               <itu-standard xmlns="http://riboseinc.com/isoxml">
       <preface/><sections>
       <terms id="H" obligation="normative"><title>1<tab/>Terms</title>
         <term id="J">
         <name>1.1</name>
         <preferred>Term2</preferred>
         <definition><p>This is a journey into sound</p></definition>
         <termsource><origin citeas="XYZ">x y z</origin></termsource>
         <termnote id="J1"><name>NOTE</name><p>This is a note</p></termnote>
       </term>
        </terms>
        </sections>
        </itu-standard>
    INPUT
        expect(xmlpp(File.read("test.html", encoding: "utf-8").to_s.gsub(%r{^.*<main}m, "<main").gsub(%r{</main>.*}m, "</main>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
        <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
             <p class="zzSTDTitle1"></p>
             <p class="zzSTDTitle2"></p>
             <div id="H"><h1 id="toc0">1&#xA0; Terms</h1>
         <div id="J"><p class="TermNum" id="J"><b>1.1&#xA0; Term2</b>: [XYZ] This is a journey into sound</p>



         <div id="J1" class="Note"><p>NOTE &#x2013; This is a note</p></div>
       </div>
        </div>
           </main>
    OUTPUT
  end

  it "processes terms & definitions subclauses with external, internal, and empty definitions" do
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
               <itu-standard xmlns="http://riboseinc.com/isoxml">
         <termdocsource type="inline" bibitemid="ISO712"/>
       <preface/><sections>
       <clause id="G"><title>2<tab/>Terms, Definitions, Symbols and Abbreviated Terms</title>
       <terms id="H" obligation="normative"><title>2.1<tab/>Terms defined in this recommendation</title>
         <term id="J">
         <name>2.1.1</name>
         <preferred>Term2</preferred>
       </term>
       </terms>
       <terms id="I" obligation="normative"><title>2.2<tab/>Terms defined elsewhere</title>
         <term id="K">
         <name>2.2.1</name>
         <preferred>Term2</preferred>
       </term>
       </terms>
       <terms id="L" obligation="normative"><title>2.3<tab/>Other terms</title>
       </terms>
       </clause>
        </sections>
        <bibliography>
        <references id="_normative_references" obligation="informative" normative="true"><title>1<tab/>References</title>
<bibitem id="ISO712" type="standard">
  <title format="text/plain">Cereals and cereal products?~@~I?~@~T?~@~IDetermination of moisture content?~@~I?~@~T?~@~IReference method</title>
  <docidentifier>ISO 712</docidentifier>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>International Organization for Standardization</name>
    </organization>
  </contributor>
</bibitem></references>
</bibliography>
        </itu-standard>
    INPUT
        #{HTML_HDR}
               <p class="zzSTDTitle1"/>
             <p class="zzSTDTitle2"/>
               <div>
                 <h1>1&#160; References</h1>
                 <table class='biblio' border='0'>
  <tbody>
    <tr id='ISO712' class='NormRef'>
      <td  style='vertical-align:top'>[ISO&#160;712]</td>
                 <td>ISO 712, <i>Cereals and cereal products?~@~I?~@~T?~@~IDetermination of moisture content?~@~I?~@~T?~@~IReference method</i>.</td>
                 </tr>
                 </tbody>
                 </table>
               </div>

<div id="G"><h1>2&#160; Terms, Definitions, Symbols and Abbreviated Terms</h1>
              <div id="H"><h2>2.1&#160; Terms defined in this recommendation</h2>
                <div id="J"><p class="TermNum" id="J"><b>2.1.1&#160; Term2</b>:</p>
     
              </div>
              </div>
              <div id="I"><h2>2.2&#160; Terms defined elsewhere</h2>
                <div id="K"><p class="TermNum" id="K"><b>2.2.1&#160; Term2</b>:</p>
     
              </div>
              </div>
              <div id="L"><h2>2.3&#160; Other terms</h2></div>
              </div>
           </div>
           </body>
    OUTPUT
  end

    it "rearranges term headers" do
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s)).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
               <p class="zzSTDTitle1"/>
             <p class="zzSTDTitle2"/>
               <div id="H"><h1>1.&#160; Terms and definitions</h1><p>For the purposes of this document,
           the following terms and definitions apply.</p>
       <p class="TermNum" id="J">1.1.</p>
         <p class="Terms" style="text-align:left;">Term2</p>
       </div>
             </div>
           </body>
           </html>
           INPUT
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
                  <p class="zzSTDTitle1"/>
             <p class="zzSTDTitle2"/>
                  <div id="H"><h1>1.&#xA0; Terms and definitions</h1><p>For the purposes of this document,
              the following terms and definitions apply.</p>
          <p class="Terms" style='text-align:left;' id="J"><b>1.1.</b>&#xA0;Term2</p>

          </div>
                </div>
              </body>
              </html>
    OUTPUT
  end

   it "processes IsoXML footnotes (Word)" do
     expect(xmlpp(IsoDoc::ITU::WordConvert.new({}).convert("test", <<~"INPUT", true).sub(%r{^.*<body }m, "<body xmlns:epub='epub' ").sub(%r{</body>.*$}m, "</body>").gsub(%r{_Ref\d+}, "_Ref"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <itu-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
    <p>A.<fn reference="2">
  <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
</fn></p>
    <p>B.<fn reference="2">
  <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
</fn></p>
    <p>C.<fn reference="1">
  <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Hello! denoted as 15 % (m/m).</p>
</fn></p>
    </foreword>
    </preface>
    </itu-standard>
    INPUT
    <body xmlns:epub="epub" lang="EN-US" link="blue" vlink="#954F72">
           <div class="WordSection1">
             <p>&#160;</p>
           </div>
           <p>
             <br clear="all" class="section"/>
           </p>
           <div class="WordSection2">
             <div>
               <h1 class="IntroTitle"/>
               <p>A.<span style='mso-bookmark:_Ref'>
  <a href='#ftn2' class='FootnoteRef' epub:type='footnote'>
    <sup>2</sup>
  </a>
</span></p>
               <p>B.<span style='mso-element:field-begin'/>
 NOTEREF _Ref \\f \\h
<span style='mso-element:field-separator'/>
<span class='MsoFootnoteReference'>2</span>
<span style='mso-element:field-end'/>
</p>
               <p>C.<span style='mso-bookmark:_Ref'>
  <a href='#ftn1' class='FootnoteRef' epub:type='footnote'>
    <sup>1</sup>
  </a>
</span>
</p>
             </div>
             <p>&#160;</p>
           </div>
           <p>
             <br clear="all" class="section"/>
           </p>
           <div class="WordSection3">
             <p class="zzSTDTitle1"/>
             <p class="zzSTDTitle2"/>
             <aside id="ftn2">
         <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
       </aside>
             <aside id="ftn1">
         <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Hello! denoted as 15 % (m/m).</p>
       </aside>
           </div>
         </body>
    OUTPUT
  end

     it "cleans up footnotes" do
    FileUtils.rm_f "test.html"
    IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", false)
    <itu-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
    <p>A.<fn reference="2">
  <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
</fn></p>
    <p>B.<fn reference="2">
  <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
</fn></p>
    <p>C.<fn reference="1">
  <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Hello! denoted as 15 % (m/m).</p>
</fn></p>
<table id="tableD-1" alt="tool tip" summary="long desc">
  <name>Table 1&#xA0;&#x2014; Repeatability and reproducibility of <em>husked</em> rice yield</name>
  <thead>
    <tr>
      <td rowspan="2" align="left">Description</td>
      <td colspan="4" align="center">Rice sample</td>
    </tr>
    </thead>
    <tbody>
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
    </tbody>
</table>
    </foreword>
    </preface>
    </itu-standard>
    INPUT
     expect(File.exist?("test.html")).to be true
    html = File.read("test.html", encoding: "UTF-8")
    expect(xmlpp(html.sub(/^.*<main /m, "<main xmlns:epub='epub' ").sub(%r{</main>.*$}m, "</main>").gsub(%r{<script>.+?</script>}, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <main xmlns:epub='epub' class='main-section'>
  <button onclick='topFunction()' id='myBtn' title='Go to top'>Top</button>
  <div>
    <h1 class='IntroTitle'/>
    <p>
      A.
      <a class='FootnoteRef' href='#fn:2' id='fnref:1'>
        <sup>1</sup>
      </a>
    </p>
    <p>
      B.
      <a class='FootnoteRef' href='#fn:2'>
        <sup>1</sup>
      </a>
    </p>
    <p>
      C.
      <a class='FootnoteRef' href='#fn:1' id='fnref:3'>
        <sup>2</sup>
      </a>
    </p>
    <p class='TableTitle' style='text-align:center;'>
      Table 1&#xA0;&#x2014; Repeatability and reproducibility of
      <i>husked</i>
       rice yield
    </p>
    <table id='tableD-1' class='MsoISOTable' style='border-width:1px;border-spacing:0;' title='tool tip'>
      <caption>
        <span style='display:none'>long desc</span>
      </caption>
      <thead>
        <tr>
          <td rowspan='2' style='text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;' scope='col'>Description</td>
          <td colspan='4' style='text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;' scope='colgroup'>Rice sample</td>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td style='text-align:left;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;'>Arborio</td>
          <td style='text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;'>
            Drago
            <a href='#tableD-1a' class='TableFootnoteRef'>a)</a>
          </td>
          <td style='text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;'>
            Balilla
            <a href='#tableD-1a' class='TableFootnoteRef'>a)</a>
          </td>
          <td style='text-align:center;border-top:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;'>Thaibonnet</td>
        </tr>
      </tbody>
      <tfoot>
        <tr>
          <td colspan='5' style='border-top:0pt;border-bottom:solid windowtext 1.5pt;'>
            <div class='TableFootnote'>
              <div id='fn:tableD-1a'>
                <p id='_0fe65e9a-5531-408e-8295-eeff35f41a55' class='TableFootnote'>
                  <span>
                    <span id='tableD-1a' class='TableFootnoteRef'>a)</span>
                    &#xA0;
                  </span>
                  Parboiled rice.
                </p>
              </div>
            </div>
          </td>
        </tr>
      </tfoot>
    </table>
  </div>
  <p class='zzSTDTitle1'/>
  <p class='zzSTDTitle2'/>
  <aside id='fn:2' class='footnote'>
    <p id='_1e228e29-baef-4f38-b048-b05a051747e4'>
      <a class='FootnoteRef' href='#fn:2'>
        <sup>1</sup>
      </a>
      Formerly denoted as 15 % (m/m).
    </p>
    <a href='#fnref:1'>&#x21A9;</a>
  </aside>
  <aside id='fn:1' class='footnote'>
    <p id='_1e228e29-baef-4f38-b048-b05a051747e4'>
      <a class='FootnoteRef' href='#fn:1'>
        <sup>2</sup>
      </a>
      Hello! denoted as 15 % (m/m).
    </p>
    <a href='#fnref:3'>&#x21A9;</a>
  </aside>
</main>
OUTPUT
  end


  it "cleans up footnotes (Word)" do
    FileUtils.rm_f "test.doc"
    IsoDoc::ITU::WordConvert.new({}).convert("test", <<~"INPUT", false)
    <itu-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
    <p>A.<fn reference="2">
  <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
</fn></p>
    <p>B.<fn reference="2">
  <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
</fn></p>
    <p>C.<fn reference="1">
  <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Hello! denoted as 15 % (m/m).</p>
</fn></p>
<table id="tableD-1" alt="tool tip" summary="long desc">
  <name>Repeatability and reproducibility of <em>husked</em> rice yield</name>
  <thead>
    <tr>
      <td rowspan="2" align="left">Description</td>
      <td colspan="4" align="center">Rice sample</td>
    </tr>
    </thead>
    <tbody>
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
    </tbody>
</table>
    </foreword>
    </preface>
    </itu-standard>
    INPUT
     expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc", encoding: "UTF-8")
expect(xmlpp(html.sub(%r{^.*<div align="center" class="table_container">}m, '').sub(%r{</table>.*$}m, "</table>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
<table class='MsoISOTable' style='mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;' title='tool tip'  summary='long desc'>
  <a name='tableD-1' id='tableD-1'/>
  <thead>
    <tr>
      <td rowspan='2' align='left' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext 1.0pt;' valign='top'>Description</td>
      <td colspan='4' align='center' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' valign='top'>Rice sample</td>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align='left' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' valign='top'>Arborio</td>
      <td align='center' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' valign='top'>
        Drago
        <a href='#tableD-1a' class='TableFootnoteRef'>a)</a>
      </td>
      <td align='center' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' valign='top'>
        Balilla
        <a href='#tableD-1a' class='TableFootnoteRef'>a)</a>
      </td>
      <td align='center' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' valign='top'>Thaibonnet</td>
    </tr>
  </tbody>
  <tfoot>
    <tr>
      <td colspan='5' style='border-top:0pt;mso-border-top-alt:0pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>
        <div class='TableFootnote'>
          <div>
            <a name='ftntableD-1a' id='ftntableD-1a'/>
            <p class='TableFootnote'>
              <a name='_0fe65e9a-5531-408e-8295-eeff35f41a55' id='_0fe65e9a-5531-408e-8295-eeff35f41a55'/>
              <span>
                <span class='TableFootnoteRef'>
                  <a name='tableD-1a' id='tableD-1a'/>
                  a)
                </span>
                <span style='mso-tab-count:1'>&#xA0; </span>
              </span>
              Parboiled rice.
            </p>
          </div>
        </div>
      </td>
    </tr>
  </tfoot>
</table>
OUTPUT

  end


 def itudoc(lang)
<<~"INPUT"
               <itu-standard xmlns="http://riboseinc.com/isoxml">
               <bibdata type="standard">
               <title language="en" format="text/plain" type="main">An ITU Standard</title>
               <title language="fr" format="text/plain" type="main">Un Standard ITU</title>
               <docidentifier type="ITU">12345</docidentifier>
               <language>#{lang}</language>
               <keyword>A</keyword>
               <keyword>B</keyword>
               <ext>
               <doctype>recommendation</doctype>
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

       <terms id="I" obligation="normative">
         <term id="J">
         <preferred>Term2</preferred>
       </term>
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
       </annex><bibliography><references id="R" obligation="informative" normative="true">
         <title>References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative" normative="false">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </itu-standard>
    INPUT
 end

   it "processes annexes and appendixes" do
     input = <<~INPUT
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
              <keyword>A</keyword>
              <keyword>B</keyword>
              <ext>
              <doctype language="">recommendation</doctype>
              <doctype language='en'>Recommendation</doctype>
              </ext>
              </bibdata>
              <preface>
              <abstract>
              <title>Abstract</title>
                  <xref target="A1">Annex A</xref>
                  <xref target="B1">Appendix I</xref>
              </abstract>
              </preface>
       <annex id="A1" obligation="normative"><title><strong>Annex A</strong><br/><br/><strong>Annex</strong></title></annex>
       <annex id="A2" obligation="normative"><title><strong>Annex B</strong><br/><br/><strong>Annex</strong></title></annex>
       <annex id="A3" obligation="normative"><title><strong>Annex C</strong><br/><br/><strong>Annex</strong></title></annex>
       <annex id="A4" obligation="normative"><title><strong>Annex D</strong><br/><br/><strong>Annex</strong></title></annex>
       <annex id="A5" obligation="normative"><title><strong>Annex E</strong><br/><br/><strong>Annex</strong></title></annex>
       <annex id="A6" obligation="normative"><title><strong>Annex F</strong><br/><br/><strong>Annex</strong></title></annex>
       <annex id="A7" obligation="normative"><title><strong>Annex G</strong><br/><br/><strong>Annex</strong></title></annex>
       <annex id="A8" obligation="normative"><title><strong>Annex H</strong><br/><br/><strong>Annex</strong></title></annex>
       <annex id="A9" obligation="normative"><title><strong>Annex J</strong><br/><br/><strong>Annex</strong></title></annex>
       <annex id="A10" obligation="normative"><title><strong>Annex K</strong><br/><br/><strong>Annex</strong></title></annex>
       <annex id="B1" obligation="informative"><title><strong>Appendix I</strong><br/><br/><strong>Annex</strong></title></annex>
       <annex id="B2" obligation="informative"><title><strong>Appendix II</strong><br/><br/><strong>Annex</strong></title></annex>
       <annex id="B3" obligation="informative"><title><strong>Appendix III</strong><br/><br/><strong>Annex</strong></title></annex>
       <annex id="B4" obligation="informative"><title><strong>Appendix IV</strong><br/><br/><strong>Annex</strong></title></annex>
       <annex id="B5" obligation="informative"><title><strong>Appendix V</strong><br/><br/><strong>Annex</strong></title></annex>
       <annex id="B6" obligation="informative"><title><strong>Appendix VI</strong><br/><br/><strong>Annex</strong></title></annex>
       <annex id="B7" obligation="informative"><title><strong>Appendix VII</strong><br/><br/><strong>Annex</strong></title></annex>
       <annex id="B8" obligation="informative"><title><strong>Appendix VIII</strong><br/><br/><strong>Annex</strong></title></annex>
       <annex id="B9" obligation="informative"><title><strong>Appendix IX</strong><br/><br/><strong>Annex</strong></title></annex>
       <annex id="B10" obligation="informative"><title><strong>Appendix X</strong><br/><br/><strong>Annex</strong></title></annex>
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
        <p class="zzSTDTitle1">Recommendation 12345</p>
             <p class="zzSTDTitle2">An ITU Standard</p>
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
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({}).convert("test", input, true).gsub(%r{<localized-strings>.*</localized-strings>}m, ""))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", presxml, true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(html)
       end

      it "processes section names" do

        presxml = <<~OUTPUT
        <itu-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
                <bibdata type="standard">
                <title language="en" format="text/plain" type="main">An ITU Standard</title>
                <title language="fr" format="text/plain" type="main">Un Standard ITU</title>
                <docidentifier type="ITU">12345</docidentifier>
                <language current="true">en</language>
                <keyword>A</keyword>
                <keyword>B</keyword>
                <ext>
                <doctype language="">recommendation</doctype>
                <doctype language='en'>Recommendation</doctype>
                </ext>
                </bibdata>
       <preface>
       <abstract><title>Abstract</title>
       <p>This is an abstract</p>
       </abstract>
       <clause id="A0"><title depth="1">History</title>
       <p>history</p>
       </clause>
       <foreword obligation="informative">
          <title>Foreword</title>
          <p id="A">This is a preamble</p>
        </foreword>
         <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
          <title depth="2">Introduction Subsection</title>
        </clause>
        </introduction></preface><sections>
        <clause id="D" obligation="normative" type="scope">
          <title depth="1">1.<tab/>Scope</title>
          <p id="E">Text</p>
        </clause>

        <terms id="I" obligation="normative"><title>3.</title>
          <term id="J"><name>3.1.</name>
          <preferred>Term2</preferred>
        </term>
        </terms>
        <definitions id="L"><title>4.</title>
          <dl>
          <dt>Symbol</dt>
          <dd>Definition</dd>
          </dl>
        </definitions>
        <clause id="M" inline-header="false" obligation="normative"><title depth="1">5.<tab/>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
          <title depth="2">5.1.<tab/>Introduction</title>
        </clause>
        <clause id="O" inline-header="false" obligation="normative">
          <title depth="2">5.2.<tab/>Clause 4.2</title>
        </clause></clause>

        </sections><annex id="P" inline-header="false" obligation="normative">
          <title><strong>Annex A</strong><br/><br/><strong>Annex</strong></title>
          <clause id="Q" inline-header="false" obligation="normative">
          <title depth="2">A.1.<tab/>Annex A.1</title>
          <clause id="Q1" inline-header="false" obligation="normative">
          <title depth="3">A.1.1.<tab/>Annex A.1a</title>
          </clause>
        </clause>
        </annex><bibliography><references id="R" obligation="informative" normative="true">
          <title depth="1">2.<tab/>References</title>
        </references><clause id="S" obligation="informative">
          <title depth="1">Bibliography</title>
          <references id="T" obligation="informative" normative="false">
          <title depth="2">Bibliography Subsection</title>
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
<div id="A0">
  <h1 class="IntroTitle">History</h1>
  <p>history</p>
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
               <p class="zzSTDTitle1">Recommendation 12345</p>
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
               <div id="J"><p class="TermNum" id="J"><b>3.1.&#160; Term2</b>:</p>

        </div>
             </div>
               <div id="L" class="Symbols">
                 <h1>4.</h1>
                 <dl>
                   <dt>
                     <p>Symbol</p>
                   </dt>
                   <dd>Definition</dd>
                 </dl>
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
           <p>
             <br clear="all" class="section"/>
           </p>
           <div class="WordSection2">
           <div class='Abstract'>
               <h1 class="AbstractTitle">Summary</h1>
               <p>This is an abstract</p>
             </div>
             <div class='Keyword'>
               <h1 class="IntroTitle">Keywords</h1>
               <p>A, B.</p>
             </div>
             <div id="A0">
  <h1 class="IntroTitle">History</h1>
  <p>history</p>
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
             <p>&#160;</p>
           </div>
           <p>
             <br clear="all" class="section"/>
           </p>
           <div class="WordSection3">
             <p class="zzSTDTitle1">Recommendation 12345</p>
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
          <div id="J"><p class="TermNum" id="J"><b>3.1.<span style="mso-tab-count:1">&#160; </span>Term2</b>: </p>
     
        </div>
        </div>
             <div id="L" class="Symbols">
               <h1>4.</h1>
               <table class="dl">
                 <tr>
                   <td valign="top" align="left">
                     <p align="left" style="margin-left:0pt;text-align:left;">Symbol</p>
                   </td>
                   <td valign="top">Definition</td>
                 </tr>
               </table>
             </div>
             <div id="M">
               <h1>5.<span style="mso-tab-count:1">&#160; </span>Clause 4</h1>
               <div id="N"><h2>5.1.<span style="mso-tab-count:1">&#160; </span>Introduction</h2>
     
        </div>
               <div id="O"><h2>5.2.<span style="mso-tab-count:1">&#160; </span>Clause 4.2</h2>
     
        </div>
             </div>
             <p>
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
             <p>
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
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({}).convert("test", itudoc("en"), true).gsub(%r{<localized-strings>.*</localized-strings>}m, ""))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", presxml, true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::ITU::WordConvert.new({}).convert("test", presxml, true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(word)
      end

            it "processes section names in French" do
              presxml = <<~OUTPUT
              <itu-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
                 <bibdata type="standard">
                 <title language="en" format="text/plain" type="main">An ITU Standard</title>
                 <title language="fr" format="text/plain" type="main">Un Standard ITU</title>
                 <docidentifier type="ITU">12345</docidentifier>
                 <language current="true">fr</language>
                 <keyword>A</keyword>
                 <keyword>B</keyword>
                 <ext>
                 <doctype language="">recommendation</doctype>
                 <doctype language='fr'>Recommendation</doctype>
                 </ext>
                 </bibdata>
        <preface>
        <abstract><title>Abstract</title>
        <p>This is an abstract</p>
        </abstract>
        <clause id="A0"><title depth="1">History</title>
        <p>history</p>
        </clause>
        <foreword obligation="informative">
           <title>Foreword</title>
           <p id="A">This is a preamble</p>
         </foreword>
          <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
           <title depth="2">Introduction Subsection</title>
         </clause>
         </introduction></preface><sections>
         <clause id="D" obligation="normative" type="scope">
           <title depth="1">1.<tab/>Scope</title>
           <p id="E">Text</p>
         </clause>

         <terms id="I" obligation="normative"><title>3.</title>
           <term id="J"><name>3.1.</name>
           <preferred>Term2</preferred>
         </term>
         </terms>
         <definitions id="L"><title>4.</title>
           <dl>
           <dt>Symbol</dt>
           <dd>Definition</dd>
           </dl>
         </definitions>
         <clause id="M" inline-header="false" obligation="normative"><title depth="1">5.<tab/>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
           <title depth="2">5.1.<tab/>Introduction</title>
         </clause>
         <clause id="O" inline-header="false" obligation="normative">
           <title depth="2">5.2.<tab/>Clause 4.2</title>
         </clause></clause>

         </sections><annex id="P" inline-header="false" obligation="normative">
           <title><strong>Annexe A</strong><br/><br/><strong>Annex</strong></title>
           <clause id="Q" inline-header="false" obligation="normative">
           <title depth="2">A.1.<tab/>Annex A.1</title>
           <clause id="Q1" inline-header="false" obligation="normative">
           <title depth="3">A.1.1.<tab/>Annex A.1a</title>
           </clause>
         </clause>
         </annex><bibliography><references id="R" obligation="informative" normative="true">
           <title depth="1">2.<tab/>References</title>
         </references><clause id="S" obligation="informative">
           <title depth="1">Bibliography</title>
           <references id="T" obligation="informative" normative="false">
           <title depth="2">Bibliography Subsection</title>
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
<div id="A0">
  <h1 class="IntroTitle">History</h1>
  <p>history</p>
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
               <p class="zzSTDTitle1">Recommendation 12345</p>
               <p class="zzSTDTitle2">Un Standard ITU</p>
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
               <div id="J"><p class="TermNum" id="J"><b>3.1.&#160; Term2</b>:</p>

        </div>
             </div>
               <div id="L" class="Symbols">
                 <h1>4.</h1>
                 <dl>
                   <dt>
                     <p>Symbol</p>
                   </dt>
                   <dd>Definition</dd>
                 </dl>
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
                 <h1 class="Annex"><b>Annexe A</b> <br/><br/><b>Annex</b></h1>
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
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({}).convert("test", itudoc("fr"), true).gsub(%r{<localized-strings>.*</localized-strings>}m, ""))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::ITU::HtmlConvert.new({}).convert("test", presxml, true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(html)
  end

            it "post-processes section names (Word)" do
              FileUtils.rm_f "test.doc"
    IsoDoc::ITU::WordConvert.new({}).convert("test", <<~INPUT, false)
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
       <clause id="D" obligation="normative" type="scope">
         <title>1<tab/>Scope</title>
         <p id="E">Text</p>
         <figure id="fig-f1-1">
  <name>Static aspects of SDL‑2010</name>
  </figure>
  <p>Hello</p>
  <figure id="fig-f1-2">
  <name>Static aspects of SDL‑2010</name>
  </figure>
  <note><p>Hello</p></note>
       </clause>
       </sections>
        <annex id="P" inline-header="false" obligation="normative">
         <title><strong>Annex A</strong><br/><br/><strong>Annex 1</strong></title>
         <clause id="Q" inline-header="false" obligation="normative">
         <title>A.1<tab/>Annex A.1</title>
         <p>Hello</p>
         </clause>
       </annex>
           <annex id="P1" inline-header="false" obligation="normative">
         <title><strong>Annex B</strong><br/><br/><strong>Annex 2</strong></title>
         <p>Hello</p>
         <clause id="Q1" inline-header="false" obligation="normative">
         <title>B.1<tab/>Annex A1.1</title>
         <p>Hello</p>
         </clause>
         </clause>
       </annex>
       </itu-standard>
    INPUT
     expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc", encoding: "UTF-8")
expect(xmlpp(html.sub(%r{^.*<div class="WordSection3">}m, %{<body><div class="WordSection3">}).gsub(%r{</body>.*$}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
<body><div class="WordSection3">
      <p class="zzSTDTitle1">Recommendation 12345</p>
      <p class="zzSTDTitle2">An ITU Standard</p>
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

  it "injects JS into blank html" do
    FileUtils.rm_f "test.html"
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-pdf:
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r{jquery\.min\.js})
    expect(html).to match(%r{Times New Roman})
    expect(html).to match(%r{<main class="main-section"><button})
  end

    it "processes eref types" do
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{<localized-strings>.*</localized-strings>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <itu-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p>
    <eref type="footnote" bibitemid="ISO712" citeas="ISO 712">A</eref>
    <eref type="inline" bibitemid="ISO712" citeas="ISO 712">A</eref>
    <eref type="footnote" bibitemid="ISO712" citeas="ISO 712"></eref>
    <eref type="inline" bibitemid="ISO712" citeas="ISO 712"></eref>
    <eref type="footnote" bibitemid="ISO712" citeas="ISO 712"><locality type="section"><referenceFrom>8</referenceFrom></locality></eref>
    <eref type="inline" bibitemid="ISO712" citeas="ISO 712"><locality type="section"><referenceFrom>8</referenceFrom></locality></eref>
    <eref type="inline" bibitemid="ISO712" citeas="ISO 712"><localityStack><locality type="section"><referenceFrom>8</referenceFrom></locality></localityStack><localityStack><locality type="section"><referenceFrom>10</referenceFrom></locality></localityStack></eref>
    </p>
    </foreword></preface>
    <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>References</title>
<bibitem id="ISO712" type="standard">
  <title format="text/plain">Cereals and cereal products</title>
  <docidentifier>ISO 712</docidentifier>
  <date type="published">2019-01-01</date>
  <contributor>
    <role type="publisher"/>
    <organization>
      <abbreviation>ISO</abbreviation>
    </organization>
  </contributor>
</bibitem>
    </references>
    </bibliography>
    </itu-standard>
    INPUT
          <?xml version='1.0'?>
 <itu-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
   <preface>
     <foreword>
       <p>
         <eref type='footnote' bibitemid='ISO712' citeas='ISO 712'>A</eref>
         <eref type='inline' bibitemid='ISO712' citeas='ISO 712'>A</eref>
         <eref type='footnote' bibitemid='ISO712' citeas='ISO 712'>[ISO 712]</eref>
         <eref type='inline' bibitemid='ISO712' citeas='ISO 712'>[ISO 712]</eref>
         <eref type='footnote' bibitemid='ISO712' citeas='ISO 712'>
           <locality type='section'>
             <referenceFrom>8</referenceFrom>
           </locality>
           [ISO 712], Section 8
         </eref>
         <eref type='inline' bibitemid='ISO712' citeas='ISO 712'>
           <locality type='section'>
             <referenceFrom>8</referenceFrom>
           </locality>
           [ISO 712], Section 8
         </eref>
         <eref type='inline' bibitemid='ISO712' citeas='ISO 712'>
           <localityStack>
             <locality type='section'>
               <referenceFrom>8</referenceFrom>
             </locality>
           </localityStack>
           <localityStack>
             <locality type='section'>
               <referenceFrom>10</referenceFrom>
             </locality>
           </localityStack>
           [ISO 712], Section 8; Section 10
         </eref>
       </p>
     </foreword>
   </preface>
   <bibliography>
     <references id='_normative_references' obligation='informative' normative='true'>
     <title depth='1'>
  1.
  <tab/>
  References
</title>
       <bibitem id='ISO712' type='standard'>
         <title format='text/plain'>Cereals and cereal products</title>
         <docidentifier>ISO 712</docidentifier>
         <date type='published'>2019-01-01</date>
         <contributor>
           <role type='publisher'/>
           <organization>
             <abbreviation>ISO</abbreviation>
           </organization>
         </contributor>
       </bibitem>
     </references>
   </bibliography>
 </itu-standard>
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
    <itu-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
          <bibdata type='standard'>
            <title language='en' format='text/plain' type='main'>An ITU Standard</title>
            <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
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
          <annex id='A1' obligation='normative'>
            <title>
              <strong>Annex F2</strong>
              <br/>
              <br/>
              <strong>Annex</strong>
            </title>
            <clause id='A2'>
              <title depth='2'>F2.1.<tab/>Subtitle</title>
              <table id='T'>
                <name>Table F2.1</name>
              </table>
              <figure id='U'>
                <name>Figure F2.1</name>
              </figure>
              <formula id='V'>
                <name>F2-1</name>
                <stem type='AsciiMath'>r = 1 %</stem>
              </formula>
            </clause>
          </annex>
        </itu-standard>
OUTPUT
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({}).convert("test", input, true).gsub(%r{<localized-strings>.*</localized-strings>}m, ""))).to be_equivalent_to xmlpp(presxml)
             IsoDoc::ITU::HtmlConvert.new({}).convert("test", presxml, false)
             html = File.read("test.html", encoding: "utf-8")
    expect(xmlpp(html.gsub(%r{^.*<main}m, "<main").gsub(%r{</main>.*}m, "</main>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <main class='main-section'>
         <button onclick='topFunction()' id='myBtn' title='Go to top'>Top</button>
         <p class='zzSTDTitle1'>Recommendation 12345</p>
         <p class='zzSTDTitle2'>An ITU Standard</p>
         <p class='zzSTDTitle3'>Subtitle</p>
         <div id='A1' class='Section3'>
           <p class='h1Annex'>
             <b>Annex F2</b>
             <br/>
             <br/>
             <b>Annex</b>
           </p>
           <p class='annex_obligation'>(This annex forms an integral part of this Recommendation.)</p>
           <div id='A2'>
             <h2 id='toc0'>F2.1.&#xA0; Subtitle</h2>
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

             IsoDoc::ITU::WordConvert.new({}).convert("test", presxml, false)
             html = File.read("test.doc", encoding: "utf-8")
    expect(xmlpp(html.gsub(%r{^.*<div class="WordSection3">}m, '<div class="WordSection3" xmlns:m="http://schemas.microsoft.com/office/2004/12/omml">').gsub(%r{<div style="mso-element:footnote-list"/>.*}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <div class='WordSection3' xmlns:m='http://schemas.microsoft.com/office/2004/12/omml'>
          <p class='zzSTDTitle1'>Recommendation 12345</p>
          <p class='zzSTDTitle2'>An ITU Standard</p>
          <p class='zzSTDTitle3'>Subtitle</p>
          <div class='Section3'>
            <a name='A1' id='A1'/>
            <p class='h1Annex'>
              <b>Annex F2</b>
              <br/>
              <br/>
              <b>Annex</b>
            </p>
            <p class='annex_obligation'>(This annex forms an integral part of this Recommendation.)</p>
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
                    <span class='stem'>
                      <m:oMath>
                        <m:r>
                          <m:t>r=1%</m:t>
                        </m:r>
                      </m:oMath>
                    </span>
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
      IsoDoc::ITU::WordConvert.new({}).convert("test", <<~"INPUT", false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><clause id="_history" obligation="normative">
  <title>History</title>
  <table id="_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4">
  <name>Table 1</name>
  <tbody>
    <tr>
      <td align="left">Edition</td>
      <td align="left">Recommendation</td>
      <td align="left">Approval</td>
      <td align="left">Study Group</td>
      <td align="left">Unique ID<fn reference="a">
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
      expect(xmlpp(html.gsub(%r{.*<p class="h1Preface">History</p>}m, '<div><p class="h1Preface">History</p>').sub(%r{</table>.*$}m, "</table></div></div>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
                       <td align="left" style="" valign="top">Unique ID<a href="#_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4a" class="TableFootnoteRef">a)</a>.</td>
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
                 <tfoot><tr><td colspan="5" style=""><div class="TableFootnote"><div><a name="ftn_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4a" id="ftn_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4a"></a>
         <p class="TableFootnote"><a name="_8a4ff03f-e7a6-4430-939d-1b7b0ffa60e9" id="_8a4ff03f-e7a6-4430-939d-1b7b0ffa60e9"></a><span><span class="TableFootnoteRef"><a name="_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4a" id="_5c4d4e85-b6b0-4f34-b1ed-57d28c4e88d4a"></a>a)</span><span style="mso-tab-count:1">&#xA0; </span></span>To access the Recommendation, type the URL <a href="http://handle.itu.int/" class="url">http://handle.itu.int/</a> in the address field of your web browser, followed by the Recommendation?~@~Ys unique ID. For example, <a href="http://handle.itu.int/11.1002/1000/11830-en" class="url">http://handle.itu.int/11.1002/1000/11830-en</a></p>
       </div></div></td></tr></tfoot></table>
       </div></div>
      OUTPUT
    end




it "processes erefs and xrefs and links (Word)" do
    expect(xmlpp(IsoDoc::ITU::WordConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
<iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p>
    <eref type="footnote" bibitemid="ISO712" citeas="ISO 712">A</stem>
    <eref type="inline" bibitemid="ISO712" citeas="ISO 712">A</stem>
    <xref target="_http_1_1">Requirement <tt>/req/core/http</tt></xref>
    <link target="http://www.example.com">Test</link>
    <link target="http://www.example.com"/>
    </p>
    </foreword></preface>
    <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>References</title>
<bibitem id="ISO712" type="standard">
  <title format="text/plain">Cereals and cereal products</title>
  <docidentifier>ISO 712</docidentifier>
  <contributor>
    <role type="publisher"/>
    <organization>
      <abbreviation>ISO</abbreviation>
    </organization>
  </contributor>
</bibitem>
    </references>
    </bibliography>
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
      <p>
      <sup>
  <a href='#ISO712'>A</a>
</sup>
<a href='#ISO712'>A</a>
<a href='#_http_1_1'>
  Requirement 
  <tt>/req/core/http</tt>
</a>
<a href='http://www.example.com' class='url'>Test</a>
<a href='http://www.example.com' class='url'>http://www.example.com</a>
      </p>
    </div>
    <p>&#160;</p>
  </div>
  <p>
    <br clear='all' class='section'/>
  </p>
  <div class='WordSection3'>
    <p class='zzSTDTitle1'/>
    <p class='zzSTDTitle2'/>
    <div>
      <h1>References</h1>
       <table class='biblio' border='0'>
   <tbody>
     <tr id='ISO712' class='NormRef'>
       <td  style='vertical-align:top'>[ISO&#160;712]</td>
       <td>
         ISO 712,
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
end



    it "processes boilerplate" do
      FileUtils.rm_f "test.html"
    IsoDoc::ITU::HtmlConvert.new({}).convert("test", <<~"INPUT", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    #{BOILERPLATE}
    </iso-standard>
    INPUT
        expect(xmlpp(File.read("test.html", encoding: "utf-8").gsub(%r{^.*<div class="prefatory-section">}m, '<div class="prefatory-section">').gsub(%r{<nav>.*}m, "</div>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
        <div class='prefatory-section'>
         <div class='boilerplate-legal'>
           <div>
             <h1 class='IntroTitle'>FOREWORD</h1>
             <p id='_'>
               The International Telecommunication Union (ITU) is the United Nations
               specialized agency in the field of telecommunications , information and
               communication technologies (ICTs). The ITU Telecommunication
               Standardization Sector (ITU-T) is a permanent organ of ITU. ITU-T is
               responsible for studying technical, operating and tariff questions and
               issuing Recommendations on them with a view to standardizing
               telecommunications on a worldwide basis.
             </p>
             <p id='_'>
               The World Telecommunication Standardization Assembly (WTSA), which meets
               every four years, establishes the topics for study by the ITU T study
               groups which, in turn, produce Recommendations on these topics.
             </p>
             <p id='_'>
               The approval of ITU-T Recommendations is covered by the procedure laid
               down in WTSA Resolution 1 .
             </p>
             <p id='_'>
               In some areas of information technology which fall within ITU-T's
               purview, the necessary standards are prepared on a collaborative basis
               with ISO and IEC.
             </p>
             <div>
               <h2 class='IntroTitle'>NOTE</h2>
               <p id='_'>
                 In this Recommendation, the expression "Administration" is used for
                 conciseness to indicate both a telecommunication administration and a
                 recognized operating agency .
               </p>
               <p id='_'>
                 Compliance with this Recommendation is voluntary. However, the
                 Recommendation may contain certain mandatory provisions (to ensure,
                 e.g., interoperability or applicability) and compliance with the
                 Recommendation is achieved when all of these mandatory provisions are
                 met. The words "shall" or some other obligatory language such as
                 "must" and the negative equivalents are used to express requirements.
                 The use of such words does not suggest that compliance with the
                 Recommendation is required of any party .
               </p>
             </div>
           </div>
         </div>
         <div class='boilerplate-license'>
           <div>
             <h1 class='IntroTitle'>INTELLECTUAL PROPERTY RIGHTS</h1>
             <p id='_'>
               ITU draws attention to the possibility that the practice or
               implementation of this Recommendation may involve the use of a claimed
               Intellectual Property Right. ITU takes no position concerning the
               evidence, validity or applicability of claimed Intellectual Property
               Rights, whether asserted by ITU members or others outside of the
               Recommendation development process.
             </p>
             <p id='_'>
               As of the date of approval of this Recommendation, ITU had received
               notice of intellectual property, protected by patents, which may be
               required to implement this Recommendation. However, implementers are
               cautioned that this may not represent the latest information and are
               therefore strongly urged to consult the TSB patent database at
               <a href='http://www.itu.int/ITU-T/ipr/'>http://www.itu.int/ITU-T/ipr/</a>
               .
             </p>
           </div>
         </div>
       </div>
    OUTPUT
    end

        it "processes boilerplate (Word)" do
      FileUtils.rm_f "test.doc"
    IsoDoc::ITU::WordConvert.new({}).convert("test", <<~"INPUT", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    #{BOILERPLATE}
    </iso-standard>
    INPUT
        expect(xmlpp(File.read("test.doc", encoding: "utf-8").gsub(%r{^.*<div class="boilerplate-legal">}m, '<div><div class="boilerplate-legal">').gsub(%r{<b>Table of Contents</b></p>.*}m, "<b>Table of Contents</b></p></div>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
               <div>
         <div class='boilerplate-legal'>
           <div>
             <p class='boilerplateHdr'>FOREWORD</p>
             <p class='boilerplate'>
               <a name='_' id='_'/>
               The International Telecommunication Union (ITU) is the United Nations
               specialized agency in the field of telecommunications , information and
               communication technologies (ICTs). The ITU Telecommunication
               Standardization Sector (ITU-T) is a permanent organ of ITU. ITU-T is
               responsible for studying technical, operating and tariff questions and
               issuing Recommendations on them with a view to standardizing
               telecommunications on a worldwide basis.
             </p>
             <p class='boilerplate'>
               <a name='_' id='_'/>
               The World Telecommunication Standardization Assembly (WTSA), which meets
               every four years, establishes the topics for study by the ITU T study
               groups which, in turn, produce Recommendations on these topics.
             </p>
             <p class='boilerplate'>
               <a name='_' id='_'/>
               The approval of ITU-T Recommendations is covered by the procedure laid
               down in WTSA Resolution 1 .
             </p>
             <p class='boilerplate'>
               <a name='_' id='_'/>
               In some areas of information technology which fall within ITU-T's
               purview, the necessary standards are prepared on a collaborative basis
               with ISO and IEC.
             </p>
             <div>
               <p class='boilerplateHdr'>NOTE</p>
               <p class='boilerplate'>
                 <a name='_' id='_'/>
                 In this Recommendation, the expression "Administration" is used for
                 conciseness to indicate both a telecommunication administration and a
                 recognized operating agency .
               </p>
               <p class='boilerplate'>
                 <a name='_' id='_'/>
                 Compliance with this Recommendation is voluntary. However, the
                 Recommendation may contain certain mandatory provisions (to ensure,
                 e.g., interoperability or applicability) and compliance with the
                 Recommendation is achieved when all of these mandatory provisions are
                 met. The words "shall" or some other obligatory language such as
                 "must" and the negative equivalents are used to express requirements.
                 The use of such words does not suggest that compliance with the
                 Recommendation is required of any party .
               </p>
             </div>
           </div>
           <p class='MsoNormal'>&#xA0;</p>
           <p class='MsoNormal'>&#xA0;</p>
           <p class='MsoNormal'>&#xA0;</p>
         </div>
         <div class='boilerplate-license'>
           <div>
             <p class='boilerplateHdr'>INTELLECTUAL PROPERTY RIGHTS</p>
             <p class='boilerplate'>
               <a name='_' id='_'/>
               ITU draws attention to the possibility that the practice or
               implementation of this Recommendation may involve the use of a claimed
               Intellectual Property Right. ITU takes no position concerning the
               evidence, validity or applicability of claimed Intellectual Property
               Rights, whether asserted by ITU members or others outside of the
               Recommendation development process.
             </p>
             <p class='boilerplate'>
               <a name='_' id='_'/>
               As of the date of approval of this Recommendation, ITU had received
               notice of intellectual property, protected by patents, which may be
               required to implement this Recommendation. However, implementers are
               cautioned that this may not represent the latest information and are
               therefore strongly urged to consult the TSB patent database at
               <a href='http://www.itu.int/ITU-T/ipr/' class='url'>http://www.itu.int/ITU-T/ipr/</a>
               .
             </p>
           </div>
           <p class='MsoNormal'>&#xA0;</p>
           <p class='MsoNormal'>&#xA0;</p>
           <p class='MsoNormal'>&#xA0;</p>
         </div>
         <div class='boilerplate-copyright'>
           <div>
             <p class='boilerplateHdr'>
               <a name='_' id='_'/>
               &#xA9; ITU 2020
             </p>
             <p class='boilerplate'>
               <a name='_' id='_'/>
               All rights reserved. No part of this publication may be reproduced, by
               any means whatsoever, without the prior written permission of ITU.
             </p>
           </div>
         </div>
         <b style='mso-bidi-font-weight:normal'>
           <span lang='EN-US' xml:lang='EN-US' style='font-size:12.0pt;&#10;mso-bidi-font-size:10.0pt;font-family:&quot;Times New Roman&quot;,serif;mso-fareast-font-family:&#10;&quot;Times New Roman&quot;;mso-ansi-language:EN-US;mso-fareast-language:EN-US;&#10;mso-bidi-language:AR-SA'>
             <br clear='all' style='page-break-before:always'/>
           </span>
         </b>
         <p class='MsoNormal' align='center' style='text-align:center'>
           <b>Table of Contents</b>
         </p>
       </div>
    OUTPUT
    end

        it "processes lists within tables (Word)" do
            FileUtils.rm_f "test.doc"
    IsoDoc::ITU::WordConvert.new({}).convert("test", <<~"INPUT", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <clause id="A">
          <table id="_2a8bd899-ab80-483a-90dc-002b6f497f54">
<thead>
<tr>
<th align="left">A</th>
<th align="left">B</th>
</tr>
</thead>
<tbody>
<tr>
<td align="left">C</td>
<td align="left">
<ul id="_7c74d800-bac5-48d9-919a-fcf0a56b6891">
<li>
<p id="_32b6b048-26ad-4bce-a544-b3862aa5fa19">A</p>
<ul id="_62c437de-18c8-44b0-8c2c-749946c54b4e">
<li>
<p id="_7289e3c0-ad96-4f5f-ba55-d91b2349f1b5">B</p>
<ul id="_a3a4be14-120c-4d88-a298-5f9130d0bb9a">
<li>
<p id="_41ac8144-9892-4510-a538-4a1b8de72884">C</p>
</li>
</ul>
</li>
</ul>
</li>
</ul>
</td>
</tr>
</tbody>
<note id="_cf69f8ff-21f2-4ce9-aefb-0bebf988b8fa">
<p id="_a510f7c5-1d32-47b2-8937-e827c7bf459a">B</p>
</note></table>
</clause>
</preface>
    </iso-standard>
    INPUT
    expect(File.exist?("test.doc")).to be true
    html = File.read("test.doc", encoding: "UTF-8")
expect(xmlpp(html.sub(%r{^.*<div align="center" class="table_container">}m, '').sub(%r{</table>.*$}m, "</table>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
<table class='MsoISOTable' style='mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;'>
  <a name='_2a8bd899-ab80-483a-90dc-002b6f497f54' id='_2a8bd899-ab80-483a-90dc-002b6f497f54'/>
  <thead>
    <tr>
      <th align='left' style='font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' valign='top'>A</th>
      <th align='left' style='font-weight:bold;border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' valign='top'>B</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align='left' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' valign='top'>C</td>
      <td align='left' style='border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;' valign='top'>
        <p style='margin-left: 0.5cm;text-indent: -0.5cm;;mso-list:l3 level1 lfo1;' class='MsoListParagraphCxSpFirst'>
           A
          <p style='margin-left: 1.0cm;text-indent: -0.5cm;;mso-list:l3 level2 lfo1;' class='MsoListParagraphCxSpFirst'>
             B
            <p style='margin-left: 1.5cm;text-indent: -0.5cm;;mso-list:l3 level3 lfo1;' class='MsoListParagraphCxSpFirst'> C </p>
          </p>
        </p>
      </td>
    </tr>
  </tbody>
  <tfoot>
    <tr>
      <td colspan='2' style='border-top:0pt;mso-border-top-alt:0pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;'>
        <div class='Note'>
          <a name='_cf69f8ff-21f2-4ce9-aefb-0bebf988b8fa' id='_cf69f8ff-21f2-4ce9-aefb-0bebf988b8fa'/>
          <p class='Note'>B</p>
        </div>
      </td>
    </tr>
  </tfoot>
</table>
    OUTPUT
   end

it "localises numbers in MathML" do
   expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new({}).convert("test", <<~INPUT, true)).sub(%r{<localized-strings>.*</localized-strings>}m, "")).to be_equivalent_to xmlpp(<<~OUTPUT)
   <iso-standard xmlns="http://riboseinc.com/isoxml">
   <bibdata>
        <title language="en">test</title>
        </bibdata>
        <preface>
        <p><stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mn>30000</mn></math></stem>
        <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>P</mi><mfenced open="(" close=")"><mrow><mi>X</mi><mo>≥</mo><msub><mrow><mi>X</mi></mrow><mrow><mo>max</mo></mrow></msub></mrow></mfenced><mo>=</mo><munderover><mrow><mo>∑</mo></mrow><mrow><mrow><mi>j</mi><mo>=</mo><msub><mrow><mi>X</mi></mrow><mrow><mo>max</mo></mrow></msub></mrow></mrow><mrow><mn>1000</mn></mrow></munderover><mfenced open="(" close=")"><mtable><mtr><mtd><mn>1000</mn></mtd></mtr><mtr><mtd><mi>j</mi></mtd></mtr></mtable></mfenced><msup><mrow><mi>p</mi></mrow><mrow><mi>j</mi></mrow></msup><msup><mrow><mfenced open="(" close=")"><mrow><mn>1</mn><mo>−</mo><mi>p</mi></mrow></mfenced></mrow><mrow><mrow><mn>1.003</mn><mo>−</mo><mi>j</mi></mrow></mrow></msup></math></stem></p>
        </preface>
   </iso-standard>
  INPUT
<iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
         <bibdata>
           <title language='en'>test</title>
         </bibdata>
         
         <preface>
           <p>
             <stem type='MathML'>30'000</stem>
             <stem type='MathML'>
               <math xmlns='http://www.w3.org/1998/Math/MathML'>
                 <mi>P</mi>
                 <mfenced open='(' close=')'>
                   <mrow>
                     <mi>X</mi>
                     <mo>&#x2265;</mo>
                     <msub>
                       <mrow>
                         <mi>X</mi>
                       </mrow>
                       <mrow>
                         <mo>max</mo>
                       </mrow>
                     </msub>
                   </mrow>
                 </mfenced>
                 <mo>=</mo>
                 <munderover>
                   <mrow>
                     <mo>&#x2211;</mo>
                   </mrow>
                   <mrow>
                     <mrow>
                       <mi>j</mi>
                       <mo>=</mo>
                       <msub>
                         <mrow>
                           <mi>X</mi>
                         </mrow>
                         <mrow>
                           <mo>max</mo>
                         </mrow>
                       </msub>
                     </mrow>
                   </mrow>
                   <mrow>
                     <mn>1'000</mn>
                   </mrow>
                 </munderover>
                 <mfenced open='(' close=')'>
                   <mtable>
                     <mtr>
                       <mtd>
                         <mn>1'000</mn>
                       </mtd>
                     </mtr>
                     <mtr>
                       <mtd>
                         <mi>j</mi>
                       </mtd>
                     </mtr>
                   </mtable>
                 </mfenced>
                 <msup>
                   <mrow>
                     <mi>p</mi>
                   </mrow>
                   <mrow>
                     <mi>j</mi>
                   </mrow>
                 </msup>
                 <msup>
                   <mrow>
                     <mfenced open='(' close=')'>
                       <mrow>
                         <mn>1</mn>
                         <mo>&#x2212;</mo>
                         <mi>p</mi>
                       </mrow>
                     </mfenced>
                   </mrow>
                   <mrow>
                     <mrow>
                       <mn>1.003</mn>
                       <mo>&#x2212;</mo>
                       <mi>j</mi>
                     </mrow>
                   </mrow>
                 </msup>
               </math>
             </stem>
           </p>
         </preface>
       </iso-standard>
OUTPUT
end

end

require "spec_helper"
require "fileutils"

logoloc = File.expand_path(
  File.join(File.dirname(__FILE__), "..", "..", "lib", "isodoc", "itu", "html"),
)

RSpec.describe Metanorma::ITU do
  it "processes default metadata" do
    csdc = IsoDoc::ITU::HtmlConvert.new({})
    docxml, = csdc.convert_init(<<~"INPUT", "test", true)
      <itu-standard xmlns="https://www.calconnect.org/standards/itu">
        <bibdata type="standard">
        <title language="en" format="text/plain" type="main">Main Title<br/>in multiple lines</title>
        <title language="en" format="text/plain" type="annex">Annex Title</title>
        <title language="fr" format="text/plain" type="main">Titre Principal</title>
        <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
      <title language='fr' format='text/plain' type='subtitle'>Soustitre</title>
      <title language='en' format='text/plain' type='amendment'>Amendment Title</title>
      <title language='fr' format='text/plain' type='amendment'>Titre de Amendment</title>
      <title language='en' format='text/plain' type='corrigendum'>Corrigendum Title</title>
      <title language='fr' format='text/plain' type='corrigendum'>Titre de Corrigendum</title>
        <docidentifier type="ITU-provisional">ABC</docidentifier>
        <docidentifier type="ITU-TemporaryDocument">SG1</docidentifier>
        <docidentifier type="ITU">ITU-R 1000</docidentifier>
        <docidentifier type="ITU-lang">ITU-R 1000-E</docidentifier>
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
    expect(htmlencode(metadata(csdc.info(docxml, nil)).to_s
      .gsub(/, :/, ",\n:"))).to be_equivalent_to <<~"OUTPUT"
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
        :docnumber_lang=>"ITU-R 1000-E",
        :docnumber_td=>"SG1",
        :docnumeric=>"1000",
        :docsubtitle=>"Subtitle",
        :doctitle=>"Main Title<br/>in multiple lines",
        :doctype=>"Directive",
        :doctype_display=>"Directive",
        :doctype_original=>"directive",
        :docyear=>"2001",
        :draft=>"3.4",
        :draft_new_doctype=>"Draft new Directive",
        :draftinfo=>" (draft 3.4, 2000-01-01)",
        :edition=>"2",
        :group=>"I",
        :implementeddate=>"XXX",
        :ip_notice_received=>"false",
        :issueddate=>"XXX",
        :iteration=>"3",
        :keywords=>["word1", "word2"],
        :lang=>"en",
        :logo_comb=>"#{File.join(logoloc, 'itu-document-comb.png')}",
        :logo_html=>"#{File.join(logoloc, '/International_Telecommunication_Union_Logo.svg')}",
        :logo_sp=>"#{File.join(logoloc, '/logo-sp.png')}",
        :logo_word=>"#{File.join(logoloc, 'International_Telecommunication_Union_Logo.svg')}",
        :obsoleteddate=>"XXX",
        :placedate_year=>"Geneva, 2018",
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
    docxml, = csdc.convert_init(<<~"INPUT", "test", true)
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
               <meeting-place>Kronos</meeting-place>
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
    expect(htmlencode(metadata(csdc.info(docxml, nil)).to_s
      .gsub(/, :/, ",\n:"))).to be_equivalent_to <<~"OUTPUT"
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
        :doctype_abbreviated=>"TR",
        :doctype_display=>"Technical Report",
        :doctype_original=>"technical-report",
        :docyear=>"2001",
        :draft=>"5",
        :draft_new_doctype=>"Draft new Technical Report",
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
        :logo_comb=>"#{File.join(logoloc, 'itu-document-comb.png')}",
        :logo_html=>"#{File.join(logoloc, '/International_Telecommunication_Union_Logo.svg')}",
        :logo_sp=>"#{File.join(logoloc, '/logo-sp.png')}",
        :logo_word=>"#{File.join(logoloc, 'International_Telecommunication_Union_Logo.svg')}",
        :meeting=>"Meeting X",
        :meeting_acronym=>"Meeting X",
        :meeting_date=>"01 Jan 2000/02 Jan 2000",
        :meeting_place=>"Kronos",
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

  it "processes default metadata for resolution" do
    csdc = IsoDoc::ITU::HtmlConvert.new({})
    docxml, = csdc.convert_init(<<~"INPUT", "test", true)
      <itu-standard xmlns='https://www.metanorma.org/ns/itu' type='semantic' version='1.2.4'>
           <bibdata type='standard'>
             <title language='en' format='text/plain' type='main'>Main Title</title>
             <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
             <docidentifier type='ITU'>ITU-R 1000</docidentifier>
             <docnumber>1000</docnumber>
             <contributor>
               <role type='author'/>
               <organization> <name>International Telecommunication Union</name> </organization>
             </contributor>
             <contributor>
               <role type='publisher'/>
               <organization> <name>International Telecommunication Union</name> </organization>
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
                 <organization> <name>International Telecommunication Union</name> </organization>
               </owner>
             </copyright>
             <keyword>Word1</keyword>
             <keyword>word2</keyword>
             <ext>
               <doctype>resolution</doctype>
               <editorialgroup>
                 <bureau>R</bureau>
               </editorialgroup>
               <meeting acronym='MX'>Meeting X</meeting>
               <meeting-place>Kronos</meeting-place>
               <meeting-date>
                 <on>2000-01-01</on>
               </meeting-date>
               <structuredidentifier>
                 <bureau>R</bureau>
                 <docnumber>1000</docnumber>
               </structuredidentifier>
             </ext>
           </bibdata>
           <sections> </sections>
         </itu-standard>
    INPUT
    expect(htmlencode(metadata(csdc.info(docxml, nil)).to_s
      .gsub(/, :/, ",\n:"))).to be_equivalent_to <<~"OUTPUT"
        {:accesseddate=>"XXX",
        :agency=>"International Telecommunication Union",
        :bureau=>"R",
        :circulateddate=>"XXX",
        :confirmeddate=>"XXX",
        :copieddate=>"XXX",
        :createddate=>"XXX",
        :docnumber=>"ITU-R 1000",
        :docnumeric=>"1000",
        :docsubtitle=>"Subtitle",
        :doctitle=>"Main Title",
        :doctype=>"Resolution",
        :doctype_display=>"Resolution",
        :doctype_original=>"resolution",
        :docyear=>"2001",
        :draft=>"5",
        :draft_new_doctype=>"Draft new Resolution",
        :draftinfo=>" (draft 5, 2000-01-01)",
        :edition=>"2",
        :implementeddate=>"XXX",
        :ip_notice_received=>"false",
        :issueddate=>"XXX",
        :keywords=>["Word1", "word2"],
        :lang=>"en",
        :logo_comb=>"#{File.join(logoloc, 'itu-document-comb.png')}",
        :logo_html=>"#{File.join(logoloc, '/International_Telecommunication_Union_Logo.svg')}",
        :logo_sp=>"#{File.join(logoloc, '/logo-sp.png')}",
        :logo_word=>"#{File.join(logoloc, 'International_Telecommunication_Union_Logo.svg')}",
        :meeting=>"Meeting X",
        :meeting_acronym=>"MX",
        :meeting_date=>"1 January 2000",
        :meeting_place=>"Kronos",
        :obsoleteddate=>"XXX",
        :placedate_year=>"Geneva, 2001",
        :publisheddate=>"XXX",
        :publisher=>"International Telecommunication Union",
        :receiveddate=>"XXX",
        :revdate=>"2000-01-01",
        :revdate_monthyear=>"01/2000",
        :script=>"Latn",
        :stage=>"Draft",
        :stage_display=>"Draft",
        :stageabbr=>"D",
        :transmitteddate=>"XXX",
        :unchangeddate=>"XXX",
        :unpublished=>true,
        :updateddate=>"XXX",
        :vote_endeddate=>"XXX",
        :vote_starteddate=>"XXX"}
      OUTPUT
  end

  it "processes default metadata for resolution, date range, days" do
    csdc = IsoDoc::ITU::HtmlConvert.new({})
    docxml, = csdc.convert_init(<<~"INPUT", "test", true)
      <itu-standard xmlns='https://www.metanorma.org/ns/itu' type='semantic' version='1.2.4'>
           <bibdata type='standard'>
             <title language='en' format='text/plain' type='main'>Main Title</title>
             <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
             <docidentifier type='ITU'>ITU-R 1000</docidentifier>
             <docnumber>1000</docnumber>
             <contributor>
               <role type='author'/>
               <organization> <name>International Telecommunication Union</name> </organization>
             </contributor>
             <contributor>
               <role type='publisher'/>
               <organization> <name>International Telecommunication Union</name> </organization>
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
                 <organization> <name>International Telecommunication Union</name> </organization>
               </owner>
             </copyright>
             <keyword>Word1</keyword>
             <keyword>word2</keyword>
             <ext>
               <doctype>resolution</doctype>
               <editorialgroup>
                 <bureau>R</bureau>
               </editorialgroup>
               <meeting acronym='MX'>Meeting X</meeting>
               <meeting-place>Kronos</meeting-place>
               <meeting-date>
                 <from>2000-01-01</from>
                 <to>2000-01-02</to>
               </meeting-date>
               <structuredidentifier>
                 <bureau>R</bureau>
                 <docnumber>1000</docnumber>
               </structuredidentifier>
             </ext>
           </bibdata>
           <sections> </sections>
         </itu-standard>
    INPUT
    expect(htmlencode(metadata(csdc.info(docxml, nil)).to_s
      .gsub(/, :/, ",\n:"))).to be_equivalent_to <<~"OUTPUT"
        {:accesseddate=>"XXX",
        :agency=>"International Telecommunication Union",
        :bureau=>"R",
        :circulateddate=>"XXX",
        :confirmeddate=>"XXX",
        :copieddate=>"XXX",
        :createddate=>"XXX",
        :docnumber=>"ITU-R 1000",
        :docnumeric=>"1000",
        :docsubtitle=>"Subtitle",
        :doctitle=>"Main Title",
        :doctype=>"Resolution",
        :doctype_display=>"Resolution",
        :doctype_original=>"resolution",
        :docyear=>"2001",
        :draft=>"5",
        :draft_new_doctype=>"Draft new Resolution",
        :draftinfo=>" (draft 5, 2000-01-01)",
        :edition=>"2",
        :implementeddate=>"XXX",
        :ip_notice_received=>"false",
        :issueddate=>"XXX",
        :keywords=>["Word1", "word2"],
        :lang=>"en",
        :logo_comb=>"#{File.join(logoloc, 'itu-document-comb.png')}",
        :logo_html=>"#{File.join(logoloc, '/International_Telecommunication_Union_Logo.svg')}",
        :logo_sp=>"#{File.join(logoloc, '/logo-sp.png')}",
        :logo_word=>"#{File.join(logoloc, 'International_Telecommunication_Union_Logo.svg')}",
        :meeting=>"Meeting X",
        :meeting_acronym=>"MX",
        :meeting_date=>"1&#x2013;2 January 2000",
        :meeting_place=>"Kronos",
        :obsoleteddate=>"XXX",
        :placedate_year=>"Geneva, 2001",
        :publisheddate=>"XXX",
        :publisher=>"International Telecommunication Union",
        :receiveddate=>"XXX",
        :revdate=>"2000-01-01",
        :revdate_monthyear=>"01/2000",
        :script=>"Latn",
        :stage=>"Draft",
        :stage_display=>"Draft",
        :stageabbr=>"D",
        :transmitteddate=>"XXX",
        :unchangeddate=>"XXX",
        :unpublished=>true,
        :updateddate=>"XXX",
        :vote_endeddate=>"XXX",
        :vote_starteddate=>"XXX"}
      OUTPUT
  end

  it "processes default metadata for resolution, date range, months" do
    csdc = IsoDoc::ITU::HtmlConvert.new({})
    docxml, = csdc.convert_init(<<~"INPUT", "test", true)
      <itu-standard xmlns='https://www.metanorma.org/ns/itu' type='semantic' version='1.2.4'>
           <bibdata type='standard'>
             <title language='en' format='text/plain' type='main'>Main Title</title>
             <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
             <docidentifier type='ITU'>ITU-R 1000</docidentifier>
             <docnumber>1000</docnumber>
             <contributor>
               <role type='author'/>
               <organization> <name>International Telecommunication Union</name> </organization>
             </contributor>
             <contributor>
               <role type='publisher'/>
               <organization> <name>International Telecommunication Union</name> </organization>
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
                 <organization> <name>International Telecommunication Union</name> </organization>
               </owner>
             </copyright>
             <keyword>Word1</keyword>
             <keyword>word2</keyword>
             <ext>
               <doctype>resolution</doctype>
               <editorialgroup>
                 <bureau>R</bureau>
               </editorialgroup>
               <meeting acronym='MX'>Meeting X</meeting>
               <meeting-place>Kronos</meeting-place>
               <meeting-date>
                 <from>2000-01-01</from>
                 <to>2000-02-02</to>
               </meeting-date>
               <structuredidentifier>
                 <bureau>R</bureau>
                 <docnumber>1000</docnumber>
               </structuredidentifier>
             </ext>
           </bibdata>
           <sections> </sections>
         </itu-standard>
    INPUT
    expect(htmlencode(metadata(csdc.info(docxml, nil)).to_s
      .gsub(/, :/, ",\n:"))).to be_equivalent_to <<~"OUTPUT"
        {:accesseddate=>"XXX",
        :agency=>"International Telecommunication Union",
        :bureau=>"R",
        :circulateddate=>"XXX",
        :confirmeddate=>"XXX",
        :copieddate=>"XXX",
        :createddate=>"XXX",
        :docnumber=>"ITU-R 1000",
        :docnumeric=>"1000",
        :docsubtitle=>"Subtitle",
        :doctitle=>"Main Title",
        :doctype=>"Resolution",
        :doctype_display=>"Resolution",
        :doctype_original=>"resolution",
        :docyear=>"2001",
        :draft=>"5",
        :draft_new_doctype=>"Draft new Resolution",
        :draftinfo=>" (draft 5, 2000-01-01)",
        :edition=>"2",
        :implementeddate=>"XXX",
        :ip_notice_received=>"false",
        :issueddate=>"XXX",
        :keywords=>["Word1", "word2"],
        :lang=>"en",
        :logo_comb=>"#{File.join(logoloc, 'itu-document-comb.png')}",
        :logo_html=>"#{File.join(logoloc, '/International_Telecommunication_Union_Logo.svg')}",
        :logo_sp=>"#{File.join(logoloc, '/logo-sp.png')}",
        :logo_word=>"#{File.join(logoloc, 'International_Telecommunication_Union_Logo.svg')}",
        :meeting=>"Meeting X",
        :meeting_acronym=>"MX",
        :meeting_date=>"1 January &#x2013; 2 February 2000",
        :meeting_place=>"Kronos",
        :obsoleteddate=>"XXX",
        :placedate_year=>"Geneva, 2001",
        :publisheddate=>"XXX",
        :publisher=>"International Telecommunication Union",
        :receiveddate=>"XXX",
        :revdate=>"2000-01-01",
        :revdate_monthyear=>"01/2000",
        :script=>"Latn",
        :stage=>"Draft",
        :stage_display=>"Draft",
        :stageabbr=>"D",
        :transmitteddate=>"XXX",
        :unchangeddate=>"XXX",
        :unpublished=>true,
        :updateddate=>"XXX",
        :vote_endeddate=>"XXX",
        :vote_starteddate=>"XXX"}
      OUTPUT
  end

  it "processes default metadata for resolution, date range, years" do
    csdc = IsoDoc::ITU::HtmlConvert.new({})
    docxml, = csdc.convert_init(<<~"INPUT", "test", true)
      <itu-standard xmlns='https://www.metanorma.org/ns/itu' type='semantic' version='1.2.4'>
           <bibdata type='standard'>
             <title language='en' format='text/plain' type='main'>Main Title</title>
             <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
             <docidentifier type='ITU'>ITU-R 1000</docidentifier>
             <docnumber>1000</docnumber>
             <contributor>
               <role type='author'/>
               <organization> <name>International Telecommunication Union</name> </organization>
             </contributor>
             <contributor>
               <role type='publisher'/>
               <organization> <name>International Telecommunication Union</name> </organization>
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
                 <organization> <name>International Telecommunication Union</name> </organization>
               </owner>
             </copyright>
             <keyword>Word1</keyword>
             <keyword>word2</keyword>
             <ext>
               <doctype>resolution</doctype>
               <editorialgroup>
                 <bureau>R</bureau>
               </editorialgroup>
               <meeting acronym='MX'>Meeting X</meeting>
               <meeting-place>Kronos</meeting-place>
               <meeting-date>
                 <from>2000-01-01</from>
                 <to>2001-01-02</to>
               </meeting-date>
               <structuredidentifier>
                 <bureau>R</bureau>
                 <docnumber>1000</docnumber>
               </structuredidentifier>
             </ext>
           </bibdata>
           <sections> </sections>
         </itu-standard>
    INPUT
    expect(htmlencode(metadata(csdc.info(docxml, nil)).to_s
      .gsub(/, :/, ",\n:"))).to be_equivalent_to <<~"OUTPUT"
        {:accesseddate=>"XXX",
        :agency=>"International Telecommunication Union",
        :bureau=>"R",
        :circulateddate=>"XXX",
        :confirmeddate=>"XXX",
        :copieddate=>"XXX",
        :createddate=>"XXX",
        :docnumber=>"ITU-R 1000",
        :docnumeric=>"1000",
        :docsubtitle=>"Subtitle",
        :doctitle=>"Main Title",
        :doctype=>"Resolution",
        :doctype_display=>"Resolution",
        :doctype_original=>"resolution",
        :docyear=>"2001",
        :draft=>"5",
        :draft_new_doctype=>"Draft new Resolution",
        :draftinfo=>" (draft 5, 2000-01-01)",
        :edition=>"2",
        :implementeddate=>"XXX",
        :ip_notice_received=>"false",
        :issueddate=>"XXX",
        :keywords=>["Word1", "word2"],
        :lang=>"en",
        :logo_comb=>"#{File.join(logoloc, 'itu-document-comb.png')}",
        :logo_html=>"#{File.join(logoloc, '/International_Telecommunication_Union_Logo.svg')}",
        :logo_sp=>"#{File.join(logoloc, '/logo-sp.png')}",
        :logo_word=>"#{File.join(logoloc, 'International_Telecommunication_Union_Logo.svg')}",
        :meeting=>"Meeting X",
        :meeting_acronym=>"MX",
        :meeting_date=>"1 January 2000 &#x2013; 2 January 2001",
        :meeting_place=>"Kronos",
        :obsoleteddate=>"XXX",
        :placedate_year=>"Geneva, 2001",
        :publisheddate=>"XXX",
        :publisher=>"International Telecommunication Union",
        :receiveddate=>"XXX",
        :revdate=>"2000-01-01",
        :revdate_monthyear=>"01/2000",
        :script=>"Latn",
        :stage=>"Draft",
        :stage_display=>"Draft",
        :stageabbr=>"D",
        :transmitteddate=>"XXX",
        :unchangeddate=>"XXX",
        :unpublished=>true,
        :updateddate=>"XXX",
        :vote_endeddate=>"XXX",
        :vote_starteddate=>"XXX"}
      OUTPUT
  end

  it "processes default metadata for service publication" do
    csdc = IsoDoc::ITU::HtmlConvert.new({})
    docxml, = csdc.convert_init(<<~"INPUT", "test", true)
      <itu-standard xmlns='https://www.metanorma.org/ns/itu' type='semantic' version='1.2.4'>
           <bibdata type='standard'>
             <title language='en' format='text/plain' type='main'>Main Title</title>
             <title language='fr' format='text/plain' type='main'>Titre Principal</title>
             <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
             <title language='fr' format='text/plain' type='subtitle'>Soustitre</title>
             <title language='en' format='text/plain' type='position-sp'>Position on 8 September 2010</title>
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
    expect(htmlencode(metadata(csdc.info(docxml, nil)).to_s
      .gsub(/, :/, ",\n:"))).to be_equivalent_to <<~"OUTPUT"
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
        :doctype_abbreviated=>"TR",
        :doctype_display=>"Technical Report",
        :doctype_original=>"technical-report",
        :docyear=>"2001",
        :draft=>"5",
        :draft_new_doctype=>"Draft new Technical Report",
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
        :logo_comb=>"#{File.join(logoloc, 'itu-document-comb.png')}",
        :logo_html=>"#{File.join(logoloc, '/International_Telecommunication_Union_Logo.svg')}",
        :logo_sp=>"#{File.join(logoloc, '/logo-sp.png')}",
        :logo_word=>"#{File.join(logoloc, 'International_Telecommunication_Union_Logo.svg')}",
        :meeting=>"Meeting X",
        :meeting_acronym=>"Meeting X",
        :meeting_date=>"01 Jan 2000/02 Jan 2000",
        :obsoleteddate=>"XXX",
        :phones=>["555", "557"],
        :placedate_year=>"Geneva, 2001",
        :positiontitle=>"Position on 8 September 2010",
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
    docxml, = csdc.convert_init(<<~"INPUT", "test", true)
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
    expect(htmlencode(metadata(csdc.info(docxml, nil)).to_s
      .gsub(/, :/, ",\n:"))).to be_equivalent_to <<~"OUTPUT"
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
        :doctype_abbreviated=>"Rec.",
        :doctype_display=>"Recommendation",
        :doctype_original=>"recommendation-annex",
        :draft_new_doctype=>"Draft new Recommendation",
        :implementeddate=>"XXX",
        :ip_notice_received=>"false",
        :issueddate=>"XXX",
        :lang=>"en",
        :logo_comb=>"#{File.join(logoloc, 'itu-document-comb.png')}",
        :logo_html=>"#{File.join(logoloc, '/International_Telecommunication_Union_Logo.svg')}",
        :logo_sp=>"#{File.join(logoloc, '/logo-sp.png')}",
        :logo_word=>"#{File.join(logoloc, 'International_Telecommunication_Union_Logo.svg')}",
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

  it "localises dates in English" do
    input = <<~INPUT
      <itu-standard xmlns="https://www.calconnect.org/standards/itu">
      <bibdata>
      <date type="published">2018-09-01</date>
      <date type="published">2018-09</date>
      <date type="published">2018</date>
      <language>en</language>
      </bibdata>
      </itu-standard>
    INPUT
    output = <<~OUTPUT
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
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(output)
  end

  it "localises dates in Arabic" do
    input = <<~INPUT
      <itu-standard xmlns="https://www.calconnect.org/standards/itu">
      <bibdata>
      <date type="published">2018-09-01</date>
      <date type="published">2018-09</date>
      <date type="published">2018</date>
      <language>ar</language>
      </bibdata>
      </itu-standard>
    INPUT
    output = <<~OUTPUT
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
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(output)
  end

  it "localises dates in Chinese" do
    input = <<~INPUT
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
    output = <<~OUTPUT
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
    expect(xmlpp(IsoDoc::ITU::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(output)
  end
end

require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Itu do
  before(:all) do
    @blank_hdr = blank_hdr_gen
  end

  before do
    # Force to download Relaton index file
    allow_any_instance_of(Relaton::Index::Type).to receive(:actual?)
      .and_return(false)
    allow_any_instance_of(Relaton::Index::FileIO).to receive(:check_file)
      .and_return(nil)
  end

  it "has a version number" do
    expect(Metanorma::Itu::VERSION).not_to be nil
  end

  it "processes a blank document" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
    INPUT
    output = <<~OUTPUT
      #{@blank_hdr}
      <sections/>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "converts a blank document" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-pdf:
      :legacy-do-not-insert-missing-sections:
    INPUT
    output = <<~OUTPUT
        #{@blank_hdr}
        <sections/>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
    expect(File.exist?("test.html")).to be true

    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-pdf:
      :document-schema: legacy
    INPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output))
    expect(File.exist?("test.html")).to be true
  end

  it "processes default metadata" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~INPUT, *OPTIONS))
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :revdate: 2000-01-01
      :copyright-year: 2001
      :title: Main Title
      :subtitle: Subtitle
      :draft: 3.4
      :legacy-do-not-insert-missing-sections:
    INPUT
    output = <<~OUTPUT
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" version="#{Metanorma::Itu::VERSION}" flavor="itu">
        <bibdata type="standard">
          <title language="en" format="text/plain" type="main">Main Title</title>
          <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
          <docidentifier primary="true" type="ITU">ITU-T 1000</docidentifier>
          <docidentifier type="ITU-lang">ITU-T 1000-E</docidentifier>
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
          <version>
            <revision-date>2000-01-01</revision-date>
            <draft>3.4</draft>
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
          <ext>
            <doctype>recommendation</doctype>
            <flavor>itu</flavor>
            <editorialgroup>
              <bureau>T</bureau>
            </editorialgroup>
            <ip-notice-received>false</ip-notice-received>
            <structuredidentifier>
          <bureau>T</bureau>
          <docnumber>1000</docnumber>
        </structuredidentifier>
          </ext>
        </bibdata>
        <metanorma-extension>
           <presentation-metadata>
             <name>document-scheme</name>
             <value>current</value>
           </presentation-metadata>
           <presentation-metadata>
             <name>TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
           <presentation-metadata>
             <name>HTML TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
           <presentation-metadata>
             <name>DOC TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
           <presentation-metadata>
             <name>PDF TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
         </metanorma-extension>
        <sections/>
      </metanorma>
    OUTPUT
    xml.xpath("//xmlns:boilerplate")
      .each(&:remove)
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output))
  end

  it "processes explicit metadata" do
    VCR.use_cassette("ITU-complements",
                     match_requests_on: %i[method uri body]) do
      xml = Nokogiri::XML(Asciidoctor.convert(<<~INPUT, *OPTIONS))
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :novalid:
        :docnumber: 1000
        :provisional-name: ABC
        :td-number: SG17-TD611
        :doctype: directive
        :edition: 2
        :revdate: 2000-01-01
        :technical-committee: TC
        :technical-committee-type: provisional
        :copyright-year: 2001
        :status: final-draft
        :iteration: 3
        :language: en
        :title-en: Main Title
        :title-fr: Titre Principal
        :subtitle-en: Subtitle
        :subtitle-fr: Soustitre
        :fullname: Fred Flintstone
        :role: author
        :surname_2: Rubble
        :givenname_2: Barney
        :role_2: editor
        :bureau: R
        :bureau_2: T
        :grouptype: A
        :grouptype_2: B
        :groupacronym: C
        :groupacronym_2: D
        :groupyearstart: E
        :groupyearstart_2: F
        :groupyearend: G
        :groupyearend_2: H
        :group: I
        :group_2: J
        :subgrouptype: A1
        :subgrouptype_2: B1
        :subgroupacronym: C1
        :subgroupacronym_2: D1
        :subgroupyearstart: E1
        :subgroupyearstart_2: F1
        :subgroupyearend: G1
        :subgroupyearend_2: H1
        :subgroup: I1
        :subgroup_2: J1
        :workgrouptype: A2
        :workgrouptype_2: B2
        :workgroupacronym: C2
        :workgroupacronym_2: D2
        :workgroupyearstart: E2
        :workgroupyearstart_2: F2
        :workgroupyearend: G2
        :workgroupyearend_2: H2
        :workgroup: I2
        :workgroup_2: J2
        :series: A3
        :series1: B3
        :series2: C3
        :keywords: word2,word1
        :recommendation-from: D3
        :recommendation-to: E3
        :approval-process: F3
        :approval-status: G3
        :annexid: H3
        :annextitle: I3
        :annextitle-fr: J3
        :legacy-do-not-insert-missing-sections:
        :amendment-number: 88
        :corrigendum-number: 88
        :amendment-title: Amendment Title
        :corrigendum-title: Corrigendum Title
        :amendment-title-fr: Titre de Amendment
        :corrigendum-title-fr: Titre de Corrigendum
        :recommendationnumber: G.7713.1/Y.1704.1
        :complements: ITU-T F.69;ITU-T F.68
        :collection-title: Articles
        :slogan-title: Slogan
        :sector: Sector
        :coverpage-image: images/image1.gif,images/image2.gif
        :document-scheme: legacy
        :question: Q10/17: Identity management and telebiometrics architecture and mechanisms, "Q11/17: Generic technologies (such as Directory, PKI, formal languages, object identifiers) to support secure applications"
        :timing: 2025-Q4
      INPUT
      output = <<~"OUTPUT"
        <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" version="#{Metanorma::Itu::VERSION}" flavor="itu">
                    <bibdata type='standard'>
                                 <title language="en" format="text/plain" type="main">Main Title</title>
             <title language="en" format="text/plain" type="annex">I3</title>
             <title language="fr" format="text/plain" type="main">Titre Principal</title>
             <title language="fr" format="text/plain" type="annex">J3</title>
             <title language="en" format="text/plain" type="subtitle">Subtitle</title>
             <title language="fr" format="text/plain" type="subtitle">Soustitre</title>
             <title language="en" format="text/plain" type="amendment">Amendment Title</title>
             <title language="fr" format="text/plain" type="amendment">Titre de Amendment</title>
             <title language="en" format="text/plain" type="corrigendum">Corrigendum Title</title>
             <title language="fr" format="text/plain" type="corrigendum">Titre de Corrigendum</title>
             <title language="en" format="text/plain" type="collection">Articles</title>
             <title language="en" format="text/plain" type="slogan">Slogan</title>
             <docidentifier type="ITU-provisional">ABC</docidentifier>
             <docidentifier type="ITU-TemporaryDocument">SG17-TD611</docidentifier>
             <docidentifier type="ITU" primary="true">ITU-R 1000</docidentifier>
             <docidentifier type="ITU-lang">ITU-R 1000-E</docidentifier>
             <docidentifier type="ITU-Recommendation">G.7713.1</docidentifier>
             <docidentifier type="ITU-Recommendation">Y.1704.1</docidentifier>
             <docnumber>1000</docnumber>
                          <contributor>
                <role type="author"/>
                <organization>
                   <name>International Telecommunication Union</name>
                   <abbreviation>ITU</abbreviation>
                </organization>
             </contributor>
             <contributor>
                <role type="author"/>
                <person>
                   <name>
                      <completename>Fred Flintstone</completename>
                   </name>
                </person>
             </contributor>
             <contributor>
                <role type="editor"/>
                <person>
                   <name>
                      <forename>Barney</forename>
                      <surname>Rubble</surname>
                   </name>
                </person>
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
             </version>
             <language>en</language>
             <script>Latn</script>
             <status>
                <stage>final-draft</stage>
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
             <relation type="complements">
                <bibitem type="standard">
                   <title type="title-main" format="text/plain" language="en" script="Latn">Plan for telex destination codes</title>
                   <title type="main" format="text/plain" language="en" script="Latn">Plan for telex destination codes</title>
                   <uri type="src">https://www.itu.int/ITU-T/recommendations/rec.aspx?rec=694&amp;lang=en</uri>
                   <uri type="obp">https://www.itu.int/rec/dologin_pub.asp?lang=e&amp;id=T-REC-F.69-198811-S!!PDF-E&amp;type=items</uri>
                   <docidentifier type="ITU" primary="true">ITU-T F.69 (11/1988)</docidentifier>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <name>International Telecommunication Union</name>
                         <abbreviation>ITU</abbreviation>
                         <uri>www.itu.int</uri>
                      </organization>
                   </contributor>
                   <edition>5</edition>
                   <language>en</language>
                   <script>Latn</script>
                   <status>
                      <stage>Withdrawal</stage>
                   </status>
                   <copyright>
                      <from>1988</from>
                      <owner>
                         <organization>
                            <name>International Telecommunication Union</name>
                            <abbreviation>ITU</abbreviation>
                            <uri>www.itu.int</uri>
                         </organization>
                      </owner>
                   </copyright>
                   <relation type="complementOf">
                      <bibitem type="standard">
                         <formattedref format="text/plain" language="en" script="Latn">F Suppl. 1 (11/1988)</formattedref>
                         <docidentifier type="ITU">F Suppl. 1 (11/1988)</docidentifier>
                      </bibitem>
                   </relation>
                   <relation type="complementOf">
                      <bibitem type="standard">
                         <formattedref format="text/plain" language="en" script="Latn">F Suppl. 2 (11/1988)</formattedref>
                         <docidentifier type="ITU">F Suppl. 2 (11/1988)</docidentifier>
                      </bibitem>
                   </relation>
                   <relation type="complementOf">
                      <bibitem type="standard">
                         <formattedref format="text/plain" language="en" script="Latn">F Suppl. 3 (09/2016)</formattedref>
                         <docidentifier type="ITU">F Suppl. 3 (09/2016)</docidentifier>
                      </bibitem>
                   </relation>
                   <relation type="complementOf">
                      <bibitem type="standard">
                         <formattedref format="text/plain" language="en" script="Latn">F Suppl. 4 (04/2021)</formattedref>
                         <docidentifier type="ITU">F Suppl. 4 (04/2021)</docidentifier>
                      </bibitem>
                   </relation>
                   <relation type="instanceOf">
                      <bibitem type="standard">
                         <title type="title-main" format="text/plain" language="en" script="Latn">Plan for telex destination codes</title>
                         <title type="main" format="text/plain" language="en" script="Latn">Plan for telex destination codes</title>
                         <uri type="src">https://www.itu.int/ITU-T/recommendations/rec.aspx?rec=694&amp;lang=en</uri>
                         <uri type="obp">https://www.itu.int/rec/dologin_pub.asp?lang=e&amp;id=T-REC-F.69-198811-S!!PDF-E&amp;type=items</uri>
                         <docidentifier type="ITU" primary="true">ITU-T F.69 (11/1988)</docidentifier>
                         <date type="published">
                            <on>1988-11-25</on>
                         </date>
                         <contributor>
                            <role type="publisher"/>
                            <organization>
                               <name>International Telecommunication Union</name>
                               <abbreviation>ITU</abbreviation>
                               <uri>www.itu.int</uri>
                            </organization>
                         </contributor>
                         <edition>5</edition>
                         <language>en</language>
                         <script>Latn</script>
                         <status>
                            <stage>Withdrawal</stage>
                         </status>
                         <copyright>
                            <from>1988</from>
                            <owner>
                               <organization>
                                  <name>International Telecommunication Union</name>
                                  <abbreviation>ITU</abbreviation>
                                  <uri>www.itu.int</uri>
                               </organization>
                            </owner>
                         </copyright>
                         <relation type="complementOf">
                            <bibitem type="standard">
                               <formattedref format="text/plain" language="en" script="Latn">F Suppl. 1 (11/1988)</formattedref>
                               <docidentifier type="ITU">F Suppl. 1 (11/1988)</docidentifier>
                            </bibitem>
                         </relation>
                         <relation type="complementOf">
                            <bibitem type="standard">
                               <formattedref format="text/plain" language="en" script="Latn">F Suppl. 2 (11/1988)</formattedref>
                               <docidentifier type="ITU">F Suppl. 2 (11/1988)</docidentifier>
                            </bibitem>
                         </relation>
                         <relation type="complementOf">
                            <bibitem type="standard">
                               <formattedref format="text/plain" language="en" script="Latn">F Suppl. 3 (09/2016)</formattedref>
                               <docidentifier type="ITU">F Suppl. 3 (09/2016)</docidentifier>
                            </bibitem>
                         </relation>
                         <relation type="complementOf">
                            <bibitem type="standard">
                               <formattedref format="text/plain" language="en" script="Latn">F Suppl. 4 (04/2021)</formattedref>
                               <docidentifier type="ITU">F Suppl. 4 (04/2021)</docidentifier>
                            </bibitem>
                         </relation>
                         <place>Geneva</place>
                      </bibitem>
                   </relation>
                   <place>Geneva</place>
                </bibitem>
             </relation>
             <relation type="complements">
                <bibitem type="standard">
                   <title type="title-main" format="text/plain" language="en" script="Latn">Establishment of the automatic intercontinental telex network</title>
                   <title type="main" format="text/plain" language="en" script="Latn">Establishment of the automatic intercontinental telex network</title>
                   <uri type="src">https://www.itu.int/ITU-T/recommendations/rec.aspx?rec=693&amp;lang=en</uri>
                   <uri type="obp">https://www.itu.int/rec/dologin_pub.asp?lang=e&amp;id=T-REC-F.68-198811-I!!PDF-E&amp;type=items</uri>
                   <docidentifier type="ITU" primary="true">ITU-T F.68 (11/1988)</docidentifier>
                   <contributor>
                      <role type="publisher"/>
                      <organization>
                         <name>International Telecommunication Union</name>
                         <abbreviation>ITU</abbreviation>
                         <uri>www.itu.int</uri>
                      </organization>
                   </contributor>
                   <edition>5</edition>
                   <language>en</language>
                   <script>Latn</script>
                   <status>
                      <stage>Published</stage>
                   </status>
                   <copyright>
                      <from>1988</from>
                      <owner>
                         <organization>
                            <name>International Telecommunication Union</name>
                            <abbreviation>ITU</abbreviation>
                            <uri>www.itu.int</uri>
                         </organization>
                      </owner>
                   </copyright>
                   <relation type="complementOf">
                      <bibitem type="standard">
                         <formattedref format="text/plain" language="en" script="Latn">F Suppl. 1 (11/1988)</formattedref>
                         <docidentifier type="ITU">F Suppl. 1 (11/1988)</docidentifier>
                      </bibitem>
                   </relation>
                   <relation type="complementOf">
                      <bibitem type="standard">
                         <formattedref format="text/plain" language="en" script="Latn">F Suppl. 2 (11/1988)</formattedref>
                         <docidentifier type="ITU">F Suppl. 2 (11/1988)</docidentifier>
                      </bibitem>
                   </relation>
                   <relation type="complementOf">
                      <bibitem type="standard">
                         <formattedref format="text/plain" language="en" script="Latn">F Suppl. 3 (09/2016)</formattedref>
                         <docidentifier type="ITU">F Suppl. 3 (09/2016)</docidentifier>
                      </bibitem>
                   </relation>
                   <relation type="complementOf">
                      <bibitem type="standard">
                         <formattedref format="text/plain" language="en" script="Latn">F Suppl. 4 (04/2021)</formattedref>
                         <docidentifier type="ITU">F Suppl. 4 (04/2021)</docidentifier>
                      </bibitem>
                   </relation>
                   <relation type="instanceOf">
                      <bibitem type="standard">
                         <title type="title-main" format="text/plain" language="en" script="Latn">Establishment of the automatic intercontinental telex network</title>
                         <title type="main" format="text/plain" language="en" script="Latn">Establishment of the automatic intercontinental telex network</title>
                         <uri type="src">https://www.itu.int/ITU-T/recommendations/rec.aspx?rec=693&amp;lang=en</uri>
                         <uri type="obp">https://www.itu.int/rec/dologin_pub.asp?lang=e&amp;id=T-REC-F.68-198811-I!!PDF-E&amp;type=items</uri>
                         <docidentifier type="ITU" primary="true">ITU-T F.68 (11/1988)</docidentifier>
                         <date type="published">
                            <on>1988-11-25</on>
                         </date>
                         <contributor>
                            <role type="publisher"/>
                            <organization>
                               <name>International Telecommunication Union</name>
                               <abbreviation>ITU</abbreviation>
                               <uri>www.itu.int</uri>
                            </organization>
                         </contributor>
                         <edition>5</edition>
                         <language>en</language>
                         <script>Latn</script>
                         <abstract format="text/plain" language="en" script="Latn"/>
                         <status>
                            <stage>Published</stage>
                         </status>
                         <copyright>
                            <from>1988</from>
                            <owner>
                               <organization>
                                  <name>International Telecommunication Union</name>
                                  <abbreviation>ITU</abbreviation>
                                  <uri>www.itu.int</uri>
                               </organization>
                            </owner>
                         </copyright>
                         <relation type="complementOf">
                            <bibitem type="standard">
                               <formattedref format="text/plain" language="en" script="Latn">F Suppl. 1 (11/1988)</formattedref>
                               <docidentifier type="ITU">F Suppl. 1 (11/1988)</docidentifier>
                            </bibitem>
                         </relation>
                         <relation type="complementOf">
                            <bibitem type="standard">
                               <formattedref format="text/plain" language="en" script="Latn">F Suppl. 2 (11/1988)</formattedref>
                               <docidentifier type="ITU">F Suppl. 2 (11/1988)</docidentifier>
                            </bibitem>
                         </relation>
                         <relation type="complementOf">
                            <bibitem type="standard">
                               <formattedref format="text/plain" language="en" script="Latn">F Suppl. 3 (09/2016)</formattedref>
                               <docidentifier type="ITU">F Suppl. 3 (09/2016)</docidentifier>
                            </bibitem>
                         </relation>
                         <relation type="complementOf">
                            <bibitem type="standard">
                               <formattedref format="text/plain" language="en" script="Latn">F Suppl. 4 (04/2021)</formattedref>
                               <docidentifier type="ITU">F Suppl. 4 (04/2021)</docidentifier>
                            </bibitem>
                         </relation>
                         <place>Geneva</place>
                      </bibitem>
                   </relation>
                   <place>Geneva</place>
                </bibitem>
             </relation>
             <series type="main">
                <title>A3</title>
             </series>
             <series type="secondary">
                <title>B3</title>
             </series>
             <series type="tertiary">
                <title>C3</title>
             </series>
             <keyword>Word1</keyword>
             <keyword>word2</keyword>
             <ext>
                <doctype>directive</doctype>
            <flavor>itu</flavor>
                <editorialgroup>
                   <sector>Sector</sector>
                </editorialgroup>
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
                <question>
                   <identifier>Q10/17</identifier>
                   <name>Identity management and telebiometrics architecture and mechanisms</name>
                </question>
                <question>
                   <identifier>Q11/17</identifier>
                   <name>Generic technologies (such as Directory, PKI, formal languages, object identifiers) to support secure applications</name>
                </question>
                <recommendationstatus>
                   <from>D3</from>
                   <to>E3</to>
                   <approvalstage process="F3">G3</approvalstage>
                </recommendationstatus>
                <ip-notice-received>false</ip-notice-received>
                <timing>2025-Q4</timing>
                <structuredidentifier>
                   <bureau>R</bureau>
                   <docnumber>1000</docnumber>
                   <annexid>H3</annexid>
                   <amendment>88</amendment>
                   <corrigendum>88</corrigendum>
                </structuredidentifier>
             </ext>
          </bibdata>
          <metanorma-extension>
             <presentation-metadata>
                <name>document-scheme</name>
                <value>legacy</value>
             </presentation-metadata>
             <presentation-metadata>
                <name>coverpage-image</name>
                <value>
                   <image src="images/image1.gif"/>
                   <image src="images/image2.gif"/>
                </value>
             </presentation-metadata>
             <presentation-metadata>
                <name>TOC Heading Levels</name>
                <value>2</value>
             </presentation-metadata>
             <presentation-metadata>
                <name>HTML TOC Heading Levels</name>
                <value>2</value>
             </presentation-metadata>
             <presentation-metadata>
                <name>DOC TOC Heading Levels</name>
                <value>2</value>
             </presentation-metadata>
             <presentation-metadata>
                <name>PDF TOC Heading Levels</name>
                <value>2</value>
             </presentation-metadata>
          </metanorma-extension>
          <sections> </sections>
       </metanorma>
      OUTPUT
      xml.xpath("//xmlns:boilerplate | //xmlns:fetched")
        .each(&:remove)
      expect(strip_guid(Xml::C14n.format(xml.to_xml)))
        .to be_equivalent_to Xml::C14n.format(strip_guid(output))
    end
  end

  it "infer study period" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :group: G
      :grouptype: A
      :groupacronym: C
      :groupyearstart: 2000
      :groupyearend: 2002
    INPUT
    output = <<~OUTPUT
      <editorialgroup>
         <bureau>T</bureau>
         <group type="A">
           <name>G</name>
           <acronym>C</acronym>
           <period>
             <start>2000</start>
             <end>2002</end>
           </period>
         </group>
       </editorialgroup>
    OUTPUT
    xml = Nokogiri::XML(Asciidoctor.convert(input, *OPTIONS))
    xml = xml.at("//xmlns:editorialgroup")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output))
    xml = Nokogiri::XML(Asciidoctor.convert(input
      .sub(":groupyearend: 2002", ""), *OPTIONS))
    xml = xml.at("//xmlns:editorialgroup")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output))
    mock_year(2000)
    xml = Nokogiri::XML(Asciidoctor.convert(input
      .sub(":groupyearend: 2002", "")
      .sub(":groupyearstart: 2000", ""),
                                            *OPTIONS))
    xml = xml.at("//xmlns:editorialgroup")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output))
    mock_year(2001)
    xml = Nokogiri::XML(Asciidoctor.convert(input
      .sub(":groupyearend: 2002", "")
      .sub(":groupyearstart: 2000", ""),
                                            *OPTIONS))
    xml = xml.at("//xmlns:editorialgroup")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output))
    mock_year(2002)
    xml = Nokogiri::XML(Asciidoctor.convert(input
      .sub(":groupyearend: 2002", "")
      .sub(":groupyearstart: 2000", ""),
                                            *OPTIONS))
    xml = xml.at("//xmlns:editorialgroup")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output)
      .sub("2002", "2004")
      .sub("2000", "2002"))
  end

  it "populates cover images" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :coverpage-image: images/image1.gif,images/image2.gif
    INPUT
    output = <<~OUTPUT
      <metanorma-extension>
        <presentation-metadata>
          <name>coverpage-image</name>
          <value>
            <image src="images/image1.gif"/>
            <image src="images/image2.gif"/>
          </value>
        </presentation-metadata>
         <presentation-metadata>
           <name>TOC Heading Levels</name>
           <value>2</value>
         </presentation-metadata>
         <presentation-metadata>
           <name>HTML TOC Heading Levels</name>
           <value>2</value>
         </presentation-metadata>
         <presentation-metadata>
           <name>DOC TOC Heading Levels</name>
           <value>2</value>
         </presentation-metadata>
         <presentation-metadata>
           <name>PDF TOC Heading Levels</name>
           <value>2</value>
         </presentation-metadata>
         <presentation-metadata>
          <name>document-scheme</name>
          <value>current</value>
        </presentation-metadata>
      </metanorma-extension>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Nokogiri::XML(Asciidoctor.convert(input, *OPTIONS))
      .at("//xmlns:metanorma-extension").to_xml)))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output))
  end

  it "processes explicit metadata, contribution" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :provisional-name: ABC
      :doctype: contribution
      :edition: 2
      :revdate: 2000-01-01
      :technical-committee: TC
      :technical-committee-type: provisional
      :copyright-year: 2001
      :status: final-draft
      :iteration: 3
      :language: en
      :title-en: Main Title
      :title-fr: Titre Principal
      :subtitle-en: Subtitle
      :subtitle-fr: Soustitre
      :bureau: R
      :group: Study Group 17
      :group-acronym: SG17
      :group-type: study-group
      :group-year-start: 2000
      :group-year-end: 2002
      :subgroup: I1
      :workgroup: I2
      :series: A3
      :series1: B3
      :series2: C3
      :keywords: voIP,word1
      :meeting: Meeting X
      :meeting-date: 2000-01-01/2000-01-02
      :meeting-place: Kronos
      :meeting-acronym: MX
      :intended-type: TD
      :source: Source
      :draft: 5
      :role: rapporteur
      :fullname: Fred Flintstone
      :affiliation: Bedrock Quarry
      :address: Canada
      :phone: 555
      :fax: 556
      :email: x@example.com
      :role_2: editor
      :fullname_2: Barney Rubble
      :affiliation_2: Bedrock Quarry 2
      :address_2: USA
      :phone_2: 557
      :fax_2: 558
      :email_2: y@example.com
    INPUT
    output = <<~OUTPUT
      <metanorma xmlns='https://www.metanorma.org/ns/standoc' type='semantic' version='#{Metanorma::Itu::VERSION}' flavor="itu">
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
              <email>y@example.com</email>
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
            <flavor>itu</flavor>
            <editorialgroup>
              <bureau>R</bureau>
              <group type="study-group">
                <name>Study Group 17</name>
                <acronym>SG17</acronym>
                <period><start>2000</start><end>2002</end></period>
              </group>
              <subgroup>
                <name>I1</name>
                #{current_study_period}
              </subgroup>
              <workgroup>
                <name>I2</name>
                #{current_study_period}
              </workgroup>
            </editorialgroup>
            <ip-notice-received>false</ip-notice-received>
            <meeting acronym='MX'>Meeting X</meeting>
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
        </metanorma>
    OUTPUT
    xml = Nokogiri::XML(Asciidoctor.convert(input, *OPTIONS))
    xml.xpath("//xmlns:boilerplate | //xmlns:metanorma-extension")
      .each(&:remove)
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output))
    xml = Nokogiri::XML(Asciidoctor.convert(input
      .sub(/:group-acronym: SG17\s+:/m, ":"), *OPTIONS))
    xml.xpath("//xmlns:boilerplate | //xmlns:metanorma-extension")
      .each(&:remove)
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output)
      .sub("<acronym>SG17</acronym>", ""))
  end

  it "processes explicit metadata, technical report" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~INPUT, *OPTIONS))
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :provisional-name: ABC
      :doctype: technical-report
      :edition: 2
      :revdate: 2000-01-01
      :technical-committee: TC
      :technical-committee-type: provisional
      :copyright-year: 2001
      :status: final-draft
      :iteration: 3
      :language: en
      :title-en: Main Title
      :title-fr: Titre Principal
      :subtitle-en: Subtitle
      :subtitle-fr: Soustitre
      :bureau: R
      :group: I
      :subgroup: I1
      :workgroup: I2
      :series: A3
      :series1: B3
      :series2: C3
      :keywords: voIP,word1
      :meeting: Meeting X
      :meeting-date: 2000-01-01/2000-01-02
      :meeting-place: Kronos
      :meeting-acronym: MX
      :intended-type: TD
      :source: Source
      :draft: 5
      :role: rapporteur
      :fullname: Fred Flintstone
      :affiliation: Bedrock Quarry
      :address: Canada
      :phone: 555
      :fax: 556
      :email: x@example.com
      :role_2: editor
      :fullname_2: Barney Rubble
      :affiliation_2: Bedrock Quarry 2
      :address_2: USA
      :phone_2: 557
      :fax_2: 558
      :email_2: y@example.com
    INPUT
    output = <<~OUTPUT
      <metanorma xmlns='https://www.metanorma.org/ns/standoc' type='semantic' version='#{Metanorma::Itu::VERSION}' flavor="itu">
        <bibdata type='standard'>
          <title language='en' format='text/plain' type='main'>Main Title</title>
          <title language='fr' format='text/plain' type='main'>Titre Principal</title>
          <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
          <title language='fr' format='text/plain' type='subtitle'>Soustitre</title>
          <docidentifier type='ITU-provisional'>ABC</docidentifier>
          <docidentifier primary="true" type='ITU'>ITU-R 1000</docidentifier>
          <docidentifier type='ITU-lang'>ITU-R 1000-E</docidentifier>
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
              <email>y@example.com</email>
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
            <doctype>technical-report</doctype>
            <flavor>itu</flavor>
            <editorialgroup>
              <bureau>R</bureau>
              <group>
                <name>I</name>
                #{current_study_period}
              </group>
              <subgroup>
                <name>I1</name>
                #{current_study_period}
              </subgroup>
              <workgroup>
                <name>I2</name>
                #{current_study_period}
              </workgroup>
            </editorialgroup>
            <ip-notice-received>false</ip-notice-received>
            <meeting acronym='MX'>Meeting X</meeting>
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
      </metanorma>
    OUTPUT
    xml.xpath("//xmlns:boilerplate | //xmlns:metanorma-extension")
      .each(&:remove)
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output))
  end

  it "processes explicit metadata, technical report #2" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~INPUT, *OPTIONS))
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docidentifier: OVERRIDE
      :docnumber: 1000
      :provisional-name: ABC
      :doctype: technical-report
      :edition: 2
      :revdate: 2000-01-01
      :technical-committee: TC
      :technical-committee-type: provisional
      :copyright-year: 2001
      :status: final-draft
      :iteration: 3
      :language: en
      :title-en: Main Title
      :title-fr: Titre Principal
      :subtitle-en: Subtitle
      :subtitle-fr: Soustitre
      :bureau: R
      :group: I
      :subgroup: I1
      :workgroup: I2
      :series: A3
      :series1: B3
      :series2: C3
      :keywords: word2,word1
      :meeting: Meeting X
      :meeting-date: 2000-01-01
      :intended-type: TD
      :source: Source
      :draft: 5
    INPUT
    output = <<~OUTPUT
      <metanorma xmlns='https://www.metanorma.org/ns/standoc' type='semantic' version='#{Metanorma::Itu::VERSION}' flavor="itu">
        <bibdata type='standard'>
          <title language='en' format='text/plain' type='main'>Main Title</title>
          <title language='fr' format='text/plain' type='main'>Titre Principal</title>
          <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
          <title language='fr' format='text/plain' type='subtitle'>Soustitre</title>
          <docidentifier type='ITU-provisional'>ABC</docidentifier>
          <docidentifier primary="true" type='ITU'>OVERRIDE</docidentifier>
          <docidentifier type='ITU-lang'>ITU-R 1000-E</docidentifier>
          <docnumber>1000</docnumber>
          <contributor>
            <role type='author'/>
            <organization>
              <name>International Telecommunication Union</name>
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
          <keyword>Word1</keyword>
          <keyword>word2</keyword>
          <ext>
            <doctype>technical-report</doctype>
            <flavor>itu</flavor>
            <editorialgroup>
              <bureau>R</bureau>
              <group>
                <name>I</name>
                #{current_study_period}
              </group>
              <subgroup>
                <name>I1</name>
                #{current_study_period}
              </subgroup>
              <workgroup>
                <name>I2</name>
                #{current_study_period}
              </workgroup>
            </editorialgroup>
            <ip-notice-received>false</ip-notice-received>
            <meeting>Meeting X</meeting>
            <meeting-date>
              <on>2000-01-01</on>
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
      </metanorma>
    OUTPUT
    xml.xpath("//xmlns:boilerplate | //xmlns:metanorma-extension")
      .each(&:remove)
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output))
  end

  it "processes explicit metadata, service publication" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~INPUT, *OPTIONS))
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :provisional-name: ABC
      :doctype: service-publication
      :edition: 2
      :revdate: 2000-01-01
      :technical-committee: TC
      :technical-committee-type: provisional
      :copyright-year: 2001
      :status: final-draft
      :iteration: 3
      :language: en
      :title-en: Main Title
      :title-fr: Titre Principal
      :subtitle-en: Subtitle
      :subtitle-fr: Soustitre
      :bureau: R
      :group: I
      :subgroup: I1
      :workgroup: I2
      :series: A3
      :series1: B3
      :series2: C3
      :keywords: word2,word1
      :meeting: Meeting X
      :meeting-date: 2000-01-01/2000-01-02
      :intended-type: TD
      :source: Source
      :draft: 5
      :role: rapporteur
      :fullname: Fred Flintstone
      :affiliation: Bedrock Quarry
      :address: Canada
      :phone: 555
      :fax: 556
      :email: x@example.com
      :role_2: editor
      :fullname_2: Barney Rubble
      :affiliation_2: Bedrock Quarry 2
      :address_2: USA
      :phone_2: 557
      :fax_2: 558
      :email_2: y@example.com
    INPUT

    output = <<~OUTPUT
      <metanorma xmlns='https://www.metanorma.org/ns/standoc' type='semantic' version='#{Metanorma::Itu::VERSION}' flavor="itu">
        <bibdata type='standard'>
          <title language='en' format='text/plain' type='main'>Main Title</title>
          <title language='fr' format='text/plain' type='main'>Titre Principal</title>
          <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
          <title language='fr' format='text/plain' type='subtitle'>Soustitre</title>
          <docidentifier type='ITU-provisional'>ABC</docidentifier>
          <docidentifier primary="true" type='ITU'>Annex to ITU OB 1000</docidentifier>
          <docidentifier type='ITU-lang'>Annex to ITU OB 1000-E</docidentifier>
          <docnumber>1000</docnumber>
          <contributor>
            <role type='author'/>
            <organization>
              <name>International Telecommunication Union</name>
              <abbreviation>ITU</abbreviation>
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
              <email>y@example.com</email>
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
          <keyword>Word1</keyword>
          <keyword>word2</keyword>
          <ext>
            <doctype>service-publication</doctype>
            <flavor>itu</flavor>
            <editorialgroup>
              <bureau>R</bureau>
              <group>
                <name>I</name>
                #{current_study_period}
              </group>
              <subgroup>
                <name>I1</name>
                #{current_study_period}
              </subgroup>
              <workgroup>
                <name>I2</name>
                #{current_study_period}
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
      </metanorma>
    OUTPUT
    xml.xpath("//xmlns:boilerplate | //xmlns:metanorma-extension")
      .each(&:remove)
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output))
  end

  it "ignores unrecognised status" do
    xml = Nokogiri::XML(Asciidoctor.convert(<<~INPUT, *OPTIONS))
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :doctype: technical-corrigendum
      :secretariat: SECRETARIAT
      :status: pizza
      :iteration: 3
      :language: en
      :title: Main Title
      :legacy-do-not-insert-missing-sections:
    INPUT
    output = <<~"OUTPUT"
      <?xml version="1.0" encoding="UTF-8"?>
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" version="#{Metanorma::Itu::VERSION}" flavor="itu">
      <bibdata type="standard">
        <title language="en" format="text/plain" type="main">Main Title</title>
        <docidentifier primary="true" type="ITU">ITU-T 1000</docidentifier>
        <docidentifier type="ITU-lang">ITU-T 1000-E</docidentifier>
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
          <stage>pizza</stage>
        </status>
        <copyright>
          <from>#{Time.now.year}</from>
          <owner>
            <organization>
            <name>International Telecommunication Union</name>
            <abbreviation>ITU</abbreviation>
            </organization>
          </owner>
        </copyright>
        <ext>
          <doctype>technical-corrigendum</doctype>
            <flavor>itu</flavor>
          <editorialgroup>
            <bureau>T</bureau>
          </editorialgroup>
          <ip-notice-received>false</ip-notice-received>
          <structuredidentifier>
            <bureau>T</bureau>
            <docnumber>1000</docnumber>
          </structuredidentifier>
        </ext>
      </bibdata>
      <sections/>
      </metanorma>
    OUTPUT
    xml.xpath("//xmlns:boilerplate | //xmlns:metanorma-extension")
      .each(&:remove)
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output))
  end

  it "uses default fonts" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :no-pdf:
      :novalid:
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^}]+font-family: "Courier New", monospace;]m)
    expect(html).to match(%r[ div[^{]+\{[^}]+font-family: "Times New Roman", serif;]m)
    expect(html).to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: "Times New Roman", serif;]m)
  end

  it "uses default fonts (Word)" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :no-pdf:
      :novalid:
    INPUT
    html = File.read("test.doc", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^}]+font-family: "Courier New", monospace;]m)
    expect(html).to match(%r[ div[^{]+\{[^}]+font-family: "Times New Roman", serif;]m)
    expect(html).to match(%r[h1 \{[^}]+font-family: "Times New Roman", serif;]m)
  end

  it "uses Chinese fonts" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-pdf:
      :script: Hans
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^}]+font-family: "Courier New", monospace;]m)
    expect(html).to match(%r[ div[^{]+\{[^}]+font-family: "Source Han Sans", serif;]m)
    expect(html).to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: "Source Han Sans", sans-serif;]m)
  end

  it "uses specified fonts" do
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-pdf:
      :script: Hans
      :body-font: Zapf Chancery
      :header-font: Comic Sans
      :monospace-font: Andale Mono
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^{]+font-family: Andale Mono;]m)
    expect(html).to match(%r[ div,[^{]+\{[^}]+font-family: Zapf Chancery;]m)
    expect(html).to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: Comic Sans;]m)
  end

  it "processes stem blocks" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [stem%unnumbered%inequality]
      ++++
      r = 1 %
      r = 1 %
      ++++
    INPUT
    output = <<~OUTPUT
      #{@blank_hdr}
                 <sections>
           <formula id="_" unnumbered="true" inequality="true">
             <stem type="MathML" block="true">
               <math xmlns="http://www.w3.org/1998/Math/MathML">
                 <mstyle displaystyle="true">
                   <mi>r</mi>
                   <mo>=</mo>
                   <mn>1</mn>
                   <mi>%</mi>
                   <mi>r</mi>
                   <mo>=</mo>
                   <mn>1</mn>
                   <mi>%</mi>
                 </mstyle>
               </math>
               <asciimath>r = 1 %
       r = 1 %</asciimath>
             </stem>
           </formula>
         </sections>
       </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output))
  end

  it "processes steps class of ordered lists" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Clause

      [class=steps]
      .Caption
      . First
      . Second
    INPUT
    output = <<~OUTPUT
        #{@blank_hdr}
        <sections>
          <clause id="_" obligation="normative" inline-header='false'>
            <title>Clause</title>
            <ol id="_" class="steps">
              <name>Caption</name>
              <li>
                <p id="_">First</p>
              </li>
              <li>
                <p id="_">Second</p>
              </li>
            </ol>
          </clause>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output))
  end

  it "does not apply smartquotes by default" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :legacy-do-not-insert-missing-sections:

      == "Quotation" A's

      `"quote" A's`

      == “Quotation” A’s

      “Quotation” A’s
    INPUT
    output = <<~OUTPUT
        #{@blank_hdr}
        <sections>
          <clause id="_" obligation="normative" inline-header='false'>
            <title>"Quotation" A's</title>
            <p id="_">
              <tt>"quote" A's</tt>
            </p>
          </clause>
          <clause id="_" obligation="normative" inline-header='false'>
            <title>"Quotation" A's</title>
            <p id="_">"Quotation" A's</p>
          </clause>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output))
  end

  it "reorders references in bibliography, and renumbers citations accordingly" do
    VCR.use_cassette("multi_standards_sort",
                     match_requests_on: %i[method uri body]) do
      xml = Asciidoctor.convert(<<~INPUT, *OPTIONS)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :novalid:

        == Clause 1
        <<ref1>>
        <<ref2>>
        <<ref3>>
        <<ref8>>
        <<ref9>>
        <<ref10>>

        [bibliography]
        == References

        * [[[ref3,IEC 60027]]], _Standard IEC 123_
        * [[[ref1,ISO 55000]]], _Standard ISO 123_
        * [[[ref2,ISO/IEC 27001]]], _Standard ISO/IEC 123_
        * [[[ref8,ITU-T Z.100]]], _Standard 30_
        * [[[ref9,ITU-T Y.140]]], _Standard 30_
        * [[[ref10,ITU-T Y.1001]]], _Standard 30_
      INPUT
      xpath = Nokogiri::XML(xml)
        .xpath("//xmlns:references/xmlns:bibitem/xmlns:docidentifier")
      expect(Xml::C14n.format(strip_guid("<div>#{xpath.to_xml}</div>")))
        .to be_equivalent_to Xml::C14n.format(strip_guid(<<~OUTPUT))
           <div>
           <docidentifier type="ITU" primary="true">ITU-T Y.1001 (11/2000)</docidentifier>
          <docidentifier type="ITU" primary="true">ITU-T Y.140 (11/2000)</docidentifier>
          <docidentifier type="ITU" primary="true">ITU-T Z.100 (06/2021)</docidentifier>
          <docidentifier type="ISO" primary="true">ISO 55000</docidentifier>
          <docidentifier type="iso-reference">ISO 55000(E)</docidentifier>
          <docidentifier type="URN">urn:iso:std:iso:55000:stage-60.60</docidentifier>
          <docidentifier type="ISO" primary="true">ISO/IEC 27001</docidentifier>
          <docidentifier type="iso-reference">ISO/IEC 27001(E)</docidentifier>
          <docidentifier type="URN">urn:iso:std:iso-iec:27001:stage-60.60</docidentifier>
           <docidentifier type="IEC" primary="true">IEC 60027</docidentifier>
           <docidentifier type="URN">urn:iec:std:iec:60027::::</docidentifier>
           </div>
        OUTPUT
    end
  end

  it "preserves &lt; &amp; &gt;" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      [[clause]]
      == Clause

      &lt;&amp;&gt;
    INPUT
    output = <<~OUTPUT
        #{@blank_hdr}
        <sections>
          <clause id='clause' obligation='normative' inline-header='false'>
            <title>Clause</title>
            <p id='_'>&lt;&amp;&gt;</p>
          </clause>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output))
  end

  it "capitalises and centers table header" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [headerrows=2]
      |===
      |a b |b c |c
      |a |b |c

      |a |b |c
      |===

    INPUT
    output = <<~OUTPUT
        #{@blank_hdr}
        <sections>
          <table id="_">
            <thead>
              <tr>
                <th valign="top" align="center">A b</th>
                <th valign="top" align="center">B c</th>
                <th valign="top" align="center">C</th>
              </tr>
              <tr>
                <th valign="top" align="center">a</th>
                <th valign="top" align="center">b</th>
                <th valign="top" align="center">c</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td valign="top" align="left">a</td>
                <td valign="top" align="left">b</td>
                <td valign="top" align="left">c</td>
              </tr>
            </tbody>
          </table>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output))
  end
end

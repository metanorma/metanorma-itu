require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::ITU do
  it "has a version number" do
    expect(Metanorma::ITU::VERSION).not_to be nil
  end

  #it "generates output for the Rice document" do
  #  FileUtils.rm_rf %w(spec/examples/rfc6350.doc spec/examples/rfc6350.html spec/examples/rfc6350.pdf)
  #  FileUtils.cd "spec/examples"
  #  Asciidoctor.convert_file "rfc6350.adoc", {:attributes=>{"backend"=>"itu"}, :safe=>0, :header_footer=>true, :requires=>["metanorma-itu"], :failure_level=>4, :mkdirs=>true, :to_file=>nil}
  #  FileUtils.cd "../.."
  #  expect(xmlpp(File.exist?("spec/examples/rfc6350.doc"))).to be true
  #  expect(xmlpp(File.exist?("spec/examples/rfc6350.html"))).to be true
  #  expect(xmlpp(File.exist?("spec/examples/rfc6350.pdf"))).to be true
  #end
  
  it "processes a blank document" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    #{ASCIIDOC_BLANK_HDR}
    INPUT
    #{BLANK_HDR}
<sections/>
</itu-standard>
    OUTPUT
  end

  it "converts a blank document" do
    FileUtils.rm_f "test.html"
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-pdf:
      :legacy-do-not-insert-missing-sections:
    INPUT
    #{BLANK_HDR}
<sections/>
</itu-standard>
    OUTPUT
    expect(File.exist?("test.html")).to be true
  end

  it "converts a blank document and insert missing sections" do
    FileUtils.rm_f "test.html"
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-pdf:
      INPUT
    #{BLANK_HDR}
    <sections>
    <clause obligation='normative' type="scope" id="_">
             <title>Scope</title>
             <p id='_'>None.</p>
           </clause>
           <terms obligation='normative' id="_">
             <title>Definitions</title>
             <p id='_'>None.</p>
           </terms>
           <definitions obligation='normative' id="_">
             <title>Abbreviations and acronyms</title>
             <p id='_'>None.</p>
           </definitions>
           <clause obligation='normative' id='_' type="conventions">
             <title>Conventions</title>
             <p id='_'>None.</p>
           </clause>
</sections>
<bibliography>
  <references obligation='informative' normative="true" id="_">
    <title>References</title>
    <p id='_'>None.</p>
  </references>
</bibliography>
</itu-standard>
      OUTPUT
  end


    it "processes default metadata" do
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true).sub(%r{<boilerplate>.*</boilerplate>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    <itu-standard xmlns="https://www.metanorma.org/ns/itu" type="semantic" version="#{Metanorma::ITU::VERSION}">
<bibdata type="standard">
  <title language="en" format="text/plain" type="main">Main Title</title>
  <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
  <docidentifier type="ITU">ITU-T 1000</docidentifier>
  <docnumber>1000</docnumber>
  <contributor>
    <role type="author"/>
    <organization>
      <name>International Telecommunication Union</name>
    </organization>
  </contributor>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>International Telecommunication Union</name>
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
      </organization>
    </owner>
  </copyright>
  <ext>
    <doctype>recommendation</doctype>
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
</itu-standard>
OUTPUT
    end

  it "processes explicit metadata" do
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true).sub(%r{<boilerplate>.*</boilerplate>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :provisional-name: ABC
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

    INPUT
<?xml version="1.0" encoding="UTF-8"?>
<itu-standard xmlns="https://www.metanorma.org/ns/itu" type="semantic" version="#{Metanorma::ITU::VERSION}">
<bibdata type="standard">
  <title language="en" format="text/plain" type="main">Main Title</title>
  <title language="en" format="text/plain" type="annex">I3</title>
  <title language="fr" format="text/plain" type="main">Titre Principal</title>
  <title language="fr" format="text/plain" type="annex">J3</title>
  <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
<title language='fr' format='text/plain' type='subtitle'>Soustitre</title>
<title language='en' format='text/plain' type='amendment'>Amendment Title</title>
<title language='fr' format='text/plain' type='amendment'>Titre de Amendment</title>
<title language='en' format='text/plain' type='corrigendum'>Corrigendum Title</title>
<title language='fr' format='text/plain' type='corrigendum'>Titre de Corrigendum</title>
  <docidentifier type="ITU-provisional">ABC</docidentifier>
  <docidentifier type="ITU">ITU-R 1000</docidentifier>
  <docnumber>1000</docnumber>
  <contributor>
    <role type="author"/>
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
    </person>
  </contributor>
  <contributor>
    <role type='editor'/>
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
     <keyword>Word1</keyword>
 <keyword>word2</keyword>
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
  <annexid>H3</annexid>
  <amendment>88</amendment>
<corrigendum>88</corrigendum>
</structuredidentifier>
  </ext>
</bibdata>
<sections/>
</itu-standard>
    OUTPUT
  end

  it "processes explicit metadata, technical report" do
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true).sub(%r{<boilerplate>.*</boilerplate>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
      :keywords: word2,word1
      :meeting: Meeting X
      :meeting-date: 2000-01-01/2000-01-02
      :intended-type: TD
      :source: Source
      :draft: 5
      :role: author
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
    <itu-standard xmlns='https://www.metanorma.org/ns/itu' type='semantic' version='#{Metanorma::ITU::VERSION'>
         <bibdata type='standard'>
           <title language='en' format='text/plain' type='main'>Main Title</title>
           <title language='fr' format='text/plain' type='main'>Titre Principal</title>
           <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
           <title language='fr' format='text/plain' type='subtitle'>Soustitre</title>
           <docidentifier type='ITU-provisional'>ABC</docidentifier>
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
OUTPUT
  end

   it "processes explicit metadata, technical report #2" do
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true).sub(%r{<boilerplate>.*</boilerplate>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
      :keywords: word2,word1
      :meeting: Meeting X
      :meeting-date: 2000-01-01
      :intended-type: TD
      :source: Source
      :draft: 5

    INPUT
    <itu-standard xmlns='https://www.metanorma.org/ns/itu' type='semantic' version='#{Metanorma::ITU::VERSION}'>
         <bibdata type='standard'>
           <title language='en' format='text/plain' type='main'>Main Title</title>
           <title language='fr' format='text/plain' type='main'>Titre Principal</title>
           <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
           <title language='fr' format='text/plain' type='subtitle'>Soustitre</title>
           <docidentifier type='ITU-provisional'>ABC</docidentifier>
           <docidentifier type='ITU'>ITU-R 1000</docidentifier>
           <docnumber>1000</docnumber>
           <contributor>
             <role type='author'/>
             <organization>
               <name>International Telecommunication Union</name>
             </organization>
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
       </itu-standard>
OUTPUT
   end

  it "ignores unrecognised status" do
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true).sub(%r{<boilerplate>.*</boilerplate>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
       <?xml version="1.0" encoding="UTF-8"?>
       <itu-standard xmlns="https://www.metanorma.org/ns/itu" type="semantic" version="#{Metanorma::ITU::VERSION}">
       <bibdata type="standard">
         <title language="en" format="text/plain" type="main">Main Title</title>
         <docidentifier type="ITU">ITU-T 1000</docidentifier>
         <docnumber>1000</docnumber>
         <contributor>
           <role type="author"/>
           <organization>
      <name>International Telecommunication Union</name>
           </organization>
         </contributor>
         <contributor>
           <role type="publisher"/>
           <organization>
      <name>International Telecommunication Union</name>
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
             </organization>
           </owner>
         </copyright>
         <ext>
         <doctype>technical-corrigendum</doctype>
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
       </itu-standard>
        OUTPUT
    end

  it "does not strip inline header" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      This is a preamble

      [%inline-header]
      == Section 1
      INPUT
    #{BLANK_HDR}
             <preface><foreword id="_" obligation="informative">
         <title>Foreword</title>
         <p id="_">This is a preamble</p>
       </foreword>
       </preface>
       <sections>
       <clause id="_" obligation="normative" inline-header="true">
         <title>Section 1</title>
       </clause></sections>
       </itu-standard>
    OUTPUT
  end

  it "uses default fonts" do
    FileUtils.rm_f "test.html"
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
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
    FileUtils.rm_f "test.doc"
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
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
    FileUtils.rm_f "test.html"
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-pdf:
      :script: Hans
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^}]+font-family: "Courier New", monospace;]m)
    expect(html).to match(%r[ div[^{]+\{[^}]+font-family: "SimSun", serif;]m)
    expect(html).to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: "SimHei", sans-serif;]m)
  end

  it "uses specified fonts" do
    FileUtils.rm_f "test.html"
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
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

  it "move sections to preface" do
    FileUtils.rm_f "test.html"
        expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      
      [preface]
      == Prefatory
      section

      == Section

      text
    INPUT
    #{BLANK_HDR}
    <preface><clause id="_" obligation="informative" inline-header='false'>
  <title>Prefatory</title>
  <p id="_">section</p>
</clause></preface><sections>
<clause id="_" obligation="normative" inline-header="false">
  <title>Section</title>
  <p id="_">text</p>
</clause></sections>
</itu-standard>

    OUTPUT
  end

  it "processes sections" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      .Foreword

      Text

      [abstract]
      == Abstract

      Text

      == Introduction

      === Introduction Subsection

      [preface]
      == History

      [preface]
      == Source

      == Scope

      Text

      [bibliography]
      == References

      == Terms and Definitions

      === Term1

      == Terms, Definitions, Symbols and Abbreviated Terms

      [.nonterm]
      === Introduction

      ==== Intro 1

      === Intro 2

      [.nonterm]
      ==== Intro 3

      === Intro 4

      ==== Intro 5

      ===== Term1

      === Normal Terms

      ==== Term2

      ==== Terms defined elsewhere

      === Symbols and Abbreviated Terms

      [.nonterm]
      ==== General

      ==== Symbols 1

      == Abbreviated Terms

      == Conventions

      == Clause 4

      === Introduction

      === Clause 4.2

      == Terms and Definitions

      == History

      == Source

      [appendix]
      == Annex

      === Annex A.1

      == Bibliography

      === Bibliography Subsection

      [bibliography]
      == Second Bibliography
    INPUT
    #{BLANK_HDR.sub(/<status>/, "<abstract> <p>Text</p> </abstract><status>")}
    <preface>
           <abstract id='_'>
             <title>Abstract</title>
             <p id='_'>Text</p>
           </abstract>
           <foreword id='_' obligation='informative'>
             <title>Foreword</title>
             <p id='_'>Text</p>
           </foreword>
           <introduction id='_' obligation='informative'>
             <title>Introduction</title>
             <clause id='_' inline-header='false' obligation='informative'>
               <title>Introduction Subsection</title>
             </clause>
           </introduction>
           <clause id='_' type='history' inline-header='false' obligation='informative'>
             <title>History</title>
           </clause>
           <clause id='_' type='source' inline-header='false' obligation='informative'>
             <title>Source</title>
           </clause>
         </preface>
         <sections>
           <clause id='_' type='scope' inline-header='false' obligation='normative'>
             <title>Scope</title>
             <p id='_'>Text</p>
           </clause>
           <terms id='_' obligation='normative'>
             <title>Definitions</title>
             <p id='_'>This Recommendation defines the following terms:</p>
             <term id='_'>
               <preferred>Term1</preferred>
             </term>
           </terms>
           <clause id='_' obligation='normative'>
             <title>Terms, Definitions, Symbols and Abbreviated Terms</title>
             <clause id='_' inline-header='false' obligation='normative'>
               <title>Introduction</title>
               <clause id='_' inline-header='false' obligation='normative'>
                 <title>Intro 1</title>
               </clause>
             </clause>
             <terms id='_' obligation='normative'>
               <title>Intro 2</title>
               <p id='_'>None.</p>
               <clause id='_' inline-header='false' obligation='normative'>
                 <title>Intro 3</title>
               </clause>
             </terms>
             <clause id='_' obligation='normative'>
               <title>Intro 4</title>
               <terms id='_' obligation='normative'>
                 <title>Intro 5</title>
                 <term id='_'>
                   <preferred>Term1</preferred>
                 </term>
               </terms>
             </clause>
             <clause id='_' obligation='normative'>
               <title>Normal Terms</title>
               <term id='_'>
                 <preferred>Term2</preferred>
               </term>
               <terms id='_' type='external' obligation='normative'>
                 <title>Terms defined elsewhere</title>
                 <p id='_'>None.</p>
               </terms>
             </clause>
             <terms id='_' obligation='normative'>
               <title>Symbols and Abbreviated Terms</title>
               <clause id='_' inline-header='false' obligation='normative'>
                 <title>General</title>
               </clause>
               <term id='_'>
                 <preferred>Symbols 1</preferred>
               </term>
             </terms>
           </clause>
           <definitions id='_' type='abbreviated_terms' obligation='normative'>
             <title>Abbreviations and acronyms</title>
             <p id='_'>None.</p>
           </definitions>
           <clause id='_' type='conventions' inline-header='false' obligation='normative'>
             <title>Conventions</title>
           </clause>
           <clause id='_' inline-header='false' obligation='normative'>
             <title>Clause 4</title>
             <clause id='_' inline-header='false' obligation='normative'>
               <title>Introduction</title>
             </clause>
             <clause id='_' inline-header='false' obligation='normative'>
               <title>Clause 4.2</title>
             </clause>
           </clause>
           <clause id='_' inline-header='false' obligation='normative'>
             <title>Terms and Definitions</title>
           </clause>
           <clause id='_' inline-header='false' obligation='normative'>
             <title>History</title>
           </clause>
           <clause id='_' inline-header='false' obligation='normative'>
             <title>Source</title>
           </clause>
         </sections>
         <annex id='_' inline-header='false' obligation='normative'>
           <title>Annex</title>
           <clause id='_' inline-header='false' obligation='normative'>
             <title>Annex A.1</title>
           </clause>
         </annex>
         <bibliography>
           <references id='_' normative='true' obligation='informative'>
             <title>References</title>
             <p id='_'>None.</p>
           </references>
           <clause id='_' obligation='informative'>
             <title>Bibliography</title>
             <references id='_' normative='false' obligation='informative'>
               <title>Bibliography Subsection</title>
             </references>
           </clause>
           <references id='_' normative='false' obligation='informative'>
             <title>Bibliography</title>
           </references>
         </bibliography>
       </itu-standard>
OUTPUT
  end

  it "inserts boilerplate before empty Normative References" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}

      [bibliography]
      == References

      INPUT
      #{BLANK_HDR}
      <sections>

</sections><bibliography><references id="_" obligation="informative" normative="true">
  <title>References</title><p id="_">None.</p>
</references></bibliography>
</itu-standard>
      OUTPUT
      end

 it "inserts boilerplate before non-empty Normative References" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}

      [bibliography]
      == References
      * [[[a,b]]] A

      INPUT
    #{BLANK_HDR}
    <sections>

       </sections><bibliography><references id="_" obligation="informative" normative="true">
         <title>References</title>
<p id="_">The following ITU-T Recommendations and other references contain provisions which, through reference in this text, constitute provisions of this Recommendation. At the time of publication, the editions indicated were valid. All Recommendations and other references are subject to revision; users of this Recommendation are therefore encouraged to investigate the possibility of applying the most recent edition of the Recommendations and other references listed below. A list of the currently valid ITU-T Recommendations is regularly published. The reference to a document within this Recommendation does not give it, as a stand-alone document, the status of a Recommendation.</p>
         <bibitem id="a">
         <formattedref format="application/x-isodoc+xml">A</formattedref>
         <docidentifier>b</docidentifier>
       </bibitem>
       </references></bibliography>
       </itu-standard>

      OUTPUT
      end

   it "processes stem blocks" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [stem%unnumbered%inequality]
      ++++
      r = 1 %
      r = 1 %
      ++++
INPUT
            #{BLANK_HDR}
            <sections>
         <formula id="_" inequality="true" unnumbered="true">
         <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>r</mi><mo>=</mo><mn>1</mn><mi>%</mi><mi>r</mi><mo>=</mo><mn>1</mn><mi>%</mi></math></stem>
       </formula>
       </sections>
       </itu-standard>
OUTPUT
   end

   it "inserts boilerplate before internal and external terms clause" do
        expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
        #{ASCIIDOC_BLANK_HDR}
        == Definitions
        === terms defined elsewhere       
        ==== Term 1
        === terms defined in this recommendation
        ==== Term 2
        INPUT
        #{BLANK_HDR}
       <sections>
           <clause id='_' obligation='normative'>
             <title>Definitions</title>
             <terms id='_' type='external' obligation='normative'>
               <title>Terms defined elsewhere</title>
               <p id='_'>This Recommendation uses the following terms defined elsewhere:</p>
               <term id='_'>
                 <preferred>Term 1</preferred>
               </term>
             </terms>
             <terms id='_' type='internal' obligation='normative'>
               <title>Terms defined in this recommendation</title>
               <p id='_'>This Recommendation defines the following terms:</p>
               <term id='_'>
                 <preferred>Term 2</preferred>
               </term>
             </terms>
           </clause>
         </sections>
       </itu-standard>
        OUTPUT
   end

   it "inserts boilerplate before empty internal and external terms clause" do
        expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
        #{ASCIIDOC_BLANK_HDR}
        == Definitions
        === terms defined elsewhere
        === terms defined in this recommendation
        INPUT
        #{BLANK_HDR}
<sections>
           <clause id='_' obligation='normative'>
             <title>Definitions</title>
             <terms id='_' type='external' obligation='normative'>
               <title>Terms defined elsewhere</title>
               <p id='_'>None.</p>
             </terms>
             <terms id='_' type='internal' obligation='normative'>
               <title>Terms defined in this recommendation</title>
               <p id='_'>None.</p>
             </terms>
           </clause>
         </sections>
       </itu-standard>
        OUTPUT
   end

   it "does not insert boilerplate before internal and external terms clause if already populated" do
        expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
        #{ASCIIDOC_BLANK_HDR}
        == Definitions
        === terms defined elsewhere       

        Boilerplate

        ==== Term 1
        === terms defined in this recommendation

        Boilerplate

        ==== Term 2
        INPUT
        #{BLANK_HDR}
        <sections>
           <clause id='_' obligation='normative'>
             <title>Definitions</title>
             <terms id='_' type='external' obligation='normative'>
               <title>Terms defined elsewhere</title>
               <p id='_'>Boilerplate</p>
               <term id='_'>
                 <preferred>Term 1</preferred>
               </term>
             </terms>
             <terms id='_' type='internal' obligation='normative'>
               <title>Terms defined in this recommendation</title>
               <p id='_'>Boilerplate</p>
               <term id='_'>
                 <preferred>Term 2</preferred>
               </term>
             </terms>
           </clause>
         </sections>
       </itu-standard>
        OUTPUT
   end

   it "inserts boilerplate before definitions with no internal and external terms clauses" do
        expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
        #{ASCIIDOC_BLANK_HDR}
        == Definitions
        === terms defined somewhere
        ==== Term 1
        === terms defined somewhere else
        ==== Term 2
        INPUT
        #{BLANK_HDR}
        <sections>
  <clause id="_" obligation="normative"><title>Definitions</title><p id="_">This Recommendation defines the following terms:</p><terms id="_" obligation="normative">
  <title>terms defined somewhere</title>
  <term id="_">
  <preferred>Term 1</preferred>
</term>
</terms>
<terms id="_" obligation="normative">
  <title>terms defined somewhere else</title>
  <term id="_">
  <preferred>Term 2</preferred>
</term>
</terms></clause>
</sections>
</itu-standard>
        OUTPUT
   end

   it "does not insert boilerplate before definitions with no internal and external terms clauses, if already populated" do
        expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
        #{ASCIIDOC_BLANK_HDR}
        == Definitions

        Boilerplate

        === terms defined somewhere
        ==== Term 1
        === terms defined somewhere else
        ==== Term 2
        INPUT
        #{BLANK_HDR}
        <sections>
  <clause id="_" obligation="normative"><title>Definitions</title><p id="_">Boilerplate</p>
<terms id="_" obligation="normative">
  <title>terms defined somewhere</title>
  <term id="_">
  <preferred>Term 1</preferred>
</term>
</terms>
<terms id="_" obligation="normative">
  <title>terms defined somewhere else</title>
  <term id="_">
  <preferred>Term 2</preferred>
</term>
</terms></clause>
</sections>
</itu-standard>
        OUTPUT
   end

   it "inserts boilerplate before symbols" do
           expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
        #{ASCIIDOC_BLANK_HDR}
        == Abbreviations and acronyms

        a:: b
        INPUT
        #{BLANK_HDR}
        <sections>
  <definitions id="_" obligation='normative'>
  <title>Abbreviations and acronyms</title><p id="_">This Recommendation uses the following abbreviations and acronyms:</p>
  <dl id="_">
  <dt>a</dt>
  <dd>
    <p id="_">b</p>
  </dd>
</dl>
</definitions>
</sections>
</itu-standard>
OUTPUT
end

   it "does not insert boilerplate before symbols if already populated" do
           expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
        #{ASCIIDOC_BLANK_HDR}
        == Abbreviations and acronyms

        Boilerplate

        a:: b
        INPUT
        #{BLANK_HDR}
        <sections>
  <definitions id="_" obligation='normative'><title>Abbreviations and acronyms</title><p id="_">Boilerplate</p>
<dl id="_">
  <dt>a</dt>
  <dd>
    <p id="_">b</p>
  </dd>
</dl></definitions>
</sections>
</itu-standard>
OUTPUT
end

  it "inserts empty clause boilerplate" do
           expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
        #{ASCIIDOC_BLANK_HDR}
        == Terms and definitions

        [bibliography]
        == Normative References

        INPUT
        #{BLANK_HDR}
        <sections>
           <terms id='_' obligation='normative'>
             <title>Definitions</title>
             <p id='_'>None.</p>
           </terms>
         </sections>
         <bibliography>
           <references id='_' normative='true' obligation='informative'>
             <title>References</title>
             <p id='_'>None.</p>
           </references>
         </bibliography>
       </itu-standard>
OUTPUT
end


  it "processes steps class of ordered lists" do
           expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
        #{ASCIIDOC_BLANK_HDR}
        == Clause

        [class=steps]
        . First
        . Second
        INPUT
        #{BLANK_HDR}
        <sections>
  <clause id="_" obligation="normative" inline-header='false'>
  <title>Clause</title>
  <ol id="_" class="steps">
  <li>
    <p id="_">First</p>
  </li>
  <li>
    <p id="_">Second</p>
  </li>
</ol>
</clause>
</sections>
</itu-standard>
OUTPUT
end

it "does not apply smartquotes by default" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
       #{BLANK_HDR}
       <sections><clause id="_" obligation="normative" inline-header='false'>
         <title>"Quotation" A's</title>
         <p id="_">
         <tt>"quote" A's</tt>
       </p>
       </clause>
       <clause id="_" obligation="normative" inline-header='false'>
         <title>"Quotation" A's</title>
         <p id="_">"Quotation" A's</p>
       </clause></sections>
       </itu-standard>
    OUTPUT
  end

 it "reorders references in bibliography, and renumbers citations accordingly" do
    FileUtils.rm_rf File.expand_path("~/.relaton-bib.pstore1")
    FileUtils.mv File.expand_path("~/.relaton/cache"), File.expand_path("~/.relaton-bib.pstore1"), force: true
    FileUtils.rm_rf File.expand_path("~/.iev.pstore1")
    FileUtils.mv File.expand_path("~/.iev.pstore"), File.expand_path("~/.iev.pstore1"), force: true
    FileUtils.rm_rf "relaton/cache"
    FileUtils.rm_rf "test.iev.pstore"

  VCR.use_cassette "multi-standards sort", :re_record_interval => 25200 do
    xml = Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
    = Document title
    Author
    :docfile: test.adoc
    :nodoc:
    :novalid:
    
    == Clause 1
    <<ref1>>
    <<ref2>>
    <<ref3>>
    <<ref4>>
    <<ref8>>
    <<ref9>>
    <<ref10>>

    [bibliography]
    == References

    * [[[ref3,IEC 60027]]], _Standard IEC 123_
    * [[[ref1,ISO 55000]]], _Standard ISO 123_
    * [[[ref4,GB 12663-2019]]], _Standard GB 123_
    * [[[ref2,ISO/IEC 27001]]], _Standard ISO/IEC 123_
    * [[[ref8,ITU-T Z.100]]], _Standard 30_
    * [[[ref9,ITU-T Y.140]]], _Standard 30_
    * [[[ref10,ITU-T Y.1001]]], _Standard 30_
    INPUT
    xpath = Nokogiri::XML(xml).xpath("//xmlns:references/xmlns:bibitem/xmlns:docidentifier")
    expect(xmlpp("<div>#{xpath.to_xml}</div>")).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <div>
    <docidentifier type='ITU'>ITU-T Y.1001</docidentifier>
<docidentifier type='ITU'>ITU-T Y.140</docidentifier>
<docidentifier type='ITU'>ITU-T Z.100</docidentifier>
<docidentifier type='ISO'>ISO 55000:2014</docidentifier>
<docidentifier type='URN'>urn:iso:std:iso:55000:stage-90.20:ed-1:en</docidentifier>
<docidentifier type='ISO'>ISO/IEC 27001 (all parts)</docidentifier>
<docidentifier type='URN'>urn:iso:std:iso-iec:27001</docidentifier>
<docidentifier type='IEC'>IEC 60027-1+AMD1:1997+AMD2:2005 CSV</docidentifier>
<docidentifier type='URN'>urn:iec:std:iec:60027-1:::csv:en:plus:amd:1:1997:plus:amd:2:2005</docidentifier>
<docidentifier type='Chinese Standard'>GB 12663-2019</docidentifier>
</div>
    OUTPUT
    FileUtils.rm_rf File.expand_path("~/.relaton/cache")
    FileUtils.mv File.expand_path("~/.relaton-bib.pstore1"), File.expand_path("~/.relaton/cache"), force: true
    FileUtils.rm_rf File.expand_path("~/.iev.pstore")
    FileUtils.mv File.expand_path("~/.iev.pstore1"), File.expand_path("~/.iev.pstore"), force: true
end
end

   it "uses add, del macros" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}

      [[clause]]
      == Clause

      add:[a <<clause>>] del:[B]
    INPUT
       #{BLANK_HDR}
       <sections>
       <clause id='clause' obligation='normative' inline-header='false'>
             <title>Clause</title>
             <p id='_'>
               <add>
                 a
                 <xref target='clause'/>
               </add>
               <del>B</del>
             </p>
           </clause>
</sections>
       </itu-standard>
    OUTPUT
  end

     it "preserves &lt; &amp; &gt;" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}

      [[clause]]
      == Clause

      &lt;&amp;&gt;
    INPUT
       #{BLANK_HDR}
       <sections>
       <clause id='clause' obligation='normative' inline-header='false'>
             <title>Clause</title>
             <p id='_'>&lt;&amp;&gt;</p>
           </clause>
</sections>
       </itu-standard>
    OUTPUT
  end

     it "capitalises table header" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [headerrows=2]
      |===
      |a b |b c |c
      |a |b |c

      |a |b |c
      |===

    INPUT
       #{BLANK_HDR}
       <sections><table id="_">
         <thead>
           <tr>
             <th valign="top" align="left">A b</th>
             <th valign="top" align="left">B c</th>
             <th valign="top" align="left">C</th>
           </tr>
           <tr>
             <th valign="top" align="left">a</th>
             <th valign="top" align="left">b</th>
             <th valign="top" align="left">c</th>
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
       </itu-standard>
    OUTPUT
  end

     it "has unique terms and definitions clauses" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      
      == Definitions

      === Term 1

      == Abbreviations and acronyms

      a:: b

      == Clause

      === Definitions

      ==== Term 1

      === Abbreviations and acronyms

      a:: b

      == Clause 2

      [heading=Definitions]
      === Definitions

      ==== Term 1

      [heading=Abbreviations and acronyms]
      === Abbreviations and acronyms

      a:: b


    INPUT
    #{BLANK_HDR}
         <sections>
           <terms id='_' obligation='normative'>
             <title>Definitions</title>
             <p id='_'>This Recommendation defines the following terms:</p>
             <term id='_'>
               <preferred>Term 1</preferred>
             </term>
           </terms>
           <definitions id='_' obligation='normative'>
             <title>Abbreviations and acronyms</title>
             <p id='_'>This Recommendation uses the following abbreviations and acronyms:</p>
             <dl id='_'>
               <dt>a</dt>
               <dd>
                 <p id='_'>b</p>
               </dd>
             </dl>
           </definitions>
           <clause id='_' inline-header='false' obligation='normative'>
             <title>Clause</title>
             <clause id='_' inline-header='false' obligation='normative'>
               <title>Definitions</title>
               <clause id='_' inline-header='false' obligation='normative'>
                 <title>Term 1</title>
               </clause>
             </clause>
             <clause id='_' inline-header='false' obligation='normative'>
               <title>Abbreviations and acronyms</title>
               <dl id='_'>
                 <dt>a</dt>
                 <dd>
                   <p id='_'>b</p>
                 </dd>
               </dl>
             </clause>
           </clause>
           <clause id='_' inline-header='false' obligation='normative'>
             <title>Clause 2</title>
             <clause id='_' inline-header='false' obligation='normative'>
               <title>Definitions</title>
               <clause id='_' inline-header='false' obligation='normative'>
                 <title>Term 1</title>
               </clause>
             </clause>
             <definitions id='_' obligation='normative'>
               <title>Abbreviations and acronyms</title>
               <dl id='_'>
                 <dt>a</dt>
                 <dd>
                   <p id='_'>b</p>
                 </dd>
               </dl>
             </definitions>
           </clause>
         </sections>
       </itu-standard>
OUTPUT
     end


end

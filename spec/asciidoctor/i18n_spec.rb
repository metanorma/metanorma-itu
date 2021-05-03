require "spec_helper"
require "fileutils"

OPTIONS = [backend: :itu, header_footer: true].freeze

RSpec.describe Asciidoctor::ITU do
  before(:all) do
    @blank_hdr = blank_hdr_gen
  end

  it "processes explicit metadata, service publication in French" do
    output = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
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
      :language: fr
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
    expect(xmlpp(output.sub(%r{<boilerplate>.*</boilerplate>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <itu-standard xmlns='https://www.metanorma.org/ns/itu' type='semantic' version='#{Metanorma::ITU::VERSION}'>
        <bibdata type='standard'>
          <title language='en' format='text/plain' type='main'>Main Title</title>
          <title language='fr' format='text/plain' type='main'>Titre Principal</title>
          <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
          <title language='fr' format='text/plain' type='subtitle'>Soustitre</title>
          <docidentifier type='ITU-provisional'>ABC</docidentifier>
          <docidentifier type='ITU'>Annexe au BE de l'UIT 1000</docidentifier>
          <docidentifier type='ITU-lang'>Annexe au BE de l'UIT 1000-F</docidentifier>
          <docnumber>1000</docnumber>
          <contributor>
            <role type='author'/>
            <organization>
              <name>International Telecommunication Union</name>
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
            </organization>
          </contributor>
          <edition>2</edition>
          <version>
            <revision-date>2000-01-01</revision-date>
            <draft>5</draft>
          </version>
          <language>fr</language>
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
            <doctype>service-publication</doctype>
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

  it "processes explicit metadata, service publication in Chinese" do
    output = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
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
      :language: zh
      :script: Hans
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
    expect(xmlpp(output.sub(%r{<boilerplate>.*</boilerplate>}m, ""))).to be_equivalent_to xmlpp(<<~"OUTPUT")
       <itu-standard xmlns='https://www.metanorma.org/ns/itu' type='semantic' version='#{Metanorma::ITU::VERSION}'>
       <bibdata type='standard'>
           <title language='en' format='text/plain' type='main'>Main Title</title>
           <title language='fr' format='text/plain' type='main'>Titre Principal</title>
           <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
           <title language='fr' format='text/plain' type='subtitle'>Soustitre</title>
           <docidentifier type='ITU-provisional'>ABC</docidentifier>
           <docidentifier type='ITU'>
             &#22269;&#38469;&#30005;&#32852;&#25805;&#20316;&#20844;&#25253;&#38468;&#20214; &#31532; 1000 &#26399;
           </docidentifier>
           <docidentifier type='ITU-lang'>
             &#22269;&#38469;&#30005;&#32852;&#25805;&#20316;&#20844;&#25253;&#38468;&#20214; &#31532; 1000 &#26399;-C
           </docidentifier>
           <docnumber>1000</docnumber>
           <contributor>
             <role type='author'/>
             <organization>
               <name>International Telecommunication Union</name>
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
             </organization>
           </contributor>
           <edition>2</edition>
           <version>
             <revision-date>2000-01-01</revision-date>
             <draft>5</draft>
           </version>
           <language>zh</language>
           <script>Hans</script>
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
             <doctype>service-publication</doctype>
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

   it "processes sections in Chinese" do
     expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR.sub(/:novalid:/, ":novalid:\n:language: zh\n:script: Hans")}
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

      [%unnumbered]
      == {blank}

      Initial text

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
       #{@blank_hdr.sub(/<status>/, '<abstract> <p>Text</p> </abstract><status>')
         .sub('<language>en</language>', '<language>zh</language>')
         .sub('<script>Latn</script>', '<script>Hans</script>')}
       <preface>
           <abstract id='_'>
             <title>&#25688;&#35201;</title>
             <p id='_'>Text</p>
           </abstract>
           <foreword id='_' obligation='informative'>
             <title>&#21069;&#35328;</title>
             <p id='_'>Text</p>
           </foreword>
           <introduction id='_' obligation='informative'>
             <title>&#24341;&#35328;</title>
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
           <clause id='_' unnumbered='true' inline-header='false' obligation='normative'>
             <p id='_'>Initial text</p>
           </clause>
           <clause id='_' type='scope' inline-header='false' obligation='normative'>
             <title>&#33539;&#22260;</title>
             <p id='_'>Text</p>
           </clause>
           <terms id='_' obligation='normative'>
             <title>&#23450;&#20041;</title>
             <p id='_'>
               &#26412;&#24314;&#35758;&#20070;&#23450;&#20041;&#19979;&#21015;&#26415;&#35821;&#65306;
             </p>
             <term id='term-term1'>
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
               <p id='_'>&#26080;</p>
               <clause id='_' inline-header='false' obligation='normative'>
                 <title>Intro 3</title>
               </clause>
             </terms>
             <clause id='_' obligation='normative'>
               <title>Intro 4</title>
               <terms id='_' obligation='normative'>
                 <title>Intro 5</title>
                 <term id='term-term1-1'>
                   <preferred>Term1</preferred>
                 </term>
               </terms>
             </clause>
             <clause id='_' obligation='normative'>
               <title>Normal Terms</title>
               <term id='term-term2'>
                 <preferred>Term2</preferred>
               </term>
               <terms id='_' type='external' obligation='normative'>
                 <title>&#20854;&#20182;&#22320;&#26041;&#23450;&#20041;&#30340;&#26415;&#35821;</title>
                 <p id='_'>&#26080;</p>
               </terms>
             </clause>
             <terms id='_' obligation='normative'>
               <title>Symbols and Abbreviated Terms</title>
               <clause id='_' inline-header='false' obligation='normative'>
                 <title>General</title>
               </clause>
               <term id='term-symbols-1'>
                 <preferred>Symbols 1</preferred>
               </term>
             </terms>
           </clause>
           <definitions id='_' type='abbreviated_terms' obligation='normative'>
             <title>&#32553;&#30053;&#35821;&#19982;&#32553;&#20889;</title>
             <p id='_'>&#26080;</p>
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
             <title>&#35268;&#33539;&#24615;&#21442;&#32771;&#25991;&#29486;</title>
             <p id='_'>&#26080;</p>
           </references>
           <clause id='_' obligation='informative'>
             <title>&#21442;&#32771;&#25991;&#29486;</title>
             <references id='_' normative='false' obligation='informative'>
               <title>Bibliography Subsection</title>
             </references>
           </clause>
           <references id='_' normative='false' obligation='informative'>
             <title>Second Bibliography</title>
           </references>
         </bibliography>
        </itu-standard>
    OUTPUT
   end
end

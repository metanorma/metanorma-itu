require "spec_helper"
require "fileutils"

OPTIONS = [backend: :itu, header_footer: true].freeze

RSpec.describe Asciidoctor::ITU do
  before(:all) do
    @blank_hdr = blank_hdr_gen
  end

  it "processes explicit metadata, service publication in French" do
    input = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
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
    output = <<~"OUTPUT"
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
    expect(xmlpp(input.sub(%r{<boilerplate>.*</boilerplate>}m, "")))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes sections in French" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR.sub(/:novalid:/, ":novalid:\n:language: fr\n:script: Latn")}
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
    output = <<~OUTPUT
            #{@blank_hdr.sub(/<status>/, '<abstract> <p>Text</p> </abstract><status>')
              .sub('<title language="en"', '<title language="fr"')
              .sub('<language>en</language>', '<language>fr</language>')}
               <preface>
        <abstract id='_'>
          <title>R&#233;sum&#233;</title>
          <p id='_'>Text</p>
        </abstract>
        <foreword id='_' obligation='informative'>
          <title>Avant-propos</title>
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
        <clause id='_' unnumbered='true' inline-header='false' obligation='normative'>
          <p id='_'>Initial text</p>
        </clause>
        <clause id='_' type='scope' inline-header='false' obligation='normative'>
          <title>Domaine d'application</title>
          <p id='_'>Text</p>
        </clause>
        <terms id='_' obligation='normative'>
          <title>D&#233;finitions</title>
          <p id='_'>La pr&#233;sente Recommandation d&#233;finit les termes suivants:</p>
          <term id='term-term1'>
            <preferred><expression><name>Term1</name></expression></preferred>
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
            <p id='_'>Aucun.</p>
            <clause id='_' inline-header='false' obligation='normative'>
              <title>Intro 3</title>
            </clause>
          </terms>
          <clause id='_' obligation='normative'>
            <title>Intro 4</title>
            <terms id='_' obligation='normative'>
              <title>Intro 5</title>
              <term id='term-term1-1'>
                <preferred><expression><name>Term1</name></expression></preferred>
              </term>
            </terms>
          </clause>
          <clause id='_' obligation='normative'>
            <title>Normal Terms</title>
            <term id='term-term2'>
              <preferred><expression><name>Term2</name></expression></preferred>
            </term>
            <terms id='_' type='external' obligation='normative'>
              <title>Termes d&#233;finis ailleurs</title>
              <p id='_'>Aucun.</p>
            </terms>
          </clause>
          <terms id='_' obligation='normative'>
            <title>Symbols and Abbreviated Terms</title>
            <clause id='_' inline-header='false' obligation='normative'>
              <title>General</title>
            </clause>
            <term id='term-symbols-1'>
              <preferred><expression><name>Symbols 1</name></expression></preferred>
            </term>
          </terms>
        </clause>
        <definitions id='_' type='abbreviated_terms' obligation='normative'>
          <title>Abr&#233;viations et acronymes</title>
          <p id='_'>Aucun.</p>
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
          <title>R&#233;f&#233;rences</title>
          <p id='_'>Aucun.</p>
        </references>
        <clause id='_' obligation='informative'>
          <title>Bibliographie</title>
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
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes explicit metadata, service publication in Chinese" do
    input = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
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
    output = <<~"OUTPUT"
      <itu-standard xmlns='https://www.metanorma.org/ns/itu' type='semantic' version='#{Metanorma::ITU::VERSION}'>
      <bibdata type='standard'>
          <title language='zh' format='text/plain' type='main'>Document title</title>
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
    expect(xmlpp(input.sub(%r{<boilerplate>.*</boilerplate>}m, "")))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes sections in Chinese" do
    input = <<~INPUT
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
    output = <<~OUTPUT
      #{@blank_hdr.sub(/<status>/, '<abstract> <p>Text</p> </abstract><status>')
        .sub('<language>en</language>', '<language>zh</language>')
        .sub('<title language="en"', '<title language="zh"')
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
              <preferred><expression><name>Term1</name></expression></preferred>
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
                  <preferred><expression><name>Term1</name></expression></preferred>
                </term>
              </terms>
            </clause>
            <clause id='_' obligation='normative'>
              <title>Normal Terms</title>
              <term id='term-term2'>
                <preferred><expression><name>Term2</name></expression></preferred>
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
                <preferred><expression><name>Symbols 1</name></expression></preferred>
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
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes explicit metadata, service publication in Arabic" do
    input = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
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
      :language: ar
      :title-en: Main Title
      :title-ar: Titre Principal
      :subtitle-en: Subtitle
      :subtitle-ar: Soustitre
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
           <itu-standard xmlns='https://www.metanorma.org/ns/itu' type='semantic' version='#{Metanorma::ITU::VERSION}'>
      <bibdata type='standard'>
        <title language='en' format='text/plain' type='main'>Main Title</title>
        <title language='ar' format='text/plain' type='main'>Titre Principal</title>
        <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
        <title language='ar' format='text/plain' type='subtitle'>Soustitre</title>
        <docidentifier type='ITU-provisional'>ABC</docidentifier>
        <docidentifier type='ITU'>
          &#1605;&#1604;&#1581;&#1602;
          &#1576;&#1575;&#1604;&#1606;&#1588;&#1585;&#1577;
          &#1575;&#1604;&#1578;&#1588;&#1594;&#1610;&#1604;&#1610;&#1577;
          &#1604;&#1604;&#1575;&#1578;&#1581;&#1575;&#1583; &#1585;&#1602;&#1605;
        </docidentifier>
        <docidentifier type='ITU-lang'>
          &#1605;&#1604;&#1581;&#1602;
          &#1576;&#1575;&#1604;&#1606;&#1588;&#1585;&#1577;
          &#1575;&#1604;&#1578;&#1588;&#1594;&#1610;&#1604;&#1610;&#1577;
          &#1604;&#1604;&#1575;&#1578;&#1581;&#1575;&#1583; &#1585;&#1602;&#1605;-A
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
        <language>ar</language>
        <script>Arab</script>
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
    expect(xmlpp(input.sub(%r{<boilerplate>.*</boilerplate>}m, "")))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes sections in Arabic" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR
       .sub(/:novalid:/, ":novalid:\n:language: ar\n:script: Arab")}
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
    output = <<~OUTPUT
            #{@blank_hdr.sub(/<status>/, '<abstract> <p>Text</p> </abstract><status>')
              .sub('<language>en</language>', '<language>ar</language>')
              .sub('<title language="en"', '<title language="ar"')
              .sub('<script>Latn</script>', '<script>Arab</script>')}
               <preface>
        <abstract id='_'>
          <title>&#1605;&#1604;&#1582;&#1589;</title>
          <p id='_'>Text</p>
        </abstract>
        <foreword id='_' obligation='informative'>
          <title>&#1578;&#1605;&#1607;&#1610;&#1583;</title>
          <p id='_'>Text</p>
        </foreword>
        <introduction id='_' obligation='informative'>
          <title>&#1605;&#1602;&#1583;&#1605;&#1577;</title>
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
          <title>&#1605;&#1580;&#1575;&#1604; &#1575;&#1604;&#1578;&#1591;&#1576;&#1610;&#1602;</title>
          <p id='_'>Text</p>
        </clause>
        <terms id='_' obligation='normative'>
          <title>
            &#1605;&#1589;&#1591;&#1604;&#1581;&#1575;&#1578;
            &#1605;&#1593;&#1585;&#1601;&#1577;
          </title>
          <p id='_'>
            &#1578;&#1593;&#1617;&#1585;&#1601; &#1607;&#1584;&#1607;
            &#1575;&#1604;&#1578;&#1608;&#1589;&#1610;&#1577;
            &#1575;&#1604;&#1605;&#1589;&#1591;&#1604;&#1581;&#1575;&#1578;
            &#1575;&#1604;&#1578;&#1575;&#1604;&#1610;&#1577;:
          </p>
          <term id='term-term1'>
            <preferred><expression><name>Term1</name></expression></preferred>
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
            <p id='_'>&#1604;&#1575; &#1578;&#1608;&#1580;&#1583;.</p>
            <clause id='_' inline-header='false' obligation='normative'>
              <title>Intro 3</title>
            </clause>
          </terms>
          <clause id='_' obligation='normative'>
            <title>Intro 4</title>
            <terms id='_' obligation='normative'>
              <title>Intro 5</title>
              <term id='term-term1-1'>
                <preferred><expression><name>Term1</name></expression></preferred>
              </term>
            </terms>
          </clause>
          <clause id='_' obligation='normative'>
            <title>Normal Terms</title>
            <term id='term-term2'>
              <preferred><expression><name>Term2</name></expression></preferred>
            </term>
            <terms id='_' type='external' obligation='normative'>
              <title>
                &#1575;&#1604;&#1605;&#1589;&#1591;&#1604;&#1581;&#1575;&#1578;
                &#1575;&#1604;&#1605;&#1593;&#1614;&#1617;&#1585;&#1601;&#1577;
                &#1601;&#1610; &#1608;&#1579;&#1575;&#1574;&#1602;
                &#1571;&#1582;&#1585;&#1609;
              </title>
              <p id='_'>&#1604;&#1575; &#1578;&#1608;&#1580;&#1583;.</p>
            </terms>
          </clause>
          <terms id='_' obligation='normative'>
            <title>Symbols and Abbreviated Terms</title>
            <clause id='_' inline-header='false' obligation='normative'>
              <title>General</title>
            </clause>
            <term id='term-symbols-1'>
              <preferred><expression><name>Symbols 1</name></expression></preferred>
            </term>
          </terms>
        </clause>
        <definitions id='_' type='abbreviated_terms' obligation='normative'>
          <title>&#1575;&#1582;&#1578;&#1589;&#1575;&#1585;</title>
          <p id='_'>&#1604;&#1575; &#1578;&#1608;&#1580;&#1583;.</p>
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
          <title>
            &#1575;&#1604;&#1605;&#1585;&#1575;&#1580;&#1593;
            &#1575;&#1604;&#1605;&#1593;&#1610;&#1575;&#1585;&#1610;&#1577;
          </title>
          <p id='_'>&#1604;&#1575; &#1578;&#1608;&#1580;&#1583;.</p>
        </references>
        <clause id='_' obligation='informative'>
          <title>
            &#1576;&#1610;&#1576;&#1604;&#1610;&#1608;&#1594;&#1585;&#1575;&#1601;&#1610;&#1575;
          </title>
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
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes explicit metadata, service publication in Spanish" do
    input = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
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
      :language: es
      :title-en: Main Title
      :title-es: Titre Principal
      :subtitle-en: Subtitle
      :subtitle-es: Soustitre
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
           <itu-standard xmlns='https://www.metanorma.org/ns/itu' type='semantic' version='#{Metanorma::ITU::VERSION}'>
            <bibdata type='standard'>
        <title language='en' format='text/plain' type='main'>Main Title</title>
        <title language='es' format='text/plain' type='main'>Titre Principal</title>
        <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
        <title language='es' format='text/plain' type='subtitle'>Soustitre</title>
        <docidentifier type='ITU-provisional'>ABC</docidentifier>
        <docidentifier type='ITU'>Anexo al BE de la UIT 1000</docidentifier>
        <docidentifier type='ITU-lang'>Anexo al BE de la UIT 1000-S</docidentifier>
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
        <language>es</language>
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
    expect(xmlpp(input.sub(%r{<boilerplate>.*</boilerplate>}m,
                           ""))).to be_equivalent_to xmlpp(output)
  end

  it "processes sections in Spanish" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR.sub(/:novalid:/, ":novalid:\n:language: es\n:script: Latn")}
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
    output = <<~OUTPUT
             #{@blank_hdr.sub(/<status>/, '<abstract> <p>Text</p> </abstract><status>')
               .sub('<title language="en"', '<title language="es"')
               .sub('<language>en</language>', '<language>es</language>')}
               <preface>
        <abstract id='_'>
          <title>Resumen</title>
          <p id='_'>Text</p>
        </abstract>
        <foreword id='_' obligation='informative'>
          <title>Pr&#243;logo</title>
          <p id='_'>Text</p>
        </foreword>
        <introduction id='_' obligation='informative'>
          <title>Introducci&#243;n</title>
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
          <title>Alcance</title>
          <p id='_'>Text</p>
        </clause>
        <terms id='_' obligation='normative'>
          <title>Definiciones</title>
          <p id='_'>Esta Recomendaci&#243;n define los siguientes t&#233;rminos:</p>
          <term id='term-term1'>
            <preferred><expression><name>Term1</name></expression></preferred>
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
            <p id='_'>Ninguna.</p>
            <clause id='_' inline-header='false' obligation='normative'>
              <title>Intro 3</title>
            </clause>
          </terms>
          <clause id='_' obligation='normative'>
            <title>Intro 4</title>
            <terms id='_' obligation='normative'>
              <title>Intro 5</title>
              <term id='term-term1-1'>
                <preferred><expression><name>Term1</name></expression></preferred>
              </term>
            </terms>
          </clause>
          <clause id='_' obligation='normative'>
            <title>Normal Terms</title>
            <term id='term-term2'>
              <preferred><expression><name>Term2</name></expression></preferred>
            </term>
            <terms id='_' type='external' obligation='normative'>
              <title>T&#233;rminos definidos en otro lugar</title>
              <p id='_'>Ninguna.</p>
            </terms>
          </clause>
          <terms id='_' obligation='normative'>
            <title>Symbols and Abbreviated Terms</title>
            <clause id='_' inline-header='false' obligation='normative'>
              <title>General</title>
            </clause>
            <term id='term-symbols-1'>
              <preferred><expression><name>Symbols 1</name></expression></preferred>
            </term>
          </terms>
        </clause>
        <definitions id='_' type='abbreviated_terms' obligation='normative'>
          <title>Abreviaciones y acr&#243;nimos</title>
          <p id='_'>Ninguna.</p>
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
          <title>Referencias</title>
          <p id='_'>Ninguna.</p>
        </references>
        <clause id='_' obligation='informative'>
          <title>Bibliograf&#237;a</title>
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
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes explicit metadata, service publication in German" do
    input = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
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
      :language: de
      :title-en: Main Title
      :title-de: Titre Principal
      :subtitle-en: Subtitle
      :subtitle-de: Soustitre
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
          <itu-standard xmlns='https://www.metanorma.org/ns/itu' type='semantic' version='#{Metanorma::ITU::VERSION}'>
      <bibdata type='standard'>
        <title language='en' format='text/plain' type='main'>Main Title</title>
        <title language='de' format='text/plain' type='main'>Titre Principal</title>
        <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
        <title language='de' format='text/plain' type='subtitle'>Soustitre</title>
        <docidentifier type='ITU-provisional'>ABC</docidentifier>
        <docidentifier type='ITU'>Anhang zum  ITU OB 1000</docidentifier>
        <docidentifier type='ITU-lang'>Anhang zum  ITU OB 1000-</docidentifier>
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
        <language>de</language>
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
    expect(xmlpp(input.sub(%r{<boilerplate>.*</boilerplate>}m, "")))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes sections in German" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR
      .sub(/:novalid:/, ":novalid:\n:language: de\n:script: Latn")}
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
    output = <<~OUTPUT
             #{@blank_hdr.sub(/<status>/, '<abstract> <p>Text</p> </abstract><status>')
               .sub('<title language="en"', '<title language="de"')
               .sub('<language>en</language>', '<language>de</language>')}
               <preface>
        <abstract id='_'>
          <title>Abstrakt</title>
          <p id='_'>Text</p>
        </abstract>
        <foreword id='_' obligation='informative'>
          <title>Vorwort</title>
          <p id='_'>Text</p>
        </foreword>
        <introduction id='_' obligation='informative'>
          <title>Einf&#252;hrung</title>
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
          <title>Umfang</title>
          <p id='_'>Text</p>
        </clause>
        <terms id='_' obligation='normative'>
          <title>Definitionen</title>
          <p id='_'>Diese Empfehlung definiert die folgenden Begriffe:</p>
          <term id='term-term1'>
            <preferred><expression><name>Term1</name></expression></preferred>
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
            <p id='_'>Keine.</p>
            <clause id='_' inline-header='false' obligation='normative'>
              <title>Intro 3</title>
            </clause>
          </terms>
          <clause id='_' obligation='normative'>
            <title>Intro 4</title>
            <terms id='_' obligation='normative'>
              <title>Intro 5</title>
              <term id='term-term1-1'>
                <preferred><expression><name>Term1</name></expression></preferred>
              </term>
            </terms>
          </clause>
          <clause id='_' obligation='normative'>
            <title>Normal Terms</title>
            <term id='term-term2'>
              <preferred><expression><name>Term2</name></expression></preferred>
            </term>
            <terms id='_' type='external' obligation='normative'>
              <title>An anderer Stelle definierte Begriffe</title>
              <p id='_'>Keine.</p>
            </terms>
          </clause>
          <terms id='_' obligation='normative'>
            <title>Symbols and Abbreviated Terms</title>
            <clause id='_' inline-header='false' obligation='normative'>
              <title>General</title>
            </clause>
            <term id='term-symbols-1'>
              <preferred><expression><name>Symbols 1</name></expression></preferred>
            </term>
          </terms>
        </clause>
        <definitions id='_' type='abbreviated_terms' obligation='normative'>
          <title>Abk&#252;rzungen und Akronyme</title>
          <p id='_'>Keine.</p>
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
          <title>Referenzen</title>
          <p id='_'>Keine.</p>
        </references>
        <clause id='_' obligation='informative'>
          <title>Bibliographie</title>
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
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes explicit metadata, service publication in Russian" do
    input = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
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
      :language: ru
      :title-en: Main Title
      :title-ru: Titre Principal
      :subtitle-en: Subtitle
      :subtitle-ru: Soustitre
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
      <itu-standard xmlns='https://www.metanorma.org/ns/itu' type='semantic' version='#{Metanorma::ITU::VERSION}'>
      <bibdata type='standard'>
           <title language='en' format='text/plain' type='main'>Main Title</title>
           <title language='ru' format='text/plain' type='main'>Titre Principal</title>
           <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
           <title language='ru' format='text/plain' type='subtitle'>Soustitre</title>
           <docidentifier type='ITU-provisional'>ABC</docidentifier>
           <docidentifier type='ITU'>
             &#1055;&#1088;&#1080;&#1083;&#1086;&#1078;&#1077;&#1085;&#1080;&#1077;
             &#1082; &#1054;&#1041; &#1052;&#1057;&#1069; 1000
           </docidentifier>
           <docidentifier type='ITU-lang'>
             &#1055;&#1088;&#1080;&#1083;&#1086;&#1078;&#1077;&#1085;&#1080;&#1077;
             &#1082; &#1054;&#1041; &#1052;&#1057;&#1069; 1000-R
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
           <language>ru</language>
           <script>Cyrl</script>
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
    expect(xmlpp(input.sub(%r{<boilerplate>.*</boilerplate>}m, "")))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes sections in Russian" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR.sub(/:novalid:/, ":novalid:\n:language: ru\n:script: Cyrl")}
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
    output = <<~OUTPUT
      #{@blank_hdr.sub(/<status>/, '<abstract> <p>Text</p> </abstract><status>')
        .sub('<language>en</language>', '<language>ru</language>')
        .sub('<script>Latn</script>', '<script>Cyrl</script>')
        .sub('<title language="en"', '<title language="ru"')}
        <preface>
          <abstract id='_'>
            <title>&#1056;&#1077;&#1092;&#1077;&#1088;&#1072;&#1090;</title>
            <p id='_'>Text</p>
          </abstract>
          <foreword id='_' obligation='informative'>
            <title>&#1055;&#1088;&#1077;&#1076;&#1080;&#1089;&#1083;&#1086;&#1074;&#1080;&#1077;</title>
            <p id='_'>Text</p>
          </foreword>
          <introduction id='_' obligation='informative'>
            <title>&#1042;&#1074;&#1077;&#1076;&#1077;&#1085;&#1080;&#1077;</title>
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
            <title>
              &#1057;&#1092;&#1077;&#1088;&#1072;
              &#1087;&#1088;&#1080;&#1084;&#1077;&#1085;&#1077;&#1085;&#1080;&#1103;
            </title>
            <p id='_'>Text</p>
          </clause>
          <terms id='_' obligation='normative'>
            <title>&#1054;&#1087;&#1088;&#1077;&#1076;&#1077;&#1083;&#1077;&#1085;&#1080;&#1103;</title>
            <p id='_'>
              &#1042; &#1085;&#1072;&#1089;&#1090;&#1086;&#1103;&#1097;&#1077;&#1081;
              &#1056;&#1077;&#1082;&#1086;&#1084;&#1077;&#1085;&#1076;&#1072;&#1094;&#1080;&#1080; &#1086;&#1087;&#1088;&#1077;&#1076;&#1077;&#1083;&#1077;&#1085;&#1099; &#1089;&#1083;&#1077;&#1076;&#1091;&#1102;&#1097;&#1080;&#1077; &#1090;&#1077;&#1088;&#1084;&#1080;&#1085;&#1099;:
            </p>
            <term id='term-term1'>
              <preferred><expression><name>Term1</name></expression></preferred>
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
              <p id='_'>&#1054;&#1090;&#1089;&#1091;&#1090;&#1089;&#1090;&#1074;&#1091;&#1102;&#1090;.</p>
              <clause id='_' inline-header='false' obligation='normative'>
                <title>Intro 3</title>
              </clause>
            </terms>
            <clause id='_' obligation='normative'>
              <title>Intro 4</title>
              <terms id='_' obligation='normative'>
                <title>Intro 5</title>
                <term id='term-term1-1'>
                  <preferred><expression><name>Term1</name></expression></preferred>
                </term>
              </terms>
            </clause>
            <clause id='_' obligation='normative'>
              <title>Normal Terms</title>
              <term id='term-term2'>
                <preferred><expression><name>Term2</name></expression></preferred>
              </term>
              <terms id='_' type='external' obligation='normative'>
                <title>
                  &#1058;&#1077;&#1088;&#1084;&#1080;&#1085;&#1099;,
                  &#1086;&#1087;&#1088;&#1077;&#1076;&#1077;&#1083;&#1077;&#1085;&#1085;&#1099;&#1077; &#1074; &#1076;&#1088;&#1091;&#1075;&#1080;&#1093; &#1076;&#1086;&#1082;&#1091;&#1084;&#1077;&#1085;&#1090;&#1072;&#1093;
                </title>
                <p id='_'>&#1054;&#1090;&#1089;&#1091;&#1090;&#1089;&#1090;&#1074;&#1091;&#1102;&#1090;.</p>
              </terms>
            </clause>
            <terms id='_' obligation='normative'>
              <title>Symbols and Abbreviated Terms</title>
              <clause id='_' inline-header='false' obligation='normative'>
                <title>General</title>
              </clause>
              <term id='term-symbols-1'>
                <preferred><expression><name>Symbols 1</name></expression></preferred>
              </term>
            </terms>
          </clause>
          <definitions id='_' type='abbreviated_terms' obligation='normative'>
            <title>
              &#1057;&#1086;&#1082;&#1088;&#1072;&#1097;&#1077;&#1085;&#1080;&#1103;
              &#1080; &#1072;&#1082;&#1088;&#1086;&#1085;&#1080;&#1084;&#1099;
            </title>
            <p id='_'>&#1054;&#1090;&#1089;&#1091;&#1090;&#1089;&#1090;&#1074;&#1091;&#1102;&#1090;.</p>
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
            <title>&#1057;&#1089;&#1099;&#1083;&#1082;&#1080;</title>
            <p id='_'>&#1054;&#1090;&#1089;&#1091;&#1090;&#1089;&#1090;&#1074;&#1091;&#1102;&#1090;.</p>
          </references>
          <clause id='_' obligation='informative'>
            <title>
              &#1041;&#1080;&#1073;&#1083;&#1080;&#1086;&#1075;&#1088;&#1072;&#1092;&#1080;&#1103;
            </title>
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
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end
end

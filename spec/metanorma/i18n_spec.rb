require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Itu do
  before(:all) do
    @blank_hdr = blank_hdr_gen
  end

  it "processes explicit metadata, service publication in French" do
    input = Asciidoctor.convert(<<~INPUT, *OPTIONS)
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
      <metanorma xmlns='https://www.metanorma.org/ns/standoc' type='semantic' version='#{Metanorma::Itu::VERSION}' flavor="itu">
        <bibdata type='standard'>
          <title language='en' format='text/plain' type='main'>Main Title</title>
          <title language='fr' format='text/plain' type='main'>Titre Principal</title>
          <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
          <title language='fr' format='text/plain' type='subtitle'>Soustitre</title>
          <docidentifier type='ITU-provisional'>ABC</docidentifier>
          <docidentifier primary="true" type='ITU'>Annexe au BE de l'UIT 1000</docidentifier>
          <docidentifier type='ITU-lang'>Annexe au BE de l'UIT 1000-F</docidentifier>
          <docnumber>1000</docnumber>
          <contributor>
            <role type='author'/>
            <organization>
                           <name>Union internationale des télécommunications</name>
                <abbreviation>UIT</abbreviation>
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
                           <name>Union internationale des télécommunications</name>
                <abbreviation>UIT</abbreviation>
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
               <name>Union internationale des télécommunications</name>
                <abbreviation>UIT</abbreviation>
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
    xml = Nokogiri::XML(input)
    xml.xpath("//xmlns:boilerplate | //xmlns:metanorma-extension")
      .each(&:remove)
    expect(Canon.format_xml(strip_guid(xml.to_xml)))
      .to be_equivalent_to Canon.format_xml(strip_guid(output))
  end

  it "processes summaries in other languages" do
    { "ar" => "ملخص", "de" => "Zusammenfassung", "en" => "Summary",
      "es" => "Resumen", "fr" => "Résumé", "ru" => "Резюме",
      "zh" => "概括" }.each do |k, v|
        input = <<~INPUT
          #{ASCIIDOC_BLANK_HDR.sub(':novalid:', ":novalid:\n:language: #{k}#{k == 'zh' ? "\n:script: Hans" : ''}")}
          .Foreword

          Text

          [abstract]
          == Summary
        INPUT
        output = <<~OUTPUT
          <abstract id='_'>
            <title id="_">#{v}</title>
          </abstract>
        OUTPUT
        xml = Nokogiri::XML(Asciidoctor.convert(input, *OPTIONS))
        xml = xml.at("//xmlns:preface/xmlns:abstract")
        expect(Canon.format_xml(strip_guid(xml.to_xml)))
          .to be_equivalent_to Canon.format_xml(strip_guid(output))
      end
  end

  it "processes sections in French" do
    input = section_template("fr", "Latn")
    output = <<~OUTPUT
            #{@blank_hdr.sub('<status>', '<abstract> <p>Text</p> </abstract><status>')
              .sub('<title language="en"', '<title language="fr"')
              .sub('<language>en</language>', '<language>fr</language>')
              .gsub('<name>International Telecommunication Union</name>', '<name>Union internationale des télécommunications</name>')
              .gsub('<abbreviation>ITU</abbreviation>', '<abbreviation>UIT</abbreviation>')
            }
            <preface>
              <abstract id="_">
                 <title id="_">Résumé</title>
                 <p id="_">Text</p>
              </abstract>
              <foreword id="_" obligation="informative">
                 <title id="_">Avant-propos</title>
                 <p id="_">Text</p>
              </foreword>
              <introduction id="_" obligation="informative">
                 <title id="_">Introduction</title>
                 <clause id="_" inline-header="false" obligation="informative">
                    <title id="_">Introduction Subsection</title>
                 </clause>
              </introduction>
              <clause id="_" type="history" inline-header="false" obligation="informative">
                 <title id="_">History</title>
              </clause>
              <clause id="_" type="source" inline-header="false" obligation="informative">
                 <title id="_">Source</title>
              </clause>
           </preface>
           <sections>
              <clause id="_" unnumbered="true" inline-header="false" obligation="normative">
                 <p id="_">Initial text</p>
              </clause>
              <clause id="_" type="scope" inline-header="false" obligation="normative">
                 <title id="_">Domaine d'application</title>
                 <p id="_">Text</p>
              </clause>
              <terms id="_" obligation="normative">
                 <title id="_">Définitions</title>
                 <p id="_">La présente Recommandation définit les termes suivants:</p>
                 <term id="_" anchor="term-Term1">
                    <preferred>
                       <expression>
                          <name>Term1</name>
                       </expression>
                    </preferred>
                 </term>
              </terms>
              <clause id="_" obligation="normative" type="terms">
                 <title id="_">Terms, Definitions, Symbols and Abbreviated Terms</title>
                 <clause id="_" inline-header="false" obligation="normative">
                    <title id="_">Introduction</title>
                    <clause id="_" inline-header="false" obligation="normative">
                       <title id="_">Intro 1</title>
                    </clause>
                 </clause>
                 <terms id="_" obligation="normative">
                    <title id="_">Intro 2</title>
                    <p id="_">Aucun.</p>
                    <clause id="_" inline-header="false" obligation="normative">
                       <title id="_">Intro 3</title>
                    </clause>
                 </terms>
                 <clause id="_" obligation="normative" type="terms">
                    <title id="_">Intro 4</title>
                    <terms id="_" obligation="normative">
                       <title id="_">Intro 5</title>
                       <term id="_" anchor="term-Term1-1">
                          <preferred>
                             <expression>
                                <name>Term1</name>
                             </expression>
                          </preferred>
                       </term>
                    </terms>
                 </clause>
                 <terms id="_" obligation="normative">
                    <title id="_">Normal Terms</title>
                    <term id="_" anchor="term-Term2">
                       <preferred>
                          <expression>
                             <name>Term2</name>
                          </expression>
                       </preferred>
                    </term>
                    <terms id="_" type="external" obligation="normative">
                       <title id="_">Termes définis ailleurs</title>
                       <p id="_">Aucun.</p>
                    </terms>
                 </terms>
                 <terms id="_" obligation="normative">
                    <title id="_">Symbols and Abbreviated Terms</title>
                    <clause id="_" inline-header="false" obligation="normative">
                       <title id="_">General</title>
                    </clause>
                    <term id="_" anchor="term-Symbols-1">
                       <preferred>
                          <expression>
                             <name>Symbols 1</name>
                          </expression>
                       </preferred>
                    </term>
                 </terms>
              </clause>
              <definitions id="_" type="abbreviated_terms" obligation="normative">
                 <title id="_">Abréviations et acronymes</title>
                 <p id="_">Aucun.</p>
              </definitions>
              <clause id="_" type="conventions" inline-header="false" obligation="normative">
                 <title id="_">Conventions</title>
              </clause>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">Clause 4</title>
                 <clause id="_" inline-header="false" obligation="normative">
                    <title id="_">Introduction</title>
                 </clause>
                 <clause id="_" inline-header="false" obligation="normative">
                    <title id="_">Clause 4.2</title>
                 </clause>
              </clause>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">Terms and Definitions</title>
              </clause>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">History</title>
              </clause>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">Source</title>
              </clause>
           </sections>
           <annex id="_" inline-header="false" obligation="normative">
              <title id="_">Annex</title>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">Annex A.1</title>
              </clause>
           </annex>
           <bibliography>
              <references id="_" normative="true" obligation="informative">
                 <title id="_">Références</title>
                 <p id="_">Aucun.</p>
              </references>
              <clause id="_" obligation="informative">
                 <title id="_">Bibliographie</title>
                 <references id="_" normative="false" obligation="informative">
                    <title id="_">Bibliography Subsection</title>
                 </references>
              </clause>
              <references id="_" normative="false" obligation="informative">
                 <title id="_">Second Bibliography</title>
              </references>
           </bibliography>
        </metanorma>
    OUTPUT
  expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(strip_guid(output))
  end

  it "processes explicit metadata, service publication in Chinese" do
    input = Asciidoctor.convert(<<~INPUT, *OPTIONS)
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
    output = <<~OUTPUT
      <metanorma xmlns='https://www.metanorma.org/ns/standoc' type='semantic' version='#{Metanorma::Itu::VERSION}' flavor="itu">
      <bibdata type='standard'>
          <title language='zh' format='text/plain' type='main'>Document title</title>
          <title language='en' format='text/plain' type='main'>Main Title</title>
          <title language='fr' format='text/plain' type='main'>Titre Principal</title>
          <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
          <title language='fr' format='text/plain' type='subtitle'>Soustitre</title>
          <docidentifier type='ITU-provisional'>ABC</docidentifier>
          <docidentifier primary="true" type='ITU'>
            &#22269;&#38469;&#30005;&#32852;&#25805;&#20316;&#20844;&#25253;&#38468;&#20214; &#31532; 1000 &#26399;
          </docidentifier>
          <docidentifier type='ITU-lang'>
            &#22269;&#38469;&#30005;&#32852;&#25805;&#20316;&#20844;&#25253;&#38468;&#20214; &#31532; 1000 &#26399;-C
          </docidentifier>
          <docnumber>1000</docnumber>
          <contributor>
            <role type='author'/>
            <organization>
            <name>国际电信联盟</name>
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
            <name>国际电信联盟</name>
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
                <name>国际电信联盟</name>
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
    xml = Nokogiri::XML(input)
    xml.xpath("//xmlns:boilerplate | //xmlns:metanorma-extension")
      .each(&:remove)
    expect(Canon.format_xml(strip_guid(xml.to_xml)))
      .to be_equivalent_to Canon.format_xml(strip_guid(output))
  end

  it "processes sections in Chinese" do
    input = section_template("zh", "Hans")
    output = <<~OUTPUT
      #{@blank_hdr.sub('<status>', '<abstract> <p>Text</p> </abstract><status>')
        .sub('<language>en</language>', '<language>zh</language>')
        .sub('<title language="en"', '<title language="zh"')
        .sub('<script>Latn</script>', '<script>Hans</script>')
        .gsub('<name>International Telecommunication Union</name>', '<name>国际电信联盟</name>')
        .gsub('<abbreviation>ITU</abbreviation>', '')
      }
            <preface>
              <abstract id="_">
                 <title id="_">摘要</title>
                 <p id="_">Text</p>
              </abstract>
              <foreword id="_" obligation="informative">
                 <title id="_">前言</title>
                 <p id="_">Text</p>
              </foreword>
              <introduction id="_" obligation="informative">
                 <title id="_">引言</title>
                 <clause id="_" inline-header="false" obligation="informative">
                    <title id="_">Introduction Subsection</title>
                 </clause>
              </introduction>
              <clause id="_" type="history" inline-header="false" obligation="informative">
                 <title id="_">History</title>
              </clause>
              <clause id="_" type="source" inline-header="false" obligation="informative">
                 <title id="_">Source</title>
              </clause>
           </preface>
           <sections>
              <clause id="_" unnumbered="true" inline-header="false" obligation="normative">
                 <p id="_">Initial text</p>
              </clause>
              <clause id="_" type="scope" inline-header="false" obligation="normative">
                 <title id="_">范围</title>
                 <p id="_">Text</p>
              </clause>
              <terms id="_" obligation="normative">
                 <title id="_">定义</title>
                 <p id="_">本建议书定义下列术语：</p>
                 <term id="_" anchor="term-Term1">
                    <preferred>
                       <expression>
                          <name>Term1</name>
                       </expression>
                    </preferred>
                 </term>
              </terms>
              <clause id="_" obligation="normative" type="terms">
                 <title id="_">Terms, Definitions, Symbols and Abbreviated Terms</title>
                 <clause id="_" inline-header="false" obligation="normative">
                    <title id="_">Introduction</title>
                    <clause id="_" inline-header="false" obligation="normative">
                       <title id="_">Intro 1</title>
                    </clause>
                 </clause>
                 <terms id="_" obligation="normative">
                    <title id="_">Intro 2</title>
                    <p id="_">无</p>
                    <clause id="_" inline-header="false" obligation="normative">
                       <title id="_">Intro 3</title>
                    </clause>
                 </terms>
                 <clause id="_" obligation="normative" type="terms">
                    <title id="_">Intro 4</title>
                    <terms id="_" obligation="normative">
                       <title id="_">Intro 5</title>
                       <term id="_" anchor="term-Term1-1">
                          <preferred>
                             <expression>
                                <name>Term1</name>
                             </expression>
                          </preferred>
                       </term>
                    </terms>
                 </clause>
                 <terms id="_" obligation="normative">
                    <title id="_">Normal Terms</title>
                    <term id="_" anchor="term-Term2">
                       <preferred>
                          <expression>
                             <name>Term2</name>
                          </expression>
                       </preferred>
                    </term>
                    <terms id="_" type="external" obligation="normative">
                       <title id="_">其他地方定义的术语</title>
                       <p id="_">无</p>
                    </terms>
                 </terms>
                 <terms id="_" obligation="normative">
                    <title id="_">Symbols and Abbreviated Terms</title>
                    <clause id="_" inline-header="false" obligation="normative">
                       <title id="_">General</title>
                    </clause>
                    <term id="_" anchor="term-Symbols-1">
                       <preferred>
                          <expression>
                             <name>Symbols 1</name>
                          </expression>
                       </preferred>
                    </term>
                 </terms>
              </clause>
              <definitions id="_" type="abbreviated_terms" obligation="normative">
                 <title id="_">缩略语与缩写</title>
                 <p id="_">无</p>
              </definitions>
              <clause id="_" type="conventions" inline-header="false" obligation="normative">
                 <title id="_">Conventions</title>
              </clause>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">Clause 4</title>
                 <clause id="_" inline-header="false" obligation="normative">
                    <title id="_">Introduction</title>
                 </clause>
                 <clause id="_" inline-header="false" obligation="normative">
                    <title id="_">Clause 4.2</title>
                 </clause>
              </clause>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">Terms and Definitions</title>
              </clause>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">History</title>
              </clause>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">Source</title>
              </clause>
           </sections>
           <annex id="_" inline-header="false" obligation="normative">
              <title id="_">Annex</title>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">Annex A.1</title>
              </clause>
           </annex>
           <bibliography>
              <references id="_" normative="true" obligation="informative">
                 <title id="_">规范性参考文献</title>
                 <p id="_">无</p>
              </references>
              <clause id="_" obligation="informative">
                 <title id="_">参考文献</title>
                 <references id="_" normative="false" obligation="informative">
                    <title id="_">Bibliography Subsection</title>
                 </references>
              </clause>
              <references id="_" normative="false" obligation="informative">
                 <title id="_">Second Bibliography</title>
              </references>
           </bibliography>
        </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(strip_guid(output))
  end

  it "processes explicit metadata, service publication in Arabic" do
    input = Asciidoctor.convert(<<~INPUT, *OPTIONS)
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
           <metanorma xmlns='https://www.metanorma.org/ns/standoc' type='semantic' version='#{Metanorma::Itu::VERSION}' flavor="itu">
      <bibdata type='standard'>
        <title language='en' format='text/plain' type='main'>Main Title</title>
        <title language='ar' format='text/plain' type='main'>Titre Principal</title>
        <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
        <title language='ar' format='text/plain' type='subtitle'>Soustitre</title>
        <docidentifier type='ITU-provisional'>ABC</docidentifier>
        <docidentifier primary="true" type='ITU'>
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
          <name>الاتحاد الدولي للاتصالات</na
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
          <name>الاتحاد الدولي للاتصالات</na
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
              <name>الاتحاد الدولي للاتصالات</na
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
    xml = Nokogiri::XML(input)
    xml.xpath("//xmlns:boilerplate | //xmlns:metanorma-extension")
      .each(&:remove)
    expect(Canon.format_xml(strip_guid(xml.to_xml)))
      .to be_equivalent_to Canon.format_xml(strip_guid(output))
  end

  it "processes sections in Arabic" do
    input = section_template("ar", "Arab")
    output = <<~OUTPUT
            #{@blank_hdr.sub('<status>', '<abstract> <p>Text</p> </abstract><status>')
              .sub('<language>en</language>', '<language>ar</language>')
              .sub('<title language="en"', '<title language="ar"')
              .sub('<script>Latn</script>', '<script>Arab</script>')
              .gsub('<name>International Telecommunication Union</name>', '<name>الاتحاد الدولي للاتصالات</name>')
              .gsub('<abbreviation>ITU</abbreviation>', '')
            }
           <preface>
              <abstract id="_" >
                 <title id="_">ملخص</title>
                 <p id="_">Text</p>
              </abstract>
              <foreword id="_" obligation="informative">
                 <title id="_">تمهيد</title>
                 <p id="_">Text</p>
              </foreword>
              <introduction id="_" obligation="informative">
                 <title id="_">مقدمة</title>
                 <clause id="_" inline-header="false" obligation="informative">
                    <title id="_">Introduction Subsection</title>
                 </clause>
              </introduction>
              <clause id="_" type="history" inline-header="false" obligation="informative">
                 <title id="_">History</title>
              </clause>
              <clause id="_" type="source" inline-header="false" obligation="informative">
                 <title id="_">Source</title>
              </clause>
           </preface>
           <sections>
              <clause id="_" unnumbered="true" inline-header="false" obligation="normative">
                 <p id="_">Initial text</p>
              </clause>
              <clause id="_" type="scope" inline-header="false" obligation="normative">
                 <title id="_">مجال التطبيق</title>
                 <p id="_">Text</p>
              </clause>
              <terms id="_" obligation="normative">
                 <title id="_">مصطلحات معرفة</title>
                 <p id="_">تعّرف هذه التوصية المصطلحات التالية:</p>
                 <term id="_" anchor="term-Term1">
                    <preferred>
                       <expression>
                          <name>Term1</name>
                       </expression>
                    </preferred>
                 </term>
              </terms>
              <clause id="_" obligation="normative" type="terms">
                 <title id="_">Terms, Definitions, Symbols and Abbreviated Terms</title>
                 <clause id="_" inline-header="false" obligation="normative">
                    <title id="_">Introduction</title>
                    <clause id="_" inline-header="false" obligation="normative">
                       <title id="_">Intro 1</title>
                    </clause>
                 </clause>
                 <terms id="_" obligation="normative">
                    <title id="_">Intro 2</title>
                    <p id="_">لا توجد.</p>
                    <clause id="_" inline-header="false" obligation="normative">
                       <title id="_">Intro 3</title>
                    </clause>
                 </terms>
                 <clause id="_" obligation="normative" type="terms">
                    <title id="_">Intro 4</title>
                    <terms id="_" obligation="normative">
                       <title id="_">Intro 5</title>
                       <term id="_" anchor="term-Term1-1">
                          <preferred>
                             <expression>
                                <name>Term1</name>
                             </expression>
                          </preferred>
                       </term>
                    </terms>
                 </clause>
                 <terms id="_" obligation="normative">
                    <title id="_">Normal Terms</title>
                    <term id="_" anchor="term-Term2">
                       <preferred>
                          <expression>
                             <name>Term2</name>
                          </expression>
                       </preferred>
                    </term>
                    <terms id="_" type="external" obligation="normative">
                       <title id="_">المصطلحات المعَّرفة في وثائق أخرى</title>
                       <p id="_">لا توجد.</p>
                    </terms>
                 </terms>
                 <terms id="_" obligation="normative">
                    <title id="_">Symbols and Abbreviated Terms</title>
                    <clause id="_" inline-header="false" obligation="normative">
                       <title id="_">General</title>
                    </clause>
                    <term id="_" anchor="term-Symbols-1">
                       <preferred>
                          <expression>
                             <name>Symbols 1</name>
                          </expression>
                       </preferred>
                    </term>
                 </terms>
              </clause>
              <definitions id="_" type="abbreviated_terms" obligation="normative">
                 <title id="_">اختصار</title>
                 <p id="_">لا توجد.</p>
              </definitions>
              <clause id="_" type="conventions" inline-header="false" obligation="normative">
                 <title id="_">Conventions</title>
              </clause>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">Clause 4</title>
                 <clause id="_" inline-header="false" obligation="normative">
                    <title id="_">Introduction</title>
                 </clause>
                 <clause id="_" inline-header="false" obligation="normative">
                    <title id="_">Clause 4.2</title>
                 </clause>
              </clause>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">Terms and Definitions</title>
              </clause>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">History</title>
              </clause>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">Source</title>
              </clause>
           </sections>
           <annex id="_" inline-header="false" obligation="normative">
              <title id="_">Annex</title>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">Annex A.1</title>
              </clause>
           </annex>
           <bibliography>
              <references id="_" normative="true" obligation="informative">
                 <title id="_">المراجع المعيارية</title>
                 <p id="_">لا توجد.</p>
              </references>
              <clause id="_" obligation="informative">
                 <title id="_">بيبليوغرافيا</title>
                 <references id="_" normative="false" obligation="informative">
                    <title id="_">Bibliography Subsection</title>
                 </references>
              </clause>
              <references id="_" normative="false" obligation="informative">
                 <title id="_">Second Bibliography</title>
              </references>
           </bibliography>
        </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(strip_guid(output))
  end

  it "processes explicit metadata, service publication in Spanish" do
    input = Asciidoctor.convert(<<~INPUT, *OPTIONS)
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
           <metanorma xmlns='https://www.metanorma.org/ns/standoc' type='semantic' version='#{Metanorma::Itu::VERSION}' flavor="itu">
            <bibdata type='standard'>
        <title language='en' format='text/plain' type='main'>Main Title</title>
        <title language='es' format='text/plain' type='main'>Titre Principal</title>
        <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
        <title language='es' format='text/plain' type='subtitle'>Soustitre</title>
        <docidentifier type='ITU-provisional'>ABC</docidentifier>
        <docidentifier primary="true" type='ITU'>Anexo al BE de la UIT 1000</docidentifier>
        <docidentifier type='ITU-lang'>Anexo al BE de la UIT 1000-S</docidentifier>
        <docnumber>1000</docnumber>
        <contributor>
          <role type='author'/>
          <organization>
                  <name>Unión Internacional de Telecomunicaciones</name>
        <abbreviation>UIT</abbreviation>
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
                  <name>Unión Internacional de Telecomunicaciones</name>
        <abbreviation>UIT</abbreviation>
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
                    <name>Unión Internacional de Telecomunicaciones</name>
        <abbreviation>UIT</abbreviation>
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
    xml = Nokogiri::XML(input)
    xml.xpath("//xmlns:boilerplate | //xmlns:metanorma-extension")
      .each(&:remove)
    expect(Canon.format_xml(strip_guid(xml.to_xml)))
      .to be_equivalent_to Canon.format_xml(strip_guid(output))
  end

  it "processes sections in Spanish" do
    input = section_template("es", "Latn")
    output = <<~OUTPUT
             #{@blank_hdr.sub('<status>', '<abstract> <p>Text</p> </abstract><status>')
               .sub('<title language="en"', '<title language="es"')
               .sub('<language>en</language>', '<language>es</language>')
               .gsub('<name>International Telecommunication Union</name>', '<name>Unión Internacional de Telecomunicaciones</name>')
               .gsub('<abbreviation>ITU</abbreviation>', '<abbreviation>UIT</abbreviation>')
             }
            <preface>
              <abstract id="_">
                 <title id="_">Resumen</title>
                 <p id="_">Text</p>
              </abstract>
              <foreword id="_" obligation="informative">
                 <title id="_">Prólogo</title>
                 <p id="_">Text</p>
              </foreword>
              <introduction id="_" obligation="informative">
                 <title id="_">Introducción</title>
                 <clause id="_" inline-header="false" obligation="informative">
                    <title id="_">Introduction Subsection</title>
                 </clause>
              </introduction>
              <clause id="_" type="history" inline-header="false" obligation="informative">
                 <title id="_">History</title>
              </clause>
              <clause id="_" type="source" inline-header="false" obligation="informative">
                 <title id="_">Source</title>
              </clause>
           </preface>
           <sections>
              <clause id="_" unnumbered="true" inline-header="false" obligation="normative">
                 <p id="_">Initial text</p>
              </clause>
              <clause id="_" type="scope" inline-header="false" obligation="normative">
                 <title id="_">Alcance</title>
                 <p id="_">Text</p>
              </clause>
              <terms id="_" obligation="normative">
                 <title id="_">Definiciones</title>
                 <p id="_">Esta Recomendación define los siguientes términos:</p>
                 <term id="_" anchor="term-Term1">
                    <preferred>
                       <expression>
                          <name>Term1</name>
                       </expression>
                    </preferred>
                 </term>
              </terms>
              <clause id="_" obligation="normative" type="terms">
                 <title id="_">Terms, Definitions, Symbols and Abbreviated Terms</title>
                 <clause id="_" inline-header="false" obligation="normative">
                    <title id="_">Introduction</title>
                    <clause id="_" inline-header="false" obligation="normative">
                       <title id="_">Intro 1</title>
                    </clause>
                 </clause>
                 <terms id="_" obligation="normative">
                    <title id="_">Intro 2</title>
                    <p id="_">Ninguna.</p>
                    <clause id="_" inline-header="false" obligation="normative">
                       <title id="_">Intro 3</title>
                    </clause>
                 </terms>
                 <clause id="_" obligation="normative" type="terms">
                    <title id="_">Intro 4</title>
                    <terms id="_" obligation="normative">
                       <title id="_">Intro 5</title>
                       <term id="_" anchor="term-Term1-1">
                          <preferred>
                             <expression>
                                <name>Term1</name>
                             </expression>
                          </preferred>
                       </term>
                    </terms>
                 </clause>
                 <terms id="_" obligation="normative">
                    <title id="_">Normal Terms</title>
                    <term id="_" anchor="term-Term2">
                       <preferred>
                          <expression>
                             <name>Term2</name>
                          </expression>
                       </preferred>
                    </term>
                    <terms id="_" type="external" obligation="normative">
                       <title id="_">Términos definidos en otro lugar</title>
                       <p id="_">Ninguna.</p>
                    </terms>
                 </terms>
                 <terms id="_" obligation="normative">
                    <title id="_">Symbols and Abbreviated Terms</title>
                    <clause id="_" inline-header="false" obligation="normative">
                       <title id="_">General</title>
                    </clause>
                    <term id="_" anchor="term-Symbols-1">
                       <preferred>
                          <expression>
                             <name>Symbols 1</name>
                          </expression>
                       </preferred>
                    </term>
                 </terms>
              </clause>
              <definitions id="_" type="abbreviated_terms" obligation="normative">
                 <title id="_">Abreviaciones y acrónimos</title>
                 <p id="_">Ninguna.</p>
              </definitions>
              <clause id="_" type="conventions" inline-header="false" obligation="normative">
                 <title id="_">Conventions</title>
              </clause>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">Clause 4</title>
                 <clause id="_" inline-header="false" obligation="normative">
                    <title id="_">Introduction</title>
                 </clause>
                 <clause id="_" inline-header="false" obligation="normative">
                    <title id="_">Clause 4.2</title>
                 </clause>
              </clause>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">Terms and Definitions</title>
              </clause>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">History</title>
              </clause>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">Source</title>
              </clause>
           </sections>
           <annex id="_" inline-header="false" obligation="normative">
              <title id="_">Annex</title>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">Annex A.1</title>
              </clause>
           </annex>
           <bibliography>
              <references id="_" normative="true" obligation="informative">
                 <title id="_">Referencias</title>
                 <p id="_">Ninguna.</p>
              </references>
              <clause id="_" obligation="informative">
                 <title id="_">Bibliografía</title>
                 <references id="_" normative="false" obligation="informative">
                    <title id="_">Bibliography Subsection</title>
                 </references>
              </clause>
              <references id="_" normative="false" obligation="informative">
                 <title id="_">Second Bibliography</title>
              </references>
           </bibliography>
        </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(strip_guid(output))
  end

  it "processes explicit metadata, service publication in German" do
    input = Asciidoctor.convert(<<~INPUT, *OPTIONS)
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
          <metanorma xmlns='https://www.metanorma.org/ns/standoc' type='semantic' version='#{Metanorma::Itu::VERSION}' flavor="itu">
      <bibdata type='standard'>
        <title language='en' format='text/plain' type='main'>Main Title</title>
        <title language='de' format='text/plain' type='main'>Titre Principal</title>
        <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
        <title language='de' format='text/plain' type='subtitle'>Soustitre</title>
        <docidentifier type='ITU-provisional'>ABC</docidentifier>
        <docidentifier primary="true" type='ITU'>Anhang zum  ITU OB 1000</docidentifier>
        <docidentifier type='ITU-lang'>Anhang zum  ITU OB 1000-</docidentifier>
        <docnumber>1000</docnumber>
        <contributor>
          <role type='author'/>
          <organization>
                  <name>Internationale Fernmeldeunion</name>
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
                  <name>Internationale Fernmeldeunion</name>
        <abbreviation>ITU</abbreviation>
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
                    <name>Internationale Fernmeldeunion</name>
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
    xml = Nokogiri::XML(input)
    xml.xpath("//xmlns:boilerplate | //xmlns:metanorma-extension")
      .each(&:remove)
    expect(Canon.format_xml(strip_guid(xml.to_xml)))
      .to be_equivalent_to Canon.format_xml(strip_guid(output))
  end

  it "processes sections in German" do
    input = section_template("de", "Latn")
    output = <<~OUTPUT
             #{@blank_hdr.sub('<status>', '<abstract> <p>Text</p> </abstract><status>')
               .sub('<title language="en"', '<title language="de"')
               .sub('<language>en</language>', '<language>de</language>')
               .gsub('<name>International Telecommunication Union</name>', '<name>Internationale Fernmeldeunion</name>')
             }
           <preface>
              <abstract id="_">
                 <title id="_">Abstrakt</title>
                 <p id="_">Text</p>
              </abstract>
              <foreword id="_" obligation="informative">
                 <title id="_">Vorwort</title>
                 <p id="_">Text</p>
              </foreword>
              <introduction id="_" obligation="informative">
                 <title id="_">Einführung</title>
                 <clause id="_" inline-header="false" obligation="informative">
                    <title id="_">Introduction Subsection</title>
                 </clause>
              </introduction>
              <clause id="_" type="history" inline-header="false" obligation="informative">
                 <title id="_">History</title>
              </clause>
              <clause id="_" type="source" inline-header="false" obligation="informative">
                 <title id="_">Source</title>
              </clause>
           </preface>
           <sections>
              <clause id="_" unnumbered="true" inline-header="false" obligation="normative">
                 <p id="_">Initial text</p>
              </clause>
              <clause id="_" type="scope" inline-header="false" obligation="normative">
                 <title id="_">Umfang</title>
                 <p id="_">Text</p>
              </clause>
              <terms id="_" obligation="normative">
                 <title id="_">Definitionen</title>
                 <p id="_">Diese Empfehlung definiert die folgenden Begriffe:</p>
                 <term id="_" anchor="term-Term1">
                    <preferred>
                       <expression>
                          <name>Term1</name>
                       </expression>
                    </preferred>
                 </term>
              </terms>
              <clause id="_" obligation="normative" type="terms">
                 <title id="_">Terms, Definitions, Symbols and Abbreviated Terms</title>
                 <clause id="_" inline-header="false" obligation="normative">
                    <title id="_">Introduction</title>
                    <clause id="_" inline-header="false" obligation="normative">
                       <title id="_">Intro 1</title>
                    </clause>
                 </clause>
                 <terms id="_" obligation="normative">
                    <title id="_">Intro 2</title>
                    <p id="_">Keine.</p>
                    <clause id="_" inline-header="false" obligation="normative">
                       <title id="_">Intro 3</title>
                    </clause>
                 </terms>
                 <clause id="_" obligation="normative" type="terms">
                    <title id="_">Intro 4</title>
                    <terms id="_" obligation="normative">
                       <title id="_">Intro 5</title>
                       <term id="_" anchor="term-Term1-1">
                          <preferred>
                             <expression>
                                <name>Term1</name>
                             </expression>
                          </preferred>
                       </term>
                    </terms>
                 </clause>
                 <terms id="_" obligation="normative">
                    <title id="_">Normal Terms</title>
                    <term id="_" anchor="term-Term2">
                       <preferred>
                          <expression>
                             <name>Term2</name>
                          </expression>
                       </preferred>
                    </term>
                    <terms id="_" type="external" obligation="normative">
                       <title id="_">An anderer Stelle definierte Begriffe</title>
                       <p id="_">Keine.</p>
                    </terms>
                 </terms>
                 <terms id="_" obligation="normative">
                    <title id="_">Symbols and Abbreviated Terms</title>
                    <clause id="_" inline-header="false" obligation="normative">
                       <title id="_">General</title>
                    </clause>
                    <term id="_" anchor="term-Symbols-1">
                       <preferred>
                          <expression>
                             <name>Symbols 1</name>
                          </expression>
                       </preferred>
                    </term>
                 </terms>
              </clause>
              <definitions id="_" type="abbreviated_terms" obligation="normative">
                 <title id="_">Abkürzungen und Akronyme</title>
                 <p id="_">Keine.</p>
              </definitions>
              <clause id="_" type="conventions" inline-header="false" obligation="normative">
                 <title id="_">Conventions</title>
              </clause>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">Clause 4</title>
                 <clause id="_" inline-header="false" obligation="normative">
                    <title id="_">Introduction</title>
                 </clause>
                 <clause id="_" inline-header="false" obligation="normative">
                    <title id="_">Clause 4.2</title>
                 </clause>
              </clause>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">Terms and Definitions</title>
              </clause>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">History</title>
              </clause>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">Source</title>
              </clause>
           </sections>
           <annex id="_" inline-header="false" obligation="normative">
              <title id="_">Annex</title>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">Annex A.1</title>
              </clause>
           </annex>
           <bibliography>
              <references id="_" normative="true" obligation="informative">
                 <title id="_">Referenzen</title>
                 <p id="_">Keine.</p>
              </references>
              <clause id="_" obligation="informative">
                 <title id="_">Bibliographie</title>
                 <references id="_" normative="false" obligation="informative">
                    <title id="_">Bibliography Subsection</title>
                 </references>
              </clause>
              <references id="_" normative="false" obligation="informative">
                 <title id="_">Second Bibliography</title>
              </references>
           </bibliography>
        </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(strip_guid(output))
  end

  it "processes explicit metadata, service publication in Russian" do
    input = Asciidoctor.convert(<<~INPUT, *OPTIONS)
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
      <metanorma xmlns='https://www.metanorma.org/ns/standoc' type='semantic' version='#{Metanorma::Itu::VERSION}' flavor="itu">
      <bibdata type='standard'>
           <title language='en' format='text/plain' type='main'>Main Title</title>
           <title language='ru' format='text/plain' type='main'>Titre Principal</title>
           <title language='en' format='text/plain' type='subtitle'>Subtitle</title>
           <title language='ru' format='text/plain' type='subtitle'>Soustitre</title>
           <docidentifier type='ITU-provisional'>ABC</docidentifier>
           <docidentifier primary="true" type='ITU'>
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
                <name>Международный Союз Электросвязи</name>
                <abbreviation>МСЭ</abbreviation>
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
                <name>Международный Союз Электросвязи</name>
                <abbreviation>МСЭ</abbreviation>
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
                 <name>Международный Союз Электросвязи</name>
                 <abbreviation>МСЭ</abbreviation>
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
    xml = Nokogiri::XML(input)
    xml.xpath("//xmlns:boilerplate | //xmlns:metanorma-extension")
      .each(&:remove)
    expect(Canon.format_xml(strip_guid(xml.to_xml)))
      .to be_equivalent_to Canon.format_xml(strip_guid(output))
  end

  it "processes sections in Russian" do
    input = section_template("ru", "Cyrl")
    output = <<~OUTPUT
      #{@blank_hdr.sub('<status>', '<abstract> <p>Text</p> </abstract><status>')
        .sub('<language>en</language>', '<language>ru</language>')
        .sub('<script>Latn</script>', '<script>Cyrl</script>')
        .sub('<title language="en"', '<title language="ru"')
        .gsub('<name>International Telecommunication Union</name>', '<name>Международный Союз Электросвязи</name>')
        .gsub('<abbreviation>ITU</abbreviation>', '<abbreviation>МСЭ</abbreviation>')
      }
            <preface>
              <abstract id="_">
                 <title id="_">Реферат</title>
                 <p id="_">Text</p>
              </abstract>
              <foreword id="_" obligation="informative">
                 <title id="_">Предисловие</title>
                 <p id="_">Text</p>
              </foreword>
              <introduction id="_" obligation="informative">
                 <title id="_">Введение</title>
                 <clause id="_" inline-header="false" obligation="informative">
                    <title id="_">Introduction Subsection</title>
                 </clause>
              </introduction>
              <clause id="_" type="history" inline-header="false" obligation="informative">
                 <title id="_">History</title>
              </clause>
              <clause id="_" type="source" inline-header="false" obligation="informative">
                 <title id="_">Source</title>
              </clause>
           </preface>
           <sections>
              <clause id="_" unnumbered="true" inline-header="false" obligation="normative">
                 <p id="_">Initial text</p>
              </clause>
              <clause id="_" type="scope" inline-header="false" obligation="normative">
                 <title id="_">Сфера применения</title>
                 <p id="_">Text</p>
              </clause>
              <terms id="_" obligation="normative">
                 <title id="_">Определения</title>
                 <p id="_">В настоящей Рекомендации определены следующие термины:</p>
                 <term id="_" anchor="term-Term1">
                    <preferred>
                       <expression>
                          <name>Term1</name>
                       </expression>
                    </preferred>
                 </term>
              </terms>
              <clause id="_" obligation="normative" type="terms">
                 <title id="_">Terms, Definitions, Symbols and Abbreviated Terms</title>
                 <clause id="_" inline-header="false" obligation="normative">
                    <title id="_">Introduction</title>
                    <clause id="_" inline-header="false" obligation="normative">
                       <title id="_">Intro 1</title>
                    </clause>
                 </clause>
                 <terms id="_" obligation="normative">
                    <title id="_">Intro 2</title>
                    <p id="_">Отсутствуют.</p>
                    <clause id="_" inline-header="false" obligation="normative">
                       <title id="_">Intro 3</title>
                    </clause>
                 </terms>
                 <clause id="_" obligation="normative" type="terms">
                    <title id="_">Intro 4</title>
                    <terms id="_" obligation="normative">
                       <title id="_">Intro 5</title>
                       <term id="_" anchor="term-Term1-1">
                          <preferred>
                             <expression>
                                <name>Term1</name>
                             </expression>
                          </preferred>
                       </term>
                    </terms>
                 </clause>
                 <terms id="_" obligation="normative">
                    <title id="_">Normal Terms</title>
                    <term id="_" anchor="term-Term2">
                       <preferred>
                          <expression>
                             <name>Term2</name>
                          </expression>
                       </preferred>
                    </term>
                    <terms id="_" type="external" obligation="normative">
                       <title id="_">Термины, определенные в других документах</title>
                       <p id="_">Отсутствуют.</p>
                    </terms>
                 </terms>
                 <terms id="_" obligation="normative">
                    <title id="_">Symbols and Abbreviated Terms</title>
                    <clause id="_" inline-header="false" obligation="normative">
                       <title id="_">General</title>
                    </clause>
                    <term id="_" anchor="term-Symbols-1">
                       <preferred>
                          <expression>
                             <name>Symbols 1</name>
                          </expression>
                       </preferred>
                    </term>
                 </terms>
              </clause>
              <definitions id="_" type="abbreviated_terms" obligation="normative">
                 <title id="_">Сокращения и акронимы</title>
                 <p id="_">Отсутствуют.</p>
              </definitions>
              <clause id="_" type="conventions" inline-header="false" obligation="normative">
                 <title id="_">Conventions</title>
              </clause>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">Clause 4</title>
                 <clause id="_" inline-header="false" obligation="normative">
                    <title id="_">Introduction</title>
                 </clause>
                 <clause id="_" inline-header="false" obligation="normative">
                    <title id="_">Clause 4.2</title>
                 </clause>
              </clause>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">Terms and Definitions</title>
              </clause>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">History</title>
              </clause>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">Source</title>
              </clause>
           </sections>
           <annex id="_" inline-header="false" obligation="normative">
              <title id="_">Annex</title>
              <clause id="_" inline-header="false" obligation="normative">
                 <title id="_">Annex A.1</title>
              </clause>
           </annex>
           <bibliography>
              <references id="_" normative="true" obligation="informative">
                 <title id="_">Ссылки</title>
                 <p id="_">Отсутствуют.</p>
              </references>
              <clause id="_" obligation="informative">
                 <title id="_">Библиография</title>
                 <references id="_" normative="false" obligation="informative">
                    <title id="_">Bibliography Subsection</title>
                 </references>
              </clause>
              <references id="_" normative="false" obligation="informative">
                 <title id="_">Second Bibliography</title>
              </references>
           </bibliography>
        </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(strip_guid(output))
  end

  private

  def section_template(lang, script)
    <<~OUTPUT
      #{ASCIIDOC_BLANK_HDR.sub(':novalid:', ":novalid:\n:language: #{lang}\n:script: #{script}")}

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
    OUTPUT
  end
end

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

  it "converts a blank document and insert missing sections" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-pdf:
    INPUT
    output = <<~OUTPUT
        #{@blank_hdr}
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
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output))

    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-pdf:
      :document-schema: not-legacy
    INPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output))
  end

  it "does not strip inline header" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      This is a preamble

      [%inline-header]
      == Section 1
    INPUT
    output = <<~OUTPUT
        #{@blank_hdr}
        <preface>
          <foreword id="_" obligation="informative">
            <title>Foreword</title>
            <p id="_">This is a preamble</p>
          </foreword>
        </preface>
        <sections>
          <clause id="_" anchor="_section_1" obligation="normative" inline-header="true">
            <title>Section 1</title>
          </clause>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output))
  end

  it "makes empty subclause titles have inline headers in resolutions" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :legacy-do-not-insert-missing-sections:
      :doctype: resolution

      This is a preamble

      == {blank}
      === {blank}
    INPUT
    output = <<~OUTPUT
        #{BLANK_HDR.sub('recommendation', 'resolution')}
        #{boilerplate(Nokogiri::XML("#{BLANK_HDR.sub('recommendation', 'resolution')}</metanorma>"))}
        <preface>
          <foreword id="_" obligation="informative">
            <title>Foreword</title>
            <p id="_">This is a preamble</p>
          </foreword>
        </preface>
        <sections>
          <clause id='_' inline-header='false' obligation='normative'>
            <clause id='_' anchor="_2" inline-header='true' obligation='normative'> </clause>
          </clause>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output))
  end

  it "does not make empty subclause titles have inline headers outside of resolutions" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :legacy-do-not-insert-missing-sections:
      :doctype: recommendation

      This is a preamble

      == {blank}
      === {blank}
    INPUT
    output = <<~OUTPUT
          #{@blank_hdr}
          <preface>
            <foreword id="_" obligation="informative">
              <title>Foreword</title>
              <p id="_">This is a preamble</p>
            </foreword>
          </preface>
          <sections>
          <clause id='_' inline-header='false' obligation='normative'>
            <clause id='_' anchor="_2" inline-header='false' obligation='normative'> </clause>
          </clause>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output))
  end

  it "move sections to preface" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      [preface]
      == Prefatory
      section

      == Section

      text
    INPUT
    output = <<~OUTPUT
        #{@blank_hdr}
        <preface>
          <clause id="_" anchor="_prefatory" obligation="informative" inline-header='false'>
            <title>Prefatory</title>
            <p id="_">section</p>
          </clause>
        </preface>
        <sections>
          <clause id="_" anchor="_section" obligation="normative" inline-header="false">
            <title>Section</title>
            <p id="_">text</p>
          </clause>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output))
  end

  it "processes sections" do
    input = <<~INPUT
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
        #{@blank_hdr.sub('<status>', '<abstract> <p>Text</p> </abstract><status>')}
           <preface>
              <abstract id="_" anchor="_abstract">
                 <title>Abstract</title>
                 <p id="_">Text</p>
              </abstract>
              <foreword id="_" obligation="informative">
                 <title>Foreword</title>
                 <p id="_">Text</p>
              </foreword>
              <introduction id="_" anchor="_introduction" obligation="informative">
                 <title>Introduction</title>
                 <clause id="_" anchor="_introduction_subsection" inline-header="false" obligation="informative">
                    <title>Introduction Subsection</title>
                 </clause>
              </introduction>
              <clause id="_" anchor="_history" type="history" inline-header="false" obligation="informative">
                 <title>History</title>
              </clause>
              <clause id="_" anchor="_source" type="source" inline-header="false" obligation="informative">
                 <title>Source</title>
              </clause>
           </preface>
           <sections>
              <clause id="_" unnumbered="true" inline-header="false" obligation="normative">
                 <p id="_">Initial text</p>
              </clause>
              <clause id="_" anchor="_scope" type="scope" inline-header="false" obligation="normative">
                 <title>Scope</title>
                 <p id="_">Text</p>
              </clause>
              <terms id="_" anchor="_terms_and_definitions" obligation="normative">
                 <title>Definitions</title>
                 <p id="_">This Recommendation defines the following terms:</p>
                 <term id="_" anchor="term-Term1">
                    <preferred>
                       <expression>
                          <name>Term1</name>
                       </expression>
                    </preferred>
                 </term>
              </terms>
              <clause id="_" anchor="_terms_definitions_symbols_and_abbreviated_terms" obligation="normative" type="terms">
                 <title>Terms, Definitions, Symbols and Abbreviated Terms</title>
                 <clause id="_" anchor="_introduction_2" inline-header="false" obligation="normative">
                    <title>Introduction</title>
                    <clause id="_" anchor="_intro_1" inline-header="false" obligation="normative">
                       <title>Intro 1</title>
                    </clause>
                 </clause>
                 <terms id="_" anchor="_intro_2" obligation="normative">
                    <title>Intro 2</title>
                    <p id="_">None.</p>
                    <clause id="_" anchor="_intro_3" inline-header="false" obligation="normative">
                       <title>Intro 3</title>
                    </clause>
                 </terms>
                 <clause id="_" anchor="_intro_4" obligation="normative" type="terms">
                    <title>Intro 4</title>
                    <terms id="_" anchor="_intro_5" obligation="normative">
                       <title>Intro 5</title>
                       <term id="_" anchor="term-Term1-1">
                          <preferred>
                             <expression>
                                <name>Term1</name>
                             </expression>
                          </preferred>
                       </term>
                    </terms>
                 </clause>
                 <terms id="_" anchor="_normal_terms" obligation="normative">
                    <title>Normal Terms</title>
                    <term id="_" anchor="term-Term2">
                       <preferred>
                          <expression>
                             <name>Term2</name>
                          </expression>
                       </preferred>
                    </term>
                    <terms id="_" anchor="_terms_defined_elsewhere" type="external" obligation="normative">
                       <title>Terms defined elsewhere</title>
                       <p id="_">None.</p>
                    </terms>
                 </terms>
                 <terms id="_" anchor="_symbols_and_abbreviated_terms" obligation="normative">
                    <title>Symbols and Abbreviated Terms</title>
                    <clause id="_" anchor="_general" inline-header="false" obligation="normative">
                       <title>General</title>
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
              <definitions id="_" anchor="_abbreviated_terms" type="abbreviated_terms" obligation="normative">
                 <title>Abbreviations and acronyms</title>
                 <p id="_">None.</p>
              </definitions>
              <clause id="_" anchor="_conventions" type="conventions" inline-header="false" obligation="normative">
                 <title>Conventions</title>
              </clause>
              <clause id="_" anchor="_clause_4" inline-header="false" obligation="normative">
                 <title>Clause 4</title>
                 <clause id="_" anchor="_introduction_3" inline-header="false" obligation="normative">
                    <title>Introduction</title>
                 </clause>
                 <clause id="_" anchor="_clause_4_2" inline-header="false" obligation="normative">
                    <title>Clause 4.2</title>
                 </clause>
              </clause>
              <clause id="_" anchor="_terms_and_definitions_2" inline-header="false" obligation="normative">
                 <title>Terms and Definitions</title>
              </clause>
              <clause id="_" anchor="_history_2" inline-header="false" obligation="normative">
                 <title>History</title>
              </clause>
              <clause id="_" anchor="_source_2" inline-header="false" obligation="normative">
                 <title>Source</title>
              </clause>
           </sections>
           <annex id="_" anchor="_annex" inline-header="false" obligation="normative">
              <title>Annex</title>
              <clause id="_" anchor="_annex_a_1" inline-header="false" obligation="normative">
                 <title>Annex A.1</title>
              </clause>
           </annex>
           <bibliography>
              <references id="_" anchor="_references" normative="true" obligation="informative">
                 <title>References</title>
                 <p id="_">None.</p>
              </references>
              <clause id="_" anchor="_bibliography" obligation="informative">
                 <title>Bibliography</title>
                 <references id="_" anchor="_bibliography_subsection" normative="false" obligation="informative">
                    <title>Bibliography Subsection</title>
                 </references>
              </clause>
              <references id="_" anchor="_second_bibliography" normative="false" obligation="informative">
                 <title>Second Bibliography</title>
              </references>
           </bibliography>
        </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(strip_guid(output))
  end

  xit "has unique terms and definitions clauses" do
    input = <<~INPUT
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
    output = <<~OUTPUT
        #{@blank_hdr}
        <sections>
          <terms id='_' obligation='normative'>
            <title>Definitions</title>
            <p id='_'>This Recommendation defines the following terms:</p>
            <term id="_" anchor="term-Term-1">
            <preferred><expression><name>Term 1</name></expression></preferred>
            </term>
          </terms>
          <definitions id='_' obligation='normative'>
            <title>Abbreviations and acronyms</title>
            <p id='_'>This Recommendation uses the following abbreviations and acronyms:</p>
            <dl id='_'>
              <dt id="_" anchor="symbol-a">a</dt>
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
                <dt id="_" anchor="symbol-a-1">a</dt>
                <dd>
                  <p id='_'>b</p>
                </dd>
              </dl>
            </definitions>
          </clause>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end

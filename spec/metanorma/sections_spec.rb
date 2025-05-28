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
            <title id="_">Scope</title>
            <p id='_'>None.</p>
          </clause>
          <terms obligation='normative' id="_">
            <title id="_">Definitions</title>
            <p id='_'>None.</p>
          </terms>
          <definitions obligation='normative' id="_">
            <title id="_">Abbreviations and acronyms</title>
            <p id='_'>None.</p>
          </definitions>
          <clause obligation='normative' id='_' type="conventions">
            <title id="_">Conventions</title>
            <p id='_'>None.</p>
          </clause>
        </sections>
        <bibliography>
          <references obligation='informative' normative="true" id="_">
            <title id="_">References</title>
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
            <title id="_">Foreword</title>
            <p id="_">This is a preamble</p>
          </foreword>
        </preface>
        <sections>
          <clause id="_" obligation="normative" inline-header="true">
            <title id="_">Section 1</title>
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
            <title id="_">Foreword</title>
            <p id="_">This is a preamble</p>
          </foreword>
        </preface>
        <sections>
          <clause id='_' inline-header='false' obligation='normative'>
            <clause id='_' inline-header='true' obligation='normative'> </clause>
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
              <title id="_">Foreword</title>
              <p id="_">This is a preamble</p>
            </foreword>
          </preface>
          <sections>
          <clause id='_' inline-header='false' obligation='normative'>
            <clause id='_' inline-header='false' obligation='normative'> </clause>
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
          <clause id="_" obligation="informative" inline-header='false'>
            <title id="_">Prefatory</title>
            <p id="_">section</p>
          </clause>
        </preface>
        <sections>
          <clause id="_" obligation="normative" inline-header="false">
            <title id="_">Section</title>
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
              <abstract id="_">
                 <title id="_">Abstract</title>
                 <p id="_">Text</p>
              </abstract>
              <foreword id="_" obligation="informative">
                 <title id="_">Foreword</title>
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
                 <title id="_">Scope</title>
                 <p id="_">Text</p>
              </clause>
              <terms id="_" obligation="normative">
                 <title id="_">Definitions</title>
                 <p id="_">This Recommendation defines the following terms:</p>
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
                    <p id="_">None.</p>
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
                       <title id="_">Terms defined elsewhere</title>
                       <p id="_">None.</p>
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
                 <title id="_">Abbreviations and acronyms</title>
                 <p id="_">None.</p>
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
                 <title id="_">References</title>
                 <p id="_">None.</p>
              </references>
              <clause id="_" obligation="informative">
                 <title id="_">Bibliography</title>
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
            <title id="_">Definitions</title>
            <p id='_'>This Recommendation defines the following terms:</p>
            <term id="_" anchor="term-Term-1">
            <preferred><expression><name>Term 1</name></expression></preferred>
            </term>
          </terms>
          <definitions id='_' obligation='normative'>
            <title id="_">Abbreviations and acronyms</title>
            <p id='_'>This Recommendation uses the following abbreviations and acronyms:</p>
            <dl id='_'>
              <dt id="_" anchor="symbol-a">a</dt>
              <dd>
                <p id='_'>b</p>
              </dd>
            </dl>
          </definitions>
          <clause id='_' inline-header='false' obligation='normative'>
            <title id="_">Clause</title>
            <clause id='_' inline-header='false' obligation='normative'>
              <title id="_">Definitions</title>
              <clause id='_' inline-header='false' obligation='normative'>
                <title id="_">Term 1</title>
              </clause>
            </clause>
            <clause id='_' inline-header='false' obligation='normative'>
              <title id="_">Abbreviations and acronyms</title>
              <dl id='_'>
                <dt>a</dt>
                <dd>
                  <p id='_'>b</p>
                </dd>
              </dl>
            </clause>
          </clause>
          <clause id='_' inline-header='false' obligation='normative'>
            <title id="_">Clause 2</title>
            <clause id='_' inline-header='false' obligation='normative'>
              <title id="_">Definitions</title>
              <clause id='_' inline-header='false' obligation='normative'>
                <title id="_">Term 1</title>
              </clause>
            </clause>
            <definitions id='_' obligation='normative'>
              <title id="_">Abbreviations and acronyms</title>
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

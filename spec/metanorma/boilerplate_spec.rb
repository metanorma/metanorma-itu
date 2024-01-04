require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::ITU do
  before(:all) do
    @blank_hdr = blank_hdr_gen
  end

  it "inserts boilerplate before empty Normative References" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      [bibliography]
      == References

    INPUT
    output = <<~OUTPUT
        #{@blank_hdr}
        <sections>
        </sections>
        <bibliography>
          <references id="_" obligation="informative" normative="true">
            <title>References</title>
            <p id="_">None.</p>
          </references>
        </bibliography>
      </itu-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "inserts boilerplate before non-empty Normative References" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      [bibliography]
      == References
      * [[[a,b]]] A

    INPUT
    output = <<~OUTPUT
        #{@blank_hdr}
        <sections>
        </sections>
        <bibliography>
          <references id="_" obligation="informative" normative="true">
            <title>References</title>
            <p id="_">The following ITU-T Recommendations and other references contain provisions which, through reference in this text, constitute provisions of this Recommendation. At the time of publication, the editions indicated were valid. All Recommendations and other references are subject to revision; users of this Recommendation are therefore encouraged to investigate the possibility of applying the most recent edition of the Recommendations and other references listed below. A list of the currently valid ITU-T Recommendations is regularly published. The reference to a document within this Recommendation does not give it, as a stand-alone document, the status of a Recommendation.</p>
            <bibitem id="a">
              <formattedref format="application/x-isodoc+xml">A</formattedref>
              <docidentifier>b</docidentifier>
            </bibitem>
          </references>
        </bibliography>
      </itu-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "inserts boilerplate before internal and external terms clause" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Definitions
      === terms defined elsewhere
      ==== Term 1
      === terms defined in this recommendation
      ==== Term 2
    INPUT
    output = <<~OUTPUT
        #{@blank_hdr}
        <sections>
          <clause id='_' obligation='normative'>
            <title>Definitions</title>
            <terms id='_' type='external' obligation='normative'>
              <title>Terms defined elsewhere</title>
              <p id='_'>This Recommendation uses the following terms defined elsewhere:</p>
              <term id='term-Term-1'>
                <preferred><expression><name>Term 1</name></expression></preferred>
              </term>
            </terms>
            <terms id='_' type='internal' obligation='normative'>
              <title>Terms defined in this recommendation</title>
              <p id='_'>This Recommendation defines the following terms:</p>
              <term id='term-Term-2'>
                <preferred><expression><name>Term 2</name></expression></preferred>
              </term>
            </terms>
          </clause>
        </sections>
      </itu-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "inserts boilerplate before empty internal and external terms clause" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Definitions
      === terms defined elsewhere
      === terms defined in this recommendation
    INPUT
    output = <<~OUTPUT
        #{@blank_hdr}
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
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "does not insert boilerplate before internal and external terms clause if already populated" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Definitions
      === terms defined elsewhere

      Boilerplate

      ==== Term 1
      === terms defined in this recommendation

      Boilerplate

      ==== Term 2
    INPUT
    output = <<~OUTPUT
       #{@blank_hdr}
       <sections>
          <clause id='_' obligation='normative'>
            <title>Definitions</title>
            <terms id='_' type='external' obligation='normative'>
              <title>Terms defined elsewhere</title>
              <p id='_'>Boilerplate</p>
              <term id='term-Term-1'>
                <preferred><expression><name>Term 1</name></expression></preferred>
              </term>
            </terms>
            <terms id='_' type='internal' obligation='normative'>
              <title>Terms defined in this recommendation</title>
              <p id='_'>Boilerplate</p>
              <term id='term-Term-2'>
                <preferred><expression><name>Term 2</name></expression></preferred>
              </term>
            </terms>
          </clause>
        </sections>
      </itu-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "inserts boilerplate before definitions with no internal and external terms clauses" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Definitions
      === terms defined somewhere
      ==== Term 1
      === terms defined somewhere else
      ==== Term 2
    INPUT
    output = <<~OUTPUT
        #{@blank_hdr}
        <sections>
          <clause id="_" obligation="normative">
            <title>Definitions</title>
            <p id="_">This Recommendation defines the following terms:</p>
            <terms id="_" obligation="normative">
              <title>terms defined somewhere</title>
              <term id="term-Term-1">
                <preferred><expression><name>Term 1</name></expression></preferred>
              </term>
            </terms>
            <terms id="_" obligation="normative">
              <title>terms defined somewhere else</title>
              <term id="term-Term-2">
                <preferred><expression><name>Term 2</name></expression></preferred>
              </term>
            </terms>
          </clause>
        </sections>
      </itu-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "doesn't insert boilerplate before definitions with no internal & external terms clauses if already populated" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Definitions

      Boilerplate

      === terms defined somewhere
      ==== Term 1
      === terms defined somewhere else
      ==== Term 2
    INPUT
    output = <<~OUTPUT
        #{@blank_hdr}
        <sections>
          <clause id="_" obligation="normative">
            <title>Definitions</title>
            <p id="_">Boilerplate</p>
            <terms id="_" obligation="normative">
              <title>terms defined somewhere</title>
                <term id="term-Term-1">
                <preferred><expression><name>Term 1</name></expression></preferred>
              </term>
            </terms>
            <terms id="_" obligation="normative">
              <title>terms defined somewhere else</title>
              <term id="term-Term-2">
                <preferred><expression><name>Term 2</name></expression></preferred>
              </term>
            </terms>
          </clause>
        </sections>
      </itu-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "inserts boilerplate before symbols" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Abbreviations and acronyms

      a:: b
    INPUT
    output = <<~OUTPUT
        #{@blank_hdr}
        <sections>
          <definitions id="_" obligation='normative'>
            <title>Abbreviations and acronyms</title>
            <p id="_">This Recommendation uses the following abbreviations and acronyms:</p>
            <dl id="_">
              <dt id='symbol-a'>a</dt>
              <dd>
                <p id="_">b</p>
              </dd>
            </dl>
          </definitions>
        </sections>
      </itu-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "does not insert boilerplate before symbols if already populated" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Abbreviations and acronyms

      Boilerplate

      a:: b
    INPUT
    output = <<~OUTPUT
        #{@blank_hdr}
        <sections>
          <definitions id="_" obligation='normative'><title>Abbreviations and acronyms</title><p id="_">Boilerplate</p>
            <dl id="_">
              <dt id='symbol-a'>a</dt>
              <dd>
                <p id="_">b</p>
              </dd>
            </dl>
          </definitions>
        </sections>
      </itu-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "inserts empty clause boilerplate" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Terms and definitions

      [bibliography]
      == Normative References

    INPUT
    output = <<~OUTPUT
       #{@blank_hdr}
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
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end
end

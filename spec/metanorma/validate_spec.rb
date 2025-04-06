require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Itu do
  context "when xref_error.adoc compilation" do
    FileUtils.rm_rf "xref_error.err.html"
    it "generates error file" do
      File.write("xref_error.adoc", <<~CONTENT)
        = X
        A

        == Clause

        <<a,b>>
      CONTENT

      expect do
        mock_pdf
        Metanorma::Compile
          .new
          .compile("xref_error.adoc", type: "itu", install_fonts: false)
      end.to(change { File.exist?("xref_error.err.html") }
              .from(false).to(true))
    end
  end

  it "Warns of illegal doctype" do
    Asciidoctor.convert(<<~INPUT, backend: :itu, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :doctype: pizza

      text
    INPUT
    expect(File.read("test.err.html"))
      .to include("pizza is not a recognised document type")
  end

  it "Warns of illegal status" do
    Asciidoctor.convert(<<~INPUT, backend: :itu, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :status: pizza

      text
    INPUT
    expect(File.read("test.err.html"))
      .to include("pizza is not a recognised status")
  end

  it "Warns if document identifier is invalid" do
    Asciidoctor.convert(<<~INPUT, backend: :itu, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :bureau: R
      :docnumber: A.0B

      text
    INPUT
    expect(File.read("test.err.html"))
      .to include("does not match ITU document identifier conventions")

    Asciidoctor.convert(<<~INPUT, backend: :itu, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :bureau: R
      :docnumber: G.650.1

      text
    INPUT
    expect(File.read("test.err.html"))
      .not_to include("does not match ITU document identifier conventions")

    Asciidoctor.convert(<<~INPUT, backend: :itu, header_footer: true)
      = Document title
      Author
      :bureau: T
      :question: Q1/17: Security standardization strategy and coordination
      :group-type: study-group
      :group: Study Group 17
      :group-acronym: SG 17
      :group-year-start: 2025
      :group-year-end: 2028
      :meeting: TODO-FULL-NAME-OF-MEETING
      :meeting-date: 2025-02-01/2025-02-02
      :meeting-place: TODO-PLACE
      :language: en
      :source: Broadcom Europe Ltd.
      :docnumber: 3000

      text
    INPUT
    expect(File.read("test.err.html"))
      .not_to include("does not match ITU document identifier conventions")
  end

  it "Warns if Recommendation Status determined and Process AAP" do
    Asciidoctor.convert(<<~INPUT, backend: :itu, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :recommendation-from: A
      :approval-process: aap
      :approval-status: determined

      text
    INPUT
    expect(File.read("test.err.html"))
      .to include("Recommendation Status determined inconsistent with AAP")
  end

  it "Warns if not Recommendation Status determined or in-force, and Process TAP" do
    Asciidoctor.convert(<<~INPUT, backend: :itu, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :recommendation-from: A
      :approval-process: tap
      :approval-status: undetermined

      text
    INPUT
    expect(File.read("test.err.html"))
      .to include("Recommendation Status undetermined inconsistent with TAP")
  end

  it "Warns if term definition does not start with capital" do
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      #{VALIDATING_BLANK_HDR}
      == Terms and Definitions

      === Term

      the definition of a term is a part of the specialized vocabulary of a particular field
    INPUT
    expect(File.read("test.err.html"))
      .to include("term definition does not start with capital")
  end

  it "Warns if term definition does not end with period" do
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      #{VALIDATING_BLANK_HDR}
      == Terms and Definitions

      === Term

      Part of the specialized vocabulary of a particular field
    INPUT
    expect(File.read("test.err.html"))
      .to include("term definition does not end with period")
  end

  it "Warns if term is not lowercase" do
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      #{VALIDATING_BLANK_HDR}
      == Terms and Definitions

      === Fred

      Part of the specialized vocabulary of a particular field
    INPUT
    expect(File.read("test.err.html"))
      .to include("Fred: term is not lowercase")
  end

  it "Warns if title includes series title" do
    Asciidoctor.convert(<<~INPUT, backend: :itu, header_footer: true)
      = Transmission Systems and Media, Digital Systems and Networks: Software tools for speech and audio coding standardization
      Author
      :docfile: test.adoc
      :nodoc:
      :series: G: Transmission Systems and Media, Digital Systems and Networks

      Part of the specialized vocabulary of a particular field
    INPUT
    expect(File.read("test.err.html"))
      .to include("Title includes series name")
  end

  it "Warns if no Summary provided" do
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      #{VALIDATING_BLANK_HDR}

      Part of the specialized vocabulary of a particular field
    INPUT
    expect(File.read("test.err.html"))
      .to include("No Summary has been provided")
  end

  it "does not warn if Summary provided" do
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      #{VALIDATING_BLANK_HDR}

      [abstract]
      == Abstract
      Part of the specialized vocabulary of a particular field
    INPUT
    expect(File.read("test.err.html"))
      .not_to include("No Summary has been provided")
  end

  it "Warns if no Keywords provided" do
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      #{VALIDATING_BLANK_HDR}

      Part of the specialized vocabulary of a particular field
    INPUT
    expect(File.read("test.err.html"))
      .to include("No Keywords have been provided")
  end

  it "does not warn if Keywords provided" do
    Asciidoctor.convert(<<~INPUT, backend: :itu, header_footer: true)
      = Transmission Systems and Media, Digital Systems and Networks: Software tools for speech and audio coding standardization
      Author
      :docfile: test.adoc
      :nodoc:
      :keywords: A

      [abstract]
      == Abstract
      Part of the specialized vocabulary of a particular field
    INPUT
    expect(File.read("test.err.html"))
      .not_to include("No Keywords have been provided")
  end

  it "warns if requirement in preface" do
    Asciidoctor.convert(<<~INPUT, backend: :itu, header_footer: true)
      = Transmission Systems and Media, Digital Systems and Networks: Software tools for speech and audio coding standardization
      Author
      :docfile: test.adoc
      :nodoc:
      :keywords: A

      [abstract]
      == Abstract
      This shall not pass.
    INPUT
    expect(File.read("test.err.html"))
      .to include("Requirement possibly in preface")
  end

  it "warns of unnumbered clause not in resolution" do
    Asciidoctor.convert(<<~INPUT, backend: :itu, header_footer: true)
      = Transmission Systems and Media, Digital Systems and Networks: Software tools for speech and audio coding standardization
      Author
      :docfile: test.adoc
      :nodoc:
      :doctype: recommendation

      [%unnumbered]
      == Clause
    INPUT
    expect(File.read("test.err.html"))
      .to include("Unnumbered clause out of place")

    Asciidoctor.convert(<<~INPUT, backend: :itu, header_footer: true)
      = Transmission Systems and Media, Digital Systems and Networks: Software tools for speech and audio coding standardization
      Author
      :docfile: test.adoc
      :nodoc:
      :doctype: resolution

      [%unnumbered]
      == Clause
    INPUT
    expect(File.read("test.err.html"))
      .not_to include("Unnumbered clause out of place")
  end

  it "warns of unnumbered clause not first clause in resolution" do
    Asciidoctor.convert(<<~INPUT, backend: :itu, header_footer: true)
      = Transmission Systems and Media, Digital Systems and Networks: Software tools for speech and audio coding standardization
      Author
      :docfile: test.adoc
      :nodoc:
      :doctype: resolution

      == Clause

      [%unnumbered]
      === Subclause

    INPUT
    expect(File.read("test.err.html"))
      .to include("Unnumbered clause out of place")
    Asciidoctor.convert(<<~INPUT, backend: :itu, header_footer: true)
      = Transmission Systems and Media, Digital Systems and Networks: Software tools for speech and audio coding standardization
      Author
      :docfile: test.adoc
      :nodoc:
      :doctype: resolution

      == Clause

      [%unnumbered]
      == {blank}
    INPUT
    expect(File.read("test.err.html"))
      .to include("Unnumbered clause out of place")
  end

  it "validates document against Metanorma XML schema" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      = A
      X
      :docfile: test.adoc
      :no-pdf:

      [align=mid-air]
      Para
    INPUT
    expect(File.read("test.err.html"))
      .to include('value of attribute "align" is invalid; must be equal to')
  end
end

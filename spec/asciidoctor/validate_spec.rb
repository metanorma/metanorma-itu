require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::ITU do
  context "when xref_error.adoc compilation" do
    it "generates error file" do
      File.write("xref_error.adoc", <<~"CONTENT")
        = X
        A

        == Clause

        <<a,b>>
      CONTENT

      expect do
        mock_pdf
        Metanorma::Compile
          .new
          .compile("xref_error.adoc", type: "itu", no_install_fonts: true)
      end.to(change { File.exist?("xref_error.err") }
              .from(false).to(true))
    end
  end

  it "Warns of illegal doctype" do
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :doctype: pizza

      text
    INPUT
    expect(File.read("test.err")).to include "pizza is not a recognised document type"
  end

  it "Warns of illegal status" do
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :status: pizza

      text
    INPUT
    expect(File.read("test.err")).to include "pizza is not a recognised status"
  end

  it "Warns if document identifier is invalid" do
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :bureau: R
      :docnumber: A.0B

      text
    INPUT
    expect(File.read("test.err")).to include "does not match ITU document identifier conventions"
  end

  it "Warns if Recommendation Status determined and Process AAP" do
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :recommendation-from: A
      :approval-process: aap
      :approval-status: determined

      text
    INPUT
    expect(File.read("test.err")).to include "Recommendation Status determined inconsistent with AAP"
  end

  it "Warns if not Recommendation Status determined or in-force, and Process TAP" do
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :recommendation-from: A
      :approval-process: tap
      :approval-status: undetermined

      text
    INPUT
    expect(File.read("test.err")).to include "Recommendation Status undetermined inconsistent with TAP"
  end

  it "Warns if term definition does not start with capital" do
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      #{VALIDATING_BLANK_HDR}
      == Terms and Definitions

      === Term

      the definition of a term is a part of the specialized vocabulary of a particular field
    INPUT
    expect(File.read("test.err")).to include "term definition does not start with capital"
  end

  it "Warns if term definition does not end with period" do
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      #{VALIDATING_BLANK_HDR}
      == Terms and Definitions

      === Term

      Part of the specialized vocabulary of a particular field
    INPUT
    expect(File.read("test.err")).to include "term definition does not end with period"
  end

  it "Warns if term is not lowercase" do
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      #{VALIDATING_BLANK_HDR}
      == Terms and Definitions

      === Fred

      Part of the specialized vocabulary of a particular field
    INPUT
    expect(File.read("test.err")).to include "Fred: term is not lowercase"
  end

  it "Warns if title includes series title" do
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      = Transmission Systems and Media, Digital Systems and Networks: Software tools for speech and audio coding standardization
      Author
      :docfile: test.adoc
      :nodoc:
      :series: G: Transmission Systems and Media, Digital Systems and Networks

      Part of the specialized vocabulary of a particular field
    INPUT
    expect(File.read("test.err")).to include "Title includes series name"
  end

  it "Warns if no Summary provided" do
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      #{VALIDATING_BLANK_HDR}

      Part of the specialized vocabulary of a particular field
    INPUT
    expect(File.read("test.err")).to include "No Summary has been provided"
  end

  it "does not warn if Summary provided" do
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      #{VALIDATING_BLANK_HDR}

      [abstract]
      == Abstract
      Part of the specialized vocabulary of a particular field
    INPUT
    expect(File.read("test.err")).not_to include "No Summary has been provided"
  end

  it "Warns if no Keywords provided" do
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      #{VALIDATING_BLANK_HDR}

      Part of the specialized vocabulary of a particular field
    INPUT
    expect(File.read("test.err")).to include "No Keywords have been provided"
  end

  it "does not warn if Keywords provided" do
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      = Transmission Systems and Media, Digital Systems and Networks: Software tools for speech and audio coding standardization
      Author
      :docfile: test.adoc
      :nodoc:
      :keywords: A

      [abstract]
      == Abstract
      Part of the specialized vocabulary of a particular field
    INPUT
    expect(File.read("test.err")).not_to include "No Keywoerds have been provided"
  end

  it "warns if requirement in preface" do
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      = Transmission Systems and Media, Digital Systems and Networks: Software tools for speech and audio coding standardization
      Author
      :docfile: test.adoc
      :nodoc:
      :keywords: A

      [abstract]
      == Abstract
      This shall not pass.
    INPUT
    expect(File.read("test.err")).to include "Requirement possibly in preface"
  end

  it "warns of unnumbered clause not in resolution" do
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      = Transmission Systems and Media, Digital Systems and Networks: Software tools for speech and audio coding standardization
      Author
      :docfile: test.adoc
      :nodoc:
      :doctype: recommendation

      [%unnumbered]
      == Clause
    INPUT
    expect(File.read("test.err")).to include "Unnumbered clause out of place"

    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      = Transmission Systems and Media, Digital Systems and Networks: Software tools for speech and audio coding standardization
      Author
      :docfile: test.adoc
      :nodoc:
      :doctype: resolution

      [%unnumbered]
      == Clause
    INPUT
    expect(File.read("test.err")).not_to include "Unnumbered clause out of place"
  end

  it "warns of unnumbered clause not first clause in resolution" do
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      = Transmission Systems and Media, Digital Systems and Networks: Software tools for speech and audio coding standardization
      Author
      :docfile: test.adoc
      :nodoc:
      :doctype: resolution

      == Clause

      [%unnumbered]
      === Subclause

    INPUT
    expect(File.read("test.err")).to include "Unnumbered clause out of place"
    Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true)
      = Transmission Systems and Media, Digital Systems and Networks: Software tools for speech and audio coding standardization
      Author
      :docfile: test.adoc
      :nodoc:
      :doctype: resolution

      == Clause

      [%unnumbered]
      == {blank}
    INPUT
    expect(File.read("test.err")).to include "Unnumbered clause out of place"
  end
end

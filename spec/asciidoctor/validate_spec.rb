require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::ITU do

  it "Warns of illegal doctype" do
    expect { Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true) }.to output(/pizza is not a recognised document type/).to_stderr
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :doctype: pizza

  text
  INPUT
end

  it "Warns of illegal status" do
    expect { Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true) }.to output(/pizza is not a recognised status/).to_stderr
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :status: pizza

  text
  INPUT
end

it "Warns if document identifier is invalid" do
  expect { Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true) }.to output(%r{does not match ITU document identifier conventions}).to_stderr
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :bureau: R
  :docnumber: A.0B

  text
  INPUT
end

it "Warns if Recommendation Status determined and Process AAP" do
  expect { Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true) }.to output(%r{Recommendation Status determined inconsistent with AAP}).to_stderr
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :recommendation-from: A
  :approval-process: aap
  :approval-status: determined

  text
  INPUT
end

it "Warns if not Recommendation Status determined or in-force, and Process TAP" do
  expect { Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true) }.to output(%r{Recommendation Status undetermined inconsistent with TAP}).to_stderr
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :recommendation-from: A
  :approval-process: tap
  :approval-status: undetermined

  text
  INPUT
end

it "Warning if term definition does not start with capital" do
  expect { Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true) }.to output(%r{term definition does not start with capital}).to_stderr
  #{VALIDATING_BLANK_HDR}
  == Terms and Definitions
  
  === Term

  the definition of a term is a part of the specialized vocabulary of a particular field
  INPUT
end

it "Warning if term definition does not end with period" do
  expect { Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true) }.to output(%r{term definition does not end with period}).to_stderr
  #{VALIDATING_BLANK_HDR}
  == Terms and Definitions
  
  === Term

  Part of the specialized vocabulary of a particular field
  INPUT
end

it "Warning if term is not lowercase" do
  expect { Asciidoctor.convert(<<~"INPUT", backend: :itu, header_footer: true) }.to output(%r{Fred: term is not lowercase}).to_stderr
  #{VALIDATING_BLANK_HDR}
  == Terms and Definitions

  === Fred

  Part of the specialized vocabulary of a particular field
  INPUT
end


end

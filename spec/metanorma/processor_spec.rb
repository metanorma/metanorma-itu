require "spec_helper"
require "metanorma"

# RSpec.describe Asciidoctor::Csand do
RSpec.describe Metanorma::Itu::Processor do
  registry = Metanorma::Registry.instance
  registry.register(Metanorma::Itu::Processor)
  processor = registry.find_processor(:itu)

  it "registers against metanorma" do
    expect(processor).not_to be nil
  end

  it "registers output formats against metanorma" do
    expect(processor.output_formats.sort.to_s).to be_equivalent_to <<~OUTPUT
      [[:doc, "doc"], [:html, "html"], [:pdf, "pdf"], [:presentation, "presentation.xml"], [:rxl, "rxl"], [:xml, "xml"]]
    OUTPUT
  end

  it "registers version against metanorma" do
    expect(processor.version.to_s).to match(%r{^Metanorma::Itu })
  end

  it "generates IsoDoc XML from a blank document" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
    INPUT
    output = <<~OUTPUT
        #{blank_hdr_gen}
        <sections/>
      </itu-standard>
    OUTPUT
    expect(strip_guid(Xml::C14n.format(processor.input_to_isodoc(input, nil))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "generates HTML from IsoDoc XML" do
    FileUtils.rm_f "test.xml"
    processor.output(<<~INPUT, "test.xml", "test.html", :html)
      <itu-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
          <terms id="H" obligation="normative" displayorder="1"><fmt-title>Terms</fmt-title>
            <term id="J">
              <fmt-name>1.1.</fmt-name>
              <fmt-preferred>Term2</fmt-preferred>
            </term>
          </terms>
          <preface/>
        </sections>
      </itu-standard>
    INPUT
    expect(Xml::C14n.format(strip_guid(File.read("test.html", encoding: "utf-8")
      .gsub(%r{^.*<main}m, "<main")
      .gsub(%r{</main>.*}m, "</main>"))))
      .to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
        <main class="main-section">
          <button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
          <div id="H">
            <h1 id="_">
              <a class="anchor" href="#H"/>
              <a class="header" href="#H">Terms</a>
            </h1>
            <div id="J">
              <p class="TermNum" id="J"><b>1.1.  Term2</b></p>
            </div>
          </div>
        </main>
      OUTPUT
  end
end

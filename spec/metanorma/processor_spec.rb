require "spec_helper"
require "metanorma"

#RSpec.describe Asciidoctor::Csand do
RSpec.describe Metanorma::ITU::Processor do

  registry = Metanorma::Registry.instance
  registry.register(Metanorma::ITU::Processor)
  processor = registry.find_processor(:itu)

  it "registers against metanorma" do
    expect(processor).not_to be nil
  end

  it "registers output formats against metanorma" do
    expect(processor.output_formats.sort.to_s).to be_equivalent_to <<~"OUTPUT"
    [[:doc, "doc"], [:html, "html"], [:pdf, "pdf"], [:rxl, "rxl"], [:xml, "xml"]]
    OUTPUT
  end

  it "registers version against metanorma" do
    expect(processor.version.to_s).to match(%r{^Metanorma::ITU })
  end

  it "generates IsoDoc XML from a blank document" do
    expect(strip_guid(processor.input_to_isodoc(<<~"INPUT", nil))).to be_equivalent_to <<~"OUTPUT"
    #{ASCIIDOC_BLANK_HDR}
    INPUT
    #{BLANK_HDR}
<preface/><sections/>
</itu-standard>
    OUTPUT
  end

  it "generates HTML from IsoDoc XML" do
    FileUtils.rm_f "test.xml"
    processor.output(<<~"INPUT", "test.html", :html)
               <itu-standard xmlns="http://riboseinc.com/isoxml">
       <sections>
       <terms id="H" obligation="normative">
         <term id="J">
         <preferred>Term2</preferred>
       </term>
        </terms>
        <preface/></sections>
        </itu-standard>
    INPUT
    expect(File.read("test.html", encoding: "utf-8").gsub(%r{^.*<main}m, "<main").gsub(%r{</main>.*}m, "</main>")).to be_equivalent_to <<~"OUTPUT"
           <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
             <p class="zzSTDTitle1"></p>
             <p class="zzSTDTitle2"></p>
       <div id="H">
  <h1>1&#xA0; Definitions</h1>
  <div id="J"><p class="TermNum" id="J"><b>1.1&#xA0; Term2</b>:</p>

       </div>
           </main>
    OUTPUT
  end

end

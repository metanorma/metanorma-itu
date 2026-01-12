require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "bundler/setup"
require "asciidoctor"
require "metanorma-itu"
require "isodoc/itu/html_convert"
require "metanorma/standoc/converter"
require "rspec/matchers"
require "equivalent-xml"
require "htmlentities"
require "metanorma"
require "metanorma/itu"
require "relaton_iso"
require "canon"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.around do |example|
    Dir.mktmpdir("rspec-") do |dir|
      Dir.chdir(dir) { example.run }
    end
  end
end

OPTIONS = [backend: :itu, header_footer: true].freeze

def presxml_options
  { semanticxmlinsert: "false" }
end

def metadata(xml)
  xml.sort.to_h.delete_if do |_k, v|
    v.nil? || (v.respond_to?(:empty?) && v.empty?)
  end
end

def htmlencode(xml)
  HTMLEntities.new.encode(xml, :hexadecimal)
    .gsub(/&#x3e;/, ">").gsub(/&#xa;/, "\n")
    .gsub(/&#x22;/, '"').gsub(/&#x3c;/, "<")
    .gsub(/&#x26;/, "&").gsub(/&#x27;/, "'")
    .gsub(/\\u(....)/) do |_s|
    "&#x#{$1.downcase};"
  end
end

def strip_guid(xml)
  xml.gsub(%r{ id="_[^"]+"}, ' id="_"')
    .gsub(%r{ id="(ftn|fn:)_[^"]+"}, ' id="fn:_"')
    .gsub(%r{ semx-id="[^"]*"}, '')
    .gsub(%r{ original-id="_[^"]+"}, ' original-id="_"')
    .gsub(%r{ target="_[^"]+"}, ' target="_"')
    .gsub(%r{ source="_[^"]+"}, ' source="_"')
    .gsub(%r{ name="_[^"]+"}, ' name="_"')
    .gsub(%r{ href="#_[^"]+"}, ' href="#_"')
    .gsub(%r{ href="#(fn:|ftn)_[^"]+"}, ' href="#fn:_"')
    .gsub(%r{<fetched>[^<]+</fetched>}, "<fetched/>")
    .gsub(%r{ schema-version="[^"]+"}, "")
end

ASCIIDOC_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:
  :legacy-do-not-insert-missing-sections:

HDR

VALIDATING_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:

HDR

LOCAL_CACHED_ISOBIB_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:
  :local-cache: spec/relatondb

HDR

def boilerplate_read(file, xmldoc)
  conv = Metanorma::Itu::Converter.new(:itu, {})
  conv.init(Asciidoctor::Document.new([]))
  x = conv.boilerplate_isodoc(xmldoc).populate_template(file, nil)
  ret = conv.boilerplate_file_restructure(x)
  ret.to_xml(encoding: "UTF-8", indent: 2,
             save_with: Nokogiri::XML::Node::SaveOptions::AS_XML)
    .gsub(/<(\/)?sections>/, "<\\1boilerplate>")
    #.gsub(/ id="_[^"]+"/, " id='_'")
end

def boilerplate(xmldoc)
  file = File.read(
    File.join(File.dirname(__FILE__), "..", "lib", "metanorma", "itu",
              "boilerplate.adoc"), encoding: "utf-8"
  )
  ret = Nokogiri::XML(boilerplate_read(file, xmldoc))
  ret.root.to_xml(encoding: "UTF-8", indent: 2,
                  save_with: Nokogiri::XML::Node::SaveOptions::AS_XML)
end

def itudoc(lang)
  script = case lang
           when "zh" then "Hans"
           else
             "Latn"
           end
  <<~"INPUT"
             <metanorma xmlns="http://riboseinc.com/isoxml">
             <bibdata type="standard">
             <title language="en" type="main">An ITU Standard</title>
             <title language="fr" type="main">Un Standard ITU</title>
             <docidentifier type="ITU">12345</docidentifier>
             <language>#{lang}</language>
             <script>#{script}</script>
             <keyword>A</keyword>
             <keyword>B</keyword>
             <ext>
             <doctype>recommendation</doctype>
             <flavor>itu</flavor>
             </ext>
             </bibdata>
    <preface>
    <abstract><title>Abstract</title>
    <p>This is an abstract</p>
    </abstract>
    <clause id="A0"><title>History</title>
    <p>history</p>
    </clause>
    <foreword obligation="informative">
       <title>Foreword</title>
       <p id="A">This is a preamble</p>
     </foreword>
      <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
       <title>Introduction Subsection</title>
     </clause>
     </introduction></preface><sections>
     <clause id="D" obligation="normative" type="scope">
       <title>Scope</title>
       <p id="E">Text</p>
     </clause>

     <terms id="I" obligation="normative">
       <term id="J">
       <preferred><expression><name>Term2</name></expression></preferred>
     </term>
     </terms>
     <definitions id="L">
       <dl>
       <dt>Symbol</dt>
       <dd>Definition</dd>
       </dl>
     </definitions>
     <clause id="M" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
       <title>Introduction</title>
     </clause>
     <clause id="O" inline-header="false" obligation="normative">
       <title>Clause 4.2</title>
     </clause></clause>

     </sections><annex id="P" inline-header="false" obligation="normative">
       <title>Annex</title>
       <clause id="Q" inline-header="false" obligation="normative">
       <title>Annex A.1</title>
       <clause id="Q1" inline-header="false" obligation="normative">
       <title>Annex A.1a</title>
       </clause>
     </clause>
     </annex><bibliography><references id="R" obligation="informative" normative="true">
       <title>References</title>
     </references><clause id="S" obligation="informative">
       <title>Bibliography</title>
       <references id="T" obligation="informative" normative="false">
       <title>Bibliography Subsection</title>
     </references>
     </clause>
     </bibliography>
     </metanorma>
  INPUT
end

BLANK_HDR = <<~"HDR".freeze
  <?xml version="1.0" encoding="UTF-8"?>
  <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" version="#{Metanorma::Itu::VERSION}" flavor="itu">
  <bibdata type="standard">
   <title language="en" type="main">Document title</title>

    <contributor>
      <role type="author"/>
      <organization>
        <name>International Telecommunication Union</name>
        <abbreviation>ITU</abbreviation>
      </organization>
    </contributor>
    <contributor>
      <role type="publisher"/>
      <organization>
        <name>International Telecommunication Union</name>
        <abbreviation>ITU</abbreviation>
      </organization>
    </contributor>

    <language>en</language>
    <script>Latn</script>
   <status>
           <stage>published</stage>
   </status>

    <copyright>
      <from>#{Time.new.year}</from>
      <owner>
        <organization>
        <name>International Telecommunication Union</name>
        <abbreviation>ITU</abbreviation>
        </organization>
      </owner>
    </copyright>
    <ext>
           <doctype>recommendation</doctype>
             <flavor>itu</flavor>
             <studyperiod>
             <start>#{Date.today.year - (Date.today.year % 2)}</start>
             <end>#{Date.today.year - (Date.today.year % 2) + 2}</end>
             </studyperiod>
           <ip-notice-received>false</ip-notice-received>
   </ext>
  </bibdata>
                     <metanorma-extension>
            <semantic-metadata>
         <stage-published>true</stage-published>
      </semantic-metadata>
            <presentation-metadata>
         <document-scheme>current</document-scheme>
         <toc-heading-levels>2</toc-heading-levels>
         <html-toc-heading-levels>2</html-toc-heading-levels>
         <doc-toc-heading-levels>2</doc-toc-heading-levels>
         <pdf-toc-heading-levels>2</pdf-toc-heading-levels>
            </presentation-metadata>
          </metanorma-extension>
HDR

def blank_hdr_gen
  <<~"HDR"
    #{BLANK_HDR}
    #{boilerplate(Nokogiri::XML("#{BLANK_HDR}</metanorma>"))}
  HDR
end

HTML_HDR = <<~HDR.freeze
  <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US" class="container">
  <div class="title-section">
    <p>&#160;</p>
  </div>
  <br/>
  <div class="prefatory-section">
    <p>&#160;</p>
  </div>
  <br/>
  <div class="main-section">
      <br/>
    <div class="TOC" id="_">
      <h1 class="IntroTitle">Table of Contents</h1>
    </div>
HDR

def mock_pdf
  allow(Mn2pdf).to receive(:convert) do |url, output, _c, _d|
    FileUtils.cp(url.gsub(/"/, ""), output.gsub(/"/, ""))
  end
end

def mock_year(year)
  allow(Date).to receive(:today)
    .and_return(Date.parse("#{year}-02-01"))
end

def current_study_period
  yr = Date.today.year - (Date.today.year % 2)
  "<period><start>#{yr}</start><end>#{yr + 2}</end></period>"
end

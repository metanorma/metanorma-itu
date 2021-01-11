require "vcr"
  
VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
  config.default_cassette_options = {
    clean_outdated_http_interactions: true,
    re_record_interval: 1512000,
    record: :once,
  }
end

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "bundler/setup"
require "asciidoctor"
require "metanorma-itu"
require "asciidoctor/itu"
require "isodoc/itu/html_convert"
require "asciidoctor/standoc/converter"
require "rspec/matchers"
require "equivalent-xml"
require "htmlentities"
require "metanorma"
require "metanorma/itu"
require "rexml/document"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def metadata(x)
  Hash[x.sort].delete_if{ |k, v| v.nil? || v.respond_to?(:empty?) && v.empty? }
end

def htmlencode(x)
  HTMLEntities.new.encode(x, :hexadecimal).gsub(/&#x3e;/, ">").gsub(/&#xa;/, "\n").
    gsub(/&#x22;/, '"').gsub(/&#x3c;/, "<").gsub(/&#x26;/, '&').gsub(/&#x27;/, "'").
    gsub(/\\u(....)/) { |s| "&#x#{$1.downcase};" }
end

def strip_guid(x)
  x.gsub(%r{ id="_[^"]+"}, ' id="_"').gsub(%r{ target="_[^"]+"}, ' target="_"')
end

def xmlpp(x)
  s = ""
  f = REXML::Formatters::Pretty.new(2)
  f.compact = true
  f.write(REXML::Document.new(x),s)
  s
end

ASCIIDOC_BLANK_HDR = <<~"HDR"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :legacy-do-not-insert-missing-sections:

HDR

VALIDATING_BLANK_HDR = <<~"HDR"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:

HDR

def boilerplate(xmldoc)
  file = File.read(File.join(File.dirname(__FILE__), "..", "lib", "asciidoctor", "itu", "boilerplate.xml"), encoding: "utf-8")
  conv = Asciidoctor::ITU::Converter.new(nil, backend: :itu, header_footer: true)
  conv.init(Asciidoctor::Document.new [])
  ret = Nokogiri::XML(
    conv.boilerplate_isodoc(xmldoc).populate_template(file, nil).
    gsub(/<p>/, "<p id='_'>").
    gsub(/<ol>/, "<ol id='_'>"))
  conv.smartquotes_cleanup(ret)
  HTMLEntities.new.decode(ret.to_xml)
end

BLANK_HDR = <<~"HDR"
       <?xml version="1.0" encoding="UTF-8"?>
       <itu-standard xmlns="https://www.metanorma.org/ns/itu" type="semantic" version="#{Metanorma::ITU::VERSION}">
       <bibdata type="standard">
        <title language="en" format="text/plain" type="main">Document title</title>

         <contributor>
           <role type="author"/>
           <organization>
             <name>International Telecommunication Union</name>
           </organization>
         </contributor>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>International Telecommunication Union</name>
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
             </organization>
           </owner>
         </copyright>
         <ext>
                <doctype>recommendation</doctype>
                <editorialgroup>
                <bureau>T</bureau>
                </editorialgroup>
                <ip-notice-received>false</ip-notice-received>
        </ext>
       </bibdata>
HDR

def blank_hdr_gen
<<~"HDR"
#{BLANK_HDR}
#{boilerplate(Nokogiri::XML(BLANK_HDR + "</itu-standard>"))}
HDR
end

HTML_HDR = <<~"HDR"
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
HDR

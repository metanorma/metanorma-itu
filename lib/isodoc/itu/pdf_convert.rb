require "isodoc"
require_relative "metadata"
require "fileutils"

module IsoDoc
  module ITU
    # A {Converter} implementation that generates PDF HTML output, and a
    # document schema encapsulation of the document for validation
    class PdfConvert < IsoDoc::PdfConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        @hierarchical_assets = options[:hierarchical_assets]
        super
      end

      def html_toc(docxml)
        docxml
      end

      def default_fonts(options)
        {
          bodyfont: (options[:script] == "Hans" ? '"SimSun",serif' : '"Open Sans",sans-serif'),
          headerfont: (options[:script] == "Hans" ? '"SimHei",sans-serif' : '"Open Sans",sans-serif'),
          monospacefont: '"Space Mono",monospace'
        }
      end

      def default_file_locations(_options)
        {
          htmlstylesheet: html_doc_path("htmlstyle.scss"),
          htmlcoverpage: html_doc_path("html_itu_titlepage.html"),
          htmlintropage: html_doc_path("html_itu_intro.html"),
          scripts_pdf: html_doc_path("scripts.pdf.html"),
        }
      end

      def googlefonts()
        <<~HEAD.freeze
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,300i,400,400i,600,600i,800|Space+Mono:400,700" rel="stylesheet">
        HEAD
      end

      def make_body(xml, docxml)
        body_attr = { lang: "EN-US", link: "blue", vlink: "#954F72", "xml:lang": "EN-US", class: "container" }
        xml.body **body_attr do |body|
          make_body1(body, docxml)
          make_body2(body, docxml)
          make_body3(body, docxml)
        end
      end

      def make_body3(body, docxml)
        body.div **{ class: "main-section" } do |div3|
          boilerplate docxml, div3
          abstract docxml, div3
          preface docxml, div3
          middle docxml, div3
          footnotes div3
          comments div3
        end
      end

       def html_preface(docxml)
        super
        authority_cleanup(docxml)
        docxml     
      end

       def authority_cleanup(docxml)
         dest = docxml.at("//div[@class = 'draft-warning']")
         auth = docxml.at("//div[@id = 'draft-warning']")
         auth&.xpath(".//h1 | .//h2")&.each { |h| h["class"] = "IntroTitle" }
         dest and auth and dest.replace(auth.remove)
         %w(copyright license legal).each do |t|
           dest = docxml.at("//div[@id = '#{t}']")
           auth = docxml.at("//div[@class = '#{t}']")
           auth&.xpath(".//h1 | .//h2")&.each { |h| h["class"] = "IntroTitle" }
           dest and auth and dest.replace(auth.remove)
         end
       end

      include BaseConvert
    end
  end
end

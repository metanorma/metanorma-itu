require "isodoc"
require_relative "metadata"
require "fileutils"

module IsoDoc
  module ITU

    # A {Converter} implementation that generates HTML output, and a document
    # schema encapsulation of the document for validation
    #
    class HtmlConvert < IsoDoc::HtmlConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      def convert1(docxml, filename, dir)
        FileUtils.cp html_doc_path('Logo_ITU.jpg'), "#{@localdir}/Logo_ITU.jpg"
        @files_to_delete << "#{@localdir}/Logo_ITU.jpg"
        super
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
          scripts: html_doc_path("scripts.html"),
        }
      end

      def googlefonts
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
          abstract docxml, div3
          preface docxml, div3
          middle docxml, div3
          footnotes div3
          comments div3
        end
      end

      include BaseConvert
    end
  end
end

require "metanorma/processor"

module Metanorma
  module ITU
    def self.fonts_used
      {
        html: ["Arial", "Courier New", "Times New Roman"],
        doc: ["Arial", "Courier New", "Times New Roman"],
        pdf: ["Arial", "Courier New", "Times New Roman"]
      }
    end

    class Processor < Metanorma::Processor

      def initialize
        @short = :itu
        @input_format = :asciidoc
        @asciidoctor_backend = :itu
      end

      def output_formats
        super.merge(
          html: "html",
          doc: "doc",
          pdf: "pdf"
        )
      end

      def version
        "Metanorma::ITU #{Metanorma::ITU::VERSION}"
      end

      def input_to_isodoc(file, filename)
        Metanorma::Input::Asciidoc.new.process(file, filename, @asciidoctor_backend)
      end

      def output(isodoc_node, inname, outname, format, options={})
        case format
        when :html
          IsoDoc::ITU::HtmlConvert.new(options).convert(inname, isodoc_node, nil, outname)
        when :doc
          IsoDoc::ITU::WordConvert.new(options).convert(inname, isodoc_node, nil, outname)
        when :pdf
          IsoDoc::ITU::PdfConvert.new(options).convert(inname, isodoc_node, nil, outname)
        when :presentation
          IsoDoc::ITU::PresentationXMLConvert.new(options).convert(inname, isodoc_node, nil, outname)
        else
          super
        end
      end
    end
  end
end

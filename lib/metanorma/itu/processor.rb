require "metanorma/processor"

module Metanorma
  module ITU
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
        "Metanorma::Acme #{Metanorma::ITU::VERSION}"
      end

      def input_to_isodoc(file, filename)
        Metanorma::Input::Asciidoc.new.process(file, filename, @asciidoctor_backend)
      end

      def output(isodoc_node, outname, format, options={})
        case format
        when :html
          IsoDoc::ITU::HtmlConvert.new(options).convert(outname, isodoc_node)
        when :doc
          IsoDoc::ITU::WordConvert.new(options).convert(outname, isodoc_node)
        when :pdf
          IsoDoc::ITU::PdfConvert.new(options).convert(outname, isodoc_node)
        else
          super
        end
      end
    end
  end
end

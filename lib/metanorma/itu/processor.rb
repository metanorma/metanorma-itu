require "metanorma/processor"

module Metanorma
  module Itu
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
          pdf: "pdf",
        )
      end

      def fonts_manifest
        {
          "Arial" => nil,
          "Courier New" => nil,
          "Times New Roman" => nil,
          "Source Han Sans" => nil,
          "Source Han Sans Normal" => nil,
          "STIX Two Math" => nil,
        }
      end

      def version
        "Metanorma::Itu #{Metanorma::Itu::VERSION}"
      end

      def output(isodoc_node, inname, outname, format, options = {})
        options_preprocess(options)
        case format
        when :html
          IsoDoc::Itu::HtmlConvert.new(options).convert(inname, isodoc_node,
                                                        nil, outname)
        when :doc
          IsoDoc::Itu::WordConvert.new(options).convert(inname, isodoc_node,
                                                        nil, outname)
        when :pdf
          IsoDoc::Itu::PdfConvert.new(options).convert(inname, isodoc_node,
                                                       nil, outname)
        when :presentation
          IsoDoc::Itu::PresentationXMLConvert.new(options).convert(
            inname, isodoc_node, nil, outname
          )
        else
          super
        end
      end
    end
  end
end

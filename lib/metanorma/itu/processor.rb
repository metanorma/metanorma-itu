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
        "Metanorma::ITU #{Metanorma::ITU::VERSION}"
      end

      def output(isodoc_node, inname, outname, format, options={})
        options_preprocess(options)
        case format
        when :html
          IsoDoc::ITU::HtmlConvert.new(options).convert(inname, isodoc_node, 
                                                        nil, outname)
        when :doc
          IsoDoc::ITU::WordConvert.new(options).convert(inname, isodoc_node, 
                                                        nil, outname)
        when :pdf
          IsoDoc::ITU::PdfConvert.new(options).convert(inname, isodoc_node, 
                                                       nil, outname)
        when :presentation
          IsoDoc::ITU::PresentationXMLConvert.new(options).convert(
            inname, isodoc_node, nil, outname)
        else
          super
        end
      end
    end
  end
end

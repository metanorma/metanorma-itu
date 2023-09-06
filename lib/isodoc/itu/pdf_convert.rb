require "isodoc"
require "fileutils"

module IsoDoc
  module ITU
    # A {Converter} implementation that generates PDF HTML output, and a
    # document schema encapsulation of the document for validation
    class PdfConvert < IsoDoc::XslfoPdfConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        @hierarchical_assets = options[:hierarchicalassets]
        super
      end

      def pdf_stylesheet(_docxml)
        if File.exist?(File.join(@libdir, "itu.#{@doctype}.xsl"))
          "itu.#{doctype}.xsl"
        else
          "itu.recommendation.xsl"
        end
      end
    end
  end
end

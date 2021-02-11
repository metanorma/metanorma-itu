require "isodoc"
require "fileutils"

module IsoDoc
  module ITU
    # A {Converter} implementation that generates PDF HTML output, and a
    # document schema encapsulation of the document for validation
    class PdfConvert < IsoDoc::XslfoPdfConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        @hierarchical_assets = options[:hierarchical_assets]
        super
      end

      def pdf_stylesheet(docxml)
        doctype = docxml&.at(ns("//bibdata/ext/doctype"))&.text

        "itu.#{doctype}.xsl" if File.exist?(File.join(@libdir, "itu.#{doctype}.xsl"))

        "itu.recommendation.xsl"
      end
    end
  end
end

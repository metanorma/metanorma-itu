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
        case doctype = docxml&.at(ns("//bibdata/ext/doctype"))&.text
        when "resolution" then "itu.resolution.xsl"
        when "recommendation-annex" then "itu.recommendation-annex.xsl"
        when "recommendation-supplement" then "itu.recommendation-supplement.xsl"
        when "technical-report" then "itu.technical-report.xsl"
        when "technical-paper" then "itu.technical-paper.xsl"
        else
          "itu.recommendation.xsl"
        end
      end
    end
  end
end

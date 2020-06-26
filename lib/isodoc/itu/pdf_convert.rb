require "isodoc"
require_relative "metadata"
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
        else
          "itu.recommendation.xsl"
        end
      end
    end
  end
end

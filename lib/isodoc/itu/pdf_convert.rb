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

      def convert(filename, file = nil, debug = false)
        file = File.read(filename, encoding: "utf-8") if file.nil?
        docxml, outname_html, dir = convert_init(file, filename, debug)
        /\.xml$/.match(filename) or
          filename = Tempfile.open([outname_html, ".xml"], encoding: "utf-8") do |f|
          f.write file
          f.path
        end
        FileUtils.rm_rf dir
        ::Metanorma::Output::XslfoPdf.new.convert(
          filename, outname_html + ".pdf", File.join(@libdir, pdf_stylesheet(docxml)))
      end
    end
  end
end

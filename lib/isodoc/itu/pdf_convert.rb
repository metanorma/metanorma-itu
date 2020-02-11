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

      def convert(filename, file = nil, debug = false)
        file = File.read(filename, encoding: "utf-8") if file.nil?
        docxml, outname_html, dir = convert_init(file, filename, debug)
        resolution = docxml.at(ns("//bibdata/ext[doctype = 'resolution']"))
        FileUtils.rm_rf dir
        ::Metanorma::Output::XslfoPdf.new.convert(
          filename, outname_html + ".pdf",
          File.join(@libdir, resolution ? "itu.resolution.xsl" : "itu.recommendation.xsl"))
      end
    end
  end
end

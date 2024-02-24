require "asciidoctor"
require "metanorma/standoc/converter"
require "fileutils"
require "metanorma-utils"
require_relative "./front"
require_relative "./validate"
require_relative "./cleanup"

module Metanorma
  module ITU
    class Converter < Standoc::Converter
      XML_ROOT_TAG = "itu-standard".freeze
      XML_NAMESPACE = "https://www.metanorma.org/ns/itu".freeze

      register_for "itu"

      def title_validate(_root)
        nil
      end

      def initialize(backend, opts)
        require "debug"; binding.b
        super
      end

      def init(node)
        super
        @smartquotes = node.attr("smartquotes") == "true"
        @no_insert_missing_sections = doctype(node) != "recommendation" ||
          node.attr("legacy-do-not-insert-missing-sections") ||
          node.attr("document-schema") == "legacy"
      end

      def boilerplate_file(_xmldoc)
        File.join(@libdir, "boilerplate.adoc")
      end

      def makexml(node)
        @draft = node.attributes.has_key?("draft")
        super
      end

      def doctype(node)
        ret = node.attr("doctype")&.gsub(/\s+/, "-")&.downcase || "recommendation"
        ret = "recommendation" if ret == "article"
        ret
      end

      def olist(node)
        id = Metanorma::Utils::anchor_or_uuid(node)
        noko do |xml|
          xml.ol **attr_code(id: id, class: node.attr("class")) do |xml_ol|
            list_caption(node, xml_ol)
            node.items.each { |item| li(xml_ol, item) }
          end
        end.join("\n")
      end

      def outputs(node, ret)
        File.open("#{@filename}.xml", "w:UTF-8") { |f| f.write(ret) }
        presentation_xml_converter(node).convert("#{@filename}.xml")
        html_converter(node).convert("#{@filename}.presentation.xml",
                                     nil, false, "#{@filename}.html")
        doc_converter(node).convert("#{@filename}.presentation.xml",
                                    nil, false, "#{@filename}.doc")
        node.attr("no-pdf") or
          pdf_converter(node)&.convert("#{@filename}.presentation.xml",
                                       nil, false, "#{@filename}.pdf")
      end

      def validate(doc)
        content_validate(doc)
        schema_validate(formattedstr_strip(doc.dup),
                        File.join(File.dirname(__FILE__), "itu.rng"))
      end

      def style(_node, _text)
        nil
      end

      def sectiontype_streamline(ret)
        case ret
        when "definitions", "terms defined elsewhere",
          "terms defined in this recommendation"
          "terms and definitions"
        when "abbreviations and acronyms" then "symbols and abbreviated terms"
        when "references" then "normative references"
        else
          super
        end
      end

      def sectiontype(node, level = true)
        ret = super
        hdr = sectiontype_streamline(node&.attr("heading")&.downcase)
        return nil if ret == "terms and definitions" &&
          hdr != "terms and definitions" && node.level > 1
        return nil if ret == "symbols and abbreviated terms" &&
          hdr != "symbols and abbreviated terms" && node.level > 1

        ret
      end

      def term_def_subclause_parse(attrs, xml, node)
        case sectiontype1(node)
        when "terms defined in this recommendation"
          term_def_parse(attrs.merge(type: "internal"), xml, node, false)
        when "terms defined elsewhere"
          term_def_parse(attrs.merge(type: "external"), xml, node, false)
        else
          super
        end
      end

      def metadata_keywords(node, xml)
        return unless node.attr("keywords")

        node.attr("keywords").split(/, */).sort.each_with_index do |kw, i|
          kw_out = i.zero? ? Metanorma::Utils.strict_capitalize_first(kw) : kw
          xml.keyword kw_out
        end
      end

      def clause_parse(attrs, xml, node)
        node.option?("unnumbered") and attrs[:unnumbered] = true
        case sectiontype1(node)
        when "conventions" then attrs = attrs.merge(type: "conventions")
        when "history"
          attrs[:preface] and attrs = attrs.merge(type: "history")
        when "source"
          attrs[:preface] and attrs = attrs.merge(type: "source")
        end
        super
      end

      def html_extract_attributes(node)
        super.merge(hierarchicalassets:
                    node.attr("hierarchical-object-numbering"))
      end

      def doc_extract_attributes(node)
        super.merge(hierarchicalassets:
                    node.attr("hierarchical-object-numbering"))
      end

      def presentation_xml_converter(node)
        IsoDoc::ITU::PresentationXMLConvert
          .new(html_extract_attributes(node)
          .merge(output_formats: ::Metanorma::ITU::Processor.new.output_formats))
      end

      def html_converter(node)
        IsoDoc::ITU::HtmlConvert.new(html_extract_attributes(node))
      end

      def pdf_converter(node)
        IsoDoc::ITU::PdfConvert.new(pdf_extract_attributes(node))
      end

      def doc_converter(node)
        IsoDoc::ITU::WordConvert.new(doc_extract_attributes(node))
      end
    end
  end
end

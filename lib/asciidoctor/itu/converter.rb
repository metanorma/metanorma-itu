require "asciidoctor"
require "asciidoctor/standoc/converter"
require "fileutils"

module Asciidoctor
  module ITU

    # A {Converter} implementation that generates RSD output, and a document
    # schema encapsulation of the document for validation
    #
    class Converter < Standoc::Converter

      register_for "itu"

      def metadata_author(node, xml)
        xml.contributor do |c|
          c.role **{ type: "author" }
          c.organization do |a|
            a.name "International Telecommunication Union"
            a.abbreviation "ITU"
          end
        end
      end

      def metadata_publisher(node, xml)
        xml.contributor do |c|
          c.role **{ type: "publisher" }
          c.organization do |a|
            a.name "International Telecommunication Union"
            a.abbreviation "ITU"
          end
        end
      end

      def metadata_committee(node, xml)
        xml.editorialgroup do |a|
          a.bureau ( node.attr("bureau") || "T" )
          a.committee node.attr("committee"),
            **attr_code(type: node.attr("committee-type"))
          i = 2
          while node.attr("committee_#{i}") do
            a.committee node.attr("committee_#{i}"),
              **attr_code(type: node.attr("committee-type_#{i}"))
            i += 1
          end
        end
      end

      def metadata_status(node, xml)
        xml.status(**{ format: "plain" }) { |s| s << node.attr("status") }
      end

      def metadata_id(node, xml)
        bureau = node.attr("bureau") || "T"
        return unless node.attr("docnumber")
        xml.docidentifier do |i|
          i << "ITU-#{bureau} "\
            "#{node.attr("docnumber")}"
        end
        xml.docnumber { |i| i << node.attr("docnumber") }
      end

      def metadata_copyright(node, xml)
        from = node.attr("copyright-year") || Date.today.year
        xml.copyright do |c|
          c.from from
          c.owner do |owner|
            owner.organization do |o|
              o.name "International Telecommunication Union"
              o.abbreviation "ITU"
            end
          end
        end
      end

      def metadata_series(node, xml)
        node.attr("series") and
          xml.series **{ type: "main" } do |s|
          s.title node.attr("series")
        end
        node.attr("series1") and
          xml.series **{ type: "secondary" } do |s|
          s.title node.attr("series1")
        end
        node.attr("series2") and
          xml.series **{ type: "tertiary" } do |s|
          s.title node.attr("series2")
        end
      end

      def metadata_keywords(node, xml)
        return unless node.attr("keywords")
        node.attr("keywords").split(/,[ ]*/).each do |kw|
          xml.keyword kw
        end
      end

      def metadata(node, xml)
        super
        metadata_series(node, xml)
        metadata_keywords(node, xml)
      end

      def title_validate(root)
        nil
      end

      def makexml(node)
        result = ["<?xml version='1.0' encoding='UTF-8'?>\n<itu-standard>"]
        @draft = node.attributes.has_key?("draft")
        result << noko { |ixml| front node, ixml }
        result << noko { |ixml| middle node, ixml }
        result << "</itu-standard>"
        result = textcleanup(result)
        ret1 = cleanup(Nokogiri::XML(result))
        validate(ret1)
        ret1.root.add_namespace(nil, Metanorma::ITU::DOCUMENT_NAMESPACE)
        ret1
      end

      def doctype(node)
        d = node.attr("doctype")
        unless %w{policy-and-procedures best-practices supporting-document report legal directives proposal standard}.include? d
          warn "#{d} is not a legal document type: reverting to 'standard'"
          d = "standard"
        end
        d
      end

            def clause_parse(attrs, xml, node)
        attrs[:preface] = true if node.attr("style") == "preface"
        super
      end

      def move_sections_into_preface(x, preface)
        x.xpath("//clause[@preface]").each do |c|
          c.delete("preface")
          preface.add_child c.remove
        end
      end

      def make_preface(x, s)
        make_abstract(x, s)
          move_sections_into_preface(x, preface)
      end

      def document(node)
        init(node)
        ret1 = makexml(node)
        ret = ret1.to_xml(indent: 2)
        unless node.attr("nodoc") || !node.attr("docfile")
          filename = node.attr("docfile").gsub(/\.adoc/, ".xml").
            gsub(%r{^.*/}, "")
          File.open(filename, "w") { |f| f.write(ret) }
          html_converter(node).convert filename unless node.attr("nodoc")
          word_converter(node).convert filename unless node.attr("nodoc")
          pdf_converter(node).convert filename unless node.attr("nodoc")
        end
        @files_to_delete.each { |f| FileUtils.rm f }
        ret
      end

      def validate(doc)
        content_validate(doc)
        schema_validate(formattedstr_strip(doc.dup),
                        File.join(File.dirname(__FILE__), "acme.rng"))
      end

      def html_path_acme(file)
        File.join(File.dirname(__FILE__), File.join("html", file))
      end

      def sections_cleanup(x)
        super
        x.xpath("//*[@inline-header]").each do |h|
          h.delete("inline-header")
        end
      end

      def style(n, t)
        return
      end

      def html_converter(node)
        IsoDoc::ITU::HtmlConvert.new(html_extract_attributes(node))
      end

      def pdf_converter(node)
        IsoDoc::ITU::PdfConvert.new(html_extract_attributes(node))
      end

      def word_converter(node)
        IsoDoc::ITU::WordConvert.new(doc_extract_attributes(node))
      end
    end
  end
end

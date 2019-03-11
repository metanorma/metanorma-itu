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

      def title_english(node, xml)
        ["en"].each do |lang|
          at = { language: lang, format: "text/plain", 
                 type: node.attr("provisional-name") ? "provisional" : "main" }
          xml.title **attr_code(at) do |t|
            t << asciidoc_sub(node.attr("title") || node.attr("title-en") || node.title)
          end
        end
      end

      def title_otherlangs(node, xml)
        node.attributes.each do |k, v|
          next unless /^title-(?<titlelang>.+)$/ =~ k
          next if titlelang == "en"
          xml.title v, { language: titlelang, format: "text/plain",
                         type: node.attr("provisional-name") ? "provisional" : "main" }
        end
      end

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
        metadata_committee1(node, xml, "")
        suffix = 2
        while node.attr("bureau_#{suffix}")
          metadata_committee1(node, xml, "_#{suffix}")
        end
      end

      def metadata_committee1(node, xml, suffix)
        xml.editorialgroup do |a|
          a.bureau ( node.attr("bureau#{suffix}") || "T" )
          a.group **attr_code(type: node.attr("grouptype#{suffix}")) do |g|
            g.name node.attr("group#{suffix}")
            g.acronym node.attr("groupacronym#{suffix}") if node.attr("groupacronym#{suffix}")
            if node.attr("groupyearstart#{suffix}")
              g.period do |p|
                period.start node.attr("groupyearstart#{suffix}")
                period.end node.attr("groupyearend#{suffix}") if node.attr("groupacronym#{suffix}")
              end
            end
          end
          if node.attr("subgroup#{suffix}")
            a.subgroup **attr_code(type: node.attr("subgrouptype#{suffix}")) do |g|
              g.name node.attr("subgroup#{suffix}")
              g.acronym node.attr("subgroupacronym#{suffix}") if node.attr("subgroupacronym#{suffix}")
              if node.attr("subgroupyearstart#{suffix}")
                g.period do |p|
                  period.start node.attr("subgroupyearstart#{suffix}")
                  period.end node.attr("subgroupyearend#{suffix}") if node.attr("subgroupyearend#{suffix}")
                end
              end
            end
          end
          if node.attr("workgroup#{suffix}")
            a.workgroup **attr_code(type: node.attr("workgrouptype#{suffix}")) do |g|
              g.name node.attr("workgroup#{suffix}")
              g.acronym node.attr("workgroupacronym#{suffix}") if node.attr("workgroupacronym#{suffix}")
              if node.attr("workgroupyearstart#{suffix}")
                g.period do |p|
                  period.start node.attr("workgroupyearstart#{suffix}")
                  period.end node.attr("workgroupyearend#{suffix}") if node.attr("wokrgroupyearend#{suffix}")
                end
              end
            end
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

      def metadata_provisionalname(node, xml)
        return unless node.attr("provisional-name")
        xml.provisionalname node.attr("provisional-name")
      end

      def metadata_keywords(node, xml)
        return unless node.attr("keywords")
        node.attr("keywords").split(/,[ ]*/).each do |kw|
          xml.keyword kw
        end
      end

      def metadata_recommendationstatus(node, xml)
        return unless node.attr("recommendation-from")
        xml.recommendationstatus do |s|
          s.from node.attr("recommendation-from")
          s.to node.attr("recommendation-to") if node.attr("recommendation-to")
          if node.attr("approval-process")
            s.approvalstage **{process: node.attr("approval-process")} do |a|
              a << node.attr("approval-status")
            end
          end
        end
      end

      def metadata(node, xml)
        super
        metadata_series(node, xml)
        metadata_provisionalname(node, xml)
        metadata_keywords(node, xml)
        metadata_recommendationstatus(node, xml)
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
        node.attr("doctype") || "recommendation"
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
        move_sections_into_preface(x, x.at("//preface"))
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
                        File.join(File.dirname(__FILE__), "itu.rng"))
      end

      def content_validate(doc)
        super
        approval_validate(doc)
      end

      def approval_validate(xmldoc)
        s = xmldoc.at("//bibdata/recommendationstatus") || return
        process = s.at("./@process").text
        if process == "aap" and %w(determined in-force).include? s.text
          warn "Recommendation Status #{s.text} inconsistent with AAP"
        end
        if process == "tap" and !%w(determined in-force).include? s.text
          warn "Recommendation Status #{s.text} inconsistent with TAP"
        end
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

      def section(node)
        a = { id: Asciidoctor::Standoc::Utils::anchor_or_uuid(node) }
        noko do |xml|
          case sectiontype(node)
          when "references" then norm_ref_parse(a, xml, node)
          when "terms and definitions",
            "terms, definitions, symbols and abbreviated terms",
            "terms, definitions, symbols and abbreviations",
            "terms, definitions and symbols",
            "terms, definitions and abbreviations",
            "terms, definitions and abbreviated terms",
            "definitions"
            @term_def = true
            term_def_parse(a, xml, node, true)
            @term_def = false
          when "symbols and abbreviated terms",
            "symbols",
            "abbreviated terms",
            "abbreviations"
            "abbreviations and acronyms"
            symbols_parse(a, xml, node)
          when "bibliography" then bibliography_parse(a, xml, node)
          else
            if @term_def then term_def_subclause_parse(a, xml, node)
            elsif @definitions then symbols_parse(a, xml, node)
            elsif @biblio then bibliography_parse(a, xml, node)
            elsif node.attr("style") == "bibliography"
              bibliography_parse(a, xml, node)
            elsif node.attr("style") == "abstract"
              abstract_parse(a, xml, node)
            elsif node.attr("style") == "appendix" && node.level == 1
              annex_parse(a, xml, node)
            else
              clause_parse(a, xml, node)
            end
          end
        end.join("\n")
      end

      def norm_ref_parse(attrs, xml, node)
        @norm_ref = true
        xml.references **attr_code(attrs) do |xml_section|
          xml_section.title { |t| t << "References" }
          xml_section << node.content
        end
        @norm_ref = false
      end

      def term_def_title(toplevel, node)
        return node.title unless toplevel
        "Definitions"
      end

      def termdef_cleanup(xmldoc)
        xmldoc.xpath("//term/preferred").each do |p|
          if ["terms defined elsewhere", "terms defined in this recommendation"].include? p.text.downcase
            p.name = "title"
            p.parent.name = "terms"
          end
        end
        super
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

require "asciidoctor"
require "asciidoctor/standoc/converter"
require "fileutils"

module Asciidoctor
  module ITU
    class Converter < Standoc::Converter
      def metadata_status(node, xml)
        xml.status do |s|
          s.stage (node.attributes.has_key?("draft") ? "draft" :
                   (node.attr("status") || node.attr("docstage") ||
                    "published" ))
        end
      end

      def title_english(node, xml)
        at = { language: "en", format: "text/plain", type: "main" }
        a = node.attr("title") || node.attr("title-en")
        xml.title **attr_code(at) do |t|
          t << (Asciidoctor::Standoc::Utils::asciidoc_sub(a) || node.title)
        end
        if a = node.attr("annextitle") || node.attr("annextitle-en")
          at[:type] = "annex"
          xml.title **attr_code(at) do |t|
            t << Asciidoctor::Standoc::Utils::asciidoc_sub(a)
          end
        end
      end

      def title_otherlangs(node, xml)
        node.attributes.each do |k, v|
          next unless /^(annex)?title-(?<lang>.+)$/ =~ k
          next if lang == "en"
          type = /^annex/.match(k) ? "annex" : "main"
          xml.title **attr_code(language: lang, format: "text/plain",
                                type: type) do |t|
            t << v
          end
        end
      end

      def title(node, xml)
        super
        subtitle_english(node, xml)
        subtitle_otherlangs(node, xml)
      end

      def subtitle_english(node, xml)
        at = { language: "en", format: "text/plain", type: "subtitle" }
        a = node.attr("subtitle") || node.attr("subtitle-en")
        xml.title **attr_code(at) do |t|
          t << Asciidoctor::Standoc::Utils::asciidoc_sub(a)
        end
      end

      def subtitle_otherlangs(node, xml)
        node.attributes.each do |k, v|
          next unless /^subtitle-(?<lang>.+)$/ =~ k
          next if lang == "en"
          xml.title **attr_code(language: lang, format: "text/plain",
                                type: "subtitle") do |t|
            t << v
          end
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
          suffix += 1
        end
      end

      def metadata_committee1(node, xml, suffix)
        xml.editorialgroup do |a|
          a.bureau ( node.attr("bureau#{suffix}") || "T" )
          if node.attr("group#{suffix}")
            a.group **attr_code(type: node.attr("grouptype#{suffix}")) do |g|
              metadata_committee2(node, g, suffix, "")
            end
          end
          if node.attr("subgroup#{suffix}")
            a.subgroup **attr_code(type: node.attr("subgrouptype#{suffix}")) do |g|
              metadata_committee2(node, g, suffix, "sub")
            end
          end
          if node.attr("workgroup#{suffix}")
            a.workgroup **attr_code(type: node.attr("workgrouptype#{suffix}")) do |g|
              metadata_committee2(node, g, suffix, "work")
            end
          end
        end
      end

      def metadata_committee2(node, g, suffix, prefix)
        g.name node.attr("#{prefix}group#{suffix}")
        node.attr("#{prefix}groupacronym#{suffix}") and
          g.acronym node.attr("#{prefix}groupacronym#{suffix}")
        if node.attr("#{prefix}groupyearstart#{suffix}")
          g.period do |p|
            p.start node.attr("#{prefix}groupyearstart#{suffix}")
            node.attr("#{prefix}groupacronym#{suffix}") and
              p.end node.attr("#{prefix}groupyearend#{suffix}")
          end
        end
      end

      def metadata_id(node, xml)
        provisional_id(node, xml)
        itu_id(node, xml)
      end

      def provisional_id(node, xml)
        return unless node.attr("provisional-name")
        xml.docidentifier **{type: "ITU-provisional"} do |i|
          i << node.attr("provisional-name")
        end
      end

      def itu_id(node, xml)
        bureau = node.attr("bureau") || "T"
        return unless node.attr("docnumber")
        xml.docidentifier **{type: "ITU"} do |i|
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

      def metadata_ip_notice(node, xml)
        xml.ip_notice_received (node.attr("ip-notice-received") || "false")
      end

      def structured_id(node, xml)
        return unless node.attr("docnumber")
        xml.structuredidentifier do |i|
          i.bureau node.attr("bureau") || "T"
          i.docnumber node.attr("docnumber")
          a = node.attr("annexid") and i.annexid a
        end
      end

      def metadata_ext(node, xml)
        metadata_doctype(node, xml)
        metadata_committee(node, xml)
        metadata_ics(node, xml)
        metadata_recommendationstatus(node, xml)
        metadata_ip_notice(node, xml)
        structured_id(node, xml)
      end
    end
  end
end

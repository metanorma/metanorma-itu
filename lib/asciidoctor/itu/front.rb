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
            t << Asciidoctor::Standoc::Utils::asciidoc_sub(v)
          end
        end
      end

      def title(node, xml)
        super
        %w(subtitle amendment-title corrigendum-title).each do |t|
        other_title_english(node, xml, t)
        other_title_otherlangs(node, xml, t)
        end
      end

      def other_title_english(node, xml, type)
        at = { language: "en", format: "text/plain", type: type.sub(/-title/, "") }
        a = node.attr(type) || node.attr("#{type}-en")
        xml.title **attr_code(at) do |t|
          t << Asciidoctor::Standoc::Utils::asciidoc_sub(a)
        end
      end

      def other_title_otherlangs(node, xml, type)
        node.attributes.each do |k, v|
          next unless m = /^#{type}-(?<lang>.+)$/.match(k)
          next if m[:lang] == "en"
          xml.title **attr_code(language: m[:lang], format: "text/plain",
                                type: type.sub(/-title/, "")) do |t|
            t << Asciidoctor::Standoc::Utils::asciidoc_sub(v)
          end
        end
      end

      def default_publisher
        "International Telecommunication Union"
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
        recommendation_id(node, xml)
      end

      def provisional_id(node, xml)
        return unless node.attr("provisional-name")
        xml.docidentifier **{type: "ITU-provisional"} do |i|
          i << node.attr("provisional-name")
        end
      end

      ITULANG = {
        "en" => "E", "fr" => "F", "ar" => "A",
        "es" => "S", "zh" => "C", "ru" => "R"
      }.freeze

      def itu_id1(node, lang)
        bureau = node.attr("bureau") || "T"
        id = if doctype(node) == "service-publication"
               @i18n.annex_to_itu_ob_abbrev.sub(/%/, node.attr("docnumber"))
             else
               "ITU-#{bureau} #{node.attr("docnumber")}"
             end
        id + (lang ? "-#{ITULANG[@lang]}" : "")
      end

      def itu_id(node, xml)
        return unless node.attr("docnumber")
        xml.docidentifier **{type: "ITU"} do |i|
          i << itu_id1(node, false)
        end
        xml.docidentifier **{type: "ITU-lang"} do |i|
          i << itu_id1(node, true)
        end
        xml.docnumber { |i| i << node.attr("docnumber") }
      end

      def recommendation_id(node, xml)
        return unless node.attr("recommendationnumber")
        node.attr("recommendationnumber").split("/").each do |s|
          xml.docidentifier **{type: "ITU-Recommendation"} do |i|
            i << s
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
          a = node.attr("amendment-number") and i.amendment a
          a = node.attr("corrigendum-number") and i.corrigendum a
        end
      end

      # also used in tech paper
      def metadata_techreport(node, xml)
        a = node.attr("meeting") and metadata_meeting(a, node.attr("meeting-acronym"), xml)
        a = node.attr("meeting-place") and xml.meeting_place a
        a = node.attr("meeting-date") and metadata_meeting_date(a, xml)
        a = node.attr("intended-type") and xml.intended_type a
        a = node.attr("source") and xml.source a
      end

      def metadata_meeting(mtg, acronym, xml)
        xml.meeting **attr_code(acronym: acronym) do |m|
          m << mtg
        end
      end

      def metadata_meeting_date(a, xml)
        xml.meeting_date do |m|
          d = a.split("/")
          if d.size > 1
            m.from d[0]
            m.to d[1]
          else
            m.on d[0]
          end
        end
      end

      def personal_role(node, c, suffix)
        if node.attr("role#{suffix}")&.downcase == "rapporteur"
          c.role "raporteur", **{ type: "editor" }
        else
          super
        end
      end

      def metadata_ext(node, xml)
        metadata_doctype(node, xml)
        metadata_committee(node, xml)
        metadata_ics(node, xml)
        metadata_recommendationstatus(node, xml)
        metadata_ip_notice(node, xml)
        metadata_techreport(node, xml)
        structured_id(node, xml)
      end
    end
  end
end

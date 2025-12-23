require "fileutils"
require_relative "./front_id"
require_relative "./front_contrib"

module Metanorma
  module Itu
    class Converter < Standoc::Converter
      def metadata_status(node, xml)
        stage = node.attr("status") || node.attr("docstage") || "published"
        stage = "draft" if node.attributes.has_key?("draft")
        xml.status do |s|
          add_noko_elem(s, "stage", stage)
        end
      end

      def relaton_relations
        super + %w(complements)
      end

      def title_defaultlang(node, xml)
        a = node.attr("title") || node.attr("title-#{@lang}") or return
        add_title_xml(xml, a, @lang, "main")
        if a = node.attr("annextitle") || node.attr("annextitle-#{@lang}")
          add_title_xml(xml, a, @lang, "annex")
        end
        title_nums(node, xml, @lang)
      end

      def title_otherlangs(node, xml)
        node.attributes.each do |k, v|
          /^(?:annex)?title-(?<lang>.+)$/ =~ k or next
          lang == @lang and next
          type = /^annex/.match?(k) ? "annex" : "main"
          add_title_xml(xml, v, lang, type)
          title_nums(node, xml, lang)
        end
      end

      def title(node, xml)
        title_defaultlang(node, xml)
        title_otherlangs(node, xml)
        title_fallback(node, xml)
        %w(subtitle amendment-title corrigendum-title collection-title
           slogan-title).each do |t|
          other_title_defaultlang(node, xml, t)
          other_title_otherlangs(node, xml, t)
        end
      end

      def other_title_defaultlang(node, xml, type)
        a = node.attr(type) || node.attr("#{type}-#{@lang}")
        add_title_xml(xml, a, @lang, type.sub(/-title/, ""))
      end

      def other_title_otherlangs(node, xml, type)
        node.attributes.each do |k, v|
          m = /^#{type}-(?<lang>.+)$/.match(k) or next
          m[:lang] == @lang and next
          add_title_xml(xml, v, m[:lang], type.sub(/-title/, ""))
        end
      end

      def metadata_question(node, xml)
        vals = csv_split(node.attr("question"), ",").map do |s1|
          t, v = s1.split(":", 2).map(&:strip)
          { id: t, value: v }
        end
        vals.each do |v|
          xml.question do |q|
            add_noko_elem(q, "identifier", v[:id])
            # q.identifier a
            add_noko_elem(q, "name", v[:value]) # q.name a
          end
        end
      end

      def group_period(node, prefix, suffix)
        s = node.attr("#{prefix}group-year-start#{suffix}") ||
          Date.today.year - (Date.today.year % 2)
        e = node.attr("#{prefix}group-year-end#{suffix}") || s.to_i + 2
        [s, e]
      end

      def metadata_series(node, xml)
        { series: "main", series1: "secondary", series2: "tertiary" }
          .each do |k, v|
          node.attr(k.to_s) and
            xml.series **{ type: v } do |s|
              add_noko_elem(s, "title", node.attr(k.to_s))
            end
        end
      end

      def metadata_recommendationstatus(node, xml)
        node.attr("recommendation-from") || node.attr("approval-process") or
          return
        xml.recommendationstatus do |s|
          add_noko_elem(s, "from", node.attr("recommendation-from"))
          add_noko_elem(s, "to", node.attr("recommendation-to"))
          node.attr("approval-process") and
            add_noko_elem(s, "approvalstage", node.attr("approval-status"),
                          process: node.attr("approval-process"))
          # s.approvalstage **{ process: node.attr("approval-process") } do |x|
          #  x << node.attr("approval-status")
          # end
        end
      end

      def metadata_ip_notice(node, xml)
        add_noko_elem(xml, "ip-notice-received",
                      node.attr("ip-notice-received") || "false")
        # xml.ip_notice_received (node.attr("ip-notice-received") || "false")
      end

      def metadata_techreport(node, xml)
        a = node.attr("meeting") and
          metadata_meeting(a, node.attr("meeting-acronym"), xml)
        add_noko_elem(xml, "meeting_place", node.attr("meeting-place"))
        # a = node.attr("meeting-place") and xml.meeting_place a
        a = node.attr("meeting-date") and metadata_meeting_date(a, xml)
        add_noko_elem(xml, "intended_type", node.attr("intended-type"))
        # a = node.attr("intended-type") and xml.intended_type a
        add_noko_elem(xml, "source", node.attr("source"))
        # a = node.attr("source") and xml.source a
      end

      def metadata_meeting(mtg, acronym, xml)
        add_noko_elem(xml, "meeting", mtg, acronym: acronym)
        # xml.meeting **attr_code(acronym: acronym) do |m|
        #  m << mtg
        # end
      end

      def metadata_contribution(node, xml)
        %w(timing).each do |k|
          add_noko_elem(xml, k, node.attr(k))
          # a = node.attr(k) and xml.send k, a
        end
      end

      def metadata_meeting_date(val, xml)
        xml.meeting_date do |m|
          d = val.split("/")
          if d.size > 1
            add_noko_elem(m, "from", d[0])
            # m.from d[0]
            add_noko_elem(m, "to", d[1])
            # m.to d[1]
          else
            add_noko_elem(m, "on", d[0])
            # m.on d[0]
          end
        end
      end

      def personal_role(node, contrib, suffix)
        if node.attr("role#{suffix}")&.downcase == "rapporteur"
          add_noko_elem(contrib, "role", "raporteur", type: "editor")
          # contrib.role "raporteur", **{ type: "editor" }
        else
          super
        end
      end

      def metadata_studyperiod(node, xml)
        s, e = group_period(node, "", "")
        xml.studyperiod do |p|
          add_noko_elem(p, "start", s.to_s)
          add_noko_elem(p, "end", e.to_s)
        end
      end

      def metadata_ext(node, xml)
        super
        metadata_question(node, xml)
        metadata_recommendationstatus(node, xml)
        metadata_ip_notice(node, xml)
        metadata_studyperiod(node, xml)
        metadata_techreport(node, xml)
        metadata_contribution(node, xml)
      end
    end
  end
end

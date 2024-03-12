require "pubid-itu"

module Metanorma
  module ITU
    class Converter < Standoc::Converter
      def metadata_id(node, xml)
        provisional_id(node, xml)
        td_id(node, xml)
        if id = node.attr("docidentifier")
          xml.docidentifier id, **attr_code(type: "ITU")
        else itu_id(node, xml)
        end
        recommendation_id(node, xml)
      end

      def provisional_id(node, xml)
        node.attr("provisional-name") or return
        xml.docidentifier type: "ITU-provisional" do |i|
          i << node.attr("provisional-name")
        end
      end

      def td_id(node, xml)
        node.attr("td-number") or return
        xml.docidentifier type: "ITU-TemporaryDocument" do |i|
          i << node.attr("td-number")
        end
      end

      ITULANG = { "en" => "E", "fr" => "F", "ar" => "A", "es" => "S",
                  "zh" => "C", "ru" => "R" }.freeze

      def itu_id1(node, lang)
        bureau = node.attr("bureau") || "T"
        id = if doctype(node) == "service-publication"
               @i18n.annex_to_itu_ob_abbrev.sub(/%/,
                                                node.attr("docnumber"))
             else
               "ITU-#{bureau} #{node.attr('docnumber')}"
             end
        id + (lang ? "-#{ITULANG[@lang]}" : "")
      end

      def itu_id(node, xml)
        node.attr("docnumber") or return
        params = itu_id_params(node)
        itu_id_out(xml, params)
      end

      def compact_blank(hash)
        hash.compact.reject { |_, v| v.is_a?(String) && v.empty? }
      end

      def itu_id_pub(node)
        (node.attr("publisher") || default_publisher).split(/[;,]/)
          .map(&:strip).map { |x| org_abbrev[x] || x }
      end

      def itu_id_params(node)
        itu_id_params_core(node).merge(itu_id_params_add(node))
      end

      def itu_id_params_core(node)
        pub = itu_id_pub(node)
        num = node.attr("docnumber")
        ret = { sector: node.attr("bureau") || "T",
                publisher: pub[0],
                copublisher: pub[1..-1] }
        ret.merge!(itu_id_params_num(num))
        ret[:copublisher].empty? and ret.delete(:copublisher)
        ret
      end

      def itu_id_params_num(num)
        if m = /^(?:(?<series>[A-Z])\.)?(?<number>\d+)$/.match(num)
          { series: m[:series], number: m[:number] }
        else { number: num }
        end
      end

      def itu_id_params_add(node)
        ret = { part: node.attr("partnumber"),
                language: node.attr("language") || "en" }
        compact_blank(ret)
      end

      def itu_id_out(xml, params)
        xml.docidentifier itu_id_default(params).to_s,
                          **attr_code(type: "ITU")
        xml.docidentifier itu_id_lang(params).to_s,
                          **attr_code(type: "ITU-lang")
      end

      def itu_id_default(params)
        p = params.dup
        p.delete(:language)
        Pubid::Itu::Identifier.create(**p)
      end

      def itu_id_lang(params)
        Pubid::Itu::Identifier.create(**params)
      end

      def recommendation_id(node, xml)
        node.attr("recommendationnumber") or return
        node.attr("recommendationnumber").split("/").each do |s|
          xml.docidentifier type: "ITU-Recommendation" do |i|
            i << s
          end
        end
      end

      def structured_id(node, xml)
        node.attr("docnumber") or return
        xml.structuredidentifier do |i|
          i.bureau node.attr("bureau") || "T"
          i.docnumber node.attr("docnumber")
          a = node.attr("annexid") and i.annexid a
          a = node.attr("amendment-number") and i.amendment a
          a = node.attr("corrigendum-number") and i.corrigendum a
        end
      end
    end
  end
end

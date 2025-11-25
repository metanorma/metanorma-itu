require "pubid-itu"

module Metanorma
  module Itu
    class Converter < Standoc::Converter
      def metadata_id(node, xml)
        provisional_id(node, xml)
        td_id(node, xml)
        if id = node.attr("docidentifier")
          xml.docidentifier id, **attr_code(type: "ITU")
        else itu_id(node, xml)
        end
        recommendation_id(node, xml)
        iso_id(node, xml)
      end

      def provisional_id(node, xml)
        node.attr("provisional-name") or return
        add_noko_elem(xml, "docidentifier",
                      node.attr("provisional-name"), type: "ITU-provisional")
        # xml.docidentifier type: "ITU-provisional" do |i|
        #  i << node.attr("provisional-name")
        # end
      end

      def td_id(node, xml)
        node.attr("td-number") or return
        add_noko_elem(xml, "docidentifier",
                      node.attr("td-number"), type: "ITU-TemporaryDocument")
        # xml.docidentifier type: "ITU-TemporaryDocument" do |i|
        #  i << node.attr("td-number")
        # end
      end

      def iso_id(node, xml)
        add_noko_elem(xml, "docidentifier",
                      node.attr("common-text-docnumber"), type: "ISO")
        # a = node.attr("common-text-docnumber") and
        #  xml.docidentifier a, type: "ISO"
      end

      ITULANG = { "en" => "E", "fr" => "F", "ar" => "A", "es" => "S",
                  "zh" => "C", "ru" => "R" }.freeze

      def itu_id(node, xml)
        node.attr("docnumber") || node.attr("docidentifier") or return
        node.attr("docidentifier") and
          return add_noko_elem(xml, "docidentifier",
                      node.attr("docidentifier"), type: "ITU", primary: "true")
        params = itu_id_params(node)
        itu_id_out(node, xml, params)
      end

      def compact_blank(hash)
        hash.compact.reject { |_, v| v.is_a?(String) && v.empty? }
      end

      def itu_id_pub(node)
        (node.attr("publisher") || "ITU").split(/[;,]/)
          .map(&:strip).map { |x| org_abbrev[x] || x }
      end

      def itu_id_params(node)
        itu_id_resolve(node, itu_id_params_core(node), itu_id_params_add(node))
      end

      def itu_id_resolve(_node, core, add)
        ret = core.merge(add)
        case @doctype
        when "service-publication"
          base = ret.merge(series: "OB")
          ret = { type: :annex, base: base }
        when "contribution"
          ret[:type] = :contribution
        end
        ret
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
        ret = { part: node.attr("partnumber") }
        @doctype == "contribution" and
          ret[:series] = node.attr("group-acronym") ||
            node.attr("group")&.sub("Study Group ", "SG")
        compact_blank(ret)
      end

      def itu_id_out(node, xml, params)
        add_noko_elem(xml, "docidentifier", itu_id_default(node, params).to_s,
                          type: "ITU", primary: "true")
        id_lang = itu_id_lang(node, params)
        add_noko_elem(xml, "docidentifier", id_lang.to_s(language: @lang),
                          type: "ITU-lang")
        add_noko_elem(xml, "docidentifier", id_lang
          .to_s(language: @lang, format: :long),
                          type: "ITU-lang-long")
      end

      def itu_id_default(node, params)
        p = params.dup
        p[:base] &&= itu_id_default(node, p[:base])
        Pubid::Itu::Identifier.create(**p)
      end

      def itu_id_lang(node, params)
        params[:base] &&= itu_id_lang(node, params[:base])
        params[:language] = @lang
        Pubid::Itu::Identifier.create(**params)
      end

      def recommendation_id(node, xml)
        node.attr("recommendationnumber") or return
        node.attr("recommendationnumber").split("/").each do |s|
          add_noko_elem(xml, "docidentifier", s, type: "ITU-Recommendation")

          # xml.docidentifier type: "ITU-Recommendation" do |i|
          #   i << s
          # end
        end
      end

      def structured_id(node, xml)
        node.attr("docnumber") or return
        xml.structuredidentifier do |i|
          add_noko_elem(i, "bureau", node.attr("bureau") || "T")
          # i.bureau node.attr("bureau") || "T"
          add_noko_elem(i, "docnumber", node.attr("docnumber"))
          # i.docnumber node.attr("docnumber")
          add_noko_elem(i, "annexid", node.attr("annexid"))
          # a = node.attr("annexid") and i.annexid a
          add_noko_elem(i, "amendment", node.attr("amendment-number"))
          # a = node.attr("amendment-number") and i.amendment a
          add_noko_elem(i, "corrigendum", node.attr("corrigendum-number"))
          # a = node.attr("corrigendum-number") and i.corrigendum a
        end
      end
    end
  end
end

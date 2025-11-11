module Metanorma
  module Itu
    class Converter < Standoc::Converter
      def metadata_id(node, xml)
        provisional_id(node, xml)
        td_id(node, xml)
        itu_id(node, xml)
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

      def itu_id1(node, lang)
        bureau = node.attr("bureau") || "T"
        id = case doctype(node)
             when "service-publication"
               itu_service_pub_id(node)
             when "contribution"
               itu_contrib_id(node)
             else
               "ITU-#{bureau} #{node.attr('docnumber')}"
             end
        id + (lang ? "-#{ITULANG[@lang]}" : "")
      end

      def itu_service_pub_id(node)
        @i18n.annex_to_itu_ob_abbrev.sub(/%/, node.attr("docnumber"))
      end

      def itu_contrib_id(node)
        group = node.attr("group-acronym") ||
          node.attr("group")&.sub("Study Group ", "SG") || "XXX"
        "#{group}-C#{node.attr('docnumber')}"
      end

      def itu_id(node, xml)
        node.attr("docnumber") || node.attr("docidentifier") or return
        add_noko_elem(xml, "docidentifier",
                      node.attr("docidentifier") || itu_id1(node, false), type: "ITU", primary: "true")
        # xml.docidentifier type: "ITU", primary: "true" do |i|
        #  i << (node.attr("docidentifier") || itu_id1(node, false))
        # end
        add_noko_elem(xml, "docidentifier",
                      itu_id1(node, true), type: "ITU-lang")
        # xml.docidentifier type: "ITU-lang" do |i|
        #   i << itu_id1(node, true)
        # end
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

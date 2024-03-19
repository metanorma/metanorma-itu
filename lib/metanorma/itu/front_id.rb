module Metanorma
  module ITU
    class Converter < Standoc::Converter
      def metadata_id(node, xml)
        provisional_id(node, xml)
        td_id(node, xml)
        itu_id(node, xml)
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
        return unless node.attr("docnumber") || node.attr("docidentifier")

        xml.docidentifier type: "ITU", primary: "true" do |i|
          i << (node.attr("docidentifier") || itu_id1(node, false))
        end
        xml.docidentifier type: "ITU-lang" do |i|
          i << itu_id1(node, true)
        end
      end

      def recommendation_id(node, xml)
        return unless node.attr("recommendationnumber")

        node.attr("recommendationnumber").split("/").each do |s|
          xml.docidentifier type: "ITU-Recommendation" do |i|
            i << s
          end
        end
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
    end
  end
end

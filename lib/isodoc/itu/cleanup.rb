module IsoDoc
  module ITU
    module BaseConvert
      def cleanup(docxml)
        super
        term_cleanup(docxml)
        refs_cleanup(docxml)
        title_cleanup(docxml)
      end

      def title_cleanup(docxml)
        docxml.xpath("//h1[@class = 'RecommendationAnnex']").each do |h|
          h.name = "p"
          h["class"] = "h1Annex"
        end
        docxml
      end

      def term_cleanup(docxml)
        term_cleanup1(docxml)
        term_cleanup2(docxml)
        docxml
      end

      def term_cleanup1(docxml)
        docxml.xpath("//p[@class = 'Terms']").each do |d|
          h2 = d.at("./preceding-sibling::*[@class = 'TermNum'][1]")
          d.children.first.previous = "<b>#{h2.children.to_xml}</b>&#xa0;"
          d["id"] = h2["id"]
          h2.remove
        end
      end

      def term_cleanup2(docxml)
        docxml.xpath("//p[@class = 'TermNum']").each do |d|
          (d1 = d.next_element and d1.name == "p") or next
          d1.children.each { |e| e.parent = d }
          d1.remove
        end
      end

      def refs_cleanup(docxml)
        docxml.xpath("//tx[following-sibling::tx]").each do |tx|
          tx << tx.next_element.remove.children
        end
        docxml.xpath("//tx").each do |tx|
          tx.name = "td"
          tx["colspan"] = "2"
          tx.wrap("<tr></tr>")
        end
        docxml
      end
    end
  end
end

module IsoDoc
  module Itu
    module BaseConvert
      def termdef_parse1(node, div, defn, source)
        div.p **{ class: "TermNum", id: node["id"] } do |p|
          p.b do |b|
            node&.at(ns("./fmt-name"))&.children&.each { |n| parse(n, b) }
            insert_tab(b, 1)
            node&.at(ns("./fmt-preferred"))&.children&.each { |n| parse(n, b) }
          end
          source and p << "#{source.value} "
        end
        defn&.children&.each { |n| parse(n, div) }
      end

      def termdef_parse(node, out)
        defn = node.at(ns("./fmt-definition"))
        source = node.at(ns("./fmt-termsource//origin/@citeas"))
        out.div **attr_code(id: node["id"]) do |div|
          termdef_parse1(node, div, defn, source)
          node.children.each do |n|
            next if %w(fmt-preferred fmt-definition fmt-termsource fmt-title
                       fmt-name).include? n.name

            parse(n, out)
          end
        end
      end
    end
  end
end

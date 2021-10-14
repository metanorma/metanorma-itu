module IsoDoc
  module ITU
    module BaseConvert
      def termdef_parse1(node, div, defn, source)
        div.p **{ class: "TermNum", id: node["id"] } do |p|
          p.b do |b|
            node&.at(ns("./name"))&.children&.each { |n| parse(n, b) }
            insert_tab(b, 1)
            node&.at(ns("./preferred"))&.children&.each { |n| parse(n, b) }
          end
          p << ": "
          source and p << "#{bracket_opt(source.value)} "
        end
        defn&.children&.each { |n| parse(n, div) }
      end

      def termdef_parse(node, out)
        defn = node.at(ns("./definition"))
        source = node.at(ns("./termsource/origin/@citeas"))
        out.div **attr_code(id: node["id"]) do |div|
          termdef_parse1(node, div, defn, source)
          set_termdomain("")
          node.children.each do |n|
            next if %w(preferred definition termsource title
                       name).include? n.name

            parse(n, out)
          end
        end
      end

      def bracket_opt(text)
        return text if text.nil?
        return text if /^\[.+\]$/.match?(text)

        "[#{text}]"
      end

      def termnote_delim
        " &ndash; "
      end
    end
  end
end

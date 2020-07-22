module IsoDoc
  module ITU
    module BaseConvert
=begin
      def terms_defs(node, out, num)
        f = node.at(ns(IsoDoc::Convert::TERM_CLAUSE)) or return num
        out.div **attr_code(id: f["id"]) do |div|
          num = num + 1
          clause_name(num, f.at(ns("./title")), div, nil)
          if f.at(ns("./clause | ./terms | ./term")).nil? then out.p "None."
          else
            f.children.reject { |c1| c1.name == "title" }.each do |c1|
              parse(c1, div)
            end
          end
        end
        num
      end

      def terms_parse(node, out)
        out.div **attr_code(id: node["id"]) do |div|
          clause_parse_title(node, div, node.at(ns("./title")), out)
          if node.at(ns("./clause | ./term")).nil? then out.p "None."
          else
            node.children.reject { |c1| c1.name == "title" }.each do |c1|
              parse(c1, div)
            end
          end
        end
      end
=end

      def termdef_parse1(node, div, defn, source)
        div.p **{ class: "TermNum", id: node["id"] } do |p|
          p.b do |b|
            node&.at(ns("./name"))&.children&.each { |n| parse(n, b) }
            insert_tab(b, 1)
            node&.at(ns("./preferred"))&.children&.each { |n| parse(n, b) }
          end
          source and p << " #{bracket_opt(source.value)}"
          p << ": "
        end
        defn and defn.children.each { |n| parse(n, div) }
      end

      def termdef_parse(node, out)
        defn = node.at(ns("./definition"))
        source = node.at(ns("./termsource/origin/@citeas"))
        out.div **attr_code(id: node["id"]) do |div|
          termdef_parse1(node, div, defn, source)
          set_termdomain("")
          node.children.each do |n|
            next if %w(preferred definition termsource title name).include? n.name
            parse(n, out)
          end
        end
      end

      def termnote_delim
        " &ndash; "
      end
    end
  end
end

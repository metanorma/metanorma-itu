module IsoDoc
  module ITU
    module BaseConvert
       def term_def_title(node)
         node
      end

      def terms_defs(node, out, num)
        f = node.at(ns(IsoDoc::Convert::TERM_CLAUSE)) or return num
        out.div **attr_code(id: f["id"]) do |div|
          num = num + 1
          clause_name(num, term_def_title(f.at(ns("./title"))), div, nil)
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

      def termdef_parse1(node, div, term, defn, source)
        div.p **{ class: "TermNum", id: node["id"] } do |p|
          p.b do |b|
            b << anchor(node["id"], :label)
            insert_tab(b, 1)
            term.children.each { |n| parse(n, b) }
          end
          source and p << " #{bracket_opt(source.value)}"
          p << ": "
        end
        defn and defn.children.each { |n| parse(n, div) }
      end

      def termdef_parse(node, out)
        term = node.at(ns("./preferred"))
        defn = node.at(ns("./definition"))
        source = node.at(ns("./termsource/origin/@citeas"))
        out.div **attr_code(id: node["id"]) do |div|
          termdef_parse1(node, div, term, defn, source)
          set_termdomain("")
          node.children.each do |n|
            next if %w(preferred definition termsource title).include? n.name
            parse(n, out)
          end
        end
      end

      def termnote_parse(node, out)
      out.div **note_attrs(node) do |div|
        first = node.first_element_child
        div.p do |p|
          p << note_label(node) # "#{anchor(node['id'], :label) || '???'}: "
          para_then_remainder(first, node, p, div)
        end
      end
    end

      def termnote_anchor_names(docxml)
        docxml.xpath(ns("//term[descendant::termnote]")).each do |t|
          c = IsoDoc::Function::XrefGen::Counter.new
          notes = t.xpath(ns(".//termnote"))
          notes.each do |n|
            return if n["id"].nil? || n["id"].empty?
            idx = notes.size == 1 ? "" : " #{c.increment(n).print}"
            @anchors[n["id"]] = anchor_struct(idx, n, @note_xref_lbl,
                                              "termnote", false)
          end
        end
      end
    end
  end
end

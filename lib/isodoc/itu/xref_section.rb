module IsoDoc
  module ITU
    class Xref < IsoDoc::Xref
      def annextype(clause)
        if clause["obligation"] == "informative" then @labels["appendix"]
        else @labels["annex"]
        end
      end

      def annex_name_lbl(clause, num)
        lbl = annextype(clause)
        if @doctype == "resolution"
          l10n("#{lbl.upcase} #{num}")
        else
          l10n("<strong>#{lbl} #{num}</strong>")
        end
      end

      def annex_name_anchors(clause, num, level)
        lbl = annextype(clause)
        @anchors[clause["id"]] =
          { label: annex_name_lbl(clause, num),
            elem: lbl,
            type: "clause", value: num.to_s, level: level,
            xref: l10n("#{lbl} #{num}") }
      end

      def annex_names1(clause, num, level)
        @anchors[clause["id"]] =
          { label: num, elem: @labels["annex_subclause"],
            xref: @doctype == "resolution" ? num : l10n("#{@labels['annex_subclause']} #{num}"),
            level: level, type: "clause" }
        i = Counter.new
        clause.xpath(ns("./clause | ./references | ./terms | ./definitions"))
          .each do |c|
          i.increment(c)
          annex_names1(c, "#{num}.#{i.print}", level + 1)
        end
      end

      def clause_names(docxml, sect_num)
        docxml.xpath(ns("//sections/clause[not(@unnumbered = 'true')]" \
                        "[not(@type = 'scope')][not(descendant::terms)]"))
          .each do |c|
          section_names(c, sect_num, 1)
        end
        docxml.xpath(ns("//sections/clause[@unnumbered = 'true']")).each do |c|
          unnumbered_section_names(c, 1)
        end
      end

      def section_names(clause, num, lvl)
        return num if clause.nil?

        num.increment(clause)
        lbl = @doctype == "resolution" ? @labels["section"] : @labels["clause"]
        @anchors[clause["id"]] =
          { label: num.print, xref: l10n("#{lbl} #{num.print}"),
            level: lvl, type: "clause", elem: lbl }
        i = Counter.new
        clause.xpath(ns(SUBCLAUSES)).each do |c|
          i.increment(c)
          section_names1(c, "#{num.print}.#{i.print}", lvl + 1)
        end
        num
      end

      def section_names1(clause, num, level)
        x = @doctype == "resolution" ? num : l10n("#{@labels['clause']} #{num}")
        @anchors[clause["id"]] =
          { label: num, level: level,
            elem: @doctype == "resolution" ? "" : @labels["clause"],
            xref: x }
        i = Counter.new
        clause.xpath(ns(SUBCLAUSES)).each do |c|
          i.increment(c)
          section_names1(c, "#{num}.#{i.print}", level + 1)
        end
      end

      def unnumbered_section_names(clause, lvl)
        return if clause.nil?

        lbl = clause&.at(ns("./title"))&.text || "[#{clause['id']}]"
        @anchors[clause["id"]] =
          { label: lbl, xref: l10n(%{"#{lbl}"}), level: lvl, type: "clause" }
        clause.xpath(ns(SUBCLAUSES)).each do |c|
          unnumbered_section_names1(c, lvl + 1)
        end
      end

      def unnumbered_section_names1(clause, level)
        lbl = clause&.at(ns("./title"))&.text || "[#{clause['id']}]"
        @anchors[clause["id"]] =
          { label: lbl, xref: l10n(%{"#{lbl}"}), level: level, type: "clause" }
        clause.xpath(ns(SUBCLAUSES)).each do |c|
          unnumbered_section_names1(c, level + 1)
        end
      end
    end
  end
end

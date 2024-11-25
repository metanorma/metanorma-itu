module IsoDoc
  module Itu
    class Xref < IsoDoc::Xref
      def clause_order_annex(docxml)
        if docxml.at(ns("//bibdata/ext/structuredidentifier/annexid"))
          [{ path: "//annex", multi: true }]
        else
          [{ path: "//annex[not(@obligation = 'informative')]", multi: true },
           { path: "//annex[@obligation = 'informative']", multi: true }]
        end
      end

      def annex_anchor_names(xml)
        t = clause_order_annex(xml)
        if annexid = xml.at(ns("//bibdata/ext/structuredidentifier/annexid"))
          xml.xpath(ns(t[0][:path])).each do |c|
            annex_names(c, annexid.text)
          end
        else
          annex_names_with_counter(xml, t[0][:path],
                                   Counter.new("@", skip_i: true))
          annex_names_with_counter(xml, t[1][:path],
                                   Counter.new(0, numerals: :roman))
        end
      end

      def annex_names_with_counter(docxml, xpath, counter)
        docxml.xpath(ns(xpath)).each do |c|
          annex_names(c, counter.increment(c).print.upcase)
        end
      end

      def clause_order_preface(_docxml)
        [{ path: "//boilerplate/*", multi: true },
         { path: "//preface/*", multi: true }]
      end

      def annextype(clause)
        if clause["obligation"] == "informative" then @labels["appendix"]
        else @labels["annex"]
        end
      end

      def annex_name_lbl(clause, num)
        lbl = annextype(clause)
        if @doctype == "resolution"
          l10n("<span class='fmt-element-name'>#{lbl.upcase}</span> #{semx(clause, num)}")
        else
          l10n("<strong><span class='fmt-element-name'>#{lbl}</span> #{semx(clause, num)}</strong>")
        end
      end

      def annex_name_anchors(clause, num, level)
        lbl = annextype(clause)
        @anchors[clause["id"]] =
          { label: annex_name_lbl(clause, num),
            elem: lbl,
            type: "clause", value: num.to_s, level: level,
            #xref: l10n("#{lbl} #{num}") }
        xref: labelled_autonum(lbl, num) 
          }
      end

      def annex_names1(clause, parentnum, num, level)
        lbl = clause_number_semx(parentnum, clause, num)
            #require 'debug'; binding.b
        @anchors[clause["id"]] =
          { label: lbl, elem: @labels["annex_subclause"],
            xref: @doctype == "resolution" ? lbl : labelled_autonum(@labels['annex_subclause'], lbl),  # l10n("#{@labels['annex_subclause']} #{num}"),
            level: level, type: "clause" }
        i = Counter.new(0)
        clause.xpath(ns("./clause | ./references | ./terms | ./definitions"))
          .each do |c|
            #require 'debug'; binding.b
          annex_names1(c, lbl, i.increment(c).print, level + 1)
        end
      end

      def main_anchor_names(xml)
        n = Counter.new
        clause_order_main(xml).each do |a|
          xml.xpath(ns(a[:path])).each do |c|
            section_names(c, n, 1)
            a[:multi] or break
          end
        end
      end

      def section_names(clause, num, lvl)
        clause.nil? and return num
        clause["unnumbered"] == "true" and return unnumbered_section_names(
          clause, 1
        )

        num.increment(clause)
        elem = @doctype == "resolution" ? @labels["section"] : @labels["clause"]
        lbl = semx(clause, num.print)
        @anchors[clause["id"]] =
          { label: lbl, xref: labelled_autonum(elem, lbl),# l10n("#{lbl} #{num.print}"),
            level: lvl, type: "clause", elem: elem }
        i = Counter.new(0)
        clause.xpath(ns(SUBCLAUSES)).each do |c|
          section_names1(c, lbl, i.increment(c).print, lvl + 1)
        end
        num
      end

      def section_names1(clause, parentnum, num, level)
        lbl = clause_number_semx(parentnum, clause, num)
        x = @doctype == "resolution" ? semx(clause, lbl) : labelled_autonum(@labels['clause'], lbl) #l10n("#{@labels['clause']} #{num}")
        @anchors[clause["id"]] =
          { label: lbl, level: level,
            elem: @doctype == "resolution" ? "" : @labels["clause"],
            xref: x }
        i = Counter.new(0)
        clause.xpath(ns(SUBCLAUSES)).each do |c|
          section_names1(c, lbl, i.increment(c).print, level + 1)
        end
      end

      def unnumbered_section_names(clause, lvl)
        clause.nil? and return
        lbl = clause.at(ns("./title"))&.text || "[#{clause['id']}]"
        @anchors[clause["id"]] =
          { label: lbl, 
            # xref: l10n(%{"#{lbl}"}),
            xref: semx(clause, lbl),
            level: lvl,
            type: "clause" }
        clause.xpath(ns(SUBCLAUSES)).each do |c|
          unnumbered_section_names1(c, lvl + 1)
        end
      end

      def unnumbered_section_names1(clause, level)
        lbl = clause&.at(ns("./title"))&.text || "[#{clause['id']}]"
        @anchors[clause["id"]] =
          { label: lbl,
            #xref: l10n(%{"#{lbl}"}), 
            xref: semx(clause, lbl),
            level: level,
            type: "clause" }
        clause.xpath(ns(SUBCLAUSES)).each do |c|
          unnumbered_section_names1(c, level + 1)
        end
      end
    end
  end
end

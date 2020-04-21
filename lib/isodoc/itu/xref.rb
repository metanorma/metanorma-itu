require "isodoc"
require_relative "metadata"
require "fileutils"

module IsoDoc
  module ITU
    module BaseConvert
      def annex_name_lbl(clause, num)
        lbl = clause["obligation"] == "informative" ? @appendix_lbl : @annex_lbl
        l10n("<b>#{lbl} #{num}</b>")
      end

      def annex_names(clause, num)
        lbl = clause["obligation"] == "informative" ? @appendix_lbl : @annex_lbl
        @anchors[clause["id"]] =
          { label: annex_name_lbl(clause, num), type: "clause",
            xref: "#{lbl} #{num}", level: 1 }
        clause.xpath(ns("./clause | ./references | ./terms | ./definitions")).
          each_with_index do |c, i|
          annex_names1(c, "#{num}.#{i + 1}", 2)
        end
        hierarchical_asset_names(clause, num)
      end

      def back_anchor_names(docxml)
        super
        if annexid = docxml&.at(ns("//bibdata/ext/structuredidentifier/annexid"))&.text
          docxml.xpath(ns("//annex")).each { |c| annex_names(c, annexid) }
        else
          docxml.xpath(ns("//annex[@obligation = 'informative']")).each_with_index do |c, i|
            annex_names(c, RomanNumerals.to_roman(i + 1))
          end
          docxml.xpath(ns("//annex[not(@obligation = 'informative')]")).each_with_index do |c, i|
            annex_names(c, (65 + i + (i > 7 ? 1 : 0)).chr.to_s)
          end
        end
      end

      def annex_names1(clause, num, level)
        @anchors[clause["id"]] =
          { label: num, xref: "#{@labels["annex_subclause"]} #{num}",
            level: level, type: "clause" }
        clause.xpath(ns("./clause | ./references | ./terms | ./definitions")).each_with_index do |c, i|
          annex_names1(c, "#{num}.#{i + 1}", level + 1)
        end
      end

      def initial_anchor_names(d)
        d.xpath(ns("//boilerplate//clause")).each { |c| preface_names(c) }
        d.xpath("//xmlns:preface/child::*").each { |c| preface_names(c) }
        @hierarchical_assets ?
          hierarchical_asset_names(d.xpath("//xmlns:preface/child::*"), "Preface") :
          sequential_asset_names(d.xpath("//xmlns:preface/child::*"))
        n = section_names(d.at(ns("//clause[title = 'Scope']")), 0, 1)
        n = section_names(d.at(ns("//bibliography/clause[title = 'References'] | "\
                                  "//bibliography/references[title = 'References']")), n, 1)
        n = section_names(d.at(ns("//sections/terms | "\
                                  "//sections/clause[descendant::terms]")), n, 1)
        n = section_names(d.at(ns("//sections/definitions")), n, 1)
        clause_names(d, n)
        middle_section_asset_names(d)
        termnote_anchor_names(d)
        termexample_anchor_names(d)
      end

      def hiersep
        "-"
      end

      MIDDLE_SECTIONS = "//clause[title = 'Scope'] | "\
          "//foreword | //introduction | //acknowledgements | "\
          "//references[title = 'References' or title = 'references'] | "\
          "//sections/terms | //preface/clause | "\
          "//sections/definitions | //clause[parent::sections]".freeze

      def middle_section_asset_names(d)
        return super unless @hierarchical_assets
        d.xpath(ns(MIDDLE_SECTIONS)).each do |c|
          hierarchical_asset_names(c, @anchors[c["id"]][:label])
        end
      end

      def sequential_figure_names(clause)
        c = IsoDoc::Function::XrefGen::Counter.new
        j = 0
        clause.xpath(ns(".//figure | .//sourcecode[not(ancestor::example)]")).each do |t|
          if t.parent.name == "figure" then j += 1
          else
            j = 0
            c.increment(t)
          end
          label = c.print + (j.zero? ? "" : "-#{(97 + j).chr.to_s}")
          next if t["id"].nil? || t["id"].empty?
          @anchors[t["id"]] =
            anchor_struct(label, nil, @figure_lbl, "figure", t["unnumbered"])
        end
      end

      def hierarchical_figure_names(clause, num)
        c = IsoDoc::Function::XrefGen::Counter.new
        j = 0
        clause.xpath(ns(".//figure | .//sourcecode[not(ancestor::example)]")).each do |t|
          if t.parent.name == "figure" then j += 1
          else
            j = 0
            c.increment(t)
          end
          label = "#{num}#{hiersep}#{c.print}" +
            (j.zero? ? "" : "#{hierfigsep}#{(97 + j).chr.to_s}")
          next if t["id"].nil? || t["id"].empty?
          @anchors[t["id"]] = anchor_struct(label, nil, @figure_lbl, "figure",
                                            t["unnumbered"])
        end
      end

      def sequential_formula_names(clause)
        clause&.first&.xpath(ns(MIDDLE_SECTIONS))&.each do |c|
          if c["id"] && @anchors[c["id"]]
          hierarchical_formula_names(c, @anchors[c["id"]][:label] || @anchors[c["id"]][:xref] || "???")
          else
            hierarchical_formula_names(c, "???")
          end
        end
      end
    end
  end
end

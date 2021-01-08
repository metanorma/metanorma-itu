require "isodoc"
require "fileutils"

module IsoDoc
  module ITU
    class Counter < IsoDoc::XrefGen::Counter
    end

    class Xref < IsoDoc::Xref
      def initialize(lang, script, klass, labels, options)
        super
        @hierarchical_assets = options[:hierarchical_assets]
      end

      def annex_name_lbl(clause, num)
        lbl = clause["obligation"] == "informative" ?  @labels["appendix"] : @labels["annex"]
        @doctype == "resolution" ? l10n("#{lbl.upcase} #{num}") :
          l10n("<strong>#{lbl} #{num}</strong>")
      end

      def annex_names(clause, num)
        lbl = clause["obligation"] == "informative" ? 
          @labels["appendix"] : @labels["annex"]
        @anchors[clause["id"]] =
          { label: annex_name_lbl(clause, num), type: "clause", xref: l10n("#{lbl} #{num}"), level: 1, value: num }
        if a = single_annex_special_section(clause)
          annex_names1(a, "#{num}", 1)
        else
          i = Counter.new
          clause.xpath(ns("./clause | ./references | ./terms | ./definitions")).
            each do |c|
             i.increment(c)
             annex_names1(c, "#{num}.#{i.print}", 2)
          end
        end
        hierarchical_asset_names(clause, num)
      end

      def back_anchor_names(docxml)
        super
        if annexid = docxml&.at(ns("//bibdata/ext/structuredidentifier/annexid"))&.text
          docxml.xpath(ns("//annex")).each { |c| annex_names(c, annexid) }
        else
          i = Counter.new(0, numerals: :roman)
          docxml.xpath(ns("//annex[@obligation = 'informative']"))
            .each_with_index do |c|
            i.increment(c)
            annex_names(c, i.print.upcase)
          end
          i = Counter.new("@")
          docxml.xpath(ns("//annex[not(@obligation = 'informative')]"))
            .each do |c|
            i.increment(c)
            i.increment(c) if i.print == "I"
            annex_names(c, i.print)
          end
        end
      end

      def annex_names1(clause, num, level)
        @anchors[clause["id"]] =
          { label: num, xref: @doctype == "resolution" ? num : l10n("#{@labels["annex_subclause"]} #{num}"), 
            level: level, type: "clause" }
        i = Counter.new
        clause.xpath(ns("./clause | ./references | ./terms | ./definitions"))
          .each do |c|
          i.increment(c)
          annex_names1(c, "#{num}.#{i.print}", level + 1)
        end
      end

      def initial_anchor_names(d)
        @doctype = d&.at(ns("//bibdata/ext/doctype"))&.text
        d.xpath(ns("//boilerplate//clause")).each { |c| preface_names(c) }
        d.xpath("//xmlns:preface/child::*").each { |c| preface_names(c) }
        @hierarchical_assets ?
          hierarchical_asset_names(d.xpath("//xmlns:preface/child::*"), 
                                   "Preface") :
                                  sequential_asset_names(d.xpath("//xmlns:preface/child::*"))
        n = Counter.new
        n = section_names(d.at(ns("//clause[@type = 'scope']")), n, 1)
        n = section_names(d.at(ns(@klass.norm_ref_xpath)), n, 1)
        n = section_names(d.at(ns("//sections/terms | //sections/clause[descendant::terms]")), n, 1)
        n = section_names(d.at(ns("//sections/definitions")), n, 1)
        clause_names(d, n)
        middle_section_asset_names(d)
        termnote_anchor_names(d)
        termexample_anchor_names(d)
      end

      def middle_sections
        "//clause[@type = 'scope'] | "\
          "//foreword | //introduction | //acknowledgements | "\
          " #{@klass.norm_ref_xpath} | "\
          "//sections/terms | //preface/clause | "\
          "//sections/definitions | //clause[parent::sections]"
      end

      def middle_section_asset_names(d)
        return super unless @hierarchical_assets
        d.xpath(ns(middle_sections)).each do |c|
          hierarchical_asset_names(c, @anchors[c["id"]][:label])
        end
      end

      def sequential_figure_names(clause)
        c = IsoDoc::XrefGen::Counter.new
        j = 0
        clause.xpath(ns(".//figure | .//sourcecode[not(ancestor::example)]")).each do |t|
          if t.parent.name == "figure" then j += 1
          else
            j = 0
            c.increment(t)
          end
          label = c.print + (j.zero? ? "" : "#{hierfigsep}#{(96 + j).chr.to_s}")
          next if t["id"].nil? || t["id"].empty?
          @anchors[t["id"]] = anchor_struct(label, nil, @labels["figure"], "figure", t["unnumbered"])
        end
      end

      def hierarchical_figure_names(clause, num)
        c = IsoDoc::XrefGen::Counter.new
        j = 0
        clause.xpath(ns(".//figure | .//sourcecode[not(ancestor::example)]")).each do |t|
          if t.parent.name == "figure" then j += 1
          else
            j = 0
            c.increment(t)
          end
          label = "#{num}#{hiersep}#{c.print}" + (j.zero? ? "" : "#{hierfigsep}#{(96 + j).chr.to_s}")
          next if t["id"].nil? || t["id"].empty?
          @anchors[t["id"]] = anchor_struct(label, nil, @labels["figure"], "figure", t["unnumbered"])
        end
      end

      def sequential_formula_names(clause)
        clause&.first&.xpath(ns(middle_sections))&.each do |c|
          if c["id"] && @anchors[c["id"]]
            hierarchical_formula_names(c, @anchors[c["id"]][:label] || @anchors[c["id"]][:xref] || "???")
          else
            hierarchical_formula_names(c, "???")
          end
        end
      end

      def hierarchical_formula_names(clause, num)
        c = IsoDoc::XrefGen::Counter.new
        clause.xpath(ns(".//formula")).each do |t|
          next if t["id"].nil? || t["id"].empty?
          @anchors[t["id"]] = anchor_struct(
            "#{num}-#{c.increment(t).print}", nil,
            t["inequality"] ? @labels["inequality"] : @labels["formula"], "formula", t["unnumbered"])
        end
      end

      def reference_names(ref)
        super
        @anchors[ref["id"]] = { xref: @anchors[ref["id"]][:xref].sub(/^\[/, '').sub(/\]$/, '') }
      end

      def termnote_anchor_names(docxml)
        docxml.xpath(ns("//term[descendant::termnote]")).each do |t|
          c = IsoDoc::XrefGen::Counter.new
          notes = t.xpath(ns(".//termnote"))
          notes.each do |n|
            return if n["id"].nil? || n["id"].empty?
            idx = notes.size == 1 ? "" : " #{c.increment(n).print}"
            @anchors[n["id"]] = 
              { label: termnote_label(idx).strip, type: "termnote", value: idx,
                xref: l10n("#{anchor(t['id'], :xref)},  #{@labels["note_xref"]} #{c.print}") }
          end
        end
      end

      def clause_names(docxml, sect_num)
        docxml.xpath(ns("//sections/clause[not(@unnumbered = 'true')][not(@type = 'scope')]")).
          each_with_index do |c, i|
          section_names(c, (i + sect_num), 1)
        end
        docxml.xpath(ns("//sections/clause[@unnumbered = 'true']")).each do |c|
          unnumbered_section_names(c, 1)
        end
      end

      def section_names(clause, num, lvl)
        return num if clause.nil?
        num = num + 1
        lbl = @doctype == "resolution" ? @labels["section"] : @labels["clause"]
        @anchors[clause["id"]] =
          { label: num.to_s, xref: l10n("#{lbl} #{num}"), level: lvl, type: "clause" }
        clause.xpath(ns(SUBCLAUSES)).each_with_index do |c, i|
          section_names1(c, "#{num}.#{i + 1}", lvl + 1)
        end
        num
      end

      def section_names1(clause, num, level)
        @anchors[clause["id"]] =
          { label: num, level: level, 
            xref: @doctype == "resolution" ? num : l10n("#{@labels["clause"]} #{num}") }
        clause.xpath(ns(SUBCLAUSES)).each_with_index do |c, i|
          section_names1(c, "#{num}.#{i + 1}", level + 1)
        end
      end

      def unnumbered_section_names(clause, lvl)
        return if clause.nil?
        lbl = clause&.at(ns("./title"))&.text || "[#{clause["id"]}]"
        @anchors[clause["id"]] =
          { label: lbl, xref: l10n(%{"#{lbl}"}), level: lvl, type: "clause" }
        clause.xpath(ns(SUBCLAUSES)).each_with_index do |c, i|
          unnumbered_section_names1(c, lvl + 1)
        end
      end

      def unnumbered_section_names1(clause, level)
        lbl = clause&.at(ns("./title"))&.text || "[#{clause["id"]}]"
        @anchors[clause["id"]] =
          { label: lbl, xref: l10n(%{"#{lbl}"}), level: level, type: "clause" }
        clause.xpath(ns(SUBCLAUSES)).each do |c|
          unnumbered_section_names1(c, level + 1)
        end
      end
    end
  end
end

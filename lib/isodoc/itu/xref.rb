require "isodoc"
require "fileutils"
require_relative "./xref_section"

module IsoDoc
  module ITU
    class Counter < IsoDoc::XrefGen::Counter
      def print
        ret = super or return nil

        ret
          .sub(/([0-9])(bis|ter|quater|quinquies|sexies|septies|octies|nonies)$/,
               "\\1<em>\\2</em>")
      end
    end

    class Xref < IsoDoc::Xref
      def initialize(lang, script, klass, labels, options)
        super
        @hierarchical_assets = options[:hierarchical_assets]
      end

      def back_anchor_names(docxml)
        super
        if @parse_settings.empty? || @parse_settings[:clauses]
          if annexid = docxml
            &.at(ns("//bibdata/ext/structuredidentifier/annexid"))&.text
            docxml.xpath(ns("//annex")).each { |c| annex_names(c, annexid) }
          else
            informative_annex_names(docxml)
            normative_annex_names(docxml)
          end
        end
      end

      def informative_annex_names(docxml)
        i = Counter.new(0, numerals: :roman)
        docxml.xpath(ns("//annex[@obligation = 'informative']"))
          .each do |c|
          i.increment(c)
          annex_names(c, i.print.upcase)
        end
      end

      def normative_annex_names(docxml)
        i = Counter.new("@", skip_i: true)
        docxml.xpath(ns("//annex[not(@obligation = 'informative')]"))
          .each do |c|
          i.increment(c)
          annex_names(c, i.print)
        end
      end

      def initial_anchor_names(doc)
        @doctype = doc&.at(ns("//bibdata/ext/doctype"))&.text
        if @parse_settings.empty? || @parse_settings[:clauses]
          doc.xpath(ns("//boilerplate//clause")).each { |c| preface_names(c) }
          doc.xpath("//xmlns:preface/child::*").each { |c| preface_names(c) }
        end
        if @parse_settings.empty?
          if @hierarchical_assets
            hierarchical_asset_names(doc.xpath("//xmlns:preface/child::*"),
                                     "Preface")
          else
            sequential_asset_names(doc.xpath("//xmlns:preface/child::*"))
          end
        end
        if @parse_settings.empty? || @parse_settings[:clauses]
          n = Counter.new
          n = section_names(doc.at(ns("//clause[@type = 'scope']")), n, 1)
          n = section_names(doc.at(ns(@klass.norm_ref_xpath)), n, 1)
          n = section_names(
            doc.at(ns("//sections/terms | //sections/clause[descendant::terms]")), n, 1
          )
          n = section_names(doc.at(ns("//sections/definitions")), n, 1)
          clause_names(doc, n)
        end
        if @parse_settings.empty?
          middle_section_asset_names(doc)
          termnote_anchor_names(doc)
          termexample_anchor_names(doc)
        end
      end

      def middle_sections
        "//clause[@type = 'scope'] | "\
          "//foreword | //introduction | //acknowledgements | "\
          " #{@klass.norm_ref_xpath} | "\
          "//sections/terms | //preface/clause | "\
          "//sections/definitions | //clause[parent::sections]"
      end

      def middle_section_asset_names(doc)
        return super unless @hierarchical_assets

        doc.xpath(ns(middle_sections)).each do |c|
          hierarchical_asset_names(c, @anchors[c["id"]][:label])
        end
      end

      def sequential_figure_names(clause)
        c = Counter.new
        j = 0
        clause.xpath(ns(".//figure | .//sourcecode[not(ancestor::example)]")).each do |t|
          if t.parent.name == "figure" then j += 1
          else
            j = 0
            c.increment(t)
          end
          label = c.print + (j.zero? ? "" : "#{hierfigsep}#{(96 + j).chr}")
          next if t["id"].nil? || t["id"].empty?

          @anchors[t["id"]] =
            anchor_struct(label, nil, @labels["figure"], "figure",
                          t["unnumbered"])
        end
      end

      def hierarchical_figure_names(clause, num)
        c = Counter.new
        j = 0
        clause.xpath(ns(".//figure | .//sourcecode[not(ancestor::example)]")).each do |t|
          if t.parent.name == "figure" then j += 1
          else
            j = 0
            c.increment(t)
          end
          label = "#{num}#{hiersep}#{c.print}" + (j.zero? ? "" : "#{hierfigsep}#{(96 + j).chr}")
          next if t["id"].nil? || t["id"].empty?

          @anchors[t["id"]] =
            anchor_struct(label, nil, @labels["figure"], "figure",
                          t["unnumbered"])
        end
      end

      def sequential_formula_names(clause)
        clause&.first&.xpath(ns(middle_sections))&.each do |c|
          if c["id"] && @anchors[c["id"]]
            hierarchical_formula_names(c,
                                       @anchors[c["id"]][:label] || @anchors[c["id"]][:xref] || "???")
          else
            hierarchical_formula_names(c, "???")
          end
        end
      end

      def hierarchical_formula_names(clause, num)
        c = Counter.new
        clause.xpath(ns(".//formula")).reject do |n|
          blank?(n["id"])
        end.each do |t|
          @anchors[t["id"]] = anchor_struct(
            "#{num}-#{c.increment(t).print}", nil,
            t["inequality"] ? @labels["inequality"] : @labels["formula"],
            "formula", t["unnumbered"]
          )
        end
      end

      def reference_names(ref)
        super
        @anchors[ref["id"]] =
          { xref: @anchors[ref["id"]][:xref].sub(/^\[/, "").sub(/\]$/, "") }
      end

      def termnote_anchor_names(docxml)
        docxml.xpath(ns("//term[termnote]")).each do |t|
          c = Counter.new
          notes = t.xpath(ns("./termnote"))
          notes.reject { |n| blank?(n["id"]) }.each do |n|
            idx = notes.size == 1 ? "" : " #{c.increment(n).print}"
            @anchors[n["id"]] =
              { label: termnote_label(idx).strip, type: "termnote", value: idx,
                xref: l10n("#{anchor(t['id'], :xref)},
                           #{@labels['note_xref']} #{c.print}") }
          end
        end
      end
    end
  end
end

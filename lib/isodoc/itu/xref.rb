require "isodoc"
require "fileutils"
require_relative "xref_section"

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
        @hierarchical_assets = options[:hierarchicalassets]
      end

      def middle_sections
        "//clause[@type = 'scope'] | " \
          "//foreword | //introduction | //acknowledgements |  " \
          "#{@klass.norm_ref_xpath} | " \
          "//sections/terms | //preface/clause | " \
          "//sections/definitions | //clause[parent::sections]"
      end

      def asset_anchor_names(doc)
        super
        if @parse_settings.empty?
          if @hierarchical_assets
            hierarchical_asset_names(doc.xpath("//xmlns:preface/child::*"),
                                     "Preface")
          else
            sequential_asset_names(doc.xpath("//xmlns:preface/child::*"))
          end
        end
      end

      def middle_section_asset_names(doc)
        @hierarchical_assets or return super
        doc.xpath(ns(middle_sections)).each do |c|
          hierarchical_asset_names(c, @anchors[c["id"]][:label])
        end
      end

      def subfigure_label(subfignum)
        subfignum.zero? and return ""
        "-#{(subfignum + 96).chr}"
      end

      def sequential_figure_body(subfignum, counter, block, klass)
        label = counter.print
        label &&= label + subfigure_label(subfignum)
        @anchors[block["id"]] = anchor_struct(
          label, nil, @labels[klass] || klass.capitalize, klass,
          block["unnumbered"]
        )
      end

      def hierarchical_figure_body(num, subfignum, counter, block, klass)
        label = "#{num}#{hiersep}#{counter.print}" + subfigure_label(subfignum)
        @anchors[block["id"]] = anchor_struct(
          label, nil, @labels[klass] || klass.capitalize,
          klass, block["unnumbered"]
        )
      end

      def sequential_formula_names(clause)
        clause.first&.xpath(ns(middle_sections))&.each do |c|
          if c["id"] && @anchors[c["id"]]
            hierarchical_formula_names(c, @anchors[c["id"]][:label] ||
                                       @anchors[c["id"]][:xref] || "???")
          else
            hierarchical_formula_names(c, "???")
          end
        end
      end

      def hierarchical_formula_names(clause, num)
        c = Counter.new
        clause.xpath(ns(".//formula")).noblank.each do |t|
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
          notes.noblank.each do |n|
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

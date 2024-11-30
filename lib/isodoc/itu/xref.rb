require "isodoc"
require "fileutils"
require_relative "xref_section"

module IsoDoc
  module Itu
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
        "//clause[@type = 'scope'] | //preface/abstract | " \
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
        subfignum.zero? and return
        (subfignum + 96).chr
      end

      def subfigure_delim
        ")"
      end

      # KILL
      def sequential_figure_bodyx(subfig, counter, elem, klass, container: false)
        label = counter.print
        label &&= label + subfigure_label(subfig)
        @anchors[elem["id"]] = anchor_struct(
          label, container ? elem : nil, @labels[klass] || klass.capitalize,
          klass, elem["unnumbered"]
        )
      end

      def figure_anchor(elem, sublabel, label, klass, container: false)
        if sublabel
          subfigure_anchor(elem, sublabel, label, klass, container: false)
        else
          @anchors[elem["id"]] = anchor_struct(
            label, elem, @labels[klass] || klass.capitalize, klass,
            { unnumb: elem["unnumbered"], container: }
          )
        end
      end

      def fig_subfig_label(label, sublabel)
        "#{label}#{delim_wrap("-")}#{sublabel}"
      end

      def subfigure_anchor(elem, sublabel, label, klass, container: false)
        figlabel = fig_subfig_label(semx(elem.parent, label), semx(elem, sublabel))
        @anchors[elem["id"]] = anchor_struct(
          figlabel, elem, @labels[klass] || klass.capitalize, klass,
          { unnumb: elem["unnumbered"] }
        )
        if elem["unnumbered"] != "true"
          #@anchors[elem["id"]][:label] = sublabel
          @anchors[elem["id"]][:xref] = @anchors[elem.parent["id"]][:xref] +
            delim_wrap("-") + semx(elem, sublabel)
          x = @anchors[elem.parent["id"]][:container] and
          @anchors[elem["id"]][:container] = x
        end
      end

      # KILL
      def hierarchical_figure_bodyx(num, subfignum, counter, block, klass)
        label = "#{num}#{hier_separator}#{counter.print}" + subfigure_label(subfignum)
        @anchors[block["id"]] = anchor_struct(
          label, nil, @labels[klass] || klass.capitalize,
          klass, block["unnumbered"]
        )
      end

      def sequential_formula_names(clause, container: false)
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
            "#{semx(clause, num)}#{delim_wrap("-")}#{semx(t, c.increment(t).print)}", t,
            t["inequality"] ? @labels["inequality"] : @labels["formula"],
            "formula", { unnumb:t["unnumbered"] }
          )
        end
      end

      def termnote_anchor_names(docxml)
        docxml.xpath(ns("//term[termnote]")).each do |t|
          c = Counter.new
          notes = t.xpath(ns("./termnote"))
          notes.noblank.each do |n|
            idx = notes.size == 1 ? "" : c.increment(n).print
            idx.blank? or notenum = " #{semx(n, idx)}"
            @anchors[n["id"]] =
              { label: termnote_label(n, idx).strip, type: "termnote", value: idx,
                xref: l10n("#{semx(t, anchor(t['id'], :xref))}<span class='fmt-comma'>,</span> <span class='fmt-element-name'>#{@labels['note_xref']}</span>#{notenum}") }
          end
        end
      end
    end
  end
end

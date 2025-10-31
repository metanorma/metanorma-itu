require_relative "init"
require "roman-numerals"
require "isodoc"
require_relative "../../relaton/render/general"
require_relative "presentation_bibdata"
require_relative "presentation_preface"

module IsoDoc
  module Itu
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def bibrender_formattedref(formattedref, _xml)
        formattedref << "." unless /\.$/.match?(formattedref.text)
        id = reference_format_start(formattedref.parent) and
          formattedref.add_first_child id
      end

      def bibrender_relaton(xml, renderings)
        f = renderings[xml["id"]][:formattedref] or return
        ids = reference_format_start(xml)
        f &&= "<formattedref>#{ids}#{f}</formattedref>"
        if x = xml.at(ns("./formattedref"))
          x.replace(f)
        elsif xml.children.empty?
          xml << f
        else
          xml.children.first.previous = f
        end
      end

      def multi_bibitem_ref_code(bib)
        id = pref_ref_code_parse(bib)
        id.nil? and return []
        id.sort_by { |i| /^ITU/.match?(i) ? 0 : 1 }
      end

      def render_multi_identifiers(ids, bib)
        ids.map do |id|
          if /^ITU/.match?(id) then doctype_title(id, bib)
          else
            id.sub(/^\[/, "").sub(/\]$/, "")
          end
        end.join("&#xA0;| ")
      end

      def doctype_title(id, bib)
        type = bib.at(ns("./ext/doctype"))&.text || "recommendation"
        if type == "recommendation" &&
            /^(?<prefix>ITU-[A-Z][  ][A-Z])[  .-]Sup[a-z]*\.[  ]?(?<num>\d+)$/ =~ id
          "#{prefix}-series Recommendations – Supplement #{num}"
        else
          d = id.sub(/^\[/, "").sub(/\]$/, "")
          "#{titlecase(type)} #{d}"
        end
      end

      def reference_format_start(bib)
        id = multi_bibitem_ref_code(bib)
        id1 = render_multi_identifiers(id, bib)
        out = id1
        out.empty? and return out
        date = bib.at(ns("./date[@type = 'published']/on | " \
          "./date[@type = 'published']/from")) and
          out << " (#{date.text.sub(/-.*$/, '')})"
        out += ", " if date || !id1.empty?
        out
      end

      def bibliography_bibitem_number1(bib, idx, normative)
        mn = bib.at(ns(".//docidentifier[@type = 'metanorma']")) and
          /^\[?\d+\]?$/.match?(mn.text) and
          mn["type"] = "metanorma-ordinal"
        if (mn = bib.at(ns(".//docidentifier[@type = 'metanorma-ordinal']"))) &&
            !bibliography_bibitem_number_skip(bib)
          idx += 1
          mn.children = "[#{idx}]"
        end
        idx
      end

      def bibliography_bibitem_number_skip(bibitem)
        implicit_reference(bibitem) ||
          bibitem["hidden"] == "true" || bibitem.parent["hidden"] == "true"
      end

      def norm_ref_entry_code(_ordinal, idents, _ids, _standard, datefn, _bib)
        ret = (idents[:metanorma] || idents[:ordinal] || idents[:sdo]).to_s
        ret.empty? and return ret
        ret = ret.sub(/^\[(.+)\]$/, "\\1")
        ret = "[#{esc ret}]"
        ret += datefn
        ret.gsub("-", "&#x2011;").gsub(/ /, "&#xa0;")
      end

      def biblio_ref_entry_code(_ordinal, idents, _id, _standard, datefn, _bib)
        ret = (idents[:metanorma] || idents[:ordinal] || idents[:sdo]).to_s
        ret = ret.sub(/^\[(.+)\]$/, "\\1")
        ret = "[#{esc ret}]"
        ret += datefn
        ret.empty? and return ret
        ret.gsub("-", "&#x2011;").gsub(/ /, "&#xa0;")
      end

      def bracket_if_num(num)
        return nil if num.nil? || num.text.strip.empty?

        num = num.text.sub(/^\[/, "").sub(/\]$/, "")
        "[#{num}]"
      end

      def pref_ref_code(bibitem)
        ret = bibitem.xpath(ns("./docidentifier[@type = 'ITU']"))
        ret.empty? and ret = super
        ret
      end

      def unbracket(ident)
        if ident.respond_to?(:size)
          ident.map { |x| unbracket1(x) }.join("&#xA0;| ")
        else
          unbracket1(ident)
        end
      end

      def reference_name(ref)
        super
        @xrefs.get[ref["id"]] =
          { xref: @xrefs.get[ref["id"]][:xref]&.sub(/^\[/, "")&.sub(/\]$/, "") }
      end
    end
  end
end

require_relative "init"
require "roman-numerals"
require "isodoc"
require_relative "../../relaton/render/general"
require_relative "presentation_bibdata"
require_relative "presentation_preface"

module IsoDoc
  module ITU
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def bibrender_formattedref(formattedref, _xml)
        formattedref << "." unless /\.$/.match?(formattedref.text)
        id = reference_format_start(formattedref.parent) and
          formattedref.children.first.previous = id
      end

      def bibrender_relaton(xml, renderings)
        f = renderings[xml["id"]][:formattedref]
        ids = reference_format_start(xml)
        f &&= "<formattedref>#{ids}#{f}</formattedref>"
        # retain date in order to generate reference tag
        keep = "./docidentifier | ./uri | ./note | ./date | ./biblio-tag"
        xml.children = "#{f}#{xml.xpath(ns(keep)).to_xml}"
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
        date = bib.at(ns("./date[@type = 'published']/on | " \
          "./date[@type = 'published']/from")) and
          out << " (#{date.text.sub(/-.*$/, '')})"
        out += ", " if date || !id1.empty?
        out
      end

      def bibliography_bibitem_number1(bib, idx)
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
        @xrefs.klass.implicit_reference(bibitem) ||
          bibitem["hidden"] == "true" || bibitem.parent["hidden"] == "true"
      end

      def norm_ref_entry_code(_ordinal, idents, _ids, _standard, datefn, _bib)
        ret = (idents[:metanorma] || idents[:ordinal] || idents[:sdo]).to_s
        /^\[.+\]$/.match?(ret) or ret = "[#{ret}]"
        ret += datefn
        ret.empty? and return ret
        ret.gsub("-", "&#x2011;").gsub(/ /, "&#xa0;")
      end

      def biblio_ref_entry_code(_ordinal, idents, _id, _standard, datefn, _bib)
        ret = (idents[:metanorma] || idents[:ordinal] || idents[:sdo]).to_s
        /^\[.+\]$/.match?(ret) or ret = "[#{ret}]"
        ret += datefn
        ret.empty? and return ret
        ret.gsub("-", "&#x2011;").gsub(/ /, "&#xa0;")
      end
    end
  end
end

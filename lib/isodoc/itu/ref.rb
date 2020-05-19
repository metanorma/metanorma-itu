require "isodoc"
require_relative "metadata"
require "fileutils"

module IsoDoc
  module ITU
    module BaseConvert
      def norm_ref(isoxml, out, num)
        q = "//bibliography/references[@normative = 'true']"
        f = isoxml.at(ns(q)) or return num
        out.div do |div|
          num = num + 1
          clause_name(num, @normref_lbl, div, nil)
          biblio_list(f, div, false)
        end
        num
      end

      def nonstd_bibitem(list, b, ordinal, biblio)
        list.p **attr_code(iso_bibitem_entry_attrs(b, biblio)) do |ref|
          id = render_identifier(bibitem_ref_code(b))
          ref << (id[0] || "[#{id[1]}]")
          date_note_process(b, ref)
          insert_tab(ref, 1)
          reference_format(b, ref)
        end
      end

      def std_bibitem_entry(list, b, ordinal, biblio)
        nonstd_bibitem(list, b, ordinal, biblio)
      end

      def bracket_if_num(x)
      return nil if x.nil?
      x = x.text.sub(/^\[/, "").sub(/\]$/, "")
      "[#{x}]"
    end

      def reference_format(b, r)
        reference_format_start(b, r)
        reference_format_title(b, r)
      end

      def titlecase(s)
        s.gsub(/ |\_|\-/, " ").split(/ /).map(&:capitalize).join(" ")
      end

      def pref_ref_code(b)
        b.at(ns("./docidentifier[@type = 'ITU']")) || super
      end

      IGNORE_IDS =
  "@type = 'DOI' or @type = 'ISSN' or @type = 'ISBN' or @type = 'rfc-anchor'".freeze

      def multi_bibitem_ref_code(b)
        id = b.xpath(ns("./docidentifier[not(@type = 'metanorma' or #{IGNORE_IDS})]"))
        id.empty? and id = b.xpath(ns("./docidentifier[not(@type = 'metanorma')]"))
        return [] if id.empty?
        id.sort_by { |i| i["type"] == "ITU" ? 0 : 1 }
      end

      def render_multi_identifiers(ids)
        ids.map do |id|
          id["type"] == "ITU" ? doctype_title(id) : 
            docid_prefix(id["type"], id.text.sub(/^\[/, "").sub(/\]$/, ""))
        end.join(" | ")
      end

      def doctype_title(id)
        type = id.parent&.at(ns("./ext/doctype"))&.text || "recommendation"
        if type == "recommendation" &&
            /^(?<prefix>ITU-[A-Z] [A-Z])[ .-]Sup[a-z]*\.[ ]?(?<num>\d+)$/ =~ id.text
          "#{prefix}-series Recommendations – Supplement #{num}"
        else
          "#{titlecase(type)} #{docid_prefix(id["type"], id.text.sub(/^\[/, '').sub(/\]$/, ''))}"
        end
      end

      def reference_format_start(b, r)
        id = multi_bibitem_ref_code(b)
        id1 = render_multi_identifiers(id)
        r << id1
        date = b.at(ns("./date[@type = 'published']")) and
          r << " (#{date.text.sub(/-.*$/, '')})"
        r << ", " if (date || !id1.empty?)
      end

      def reference_format_title(b, r)
        if ftitle = b.at(ns("./formattedref"))
          ftitle&.children&.each { |n| parse(n, r) }
          /\.$/.match(ftitle&.text) or r << "."
        elsif title = iso_title(b)
          r.i do |i|
            title&.children&.each { |n| parse(n, i) }
          end
          /\.$/.match(title&.text) or r << "."
        end
      end

      def reference_names(ref)
        super
        @anchors[ref["id"]] = { xref: @anchors[ref["id"]][:xref].sub(/^\[/, '').sub(/\]$/, '') }
      end
    end
  end
end

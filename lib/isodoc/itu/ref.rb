require "isodoc"
require_relative "metadata"
require "fileutils"

module IsoDoc
  module ITU
    module BaseConvert
      def nonstd_bibitem(list, bibitem, _ordinal, biblio)
        list.tr **attr_code(iso_bibitem_entry_attrs(bibitem, biblio)) do |ref|
          ref.td style: "vertical-align:top" do |td|
            tag = bibitem.at(ns("./biblio-tag"))
            tag&.children&.each { |n| parse(n, td) }
          end
          ref.td { |td| reference_format(bibitem, td) }
        end
      end

      def std_bibitem_entry(list, bibitem, ordinal, biblio)
        nonstd_bibitem(list, bibitem, ordinal, biblio)
      end

      def biblio_list(clause, div, biblio)
        div.table class: "biblio", border: "0" do |t|
          i = 0
          t.tbody do |tbody|
            clause.elements.each do |b|
              if b.name == "bibitem"
                next if implicit_reference(b)

                i += 1
                nonstd_bibitem(tbody, b, i, biblio)
              else
                unless %w(title clause references).include? b.name
                  tbody.tx { |tx| parse(b, tx) }
                end
              end
            end
          end
        end
        clause.xpath(ns("./clause | ./references")).each do |x|
          parse(x, div)
        end
      end

      def bracket_if_num(num)
        return nil if num.nil?

        num = num.text.sub(/^\[/, "").sub(/\]$/, "")
        "[#{num}]"
      end

      def pref_ref_code(bibitem)
        ret = bibitem.xpath(ns("./docidentifier[@type = 'ITU']"))
        ret.empty? and ret = super
        ret
      end

            def titlecase(str)
        str.gsub(/ |_|-/, " ").split(/ /).map(&:capitalize).join(" ")
      end

      def doctype_title(id)
        type = id.parent&.at(ns("./ext/doctype"))&.text || "recommendation"
        if type == "recommendation" &&
            /^(?<prefix>ITU-[A-Z][  ][A-Z])[  .-]Sup[a-z]*\.[  ]?(?<num>\d+)$/ =~ id.text
          "#{prefix}-series Recommendations – Supplement #{num}"
        else
          d = docid_prefix(id["type"], id.text.sub(/^\[/, "").sub(/\]$/, ""))
          "#{titlecase(type)} #{d}"
        end
      end

      def unbracket(ident)
        if ident.respond_to?(:size)
          ident.map { |x| unbracket1(x) }.join("&#xA0;| ")
        else
          unbracket1(ident)
        end
      end
    end
  end
end

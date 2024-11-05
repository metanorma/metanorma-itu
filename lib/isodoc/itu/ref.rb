require "isodoc"
require_relative "metadata"
require "fileutils"

module IsoDoc
  module Itu
    module BaseConvert
      def bibitem_entry(list, bibitem, _ordinal, biblio)
        list.tr **attr_code(iso_bibitem_entry_attrs(bibitem, biblio)) do |ref|
          ref.td style: "vertical-align:top" do |td|
            tag = bibitem.at(ns("./biblio-tag"))
            tag&.children&.each { |n| parse(n, td) }
          end
          ref.td { |td| reference_format(bibitem, td) }
        end
      end

      def biblio_list(clause, div, biblio)
        div.table class: "biblio", border: "0" do |t|
          i = 0
          t.tbody do |tbody|
            clause.elements.each do |b|
              if b.name == "bibitem"
                b["hidden"] == "true" and next
                i += 1
                bibitem_entry(tbody, b, i, biblio)
              else
                unless %w(title clause references).include? b.name
                  tbody.tx { |tx| parse(b, tx) }
                end
              end
            end
          end
        end
        clause.xpath(ns("./clause | ./references")).each { |x| parse(x, div) }
      end
    end
  end
end

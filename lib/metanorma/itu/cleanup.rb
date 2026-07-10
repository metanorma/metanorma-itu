require_relative "cleanup_section"

module Metanorma
  module Itu
    class Cleanup < Standoc::Cleanup
      def copied_instance_variables
        super + %i[no_insert_missing_sections]
      end

      def boilerplate_file(_xmldoc)
        File.join(@libdir, "boilerplate.adoc")
      end

      def table_cleanup(xmldoc)
        super
        xmldoc.xpath("//thead/tr[1]/th | //thead/tr[1]/td").each do |t|
          text = t.at("./descendant::text()") or next
          text.replace(::Metanorma::Utils.strict_capitalize_first(text.text))
        end
      end

      def header_rows_cleanup(xmldoc)
        super
        xmldoc.xpath("//table/thead/tr/th").each do |x|
          x["align"] = "center"
        end
      end

      def cleanup(xmldoc)
        symbols_cleanup(xmldoc)
        super
        obligations_cleanup(xmldoc)
        xmldoc
      end

      def smartquotes_cleanup(xmldoc)
        @smartquotes and return super
        xmldoc.traverse do |n|
          n.text? or next
          n.replace(HTMLEntities.new.encode(
                      n.text.gsub(/\u2019|\u2018|\u201a|\u201b/, "'")
                      .gsub(/\u201c|\u201d|\u201e|\u201f/, '"'), :basic
                    ))
        end
        xmldoc
      end

      PUBLISHER = "./contributor[role/@type = 'publisher']/organization".freeze

      # ITU first, then ISO, then IEC, then other standards, then everything
      # else. Overridable per-document / per-taste via :sort-biblio-<abbrev>:
      # through the shared Standoc::Ref helpers.
      DEFAULT_PUBLISHER_SORT = [
        { abbrev: "ITU", name: "International Telecommunication Union",
          rank: 1 },
        { abbrev: "ISO", name: "International Organization for Standardization",
          rank: 2 },
        { abbrev: "IEC", name: "International Electrotechnical Commission",
          rank: 3 },
      ].freeze

      def pub_class(bib)
        publisher_sort_rank(bib, DEFAULT_PUBLISHER_SORT)
      end

      def sort_biblio(bib)
        bib.sort do |a, b|
          sort_biblio_key(a) <=> sort_biblio_key(b)
        end
      end

      # sort by: doc class (ITU, ISO, IEC, other standard (not DOI &c), other
      # then standard class (docid class other than DOI &c)
      # then alphanumeric doc id (not DOI &c)
      # then title
      def sort_biblio_key(bib)
        pubclass = pub_class(bib)
        id = bib.at("./docidentifier[not(#{@conv.skip_docid} or @type = " \
                     "'metanorma')]")
        metaid = bib.at("./docidentifier[@type = 'metanorma']")&.text
        # abbrid = metaid unless /^\[\d+\]$/.match?(metaid)
        type = id["type"] if id
        title = (bib.at("./title[@type = 'main']") ||
          bib.at("./title") || bib.at("./formattedref"))&.text
        "#{pubclass} :: #{type} :: #{id&.text || metaid} :: #{title}"
      end

      def biblio_reorder(xmldoc)
        xmldoc.xpath("//references").each do |r|
          biblio_reorder1(r)
        end
      end

      def published?(status, _xmldoc)
        !%w(in-force-prepublished draft).include?(status.downcase)
      end
    end
  end
end

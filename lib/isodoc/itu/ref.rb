require "isodoc"
require_relative "metadata"
require "fileutils"

module IsoDoc
  module ITU
    module BaseConvert
      def norm_ref(isoxml, out, num)
        q = "//bibliography/references[title = 'References']"
        f = isoxml.at(ns(q)) or return num
        out.div do |div|
          num = num + 1
          clause_name(num, @normref_lbl, div, nil)
          f.elements.reject do |e|
            %w(reference title bibitem note).include? e.name
          end.each { |e| parse(e, div) }
          biblio_list(f, div, false)
        end
        num
      end

      def nonstd_bibitem(list, b, ordinal, biblio)
        list.p **attr_code(iso_bibitem_entry_attrs(b, biblio)) do |ref|
          ref << "[#{render_identifier(bibitem_ref_code(b))}]"
          date_note_process(b, ref)
          insert_tab(ref, 1)
          reference_format(b, ref)
        end
      end

      def std_bibitem_entry(list, b, ordinal, biblio)
        nonstd_bibitem(list, b, ordinal, biblio)
      end

      def reference_format(b, r)
        reference_format_start(b, r)
        reference_format_title(b, r)
      end

      def titlecase(s)
        s.gsub(/ |\_|\-/, " ").split(/ /).map(&:capitalize).join(" ")
      end

      def bibitem_ref_code(b)
        id = b.at(ns("./docidentifier[@type = 'ITU']"))
        id ||= b.at(ns("./docidentifier[not(@type = 'DOI' or @type = 'metanorma' "\
                     "or @type = 'ISSN' or @type = 'ISBN')]"))
        id ||= b.at(ns("./docidentifier[not(@type = 'DOI' or @type = 'ISSN' or "\
                       "@type = 'ISBN')]"))
        id ||= b.at(ns("./docidentifier"))
        return id if id
        id = Nokogiri::XML::Node.new("docidentifier", b.document)
        id.text = "(NO ID)"
        id
      end

      def multi_bibitem_ref_code(b)
        id = b.xpath(ns("./docidentifier[not(@type = 'DOI' or @type = "\
                        "'metanorma' or @type = 'ISSN' or @type = 'ISBN')]"))
        id.empty? and id = b.xpath(ns("./docidentifier[not(@type = 'DOI' or "\
                                      "@type = 'ISSN' or @type = 'ISBN')]"))
        id.empty? and id = b.xpath(ns("./docidentifier"))
        return ["(NO ID)"] if id.empty?
        id.sort_by { |i| i["type"] == "ITU" ? 0 : 1 }
      end

      def render_identifiers(ids)
        ids.map do |id|
          (id["type"] == "ITU" ? titlecase(id.parent&.at(ns("./ext/doctype"))&.text ||
                                           "recommendation") + " " : "") +
                                          docid_prefix(id["type"], id.text.sub(/^\[/, "").sub(/\]$/, ""))
        end.join(" | ")
      end

      def reference_format_start(b, r)
        id = multi_bibitem_ref_code(b)
        r << render_identifiers(id)
        date = b.at(ns("./date[@type = 'published']")) and
          r << " (#{date.text.sub(/-.*$/, '')})"
        r << ", "
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
    end
  end
end

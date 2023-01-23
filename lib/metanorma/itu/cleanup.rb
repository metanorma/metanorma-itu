module Metanorma
  module ITU
    class Converter < Standoc::Converter
      def sections_cleanup(xml)
        super
        insert_missing_sections(xml) unless @no_insert_missing_sections
        insert_empty_clauses(xml)
        resolution_inline_header(xml)
      end

      def resolution_inline_header(xml)
        return unless xml&.at("//bibdata/ext/doctype")&.text == "resolution"

        xml.xpath("//clause//clause").each do |c|
          next if (title = c.at("./title")) && !title&.text&.empty?

          c["inline-header"] = true
        end
      end

      def table_cleanup(xmldoc)
        super
        xmldoc.xpath("//thead/tr[1]/th | //thead/tr[1]/td").each do |t|
          text = t.at("./descendant::text()") or next
          text.replace(text.text.capitalize)
        end
      end

      def insert_missing_sections(xml)
        insert_scope(xml)
        insert_norm_ref(xml)
        insert_terms(xml)
        insert_symbols(xml)
        insert_conventions(xml)
      end

      def add_id
        %(id="_#{UUIDTools::UUID.random_create}")
      end

      def insert_scope(xml)
        xml.at("./*/sections") or
          xml.at("./*/preface | ./*/boilerplate | ./*/bibdata").next =
            "<sections><sentinel/></sections>"
        xml.at("./*/sections/*") or xml.at("./*/sections") << "<sentinel/>"
        ins = xml.at("//sections").elements.first
        xml.at("//sections/clause[@type = 'scope']") or
          ins.previous =
            "<clause type='scope' #{add_id}><title>#{@i18n.scope}</title><p>" \
            "#{@i18n.clause_empty}</p></clause>"
        xml&.at("//sentinel")&.remove
      end

      def insert_norm_ref(xml)
        xml.at("//bibliography") or
          xml.at("./*/annex[last()] | ./*/sections").next =
            "<bibliography><sentinel/></bibliography>"
        ins = xml.at("//bibliography").elements.first
        xml.at("//bibliography/references[@normative = 'true']") or
          ins.previous = "<references #{add_id} normative='true'>" \
                         "<title>#{@i18n.normref}</title></references>"
        xml&.at("//sentinel")&.remove
      end

      def insert_terms(xml)
        ins = xml.at("//sections/clause[@type = 'scope']")
        xml.at("//sections//terms") or
          ins.next = "<terms #{add_id}><title>#{@i18n.termsdef}</title></terms>"
      end

      def insert_symbols(xml)
        ins =  xml.at("//sections/terms") ||
          xml.at("//sections/clause[descendant::terms]")
        unless xml.at("//sections//definitions")
          ins.next = "<definitions #{add_id}>" \
                     "<title>#{@i18n.symbolsabbrev}</title></definitions>"
        end
      end

      def insert_conventions(xml)
        ins =  xml.at("//sections//definitions") ||
          xml.at("//sections/clause[descendant::definitions]")
        unless xml.at("//sections/clause[@type = 'conventions']")
          ins.next = "<clause #{add_id} type='conventions'>" \
                     "<title>#{@i18n.conventions}</title><p>" \
                     "#{@i18n.clause_empty}</p></clause>"
        end
      end

      def insert_empty_clauses(xml)
        xml.xpath("//terms[not(./term)][not(.//terms)]").each do |c|
          insert_empty_clauses1(c, @i18n.clause_empty)
        end
        xml.xpath("//definitions[not(./dl)]").each do |c|
          insert_empty_clauses1(c, @i18n.clause_empty)
        end
      end

      def insert_empty_clauses1(clause, text)
        clause.at("./p") and return
        ins = clause.at("./title") or return
        ins.next = "<p>#{text}</p>"
      end

      def cleanup(xmldoc)
        symbols_cleanup(xmldoc)
        super
        obligations_cleanup(xmldoc)
        xmldoc
      end

      def smartquotes_cleanup(xmldoc)
        return super if @smartquotes

        xmldoc.traverse do |n|
          next unless n.text?

          n.replace(HTMLEntities.new.encode(
                      n.text.gsub(/\u2019|\u2018|\u201a|\u201b/, "'")
                      .gsub(/\u201c|\u201d|\u201e|\u201f/, '"'), :basic
                    ))
        end
        xmldoc
      end

      def termdef_boilerplate_cleanup(xmldoc); end

      def terms_extract(div)
        internal = div.at("./terms[@type = 'internal']/title")
        external = div.at("./terms[@type = 'external']/title")
        [internal, external]
      end

      def term_defs_boilerplate(div, _source, _term, _preface, _isodoc)
        internal, external = terms_extract(div.parent)
        internal&.next_element&.name == "term" and
          internal.next = "<p>#{@i18n.internal_terms_boilerplate}</p>"
        internal and internal&.next_element == nil and
          internal.next = "<p>#{@i18n.no_terms_boilerplate}</p>"
        external&.next_element&.name == "term" and
          external.next = "<p>#{@i18n.external_terms_boilerplate}</p>"
        external and external&.next_element == nil and
          external.next = "<p>#{@i18n.no_terms_boilerplate}</p>"
        !internal and !external and
          %w(term terms).include? div&.next_element&.name and
          div.next = "<p>#{@i18n.term_def_boilerplate}</p>"
      end

      def section_names_terms_cleanup(xml)
        super
        replace_title(
          xml, "//terms[@type = 'internal'] | " \
               "//clause[./terms[@type = 'internal']]" \
               "[not(./terms[@type = 'external'])]",
          @i18n&.internal_termsdef
        )
        replace_title(
          xml, "//terms[@type = 'external'] | " \
               "//clause[./terms[@type = 'external']]" \
               "[not(./terms[@type = 'internal'])]",
          @i18n&.external_termsdef
        )
      end

      def symbols_cleanup(xmldoc)
        sym = xmldoc.at("//definitions/title")
        sym and sym&.next_element&.name == "dl" and
          sym.next = "<p>#{@i18n.symbols_boilerplate}</p>"
      end

      PUBLISHER = "./contributor[role/@type = 'publisher']/organization".freeze

      def pub_class(bib)
        return 1 if bib.at("#{PUBLISHER}[abbreviation = 'ITU']")
        return 1 if bib.at("#{PUBLISHER}[name = 'International " \
                           "Telecommunication Union']")
        return 2 if bib.at("#{PUBLISHER}[abbreviation = 'ISO']")
        return 2 if bib.at("#{PUBLISHER}[name = 'International Organization " \
                           "for Standardization']")
        return 3 if bib.at("#{PUBLISHER}[abbreviation = 'IEC']")
        return 3 if bib.at("#{PUBLISHER}[name = 'International " \
                           "Electrotechnical Commission']")
        return 4 if bib.at("./docidentifier[@type][not(#{skip_docid} or " \
                           "@type = 'metanorma')]")

        5
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
        id = bib&.at("./docidentifier[not(#{skip_docid} or @type = " \
                     "'metanorma')]")
        metaid = bib&.at("./docidentifier[@type = 'metanorma']")&.text
        abbrid = metaid unless /^\[\d+\]$/.match?(metaid)
        type = id["type"] if id
        title = bib&.at("./title[@type = 'main']")&.text ||
          bib&.at("./title")&.text || bib&.at("./formattedref")&.text
        "#{pubclass} :: #{type} :: #{id&.text || metaid} :: #{title}"
      end

      def biblio_reorder(xmldoc)
        xmldoc.xpath("//references").each do |r|
          biblio_reorder1(r)
        end
      end
    end
  end
end

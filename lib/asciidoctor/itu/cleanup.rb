module Asciidoctor
  module ITU
    class Converter < Standoc::Converter
      def sections_cleanup(x)
        super
        insert_missing_sections(x) unless @no_insert_missing_sections
        insert_empty_clauses(x)
        resolution_inline_header(x)
      end

      def resolution_inline_header(x)
        return unless x&.at("//bibdata/ext/doctype")&.text == "resolution"
        x.xpath("//clause//clause").each do |c|
          next if title = c.at("./title") and !title&.text&.empty?
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

      def insert_missing_sections(x)
        insert_scope(x)
        insert_norm_ref(x)
        insert_terms(x)
        insert_symbols(x)
        insert_conventions(x)
      end

      def add_id
        %(id="_#{UUIDTools::UUID.random_create}")
      end

      def insert_scope(x)
        x.at("./*/sections") or
          x.at("./*/preface | ./*/boilerplate | ./*/bibdata").next =
          "<sections><sentinel/></sections>"
        x.at("./*/sections/*") or x.at("./*/sections") << "<sentinel/>"
        ins = x.at("//sections").elements.first
        x.at("//sections/clause[@type = 'scope']") or
          ins.previous =
            "<clause type='scope' #{add_id}><title>#{@i18n.scope}</title><p>"\
            "#{@i18n.clause_empty}</p></clause>"
        x&.at("//sentinel")&.remove
      end

      def insert_norm_ref(x)
        x.at("//bibliography") or
          x.at("./*/annex[last()] | ./*/sections").next =
          "<bibliography><sentinel/></bibliography>"
        ins = x.at("//bibliography").elements.first
        x.at("//bibliography/references[@normative = 'true']") or
          ins.previous = "<references #{add_id} normative='true'>"\
          "<title>#{@i18n.normref}</title></references>"
        x&.at("//sentinel")&.remove
      end

      def insert_terms(x)
        ins =  x.at("//sections/clause[@type = 'scope']")
        x.at("//sections//terms") or
          ins.next = "<terms #{add_id}><title>#{@i18n.termsdef}</title></terms>"
      end

      def insert_symbols(x)
        ins =  x.at("//sections/terms") ||
          x.at("//sections/clause[descendant::terms]")
        unless x.at("//sections//definitions")
          ins.next = "<definitions #{add_id}>"\
            "<title>#{@i18n.symbolsabbrev}</title></definitions>"
        end
      end

      def insert_conventions(x)
        ins =  x.at("//sections//definitions") ||
          x.at("//sections/clause[descendant::definitions]")
        unless x.at("//sections/clause[@type = 'conventions']")
          ins.next = "<clause #{add_id} type='conventions'>"\
            "<title>#{@i18n.conventions}</title><p>"\
            "#{@i18n.clause_empty}</p></clause>"
        end
      end

      def insert_empty_clauses(x)
        x.xpath("//terms[not(./term)][not(.//terms)]").each do |c|
          insert_empty_clauses1(c, @i18n.clause_empty)
        end
        x.xpath("//definitions[not(./dl)]").each do |c|
          insert_empty_clauses1(c, @i18n.clause_empty)
        end
      end

      def insert_empty_clauses1(c, text)
        c.at("./p") and return
        ins = c.at("./title") or return
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
            n.text.gsub(/\u2019|\u2018|\u201a|\u201b/, "'").
            gsub(/\u201c|\u201d|\u201e|\u201f/, '"'), :basic))
        end
        xmldoc
      end

      def termdef_boilerplate_cleanup(xmldoc)
      end

      def terms_extract(div)
        internal = div.at("./terms[@type = 'internal']/title")
        external = div.at("./terms[@type = 'external']/title")
        [internal, external]
      end

      def term_defs_boilerplate(div, source, term, preface, isodoc)
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

      def section_names_terms_cleanup(x)
        super
        replace_title(
          x, "//terms[@type = 'internal'] | "\
          "//clause[./terms[@type = 'internal']][not(./terms[@type = 'external'])]", 
          @i18n&.internal_termsdef)
        replace_title(
          x, "//terms[@type = 'external'] | "\
          "//clause[./terms[@type = 'external']][not(./terms[@type = 'internal'])]", 
          @i18n&.external_termsdef)
      end

      def symbols_cleanup(xmldoc)
        sym = xmldoc.at("//definitions/title")
        sym and sym&.next_element&.name == "dl" and
          sym.next = "<p>#{@i18n.symbols_boilerplate}</p>"
      end

      PUBLISHER = "./contributor[role/@type = 'publisher']/organization".freeze

      def pub_class(bib)
        return 1 if bib.at("#{PUBLISHER}[abbreviation = 'ITU']")
        return 1 if bib.at("#{PUBLISHER}[name = 'International "\
                           "Telecommunication Union']")
        return 2 if bib.at("#{PUBLISHER}[abbreviation = 'ISO']")
        return 2 if bib.at("#{PUBLISHER}[name = 'International Organization "\
                           "for Standardization']")
        return 3 if bib.at("#{PUBLISHER}[abbreviation = 'IEC']")
        return 3 if bib.at("#{PUBLISHER}[name = 'International "\
                           "Electrotechnical Commission']")
        return 4 if bib.at("./docidentifier[@type][not(@type = 'DOI' or "\
                           "@type = 'metanorma' or @type = 'ISSN' or @type = "\
                           "'ISBN')]")
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
        num = bib&.at("./docnumber")&.text
        id = bib&.at("./docidentifier[not(@type = 'DOI' or @type = "\
                     "'metanorma' or @type = 'ISSN' or @type = 'ISBN')]")
        metaid = bib&.at("./docidentifier[@type = 'metanorma']")&.text
        abbrid = metaid unless /^\[\d+\]$/.match(metaid)
        type = id['type'] if id
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

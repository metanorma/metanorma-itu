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
        @doctype == "resolution" or return
        xml.xpath("//clause//clause").each do |c|
          (title = c.at("./title")) && !title.text&.empty? and next
          c["inline-header"] = true
        end
      end

      def insert_missing_sections(xml)
        xml.at("//metanorma-extension/semantic-metadata/" \
              "headless[text() = 'true']") and return nil
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
        xml.at("//sentinel")&.remove
      end

      def insert_norm_ref(xml)
        xml.at("//bibliography") or
          xml.at("./*/annex[last()] | ./*/sections").next =
            "<bibliography><sentinel/></bibliography>"
        ins = xml.at("//bibliography").elements.first
        xml.at("//bibliography/references[@normative = 'true']") or
          ins.previous = "<references #{add_id} normative='true'>" \
                         "<title>#{@i18n.normref}</title></references>"
        xml.at("//sentinel")&.remove
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

      def sections_names_pref_cleanup(xml)
        super
        t = xml.at("//preface//abstract") or return
        t["id"] == "_summary" and
          replace_title(xml, "//preface//abstract", @i18n&.summary)
      end
    end
  end
end

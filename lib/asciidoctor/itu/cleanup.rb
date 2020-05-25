module Asciidoctor
  module ITU
    class Converter < Standoc::Converter
      def sections_cleanup(x)
        super
        insert_missing_sections(x) unless @no_insert_missing_sections
      end

      def table_cleanup(xmldoc)
        super
        xmldoc.xpath("//thead/tr[1]/th | //thead/tr[1]/td").each do |t|
          text = t.at("./descendant::text()") or next
          text.replace(text.text.titlecase)
        end
      end

      def insert_missing_sections(x)
        insert_scope(x)
        insert_norm_ref(x)
        insert_terms(x)
        insert_symbols(x)
        insert_conventions(x)
      end

      def insert_scope(x)
        x.at("./*/sections") or
          x.at("./*/preface | ./*/boilerplate | ./*/bibdata").next =
          "<sections><sentinel/></sections>"
        x.at("./*/sections/*") or x.at("./*/sections") << "<sentinel/>"
        ins = x.at("//sections").elements.first
        unless x.at("//sections/clause/title[text() = 'Scope']")
          ins.previous = "<clause><title>Scope</title><p>"\
            "#{@labels['clause_empty']}</p></clause>"
        end
        x&.at("//sentinel")&.remove
      end

      def insert_norm_ref(x)
        x.at("//bibliography") or
          x.at("./*/annex[last()] | ./*/sections").next =
          "<bibliography><sentinel/></bibliography>"
        ins = x.at("//bibliography").elements.first
        unless x.at("//bibliography/references[@normative = 'true']")
          #ins.previous = "<references normative='true'><title>References</title><p>"\
          #  "#{@labels['clause_empty']}</p></references>"
          ins.previous = "<references normative='true'><title>References</title>"\
            "</references>"
        end
        x&.at("//sentinel")&.remove
      end

      def insert_terms(x)
        ins =  x.at("//sections/clause/title[text() = 'Scope']/..")
        unless x.at("//sections//terms")
          ins.next = "<terms><title>Definitions</title><p>"\
            "#{@labels['clause_empty']}</p></terms>"
        end
      end

      def insert_symbols(x)
        ins =  x.at("//sections/terms") ||
          x.at("//sections/clause[descendant::terms]")
        unless x.at("//sections//definitions")
          ins.next = "<definitions><title>Abbreviations and acronyms</title><p>"\
            "#{@labels['clause_empty']}</p></definitions>"
        end
      end

      def insert_conventions(x)
        ins =  x.at("//sections//definitions") ||
          x.at("//sections/clause[descendant::definitions]")
        unless x.at("//sections/clause/title[text() = 'Conventions']")
          ins.next = "<clause id='_#{UUIDTools::UUID.random_create}'>"\
          "<title>Conventions</title><p>"\
          "#{@labels['clause_empty']}</p></clause>"
          end
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

          def termdef_cleanup(xmldoc)
          xmldoc.xpath("//term/preferred").each do |p|
          if ["terms defined elsewhere",
          "terms defined in this recommendation"].include? p.text.downcase
          p.name = "title"
          p.parent.name = "terms"
          end
          end
          super
          end

          def termdef_boilerplate_cleanup(xmldoc)
          end

          def symbols_cleanup(xmldoc)
          sym = xmldoc.at("//definitions/title")
          sym and sym&.next_element&.name == "dl" and
          sym.next = "<p>#{@symbols_boilerplate}</p>"
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

        def normref_cleanup(xmldoc)
          super
          r = xmldoc.at(NORM_REF) || return
          title = r.at("./title") and
            title.content = "References"
        end
      end
    end
  end

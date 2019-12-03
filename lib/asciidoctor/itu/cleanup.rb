module Asciidoctor
  module ITU
    class Converter < Standoc::Converter
      def sections_cleanup(x)
        super
        x.xpath("//*[@inline-header]").each do |h|
          h.delete("inline-header")
        end
      end

      def cleanup(xmldoc)
        symbols_cleanup(xmldoc)
        super
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
        return 1 if bib.at("#{PUBLISHER}[name = 'International Telecommunication Union']")
        return 2 if bib.at("#{PUBLISHER}[abbreviation = 'ISO']")
        return 2 if bib.at("#{PUBLISHER}[name = 'International Organization "\
                           "for Standardization']")
        return 3 if bib.at("#{PUBLISHER}[abbreviation = 'IEC']")
        return 3 if bib.at("#{PUBLISHER}[name = 'International "\
                           "Electrotechnical Commission']")
        return 4 if bib.at("./docidentifier[@type][not(@type = 'DOI' or "\
                           "@type = 'metanorma' or @type = 'ISSN' or @type = 'ISBN')]")
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
        id = bib&.at("./docidentifier[not(@type = 'DOI' or "\
                           "@type = 'metanorma' or @type = 'ISSN' or @type = 'ISBN')]")
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

      def boilerplate_cleanup(xmldoc)
        super
        initial_boilerplate(xmldoc)
      end

      def initial_boilerplate(x)
        return if x.at("//boilerplate")
        preface = x.at("//preface") || x.at("//sections") || x.at("//annex") ||
          x.at("//references") || return
        preface.previous = boilerplate(x)
      end

       def boilerplate(x_orig)
        x = x_orig.dup
        # TODO variable
        x.root.add_namespace(nil, Metanorma::ITU::DOCUMENT_NAMESPACE)
        x = Nokogiri::XML(x.to_xml)
        conv = IsoDoc::ITU::HtmlConvert.new({})
        conv.metadata_init("en", "Latn", {})
        conv.info(x, nil)
        file = @boilerplateauthority ? "#{@localdir}/#{@boilerplateauthority}" :
          File.join(File.dirname(__FILE__), "itu_intro.xml")
          conv.populate_template((File.read(file, encoding: "UTF-8")), nil)
      end
    end
  end
end

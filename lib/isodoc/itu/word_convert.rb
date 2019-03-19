require "isodoc"
require_relative "metadata"
require "fileutils"

module IsoDoc
  module ITU
    # A {Converter} implementation that generates Word output, and a document
    # schema encapsulation of the document for validation

    class WordConvert < IsoDoc::WordConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      def convert1(docxml, filename, dir)
        FileUtils.cp html_doc_path('itu-document-comb.png'), File.join(@localdir, "itu-document-comb.png")
        FileUtils.cp html_doc_path('logo.png'), File.join(@localdir, "logo.png")
        super
      end

      def default_fonts(options)
        {
          bodyfont: (options[:script] == "Hans" ? '"SimSun",serif' : '"Times New Roman",serif'),
          headerfont: (options[:script] == "Hans" ? '"SimHei",sans-serif' : '"Times New Roman",serif'),
          monospacefont: '"Courier New",monospace'
        }
      end

      def default_file_locations(options)
        {
          wordstylesheet: html_doc_path("wordstyle.scss"),
          standardstylesheet: html_doc_path("itu.scss"),
          header: html_doc_path("header.html"),
          wordcoverpage: html_doc_path("word_itu_titlepage.html"),
          wordintropage: html_doc_path("word_itu_intro.html"),
          ulstyle: "l3",
          olstyle: "l2",
        }
      end

      def metadata_init(lang, script, labels)
        @meta = Metadata.new(lang, script, labels)
      end

      def load_yaml(lang, script)
        y = if @i18nyaml then YAML.load_file(@i18nyaml)
            elsif lang == "en"
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-en.yaml"))
            else
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-en.yaml"))
            end
        super.merge(y)
      end

      def make_body(xml, docxml)
        body_attr = { lang: "EN-US", link: "blue", vlink: "#954F72" }
        xml.body **body_attr do |body|
          make_body1(body, docxml)
          make_body2(body, docxml)
          make_body3(body, docxml)
        end
      end

      def make_body2(body, docxml)
        body.div **{ class: "WordSection2" } do |div2|
          info docxml, div2
          abstract docxml, div2
          keywords docxml, div2
          preface docxml, div2
          div2.p { |p| p << "&nbsp;" } # placeholder
        end
        section_break(body)
      end

      FRONT_CLAUSE = "//*[parent::preface]"\
        "[not(local-name() = 'abstract')]".freeze

      def preface(isoxml, out)
        isoxml.xpath(ns(FRONT_CLAUSE)).each do |c|
          title = c&.at(ns("./title"))
          out.div **attr_code(id: c["id"]) do |s|
            clause_name(nil, title&.content, s, class: "IntroTitle")
            c.elements.reject { |c1| c1.name == "title" }.each do |c1|
              parse(c1, s)
            end
          end
        end
      end


      def info(isoxml, out)
        @meta.keywords isoxml, out
        @meta.ip_notice_received isoxml, out
        super
      end

      def annex_name(annex, name, div)
        div.h1 **{ class: "Annex" } do |t|
          t << "#{get_anchors[annex['id']][:label]} "
          t.br
          t.b do |b|
            name&.children&.each { |c2| parse(c2, b) }
          end
        end
      end

      def term_defs_boilerplate(div, source, term, preface)
        if source.empty? && term.nil?
          div << @no_terms_boilerplate
        else
          div << term_defs_boilerplate_cont(source, term)
        end
      end

      def i18n_init(lang, script)
        super
      end

      def fileloc(loc)
        File.join(File.dirname(__FILE__), loc)
      end

      def cleanup(docxml)
        super
        term_cleanup(docxml)
      end

      def term_cleanup(docxml)
        docxml.xpath("//p[@class = 'Terms']").each do |d|
          h2 = d.at("./preceding-sibling::*[@class = 'TermNum'][1]")
          h2.add_child("&nbsp;")
          h2.add_child(d.remove)
        end
        docxml
      end

      def abstract(isoxml, out)
        f = isoxml.at(ns("//preface/abstract")) || return
        out.div **attr_code(id: f["id"]) do |s|
          clause_name(nil, "Summary", s, class: "AbstractTitle")
          f.elements.each { |e| parse(e, s) unless e.name == "title" }
        end
      end

      def keywords(_docxml, out)
        kw = @meta.get[:keywords]
        kw.nil? || kw.empty? and return
        out.div do |div|
          clause_name(nil, "Keywords", div,  class: "IntroTitle")
          div.p kw.sort.join(", ") + "."
        end
      end

      def word_preface(docxml)
        super
        abstractbox = docxml.at("//div[@id='abstractbox']")
        historybox = docxml.at("//div[@id='historybox']")
        keywordsbox = docxml.at("//div[@id='keywordsbox']")
        abstract = docxml.at("//p[@class = 'h1Preface' and text() = 'Summary']/..")
        history = docxml.at("//p[@class = 'h1Preface' and text() = 'History']/..")
        keywords = docxml.at("//p[@class = 'h1Preface' and text() = 'Keywords']/..")
        abstract.parent = abstractbox if abstract && abstractbox
        history.parent = historybox if history && historybox
        keywords.parent = keywordsbox if keywords && keywordsbox
      end

      def initial_anchor_names(d)
        d.xpath("//xmlns:preface/child::*").each do |c|
          preface_names(c)
        end
        sequential_asset_names(d.xpath("//xmlns:preface/child::*"))
        n = section_names(d.at(ns("//clause[title = 'Scope']")), 0, 1)
        n = section_names(d.at(ns("//bibliography/clause[title = 'References'] | "\
                                  "//bibliography/references[title = 'References']")), n, 1)
        n = section_names(d.at(ns("//sections/terms | "\
                                  "//sections/clause[descendant::terms]")), n, 1)
        n = section_names(d.at(ns("//sections/definitions")), n, 1)
        clause_names(d, n)
        middle_section_asset_names(d)
        termnote_anchor_names(d)
        termexample_anchor_names(d)
      end

      def word_preface_cleanup(docxml)
        docxml.xpath("//h1[@class = 'AbstractTitle'] | "\
                     "//h1[@class = 'IntroTitle']").each do |h2|
          h2.name = "p"
          h2["class"] = "h1Preface"
        end
      end

      def word_cleanup(docxml)
        word_preface_cleanup(docxml)
        super
        docxml
      end

      def middle_title(out)
        out.p(**{ class: "zzSTDTitle1" }) { |p| p << "Recommendation " + @meta.get[:docidentifier] }
        out.p(**{ class: "zzSTDTitle2" }) { |p| p << @meta.get[:doctitle] }
      end

      def norm_ref(isoxml, out, num)
        q = "//bibliography/references[title = 'References']"
        f = isoxml.at(ns(q)) or return num
        out.div do |div|
          num = num + 1
          clause_name(num, "References", div, nil)
          norm_ref_preface(f, div)
          biblio_list(f, div, false)
        end
        num
      end

      def norm_ref_preface(f, div)
        div.p "The following ITU-T Recommendations and other references contain provisions which, through reference in this text, constitute provisions of this Recommendation. At the time of publication, the editions indicated were valid. All Recommendations and other references are subject to revision; users of this Recommendation are therefore encouraged to investigate the possibility of applying the most recent edition of the Recommendations and other references listed below. A list of the currently valid ITU-T Recommendations is regularly published. The reference to a document within this Recommendation does not give it, as a stand-alone document, the status of a Recommendation."
      end

      def term_defs_boilerplate(div, source, term, preface)
      end

      def split_bibitems(f)
        bibitem = []
        f.xpath(ns("./bibitem")).each do |x|
          bibitem << x
        end
        bibitem
      end

      def noniso_bibitem_entry(list, b, ordinal, biblio)
        return if implicit_reference(b)
        list.p **attr_code(iso_bibitem_entry_attrs(b, biblio)) do |ref|
          ref << "[#{iso_bibitem_ref_code(b)}]"
          date_note_process(b, ref)
          insert_tab(ref, 1)
          reference_format(b, ref)
        end
      end

      def biblio_list(f, div, bibliography)
        bibitems = split_bibitems(f)
        bibitems.each_with_index do |b, i|
          noniso_bibitem_entry(div, b, (i + 1), bibliography)
        end
      end

      ELSEWHERE_TERMS = "This Recommendation uses the following terms defined elsewhere:"
      HERE_TERMS = "This Recommendation defines the following terms:"

      def terms_parse(node, out)
        out.div **attr_code(id: node["id"]) do |div|
          clause_parse_title(node, div, node.at(ns("./title")), out)
          title = node.at(ns("./title"))&.text&.downcase
          title == "terms defined elsewhere" and out.p ELSEWHERE_TERMS
          title == "terms defined in this recommendation" and out.p HERE_TERMS
          content = node.at(ns("./clause | ./term"))
          if content.nil? then out.p "None."
          else
            node.children.reject { |c1| c1.name == "title" }.each do |c1|
              parse(c1, div)
            end
          end
        end
      end

      def termdef_parse1(node, div, term, defn, source)
        div.p **{ class: "TermNum", id: node["id"] } do |p|
          p.b do |b|
            b << get_anchors[node["id"]][:label]
            insert_tab(b, 1)
            term.children.each { |n| parse(n, b) }
          end
          source and p << " [#{source.value}]"
          p << ":"
          defn.children.each { |n| parse(n, p) }
        end
      end

      def termdef_parse(node, out)
        term = node.at(ns("./preferred"))
        defn = node.at(ns("./definition"))
        source = node.at(ns("./termsource/origin/@citeas"))
        out.div **attr_code(id: node["id"]) do |div|
          termdef_parse1(node, div, term, defn, source)
          set_termdomain("")
          node.children.each do |n|
            next if %w(preferred definition termsource title).include? n.name
            parse(n, out)
          end
        end
      end

      def get_eref_linkend(node)
        link = "[#{anchor_linkend(node, docid_l10n(node["target"] || node["citeas"]))}]"
        link += eref_localities(node.xpath(ns("./locality")), link)
        contents = node.children.select { |c| c.name != "locality" }
        return link if contents.nil? || contents.empty?
        Nokogiri::XML::NodeSet.new(node.document, contents).to_xml
      end

      def eref_parse(node, out)
        linkend = get_eref_linkend(node)
        if node["type"] == "footnote"
          out.sup do |s|
            s.a(**{ "href": "#" + node["bibitemid"] }) { |l| l << linkend }
          end
        else
          out.a(**{ "href": "#" + node["bibitemid"] }) { |l| l << linkend }
        end
      end


    end
  end
end

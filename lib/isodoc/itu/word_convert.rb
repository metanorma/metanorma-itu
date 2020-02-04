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
        @hierarchical_assets = options[:hierarchical_assets]
        super
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
          boilerplate docxml, div2
          abstract docxml, div2
          keywords docxml, div2
          preface docxml, div2
          div2.p { |p| p << "&nbsp;" } # placeholder
        end
        section_break(body)
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

      def word_preface_cleanup(docxml)
        docxml.xpath("//h1[@class = 'AbstractTitle'] | "\
                     "//h1[@class = 'IntroTitle']").each do |h2|
          h2.name = "p"
          h2["class"] = "h1Preface"
        end
      end

      def word_term_cleanup(docxml)
        docxml.xpath("//p[@class = 'TermNum']").each do |t|
        end
      end

      def word_cleanup(docxml)
        word_footnote_cleanup(docxml)
        word_title_cleanup(docxml)
        word_preface_cleanup(docxml)
        word_term_cleanup(docxml)
        word_history_cleanup(docxml)
        authority_hdr_cleanup(docxml)
        super
        docxml
      end

      def word_footnote_cleanup(docxml)
        docxml.xpath("//aside").each do |a|
          a.first_element_child.children.first.previous =
            '<span style="mso-tab-count:1"/>'
        end
      end

      def word_title_cleanup(docxml)
        docxml.xpath("p[@class = 'h1Preface'] | p[@class = 'h2Annex'] | "\
                     "//h1 | //h2 | //h3 | //h4 | //h5 | //h6 | "\
                     "//p[@class = 'annex_obligation']").each do |h|
          h&.next_element&.name == "p" or next
          h.next_element["class"] ||= "Normalaftertitle"
        end
      end

      def word_history_cleanup(docxml)
        docxml.xpath("//div[@id='_history']//table").each do |t|
          t["class"] = "MsoNormalTable"
          t.xpath(".//td").each { |td| td["style"] = nil }
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

      def formula_parse1(node, out)
        out.div **attr_code(id: node["id"], class: "formula") do |div|
          div.p **attr_code(class: "formula") do |p|
            insert_tab(div, 2)
            parse(node.at(ns("./stem")), div)
            lbl = anchor(node['id'], :label, false)
            unless lbl.nil?
              insert_tab(div, 1)
              div << "(#{lbl})"
            end
          end
        end
      end

      def default_fonts(options)
        { bodyfont: (options[:script] == "Hans" ? '"SimSun",serif' :
                     '"Times New Roman",serif'),
                     headerfont: (options[:script] == "Hans" ? '"SimHei",sans-serif' :
                                  '"Times New Roman",serif'),
                                  monospacefont: '"Courier New",monospace' }
      end

      def default_file_locations(options)
        { wordstylesheet: html_doc_path("wordstyle.scss"),
          standardstylesheet: html_doc_path("itu.scss"),
          header: html_doc_path("header.html"),
          wordcoverpage: html_doc_path("word_itu_titlepage.html"),
          wordintropage: html_doc_path("word_itu_intro.html"),
          ulstyle: "l3",
          olstyle: "l2", }
      end

      def make_tr_attr(td, row, totalrows, header)
        super.merge(valign: "top")
      end

      def ol_parse(node, out)
        out.ol **attr_code(class: node["class"], id: node["id"] ) do |ol|
          node.children.each { |n| parse(n, ol) }
        end
      end

      def toWord(result, filename, dir, header)
        result = populate_template(result, :word)
        result = from_xhtml(word_cleanup(to_xhtml(result)))
        unless @landscape.nil? || @landscapestyle.empty?
          @wordstylesheet&.open
          @wordstylesheet&.write(@landscapestyle)
          @wordstylesheet&.close
        end
        Html2Doc.process(result, filename: filename, stylesheet: @wordstylesheet&.path,
                         header_file: header&.path, dir: dir,
                         asciimathdelims: [@openmathdelim, @closemathdelim],
                         liststyles: { ul: @ulstyle, ol: @olstyle, steps: "l4" })
        header&.unlink
        @wordstylesheet&.unlink
      end

      def link_parse(node, out)
        out.a **attr_code(href: node["target"], title: node["alt"], class: "url") do |l|
          if node.text.empty?
            l << node["target"].sub(/^mailto:/, "")
          else
            node.children.each { |n| parse(n, l) }
          end
        end
      end

      def authority_hdr_cleanup(docxml)
        docxml&.xpath("//div[@id = 'draft-warning']").each do |d|
          d.xpath(".//h1 | .//h2").each do |p|
            p.name = "p"
            p["class"] = "draftwarningHdr"
          end
        end
        %w(copyright license legal).each do |t|
          docxml&.xpath("//div[@class = 'boilerplate-#{t}']").each do |d|
            p = d&.at("./descendant::h1[2]") and
              p.previous = "<p>&nbsp;</p><p>&nbsp;</p><p>&nbsp;</p>"
            d.xpath(".//h1 | .//h2").each do |p|
              p.name = "p"
              p["class"] = "boilerplateHdr"
            end
          end
        end
      end

      def authority_cleanup(docxml)
        dest = docxml.at("//div[@class = 'draft-warning']")
        auth = docxml.at("//div[@id = 'draft-warning']")
        dest and auth and dest.replace(auth.remove)
        %w(copyright license legal).each do |t|
          dest = docxml.at("//div[@id = 'boilerplate-#{t}-destination']")
          auth = docxml.at("//div[@class = 'boilerplate-#{t}']")
          next unless auth && dest
          t == "copyright" and p = auth&.at(".//p[@class = 'Normalaftertitle']") and
            p["class"] = "boilerplateHdr"
          auth&.xpath(".//p[not(@class) or @class = 'Normalaftertitle']")&.each do |p|
            p["class"] = "boilerplate"
          end
          auth << "<p>&nbsp;</p><p>&nbsp;</p><p>&nbsp;</p>" unless t == "copyright"
          dest.replace(auth.remove)
        end
      end

      include BaseConvert
    end
  end
end

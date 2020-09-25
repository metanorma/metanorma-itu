require "isodoc"
require_relative "init"
require_relative "word_cleanup"
require "fileutils"

module IsoDoc
  module ITU
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
          preface_block docxml, div2
          abstract docxml, div2
          keywords docxml, div2
          preface docxml, div2
          div2.p { |p| p << "&nbsp;" } # placeholder
        end
        section_break(body)
      end

      def abstract(isoxml, out)
        f = isoxml.at(ns("//preface/abstract")) || return
        out.div **attr_code(id: f["id"], class: "Abstract") do |s|
          clause_name(nil, "Summary", s, class: "AbstractTitle")
          f.elements.each { |e| parse(e, s) unless e.name == "title" }
        end
      end

      def keywords(_docxml, out)
        kw = @meta.get[:keywords]
        kw.nil? || kw.empty? and return
        out.div **attr_code(class: "Keyword") do |div|
          clause_name(nil, "Keywords", div,  class: "IntroTitle")
          div.p kw.join(", ") + "."
        end
      end

      def formula_parse1(node, out)
        out.div **attr_code(class: "formula") do |div|
          div.p **attr_code(class: "formula") do |p|
            insert_tab(div, 1)
            parse(node.at(ns("./stem")), div)
            if lbl = node&.at(ns("./name"))&.text
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

      def ol_attrs(node)
        { class: node["class"], id: node["id"], style: keep_style(node),
          start: node["start"] }
      end

      def link_parse(node, out)
        out.a **attr_code(href: node["target"], title: node["alt"], 
                          class: "url") do |l|
          if node.text.empty?
            l << node["target"].sub(/^mailto:/, "")
          else
            node.children.each { |n| parse(n, l) }
          end
        end
      end

      def clause_attrs(node)
        ret = {}
        %w(source history).include?(node["type"]) and
          ret = { class: node["type"] }
        super.merge(ret)
      end

      include BaseConvert
      include Init
    end
  end
end

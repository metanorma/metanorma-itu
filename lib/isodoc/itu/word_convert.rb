require "isodoc"
require_relative "init"
require_relative "word_cleanup"
require "fileutils"

module IsoDoc
  module Itu
    class WordConvert < IsoDoc::WordConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        @hierarchical_assets = options[:hierarchicalassets]
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

      def make_body1(body, _docxml)
        @wordcoverpage or return
        super
      end

      def make_body2(body, docxml)
        body.div class: "WordSection2" do |div2|
          boilerplate docxml, div2
          content(div2, docxml, ns("//preface/*[@displayorder]"))
          div2.p { |p| p << "&#xa0;" } # placeholder
        end
        @doctype == "contribution" or section_break(body)
      end

      def abstract(clause, out)
        out.div **attr_code(id: clause["id"], class: "Abstract") do |s|
          @doctype == "contribution" or
            clause_name(clause, "Summary", s, class: "AbstractTitle")
          clause.elements.each { |e| parse(e, s) unless e.name == "title" }
        end
      end

      def formula_parse1(node, out)
        out.div **attr_code(class: "formula") do |div|
          div.p **attr_code(class: "formula") do |_p|
            insert_tab(div, 1)
            parse(node.at(ns("./stem")), div)
            if lbl = node&.at(ns("./name"))&.text
              insert_tab(div, 1)
              div << "(#{lbl})"
            end
          end
        end
      end

      def convert1(docxml, filename, dir)
        case @doctype
        when "service-publication"
          @wordcoverpage = html_doc_path("word_itu_titlepage_sp.html")
          options[:bodyfont] = "Arial"
          options[:headerfont] = "Arial"
        when "contribution"
          @wordcoverpage = nil
          @wordintropage = nil
        end
        super
      end

      def default_fonts(options)
        { bodyfont: (if options[:script] == "Hans"
                       '"Source Han Sans",serif'
                     else
                       '"Times New Roman",serif'
                     end),
          headerfont: (if options[:script] == "Hans"
                         '"Source Han Sans",sans-serif'
                       else
                         '"Times New Roman",serif'
                       end),
          monospacefont: '"Courier New",monospace',
          normalfontsize: "12.0pt",
          footnotefontsize: "11.0pt",
          smallerfontsize: "11.0pt",
          monospacefontsize: "10.0pt" }
      end

      def default_file_locations(_options)
        { wordstylesheet: html_doc_path("wordstyle.scss"),
          standardstylesheet: html_doc_path("itu.scss"),
          header: html_doc_path("header.html"),
          wordcoverpage: html_doc_path("word_itu_titlepage.html"),
          wordintropage: html_doc_path("word_itu_intro.html"),
          ulstyle: "l3",
          olstyle: "l2" }
      end

      def make_tr_attr(tcell, row, totalrows, header, bordered)
        super.merge(valign: "top")
      end

      def ol_attrs(node)
        { class: node["class"], id: node["id"], style: keep_style(node) }
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

      def table_of_contents(clause, out)
        page_break(out)
        out.div **attr_code(preface_attrs(clause)) do |div|
          div.p class: "zzContents" do |p|
            clause.at(ns("./title"))&.children&.each do |c|
              parse(c, p)
            end
          end
          div.p style: "tab-stops:right 17.0cm" do |p|
            insert_tab(p, 1)
            p << "<b>#{@i18n.page}</b>"
          end
          clause.elements.each do |e|
            parse(e, div) unless e.name == "title"
          end
        end
      end

      include BaseConvert
      include Init
    end
  end
end

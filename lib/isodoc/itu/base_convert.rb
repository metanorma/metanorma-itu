require "isodoc"
require "fileutils"
require_relative "ref"
require_relative "xref"
require_relative "terms"
require_relative "cleanup"

module IsoDoc
  module Itu
    module BaseConvert
      FRONT_CLAUSE = "//*[parent::preface]" \
                     "[not(local-name() = 'abstract')]".freeze

      def introduction(clause, out)
        title = clause.at(ns("./fmt-title"))
        out.div **attr_code(clause_attrs(clause)) do |s|
          clause_name(clause, title, s, class: "IntroTitle")
          clause.elements.reject { |c1| c1.name == "fmt-title" }.each do |c1|
            parse(c1, s)
          end
        end
      end

      def foreword(clause, out)
        introduction(clause, out)
      end

      def acknowledgements(clause, out)
        introduction(clause, out)
      end

      def preface_normal(clause, out)
        introduction(clause, out)
      end

      def clausedelim
        ""
      end

      def para_class(node)
        node["class"] == "supertitle" and return "supertitle"
        super
      end

      def annex_name(_annex, name, div)
        r_a = @meta.get[:doctype_original] == "recommendation-annex"
        div.h1 class: r_a ? "RecommendationAnnex" : "Annex" do |t|
          name&.children&.each { |c2| parse(c2, t) }
        end
      end

      def annex(node, out)
        @meta.get[:doctype_original] == "recommendation-annex" or
          page_break(out)
        out.div **attr_code(id: node["id"], class: "Section3") do |s|
          annex_name(node, nil, s) unless node.at(ns("./fmt-title"))
          node.elements.each do |c1|
            if c1.name == "fmt-title" then annex_name(node, c1, s)
            else
              parse(c1, s)
            end
          end
        end
      end

      def info(isoxml, out)
        @meta.ip_notice_received isoxml, out
        @meta.techreport isoxml, out
        @meta.contribution isoxml, out
        super
      end

      def note_parse(node, out)
        node["type"] == "title-footnote" and return
        super
      end

      def clause_attrs(node)
        if node["type"] == "keyword"
          super.merge(class: "Keyword")
        else super
        end
      end

      # can have supertitle in resolution
      def clause(clause, out)
        out.div **attr_code(clause_attrs(clause)) do |s|
          clause.elements.each do |c1|
            if c1.name == "fmt-title" then clause_name(clause, c1, s, nil)
            else
              parse(c1, s)
            end
          end
        end
      end

      def dl_parse(node, out)
        node.ancestors("table, formula, figure").empty? or return super
        dl1(node)
        table_parse(node, out)
      end

      def dl1(dlist)
        ret = dl2tbody(dlist)
        n = dlist.at(ns("./colgroup")) and ret = "#{n.remove.to_xml}#{ret}"
        n = dlist.at(ns("./fmt-name")) and ret = "#{n.remove.to_xml}#{ret}"
        dlist.name = "table"
        dlist["class"] = "dl"
        dlist.children.first.previous = ret
      end

      def dl2tbody(dlist)
        ret = ""
        dlist.elements.select { |n| %w{dt dd}.include? n.name }
          .each_slice(2) do |dt, dd|
            ret += "<tr><th width='20%'>#{dt.children.to_xml}</th>" \
             "<td width='80%'>#{dd.children.to_xml}</td></tr>"
            dt.replace(" ")
            dd.remove
          end
        "<tbody>#{ret}</tbody>"
      end
    end
  end
end

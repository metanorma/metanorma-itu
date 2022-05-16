require "isodoc"
require "fileutils"
require_relative "./ref"
require_relative "./xref"
require_relative "./terms"
require_relative "./cleanup"

module IsoDoc
  module ITU
    module BaseConvert
      FRONT_CLAUSE = "//*[parent::preface]"\
                     "[not(local-name() = 'abstract')]".freeze

      def preface(isoxml, out)
        isoxml.xpath(ns(FRONT_CLAUSE)).each do |c|
          next unless is_clause?(c.name)

          title = c&.at(ns("./title"))
          out.div **attr_code(clause_attrs(c)) do |s|
            clause_name(nil, title, s, class: "IntroTitle")
            c.elements.reject { |c1| c1.name == "title" }.each do |c1|
              parse(c1, s)
            end
          end
        end
      end

      def clausedelim
        ""
      end

      def note_delim
        " &#x2013; "
      end

      def para_class(node)
        return "supertitle" if node["class"] == "supertitle"

        super
      end

      def ol_depth(node)
        return super unless node["class"] == "steps" ||
          node.at(".//ancestor::xmlns:ol[@class = 'steps']")

        depth = node.ancestors("ul, ol").size + 1
        type = :arabic
        type = :alphabet if [2, 7].include? depth
        type = :roman if [3, 8].include? depth
        type = :alphabet_upper if [4, 9].include? depth
        type = :roman_upper if [5, 10].include? depth
        ol_style(type)
      end

      def annex_name(annex, name, div)
        preceding_floating_titles(name, div)
        r_a = @meta.get[:doctype_original] == "recommendation-annex"
        div.h1 **{ class: r_a ? "RecommendationAnnex" : "Annex" } do |t|
          name&.children&.each { |c2| parse(c2, t) }
        end
        @meta.get[:doctype_original] == "resolution" or
          annex_obligation_subtitle(annex, div)
      end

      def annex_obligation_subtitle(annex, div)
        info = annex["obligation"] == "informative"
        div.p **{ class: "annex_obligation" } do |p|
          p << (info ? @i18n.inform_annex : @i18n.norm_annex)
            .sub(/%/, @meta.get[:doctype] || "")
        end
      end

      def annex(isoxml, out)
        isoxml.xpath(ns("//annex")).each do |c|
          @meta.get[:doctype_original] == "recommendation-annex" or
            page_break(out)
          out.div **attr_code(id: c["id"], class: "Section3") do |s|
            annex_name(c, nil, s) unless c.at(ns("./title"))
            c.elements.each do |c1|
              if c1.name == "title" then annex_name(c, c1, s)
              else
                parse(c1, s)
              end
            end
          end
        end
      end

      def info(isoxml, out)
        @meta.ip_notice_received isoxml, out
        @meta.techreport isoxml, out
        super
      end

      def middle_title(isoxml, out)
        if @meta.get[:doctype] == "Resolution"
          middle_title_resolution(isoxml, out)
        else
          middle_title_recommendation(isoxml, out)
        end
      end

      def middle_title_resolution(isoxml, out)
        res = isoxml.at(ns("//bibdata/title[@type = 'resolution']"))
        out.p(**{ align: "center", style: "text-align:center;" }) do |p|
          res.children.each { |n| parse(n, p) }
        end
        out.p(**{ class: "zzSTDTitle2" }) { |p| p << @meta.get[:doctitle] }
        middle_title_resolution_subtitle(isoxml, out)
      end

      def middle_title_resolution_subtitle(isoxml, out)
        out.p(**{ align: "center", style: "text-align:center;" }) do |p|
          p.i do |i|
            i << "("
            isoxml.at(ns("//bibdata/title[@type = 'resolution-placedate']"))
              .children.each { |n| parse(n, i) }
            i << ")"
          end
          isoxml.xpath(ns("//note[@type = 'title-footnote']")).each do |f|
            footnote_parse(f, p)
          end
        end
      end

      def middle_title_recommendation(isoxml, out)
        out.p(**{ class: "zzSTDTitle1" }) do |p|
          type = @meta.get[:doctype]
          @meta.get[:unpublished] && @meta.get[:draft_new_doctype] and
            type = @meta.get[:draft_new_doctype]
          id = @meta.get[:docnumber] and p << "#{type} #{id}"
        end
        out.p(**{ class: "zzSTDTitle2" }) do |p|
          p << @meta.get[:doctitle]
          isoxml.xpath(ns("//note[@type = 'title-footnote']")).each do |f|
            footnote_parse(f, p)
          end
        end
        s = @meta.get[:docsubtitle] and
          out.p(**{ class: "zzSTDTitle3" }) { |p| p << s }
      end

      def note_p_parse(node, div)
        name = node&.at(ns("./name"))&.remove
        div.p do |p|
          name and p.span **{ class: "note_label" } do |s|
            name.children.each { |n| parse(n, s) }
            s << note_delim
          end
          node.first_element_child.children.each { |n| parse(n, p) }
        end
        node.element_children[1..-1].each { |n| parse(n, div) }
      end

      def note_parse1(node, div)
        name = node&.at(ns("./name"))&.remove
        div.p do |p|
          name and p.span **{ class: "note_label" } do |s|
            name.children.each { |n| parse(n, s) }
          end
        end
        node.children.each { |n| parse(n, div) }
      end

      def table_footnote_reference_format(node)
        node.content += ")"
      end

      def note_parse(node, out)
        return if node["type"] == "title-footnote"

        super
      end

      # can have supertitle in resolution
      def clause(isoxml, out)
        isoxml.xpath(ns(middle_clause(isoxml))).each do |c|
          clause_core(c, out)
        end
      end

      def clause_core(clause, out)
        out.div **attr_code(clause_attrs(clause)) do |s|
          clause.elements.each do |c1|
            if c1.name == "title" then clause_name(nil, c1, s, nil)
            else
              parse(c1, s)
            end
          end
        end
      end

      def scope(isoxml, out, num)
        return super unless @meta.get[:doctype_original] == "resolution"

        f = isoxml.at(ns("//clause[@type = 'scope']")) or return num
        clause_core(f, out)
        num + 1
      end
    end
  end
end

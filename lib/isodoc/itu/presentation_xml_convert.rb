require_relative "init"
require "roman-numerals"
require "isodoc"
require_relative "../../relaton/render/general"
require_relative "presentation_bibdata"
require_relative "presentation_preface"
require_relative "presentation_ref"
require_relative "presentation_contribution"

module Nokogiri
  module XML
    class Node
      def traverse_topdown(&block)
        yield(self)
        children.each { |j| j.traverse_topdown(&block) }
      end
    end
  end
end

module IsoDoc
  module Itu
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def initialize(options)
        @hierarchical_assets = options[:hierarchicalassets]
        super
      end

      def eref(docxml)
        docxml.xpath(ns("//eref")).each { |f| eref1(f) }
      end

      def origin(docxml)
        docxml.xpath(ns("//origin[not(termref)]")).each { |f| eref1(f) }
      end

      def quotesource(docxml)
        docxml.xpath(ns("//quote//source")).each { |f| eref1(f) }
      end

      def eref1(elem)
        get_eref_linkend(elem)
      end

      def note1(elem)
        elem["type"] == "title-footnote" and return
        super
      end

      def note_delim(elem)
        if elem.at(ns("./*[local-name() != 'name'][1]"))&.name == "p"
          "\u00a0\u2013\u00a0"
        else
          ""
        end
      end

      def table1(elem)
        elem.xpath(ns("./name | ./thead/tr/th")).each do |n|
          capitalise_unless_text_transform(n)
        end
        super
      end

      def capitalise_unless_text_transform(elem)
        css = nil
        elem.traverse_topdown do |n|
          n.name == "span" && /text-transform:/.match?(n["style"]) and
            css = n
          n.text? && /\S/.match?(n.text) or next
          css && n.ancestors.include?(css) or
            n.replace(::Metanorma::Utils.strict_capitalize_first(n.text))
          break
        end
      end

      def get_eref_linkend(node)
        non_locality_elems(node).select do |c|
          !c.text? || /\S/.match(c)
        end.empty? or return
        link = anchor_linkend(node,
                              docid_l10n(node["target"] || node["citeas"]))
        link && !/^\[.*\]$/.match(link) and link = "[#{link}]"
        link += eref_localities(node.xpath(ns("./locality | ./localityStack")),
                                link, node)
        non_locality_elems(node).each(&:remove)
        node.add_child(link)
      end

      def titlecase(str)
        str.gsub(/ |_|-/, " ").split(/ /).map(&:capitalize).join(" ")
      end

      def twitter_cldr_localiser_symbols
        { group: "'" }
      end

      def clause1(elem)
        clause1_super?(elem) and return super
        @suppressheadingnumbers || elem["unnumbered"] and return
        t = elem.at(ns("./title")) and t["depth"] = "1"
        lbl = @xrefs.anchor(elem["id"], :label, false) or return
        elem.previous =
          "<p keep-with-next='true' class='supertitle'>" \
          "#{@i18n.get['section'].upcase} #{lbl}</p>"
      end

      def clause1_super?(elem)
        @doctype != "resolution" ||
          !%w(sections bibliography).include?(elem.parent.name)
      end

      def annex1(elem)
        @doctype == "resolution" or return super
        elem.elements.first.previous = annex1_supertitle(elem)
        t = elem.at(ns("./title")) and
          t.children = "<strong>#{to_xml(t.children)}</strong>"
      end

      def annex1_supertitle(elem)
        lbl = @xrefs.anchor(elem["id"], :label)
        res = elem.at(ns("//bibdata/title[@type = 'resolution']"))
        subhead = @i18n.l10n("(#{@i18n.get['to']} #{to_xml(res.children)})")
        "<p class='supertitle'>#{lbl}<br/>#{subhead}</p>"
      end

      def ol_depth(node)
        node["class"] == "steps" ||
          node.at(".//ancestor::xmlns:ol[@class = 'steps']") or return super
        depth = node.ancestors("ul, ol").size + 1
        type = :arabic
        type = :alphabet if [2, 7].include? depth
        type = :roman if [3, 8].include? depth
        type = :alphabet_upper if [4, 9].include? depth
        type = :roman_upper if [5, 10].include? depth
        type
      end

      def middle_title(isoxml)
        s = isoxml.at(ns("//sections")) or return
        titfn = isoxml.at(ns("//note[@type = 'title-footnote']"))
        case @doctype
        when "resolution"
          middle_title_resolution(isoxml, s.children.first)
        when "contribution"
        else
          middle_title_recommendation(isoxml, s.children.first)
        end
        titfn and renumber_footnotes(isoxml)
      end

      def renumber_footnotes(isoxml)
        (isoxml.xpath(ns("//fn")) -
         isoxml.xpath(ns("//table//fn | //figure//fn")))
          .each_with_index do |fn, i|
            fn["reference"] = (i + 1).to_s
          end
      end

      def middle_title_resolution(isoxml, out)
        res = isoxml.at(ns("//bibdata/title[@type = 'resolution']"))
        out.previous =
          "<p class='zzSTDTitle1' align='center'>#{res.children.to_xml}</p>"
        t = @meta.get[:doctitle] and
          out.previous = "<p class='zzSTDTitle2'>#{t}</p>"
        middle_title_resolution_subtitle(isoxml, out)
      end

      def middle_title_resolution_subtitle(isoxml, out)
        ret = "<p align='center' class='zzSTDTitle2'><em>("
        d = isoxml.at(ns("//bibdata/title[@type = 'resolution-placedate']"))
        ret += "#{d.children.to_xml.strip}</em>)"
        ret += "#{title_footnotes(isoxml)}</p>"
        out.previous = ret
      end

      def middle_title_recommendation(isoxml, out)
        ret = ""
        type = @meta.get[:doctype]
        @meta.get[:unpublished] && @meta.get[:draft_new_doctype] and
          type = @meta.get[:draft_new_doctype]
        id = @meta.get[:docnumber] and
          ret += "<<p class='zzSTDTitle1'>#{type} #{id}</p>"
        t = @meta.get[:doctitle] and
          ret += "<p class='zzSTDTitle2'>#{t}"
        ret += "#{title_footnotes(isoxml)}</p>"
        s = @meta.get[:docsubtitle] and ret += "<p class='zzSTDTitle3'>#{s}</p>"
        out.previous = ret
      end

      def title_footnotes(isoxml)
        ret = ""
        isoxml.xpath(ns("//note[@type = 'title-footnote']"))
          .each_with_index do |f, i|
            ret += "<fn reference='H#{i}'>#{f.remove.children.to_xml}</fn>"
          end
        ret
      end

      def dl(xml)
        (xml.xpath(ns("//dl")) -
         xml.xpath(ns("//table//dl | //figure//dl | //formula//dl")))
          .each do |d|
            dl1(d)
          end
      end

      def dl1(dlist)
        ins = dlist.at(ns("./dt"))
        ins.previous =
          '<colgroup><col width="20%"/><col width="80%"/></colgroup>'
      end

      include Init
    end
  end
end

require_relative "init"
require "roman-numerals"
require "isodoc"
require_relative "../../relaton/render/general"
require_relative "presentation_bibdata"
require_relative "presentation_preface"
require_relative "presentation_ref"
require_relative "presentation_contribution"
require_relative "presentation_section"
require_relative "../../nokogiri/xml"

module IsoDoc
  module Itu
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def initialize(options)
        @hierarchical_assets = options[:hierarchicalassets]
        super
      end

      def eref(docxml)
        docxml.xpath(ns("//fmt-eref")).each { |f| eref1(f) }
      end

      def origin(docxml)
        docxml.xpath(ns("//fmt-origin[not(termref)]")).each do |f|
          f["citeas"] = bracket_opt(f["citeas"])
          eref1(f)
        end
      end

      def bracket_opt(text)
        text.nil? and return
        /^\[.+\]$/.match?(text) and return text
        "[#{text}]"
      end

      def designation1(desgn)
        super
        desgn.name == "preferred" or return
        out = desgn.parent
          .at(ns("./fmt-preferred//semx[@element = 'preferred'][last()]"))
        out or return
        out.text.strip.empty? and return
        out.children = l10n "#{to_xml out.children}:"
      end

      def designation(docxml)
        super
        docxml.xpath(ns("//fmt-preferred")).each do |x|
          x.xpath(ns("./p")).each { |p| p.replace(p.children) }
        end
      end

      def termsource_label(elem, sources)
        elem.replace(sources)
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
        else ""
        end
      end

      def table1(elem)
        elem.xpath(ns("./thead/tr/th")).each do |n|
          capitalise_unless_text_transform(n)
        end
        super
        elem.xpath(ns("./fmt-name//semx[@element = 'name']")).each do |n|
          capitalise_unless_text_transform(n)
        end
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

      def fn_ref_label(fnote)
        if fnote.ancestors("table, figure").empty? ||
            !fnote.ancestors("name, fmt-name").empty?
          super
        else
          "<sup>#{fn_label(fnote)}" \
            "<span class='fmt-label-delim'>)</span></sup>"
        end
      end

      def fn_body_label(fnote)
        if fnote.ancestors("table, figure").empty? ||
            !fnote.ancestors("name, fmt-name").empty?
          super
        else
          "<sup>#{fn_label(fnote)}" \
            "<span class='fmt-label-delim'>)</span></sup>"
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

      def ul_label_list(_elem)
        %w(&#x2013; &#x2022; &#x6f;)
      end

      def dl(xml)
        super
        (xml.xpath(ns("//dl")) -
         xml.xpath(ns("//table//dl | //figure//dl | //formula//dl | //dl//dl")))
          .each do |d|
            dl2(d)
          end
      end

      def dl2(dlist)
        ins = dlist.at(ns("./dt"))
        ins.previous =
          '<colgroup><col width="20%"/><col width="80%"/></colgroup>'
      end

      def termnote_delim(_elem, lbl)
        l10n(" &#x2013; ", { prev: lbl })
      end

      include Init
    end
  end
end

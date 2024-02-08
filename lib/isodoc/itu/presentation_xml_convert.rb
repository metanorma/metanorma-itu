require_relative "init"
require "roman-numerals"
require "isodoc"
require_relative "../../relaton/render/general"
require_relative "presentation_bibdata"
require_relative "presentation_preface"

module IsoDoc
  module ITU
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def initialize(options)
        @hierarchical_assets = options[:hierarchicalassets]
        super
      end

      def convert1(docxml, filename, dir)
        insert_preface_sections(docxml)
        super
      end

      def eref(docxml)
        docxml.xpath(ns("//eref")).each { |f| eref1(f) }
      end

      def origin(docxml)
        docxml.xpath(ns("//origin[not(termref)]")).each { |f| eref1(f) }
      end

      def quotesource(docxml)
        docxml.xpath(ns("//quote/source")).each { |f| eref1(f) }
      end

      def eref1(elem)
        get_eref_linkend(elem)
      end

      def note1(elem)
        elem["type"] == "title-footnote" and return
        super
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

      def bibrenderer
        ::Relaton::Render::ITU::General.new(language: @lang)
      end

      def bibrender_formattedref(formattedref, _xml)
        formattedref << "." unless /\.$/.match?(formattedref.text)
        id = reference_format_start(formattedref.parent) and
          formattedref.children.first.previous = id
      end

      def bibrender_relaton(xml, renderings)
        f = renderings[xml["id"]][:formattedref]
        ids = reference_format_start(xml)
        f &&= "<formattedref>#{ids}#{f}</formattedref>"
        # retain date in order to generate reference tag
        keep = "./docidentifier | ./uri | ./note | ./date | ./biblio-tag"
        xml.children = "#{f}#{xml.xpath(ns(keep)).to_xml}"
      end

      def multi_bibitem_ref_code(bib)
        skip = IsoDoc::Function::References::SKIP_DOCID
        skip1 = "@type = 'metanorma' or @type = 'metanorma-ordinal'"
        prim = "[@primary = 'true']"
        id = bib.xpath(ns("./docidentifier#{prim}[not(#{skip} or #{skip1})]"))
        id.empty? and id = bib.xpath(ns("./docidentifier#{prim}[not(#{skip1})]"))
        id.empty? and id = bib.xpath(ns("./docidentifier[not(#{skip} or #{skip1})]"))
        id.empty? and id = bib.xpath(ns("./docidentifier[not(#{skip1})]"))
        id.empty? and return id
        id.sort_by { |i| i["type"] == "ITU" ? 0 : 1 }
      end

      def render_multi_identifiers(ids)
        ids.map do |id|
          if id["type"] == "ITU" then doctype_title(id)
          else
            docid_prefix(id["type"], id.text.sub(/^\[/, "").sub(/\]$/, ""))
          end
        end.join("&#xA0;| ")
      end

      def reference_format_start(bib)
        id = multi_bibitem_ref_code(bib)
        id1 = render_multi_identifiers(id)
        out = id1
        date = bib.at(ns("./date[@type = 'published']/on | " \
          "./date[@type = 'published']/from")) and
          out << " (#{date.text.sub(/-.*$/, '')})"
        out += ", " if date || !id1.empty?
        out
      end

      def titlecase(str)
        str.gsub(/ |_|-/, " ").split(/ /).map(&:capitalize).join(" ")
      end

      def doctype_title(id)
        type = id.parent&.at(ns("./ext/doctype"))&.text || "recommendation"
        if type == "recommendation" &&
            /^(?<prefix>ITU-[A-Z][  ][A-Z])[  .-]Sup[a-z]*\.[  ]?(?<num>\d+)$/ =~ id.text
          "#{prefix}-series Recommendations – Supplement #{num}"
        else
          d = docid_prefix(id["type"], id.text.sub(/^\[/, "").sub(/\]$/, ""))
          "#{titlecase(type)} #{d}"
        end
      end

      def twitter_cldr_localiser_symbols
        { group: "'" }
      end

      def clause1(elem)
        @doctype == "resolution" or return super
        %w(sections bibliography).include? elem.parent.name or return super
        @suppressheadingnumbers || elem["unnumbered"] and return
        t = elem.at(ns("./title")) and t["depth"] = "1"
        lbl = @xrefs.anchor(elem["id"], :label, false) or return
        elem.previous =
          "<p keep-with-next='true' class='supertitle'>" \
          "#{@i18n.get['section'].upcase} #{lbl}</p>"
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

      def info(isoxml, out)
        @meta.ip_notice_received isoxml, out
        @meta.techreport isoxml, out
        super
      end

      def bibliography_bibitem_number1(bib, idx)
        mn = bib.at(ns(".//docidentifier[@type = 'metanorma']")) and
          /^\[?\d+\]?$/.match?(mn.text) and
          mn["type"] = "metanorma-ordinal"
        if (mn = bib.at(ns(".//docidentifier[@type = 'metanorma-ordinal']"))) &&
            !bibliography_bibitem_number_skip(bib)
          idx += 1
          mn.children = "[#{idx}]"
        end
        idx
      end

      def bibliography_bibitem_number_skip(bibitem)
        @xrefs.klass.implicit_reference(bibitem) ||
          bibitem["hidden"] == "true" || bibitem.parent["hidden"] == "true"
      end

      def norm_ref_entry_code(_ordinal, idents, _ids, _standard, datefn, _bib)
        ret = (idents[:metanorma] || idents[:ordinal] || idents[:sdo]).to_s
        /^\[.+\]$/.match?(ret) or ret = "[#{ret}]"
        ret += datefn
        ret.empty? and return ret
        ret.gsub("-", "&#x2011;").gsub(/ /, "&#xa0;")
      end

      def biblio_ref_entry_code(_ordinal, idents, _id, _standard, datefn, _bib)
        ret = (idents[:metanorma] || idents[:ordinal] || idents[:sdo]).to_s
        /^\[.+\]$/.match?(ret) or ret = "[#{ret}]"
        ret += datefn
        ret.empty? and return ret
        ret.gsub("-", "&#x2011;").gsub(/ /, "&#xa0;")
      end

      def toc_title(docxml)
        @doctype == "resolution" and return
        super
      end

      def middle_title(isoxml)
        s = isoxml.at(ns("//sections")) or return
        titfn = isoxml.at(ns("//note[@type = 'title-footnote']"))
        if @meta.get[:doctype] == "Resolution"
          middle_title_resolution(isoxml, s.children.first)
        else
          middle_title_recommendation(isoxml, s.children.first)
        end
        titfn and renumber_footnotes(isoxml)
      end

      def renumber_footnotes(isoxml)
        (isoxml.xpath(ns("//fn")) - isoxml.xpath(ns("//table//fn | //figure//fn")))
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

      include Init
    end
  end
end

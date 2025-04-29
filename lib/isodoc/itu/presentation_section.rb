module IsoDoc
  module Itu
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def clause1(elem)
        clause1_super?(elem) and return super
        lbl = @xrefs.anchor(elem["id"], :label, false)
        oldsuppressheadingnumbers = @suppressheadingnumbers
        @suppressheadingnumbers = true
        super
        @suppressheadingnumbers = oldsuppressheadingnumbers
        lbl.blank? || elem["unnumbered"] and return
        elem.previous =
          "<p keep-with-next='true' class='supertitle'>" \
          "#{labelled_autonum(@i18n.get['section'].upcase, elem['id'],
                              lbl)}</p>"
        # "<span element='fmt-element-name'>#{@i18n.get['section'].upcase}</span> #{autonum(elem['id'], lbl)}</p>"
      end

      def clause1_super?(elem)
        @doctype != "resolution" ||
          !%w(sections bibliography).include?(elem.parent.name)
      end

      def annex1(elem)
        if @doctype == "resolution"
          annex1_resolution(elem)
        else
          super
          annex1_non_resolution(elem)
        end
      end

      def annex1_resolution(elem)
        elem.elements.first.previous = annex1_supertitle(elem)
        # TODO: do not alter title, alter semx/@element = title
        t = elem.at(ns("./title")) and
          t.children = "<strong>#{to_xml(t.children)}</strong>"
        prefix_name(elem, {}, nil, "title")
      end

      def annex1_non_resolution(elem)
        info = elem["obligation"] == "informative"
        ins = elem.at(ns("./fmt-xref-label")) || elem.at(ns("./fmt-title"))
        p = (info ? @i18n.inform_annex : @i18n.norm_annex)
          .gsub("%", @i18n.doctype_dict[@meta.get[:doctype_original]] || "")
        ins.next = %(<p class="annex_obligation"><span class='fmt-obligation'>#{p}</span></p>)
      end

      def annex1_supertitle(elem)
        lbl = @xrefs.anchor(elem["id"], :label)
        res = elem.at(ns("//bibdata/title[@type = 'resolution']"))
        subhead = @i18n.l10n("(#{@i18n.get['to']} #{to_xml(res.children)})")
        "<p class='supertitle'>#{autonum(elem['id'],
                                         lbl)}<br/>#{subhead}</p>"
      end

      def middle_title(isoxml)
        s = isoxml.at(ns("//sections")) or return
        # isoxml.at(ns("//note[@type = 'title-footnote']"))
        case @doctype
        when "resolution"
          middle_title_resolution(isoxml, s.children.first)
        when "contribution"
        else
          middle_title_recommendation(isoxml, s.children.first)
        end
        # titfn and renumber_footnotes(isoxml)
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
            ret += <<~FN.strip
              <fn id='_#{UUIDTools::UUID.random_create}' reference='H#{i}'>#{f.remove.children.to_xml}</fn>
            FN
          end
        ret
      end
    end
  end
end

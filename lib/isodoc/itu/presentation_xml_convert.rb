require_relative "init"
require "roman-numerals"
require "isodoc"
require_relative "../../relaton/render/general"
require_relative "presentation_bibdata"

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

      def insert_preface_sections(docxml)
        x = insert_editors_clause(docxml) and
          editors_insert_pt(docxml).next = x
      end

      def editors_insert_pt(docxml)
        docxml.at(ns("//preface")) || docxml.at(ns("//sections"))
          .add_previous_sibling("<preface> </preface>").first
        ins = docxml.at(ns("//preface/acknolwedgements")) and return ins
        docxml.at(ns("//preface")).children[-1]
      end

      def insert_editors_clause(doc)
        ret = extract_editors(doc) or return
        eds = ret[:names].each_with_object([]).with_index do |(_x, acc), i|
          acc << { name: ret[:names][i], affiliation: ret[:affiliations][i],
                   email: ret[:emails][i] }
        end
        editors_clause(eds)
      end

      def extract_editors(doc)
        e = doc.xpath(ns("//bibdata/contributor[role/@type = 'editor']/person"))
        e.empty? and return
        { names: @meta.extract_person_names(e),
          affiliations: @meta.extract_person_affiliations(e),
          emails: e.reduce([]) { |ret, p| ret << p.at(ns("./email"))&.text } }
      end

      def editors_clause(eds)
        ed_lbl = @i18n.inflect(@i18n.get["editor_full"],
                               number: eds.size > 1 ? "pl" : "sg")
        ed_lbl &&= l10n("#{ed_lbl.capitalize}:")
        mail_lbl = l10n("#{@i18n.get['email']}: ")
        ret = <<~SUBMITTING
          <clause id="_#{UUIDTools::UUID.random_create}" type="editors">
          <table id="_#{UUIDTools::UUID.random_create}" unnumbered="true"><tbody>
        SUBMITTING
        ret += editor_table_entries(eds, ed_lbl, mail_lbl)
        "#{ret}</tbody></table></clause>"
      end

      def editor_table_entries(eds, ed_lbl, mail_lbl)
        eds.each_with_index.with_object([]) do |(n, i), m|
          mail = ""
          n[:email] and
            mail = "#{mail_lbl}<link target='mailto:#{n[:email]}'>" \
                   "#{n[:email]}</link>"
          aff = n[:affiliation].empty? ? "" : "<br/>#{n[:affiliation]}"
          th = "<th>#{i.zero? ? ed_lbl : ''}</th>"
          m << "<tr>#{th}<td>#{n[:name]}#{aff}</td><td>#{mail}</td></tr>"
        end.join("\n")
      end

      def prefix_container(container, linkend, node, _target)
        l10n("#{linkend} #{@i18n.get['in']} #{anchor_xref(node, container)}")
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
        contents = non_locality_elems(node).select do |c|
          !c.text? || /\S/.match(c)
        end
        return unless contents.empty?

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
      end

      def bibrender_relaton(xml, renderings)
        f = renderings[xml["id"]][:formattedref]
        f &&= "<formattedref>#{f}</formattedref>"
        # retain date in order to generate reference tag
        keep = "./docidentifier | ./uri | ./note | ./date | ./biblio-tag"
        xml.children = "#{f}#{xml.xpath(ns(keep)).to_xml}"
      end

      def twitter_cldr_localiser_symbols
        { group: "'" }
      end

      def clause1(elem)
        elem.at(ns("//bibdata/ext/doctype"))&.text ==
          "resolution" or return super
        %w(sections bibliography).include? elem.parent.name or return super
        @suppressheadingnumbers || elem["unnumbered"] and return

        t = elem.at(ns("./title")) and t["depth"] = "1"
        lbl = @xrefs.anchor(elem["id"], :label, false) or return
        elem.elements.first.previous =
          "<p keep-with-next='true' class='supertitle'>" \
          "#{@i18n.get['section'].upcase} #{lbl}</p>"
      end

      def annex1(elem)
        elem.at(ns("//bibdata/ext/doctype"))&.text == "resolution" or
          return super

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
        return super unless node["class"] == "steps" ||
          node.at(".//ancestor::xmlns:ol[@class = 'steps']")

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

      def norm_ref_entry_code(_ordinal, idents, _ids, _standard, datefn, _bib)
        ret = (idents[:metanorma] || idents[:sdo] || idents[:ordinal]).to_s
        !idents[:metanorma] && idents[:sdo] and ret = "[#{ret}]"
        ret += datefn
        ret.empty? and return ret
        ret.gsub("-", "&#x2011;").gsub(/ /, "&#xa0;")
      end

      def biblio_ref_entry_code(_ordinal, idents, _id, _standard, datefn, _bib)
        ret = (idents[:metanorma] || idents[:sdo] || idents[:ordinal]).to_s
        !idents[:metanorma] && idents[:sdo] and ret = "[#{ret}]"
        ret += datefn
        ret.empty? and return ret
        ret.gsub("-", "&#x2011;").gsub(/ /, "&#xa0;")
      end

      def toc_title(docxml)
        doctype = docxml.at(ns("//bibdata/ext/doctype"))
        doctype&.text == "resolution" and return
        super
      end

      def middle_title(isoxml)
        s = docxml.at(ns("//sections")) or return
        if @meta.get[:doctype] == "Resolution"
          middle_title_resolution(isoxml, s.children.first)
        else
          middle_title_recommendation(isoxml, s.children.first)
        end
      end

      def middle_title_resolution(isoxml, out)
        res = isoxml.at(ns("//bibdata/title[@type = 'resolution']"))
        out.previous =
          "<p class='zzSTDTitle1' align='center'>#{res.children.to_xml}</p>"
        out.previous = "<p class='zzSTDTitle2'>#{@meta.get[:doctitle]}</p>"
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
        ret += "<p class='zzSTDTitle2'>#{@meta.get[:doctitle]}"
        ret += "#{title_footnotes(isoxml)}</p>"
        s = @meta.get[:docsubtitle] and ret += "<p class='zzSTDTitle3'>#{s}</p>"
        out.previous = ret
      end

      def title_footnotes(isoxml)
        ret = ""
        isoxml.xpath(ns("//note[@type = 'title-footnote']")).each do |f|
          ret += "<fn>#{f.remove.children.to_xml}</fn>"
        end
        ret
      end

      def rearrange_clauses(docxml)
        super
        k = keywords(docxml) or return
        if a = docxml.at(ns("//preface/abstract"))
          a.next = k
          elseif a = docxml.at(ns("//preface"))
          a.children.first.previous = k
        end
      end

      def keywords(_docxml)
        kw = @meta.get[:keywords]
        kw.nil? || kw.empty? and return
        "<clause type='keyword'><title>#{@i18n.keywords}</title>" \
          "<p>#{kw.join(', ')}.</p>"
      end

      include Init
    end
  end
end

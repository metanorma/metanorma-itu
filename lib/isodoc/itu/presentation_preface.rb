module IsoDoc
  module ITU
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def insert_preface_sections(docxml)
        if @doctype == "contribution"
          x = contribution_table(docxml) and
            contribution_table_insert_pt(docxml).next = x
        else
          x = insert_editors_clause(docxml) and
            editors_insert_pt(docxml).next = x
        end
      end

      def editors_insert_pt(docxml)
        docxml.at(ns("//preface")) || docxml.at(ns("//sections"))
          .add_previous_sibling("<preface> </preface>").first
        ins = docxml.at(ns("//preface/acknolwedgements")) and return ins
        docxml.at(ns("//preface")).children[-1]
      end

      def contribution_table_insert_pt(docxml)
        docxml.at(ns("//preface")) || docxml.at(ns("//sections"))
          .add_previous_sibling("<preface> </preface>").first
        docxml.at(ns("//preface")).children.first.before(" ").previous
      end

      def contribution_table(_doc)
        @doctype == "contribution" or return
        bureau = bold_and_upcase(@meta.get[:bureau_full])
        <<~TABLE
          <clause unnumbered="true" type="contribution-metadata">
          <table class="contribution-metadata" unnumbered="true" width="100%">
          <colgroup><col width="11.8%"/><col width="41.2%"/><col width="47.0%"/></colgroup>
          <thead>
          <tr><th rowspan="3"><image height="56" width="56" src="#{@meta.get[:logo_small]}"/></th>
          <td rowspan="3"><p style="font-size:8pt;margin-top:6pt;margin-bottom:0pt;">#{@i18n.international_telecommunication_union.upcase}</p>
          <p class="bureau_big" style="font-size:13pt;margin-top:6pt;margin-bottom:0pt;">#{bureau}</p>
          <p style="font-size:10pt;margin-top:6pt;margin-bottom:0pt;">#{@i18n.studyperiod.sub('%', @meta.get[:study_group_period]).upcase}</p></th>
          <th align="right"><p style="font-size:16pt;">#{@meta.get[:docnumber]}</p></th></tr>
          <tr><th align="right"><p  style="font-size:14pt;">#{@meta.get[:group].upcase}</p></th></tr>
          <tr>
          <th align="right"><p style="font-size:14pt;">#{@i18n.l10n("#{@i18n.original}: #{@i18n.current_language}")}</p></th>
          </tr></thead>
          <tbody>
          <tr><th align="left" width="95">#{colon_i18n(@i18n.questions)}</th><td>#{@meta.get[:questions]}</td>
          <td align="right">#{@i18n.l10n("#{@meta.get[:meeting_place]}, #{@meta.get[:meeting_date]}")}</td></tr>
          <tr><th align="center" colspan="3">#{@i18n.get['doctype_dict']['contribution'].upcase}</th></tr>
          <tr><th align="left" width="95">#{colon_i18n(@i18n.document_source)}</th><td colspan="2">#{@meta.get[:source]}</td></tr>
          <tr><th align="left" width="95">#{colon_i18n(@i18n.title)}</th><td colspan="2">#{@meta.get[:doctitle_en]}</td></tr>
          #{contribution_table_contacts}
          </tbody></table>
          </clause>
        TABLE
      end

      def colon_i18n(text)
        @i18n.l10n("#{text}:")
      end

      def bold_and_upcase(xml)
        x = Nokogiri::XML("<root>#{xml}</root>")
        x.traverse do |e|
          e.text? or next
          e.replace("<strong>#{e.text.upcase}</strong>")
        end
        x.root.children.to_xml
      end

      def contribution_table_contacts
        n = (0..@meta.get[:authors]&.size).each_with_object([]) do |i, ret|
          ret << contribution_table_contact(i)
        end
        n.map do |x|
          lbl = colon_i18n(@i18n.contact)
          "<tr><th align='left' width='95'>#{lbl}</th>#{x}</tr>"
        end.join("\n")
      end

      def contribution_table_contact(idx)
        <<~CELL
          <td>#{@meta.get[:authors][idx]}<br/>
          #{@meta.get[:affiliations][idx]}<br/>
          #{@meta.get[:addresses][idx]}</td>
          <td>#{@i18n.tel_abbrev}<tab/>#{@meta.get[:phones][idx]}<br/>
          #{@i18n.email}<tab/>#{@meta.get[:emails][idx]}</td>
        CELL
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

      def rearrange_clauses(docxml)
        super
        insert_preface_sections(docxml)
        a = docxml.at(ns("//preface/abstract"))
        keywords_abstract_swap(a, keywords(docxml), docxml)
        c = docxml.at(ns("//preface/clause[@type='contribution-metadata']")) and
          a and c.next = a
        abstract_render(a)
      end

      def keywords_abstract_swap(abstract, keywords, docxml)
        @doctype == "contribution" and return
        keywords or return
        if abstract then abstract.next = keywords
        else
          p = contribution_table_insert_pt(docxml)
          p.next = keywords
        end
      end

      def abstract_render(abstract)
        @doctype == "contribution" or return
        abstract.at(ns("./title"))&.remove
        abstract.children = <<~TABLE
          <table class="abstract" unnumbered="true" width="100%">
          <colgroup><col width="11.8%"/><col width="78.2%"/></colgroup>
          <tbody>
          <tr><th align="left" width="95"><p>#{colon_i18n(@i18n.abstract)}</p></th>
          <td>#{abstract.children.to_xml}</td></tr>
          </tbody></table>
        TABLE
      end

      def keywords(_docxml)
        kw = @meta.get[:keywords]
        kw.nil? || kw.empty? || @doctype == "contribution" and return
        "<clause type='keyword'><title>#{@i18n.keywords}</title>" \
          "<p>#{@i18n.l10n(kw.join(', '))}.</p>"
      end

      def toc_title(docxml)
        %w(resolution contribution).include?(@doctype) and return
        super
      end

      include Init
    end
  end
end

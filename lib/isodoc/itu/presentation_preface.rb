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
        <<~TABLE
          <clause unnumbered="true">
          <table class="contribution-metadata" unnumbered="true"><thead>
          <tr><th rowspan="3"><image src="#{@meta.get[:logo_sp]}"/></th>
          <th rowspan="3"><p>#{@i18n.international_telecommunication_union}</p>
          <p class="bureau_big">#{@meta.get[:bureau_full]}</p>
          <p>#{@i18n.studyperiod.sub('%', @meta.get[:study_group_period])}</th>
          <th>#{@meta.get[:docnumber]}<th></tr>
          <tr><th>#{@meta.get[:group]}</th></tr>
          <tr><th>#{@i18n.l10n("#{@i18n.original}: #{@i18n.current_language}")}</th></tr></thead>
          <tbody>
          <tr><th>#{@i18n.l10n("#{@i18n.questions}:")}</th><td>#{@meta.get[:questions]}</td>
          <td align="right">#{@i18n.l10n("#{@meta.get[:meeting_place]}, #{@meta.get[:meeting_date]}")}</td></tr>
          <tr><th align="center">#{@i18n.get['doctype_dict']['contribution']}</th></tr>
          <tr><th>#{@i18n.document_source}</th><td>#{@meta.get[:source]}</td></tr>
          <tr><th>#{@i18n.title}</th><td>#{@meta.get[:doctitle_en]}</td></tr>
          #{contribution_table_contacts}
          </tbody></table>
          </clause>
        TABLE
      end

      def contribution_table_contacts
        (0..@meta.get[:authors]&.size).each_with_object([]) do |i, ret|
          ret << contribution_table_contact(i)
        end.map { |x| "<tr><th>#{@i18n.contact}</th>#{x}</tr>" }.join("\n")
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
        k = keywords(docxml) or return
        if a = docxml.at(ns("//preface/abstract"))
          a.next = k
        elsif a = docxml.at(ns("//preface"))
          a.children.first.previous = k
        end
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

module IsoDoc
  module ITU
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
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
        kw.nil? || kw.empty? and return
        "<clause type='keyword'><title>#{@i18n.keywords}</title>" \
          "<p>#{kw.join(', ')}.</p>"
      end

      include Init
    end
  end
end
module IsoDoc
  module Itu
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def contribution_table_insert_pt(docxml)
        docxml.at(ns("//preface")) || docxml.at(ns("//sections"))
          .add_previous_sibling("<preface> </preface>").first
        docxml.at(ns("//preface")).children.first.before(" ").previous
      end

      def contribution_table(_doc)
        @doctype == "contribution" or return
        bureau = bold_and_upcase(@meta.get[:bureau_full])
        <<~TABLE
          <clause #{add_id_text} unnumbered="true" type="contribution-metadata">
          <table #{add_id_text} class="contribution-metadata" unnumbered="true" width="100%">
          <colgroup><col width="11.8%"/><col width="41.2%"/><col width="47.0%"/></colgroup>
          <thead>
          <tr #{add_id_text}><th rowspan="3" #{add_id_text}><image height="56" width="56" src="#{@meta.get[:logo_small]}"/></th>
          <td #{add_id_text} rowspan="3"><p style="font-size:8pt;margin-top:6pt;margin-bottom:0pt;">#{@i18n.international_telecommunication_union.upcase}</p>
          <p class="bureau_big" style="font-size:13pt;margin-top:6pt;margin-bottom:0pt;">#{bureau}</p>
          <p style="font-size:10pt;margin-top:6pt;margin-bottom:0pt;">#{@i18n.studyperiod.sub('%', @meta.get[:study_group_period]).upcase}</p></th>
          <th #{add_id_text} align="right"><p style="font-size:16pt;">#{@meta.get[:docnumber]}</p></th></tr>
          <tr #{add_id_text}><th #{add_id_text} align="right"><p  style="font-size:14pt;">#{@meta.get[:group].upcase}</p></th></tr>
          <tr #{add_id_text}>
          <th #{add_id_text} align="right"><p style="font-size:14pt;">#{@i18n.l10n("#{@i18n.original}: #{@i18n.current_language}")}</p></th>
          </tr></thead>
          <tbody>
          <tr #{add_id_text}><th #{add_id_text} align="left" width="95">#{colon_i18n(@i18n.questions)}</th><td #{add_id_text}>#{@meta.get[:questions]}</td>
          <td #{add_id_text} align="right">#{@i18n.l10n("#{@meta.get[:meeting_place]}, #{@meta.get[:meeting_date]}")}</td></tr>
          <tr #{add_id_text}><th #{add_id_text} align="center" colspan="3">#{@i18n.get['doctype_dict']['contribution'].upcase}</th></tr>
          <tr #{add_id_text}><th #{add_id_text} align="left" width="95">#{colon_i18n(@i18n.document_source)}</th><td #{add_id_text} colspan="2">#{@meta.get[:source]}</td></tr>
          <tr #{add_id_text}><th #{add_id_text} align="left" width="95">#{colon_i18n(@i18n.title)}</th><td #{add_id_text} colspan="2">#{@meta.get[:doctitle_en]}</td></tr>
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
          "<tr #{add_id_text}>"  \
            "<th #{add_id_text} align='left' width='95'>#{lbl}</th>#{x}</tr>"
        end.join("\n")
      end

      def contribution_table_contact(idx)
        @meta.get[:emails][idx] and
          e = "<br/>#{@i18n.email}<tab/>#{@meta.get[:emails][idx]}"
        <<~CELL
          <td #{add_id_text}>#{@meta.get[:authors][idx]}<br/>
          #{@meta.get[:affiliations][idx]}<br/>
          #{@meta.get[:addresses][idx]}</td>
          <td #{add_id_text}>#{@i18n.tel_abbrev}<tab/>#{@meta.get[:phones][idx]}#{e}</td>
        CELL
      end

      def extract_clause_data(clause, type)
        x = clause.at(ns("./clause[@type = '#{type}']")) or return
        ret = x.dup
        ret.at(ns("./title"))&.remove
        ret.at(ns("./fmt-title"))&.remove
        ret.children.to_xml
      end

      def contribution_justification_contact(idx)
        @meta.get[:emails][idx] and
          e = ", #{@i18n.email}<tab/>#{@meta.get[:emails][idx]}"
        <<~CELL
          #{@meta.get[:authors][idx]}<br/>
          #{@meta.get[:affiliations][idx]}<br/>
          #{@meta.get[:addresses][idx]}#{e}
        CELL
      end

      def contrib_justification_contacts
        (0..@meta.get[:authors]&.size).each_with_object([]) do |i, ret|
          ret << contribution_justification_contact(i)
        end
      end

      def contribution_justification_title(_doc)
        n = @meta.get[:docnumber]
        if @meta.get[:subdoctype] == "recommendation"
          "A.1 justification for proposed draft new Recommendation #{n}"
        else
          s = @meta.get[:subdoctype]
          "A.13 justification for proposed draft new #{s} "\
            "#{n} “#{@meta.get[:doctitle_en]}”"
        end
      end

      def contribution_justification_auths
        auths = contrib_justification_contacts
        auths_tail = auths[1..auths.size].map do |x|
          "<tr #{add_id_text}><td #{add_id_text} colspan='2'>#{x}</td></td>"
        end.join("\n")
        [auths, auths_tail]
      end

      def contribution_justification(doc)
        @doctype == "contribution" or return
        annex = doc.at(ns("//annex[@type = 'justification']")) or return
        auths, auths_tail = contribution_justification_auths
        annex.children = <<~TABLE
          <title #{add_id_text}>#{contribution_justification_title(doc)}</title>
          <table #{add_id_text} class="contribution-metadata" unnumbered="true" width="100%">
            <colgroup><col width="15.9%"/><col width="6.1%"/><col width="45.5%"/><col width="17.4%"/><col width="15.1%"/></colgroup>
            <tbody>
            <tr #{add_id_text}>
            <th #{add_id_text} align="left">#{colon_i18n(@i18n.questions)}</th><td #{add_id_text}>#{@meta.get[:questions]}</td>
            <th #{add_id_text} align="left">Proposed new ITU-T #{@meta.get[:subdoctype]}</th>
            <td #{add_id_text} colspan="2">#{@i18n.l10n("#{@meta.get[:meeting_place]}, #{@meta.get[:meeting_date]}")}</td>
            </tr>
            <tr #{add_id_text}><th #{add_id_text} align="left">Reference and title:</th>
            <td #{add_id_text} colspan="4">Draft new #{@meta.get[:subdoctype]} on “#{@meta.get[:doctitle_en]}”</td>
            </tr>
            <tr #{add_id_text}>
            <th #{add_id_text} align="left">Base text:</th><td #{add_id_text} colspan="2">#{extract_clause_data(annex, 'basetext')}</td>
            <th #{add_id_text} align="left">Timing:</th><td #{add_id_text}>#{@meta.get[:timing]}</td>
            </tr>
            <tr #{add_id_text}><th #{add_id_text} align="left" rowspan="#{auths.size - 1}">Editor(s):</th>
            <td #{add_id_text} colspan="2">#{auths[0]}</td>
            <th #{add_id_text} align="left" rowspan="#{auths.size - 1}">Approval process:</th>
            <td #{add_id_text} rowspan="#{auths.size - 1}">#{@meta.get[:approval_process]}</td>
            </tr>
            #{auths_tail}
            <tr #{add_id_text}><td #{add_id_text} colspan="5"><p><strong>Scope</strong> (defines the intent or object of the Recommendation and the aspects covered, thereby indicating the limits of its applicability):</p>#{extract_clause_data(annex, 'scope')}</td></tr>
            <tr #{add_id_text}><td #{add_id_text} colspan="5"><p><strong>Summary</strong> (provides a brief overview of the purpose and contents of the Recommendation, thus permitting readers to judge its usefulness for their work):</p>#{extract_clause_data(annex, 'summary')}</td></tr>
            <tr #{add_id_text}><td #{add_id_text} colspan="5"><p><strong>Relations to ITU-T Recommendations or to other standards</strong> (approved or under development):</p>#{extract_clause_data(annex, 'relatedstandards')}</td></tr>
            <tr #{add_id_text}><td #{add_id_text} colspan="5"><p><strong>Liaisons with other study groups or with other standards bodies:</strong></p>#{extract_clause_data(annex, 'liaisons')}</td></tr>
            <tr #{add_id_text}><td #{add_id_text} colspan="5"><p><strong>Supporting members that are committing to contributing actively to the work item:</strong></p>#{extract_clause_data(annex, 'supportingmembers')}</td></tr>
            </tbody>
          </table>
        TABLE
      end
    end
  end
end

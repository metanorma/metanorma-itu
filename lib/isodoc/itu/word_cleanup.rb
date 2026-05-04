module IsoDoc
  module Itu
    class WordConvert < IsoDoc::WordConvert
      def word_preface_cleanup(docxml)
        docxml.xpath("//h1[@class = 'AbstractTitle'] | " \
                     "//h1[@class = 'IntroTitle']").each do |h2|
                       h2.name = "p"
                       h2["class"] = "h1Preface"
                     end
      end

      def word_term_cleanup(docxml); end

      def word_cleanup(docxml)
        word_footnote_cleanup(docxml)
        word_title_cleanup(docxml)
        word_preface_cleanup(docxml)
        word_term_cleanup(docxml)
        word_history_cleanup(docxml)
        authority_hdr_cleanup(docxml)
        table_list_style(docxml)
        super
        docxml
      end

      def word_footnote_cleanup(docxml)
        docxml.xpath("//aside").each do |a|
          a.first_element_child
            .add_first_child '<span style="mso-tab-count:1"/>'
        end
      end

      def word_title_cleanup(docxml)
        docxml.xpath("//p[@class = 'annex_obligation']").each do |h|
          h.next_element&.name == "p" or next
          h.next_element["class"] ||= "Normalaftertitle"
        end
        docxml.xpath("//p[@class = 'FigureTitle']").each do |h|
          h.parent&.next_element&.name == "p" or next
          h.parent.next_element["class"] ||= "Normalaftertitle"
        end
      end

      def word_history_cleanup(docxml)
        docxml.xpath("//div[@id='_history']//table").each do |t|
          t["class"] = "MsoNormalTable"
          t.xpath(".//td").each { |td| td["style"] = nil }
        end
      end

      def word_preface(docxml)
        super
        { abstractbox: "Abstract", historybox: "history",
          sourcebox: "source", keywordsbox: "Keyword",
          changelogbox: "change_log" }.each do |k, v|
          box = docxml.at("//div[@id='#{k}']")
          content = docxml.at("//div[@class = '#{v}']")
          content.parent = box if content && box
        end
      end

      def toWord(result, filename, dir, header)
        Html2Doc.new(
          filename: filename, imagedir: @localdir,
          stylesheet: @wordstylesheet&.path,
          header_file: header&.path, dir: dir,
          asciimathdelims: [@openmathdelim, @closemathdelim],
          liststyles: { ul: @ulstyle, ol: @olstyle, steps: "l4" }
        ).process(result)
        header&.unlink
        @wordstylesheet&.unlink if @wordstylesheet.is_a?(Tempfile)
      end

      def postprocess_cleanup(result)
        result = from_xhtml(cleanup(to_xhtml(textcleanup(result))))
        result = populate_template(result, :word)
        from_xhtml(word_cleanup(to_xhtml(result)))
          .gsub("-DOUBLE_HYPHEN_ESCAPE-", "--")
      end

      def wordstylesheet_update
        super
        unless @landscapestyle.nil? || @landscapestyle.empty?
          @wordstylesheet&.open
          @wordstylesheet&.write(@landscapestyle)
          @wordstylesheet&.close
        end
        @wordstylesheet
      end

      def authority_hdr_cleanup(docxml)
        authority_hdr_cleanup1(docxml)
        authority_hdr_cleanup2(docxml)
      end

      def authority_hdr_cleanup1(docxml)
        docxml&.xpath("//div[@id = 'draft-warning']")&.each do |d|
          d.xpath(".//h1 | .//h2").each do |p|
            p.name = "p"
            p["class"] = "draftwarningHdr"
          end
        end
      end

      def authority_hdr_cleanup2(docxml)
        %w(copyright license legal).each do |t|
          docxml.xpath("//div[@class = 'boilerplate-#{t}']")&.each do |d|
            para = d.at("./descendant::h1[2]") and
              para.previous = "<p>&#xa0;</p><p>&#xa0;</p><p>&#xa0;</p>"
            d.xpath(".//h1 | .//h2").each do |p|
              p.name = "p"
              p["class"] = "boilerplateHdr"
            end
          end
        end
      end

      def authority_cleanup(docxml)
        dest = docxml.at("//div[@class = 'draft-warning']")
        auth = docxml.at("//div[@id = 'draft-warning']")
        dest and auth and dest.replace(auth.remove)
        %w(copyright license legal).each do |t|
          authority_cleanup1(docxml, t)
        end
        coverpage_note_cleanup(docxml)
      end

      def authority_cleanup1(docxml, type)
        auth, dest = authority_cleanup1_prep(docxml, type)
        (auth && dest) or return
        type == "copyright" and para = auth.at(".//p") and
          para["class"] = "boilerplateHdr"
        auth.xpath(".//p[not(@class)]").each do |p|
          p["class"] = "boilerplate"
        end
        type == "copyright" or
          auth << "<p>&#xa0;</p><p>&#xa0;</p><p>&#xa0;</p>"
        dest.replace(auth.remove)
      end

      def authority_cleanup1_prep(docxml, type)
        dest = docxml.at("//div[@id = 'boilerplate-#{type}-destination']")
        auth = docxml.at("//div[@class = 'boilerplate-#{type}']")
        auth.remove if auth && !dest
        [auth, dest]
      end

      TOPLIST = "[not(ancestor::ul) and not(ancestor::ol)]".freeze

      def table_list_style(xml)
        xml.xpath("//table//ul#{TOPLIST} | //table//ol#{TOPLIST}").each do |t|
          table_list_style1(t, 1)
        end
      end

      def table_list_style1(tab, num)
        (tab.xpath(".//li") - tab.xpath(".//ol//li | .//ul//li")).each do |t1|
          indent_list(t1, num)
          t1.xpath("./div | ./p").each { |p| indent_list(p, num) }
          (t1.xpath(".//ul") - t1.xpath(".//ul//ul | .//ol//ul")).each do |t2|
            table_list_style1(t2, num + 1)
          end
          (t1.xpath(".//ol") - t1.xpath(".//ul//ol | .//ol//ol")).each do |t2|
            table_list_style1(t2, num + 1)
          end
        end
      end

      def indent_list(list, num)
        list["style"] = (list["style"] ? "#{list['style']};" : "")
        list["style"] += "margin-left: #{num * 0.5}cm;text-indent: -0.5cm;"
      end
    end
  end
end

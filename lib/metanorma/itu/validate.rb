module Metanorma
  module Itu
    class Converter < Standoc::Converter
      def bibdata_validate(doc)
        doctype_validate(doc)
        stage_validate(doc)
      end

      def doctype_validate(_xmldoc)
        %w(recommendation recommendation-supplement recommendation-amendment
           recommendation-corrigendum recommendation-errata recommendation-annex
           focus-group implementers-guide technical-paper technical-report
           joint-itu-iso-iec service-publication
           contribution).include? @doctype or
          @log.add("ITU_1", nil, params: [@doctype])
      end

      def stage_validate(xmldoc)
        stage = xmldoc&.at("//bibdata/status/stage")&.text
        %w(in-force superseded in-force-prepublished withdrawn
           draft).include? stage or
          @log.add("ITU_2", nil, params: [stage])
      end

      def content_validate(doc)
        super
        approval_validate(doc)
        itu_identifier_validate(doc)
        bibdata_validate(doc.root)
        termdef_style(doc.root)
        title_validate1(doc.root)
        reqt_validate(doc.root)
        numbers_validate(doc.root)
      end

      # Editing Guidelines 6.3
      def title_validate1(xmldoc)
        t = xmldoc.at("//bibdata/title")&.text
        xmldoc.xpath("//bibdata/series/title").each do |s|
          series = s.text.sub(/^[A-Z]: /, "")
          t.downcase.include?(series.downcase) and
            @log.add("ITU_3", nil, params: [series])
        end
      end

      def extract_text(node)
        return "" if node.nil?

        node1 = Nokogiri::XML.fragment(node.to_s)
        node1.xpath("//link | //locality | //localityStack").each(&:remove)
        ret = ""
        node1.traverse { |x| ret += x.text if x.text? }
        ret
      end

      # Editing Guidelines 7
      def reqt_validate(xmldoc)
        xmldoc.xpath("//preface/*").each do |c|
          extract_text(c).split(/\.\s+/).each do |t|
            /\b(shall|must)\b/i.match(t) and
              @log.add("ITU_4", c, params: [t.strip])
          end
        end
      end

      # Editing Guidelines 9.4.3
      # Supplanted by rendering
      def numbers_validate(xmldoc); end

      #       def style_two_regex_not_prev(node, text, regex, regex_prev, warning)
      #         text.nil? and return
      #         arr = text.split(/\W+/)
      #         arr.each_index do |i|
      #           m_prev = i.zero? ? nil : regex_prev.match(arr[i - 1])
      #           if !regex.match?(arr[i]) && m_prev.nil?
      #             @log.add("Style", node, "#{warning}: #{m[:num]}")
      #             # ID = ITU_5
      #           end
      #         end
      #       end

      def approval_validate(xmldoc)
        s = xmldoc.at("//bibdata/ext/recommendationstatus/approvalstage") or
          return
        process = s["process"]
        (process == "aap") && %w(determined in-force).include?(s.text) and
          @log.add("ITU_6", nil, params: [s.text])
        (process == "tap") && !%w(determined in-force).include?(s.text) and
          @log.add("ITU_7", nil, params: [s.text])
      end

      def itu_identifier_validate(xmldoc)
        xmldoc.xpath("//bibdata/docidentifier[@type = 'ITU']").each do |x|
          /^SG \d+/.match?(x.text) ||
            /^ITU-[RTD] [AD-VX-Z]\.\d+(\.\d+)?$/.match?(x.text) or
            @log.add("ITU_8", nil, params: [x.text])
        end
      end

      def section_validate(doc)
        super
        section_check(doc.root)
        unnumbered_check(doc.root)
      end

      def unnumbered_check(xmldoc)
        xmldoc.xpath("//clause[@unnumbered = 'true']").each do |c|
          next if (@doctype == "resolution") && (c.parent.name == "sections") &&
            !c.at("./preceding-sibling::clause")

          @log.add("ITU_9", c)
        end
      end

      # Editing Guidelines 7.2, 7.3
      def section_check(xmldoc)
        xmldoc.at("//bibdata/abstract") or
          @log.add("ITU_10", nil)
        xmldoc.at("//bibdata/keyword") or
          @log.add("ITU_11", nil)
      end

      def termdef_style(xmldoc)
        xmldoc.xpath("//term").each do |t|
          para = t.at("./definition/verbal-definition") || return
          term = t.at("./preferred//name").text
          termdef_warn(term, /^[A-Z][a-z]+/, t, term, "term is not lowercase")
          termdef_warn(para.text.strip, /^[a-z]/, t, term,
                       "term definition does not start with capital")
          termdef_warn(para.text.strip, /[^.]\z/, t, term,
                       "term definition does not end with period")
        end
      end

      def termdef_warn(text, regex, node, term, msg)
        regex.match(text) && @log.add("ITU_12", node, params: [term, msg])
      end
    end
  end
end

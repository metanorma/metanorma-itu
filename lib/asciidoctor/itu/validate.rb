module Asciidoctor
  module ITU
    class Converter < Standoc::Converter
      def bibdata_validate(doc)
        doctype_validate(doc)
        stage_validate(doc)
      end

      def doctype_validate(xmldoc)
        doctype = xmldoc&.at("//bibdata/ext/doctype")&.text
        %w(recommendation recommendation-supplement recommendation-amendment 
        recommendation-corrigendum recommendation-errata recommendation-annex 
        focus-group implementers-guide technical-paper technical-report 
        joint-itu-iso-iec service-publication).include? doctype or
        @log.add("Document Attributes", nil, "#{doctype} is not a recognised document type")
      end

      def stage_validate(xmldoc)
        stage = xmldoc&.at("//bibdata/status/stage")&.text
        %w(in-force superseded in-force-prepublished withdrawn 
        draft).include? stage or
          @log.add("Document Attributes", nil, 
                   "#{stage} is not a recognised status")
      end

      def content_validate(doc)
        super
        approval_validate(doc)
        itu_identifier_validate(doc)
        bibdata_validate(doc.root)
        termdef_style(doc.root)
        title_validate1(doc.root)
        requirement_validate(doc.root)
        numbers_validate(doc.root)
      end

      # Editing Guidelines 6.3
      def title_validate1(xmldoc)
        t = xmldoc.at("//bibdata/title")&.text
        xmldoc.xpath("//bibdata/series/title").each do |s|
          series = s.text.sub(/^[A-Z]: /, "")
          t.downcase.include?(series.downcase) and
            @log.add("Document Attributes", nil, "Title includes series name #{series}")
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
      def requirement_validate(xmldoc)
        xmldoc.xpath("//preface/*").each do |c|
          extract_text(c).split(/\.\s+/).each do |t|
            /\b(shall|must)\b/i.match(t) and
              @log.add("Style", c, 
                       "Requirement possibly in preface: #{t.strip}")
          end
        end
      end

      # Editing Guidelines 9.4.3
      # Supplanted by rendering
      def numbers_validate(xmldoc)
      end

      def style_two_regex_not_prev(n, text, re, re_prev, warning)
        return if text.nil?
        arr = text.split(/\W+/)
        arr.each_index do |i|
          m = re.match arr[i]
          m_prev = i.zero? ? nil : re_prev.match(arr[i - 1])
          if !m.nil? && m_prev.nil?
            @log.add("Style", n, "#{warning}: #{m[:num]}")
          end
        end
      end

      def approval_validate(xmldoc)
        s = xmldoc.at("//bibdata/ext/recommendationstatus/approvalstage") or
          return
        process = s["process"]
        if process == "aap" and %w(determined in-force).include? s.text
          @log.add("Document Attributes", nil, 
                   "Recommendation Status #{s.text} inconsistent with AAP")
        end
        if process == "tap" and !%w(determined in-force).include? s.text
          @log.add("Document Attributes", nil, 
                   "Recommendation Status #{s.text} inconsistent with TAP")
        end
      end

      def itu_identifier_validate(xmldoc)
        s = xmldoc.xpath("//bibdata/docidentifier[@type = 'ITU']").each do |x|
          /^ITU-[RTD] [AD-VX-Z]\.[0-9]+$/.match(x.text) or
            @log.add("Style", nil, "#{x.text} does not match ITU document "\
                     "identifier conventions")
        end
      end

      def section_validate(doc)
        super
        section_check(doc.root)
        unnumbered_check(doc.root)
      end

      def unnumbered_check(xmldoc)
        doctype = xmldoc&.at("//bibdata/ext/doctype")&.text
        xmldoc.xpath("//clause[@unnumbered = 'true']").each do |c|
          next if doctype == "resolution" and c.parent.name == "sections" and
            !c.at("./preceding-sibling::clause")
          @log.add("Style", c, "Unnumbered clause out of place")
        end
      end

      # Editing Guidelines 7.2, 7.3
      def section_check(xmldoc)
        xmldoc.at("//bibdata/abstract") or
          @log.add("Style", nil, "No Summary has been provided")
        xmldoc.at("//bibdata/keywords") or
          @log.add("Style", nil, "No Keywords have been provided")
      end

      def termdef_style(xmldoc)
        xmldoc.xpath("//term").each do |t|
          para = t.at("./definition") || return
          term = t.at("./preferred").text
          termdef_warn(term, /^[A-Z][a-z]+/, t, term, "term is not lowercase")
          termdef_warn(para.text, /^[a-z]/, t, term, 
                       "term definition does not start with capital")
          termdef_warn(para.text, /[^.]$/, t, term, 
                       "term definition does not end with period")
        end
      end

      def termdef_warn(text, re, t, term, msg)
        re.match(text) && @log.add("Style", t, "#{term}: #{msg}")
      end
    end
  end
end

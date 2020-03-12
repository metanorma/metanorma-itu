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
        joint-itu-iso-iec).include? doctype or
        @log.add("Document Attributes", nil, "#{doctype} is not a recognised document type")
      end

      def stage_validate(xmldoc)
        stage = xmldoc&.at("//bibdata/status/stage")&.text
        %w(in-force superseded in-force-prepublished withdrawn draft).include? stage or
          @log.add("Document Attributes", nil, "#{stage} is not a recognised status")
      end

      def content_validate(doc)
        super
        approval_validate(doc)
        itu_identifier_validate(doc)
        bibdata_validate(doc.root)
        termdef_style(doc.root)
      end

      def approval_validate(xmldoc)
        s = xmldoc.at("//bibdata/ext/recommendationstatus/approvalstage") || return
        process = s["process"]
        if process == "aap" and %w(determined in-force).include? s.text
          @log.add("Document Attributes", nil, "Recommendation Status #{s.text} inconsistent with AAP")
        end
        if process == "tap" and !%w(determined in-force).include? s.text
          @log.add("Document Attributes", nil, "Recommendation Status #{s.text} inconsistent with TAP")
        end
      end

      def itu_identifier_validate(xmldoc)
        s = xmldoc.xpath("//bibdata/docidentifier[@type = 'ITU']").each do |x|
          /^ITU-[RTF] [AD-VX-Z]\.[0-9]+$/.match(x.text) or
            @log.add("Style", nil, "#{x.text} does not match ITU document identifier conventions")
        end
      end

      def termdef_style(xmldoc)
        xmldoc.xpath("//term").each do |t|
          para = t.at("./definition") || return
          term = t.at("./preferred").text
          termdef_warn(term, /^[A-Z][a-z]+/, t, term, "term is not lowercase")
          termdef_warn(para.text, /^[a-z]/, t, term, "term definition does not start with capital")
          termdef_warn(para.text, /[^.]$/, t, term, "term definition does not end with period")
        end
      end

      def termdef_warn(text, re, t, term, msg)
        re.match(text) && @log.add("Style", t, "#{term}: #{msg}")
      end
    end
  end
end

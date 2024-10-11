module IsoDoc
  module Itu
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def bibdata_i18n(bib)
        super
        bibdata_dates(bib)
        bibdata_title(bib)
        amendment_id(bib)
      end

      def bibdata_dates(bib)
        bib.xpath(ns("./date")).each do |d|
          d.next = d.dup
          d.next["format"] = "ddMMMyyyy"
          d.next.children = ddMMMyyyy(d.text)
        end
      end

      def bibdata_title(bib)
        case bib.at(ns("./ext/doctype"))&.text
        when "service-publication" then bibdata_title_service_population(bib)
        when "resolution" then bibdata_title_resolution(bib)
        end
      end

      def bibdata_title_resolution(bib)
        place = bib.at(ns("./ext/meeting-place"))&.text
        year = bib.at(ns("./ext/meeting-date/from | ./ext/meeting-date/on"))
          &.text&.gsub(/-.*$/, "")
        text = bibdata_title_resolution_name(bib, place, year)
        bib.at(ns("./title")).next = <<~INS
          <title language="#{@lang}" format="text/plain" type="resolution">#{text}</title>
          <title language="#{@lang}" format="text/plain" type="resolution-placedate">#{place}, #{year}</title>
        INS
      end

      def bibdata_title_resolution_name(bib, place, year)
        ed = bib.at(ns("./edition"))&.text
        rev = ed && ed != "1" ? "#{@i18n.get['revision_abbreviation']} " : ""
        num = bib.at(ns("./docnumber"))
        @i18n.l10n("#{@i18n.get['doctype_dict']['resolution'].upcase} " \
                          "#{num&.text} (#{rev}#{place}, #{year})")
      end

      def bibdata_title_service_population(bib)
        date = bib&.at(ns("./date[@type = 'published']"))&.text or return
        text = l10n(@i18n.get["position_on"].sub("%", ddmmmmyyyy(date)))
        ins = bib.at(ns("./title"))
        ins.next = <<~INS
          <title language="#{@lang}" format="text/plain" type="position-sp">#{text}</title>
        INS
      end

      def ddMMMyyyy(date)
        d = date.split("-").map { |x| x.sub(/^0/, "") }
        case @lang
        when "zh"
          d[0] += "年" if d[0]
          d[1] += "月" if d[1]
          d[2] += "日" if d[2]
          d.join
        when "ar"
          d[1] = ::RomanNumerals.to_roman(d[1].to_i).upcase if d[1]
          d.join(".")
        else
          d[1] = ::RomanNumerals.to_roman(d[1].to_i).upcase if d[1]
          d.reverse.join(".")
        end
      end

      def ddmmmmyyyy(date)
        @lang == "zh" and return ddMMMyyyy(date)
        d = date.split("-")
        d[1] &&= @meta.months[d[1].to_sym]
        d[2] &&= d[2].sub(/^0/, "")
        l10n(d.reverse.join(" "))
      end

      def amendment_id(bib)
        %w(amendment corrigendum).each do |w|
          if dn = bib.at(ns("./ext/structuredidentifier/#{w}"))
            dn["language"] = ""
            dn.next = dn.dup
            dn.next["language"] = @lang
            dn.next.children = @i18n.l10n("#{@i18n.get[w]} #{dn.text}")
          end
        end
      end
    end
  end
end

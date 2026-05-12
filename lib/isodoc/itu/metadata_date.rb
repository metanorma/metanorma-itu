module IsoDoc
  module Itu
    class Metadata < IsoDoc::Metadata
      def monthyr(isodate)
        IsoDoc::ExtendedDateFormatter.format_iso_date(
          isodate,
          lang: @lang,
          year_month: "%m/%Y",
          full: "%m/%Y",
        )
      end

      def ddMMMYYYY(isodate)
        out = IsoDoc::ExtendedDateFormatter.format_iso_date(
          isodate,
          lang: @lang,
          full: "%d %b %Y",
        )
        out == isodate ? out : @i18n.l10n(out)
      end

      def ddMMMMYYYY(date1, date2)
        m1 = /(?<yr>\d\d\d\d)-(?<mo>\d\d)-(?<dd>\d\d)/.match date1
        m2 = /(?<yr>\d\d\d\d)-(?<mo>\d\d)-(?<dd>\d\d)/.match date2
        if m1 && m1[:yr] && m1[:mo] && m1[:dd]
          dd1 = m1[:dd].sub(/^0/, "")
          if m2 && m2[:yr] && m2[:mo] && m2[:dd]
            dd2 = m2[:dd].sub(/^0/, "")
            if m1[:yr] == m2[:yr]
              if m1[:mo] == m2[:mo]
                @i18n.l10n("#{dd1}&#x2013;#{dd2} #{localized_month(m1[:mo])} #{m1[:yr]}")
              else
                @i18n.l10n("#{dd1} #{localized_month(m1[:mo])} &#x2013; " \
                           "#{dd2} #{localized_month(m2[:mo])} #{m1[:yr]}")
              end
            else
              @i18n.l10n("#{dd1} #{localized_month(m1[:mo])} #{m1[:yr]} &#x2013; " \
                         "#{dd2} #{localized_month(m2[:mo])} #{m2[:yr]}")
            end
          else
            date2.nil? ? @i18n.l10n("#{dd1} #{localized_month(m1[:mo])} #{m1[:yr]}") : "#{date1}/#{date2}"
          end
        else
          date2.nil? ? date1 : "#{date1}/#{date2}"
        end
      end

      private

      def localized_month(month)
        IsoDoc::ExtendedDateFormatter.format(
          "2000-#{month}-01", "%B", lang: @lang
        )
      end
    end
  end
end

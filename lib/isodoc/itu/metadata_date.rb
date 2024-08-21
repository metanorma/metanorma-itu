module IsoDoc
  module ITU
    class Metadata < IsoDoc::Metadata
      def monthyr(isodate)
        m = /(?<yr>\d\d\d\d)-(?<mo>\d\d)/.match isodate
        m && m[:yr] && m[:mo] or return isodate
        "#{m[:mo]}/#{m[:yr]}"
      end

      def ddMMMYYYY(isodate)
        m = /(?<yr>\d\d\d\d)-(?<mo>\d\d)-(?<dd>\d\d)/.match isodate
        m && m[:yr] && m[:mo] && m[:dd] or return isodate
        mmm = DateTime.parse(isodate).localize(@lang.to_sym)
          .to_additional_s("yMMM")
        @i18n.l10n("#{m[:dd]} #{mmm}")
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
                @i18n.l10n("#{dd1}&#x2013;#{dd2} #{months[m1[:mo].to_sym]} #{m1[:yr]}")
              else
                @i18n.l10n("#{dd1} #{months[m1[:mo].to_sym]} &#x2013; " \
                           "#{dd2} #{months[m2[:mo].to_sym]} #{m1[:yr]}")
              end
            else
              @i18n.l10n("#{dd1} #{months[m1[:mo].to_sym]} #{m1[:yr]} &#x2013; " \
                         "#{dd2} #{months[m2[:mo].to_sym]} #{m2[:yr]}")
            end
          else
            date2.nil? ? @i18n.l10n("#{dd1} #{months[m1[:mo].to_sym]} #{m1[:yr]}") : "#{date1}/#{date2}"
          end
        else
          date2.nil? ? date1 : "#{date1}/#{date2}"
        end
      end
    end
  end
end

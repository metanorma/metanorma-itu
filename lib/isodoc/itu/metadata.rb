require "isodoc"
require "twitter_cldr"

module IsoDoc
  module ITU

    class Metadata < IsoDoc::Metadata
      def initialize(lang, script, labels)
        super
        here = File.dirname(__FILE__)
        n = "International_Telecommunication_Union_Logo.svg"
        set(:logo_html,
            File.expand_path(File.join(here, "html", n)))
        set(:logo_comb,
            File.expand_path(File.join(here, "html", "itu-document-comb.png")))
        set(:logo_word,
            File.expand_path(File.join(here, "html", n)))
      end

      def title(isoxml, _out)
        main = isoxml&.at(ns("//bibdata/title[@language='#{@lang}']"\
                             "[@type = 'main']"))&.text
        set(:doctitle, main)
        main = isoxml&.at(ns("//bibdata/title[@language='#{@lang}']"\
                             "[@type = 'subtitle']"))&.text
        set(:docsubtitle, main)
        main = isoxml&.at(ns("//bibdata/title[@language='#{@lang}']"\
                             "[@type = 'amendment']"))&.text
        set(:amendmenttitle, main)
        main = isoxml&.at(ns("//bibdata/title[@language='#{@lang}']"\
                             "[@type = 'corrigendum']"))&.text
        set(:corrigendumtitle, main)
        series = isoxml&.at(ns("//bibdata/series[@type='main']/title"))&.text
        set(:series, series)
        series1 =
          isoxml&.at(ns("//bibdata/series[@type='secondary']/title"))&.text
        set(:series1, series1)
        series2 =
          isoxml&.at(ns("//bibdata/series[@type='tertiary']/title"))&.text
        set(:series2, series2)
        annext = isoxml&.at(ns("//bibdata/title[@type='annex']"))&.text
        set(:annextitle, annext)
      end

      def subtitle(_isoxml, _out)
        nil
      end

      def author(xml, _out)
        bureau = xml.at(ns("//bibdata/ext/editorialgroup/bureau"))
        set(:bureau, bureau.text) if bureau
        tc = xml.at(ns("//bibdata/ext/editorialgroup/committee"))
        set(:tc, tc.text) if tc
        tc = xml.at(ns("//bibdata/ext/editorialgroup/group/name"))
        set(:group, tc.text) if tc
        tc = xml.at(ns("//bibdata/ext/editorialgroup/subgroup/name"))
        set(:subgroup, tc.text) if tc
        tc = xml.at(ns("//bibdata/ext/editorialgroup/workgroup/name"))
        set(:workgroup, tc.text) if tc
        super
        authors = xml.xpath(ns("//bibdata/contributor[role/@type = 'author' "\
                                "or xmlns:role/@type = 'editor']/person"))
        person_attributes(authors) unless authors.empty?
      end

      def append(key, value)
        @metadata[key] << value
      end

      def person_attributes(authors)
        %i(affiliations addresses emails faxes phones).each { |i| set(i, []) }
        authors.each do |a|
          append(:affiliations, 
                 a&.at(ns("./affiliation/organization/name"))&.text)
          append(:addresses, a&.at(ns("./affiliation/organization/address/"\
                                      "formattedAddress"))&.text)
          append(:emails, a&.at(ns("./email"))&.text)
          append(:faxes, a&.at(ns("./phone[@type = 'fax']"))&.text)
          append(:phones, a&.at(ns("./phone[not(@type = 'fax')]"))&.text)
        end
      end

      def docid(isoxml, _out)
        dn = isoxml.at(ns("//bibdata/docidentifier[@type = 'ITU']"))
        set(:docnumber, dn&.text)
        dn = isoxml.at(ns("//bibdata/docidentifier[@type = 'ITU-Recommendation']"))
        dn and set(:recommendationnumber, dn&.text)
        dn = isoxml.at(ns("//bibdata/ext/structuredidentifier/annexid"))
        oblig = isoxml&.at(ns("//annex/@obligation"))&.text
        lbl = oblig == "informative" ? @labels["appendix"] : @labels["annex"]
        dn and set(:annexid, @i18n.l10n("#{lbl} #{dn&.text}"))
        dn = isoxml.at(ns("//bibdata/ext/structuredidentifier/amendment")) and
          set(:amendmentid, @i18n.l10n("#{@labels["amendment"]} #{dn&.text}"))
        dn = isoxml.at(ns("//bibdata/ext/structuredidentifier/corrigendum")) and
          set(:corrigendumid,
              @i18n.l10n("#{@labels["corrigendum"]} #{dn&.text}"))
      end

      def unpublished(status)
        %w(in-force-prepublished draft).include? status.downcase
      end

      def bibdate(isoxml, _out)
        pubdate = isoxml.xpath(ns("//bibdata/date[not(@format)][@type = 'published']"))
        pubdate and set(:pubdate_monthyear, monthyr(pubdate.text))
        pubdate = isoxml.xpath(ns("//bibdata/date[@format = 'ddMMMyyyy'][@type = 'published']"))
        pubdate and set(:pubdate_ddMMMyyyy, monthyr(pubdate.text))
      end

      def version(isoxml, _out)
        super
        y = get[:docyear] and
          set(:placedate_year, @labels["placedate"].sub(/%/, y))
      end

      def monthyr(isodate)
        m = /(?<yr>\d\d\d\d)-(?<mo>\d\d)/.match isodate
        return isodate unless m && m[:yr] && m[:mo]
        return "#{m[:mo]}/#{m[:yr]}"
      end

      def keywords(isoxml, _out)
        super
        set(:keywords, get[:keywords].sort)
      end

      def doctype(isoxml, _out)
        d = isoxml&.at(ns("//bibdata/ext/doctype"))&.text
        set(:doctype_original, d)
        if d == "recommendation-annex"
          set(:doctype, "Recommendation")
          set(:doctype_display, "Recommendation")
        else
          super
        end
      end

      def ip_notice_received(isoxml, _out)
        received = isoxml.at(ns("//bibdata/ext/ip-notice-received"))&.text ||
          "false"
        set(:ip_notice_received, received)
      end

      def ddMMMYYYY(isodate)
        m = /(?<yr>\d\d\d\d)-(?<mo>\d\d)-(?<dd>\d\d)/.match isodate
        return isodate unless m && m[:yr] && m[:mo] && m[:dd]
        mmm = DateTime.parse(isodate).localize(@lang.to_sym).#with_timezone("UCT").
          to_additional_s("MMM")
        @i18n.l10n("#{m[:dd]} #{mmm} #{m[:yr]}")
      end

      def techreport(isoxml, _out)
        a = isoxml&.at(ns("//bibdata/ext/meeting"))&.text and set(:meeting, a)
        a = isoxml&.at(ns("//bibdata/ext/intended-type"))&.text and
          set(:intended_type, a)
        a = isoxml&.at(ns("//bibdata/ext/source"))&.text and set(:source, a)
        if o = isoxml&.at(ns("//bibdata/ext/meeting-date/on"))&.text
          set(:meeting_date, ddMMMYYYY(o))
        elsif f = isoxml&.at(ns("//bibdata/ext/meeting-date/from"))&.text
          t = isoxml&.at(ns("//bibdata/ext/meeting-date/to"))&.text
          set(:meeting_date, "#{ddMMMYYYY(f)}/#{ddMMMYYYY(t)}")
        end
      end
    end
  end
end

require "isodoc"

module IsoDoc
  module ITU

    class Metadata < IsoDoc::Metadata
      def initialize(lang, script, labels)
        super
        here = File.dirname(__FILE__)
        set(:logo_html,
            #File.expand_path(File.join(here, "html", "Logo_ITU.jpg")))
            File.expand_path(File.join(here, "html", "International_Telecommunication_Union_Logo.svg")))
        set(:logo_comb,
            File.expand_path(File.join(here, "html", "itu-document-comb.png")))
        #set(:logo_word, File.expand_path(File.join(here, "html", "logo.png")))
        set(:logo_word, File.expand_path(File.join(here, "html", "International_Telecommunication_Union_Logo.svg")))
      end

      def title(isoxml, _out)
        main = isoxml&.at(ns("//bibdata/title[@language='en']"))&.text
        set(:doctitle, main)
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

      def author(isoxml, _out)
        bureau = isoxml.at(ns("//bibdata/ext/editorialgroup/bureau"))
        set(:bureau, bureau.text) if bureau
        tc = isoxml.at(ns("//bibdata/ext/editorialgroup/committee"))
        set(:tc, tc.text) if tc
      end

      def docid(isoxml, _out)
        dn = isoxml.at(ns("//bibdata/docidentifier[@type = 'ITU']"))
        set(:docnumber, dn&.text)
        dn = isoxml.at(ns("//bibdata/ext/structuredidentifier/annexid"))
        oblig = isoxml&.at(ns("//annex/@obligation"))&.text
        lbl = oblig == "informative" ? @labels["appendix"] : @labels["annex"]
        dn and set(:annexid, IsoDoc::Function::I18n::l10n("#{lbl} #{dn&.text}"))
      end

      def unpublished(status)
        %w(in-force-prepublished draft).include? status.downcase
      end

      def version(isoxml, _out)
        super
        revdate = get[:revdate]
        set(:revdate_monthyear, monthyr(revdate))
      end

      MONTHS = {
        "01": "January",
        "02": "February",
        "03": "March",
        "04": "April",
        "05": "May",
        "06": "June",
        "07": "July",
        "08": "August",
        "09": "September",
        "10": "October",
        "11": "November",
        "12": "December",
      }.freeze

      def bibdate(isoxml, _out)
        pubdate = isoxml.xpath(ns("//bibdata/date[@type = 'published']"))
        pubdate and set(:pubdate_monthyear, monthyr(pubdate.text))
      end

      def monthyr(isodate)
        m = /(?<yr>\d\d\d\d)-(?<mo>\d\d)/.match isodate
        return isodate unless m && m[:yr] && m[:mo]
        return "#{m[:mo]}/#{m[:yr]}"
      end

      def keywords(isoxml, _out)
        keywords = []
        isoxml.xpath(ns("//bibdata/keyword")).each do |kw|
          keywords << kw.text
        end
        set(:keywords, keywords.sort)
      end

      def ip_notice_received(isoxml, _out)
        received = isoxml.at(ns("//bibdata/ext/ip-notice-received"))&.text ||
          "false"
        set(:ip_notice_received, received)
      end
    end
  end
end

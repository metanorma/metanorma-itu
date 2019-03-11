require "isodoc"

module IsoDoc
  module ITU

    class Metadata < IsoDoc::Metadata
      def initialize(lang, script, labels)
        super
        set(:status, "XXX")
      end

      def title(isoxml, _out)
        main = isoxml&.at(ns("//bibdata/title[@language='en']"))&.text
        set(:doctitle, main)
        series = isoxml&.at(ns("//bibdata/series[@type='main']/title"))&.text
        set(:series, series)
        series1 = isoxml&.at(ns("//bibdata/series[@type='secondary']/title"))&.text
        set(:series1, series1)
        series2 = isoxml&.at(ns("//bibdata/series[@type='tertiary']/title"))&.text
        set(:series2, series2)
      end

      def subtitle(_isoxml, _out)
        nil
      end

      def author(isoxml, _out)
        bureau = isoxml.at(ns("//bibdata/editorialgroup/bureau"))
        set(:bureau, bureau.text) if bureau
        tc = isoxml.at(ns("//bibdata/editorialgroup/committee"))
        set(:tc, tc.text) if tc
      end

      def docid(isoxml, _out)
        dn = isoxml.at(ns("//bibdata/docnumber"))
        set(:docnumber, dn&.text)
        dn = isoxml.at(ns("//bibdata/docidentifier"))
        set(:docidentifier, dn&.text)
      end

      def status_print(status)
        status.split(/-/).map{ |w| w.capitalize }.join(" ")
      end

      def status_abbr(status)
        case status
        when "working-draft" then "wd"
        when "committee-draft" then "cd"
        when "draft-standard" then "d"
        else
          ""
        end
      end

      def unpublished(status)
        %w(in-force-prepublished).include? status.downcase
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
        set(:keywords, keywords)
      end
    end
  end
end

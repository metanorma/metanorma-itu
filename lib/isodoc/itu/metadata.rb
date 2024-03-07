require "isodoc"
require "twitter_cldr"

module IsoDoc
  module ITU
    class Metadata < IsoDoc::Metadata
      def initialize(lang, script, locale, labels)
        super
        n = "International_Telecommunication_Union_Logo.svg"
        set(:logo_html, fileloc(n))
        set(:logo_comb, fileloc("itu-document-comb.png"))
        set(:logo_word, fileloc(n))
        set(:logo_sp, fileloc("logo-sp.png"))
        @isodoc = IsoDoc::ITU::HtmlConvert.new({})
      end

      def fileloc(file)
        here = File.dirname(__FILE__)
        File.expand_path(File.join(here, "html", file))
      end

      def title(isoxml, _out)
        { doctitle: "//bibdata/title[@language='#{@lang}'][@type = 'main']",
          docsubtitle: "//bibdata/title[@language='#{@lang}']" \
                       "[@type = 'subtitle']",
          amendmenttitle: "//bibdata/title[@language='#{@lang}']" \
                          "[@type = 'amendment']",
          corrigendumtitle: "//bibdata/title[@language='#{@lang}']" \
                            "[@type = 'corrigendum']",
          series: "//bibdata/series[@type='main']/title",
          series1: "//bibdata/series[@type='secondary']/title",
          series2: "//bibdata/series[@type='tertiary']/title",
          annextitle: "//bibdata/title[@type='annex']",
          collectiontitle: "//bibdata/title[@type='collection']",
          positiontitle: "//bibdata/title[@type='position-sp']" }.each do |k, v|
          titleset(isoxml, k, v)
        end
      end

      def titleset(isoxml, key, xpath)
        value = isoxml.at(ns(xpath)) or return
        out = @isodoc.noko do |xml|
          xml.span do |s|
            value.children.each { |c| @isodoc.parse(c, s) }
          end
        end.join
        set(key, out.sub(%r{^<span>}, "").sub(%r{</span>$}, ""))
      end

      def subtitle(_isoxml, _out)
        nil
      end

      def author(xml, _out)
        sector = xml.at(ns("//bibdata/ext/editorialgroup/sector"))
        set(:sector, sector.text) if sector
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
        authors = xml.xpath(ns("//bibdata/contributor[role/@type = 'author' " \
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
                 a.at(ns("./affiliation/organization/name"))&.text)
          append(:addresses, a.at(ns("./affiliation/organization/address/" \
                                     "formattedAddress"))&.text)
          append(:emails, a.at(ns("./email"))&.text)
          append(:faxes, a.at(ns("./phone[@type = 'fax']"))&.text)
          append(:phones, a.at(ns("./phone[not(@type = 'fax')]"))&.text)
        end
      end

      def docid(isoxml, _out)
        { docnumber: "ITU", recommendationnumber: "ITU-Recommendation",
          docnumber_lang: "ITU-lang", docnumber_td: "ITU-TemporaryDocument",
          docnumber_provisional: "ITU-provisional" }
          .each do |k, v|
            dn = isoxml.at(ns("//bibdata/docidentifier[@type = '#{v}']")) and
              set(k, dn.text)
          end
        dn = isoxml.at(ns("//bibdata/ext/structuredidentifier/annexid"))
        oblig = isoxml.at(ns("//annex/@obligation"))&.text
        lbl = oblig == "informative" ? @labels["appendix"] : @labels["annex"]
        dn and set(:annexid, @i18n.l10n("#{lbl} #{dn.text}"))
        dn = isoxml.at(ns("//bibdata/ext/structuredidentifier/amendment")) and
          set(:amendmentid, @i18n.l10n("#{@labels['amendment']} #{dn.text}"))
        dn = isoxml.at(ns("//bibdata/ext/structuredidentifier/corrigendum")) and
          set(:corrigendumid,
              @i18n.l10n("#{@labels['corrigendum']} #{dn.text}"))
      end

      def unpublished(status)
        %w(in-force-prepublished draft).include? status.downcase
      end

      def bibdate(isoxml, _out)
        pubdate = isoxml.at(ns("//bibdata/date[not(@format)][@type = 'published']"))
        pubdate and set(:pubdate_monthyear, monthyr(pubdate.text))
        pubdate = isoxml.at(ns("//bibdata/date[@format = 'ddMMMyyyy'][@type = 'published']"))
        pubdate and set(:pubdate_ddMMMyyyy, monthyr(pubdate.text))
        pubdate = isoxml.at(ns("//bibdata/date[not(@format)][@type = 'published']")) ||
          isoxml.at(ns("//bibdata/copyright/from"))
        pubdate and
          set(:placedate_year,
              @labels["placedate"]
          .sub("%", pubdate.text.sub(/^(\d\d\d\d).*$/, "\\1")))
      end

      def monthyr(isodate)
        m = /(?<yr>\d\d\d\d)-(?<mo>\d\d)/.match isodate
        return isodate unless m && m[:yr] && m[:mo]

        "#{m[:mo]}/#{m[:yr]}"
      end

      def keywords(isoxml, _out)
        super
        set(:keywords, get[:keywords].sort)
      end

      def doctype(isoxml, _out)
        d = isoxml&.at(ns("//bibdata/ext/doctype"))&.text
        set(:doctype_original, d)
        set(:doctype_abbreviated, @labels.dig("doctype_abbrev", d))
        if d == "recommendation-annex"
          set(:doctype, "Recommendation")
          set(:doctype_display, "Recommendation")
        else super
        end
        d = get[:doctype] and
          set(:draft_new_doctype, @labels["draft_new"].sub("%", d))
      end

      def ip_notice_received(isoxml, _out)
        received = isoxml.at(ns("//bibdata/ext/ip-notice-received"))&.text ||
          "false"
        set(:ip_notice_received, received)
      end

      def ddMMMYYYY(isodate)
        m = /(?<yr>\d\d\d\d)-(?<mo>\d\d)-(?<dd>\d\d)/.match isodate
        return isodate unless m && m[:yr] && m[:mo] && m[:dd]

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

      def techreport(isoxml, _out)
        if a = isoxml.at(ns("//bibdata/ext/meeting"))&.text
          set(:meeting, a)
          set(:meeting_acronym, a)
        end
        a = isoxml.at(ns("//bibdata/ext/meeting/@acronym"))&.text and
          set(:meeting_acronym, a)
        a = isoxml.at(ns("//bibdata/ext/meeting-place"))&.text and
          set(:meeting_place, a)
        a = isoxml.at(ns("//bibdata/ext/intended-type"))&.text and
          set(:intended_type, a)
        a = isoxml.at(ns("//bibdata/ext/source"))&.text and set(:source, a)
        meeting(isoxml)
      end

      def meeting(isoxml)
        resolution =
          isoxml.at(ns("//bibdata/ext/doctype"))&.text == "resolution"
        if o = isoxml.at(ns("//bibdata/ext/meeting-date/on"))&.text
          set(:meeting_date, resolution ? ddMMMMYYYY(o, nil) : ddMMMYYYY(o))
        elsif f = isoxml.at(ns("//bibdata/ext/meeting-date/from"))&.text
          t = isoxml.at(ns("//bibdata/ext/meeting-date/to"))&.text
          set(:meeting_date,
              resolution ? ddMMMMYYYY(f, t) : "#{ddMMMYYYY(f)}/#{ddMMMYYYY(t)}")
        end
      end
    end
  end
end

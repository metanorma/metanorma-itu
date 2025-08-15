require "twitter_cldr"
require_relative "metadata_date"

module IsoDoc
  module Itu
    class Metadata < IsoDoc::Metadata
      def initialize(lang, script, locale, labels)
        super
        n = "International_Telecommunication_Union_Logo.svg"
        set(:logo_html, fileloc(n))
        set(:logo_comb, fileloc("itu-document-comb.png"))
        set(:logo_word, fileloc(n))
        set(:logo_sp, fileloc("logo-sp.png"))
        set(:logo_small, fileloc("logo-small.png"))
        @isodoc = IsoDoc::Itu::HtmlConvert.new({})
      end

      def fileloc(file)
        here = File.dirname(__FILE__)
        File.expand_path(File.join(here, "html", file))
      end

      TITLE_XPATHS =
        { doctitle: "//bibdata/title[@language='@_lang'][@type = 'main']",
          docsubtitle: "//bibdata/title[@language='@_lang']" \
                       "[@type = 'subtitle']",
          amendmenttitle: "//bibdata/title[@language='@_lang']" \
                          "[@type = 'amendment']",
          corrigendumtitle: "//bibdata/title[@language='@_lang']" \
                            "[@type = 'corrigendum']",
          series: "//bibdata/series[@type='main']/title",
          series1: "//bibdata/series[@type='secondary']/title",
          series2: "//bibdata/series[@type='tertiary']/title",
          annextitle: "//bibdata/title[@type='annex']",
          collectiontitle: "//bibdata/title[@type='collection']",
          slogantitle: "//bibdata/title[@type='slogan']",
          positiontitle: "//bibdata/title[@type='position-sp']" }.freeze

      def title(xml, _out)
        TITLE_XPATHS.each do |k, v|
          titleset(xml, k, v.sub("@_lang", @lang))
        end
        titleset(xml, :doctitle_en,
                 "//bibdata/title[@language='en'][@type = 'main']") or
          titleset(xml, :doctitle_en,
                   "//bibdata/title[@language='#{@lang}'][@type = 'main']")
      end

      def titleset(xml, key, xpath)
        value = xml.at(ns(xpath)) or return
        out = @isodoc.noko do |x|
          x.span do |s|
            value.children.each { |c| @isodoc.parse(c, s) }
          end
        end.join
        set(key, out.sub(%r{^<span>}, "").sub(%r{</span>$}, ""))
        true
      end

      def subtitle(_xml, _out)
        nil
      end

      COMMITTEE_XPATH = "//bibdata/contributor[role/description = 'committee']/" \
        "organization/subdivision".freeze

      def author(xml, _out)
        sector = xml.at(ns("#{COMMITTEE_XPATH}[@type='Sector']/name"))
        set(:sector, sector.text) if sector
        bureau(xml)
        tc = xml.at(ns("#{COMMITTEE_XPATH}[@type='Group']/name"))
        set(:group, tc.text) if tc
        tc = xml.at(ns("#{COMMITTEE_XPATH}[@type='Group']/identifier"))
        set(:group_acronym, tc.text) if tc
        start1 = xml.at(ns("//bibdata/ext/studyperiod/start"))
        end1 = xml.at(ns("//bibdata/ext/studyperiod/end"))
        if start1
          set(:study_group_period,
              @i18n.l10n("#{start1.text}–#{end1.text}"))
        end
        tc = xml.at(ns("#{COMMITTEE_XPATH}[@type='Subgroup']/name"))
        set(:subgroup, tc.text) if tc
        tc = xml.at(ns("#{COMMITTEE_XPATH}[@type='Workgroup']/name"))
        set(:workgroup, tc.text) if tc
        super
        authors = xml.xpath(ns("//bibdata/contributor[role/@type = 'author' " \
                               "or xmlns:role/@type = 'editor']/person"))
        person_attributes(authors) unless authors.empty?
      end

      def bureau(xml)
        if bureau = xml.at(ns("#{COMMITTEE_XPATH}[@type='Bureau']/name"))
          set(:bureau, bureau.text)
          case bureau.text
          when "T" then set(:bureau_full, @i18n.tsb_full)
          when "D" then set(:bureau_full, @i18n.bdt_full)
          when "R" then set(:bureau_full, @i18n.br_full)
          end
        end
      end

      def append(key, value)
        @metadata[key] << value
      end

      PERSON_ATTRS =
        { affiliations: "./affiliation/organization/name",
          addresses: "./affiliation/organization/address/formattedAddress",
          emails: "./email", faxes: "./phone[@type = 'fax']",
          phones: "./phone[not(@type = 'fax')]" }.freeze

      def person_attributes(authors)
        PERSON_ATTRS.each_key { |k| set(k, []) }
        authors.each do |a|
          PERSON_ATTRS.each do |k, v|
            append(k, a.at(ns(v))&.text)
          end
        end
      end

      def docid(xml, _out)
        { docnumber: "ITU", recommendationnumber: "ITU-Recommendation",
          docnumber_lang: "ITU-lang", docnumber_td: "ITU-TemporaryDocument",
          docnumber_provisional: "ITU-provisional", docnumber_iso: "ISO" }
          .each do |k, v|
            dn = xml.at(ns("//bibdata/docidentifier[@type = '#{v}']")) and
              set(k, dn.text)
          end
        dn = xml.at(ns("//bibdata/ext/structuredidentifier/annexid"))
        oblig = xml.at(ns("//annex/@obligation"))&.text
        lbl = oblig == "informative" ? @labels["appendix"] : @labels["annex"]
        dn and set(:annexid, @i18n.l10n("#{lbl} #{dn.text}"))
        dn = xml.at(ns("//bibdata/ext/structuredidentifier/amendment")) and
          set(:amendmentid, @i18n.l10n("#{@labels['amendment']} #{dn.text}"))
        dn = xml.at(ns("//bibdata/ext/structuredidentifier/corrigendum")) and
          set(:corrigendumid,
              @i18n.l10n("#{@labels['corrigendum']} #{dn.text}"))
      end

      def bibdate(xml, _out)
        d = xml.at(ns("//bibdata/date[not(@format)][@type = 'published']"))
        d and set(:pubdate_monthyear, monthyr(d.text))
        d = xml.at(ns("//bibdata/date[@format = 'ddMMMyyyy'][@type = 'published']"))
        d and set(:pubdate_ddMMMyyyy, monthyr(d.text))
        d = xml.at(ns("//bibdata/date[not(@format)][@type = 'published']")) ||
          xml.at(ns("//bibdata/copyright/from"))
        d and set(:placedate_year, @labels["placedate"]
                    .sub("%", d.text.sub(/^(\d\d\d\d).*$/, "\\1")))
      end

      def keywords(xml, _out)
        super
        set(:keywords, get[:keywords].sort)
        q = xml.xpath(ns("//bibdata/ext/question/identifier"))
        q.empty? or set(:questions,
                        q.map { |x| x.text.sub(/^Q/, "") }.join(", "))
      end

      def doctype(xml, _out)
        d = xml&.at(ns("//bibdata/ext/doctype"))&.text
        set(:doctype_original, d)
        set(:doctype_abbreviated, @labels.dig("doctype_abbrev", d))
        if d == "recommendation-annex"
          set(:doctype, "Recommendation")
          set(:doctype_display, "Recommendation")
        else super
        end
        d = get[:doctype_display] and
          set(:draft_new_doctype, @labels["draft_new"].sub("%", d))
      end

      def ip_notice_received(xml, _out)
        received = xml.at(ns("//bibdata/ext/ip-notice-received"))&.text ||
          "false"
        set(:ip_notice_received, received)
      end

      def contribution(xml, _out)
        a = xml.at(ns("//bibdata/ext/timing")) and set(:timing, a.text)
        a = xml.at(ns("//bibdata/ext/recommendationstatus/approvalstage/@process")) and
          set(:approval_process, a.text)
      end

      def techreport(xml, _out)
        if a = xml.at(ns("//bibdata/ext/meeting"))&.text
          set(:meeting, a)
          set(:meeting_acronym, a)
        end
        a = xml.at(ns("//bibdata/ext/meeting/@acronym"))&.text and
          set(:meeting_acronym, a)
        a = xml.at(ns("//bibdata/ext/meeting-place"))&.text and
          set(:meeting_place, a)
        a = xml.at(ns("//bibdata/ext/intended-type"))&.text and
          set(:intended_type, a)
        a = xml.at(ns("//bibdata/ext/source"))&.text and set(:source, a)
        meeting(xml)
      end

      def meeting(xml)
        resolution =
          xml.at(ns("//bibdata/ext/doctype"))&.text == "resolution"
        if o = xml.at(ns("//bibdata/ext/meeting-date/on"))&.text
          set(:meeting_date, resolution ? ddMMMMYYYY(o, nil) : ddMMMYYYY(o))
        elsif f = xml.at(ns("//bibdata/ext/meeting-date/from"))&.text
          t = xml.at(ns("//bibdata/ext/meeting-date/to"))&.text
          set(:meeting_date,
              resolution ? ddMMMMYYYY(f, t) : "#{ddMMMYYYY(f)}/#{ddMMMYYYY(t)}")
        end
      end
    end
  end
end

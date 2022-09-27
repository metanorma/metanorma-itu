require_relative "init"
require "roman-numerals"
require "isodoc"
require_relative "../../relaton/render/general"

module IsoDoc
  module ITU
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def initialize(options)
        @hierarchical_assets = options[:hierarchical_assets]
        super
      end

      def prefix_container(container, linkend, _target)
        l10n("#{linkend} #{@i18n.get['in']} #{@xrefs.anchor(container, :xref)}")
      end

      def eref(docxml)
        docxml.xpath(ns("//eref")).each do |f|
          eref1(f)
        end
      end

      def origin(docxml)
        docxml.xpath(ns("//origin[not(termref)]")).each do |f|
          eref1(f)
        end
      end

      def quotesource(docxml)
        docxml.xpath(ns("//quote/source")).each do |f|
          eref1(f)
        end
      end

      def eref1(elem)
        get_eref_linkend(elem)
      end

      def note1(elem)
        return if elem["type"] == "title-footnote"

        super
      end

      def get_eref_linkend(node)
        contents = non_locality_elems(node).select do |c|
          !c.text? || /\S/.match(c)
        end
        return unless contents.empty?

        link = anchor_linkend(node,
                              docid_l10n(node["target"] || node["citeas"]))
        link && !/^\[.*\]$/.match(link) and link = "[#{link}]"
        link += eref_localities(node.xpath(ns("./locality | ./localityStack")),
                                link, node)
        non_locality_elems(node).each(&:remove)
        node.add_child(link)
      end

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
        case bib&.at(ns("./ext/doctype"))&.text
        when "service-publication" then bibdata_title_service_population(bib)
        when "resolution" then bibdata_title_resolution(bib)
        end
      end

      def bibdata_title_resolution(bib)
        place = bib&.at(ns("./ext/meeting-place"))&.text
        ed = bib&.at(ns("./edition"))&.text
        rev = ed && ed != "1" ? "#{@i18n.get['revision_abbreviation']} " : ""
        year = bib&.at(ns("./ext/meeting-date/from | ./ext/meeting-date/on"))
          &.text&.gsub(/-.*$/, "")
        num = bib&.at(ns("./docnumber"))&.text
        text = @i18n.l10n("#{@i18n.get['doctype_dict']['resolution'].upcase} "\
                          "#{num} (#{rev}#{place}, #{year})")
        ins = bib.at(ns("./title"))
        ins.next = <<~INS
          <title language="#{@lang}" format="text/plain" type="resolution">#{text}</title>
          <title language="#{@lang}" format="text/plain" type="resolution-placedate">#{place}, #{year}</title>
        INS
      end

      def bibdata_title_service_population(bib)
        date = bib&.at(ns("./date[@type = 'published']"))&.text or return
        text = l10n(@i18n.get["position_on"].sub(/%/, ddmmmmyyyy(date)))
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

      def bibrenderer
        ::Relaton::Render::ITU::General.new(language: @lang)
      end

      def bibrender_formattedref(formattedref, _xml)
        formattedref << "." unless /\.$/.match?(formattedref.text)
      end

      def bibrender_relaton(xml, renderings)
        f = renderings[xml["id"]][:formattedref]
        f &&= "<formattedref>#{f}</formattedref>"
        # retain date in order to generate reference tag
        xml.children =
          "#{f}#{xml.xpath(ns('./docidentifier | ./uri | ./note | ./date')).to_xml}"
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
            dn.next.children = @i18n.l10n("#{@i18n.get[w]} #{dn&.text}")
          end
        end
      end

      def twitter_cldr_localiser_symbols
        { group: "'" }
      end

      def clause1(elem)
        return super unless elem&.at(ns("//bibdata/ext/doctype"))&.text ==
          "resolution"
        return super unless %w(sections bibliography).include? elem.parent.name
        return if @suppressheadingnumbers || elem["unnumbered"]

        t = elem.at(ns("./title")) and t["depth"] = "1"
        lbl = @xrefs.anchor(elem["id"], :label, false) or return
        elem.elements.first.previous =
          "<p keep-with-next='true' class='supertitle'>"\
          "#{@i18n.get['section'].upcase} #{lbl}</p>"
      end

      def annex1(elem)
        return super unless elem.at(ns("//bibdata/ext/doctype"))&.text ==
          "resolution"

        lbl = @xrefs.anchor(elem["id"], :label)
        res = elem.at(ns("//bibdata/title[@type = 'resolution']"))
        subhead = @i18n.l10n("(#{@i18n.get['to']} #{res.children.to_xml})")
        elem.elements.first.previous =
          "<p class='supertitle'>#{lbl}<br/>#{subhead}</p>"
        t = elem.at(ns("./title")) and
          t.children = "<strong>#{t.children.to_xml}</strong>"
      end

      def ol_depth(node)
        return super unless node["class"] == "steps" ||
          node.at(".//ancestor::xmlns:ol[@class = 'steps']")

        depth = node.ancestors("ul, ol").size + 1
        type = :arabic
        type = :alphabet if [2, 7].include? depth
        type = :roman if [3, 8].include? depth
        type = :alphabet_upper if [4, 9].include? depth
        type = :roman_upper if [5, 10].include? depth
        type
      end

      def info(isoxml, out)
        @meta.ip_notice_received isoxml, out
        @meta.techreport isoxml, out
        super
      end

      include Init
    end
  end
end

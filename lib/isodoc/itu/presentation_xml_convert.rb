require_relative "init"
require "roman-numerals"
require "isodoc"

module IsoDoc
  module ITU
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def initialize(options)
        @hierarchical_assets = options[:hierarchical_assets]
        super
      end

      def prefix_container(container, linkend, _target)
        l10n("#{linkend} #{@i18n.get["in"]} #{@xrefs.anchor(container, :xref)}")
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

      def eref1(f)
        get_eref_linkend(f)
      end

      def note1(f)
        return if f["type"] == "title-footnote"
        super
      end

      def get_eref_linkend(node)
        contents = non_locality_elems(node).select do |c|
          !c.text? || /\S/.match(c)
        end
        return unless contents.empty?
        link = anchor_linkend(node, docid_l10n(node["target"] || node["citeas"]))
        link && !/^\[.*\]$/.match(link) and link = "[#{link}]"
        link += eref_localities(node.xpath(ns("./locality | ./localityStack")), link)
        non_locality_elems(node).each { |n| n.remove }
        node.add_child(link)
      end

      def bibdata_i18n(b)
        super
        bibdata_dates(b)
        bibdata_title(b)
        amendment_id(b)
      end

      def bibdata_dates(b)
        b.xpath(ns("./date")).each do |d|
          d.next = d.dup
          d.next["format"] = "ddMMMyyyy"
          d.next.children = ddMMMyyyy(d.text)
        end
      end

      def bibdata_title(b)
        case b&.at(ns("./ext/doctype"))&.text 
        when "service-publication" then bibdata_title_service_population(b)
        when "resolution" then bibdata_title_resolution(b)
        end
      end

      def bibdata_title_resolution(b)
        num = b&.at(ns("./docnumber"))&.text
        place = b&.at(ns("./ext/meeting-place"))&.text
        ed = b&.at(ns("./edition"))&.text
        rev = (ed && ed != "1")  ? "#{@i18n.get["revision_abbreviation"]} " : ""
        year = b&.at(ns("./ext/meeting-date/from | ./ext/meeting-date/on"))&.text&.gsub(/-.*$/, "")
        num = b&.at(ns("./docnumber"))&.text
        text = @i18n.l10n("#{@i18n.get['doctype_dict']['resolution'].upcase} #{num} (#{rev}#{place}, #{year})")
        ins = b.at(ns("./title"))
        ins.next = <<~END
        <title language="#{@lang}" format="text/plain" type="resolution">#{text}</title>
        <title language="#{@lang}" format="text/plain" type="resolution-placedate">#{place}, #{year}</title>
        END
      end

      def bibdata_title_service_population(b)
        date = b&.at(ns("./date[@type = 'published']"))&.text or return
        text = l10n(@i18n.get["position_on"].sub(/%/, ddmmmmyyyy(date)))
        ins = b.at(ns("./title"))
        ins.next = <<~END
        <title language="#{@lang}" format="text/plain" type="position-sp">#{text}</title>
        END
      end

      def ddMMMyyyy(date)
        d = date.split(/-/).map { |x| x.sub(/^0/, "") }
        if @lang == "zh"
          d[0] += "年" if d.dig(0)
          d[1] += "月" if d.dig(1)
          d[2] += "日" if d.dig(2)
          d.join("")
        elsif @lang == "ar"
          d[1] = ::RomanNumerals.to_roman(d[1].to_i).upcase if d.dig(1)
          d.join(".")
        else
          d[1] = ::RomanNumerals.to_roman(d[1].to_i).upcase if d.dig(1)
          d.reverse.join(".")
        end
      end

      def ddmmmmyyyy(date)
        if @lang == "zh"
          ddMMMyyyy(date)
        else
          d = date.split(/-/)
          d[1] = @meta.months[d[1].to_sym] if d.dig(1)
          d[2] = d[2].sub(/^0/, "") if d.dig(2)
          l10n(d.reverse.join(" "))
        end
      end

      def amendment_id(b)
        %w(amendment corrigendum).each do |w|
          if dn = b.at(ns("./ext/structuredidentifier/#{w}"))
            dn["language"] = ""
            dn.next = dn.dup
            dn.next["language"] = @lang
            dn.next.children = @i18n.l10n("#{@i18n.get[w]} #{dn&.text}")
          end
        end
      end

      def twitter_cldr_localiser_symbols
        {group: "'"}
      end

      def clause1(f)
        return super unless f&.at(ns("//bibdata/ext/doctype"))&.text == "resolution"
        return super unless %w(sections bibliography).include? f.parent.name
        return if @suppressheadingnumbers || f["unnumbered"]
        t = f.at(ns("./title")) and t["depth"] = "1"
        lbl = @xrefs.anchor(f['id'], :label, false) or return
        f.elements.first.previous =
          "<p keep-with-next='true' class='supertitle'>#{@i18n.get['section'].upcase} #{lbl}</p>"
      end

      def annex1(f)
        return super unless f&.at(ns("//bibdata/ext/doctype"))&.text == "resolution"
        lbl = @xrefs.anchor(f['id'], :label)
        subhead = (@i18n.l10n("(#{@i18n.get['to']} ") + 
                   f.at(ns("//bibdata/title[@type = 'resolution']")).children.to_xml + @i18n.l10n(")"))
        f.elements.first.previous = "<p align='center'>#{lbl}<br/>#{subhead}</p>"
        if t = f.at(ns("./title"))
          t.children = "<strong>#{t.children.to_xml}</strong>"
        end
      end

      include Init
    end
  end
end


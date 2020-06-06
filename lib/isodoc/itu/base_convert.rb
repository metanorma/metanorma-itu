require "isodoc"
require_relative "metadata"
require "fileutils"
require_relative "./ref.rb"
require_relative "./xref.rb"
require_relative "./terms.rb"

module IsoDoc
  module ITU
    module BaseConvert
      def load_yaml(lang, script)
        y = if @i18nyaml then YAML.load_file(@i18nyaml)
            elsif lang == "en"
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-en.yaml"))
            else
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-en.yaml"))
            end
        super.merge(y)
      end

      def metadata_init(lang, script, labels)
        @meta = Metadata.new(lang, script, labels)
      end

      FRONT_CLAUSE = "//*[parent::preface]"\
        "[not(local-name() = 'abstract')]".freeze

      def preface(isoxml, out)
        isoxml.xpath(ns(FRONT_CLAUSE)).each do |c|
          title = c&.at(ns("./title"))
          out.div **attr_code(id: c["id"]) do |s|
            clause_name(nil, title, s, class: "IntroTitle")
            c.elements.reject { |c1| c1.name == "title" }.each do |c1|
              parse(c1, s)
            end
          end
        end
      end

      def bracket_opt(b)
        return b if b.nil?
        return b if /^\[.+\]$/.match(b)
        "[#{b}]"
      end

      def clausedelim
        ""
      end

      def note_label(node)
        n = get_anchors[node["id"]]
        (n.nil? || n[:label].nil? || n[:label].empty?) and
          return "#{@note_lbl} &ndash; "
        l10n("#{@note_lbl} #{n[:label]} &ndash; ")
      end

      def prefix_container(container, linkend, _target)
        l10n("#{linkend} #{@labels["in"]} #{anchor(container, :xref)}")
      end

      def ol_depth(node)
        return super unless node["class"] == "steps" or
          node.at(".//ancestor::xmlns:ol[@class = 'steps']")
        depth = node.ancestors("ul, ol").size + 1
        type = :arabic
        type = :alphabet if [2, 7].include? depth
        type = :roman if [3, 8].include? depth
        type = :alphabet_upper if [4, 9].include? depth
        type = :roman_upper if [5, 10].include? depth
        ol_style(type)
      end

      def annex_name(annex, name, div)
        r_a = @meta.get[:doctype_original] == "recommendation-annex"
        div.h1 **{ class: r_a ? "RecommendationAnnex" : "Annex" } do |t|
          t << "#{anchor(annex['id'], :label)} "
          t.br
          t.br
          t.b do |b|
            name&.children&.each { |c2| parse(c2, b) }
          end
        end
        annex_obligation_subtitle(annex, div)
      end

      def annex_obligation_subtitle(annex, div)
        info = annex["obligation"] == "informative"
        div.p **{class: "annex_obligation" } do |p|
          p << (info ? @inform_annex_lbl : @norm_annex_lbl).
            sub(/%/, @meta.get[:doctype] || "")
        end
      end

      def annex(isoxml, out)
      isoxml.xpath(ns("//annex")).each do |c|
        @meta.get[:doctype_original] == "recommendation-annex" or
          page_break(out)
        out.div **attr_code(id: c["id"], class: "Section3") do |s|
          annex_name(c, nil, s) unless c.at(ns("./title"))
          c.elements.each do |c1|
            if c1.name == "title" then annex_name(c, c1, s)
            else
              parse(c1, s)
            end
          end
        end
      end
    end

      def i18n_init(lang, script)
        super
      end

      def fileloc(loc)
        File.join(File.dirname(__FILE__), loc)
      end

      def cleanup(docxml)
        super
        term_cleanup(docxml)
        refs_cleanup(docxml)
        title_cleanup(docxml)
      end

      def title_cleanup(docxml)
        docxml.xpath("//h1[@class = 'RecommendationAnnex']").each do |h|
          h.name = "p"
          h["class"] = "h1Annex"
        end
        docxml
      end

      def term_cleanup(docxml)
        docxml.xpath("//p[@class = 'Terms']").each do |d|
          h2 = d.at("./preceding-sibling::*[@class = 'TermNum'][1]")
          d.children.first.previous = "<b>#{h2.children.to_xml}</b>&nbsp;"
          d["id"] = h2["id"]
          h2.remove
        end
        docxml.xpath("//p[@class = 'TermNum']").each do |d|
          d1 = d.next_element and d1.name == "p" or next
          d1.children.each { |e| e.parent = d }
          d1.remove
        end
        docxml
      end

      def refs_cleanup(docxml)
        docxml.xpath("//tx[following-sibling::tx]").each do |tx|
          tx << tx.next_element.remove.children
        end
        docxml.xpath("//tx").each do |tx|
          tx.name = "td"
          tx["colspan"] = "2"
          tx.wrap("<tr></tr>")
        end
        docxml
      end

      def info(isoxml, out)
        @meta.keywords isoxml, out
        @meta.ip_notice_received isoxml, out
        super
      end

      def get_eref_linkend(node)
        l = anchor_linkend(node, docid_l10n(node["target"] || node["citeas"]))
        l && !/^\[.*\]$/.match(l) and l = "[#{l}]"
        l += eref_localities(node.xpath(ns("./locality | ./localityStack")), l)
        contents = node.children.select do |c|
          !%w{locality localityStack}.include? c.name
        end
        return l if contents.nil? || contents.empty?
        Nokogiri::XML::NodeSet.new(node.document, contents).to_xml
      end

      def eref_parse(node, out)
        linkend = get_eref_linkend(node)
        if node["type"] == "footnote"
          out.sup do |s|
            s.a(**{ "href": "#" + node["bibitemid"] }) { |l| l << linkend }
          end
        else
          out.a(**{ "href": "#" + node["bibitemid"] }) { |l| l << linkend }
        end
      end

      def middle_title(out)
        out.p(**{ class: "zzSTDTitle1" }) do |p|
          id = @meta.get[:docnumber] and p << "#{@meta.get[:doctype]} #{id}" 
        end
        out.p(**{ class: "zzSTDTitle2" }) { |p| p << @meta.get[:doctitle] }
        s = @meta.get[:docsubtitle] and
          out.p(**{ class: "zzSTDTitle3" }) { |p| p << s }
      end

      def add_parse(node, out)
        out.span **{class: "addition"} do |e|
          node.children.each { |n| parse(n, e) }
        end
      end

      def del_parse(node, out)
        out.span **{class: "deletion"} do |e|
          node.children.each { |n| parse(n, e) }
        end
      end

      def error_parse(node, out)
        case node.name
        when "add" then add_parse(node, out)
        when "del" then del_parse(node, out)
        else
          super
        end
      end

      def note_p_parse(node, div)
        div.p do |p|
          p.span **{ class: "note_label" } do |s|
            s << note_label(node)
          end
          node.first_element_child.children.each { |n| parse(n, p) }
        end
        node.element_children[1..-1].each { |n| parse(n, div) }
      end

      def note_parse1(node, div)
        div.p do |p|
          p.span **{ class: "note_label" } do |s|
            s << note_label(node)
          end
        end
        node.children.each { |n| parse(n, div) }
      end

      def table_footnote_reference_format(a)
        a.content = a.content + ")"
      end
    end
  end
end

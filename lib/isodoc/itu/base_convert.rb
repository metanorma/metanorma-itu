require "isodoc"
require_relative "metadata"
require "fileutils"
require_relative "./ref.rb"
require_relative "./xref.rb"

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
            clause_name(nil, title&.content, s, class: "IntroTitle")
            c.elements.reject { |c1| c1.name == "title" }.each do |c1|
              parse(c1, s)
            end
          end
        end
      end

      def clausedelim
        ""
      end

      def formula_where(dl, out)
      return unless dl
      out.p { |p| p << l10n("#{@where_lbl}:") }
      parse(dl, out)
    end

      def prefix_container(container, linkend, _target)
        require "byebug"; byebug
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
        div.h1 **{ class: "Annex" } do |t|
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
        type = annex&.document&.root&.at("//bibdata/ext/doctype")&.text ||
          "recommendation"
        type = type.split(" ").map {|w| w.capitalize }.join(" ")
        info = annex["obligation"] == "informative"
        div.p **{class: "annex_obligation" } do |p|
          p << (info ? @inform_annex_lbl : @norm_annex_lbl).sub(/%/, type)
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
      end

      def term_cleanup(docxml)
        docxml.xpath("//p[@class = 'Terms']").each do |d|
          h2 = d.at("./preceding-sibling::*[@class = 'TermNum'][1]")
          h2.add_child("&nbsp;")
          h2.add_child(d.remove)
        end
        docxml.xpath("//p[@class = 'TermNum']").each do |d|
          d1 = d.next_element and d1.name == "p" or next
          d1.children.each { |e| e.parent = d }
          d1.remove
        end
        docxml
      end

      def info(isoxml, out)
        @meta.keywords isoxml, out
        @meta.ip_notice_received isoxml, out
        super
      end

      def terms_defs_title(node)
        t = node.at(ns("./title")) and return t.text
        super
      end

      def terms_defs(node, out, num)
        f = node.at(ns(IsoDoc::Convert::TERM_CLAUSE)) or return num
        out.div **attr_code(id: f["id"]) do |div|
          num = num + 1
          clause_name(num, terms_defs_title(f), div, nil)
          if f.at(ns("./clause | ./terms | ./term")).nil? then out.p "None."
          else
            f.children.reject { |c1| c1.name == "title" }.each do |c1|
              parse(c1, div)
            end
          end
        end
        num
      end

      def terms_parse(node, out)
        out.div **attr_code(id: node["id"]) do |div|
          clause_parse_title(node, div, node.at(ns("./title")), out)
          if node.at(ns("./clause | ./term")).nil? then out.p "None."
          else
            node.children.reject { |c1| c1.name == "title" }.each do |c1|
              parse(c1, div)
            end
          end
        end
      end

      def termdef_parse1(node, div, term, defn, source)
        div.p **{ class: "TermNum", id: node["id"] } do |p|
          p.b do |b|
            b << anchor(node["id"], :label)
            insert_tab(b, 1)
            term.children.each { |n| parse(n, b) }
          end
          source and p << " [#{source.value}]"
          p << ": "
        end
        defn and defn.children.each { |n| parse(n, div) }
      end

      def termdef_parse(node, out)
        term = node.at(ns("./preferred"))
        defn = node.at(ns("./definition"))
        source = node.at(ns("./termsource/origin/@citeas"))
        out.div **attr_code(id: node["id"]) do |div|
          termdef_parse1(node, div, term, defn, source)
          set_termdomain("")
          node.children.each do |n|
            next if %w(preferred definition termsource title).include? n.name
            parse(n, out)
          end
        end
      end

      def get_eref_linkend(node)
        link = "[#{anchor_linkend(node, docid_l10n(node["target"] || node["citeas"]))}]"
        link += eref_localities(node.xpath(ns("./locality")), link)
        contents = node.children.select { |c| c.name != "locality" }
        return link if contents.nil? || contents.empty?
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
          id = @meta.get[:docidentifier] and p << "Recommendation #{id}" 
        end
        out.p(**{ class: "zzSTDTitle2" }) { |p| p << @meta.get[:doctitle] }
      end

      def make_table_footnote_target(out, fnid, fnref)
        attrs = { id: fnid, class: "TableFootnoteRef" }
        out.span do |s|
          out.span **attrs do |a|
            a << fnref + ")"
          end
          insert_tab(s, 1)
        end
      end
    end
  end
end

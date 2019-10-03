require "isodoc"
require_relative "metadata"
require "fileutils"

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

      def annex_name(annex, name, div)
        div.h1 **{ class: "Annex" } do |t|
          t << "#{anchor(annex['id'], :label)} "
          t.br
          t.br
          t.b do |b|
            name&.children&.each { |c2| parse(c2, b) }
          end
        end
        type = annex&.document&.root&.at("//bibdata/ext/doctype")&.text || "recommendation"
        type = type.split(" ").map {|w| w.capitalize }.join(" ")
        info = annex["obligation"] == "informative"
        div.p { |p| p << (info ? @inform_annex_lbl : @norm_annex_lbl).sub(/%/, type) }
      end

      def annex_name_lbl(clause, num)
        lbl = clause["obligation"] == "informative" ? @appendix_lbl : @annex_lbl
        l10n("<b>#{lbl} #{num}</b>")
      end

      def annex_names(clause, num)
        lbl = clause["obligation"] == "informative" ? @appendix_lbl : @annex_lbl
        @anchors[clause["id"]] = { label: annex_name_lbl(clause, num), type: "clause",
                                   xref: "#{lbl} #{num}", level: 1 }
        clause.xpath(ns("./clause")).each_with_index do |c, i|
          annex_names1(c, "#{num}.#{i + 1}", 2)
        end
        hierarchical_asset_names(clause, num)
      end

      def back_anchor_names(docxml)
        super
        if annexid = docxml&.at(ns("//bibdata/ext/structuredidentifier/annexid"))&.text
          docxml.xpath(ns("//annex")).each { |c| annex_names(c, annexid) }
        else
          docxml.xpath(ns("//annex[@obligation = 'informative']")).each_with_index do |c, i|
            annex_names(c, RomanNumerals.to_roman(i + 1))
          end
          docxml.xpath(ns("//annex[not(@obligation = 'informative')]")).each_with_index do |c, i|
            annex_names(c, (65 + i + (i > 7 ? 1 : 0)).chr.to_s)
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
      end

      def term_cleanup(docxml)
        docxml.xpath("//p[@class = 'Terms']").each do |d|
          h2 = d.at("./preceding-sibling::*[@class = 'TermNum'][1]")
          h2.add_child("&nbsp;")
          h2.add_child(d.remove)
        end
        docxml
      end

      def info(isoxml, out)
        @meta.keywords isoxml, out
        @meta.ip_notice_received isoxml, out
        super
      end

      def initial_anchor_names(d)
        d.xpath("//xmlns:preface/child::*").each do |c|
          preface_names(c)
        end
        sequential_asset_names(d.xpath("//xmlns:preface/child::*"))
        n = section_names(d.at(ns("//clause[title = 'Scope']")), 0, 1)
        n = section_names(d.at(ns("//bibliography/clause[title = 'References'] | "\
                                  "//bibliography/references[title = 'References']")), n, 1)
        n = section_names(d.at(ns("//sections/terms | "\
                                  "//sections/clause[descendant::terms]")), n, 1)
        n = section_names(d.at(ns("//sections/definitions")), n, 1)
        clause_names(d, n)
        middle_section_asset_names(d)
        termnote_anchor_names(d)
        termexample_anchor_names(d)
      end

      def norm_ref(isoxml, out, num)
        q = "//bibliography/references[title = 'References']"
        f = isoxml.at(ns(q)) or return num
        out.div do |div|
          num = num + 1
          clause_name(num, @normref_lbl, div, nil)
          biblio_list(f, div, false)
        end
        num
      end

      def nonstd_bibitem(list, b, ordinal, biblio)
        list.p **attr_code(iso_bibitem_entry_attrs(b, biblio)) do |ref|
          ref << "[#{render_identifier(bibitem_ref_code(b))}]"
          date_note_process(b, ref)
          insert_tab(ref, 1)
          reference_format(b, ref)
        end
      end

      def std_bibitem_entry(list, b, ordinal, biblio)
        nonstd_bibitem(list, b, ordinal, biblio)
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
          title = node.at(ns("./title"))&.text&.downcase
          title == "terms defined elsewhere" and out.p @labels["elsewhere_terms"]
          title == "terms defined in this recommendation" and out.p @labels["here_terms"]
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
          defn and defn.children.each { |n| parse(n, p) }
        end
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
    end
  end
end

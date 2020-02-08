require "asciidoctor"
require "asciidoctor/standoc/converter"
require "fileutils"
require_relative "./front.rb"
require_relative "./validate.rb"
require_relative "./cleanup.rb"
require_relative "./macros.rb"

module Asciidoctor
  module ITU
    # A {Converter} implementation that generates RSD output, and a document
    # schema encapsulation of the document for validation
    #
    class Converter < Standoc::Converter
      XML_ROOT_TAG = "itu-standard".freeze
      XML_NAMESPACE = "https://www.metanorma.com/ns/itu".freeze

      register_for "itu"

      Asciidoctor::Extensions.register do
        inline_macro AddMacro
        inline_macro DelMacro
      end

      def title_validate(root)
        nil
      end

      def init(node)
        super
        @smartquotes = node.attr("smartquotes") == "true"
      end

      def makexml(node)
        @draft = node.attributes.has_key?("draft")
        super
      end

      def doctype(node)
        ret = node.attr("doctype") || "recommendation"
        ret = "recommendation" if ret == "article"
        ret
      end

      def olist(node)
        noko do |xml|
          xml.ol **attr_code(id: Asciidoctor::Standoc::Utils::anchor_or_uuid(node),
                             class: node.attr("class")) do |xml_ol|
            node.items.each { |item| li(xml_ol, item) }
          end
        end.join("\n")
      end

      def clause_parse(attrs, xml, node)
        attrs[:preface] = true if node.attr("style") == "preface"
        super
      end

      def move_sections_into_preface(x, preface)
        x.xpath("//clause[@preface]").each do |c|
          c.delete("preface")
          preface.add_child c.remove
        end
      end

      def make_preface(x, s)
        s.add_previous_sibling("<preface/>") unless x.at("//preface")
        make_abstract(x, s)
        move_sections_into_preface(x, x.at("//preface"))
      end

      def document(node)
        init(node)
        ret1 = makexml(node)
        ret = ret1.to_xml(indent: 2)
        unless node.attr("nodoc") || !node.attr("docfile")
          filename = node.attr("docfile").gsub(/\.adoc/, ".xml").
            gsub(%r{^.*/}, "")
          File.open(filename, "w") { |f| f.write(ret) }
          html_converter(node).convert filename unless node.attr("nodoc")
          word_converter(node).convert filename unless node.attr("nodoc")
          pdf_converter(node).convert filename unless node.attr("nodoc")
        end
        @files_to_delete.each { |f| FileUtils.rm f }
        ret
      end

      def validate(doc)
        content_validate(doc)
        schema_validate(formattedstr_strip(doc.dup),
                        File.join(File.dirname(__FILE__), "itu.rng"))
      end

      def style(n, t)
        return
      end

      def section(node)
        a = section_attributes(node)
        noko do |xml|
          case sectiontype(node)
          when "references" then norm_ref_parse(a, xml, node)
          when "terms and definitions",
            "terms, definitions, symbols and abbreviated terms",
            "terms, definitions, symbols and abbreviations",
            "terms, definitions and symbols",
            "terms, definitions and abbreviations",
            "terms, definitions and abbreviated terms",
            "definitions"
            @term_def = true
            term_def_parse(a, xml, node, true)
            @term_def = false
          when "symbols and abbreviated terms",
            "symbols",
            "abbreviated terms",
            "abbreviations",
            "abbreviations and acronyms"
            symbols_parse(a, xml, node)
          when "bibliography" then bibliography_parse(a, xml, node)
          else
            if @term_def then term_def_subclause_parse(a, xml, node)
            elsif @definitions then symbols_parse(a, xml, node)
            elsif @biblio then bibliography_parse(a, xml, node)
            elsif node.attr("style") == "bibliography"
              bibliography_parse(a, xml, node)
            elsif node.attr("style") == "abstract"
              abstract_parse(a, xml, node)
            elsif node.attr("style") == "appendix" && node.level == 1
              annex_parse(a, xml, node)
            else
              clause_parse(a, xml, node)
            end
          end
        end.join("\n")
      end

      def norm_ref_parse(attrs, xml, node)
        @norm_ref = true
        xml.references **attr_code(attrs) do |xml_section|
          xml_section.title { |t| t << "References" }
          xml_section << node.content
        end
        @norm_ref = false
      end

      def term_def_title(toplevel, node)
        return node.title unless toplevel
        "Definitions"
      end

      def terms_extract(div)
        internal = nil
        external = nil
        div.parent.xpath("./terms/title").each do |t|
          case t&.text&.downcase
          when "terms defined elsewhere" then external = t
          when "terms defined in this recommendation" then internal = t
          end
        end
        [internal, external]
      end

      def term_defs_boilerplate(div, source, term, preface, isodoc)
        internal, external = terms_extract(div)
        internal&.next_element&.name == "term" and
          internal.next = "<p>#{@internal_terms_boilerplate}</p>"
        internal and internal&.next_element == nil and
          internal.next = "<p>#{@no_terms_boilerplate}</p>"
        external&.next_element&.name == "term" and
          external.next = "<p>#{@external_terms_boilerplate}</p>"
        external and external&.next_element == nil and
          external.next = "<p>#{@no_terms_boilerplate}</p>"
        !internal and !external and
          %w(term terms).include? div&.next_element&.name and
          div.next = "<p>#{@term_def_boilerplate}</p>"
      end

      NORM_REF = "//bibliography/references[title = 'References']".freeze

      def load_yaml(lang, script)
        y = if @i18nyaml then YAML.load_file(@i18nyaml)
            elsif lang == "en"
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-en.yaml"))
            else
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-en.yaml"))
            end
        @symbols_boilerplate = y["symbols_boilerplate"] || ""
        super.merge(y)
      end

      def i18n_init(lang, script)
        super
      end

      def html_extract_attributes(node)
        super.merge(hierarchical_assets: node.attr("hierarchical-assets"))
      end

      def doc_extract_attributes(node)
        super.merge(hierarchical_assets: node.attr("hierarchical-assets"))
      end

      def html_converter(node)
        IsoDoc::ITU::HtmlConvert.new(html_extract_attributes(node))
      end

      def pdf_converter(node)
        IsoDoc::ITU::PdfConvert.new(html_extract_attributes(node))
      end

      def word_converter(node)
        IsoDoc::ITU::WordConvert.new(doc_extract_attributes(node))
      end
    end
  end
end

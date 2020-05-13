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
      XML_NAMESPACE = "https://www.metanorma.org/ns/itu".freeze

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
        @no_insert_missing_sections = doctype(node) != "recommendation" ||
          node.attr("legacy-do-not-insert-missing-sections")
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
        id = Asciidoctor::Standoc::Utils::anchor_or_uuid(node)
        noko do |xml|
          xml.ol **attr_code(id: id, class: node.attr("class")) do |xml_ol|
            node.items.each { |item| li(xml_ol, item) }
          end
        end.join("\n")
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
        @log.write(@localdir + @filename + ".err") unless @novalid
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

      def sectiontype_streamline(ret)
        case ret
        when "definitions" then "terms and definitions"
        when "abbreviations and acronyms" then "symbols and abbreviated terms"
        when "references" then "normative references"
        else
          super
        end
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
        super.merge(hierarchical_assets: node.attr("hierarchical-object-numbering"))
      end

      def doc_extract_attributes(node)
        super.merge(hierarchical_assets: node.attr("hierarchical-object-numbering"))
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
